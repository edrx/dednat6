-- zhaspecs.lua: construct ZHA specs from walls, points, or generators.
-- http://angg.twu.net/dednat6/dednat6/zhaspecs.lua
-- http://angg.twu.net/dednat6/dednat6/zhaspecs.lua.html
--         (find-angg "dednat6/dednat6/zhaspecs.lua")
--
-- A ZHA object has fields L and R that obey the "ZHA conditions",
-- which are:
--
--     dom(L)  = dom(R) = {0, 1, ..., maxy}  (range)
--       L[0]  = R[0]      (bottom point)
--    L[maxy]  = R[maxy]   (top point)
--       L[y] <= R[y]      (left wall <= right wall)
--     L[y+1]  = L[y]±1    (left wall changes in unit steps)
--     R[y+1]  = R[y]±1    (right wall changes in unit steps)
--
-- These L and R never change after the ZHA object is created.
-- The ZHA conditions are explained in sec.4 ("ZHAs") of this:
--
--   http://angg.twu.net/LATEX/2017planar-has-1.pdf
--   See p.7: (ph1p 7)
--
-- An LR object has L and R fields that are *modifiable*: the methods
-- "putx", "addleftpoint", "addrightpoint", and "addgenerators" modify
-- the L and R fields of the LR object in a way that preserves the ZHA
-- conditions. This allows us to start with a lozenge, then modify it
-- bit by bit by adding generators, or intercolumn arrows, as
-- described in sec.15 ("Topologies on 2CGs") of the paper:
--
--   http://angg.twu.net/LATEX/2017planar-has-1.pdf
--   See p.28: (ph1p 28)
--
-- The highest-level method here is LR.fromtcgspec(); note that it is
-- called from ZHA.fromtcgspec().
--
-- I found the algorithms here quite tricky to implement, and that's
-- why this became a separate class, with its own visualization tools,
-- in a separate file.


-- «.LR»			(to "LR")
-- «.LR-tests»			(to "LR-tests")
-- «.LR-putxy-tests»		(to "LR-putxy-tests")
-- «.LR-twocolgraph-tests»	(to "LR-twocolgraph-tests")
-- «.LR-fromtcgspec-tests»	(to "LR-fromtcgspec-tests")
-- «.LR-shrinktop-tests»	(to "LR-shrinktop-tests")

require "zhas"               -- (find-dn6 "zhas.lua")




--  _     ____  
-- | |   |  _ \ 
-- | |   | |_) |
-- | |___|  _ < 
-- |_____|_| \_\
--              
-- «LR» (to ".LR")

LR = Class {
  type = "LR",
  empty = function (maxy, ax)
      return LR {L={}, R={}, maxy=maxy, ax=ax}
    end,
  from = function (L, R, maxy, ax)
      return LR {L=L, R=R, maxy=maxy, ax=ax}
    end,
  fromspec = function (spec, x0, ax)
      local z = ZHA.fromspec0(spec, x0)
      return LR {L=z.L, R=z.R, ax=ax}
    end,
  fromtriples = function (A, maxy, ax)
      local L, R = {}, {}
      for _,triple in ipairs(A) do
        local y, l, r = triple[1], triple[2], triple[3]
        L[y], R[y] = l, (r or l)
      end
      return LR {L=L, R=R, maxy=maxy, ax=ax}
    end,
  --
  -- 2-column graphs
  -- See: (find-dn6 "tcgs.lua" "TCGSpec")
  fromtcgspec = function (spec, ax)
      -- local maxl,maxr,leftgens,rightgens = unpack(split(spec, "[ %d]+"))
      local pat = "^ *(%d)[ ,]*(%d) *;([ %d]*),([ %d]*)$"
      local maxl,maxr,leftgens,rightgens = spec:match(pat)
      maxl,maxr = tonumber(maxl),tonumber(maxr)
      return LR.fromtwocolgraph(maxl+0, maxr+0, leftgens, rightgens, ax)
    end,
  fromtwocolgraph = function (maxl, maxr, leftgens, rightgens, ax)
      return LR.lozenge(maxl, maxr, ax):addgenerators(leftgens, rightgens)
    end,
  lozenge = function (maxl, maxr, ax)
      local o = LR {L={}, R={}, ax=ax, maxl=maxl, maxr=maxr, maxy=maxl+maxr}
      for y=0,maxl+maxr do
        o.L[y] = o:nesex(-maxl, maxl, y)
        o.R[y] = o:nwswx( maxr, maxr, y)
      end
      return o
    end,
  --
  __tostring = function (o) return o:asciipicture():tostring() end,
  __index = {
    PP = function (o) print(mytabletostring(o)); return o end,
    ap = function (o) return o:asciipicture() end,
    asciipicture = function (o)
        local ap = AsciiPicture.new("  ")
        local put = function (x, y, n) ap:put(V{x, y}, n.."") end
        for y=0,(o.maxy or #o.L) do
          if o.L[y] then put(o.L[y], y, o.L[y]) end
          if o.R[y] then put(o.R[y], y, o.R[y]) end
          if o.ax then put(o.ax, y, y..":") end
        end
        return ap
      end,
    triples = function (o)
        local A = {}
        for y=(o.maxy or #o.L),0,-1 do
          local l, r = o.L[y], o.R[y]
          if l then table.insert(A, {y, l, r}) end
        end
        return A
      end,
    spec = function (o)
        local W = {}
        for y=0,#o.L do W[y] = toint((o.R[y] - o.L[y])/2) + 1 end
        local spec = "1"
        for y=1,#o.L do
          if W[y] == W[y-1]
          then spec = spec..((o.L[y]<o.L[y-1]) and "L" or "R")
          else spec = spec..W[y]
          end
        end  
        return spec
      end,
    zha = function (o) return ZHA.fromspec(o:spec()) end,
    --
    -- putxy - see: (find-dn6 "luarects.lua" "ZHAFromPoints")
    putxy = function (o, x, y)
        o.L[y], o.R[y] = minmax(o.L[y], x, o.R[y])
        return o
      end,
    --
    -- addgenerators (for 2-column graphs)
    swx = function (o, x0, y0, y1) return x0+(y1-y0) end,
    nex = function (o, x0, y0, y1) return x0+(y1-y0) end,
    sex = function (o, x0, y0, y1) return x0-(y1-y0) end,
    nwx = function (o, x0, y0, y1) return x0-(y1-y0) end,
    nesex = function (o, x0, y0, y1)
        return y1>y0 and o:nex(x0, y0, y1) or o:sex(x0, y0, y1)
      end,
    nwswx = function (o, x0, y0, y1)
        return y1>y0 and o:nwx(x0, y0, y1) or o:swx(x0, y0, y1)
      end,
    addleftpoint = function (o, x0, y0)
        for y=0,o.maxy do o.L[y] = max(o.L[y], o:nwswx(x0, y0, y)) end
        return o
      end,
    addrightpoint = function (o, x0, y0)
        for y=0,o.maxy do o.R[y] = min(o.R[y], o:nesex(x0, y0, y)) end
        return o
      end,
    addgenerators = function (o, leftstr, rightstr)
        for leftgen in leftstr:gmatch"%d%d" do
          local leftpoint = v(leftgen) + V{1,-1}
          o:addleftpoint(leftpoint:to_x_y())
        end
        for rightgen in rightstr:gmatch"%d%d" do
          local rightpoint = v(rightgen) + V{-1,-1}
          o:addrightpoint(rightpoint:to_x_y())
        end
        return o
      end,
    --
    shrinktop = function (o, newtop)
        newtop = v(newtop)
        local x1, y1 = newtop[1], newtop[2]
        if not (y1 <= o.maxy) then return o end
        if not (o.L[y1] <= x1 and x1 <= o.R[y1]) then return o end
        for y=o.maxy,y1+1,-1 do
          o.L[y] = nil
          o.R[y] = nil
        end
        o.maxy = y1
        for dy=0,y1 do
          local y, xl, xr = y1-dy, x1-dy, x1+dy
          o.L[y] = max(o.L[y], xl)
          o.R[y] = min(o.R[y], xr)
        end
        return o
      end,
  },
}

-- «LR-tests» (to ".LR-tests")
--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "zhaspecs.lua"
require "picture"
require "zhas"
A = {{5,  1    },
     {4,   2   },
     {3,  1,3  },
     {2, 0,  4 },
     {1,  1,3  },
     {0,   2   }}
= LR.fromtriples(A, nil)
= LR.fromtriples(A, nil, -2)
= LR.fromtriples(A, nil, -4)

o = LR.fromtriples(A, nil, -2)
= o
= o:PP()
= o:spec()
= o:zha():PP()

= LR.fromspec("123RR21RL")
= LR.fromspec("123RR21RL", nil, -4)
= LR.fromspec("123RR21RL",   0, -4)
= LR.fromspec("123RR21RL",   1, -4)
= LR.fromspec("123RR21RL",   2, -4)
PPV(LR.fromspec("123RR21RL", 2, -4):triples())

 (ex "lr-0")


-- «LR-putxy-tests» (to ".LR-putxy-tests")
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "zhaspecs.lua"
require "picture"
require "zhas"
f = function (y, str)
    for x,c in str:gmatch"()(%S)" do o:putxy(x, y) end
    return o
  end
o = LR.from({}, {}, 5, -2)
= o
= f(5, " o   ")
= f(4, "  o  ")
= f(3, " o o ")
= f(2, "o o o")
= f(1, " o o ")
= f(0, "  o  ")
= o:zha()

 (ex "lr-putxy")


-- «LR-twocolgraph-tests» (to ".LR-twocolgraph-tests")
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "zhaspecs.lua"
require "picture"
require "zhas"
= LR.lozenge(2, 4)
= LR.lozenge(4, 6)
= LR.lozenge(4, 6, -6)
= LR.lozenge(4, 6):zha()
= LR.lozenge(4, 6):addgenerators("32", ""):zha()
= LR.lozenge(4, 6):addgenerators("32", "15"):zha()
= LR.lozenge(4, 6):addgenerators("32", "15 26"):zha()
= LR.fromtwocolgraph(4, 6, "",   ""     ):zha()
= LR.fromtwocolgraph(4, 6, "32", ""     ):zha()
= LR.fromtwocolgraph(4, 6, "32", "15"   ):zha()
= LR.fromtwocolgraph(4, 6, "32", "15 26"):zha()
= LR.fromtcgspec("   4, 6;    ,        "):zha()
= LR.fromtcgspec("   4, 6;  32,        "):zha()
= LR.fromtcgspec("   4, 6;  32,   15   "):zha()
= LR.fromtcgspec("   4, 6;  32,   15 26"):zha()
= LR.fromtcgspec("   4, 6;  32,   15 26"):zha().spec
= LR.fromtcgspec("   4, 6;  32,   15 26"):zha():totcgspec()
= LR.fromtcgspec(     "46;  32,   15 26"):zha():totcgspec()

 (ex "lr-2col")

-- «LR-fromtcgspec-tests» (to ".LR-fromtcgspec-tests")
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "zhaspecs.lua"
require "picture"
require "zhas"
= LR.fromtcgspec("4, 6; 11 22 34 45, 25"):zha()
= LR.fromtcgspec("4, 6; 11 22 34 45, 25"):zha().spec
= LR.fromtcgspec("4, 6; 11 22 34 45, 25"):zha():totcgspec()
= LR.fromtcgspec("4, 6; 11 22 34 45, 25 06"):zha()
= LR.fromtcgspec("4, 6; 11 22 34 45, 25 06"):zha():totcgspec()


-- «LR-shrinktop-tests» (to ".LR-shrinktop-tests")
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "zhaspecs.lua"
require "picture"
require "zhas"
o = LR.fromtcgspec("4, 6; 11 22 34 45, 25 06")
= o:zha()
= o:shrinktop(v"47"):zha()
= o:shrinktop( "35"):zha()

--]]





-- (find-LATEXgrep "grep --color -nH -e tcg_spec 2017planar-has-2.tex")
-- (find-LATEXfile "2017planar-has-2.tex" "tcgnew =")
-- (find-LATEX "edrxpict.lua" "TCG")
-- (find-LATEX "edrxpict.lua" "TCG" "new  =")



-- Local Variables:
-- coding: utf-8-unix
-- End:

