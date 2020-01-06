-- tcgs.lua: classes for two-column graphs.
-- http://angg.twu.net/dednat6/dednat6/tcgs.lua
-- http://angg.twu.net/dednat6/dednat6/tcgs.lua.html
--         (find-angg "dednat6/dednat6/tcgs.lua")
--
-- This is a hack that I use in the papers of my "Planar Heyting
-- Algebras for Children" series.
--
-- This file supersedes the code for TCGs in:
--   (find-LATEX "edrxpict.lua" "TCG")
-- but it defines classes with different names so that this and the
-- old version can be loaded together (and the migration can be made
-- gradually).

-- «.qmarks-cuts»	(to "qmarks-cuts")
-- «.qmarks-cuts-test»	(to "qmarks-cuts-test")
-- «.Line»		(to "Line")
-- «.Line-test»		(to "Line-test")
-- «.TCGSpec»		(to "TCGSpec")
-- «.TCGSpec-test»	(to "TCGSpec-test")
-- «.TCGDims»		(to "TCGDims")
-- «.TCGDims-test»	(to "TCGDims-test")
-- «.TCGQ»		(to "TCGQ")
-- «.TCGQ-tests»	(to "TCGQ-tests")


-- (find-LATEX "edrxtikz.lua" "Line")
-- (find-LATEX "edrxtikz.lua" "Line-test")

require "zhaspecs"          -- (find-dn6 "zhaspecs.lua")
require "picture"           -- (find-dn6 "picture.lua")




--                             _           __   __               _       
--   __ _ _ __ ___   __ _ _ __| | _____   / /   \ \    ___ _   _| |_ ___ 
--  / _` | '_ ` _ \ / _` | '__| |/ / __| / /_____\ \  / __| | | | __/ __|
-- | (_| | | | | | | (_| | |  |   <\__ \ \ \_____/ / | (__| |_| | |_\__ \
--  \__, |_| |_| |_|\__,_|_|  |_|\_\___/  \_\   /_/   \___|\__,_|\__|___/
--     |_|                                                               
--
-- «qmarks-cuts» (to ".qmarks-cuts")
-- Convert between the formats "qmarks" and "cuts".
-- For example: (".??", "..???") <-> "321/0 0|1|2345".
-- See: (find-es "dednat" "qmarks-to-cuts")

qmarkstocuts = function (leftqmarks, rightqmarks)
    local cuts = ""
    local add = function (s) cuts = cuts..s end
    local leftqm  = function (y) return leftqmarks :sub(y,y) == "?" end
    local rightqm = function (y) return rightqmarks:sub(y,y) == "?" end
    for y=#leftqmarks,1,-1 do
      add(y)
      if not leftqm(y) then add("/") end
    end
    add("0 0")
    for y=1,#rightqmarks do
      if not rightqm(y) then add("|") end
      add(y)
    end
    return cuts
  end

cutstoqmarks = function (cuts)
    local l,r = cuts:sub(1,1)+0, cuts:sub(-1,-1)+0
    local lqmarks,rqmarks = "", ""
    lqmark = function (y) return not cuts:match(y.."/") end
    rqmark = function (y) return not cuts:match("|"..y) end
    for y=1,l do lqmarks = lqmarks .. (lqmark(y) and "?" or ".") end
    for y=1,r do rqmarks = rqmarks .. (rqmark(y) and "?" or ".") end
    return lqmarks, rqmarks
  end

-- «qmarks-cuts-test» (to ".qmarks-cuts-test")
--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
loaddednat6()
require "tcgs"

PP(qmarkstocuts(".??", "..???"))
PP(cutstoqmarks "321/0 0|1|2345")

--]]



--  _     _            
-- | |   (_)_ __   ___ 
-- | |   | | '_ \ / _ \
-- | |___| | | | |  __/
-- |_____|_|_| |_|\___|
--                     
-- «Line» (to ".Line")
-- Parametrized lines.
-- This is a copy of:
--   (find-LATEX "edrxtikz.lua" "Line")
-- minus MAYBE some methods for Analytic Geometry and Tikz.
--
Line = Class {
  new   = function (A, v, mint, maxt)
      return Line {A=A, v=v, mint=mint, maxt=maxt}
    end,
  newAB = function (A, B, mint, maxt) return Line.new(A, B-A, mint, maxt) end,
  type  = "Line",
  __tostring = function (li) return li:tostring() end,
  __index = {
    t = function (li, t) return li.A + t * li.v end,
    draw = function (li) return formatt("%s -- %s", li:t(li.mint), li:t(li.maxt)) end,
    tostring = function (li) return formatt("%s + t%s", li.A, li.v) end,
    proj = function (li, P) return li.A + li.v:proj(P - li.A) end,
    sym = function (li, P) return P + 2*(li:proj(P) - P) end,
    --
    pict = function (li) return formatt("\\Line%s%s", li:t(li.mint), li:t(li.maxt)) end,
    --
    -- (find-LATEX "edrxpict.lua" "pict2evector")
    pictv = function (li)
        local x0,y0 = li:t(li.mint):to_x_y()
        local x1,y1 = li:t(li.maxt):to_x_y()
        return pict2evector(x0, y0, x1, y1)
      end,
  },
}

-- «Line-test» (to ".Line-test")
--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
-- dofile "edrxtikz.lua"
dofile "tcgs.lua"
r = Line.new(v(0, 1), v(3, 2), -1, 2)
= r
= r:t(0)
= r:t(0.1)
= r:t(1)
= r:draw()
= r:pict()

--]]




--  _____ ____ ____ ____                  
-- |_   _/ ___/ ___/ ___| _ __   ___  ___ 
--   | || |  | |  _\___ \| '_ \ / _ \/ __|
--   | || |__| |_| |___) | |_) |  __/ (__ 
--   |_| \____\____|____/| .__/ \___|\___|
--                       |_|              
--
-- «TCGSpec» (to ".TCGSpec")
-- Based on:
-- (find-dn6 "zhaspecs.lua" "LR-fromtcgspec-tests")
-- (find-dn6 "zhaspecs.lua" "LR")
-- (find-dn6 "zhaspecs.lua" "LR" "fromtcgspec =")

TCGSpec = Class {
  type  = "TCGSpec",
  split = function (specstr)
      local pat = "^(%d)[ ,]*(%d);([ %d]*),([ %d]*)$"
      local l,r,lgens,rgens = specstr:match(pat)
      local l,r,lgens,rgens = l+0, r+0, split(lgens), split(rgens)
      return l,r,lgens,rgens
    end,
  new = function (specstr, leftqmarks, rightqmarks)
      local l,r,lgens,rgens = TCGSpec.split(specstr)
      return TCGSpec {tcgspec=specstr,
                      maxl=l, maxr=r, leftgens=lgens, rightgens=rgens,
                      leftqmarks=leftqmarks, rightqmarks=rightqmarks
                     }
    end,
  --
  ddtonn = function (dd)
      local a,b = dd:match("^(%d)(%d)$")
      return a+0, b+0
    end,
  generatelrs = function (lrs)
      if type(lrs) == "string" then lrs = split(lrs) end
      return cow(function ()
          for _,lr in ipairs(lrs) do
            local l,r = TCGSpec.ddtonn(lr)
            coy(lr, l, r)
          end
        end)
    end,
  --
  __tostring = function (ts) return mytabletostring(ts) end,
  __index = {
    zha = function (ts)
        return LR.fromtcgspec(ts.tcgspec):zha()
      end,
    zhaspec = function (ts) return ts:zha().spec end,
    generateleftgens = function (ts)
        return TCGSpec.generatelrs(ts.leftgens)
      end,
    generaterightgens = function (ts)
        return TCGSpec.generatelrs(ts.rightgens)
      end,
    hasqmarks = function (ts) return ts.leftqmarks end,
    --
    cuts = function (ts)
        return qmarkstocuts(ts.leftqmarks, ts.rightqmarks)
      end,
    mp = function (ts, opts)
        local mp = mpnew(opts or {}, ts:zhaspec())
        if ts:hasqmarks() then mp = mp:addcuts("c "..ts:cuts()) end
        return mp
      end,
    --
    ap = function (ts)
        local tdims = TCGDims {h=6, v=3, q=2, crh=2, crv=1, qrh=1} -- dummy
        return TCGQ.newdsoa(tdims, ts, {}, "lr q").ap
      end,
    --
    tcgq = function (ts, opts, actions)
        return TCGQ.newdsoa(tdims, ts, opts, actions) -- use a global tdims
      end,
  },
}

-- «TCGSpec-test» (to ".TCGSpec-test")
--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "tcgs.lua"
spec = "46; 32, 15 26"

ts = TCGSpec.new(spec)
= ts
= ts:zha()
= ts:zha().spec
= ts:zhaspec()
for lr,l,r in ts:generateleftgens()  do PP(lr,l,r) end
for lr,l,r in ts:generaterightgens() do PP(lr,l,r) end
for i,c in ("abcde"):gmatch("()(.)") do PP(i, c) end


 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "tcgs.lua"
ts = TCGSpec.new("46; 22 34 45, 25", ".???", "???.?.")
= ts
= ts:zha()
= ts:zhaspec()
= ts:cuts()
= ts:mp()
= ts:mp():addlrs()
  ts:mp({zdef="foo"}):lprint()

= TCGSpec.new("46; 22 34 45, 25", ".???", "???.?."):mp():addlrs()
= TCGSpec.new("46; 22 34 45, 25"                  ):mp():addlrs()

-- (ph2p 24 "Q-partitions-are-slash-partitions" "side of each")
-- (ph2     "Q-partitions-are-slash-partitions" "side of each")

 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "tcgs.lua"
= TCGSpec.new("46; 32, 15 26", "?..?","..??.."):ap()
= TCGSpec.new("46; 32, 15 26"                 ):ap()
= TCGSpec.new("46; 32, 15 26", "?..?","..??.."):mp()
= TCGSpec.new("46; 32, 15 26", "?..?","..??.."):mp():addlrs()
= TCGSpec.new("46; 32, 15 26"                 ):mp():addlrs()
= TCGSpec.new("46; 32, 15 26"                 ):zha()

--]]




--  _____ ____ ____ ____  _               
-- |_   _/ ___/ ___|  _ \(_)_ __ ___  ___ 
--   | || |  | |  _| | | | | '_ ` _ \/ __|
--   | || |__| |_| | |_| | | | | | | \__ \
--   |_| \____\____|____/|_|_| |_| |_|___/
--                                        
-- «TCGDims» (to ".TCGDims")
-- New! 2019apr28.
-- A structure that holds the dimension parameters of a TCG.
-- The functions L and R return the centers of the column cells.
-- The functions QL and QR return the centers of the question mark cells.
-- The "radius" of a node cell is (crh,crv).
-- The "radius" of a question mark cell is (qrh,crv).
TCGDims = Class {
  type    = "TCGDims",
  __tostring = function (td) return mytabletostring(td) end,
  __index = {
    L  = function (td, y) return v(0,         td.v*y) end,
    R  = function (td, y) return v(td.h,      td.v*y) end,
    QR = function (td, y) return v(td.h+td.q, td.v*y) end,
    QL = function (td, y) return v(    -td.q, td.v*y) end,
    cellradius  = function (td) return v(td.crh, td.crv) end,
    qmarkradius = function (td) return v(td.qrh, td.crv) end,
    varrowts    = function (td) return td.crv/td.v, 1-td.crv/td.v end,
    harrowts    = function (td) return td.crh/td.h, 1-td.crh/td.h end,
    larrowparams = function (td, y0, y1)
        return td:L(y0), td:L(y1), td:varrowts()
      end,
    rarrowparams = function (td, y0, y1)
        return td:R(y0), td:R(y1), td:varrowts()
      end,
    lrarrowparams = function (td, y0, y1)
        return td:L(y0), td:R(y1), td:harrowts()
      end,
    rlarrowparams = function (td, y0, y1)
        return td:R(y0), td:L(y1), td:harrowts()
      end,
    lowerleft  = function (td) return td:L(1)-td:cellradius() end,
    lowerleftq = function (td) return td:QL(1)-td:qmarkradius() end,
    upperright = function (td, y) return td:R(y)+td:cellradius() end,
    upperrightq = function (td, y) return td:QR(y)+td:qmarkradius() end,
  },
}

-- «TCGDims-test» (to ".TCGDims-test")
--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "tcgs.lua"
td = TCGDims {h=6, v=3, q=2, crh=2, crv=1, qrh=1}
= td
= td:lowerleft()
= td:lowerleftq()
= td:upperright(4)
= td:upperrightq(4)
= td:larrowparams(1, 0)
= td:lrarrowparams(1, 0)

--]]

-- (find-dn6 "picture.lua" "LPicture")
-- (find-LATEX "edrxtikz.lua" "Line")
-- LPicture.__index.addarrow = function (lp, A, B, t0, t1)
--     lp:addtex(Line.newAB(A, B, t0, t1):pictv())
--   end




--  _____ ____ ____  ___  
-- |_   _/ ___/ ___|/ _ \ 
--   | || |  | |  _| | | |
--   | || |__| |_| | |_| |
--   |_| \____\____|\__\_\
--                        
-- «TCGQ» (to ".TCGQ")
-- A class for TCGs with optional question marks. This is a rewrite of
-- the obsolete TCG class, but this uses a TCGDims object in a field
-- ".td" to makes the dimensions much easier to adjust and to make the
-- calculations more readable. A TCGQ object has a field ".lp" with an
-- LPicture object with commands to draw all its nodes and arrows, a
-- field ".ap" with an AsciiPicture object that only stores its nodes
-- and qnodes (that I use to visualize in ascii how a TCGQ is converted
-- to a ZHAJ), and an optional TCGSpec object in the field ".ts".
--
-- It is possible to create a "low-level TCGQ" without a tcgspec for
-- tests; in this case you have to specify explicitly its "l" and "r".
-- In a "high-level TCGQ" the fields "l" and "r" are extracted the
-- tcgspec.
--
TCGQ = Class {
  type    = "TCGQ",
  new = function (tdims, opts, l, r, tcgspec)
      local tq = TCGQ {tdims=tdims, opts=opts, l=l, r=r,
                       ts=tcgspec,
                       lp=LPicture.new(opts),
                       ap=AsciiPicture.new("   "):put(v(1,1)," "),
                      }
      if tcgspec then
        tq.l = tcgspec.maxl
        tq.r = tcgspec.maxr
        if tcgspec:hasqmarks() then tq:addqpoints() end
      end
      tq:addpoints()
      return tq
    end,
  newdsoa = function (tdims, tcgspec, opts, actions)
      return TCGQ.new(tdims, opts, nil, nil, tcgspec):act(actions or "")
    end,
  --
  __index = {
    tolatex = function (tq) return tq.lp:tolatex() end,
    print   = function (tq) print(tq.lp); return tq end,
    lprint  = function (tq) print(tq.lp:tolatex()); return tq end,
    output  = function (tq) output(tq.lp:tolatex()); return tq end,
    --
    -- Functions to adjust the boundaries of the LPicture
    addpoints = function (tq)
        tq.lp:addpoint(tq.tdims:lowerleft())
        tq.lp:addpoint(tq.tdims:upperright(max(tq.l, tq.r)))
        return tq
      end,
    addqpoints = function (tq)
        tq.lp:addpoint(tq.tdims:lowerleftq())
        tq.lp:addpoint(tq.tdims:upperrightq(max(tq.l, tq.r)))
        return tq
      end,
    --
    -- Draw boxes on cells and qmarks, for debugging
    drawboxes = function (tq)
        for y=1,tq.l do tq.lp:addrectr(tq.tdims:L(y), tq.tdims:cellradius()) end
        for y=1,tq.r do tq.lp:addrectr(tq.tdims:R(y), tq.tdims:cellradius()) end
        return tq
      end,
    drawqboxes = function (tq)
        for y=1,tq.l do tq.lp:addrectr(tq.tdims:QL(y), tq.tdims:qmarkradius()) end
        for y=1,tq.r do tq.lp:addrectr(tq.tdims:QR(y), tq.tdims:qmarkradius()) end
        return tq
      end,
    --
    -- Draw the standard vertical arrows.
    varrows = function (tq)
        for y=tq.l,2,-1 do tq.lp:addarrow(tq.tdims:larrowparams(y, y-1)) end
        for y=tq.r,2,-1 do tq.lp:addarrow(tq.tdims:rarrowparams(y, y-1)) end
        return tq
      end,
    --
    -- Put text in cells and in the qmark cells
    put = function (tq, v, tex)
        tq.lp:rawput(v, "\\cell{"..tex.."}")
        return tq
      end,
    aput = function (tq, x, y, tex)
        tex = (tex or ""):gsub("[\\_]", ""):sub(1,1)
        tq.ap:put(v(x,y), tex)
        return tq
      end,
    Lput  = function (tq, y, tex) tq:put(tq.tdims:L(y),  tex):aput(1, y, tex) end,
    Rput  = function (tq, y, tex) tq:put(tq.tdims:R(y),  tex):aput(2, y, tex) end,
    QLput = function (tq, y, tex) tq:put(tq.tdims:QL(y), tex):aput(0, y, tex) end,
    QRput = function (tq, y, tex) tq:put(tq.tdims:QR(y), tex):aput(3, y, tex) end,
    --
    bullets = function (tq)
        for y=1,tq.l do tq:Lput(y, "\\bullet") end
        for y=1,tq.r do tq:Rput(y, "\\bullet") end
        return tq
      end,
    lrs = function (tq)
        for y=1,tq.l do tq:Lput(y, y.."\\_") end
        for y=1,tq.r do tq:Rput(y, "\\_"..y) end
        return tq
      end,
    --
    -- Low-level functions to put "?"s and "!"s in qmark cells
    QLputs = function (tq, qmarks)
        for y,c in qmarks:gmatch("()(.)") do
            if c=="?" or c=="!" then tq:QLput(y, c) end
          end
        return tq
      end,
    QRputs = function (tq, qmarks)
        for y,c in qmarks:gmatch("()(.)") do
            if c=="?" or c=="!" then tq:QRput(y, c) end
          end
        return tq
      end,
    --
    -- A low-level function to put digits in cells
    digits = function (tq, ldigits, rdigits)
        for y,d in ldigits:gmatch("()(.)") do tq:Lput(y, d) end
        for y,d in rdigits:gmatch("()(.)") do tq:Rput(y, d) end
        return tq
      end,
    --
    -- Functions that work only on "high-level TCGQs", that are the
    -- ones with a "ts" field holding a TCGSpec object.
    qmarks = function (tq)
        if tq.ts:hasqmarks() then
          tq:QLputs(tq.ts.leftqmarks)
          tq:QRputs(tq.ts.rightqmarks)
        end
        return tq
      end,
    harrows = function (tq)
        for lr,l,r in tq.ts:generateleftgens()  do
          -- PP("->", l, r)
          tq.lp:addarrow(tq.tdims:lrarrowparams(l, r))
        end
        for lr,l,r in tq.ts:generaterightgens() do
          -- PP("<-", l, r)
          tq.lp:addarrow(tq.tdims:rlarrowparams(r, l))
        end
        return tq
      end,
    --
    act = function (tq, actions)
        for i,action in ipairs(split(actions)) do
          if     action == "b"  then tq:bullets()
          elseif action == "lr" then tq:lrs()
          elseif action == "v"  then tq:varrows()
          elseif action == "h"  then tq:harrows()
          elseif action == "q"  then tq:qmarks()
          elseif action == "B"  then tq:drawboxes()
          elseif action == "QB" then tq:drawqboxes()
          elseif action == "p"  then tq:print()
          elseif action == "ap" then tq.ap:print()
          elseif action == "o"  then tq:output()
          else error("Bad action: "..action)
          end
        end
        return tq
      end,
  },
}

-- «TCGQ-tests» (to ".TCGQ-tests")
--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
loaddednat6()
require "tcgs"
td = TCGDims {h=6, v=3, q=4, crh=2, crv=1, qrh=1}
opts = {meta="p s", def="foo"}
tq = TCGQ.new(td, opts, 3, 4):drawboxes():drawqboxes():varrows()
tq:addqpoints()
tq:Lput(2, "A")
tq:lprint()

 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
loaddednat6()
require "tcgs"
td = TCGDims {h=6, v=3, q=4, crh=2, crv=1, qrh=1}
opts = {meta="p s", def="foo"}
tq = TCGQ.new(td, opts, 3, 4)
= tq.ap
= tq:lrs().ap
= tq:bullets().ap
= tq:QLputs("?.!").ap
= tq.ap
= tq:lrs().ap

 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
loaddednat6()
dofile "tcgs.lua"
tspec = TCGSpec.new("46; 32,   15 26", "?..?", "..??..")
tdims = TCGDims {h=6, v=3, q=2, crh=2, crv=1, qrh=1}
tq  = TCGQ.new(tdims, {tdef="foo"}, nil, nil, tspec)
tq:bullets()
tq:lrs()
tq:varrows()
tq:harrows()
tq:qmarks()
tq:drawboxes()
tq:drawqboxes()
tq:print()

 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
loaddednat6()
dofile "tcgs.lua"
tspec = TCGSpec.new("46; 32, 15 26", "?..?","..??..")
tdims = TCGDims {h=6, v=3, q=2, crh=2, crv=1, qrh=1}
tq = TCGQ.newdsoa(tdims, tspec, {tdef="foo"}, "b v h p")
tq = TCGQ.newdsoa(tdims, tspec, {tdef="foo"})
tq:print()

tdims = TCGDims {h=6, v=3, q=2, crh=2, crv=1, qrh=1}
tq = TCGQ.newdsoa(tdims, tspec, {tdef="foo"}, "lr")
tq:print()
= tq.ap

--]]








-- Local Variables:
-- coding: raw-text-unix
-- End:

