-- diagmiddle.lua: words for drawing arrows between the sides of rectangles.
-- This file:
--   http://angg.twu.net/dednat6/dednat6/diagmiddle.lua.html
--   http://angg.twu.net/dednat6/dednat6/diagmiddle.lua
--           (find-angg "dednat6/dednat6/diagmiddle.lua")
-- Author: Eduardo Ochs <eduardoochs@gmail.com>
-- Version: 2019dec08
-- License: GPL3
--
--
-- This is a hack! I wrote this to draw the middle arrows in
-- adjunctions, and then adapted it to draw arrows in the middle of
-- slanted rectangles, like in this diagram:
--   http://angg.twu.net/dednat6.html#a-big-example
--
-- It worked well enough for me, so I've kept it... the algorithm that
-- the "splitdist*" functions use to calculate the phantom nodes is a
-- bit hard to explain, and I would love to 1) write better docs for
-- it, 2) implement variants of it that people would find clearer. If
-- you want me to work on (1) on (2) please do get in touch, and I'll
-- stop postponing this!
--
-- A link to a very old implementation of this:
--   (find-dn4 "experimental.lua" "splitdist")



-- «.midpoint»		(to "midpoint")
-- «.midpoint-tests»	(to "midpoint-tests")
-- «.splitdist»		(to "splitdist")
-- «.splitdist-tests»	(to "splitdist-tests")
-- «.splitdists»	(to "splitdists")
-- «.splitdists-tests»	(to "splitdists-tests")
-- «.harrownodes»	(to "harrownodes")
-- «.varrownodes»	(to "varrownodes")
-- «.dharrownodes»	(to "dharrownodes")
-- «.dvarrownodes»	(to "dvarrownodes")



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
• (eepitch-lua51)
• (eepitch-kill)
• (eepitch-lua51)
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
PPV(nodes)
PP(nodes["a"])
PP(nodes["a,b"])

--]==]



-- Words for drawing arrows in the middle of rectangles (in adjunctions).
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
    elseif type=="nn_" then
      return x1+dx0+rest/2, x2-rest/2
    elseif type=="_nn" then
      return x1+rest/2, x2-dx2-rest/2
    elseif type=="n_n" then
      return x1+dx0, x2-dx2
    end
    local p = function (n) return n or "nil" end
    print("Bad splitdist pattern: "..p(dx0).." "..p(dx1).." "..p(dx2))
  end

-- «splitdist-tests»  (to ".splitdist-tests")
--[[
• (eepitch-lua51)
• (eepitch-kill)
• (eepitch-lua51)
dofile "diagmiddle.lua"
= splitdist(100, 200,  nil,  10, nil)   --> 145 155
= splitdist(100, 200,   20,  10, nil)   --> 155 165
= splitdist(100, 200,  nil,  10,  20)   --> 135 145
= splitdist(100, 200,   20, nil,  30)   --> 120 170

= splitdist(200, 100,  nil,  10, nil)   --> 145 155

--]]



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

-- New, 2019oct06:
harrownodes0 = function (x0, y0, x2, y2, dx0, dx1, dx2)
    local x1a, x1b = splitdist(x0, x2, dx0, dx1, dx2)
    local y1 = (y0 + y2)/2
    return x1a, y1, x1b, y1
  end
varrownodes0 = function (x0, y0, x2, y2, dy0, dy1, dy2)
    local y1a, y1b = splitdist(y0, y2, dy0, dy1, dy2)
    local x1 = (x0 + x2)/2
    return x1, y1a, x1, y1b
  end
dharrownodes0 = function (x0, y0, x2, y2, dx0, dx1, dx2)
    local x1a, x1b = splitdist(x0, x2, dx0, dx1, dx2)
    local y1a, y1b = proportionals(x0, x1a, x1b, x2, y0, y2)
    return x1a, y1a, x1b, y1b
  end
dvarrownodes0 = function (x0, y0, x2, y2, dy0, dy1, dy2)
    local y1a, y1b = splitdist(y0, y2, dy0, dy1, dy2)
    local x1a, x1b = proportionals(y0, y1a, y1b, y2, x0, x2)
    return x1a, y1a, x1b, y1b
  end

-- «splitdists-tests»  (to ".splitdists-tests")
-- 
--[[
• (eepitch-lua51)
• (eepitch-kill)
• (eepitch-lua51)
dofile "diagmiddle.lua"
= proportional (10,   15,   20,        100, 200)   --> 150
= proportionals(10, 14, 16, 20,        100, 200)   --> 140 160
= splitdist    (10, 20, nil, 2, nil)               --> 14 16
= splitdists   (10, 20, nil, 2, nil,   100, 200)   --> 14 16 140 160

= harrownodes0  (10, 100,  20, 200,  nil,  2, nil)   --> 14 150  16 150
= varrownodes0  (10, 100,  20, 200,  nil, 20, nil)   --> 15 140  15 160
= dharrownodes0 (10, 100,  20, 200,  nil,  2, nil)   --> 14 140  16 160
= dvarrownodes0 (10, 100,  20, 200,  nil, 20, nil)   --> 14 140  16 160

--]]


-- «harrownodes»  (to ".harrownodes")
-- «varrownodes»  (to ".varrownodes")
harrownodes = function (dx0, dx1, dx2, TeX1, TeX2)
    local node0, node2 = ds:pick(1), ds:pick(0)
    local x0, y0, x2, y2 = node0.x, node0.y, node2.x, node2.y
    local x1a, y1a, x1b, y1b = harrownodes0(x0, y0, x2, y2, dx0, dx1, dx2)
    ds:push(storenode{x=x1a, y=y1a, TeX=(TeX1 or phantomnode)})
    ds:push(storenode{x=x1b, y=y1b, TeX=(TeX2 or phantomnode)})
  end
varrownodes = function (dy0, dy1, dy2, TeX1, TeX2)
    local node0, node2 = ds:pick(1), ds:pick(0)
    local x0, y0, x2, y2 = node0.x, node0.y, node2.x, node2.y
    local x1a, y1a, x1b, y1b = varrownodes0(x0, y0, x2, y2, dy0, dy1, dy2)
    ds:push(storenode{x=x1a, y=y1a, TeX=(TeX1 or phantomnode)})
    ds:push(storenode{x=x1b, y=y1b, TeX=(TeX2 or phantomnode)})
  end

-- «dharrownodes»  (to ".dharrownodes")
-- «dvarrownodes»  (to ".dvarrownodes")
dharrownodes = function (dx0, dx1, dx2, TeX1, TeX2)
    local node0, node2 = ds:pick(1), ds:pick(0)
    local x0, y0, x2, y2 = node0.x, node0.y, node2.x, node2.y
    local x1a, y1a, x1b, y1b = dharrownodes0(x0, y0, x2, y2, dx0, dx1, dx2)
    ds:push(storenode{x=x1a, y=y1a, TeX=(TeX1 or phantomnode)})
    ds:push(storenode{x=x1b, y=y1b, TeX=(TeX2 or phantomnode)})
  end
dvarrownodes = function (dy0, dy1, dy2, TeX1, TeX2)
    local node0, node2 = ds:pick(1), ds:pick(0)
    local x0, y0, x2, y2 = node0.x, node0.y, node2.x, node2.y
    local x1a, y1a, x1b, y1b = dvarrownodes0(x0, y0, x2, y2, dy0, dy1, dy2)
    ds:push(storenode{x=x1a, y=y1a, TeX=(TeX1 or phantomnode)})
    ds:push(storenode{x=x1b, y=y1b, TeX=(TeX2 or phantomnode)})
  end

forths["harrownodes"] = function ()
    harrownodes(getwordasluaexpr(), getwordasluaexpr(), getwordasluaexpr())
  end
forths["varrownodes"] = function ()
    varrownodes(getwordasluaexpr(), getwordasluaexpr(), getwordasluaexpr())
  end
forths["dharrownodes"] = function ()
    dharrownodes(getwordasluaexpr(), getwordasluaexpr(), getwordasluaexpr())
  end
forths["dvarrownodes"] = function ()
    dvarrownodes(getwordasluaexpr(), getwordasluaexpr(), getwordasluaexpr())
  end




-- Old versions (commented out in 2019oct06):
-- harrownodes = function (dx0, dx1, dx2, TeX1, TeX2)
--     local node1, node2 = ds:pick(1), ds:pick(0)
--     local midy = (node1.y + node2.y)/2
--     local x1, x2 = splitdist(node1.x, node2.x, dx0, dx1, dx2)
--     ds:push(storenode{x=x1, y=midy, TeX=(TeX1 or phantomnode)})
--     ds:push(storenode{x=x2, y=midy, TeX=(TeX2 or phantomnode)})
--   end
-- varrownodes = function (dy0, dy1, dy2, TeX1, TeX2)
--     local node1, node2 = ds:pick(1), ds:pick(0)
--     local midx = (node1.x + node2.x)/2
--     local y1, y2 = splitdist(node1.y, node2.y, dy0, dy1, dy2)
--     ds:push(storenode{x=midx, y=y1, TeX=(TeX1 or phantomnode)})
--     ds:push(storenode{x=midx, y=y2, TeX=(TeX2 or phantomnode)})
--   end
-- dharrownodes = function (dx0, dx1, dx2, TeX1a, TeX1b)
--     local node0, node2 = ds:pick(1), ds:pick(0)
--     local x0, x2, y0, y2 = node0.x, node2.x, node0.y, node2.y
--     local x1a, x1b, y1a, y1b = splitdists(x0, x2, dx0, dx1, dx2, y0, y2)
--     ds:push(storenode{x=x1a, y=y1a, TeX=(TeX1a or phantomnode)})
--     ds:push(storenode{x=x1b, y=y1b, TeX=(TeX1b or phantomnode)})
--   end
-- dvarrownodes = function (dy0, dy1, dy2, TeX1a, TeX1b)
--     local node0, node2 = ds:pick(1), ds:pick(0)
--     local x0, x2, y0, y2 = node0.x, node2.x, node0.y, node2.y
--     local y1a, y1b, x1a, x1b = splitdists(y0, y2, dy0, dy1, dy2, x0, x2)
--     ds:push(storenode{x=x1a, y=y1a, TeX=(TeX1a or phantomnode)})
--     ds:push(storenode{x=x1b, y=y1b, TeX=(TeX1b or phantomnode)})
--   end





-- Local Variables:
-- coding:             utf-8-unix
-- End:
