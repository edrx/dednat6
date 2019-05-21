-- diagmiddle.lua: words for drawing arrows between the sides of rectangles.
-- This file:
--   http://angg.twu.net/dednat6/diagmiddle.lua.html
--   http://angg.twu.net/dednat6/diagmiddle.lua
--                    (find-dn6 "diagmiddle.lua")
-- Author: Eduardo Ochs <eduardoochs@gmail.com>
-- Version: 2011may09
-- License: GPL3
--
-- This corresponds to:
--   (find-dn4 "experimental.lua" "splitdist")
-- and at the moment (?) it is not included by default in dednat6.
-- The test that uses this file is at:
--   (find-dn6 "tests/test3.tex")



-- «.midpoint»		(to "midpoint")
-- «.midpoint-tests»	(to "midpoint-tests")
-- «.splitdist»		(to "splitdist")
-- «.splitdists»	(to "splitdists")



require "diagforth"    -- (find-dn6 "diagforth.lua")

phantomnode = "\\phantom{O}"



-- «midpoint» (to ".midpoint")
forths["midpoint"] = function ()
    -- local node1, node2 = ds[2], ds[1]
    local node1, node2 = ds:pick(1), ds:pick(0)
    local midx, midy = (node1.x + node2.x)/2, (node1.y + node2.y)/2
    ds:pock(1, storenode{x=midx, y=midy, TeX=phantomnode})
    ds:pop()
  end

-- «midpoint-tests» (to ".midpoint-tests")
-- (find-dn6 "diagforth.lua" "high-level-tests")
--[==[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "diagmiddle.lua"

na = function (nodeid)
    local n = nodes[tonumber(nodeid) or nodeid]
    return "("..n.x..","..n.y.."):"..(n.tag or "")
  end
nas = function (str) return (str:gsub("%S+", na)) end

run = dxyrun
run [[ 2Dx     100     +20 ]]
run [[ 2D 100 a,b <=== a   ]]
run [[ 2D      -       -   ]]
run [[ 2D      |  <->  |   ]]
run [[ 2D      v       v   ]]
run [[ 2D +20  c ==> b|->c ]]
= nas "1 2 3 4"
= nas "a c"

PP(xs)
PP(lasty)                 --> 120
PP(nodes)
PP(nodes["a"])
PP(nodes["a,b"])

--]==]



-- Words for drawing arrows in the middle of rectangles.
-- Actually these words build the vertex nodes for those arrows.
--    "harrownodes" is for horizontal arrows,
--    "varrownodes" is for vertical arrows,
--   "dharrownodes" and
--   "dvarrownodes" are for diagonal arrows.
-- They all expect two nodes on the stack, "node1" and "node2", and
-- they read three parameters with getwordasluaexpr(): "dx0", "dx1",
-- and "dx2" (or "dy0", "dy1" and "dy2").
--   "dx0" controls how far from "node1" the arrow starts,
--   "dx1" controls the length of the arrow,
--   "dx2" controls how far from "node2" the arrow starts.
-- Some of dx0, dx1, and dx2 can be nil; see "splitdist" below.
--   "harrownodes" uses y = (node1.y+node2.y)/2.
--   "varrownodes" uses x = (node1.x+nodex.y)/2.
-- This needs more documentation. Sorry.
-- Also, the "\phantom{O}" shouldn't be hardcoded.

-- «splitdist»  (to ".splitdist")
splitdist = function (x1, x2, dx0, dx1, dx2)
    local dx = x2-x1
    local rest = dx-(dx0 or 0)-(dx1 or 0)-(dx2 or 0)
    local type = (dx0 and "n" or "_")..(dx1 and "n" or "_")..
                 (dx2 and "n" or "_")
    if type=="_n_" then
      return x1+rest/2, x2-rest/2
    elseif type=="n_n" then
      return x1+dx0, x2-dx2
    elseif type=="nn_" then
      return x1+dx0+rest/2, x2-rest/2
    elseif type=="_nn" then
      return x1+rest/2, x2-dx2-rest/2
    end
    local p = function (n) return n or "nil" end
    print("Bad splitdist pattern: "..p(dx0).." "..p(dx1).." "..p(dx2))
  end

harrownodes = function (dx0, dx1, dx2, TeX1, TeX2)
    local node1, node2 = ds:pick(1), ds:pick(0)
    local midy = (node1.y + node2.y)/2
    local x1, x2 = splitdist(node1.x, node2.x, dx0, dx1, dx2)
    ds:push(storenode{x=x1, y=midy, TeX=(TeX1 or phantomnode)})
    ds:push(storenode{x=x2, y=midy, TeX=(TeX2 or phantomnode)})
  end
varrownodes = function (dy0, dy1, dy2, TeX1, TeX2)
    local node1, node2 = ds:pick(1), ds:pick(0)
    local midx = (node1.x + node2.x)/2
    local y1, y2 = splitdist(node1.y, node2.y, dy0, dy1, dy2)
    ds:push(storenode{x=midx, y=y1, TeX=(TeX1 or phantomnode)})
    ds:push(storenode{x=midx, y=y2, TeX=(TeX2 or phantomnode)})
  end

forths["harrownodes"] = function ()
    harrownodes(getwordasluaexpr(), getwordasluaexpr(), getwordasluaexpr())
  end
forths["varrownodes"] = function ()
    varrownodes(getwordasluaexpr(), getwordasluaexpr(), getwordasluaexpr())
  end



-- «splitdists» (to ".splitdists")
-- (find-dn4file "experimental.lua" "dharrownodes = ")
proportional = function (w0, w1, w2, z0, z2)
    local way = (w1 - w0)/(w2 - w0)
    return z0 + (z2 - z0)*way
  end
proportionals = function (w0, w1a, w1b, w2, z0, z2)
    return proportional(w0, w1a, w2, z0, z2),
           proportional(w0, w1b, w2, z0, z2)
  end
splitdists = function (w0, w2, dw0, dw1, dw2, z0, z2)
    local w1a, w1b = splitdist(w0, w2, dw0, dw1, dw2)
    local z1a, z1b = proportionals(w0, w1a, w1b, w2, z0, z2)
    return w1a, w1b, z1a, z1b
  end
dharrownodes = function (dx0, dx1, dx2, TeX1a, TeX1b)
    local node0, node2 = ds:pick(1), ds:pick(0)
    local x0, x2, y0, y2 = node0.x, node2.x, node0.y, node2.y
    local x1a, x1b, y1a, y1b = splitdists(x0, x2, dx0, dx1, dx2, y0, y2)
    ds:push(storenode{x=x1a, y=y1a, TeX=(TeX1a or phantomnode)})
    ds:push(storenode{x=x1b, y=y1b, TeX=(TeX1b or phantomnode)})
  end
dvarrownodes = function (dy0, dy1, dy2, TeX1a, TeX1b)
    local node0, node2 = ds:pick(1), ds:pick(0)
    local x0, x2, y0, y2 = node0.x, node2.x, node0.y, node2.y
    local y1a, y1b, x1a, x1b = splitdists(y0, y2, dy0, dy1, dy2, x0, x2)
    ds:push(storenode{x=x1a, y=y1a, TeX=(TeX1a or phantomnode)})
    ds:push(storenode{x=x1b, y=y1b, TeX=(TeX1b or phantomnode)})
  end

forths["dharrownodes"] = function ()
    dharrownodes(getwordasluaexpr(), getwordasluaexpr(), getwordasluaexpr())
  end
forths["dvarrownodes"] = function ()
    dvarrownodes(getwordasluaexpr(), getwordasluaexpr(), getwordasluaexpr())
  end



-- dump-to: tests
--[==[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "diagmiddle.lua"

--]==]

-- Local Variables:
-- coding:             raw-text-unix
-- ee-anchor-format:   "«%s»"
-- End:
