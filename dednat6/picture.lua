-- picture.lua: classes to create LaTeX pictures (and ascii representations).
-- This file:
-- http://angg.twu.net/dednat6/dednat6/picture.lua
-- http://angg.twu.net/dednat6/dednat6/picture.lua.html
--         (find-angg "dednat6/dednat6/picture.lua")
--
-- This file defines a class LPicture that generates LaTeX
-- pict2e diagrams, and a class AsciiPicture for ascii
-- representations of the same diagrams. The classes for mixed
-- LaTeX/ascii pictures are elsewhere, at:
--
--   (find-dn6 "zhas.lua" "MixedPicture")
--
-- This file is a full rewrite of:
--   (find-angg "LUA/picture.lua" "Picture")
--
-- IMPORTANT! Until 2015 I didn't know that pict2e existed, and I used
-- picture-mode instead. The code here still has some fossils from
-- that time. See the comments in this section: (to "pict2e")
--
-- BAD NEWS: the description above may give the impression that this
-- module is quite general, but this is currently not the case... this
-- module is used by my super-hacky code for handling finite planar
-- Heyting Algebras, a.k.a. ZHAs, and is not independent from it. =(
--
--
-- «.V»				(to "V")
-- «.V-tests»			(to "V-tests")
-- «.BoundingBox»		(to "BoundingBox")
-- «.BoundingBox-tests»		(to "BoundingBox-tests")
-- «.AsciiPicture»		(to "AsciiPicture")
-- «.AsciiPicture-tests»	(to "AsciiPicture-tests")
-- «.metaopts»			(to "metaopts")
-- «.copyopts»			(to "copyopts")
-- «.copyopts-tests»		(to "copyopts-tests")
-- «.makepicture»		(to "makepicture")
-- «.makepicture-tests»		(to "makepicture-tests")
-- «.texarrow»			(to "texarrow")
-- «.pict2e»			(to "pict2e")
-- «.pict2e-test»		(to "pict2e-test")
-- «.LPicture»			(to "LPicture")
-- «.LPicture-tests»		(to "LPicture-tests")
--
-- Obsolete (to be deleted):
-- «.Picture»			(to "Picture")
-- «.Picture-tests»		(to "Picture-tests")


require "output"             -- (find-dn6 "output.lua" "formatt")




--  ____  ____                   _                 
-- |___ \|  _ \  __   _____  ___| |_ ___  _ __ ___ 
--   __) | | | | \ \ / / _ \/ __| __/ _ \| '__/ __|
--  / __/| |_| |  \ V /  __/ (__| || (_) | |  \__ \
-- |_____|____/    \_/ \___|\___|\__\___/|_|  |___/
--                                                 
-- This class supports the usual operations on 2D vectors and also the
-- logical operations on elements of a ZHA - even the implication,
-- IIRC...
-- «V» (to ".V")
V = Class {
  type    = "V",
  -- __tostring = function (v) return "("..v[1]..","..v[2]..")" end,
  __tostring = function (v) return pformat("(%s,%s)",    v[1], v[2]) end,
  __add      = function (v, w) return V{v[1]+w[1], v[2]+w[2]} end,
  __sub      = function (v, w) return V{v[1]-w[1], v[2]-w[2]} end,
  __unm      = function (v) return v*-1 end,
  __mul      = function (v, w)
      local ktimesv   = function (k, v) return V{k*v[1], k*v[2]} end
      local innerprod = function (v, w) return v[1]*w[1] + v[2]*w[2] end
      if     type(v) == "number" and type(w) == "table" then return ktimesv(v, w)
      elseif type(v) == "table" and type(w) == "number" then return ktimesv(w, v)
      elseif type(v) == "table" and type(w) == "table"  then return innerprod(v, w)
      else error("Can't multiply "..tostring(v).."*"..tostring(w))
      end
    end,
  --
  -- isdd = function (s)
  --     return type(s) == "string" and s:match"^%d%d$"
  --   end,
  -- ispxcyp = function (s)
  --     return type(s) == "string" and s:match"^%((.-),(.-)%)$"
  --   end,
  -- fromdd = function (s) return V{s:sub(1,1)+0, s:sub(2,2)+0} end,
  -- frompxcyp = function (s)
  --     local x, y = a:match("^%((.-),(.-)%)$")
  --     return V{x+0, y+0}
  --   end,
  --
  fromab = function (a, b)
      if     type(a) == "table"  then return a
      elseif type(a) == "number" then return V{a,b}
      elseif type(a) == "string" then
        local x, y = a:match("^%((.-),(.-)%)$")
        if x then return V{x+0, y+0} end
        local l, r = a:match("^(%d)(%d)$")
        if l then return V{tonumber(l), tonumber(r)}:lrtoxy() end
        local l, r, ensw = a:match("^(%d)(%d)([ensw])$")
        if l then return V{tonumber(l), tonumber(r)}:lrtoxy():walk(ensw) end
        error("V() got bad string: "..a)
      end
    end,
  __call = function () print "hi"
    end,
  __index = {
    xytolr = function (v)
        local x, y = v[1], v[2]
        local l = toint((y - x) / 2)
        local r = toint((y + x) / 2)
        return V{l, r}
      end,
    lrtoxy = function (v)
        local l, r = v[1], v[2]
        local x = r - l
        local y = r + l
        return V{x, y}
      end,
    todd = function (v) return v[1]..v[2] end,
    to12 = function (v) return v[1], v[2] end,
    to_x_y = function (v) return v:to12() end,
    to_l_r = function (v) return v:xytolr():to12() end,
    xy = function (v) return "("..v[1]..","..v[2]..")" end,
    lr = function (v) local l, r = v:to_l_r(); return l..r end,
    torowcol = function (v, nlines, w, rectw)
        local x, y = v[1], v[2]
        if checkrange(0, y, nlines-1) and
           checkrange(0, x, rectw/w - 1)
        then return nlines-y, x*w+1
        end
      end,
    naiveprod = function (v, w)
        return V{v[1]*w[1], v[2]*w[2]}
      end,
    naivemin = function (v, w)
        return V{min(v[1], w[1]), min(v[2], w[2])}
      end,
    naivemax = function (v, w)
        return V{max(v[1], w[1]), max(v[2], w[2])}
      end,
    s  = function (v) return v+V{ 0, -1} end,
    n  = function (v) return v+V{ 0,  1} end,
    w  = function (v) return v+V{-1,  0} end,
    e  = function (v) return v+V{ 1,  0} end,
    se = function (v) return v+V{ 1, -1} end,
    sw = function (v) return v+V{-1, -1} end,
    ne = function (v) return v+V{ 1,  1} end,
    nw = function (v) return v+V{-1,  1} end,
    walk = function (v, ensw) return v[ensw](v) end,
    -- to_l_r_l_r = function (P, Q)
    --     local Pl,Pr = P:to_l_r()
    --     local Ql,Qr = Q:to_l_r()
    --     return Pl, Pr, Ql, Qr
    --   end,
    --
    And = function (P, Q)
        -- local Pl, Pr, Ql, Qr = P:to_l_r_l_r(Q)
        local Pl, Pr = P:to_l_r()
        local Ql, Qr = Q:to_l_r()
        return V{min(Pl, Ql), min(Pr, Qr)}:lrtoxy()
      end,
    Or = function (P, Q)
        -- local Pl, Pr, Ql, Qr = P:to_l_r_l_r(Q)
        local Pl, Pr = P:to_l_r()
        local Ql, Qr = Q:to_l_r()
        return V{max(Pl, Ql), max(Pr, Qr)}:lrtoxy()
      end,
    --
    above = function (P, Q)
        local Pl, Pr = P:to_l_r()
        local Ql, Qr = Q:to_l_r()
        return Pl >= Ql and Pr >= Qr
      end,
    below = function (P, Q)
        local Pl, Pr = P:to_l_r()
        local Ql, Qr = Q:to_l_r()
        return Pl <= Ql and Pr <= Qr
      end,
    leftof = function (P, Q)
        local Pl, Pr = P:to_l_r()
        local Ql, Qr = Q:to_l_r()
        return Pl >= Ql and Pr <= Qr
      end,
    rightof = function (P, Q)
        local Pl, Pr = P:to_l_r()
        local Ql, Qr = Q:to_l_r()
        return Pl <= Ql and Pr >= Qr
      end,
  },
}

v = V.fromab
lr = function (l, r) return V{l, r}:lrtoxy() end
-- lr = function (l, r)
--     if V.isdd(l) then return V.fromdd(l):lrtoxy() end
--     return V{l, r}:lrtoxy()
--   end

-- «V-tests» (to ".V-tests")
--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "picture.lua"
= V{3,4}             --> (3,4)    
= V{3,4} - V{2,1}    --> (1,3)    
= V{3,4} + V{2,1}    --> (5,5)    
= V{3,4} * V{2,1}    --> 10	     
= V{3,4} * -10	     --> (-30,-40)
= -10 * V{3,4}	     --> (-30,-40)
= V{-3,3}:xytolr()   --> (3,0)    
= V{3,3}:xytolr()    --> (0,3)    
= V{2,4}:xytolr()    --> (1,3)    

dofile "zhas.lua"
= V{0,0}:torowcol(4, 2, 6)   --> 4 1
= V{1,0}:torowcol(4, 2, 6)   --> 4 3
= V{2,0}:torowcol(4, 2, 6)   --> 4 5
= V{3,0}:torowcol(4, 2, 6)   --> (nothing)
= V{0,1}:torowcol(4, 2, 6)   --> 3 1
= V{0,2}:torowcol(4, 2, 6)   --> 3 5
= V{0,3}:torowcol(4, 2, 6)   --> 3 5
= V{0,4}:torowcol(4, 2, 6)   --> (nothing)

-- (ex "v-1")

 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "picture.lua"
= v{2, 3}
= v(2, 3)
= v(2, 3):to12()

-- (ex "v-2")

 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "picture.lua"
= v"20"
= v"02"
= v"22"

-- Obsolete and broken:
= lr"00"      -- err?
= lr"10"      -- err?
= lr"03"      -- err?
= lr"03":s()  -- err?

--  (ex "v-3")

--]]



--  ____                        _ _             ____            
-- | __ )  ___  _   _ _ __   __| (_)_ __   __ _| __ )  _____  __
-- |  _ \ / _ \| | | | '_ \ / _` | | '_ \ / _` |  _ \ / _ \ \/ /
-- | |_) | (_) | |_| | | | | (_| | | | | | (_| | |_) | (_) >  < 
-- |____/ \___/ \__,_|_| |_|\__,_|_|_| |_|\__, |____/ \___/_/\_\
--                                        |___/                 
-- A BoundingBox object contains:
--   a field "x0x0" with a V object (the lower left corner),
--   a field "x1x1" with a V object (the upper right corner).
--
-- «BoundingBox» (to ".BoundingBox")

BoundingBox = Class {
  type    = "BoundingBox",
  new     = function () return BoundingBox {} end,
  __tostring = function (bb)
      -- return bb.x0y0 and tostring(bb.x0y0).." to "..tostring(bb.x1y1) or "empty"
      if bb.x0y0 then
        return "BoundingBox: \n (x1,y1)="..tostring(bb.x1y1)..
                            "\n (x0,y0)="..tostring(bb.x0y0)
      else
        return "BoundingBox: empty"
      end
    end,
  __index = {
    addpoint = function (bb, v)
        if bb.x0y0 then bb.x0y0 = bb.x0y0:naivemin(v) else bb.x0y0 = v end
        if bb.x1y1 then bb.x1y1 = bb.x1y1:naivemax(v) else bb.x1y1 = v end
        return bb
      end,
    addbox = function (bb, v, delta0, delta1)
        bb:addpoint(v+delta0)
        return bb:addpoint(v+(delta1 or -delta0))
      end,
    x0y0x1y1 = function (bb)
        local x0, y0 = bb.x0y0:to_x_y()
        local x1, y1 = bb.x1y1:to_x_y()
        return x0, y0, x1, y1
      end,
    x0x1y0y1 = function (bb)
        local x0, y0 = bb.x0y0:to_x_y()
        local x1, y1 = bb.x1y1:to_x_y()
        return x0, x1, y0, y1
      end,
    --
    merge = function (bb1, bb2)
        if bb2.x0y0 then bb1:addpoint(bb2.x0y0) end
        if bb2.x1y1 then bb1:addpoint(bb2.x1y1) end
        return bb1
      end,
  },
}

-- «BoundingBox-tests» (to ".BoundingBox-tests")
--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "picture.lua"
bb = BoundingBox.new()
PP(bb)
= bb
= bb:addpoint(v(2, 4))
PP(bb)
= bb:addbox(v(6, 7), v(.5, .5))
= bb:addbox(v(1, 2), v(.5, .5))
= bb:x0x1y0y1()
PP(bb)

-- (ex "boundingbox")

--]]



--     _             _ _ ____  _      _                  
--    / \   ___  ___(_|_)  _ \(_) ___| |_ _   _ _ __ ___ 
--   / _ \ / __|/ __| | | |_) | |/ __| __| | | | '__/ _ \
--  / ___ \\__ \ (__| | |  __/| | (__| |_| |_| | | |  __/
-- /_/   \_\___/\___|_|_|_|   |_|\___|\__|\__,_|_|  \___|
--                                                       
-- «AsciiPicture» (to ".AsciiPicture")
-- This is a minimalistic, and V-based, reimplementation of the
-- ascii side of the "Picture" class from:
-- (find-dn6 "picture.lua" "Picture")

pad = function (spaces, str)
    return ((str or "")..spaces):sub(1, #spaces)
  end

AsciiPicture = Class {
  type = "AsciiPicture",
  new  = function (s)
      return AsciiPicture {s=s or "  ", bb=BoundingBox.new()}
    end,
  __tostring = function (ap) return ap:tostring() end,
  __index = {
    get  = function (ap, v) return pad(ap.s, ap:get0(v)) end,
    get0 = function (ap, v)
        local x, y = v:to_x_y()
        return ap[y] and ap[y][x]
      end,
    put = function (ap, v, str)
        local x, y = v:to_x_y()
        ap[y] = ap[y] or {}
        ap[y][x] = str
        ap.bb:addpoint(v)
        return ap
      end,
    --
    tolines = function (ap)
        if not ap.bb.x0y0 then return {} end     -- empty
        local x0, x1, y0, y1 = ap.bb:x0x1y0y1()
        local lines = {}
        for y=y1,y0,-1 do
          local line = ""
          for x=x0,x1 do line = line..ap:get(v(x, y)) end
          table.insert(lines, line)
        end
        return lines
      end,
    tostring = function (ap) return table.concat(ap:tolines(), "\n") end,
    print = function (ap) print(ap); return ap end,
  },
}

-- «AsciiPicture-tests» (to ".AsciiPicture-tests")
--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "picture.lua"
ap = AsciiPicture.new("  ")
ap = AsciiPicture.new("     ")
ap = AsciiPicture.new("      ")
for l=0,2 do
  for r=0,3 do
    local pos=lr(l, r)
    ap:put(pos, "..")
    ap:put(pos, pos:lr())
    ap:put(pos, pos:xy())
  end
end
= ap
PPV(ap)

 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "picture.lua"
ap = AsciiPicture.new("  ")
PP(ap)
PP(ap.bb)
= ap
= ap.bb
ap = AsciiPicture.new("  "):put(v(1,1),"  ")
= ap
= ap:put(v(1,1), "..")
= ap
= ap.bb
PP(ap)

--]]




--                                    _       
--   ___ ___  _ __  _   _  ___  _ __ | |_ ___ 
--  / __/ _ \| '_ \| | | |/ _ \| '_ \| __/ __|
-- | (_| (_) | |_) | |_| | (_) | |_) | |_\__ \
--  \___\___/| .__/ \__, |\___/| .__/ \__|___/
--           |_|    |___/      |_|            
--
-- An _UGLY_ hack to let me specify options for makepicture in a compact way.
-- A call to copyopts(A, B) copies the options in the table A to the table B.
-- If there is a field "meta" in A it is treated in a special way:
--
--   copyopts({foo=2, bar=3, meta="s ()"}, B)
--
-- works as this, but in an unspecified order:
--
--   copyopts({foo=2, bar=3}, B)
--   copyopts(metaopts["s"],  B)
--   copyopts(metaopts["()"], B)
--
-- Used by: (find-dn6 "zhas.lua" "MixedPicture" "LPicture.new(options)")
--          (find-dn6 "picture.lua" "LPicture" "new" "copyopts(opts, lp)")
--
-- «copyopts» (to ".copyopts")
--          
copyopts = function (A, B)
    if type(A) == "string" then
      for _,name in ipairs(split(A)) do
        local tbl = metaopts[name] or error("No metaopt[\""..A.."\"]")
        copyopts(tbl, B)
      end
      return B
      -- Old:
      -- if A:match(" ") then
      --   for _,str in ipairs(split(A)) do copyopts(str, B) end
      --   return B
      -- else
      --   local mopts = metaopts[A] or error("No metaopt[\""..A.."\"]")
      --   return copyopts(mopts, B)
      -- end
    end
    for key,val in pairs(A) do
      if key == "meta" then
        copyopts(val, B)
      else
        B[key] = val
      end
    end
    return B
  end

-- «metaopts» (to ".metaopts")
--
metaopts = {}
metaopts["b"]   = {bhbox = 1}
metaopts["p"]   = {paren = 1}
metaopts["()"]  = {paren = 1}
metaopts["{}"]  = {curly = 1}
metaopts["s"]    = {cellfont="\\scriptsize",       celllower="2pt"}
metaopts["ss"]   = {cellfont="\\scriptscriptsize", celllower="1.5pt"}  -- ?
metaopts["t"]    = {cellfont="\\tiny",             celllower="1.5pt"}  -- ?
metaopts["t"]    = {cellfont="\\tiny",             celllower="1.25pt"}  -- ?
metaopts["10pt"] = {scale="10pt"} 
metaopts["8pt"]  = {scale="8pt", meta="s"} 
--
-- metaopts that are mainly for TCGs:
metaopts["1pt"]  = {scale="1pt"}

-- «copyopts-tests» (to ".copyopts-tests")
--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "picture.lua"
testcopyopts = function (A) PP(copyopts(A, {})) end
testcopyopts  "8pt"
testcopyopts  "8pt ()"
testcopyopts {foo=2, bar=3}
testcopyopts {foo=2, bar=3, meta="8pt"}
testcopyopts {foo=2, bar=3, meta="8pt ()"}
testcopyopts {foo=2, bar=3}

--]]






--                  _              _      _                  
--  _ __ ___   __ _| | _____ _ __ (_) ___| |_ _   _ _ __ ___ 
-- | '_ ` _ \ / _` | |/ / _ \ '_ \| |/ __| __| | | | '__/ _ \
-- | | | | | | (_| |   <  __/ |_) | | (__| |_| |_| | | |  __/
-- |_| |_| |_|\__,_|_|\_\___| .__/|_|\___|\__|\__,_|_|  \___|
--                          |_|                              
--
-- «makepicture» (to ".makepicture")
-- (find-LATEX "edrx15.sty" "picture-cells")
--
makepicture = function (options, bb, body)
    local x0, y0, x1, y1 = bb:x0y0x1y1()
    local a = {}
    a.xdimen = x1 - x0
    a.ydimen = y1 - y0
    -- a.xoffset = (x0 + x1)/2
    -- a.yoffset = (y0 + y1)/2
    a.xoffset = x0
    a.yoffset = y0
    a.setscale = "\\unitlength="..(options.scale or "10pt").."%\n"
    a.setlower = "\\celllower="..(options.celllower or "2.5pt").."%\n"
    a.setfont  = "\\def\\cellfont{"..(options.cellfont or "").."}%\n"
    a.body = body
    -- local fmt = "!setscale!setlower!setfont"..
    --             "\\begin{picture}(!xdimen,!ydimen)(!xoffset,!yoffset)\n"..
    --             "!body"..
    --             "\\end{picture}"
    -- 2017nov28:
    a.xydimen  = tostring(v(a.xdimen,  a.ydimen))
    a.xyoffset = tostring(v(a.xoffset, a.yoffset))
    local fmt = "!setscale!setlower!setfont"..
                "\\begin{picture}!xydimen!xyoffset\n"..
                "!body"..
                "\\end{picture}"
    local latex = (fmt:gsub("!([a-z]+)", a))
    latex = "\\vcenter{\\hbox{"..latex.."}}"
    if options.bhbox then latex = "\\bhbox{$"..latex.."$}" end
    if options.paren then latex = "\\left("..latex.."\\right)" end
    if options.curly then latex = "\\left\\{"..latex.."\\right\\}" end
    if options.def   then latex = "\\def\\"..options.def.."{"..latex.."}" end
    --
    -- 2019apr29:
    -- (find-es "dednat" "defzha-and-deftcg")
    if options.tdef  then latex = "\\deftcg{"..options.tdef.."}{"..latex.."}" end
    if options.zdef  then latex = "\\defzha{"..options.zdef.."}{"..latex.."}" end
    return latex
  end

-- «makepicture-tests»  (to ".makepicture-tests")
--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "picture.lua"
bb = BoundingBox.new()
bb:addpoint(v(2,5))
bb:addpoint(v(4,12))
= bb
opts = {}
body = "  hello\n"
= makepicture({},           bb, body)
= makepicture({def ="foo"}, bb, body)
= makepicture({tdef="foo"}, bb, body)
= makepicture({zdef="foo"}, bb, body)
= makepicture({meta="s"},   bb, body)

--]]



--  _                                        
-- | |_ _____  ____ _ _ __ _ __ _____      __
-- | __/ _ \ \/ / _` | '__| '__/ _ \ \ /\ / /
-- | ||  __/>  < (_| | |  | | | (_) \ V  V / 
--  \__\___/_/\_\__,_|_|  |_|  \___/ \_/\_/  
--                                           
-- «texarrow» (to ".texarrow")
-- Used in: (find-dn6 "zhas.lua" "MixedPicture")
--          (find-dn6 "zhas.lua" "MixedPicture" "addarrows =")
--          (find-dn6 "zhas.lua" "MixedPicture" "addarrowsexcept =")
--          (find-dn6 "picture.lua" "LPicture")
--          (find-dn6 "picture.lua" "LPicture" "putarrow =")
--          (find-dn6 "zhas.lua" "ZHA")
--          (find-dn6 "zhas.lua" "ZHA" "arrows =")
--
texarrow = {
  nw="\\nwarrow",  n="\\uparrow",   ne="\\nearrow",
   w="\\leftarrow",                  e="\\rightarrow",
  sw="\\swarrow",  s="\\downarrow", se="\\searrow",
}
texarrow_inv = {
  nw="\\searrow",   n="\\downarrow", ne="\\swarrow",
   w="\\rightarrow",                  e="\\leftarrow",
  sw="\\nearrow",   s="\\uparrow",   se="\\nwarrow", 
}
texarrow_smart = function (usewhitemoves)
    if usewhitemoves then return texarrow_inv end
    return texarrow
  end

-- Usage: local tar = texarrow_smart(usewhitemoves)
--        pic:putarrow(v"34", 0, -1, tar.s)



--        _      _   ____      
--  _ __ (_) ___| |_|___ \ ___ 
-- | '_ \| |/ __| __| __) / _ \
-- | |_) | | (__| |_ / __/  __/
-- | .__/|_|\___|\__|_____\___|
-- |_|                         
--
-- «pict2e» (to ".pict2e")
-- In the old picture-mode a line segment and an arrow from (x0,y0)
-- to (x1,y1) had to be written as:
--
--   \put(x0,y0){\line(Dx,Dy){len}}
--   \put(x0,y0){\arrow(Dx,Dy){len}}
--
-- respectively, where:
--
--   (x1,y1) = (x0,y0) + len * (Dx,Dy),
--   Dx and Dy are integers between -6 and 6, and
--   Dx and Dy have no common divisor.
--
-- This is explained here (Dx and Dy form a "slope pair"):
--
--   (find-kopkadaly4page (+ 12 294) "Straight lines")
--   (find-kopkadaly4text (+ 12 294) "Straight lines")
--   (find-kopkadaly4page (+ 12 294) "Straight lines" "slope pair")
--   (find-kopkadaly4text (+ 12 294) "Straight lines" "slope pair")
--   (find-kopkadaly4page (+ 12 294) "Arrows")
--   (find-kopkadaly4text (+ 12 294) "Arrows")
--   (find-kopkadaly4page (+ 12 295) "\\vector(x,y){length}")
--   (find-kopkadaly4text (+ 12 295) "\\vector(x,y){length}")
--
-- As I only used lines that were either vertical or had slopes 0, 1,
-- or -1, my code for calculating Dx, Dy and len was just the sequence
-- of "if"s below, that would not cover cases like dy/dx = 2/3...
--
--   pictvector = function (x0, y0, x1, y1)
--       local dx, dy = x1 - x0, y1 - y0
--       local f = function (dx, dy, len)
--           return format("\\put(%.3f,%.3f){\\vector(%.3f,%.3f){%.3f}}",
--             x0, y0, dx, dy, len)
--         end
--       if dx > 0 then return f(1, dy/dx, dx) end
--       if dx < 0 then return f(-1, -dy/dx, -dx) end
--       if dx == 0 and dy > 0 then return f(0, 1, dy) end
--       if dx == 0 and dy < 0 then return f(0, -1, -dy) end
--       error()
--     end
--
-- In pict2e we can create line segments and arrows with just:
--
--   \Line(x0,y0)(x1,y1)
--   \put(x0,y0){\arrow(dx,dy){len}}
--
-- with dx=x1-x0, dy=y1-y0, len=|dx|. See:
--
--   (find-pict2epage 4 "\\line and \\vector Slopes")
--   (find-pict2etext 4 "\\line and \\vector Slopes")
--   (find-pict2epage 4 "\\vector Slopes" "These restrictions are eliminated")
--   (find-pict2etext 4 "\\vector Slopes" "These restrictions are eliminated")
--   (find-pict2epage 9 "2.4.2   Lines, polygons")
--   (find-pict2etext 9 "2.4.2   Lines, polygons")
--
pict2eline = function (x0, y0, x1, y1)
    return pformat("\\Line(%s,%s)(%s,%s)", x0,y0, x1,y1)
  end
pict2evector = function (x0, y0, x1, y1)
    local dx, dy = x1-x0, y1-y0
    local absdx, absdy = math.abs(dx), math.abs(dy)
    local veryvertical = absdy > 100*absdx
    local f = function (Dx,Dy,len) return
        pformat("\\put(%s,%s){\\vector(%s,%s){%s}}", x0,y0, Dx,Dy, len)
      end
    if veryvertical then
      if dy > 0 then return f(0,1, dy) else return f(0,-1, -dy) end 
    else
      if dx > 0 then return f(dx,dy, dx) else return f(dx,dy, -dx) end
    end 
  end


-- «pict2e-test» (to ".pict2e-test")
--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "picture.lua"
= pict2eline  (1.2, 3.4, 5.6, 7.2)
= pict2evector(1.2, 3.4, 5.6, 7.2)

 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
loaddednat6()
lp = LPicture.new({def="foo"})
for theta=0.1,2*math.pi,0.1 do
  local vunit = v(math.cos(theta), math.sin(theta))
  lp:addlineorvector(v(0,0), vunit*theta, "vector")
end
lp:print()

--]]





--  _     ____  _      _                  
-- | |   |  _ \(_) ___| |_ _   _ _ __ ___ 
-- | |   | |_) | |/ __| __| | | | '__/ _ \
-- | |___|  __/| | (__| |_| |_| | | |  __/
-- |_____|_|   |_|\___|\__|\__,_|_|  \___|
--                                        
-- «LPicture» (to ".LPicture")
-- This is a minimalistic, and V-based, reimplementation of the
-- LaTeX side of the "Picture" class from:
--   (find-dn6 "picture.lua" "Picture")
-- This is used by:
--   (find-dn6 "zhas.lua" "MixedPicture")
--   (find-dn6 "zhas.lua" "MixedPicture" "both an ascii representation and a LaTeX")

LPicture = Class {
  type = "LPicture",
  new  = function (opts)
      local lp = {latex="", bb=BoundingBox.new()}    -- start empty
      -- for k,v in pairs(opts or {}) do lp[k] = v end  -- copy options
      copyopts(opts, lp)
      return LPicture(lp)                            -- set metatable
    end,
  __tostring = function (lp) return lp:tolatex() end,
  __index = {
    addpoint = function (lp, v) lp.bb:addpoint(v); return lp end,
    put = function (lp, v, tex)
        local x, y = v:to_x_y()
        lp.latex = lp.latex .. "  \\put("..x..","..y.."){\\cell{"..tex.."}}\n"
        lp:addpoint(v-V{.5,.5})
        lp:addpoint(v+V{.5,.5})
        return lp
      end,
    putarrow = function (lp, v, dx, dy, tex)
        lp:put(v+V{dx,dy}*0.5, tex)
      end,
    --
    -- Old version with obsolete picture-mode-isms:
    -- addlineorvector = function (lp, src, tgt, cmd)
    --     lp:addpoint(src)
    --     lp:addpoint(tgt)
    --     local x0, y0 = src:to_x_y()
    --     local x1, y1 = tgt:to_x_y()
    --     local dx, dy = x1-x0, y1-y0
    --     local adx, ady = math.abs(dx), math.abs(dy)
    --     local len = max(adx, ady)
    --     local udx, udy = dx/len, dy/len
    --     local put = "  \\put("..x0..","..y0..")"..
    --                 "{\\"..(cmd or "line").."("..udx..","..udy.."){"..len.."}}"
    --     lp.latex = lp.latex..put.."\n"
    --   end,
    --
    addlineorvector = function (lp, src, tgt, cmd) 
        lp:addpoint(src)
        lp:addpoint(tgt)
        local x0, y0 = src:to_x_y()
        local x1, y1 = tgt:to_x_y()
        local tex = (cmd == "vector") and pict2evector(x0,y0, x1,y1)
                                      or  pict2eline  (x0,y0, x1,y1)
        lp.latex = lp.latex.."  "..tex.."\n"
      end,
    --
    tolatex = function (lp)
        return makepicture(lp, lp.bb, lp.latex)
      end,
    --
    -- 2016dec08:
    addtex = function (lp, tex) lp.latex = lp.latex.."  "..tex.."\n"; return lp; end,
    addt   = function (lp, ...) return lp:addtex(formatt(...)) end,
    rawput = function (lp, v, tex) return lp:addt("\\put%s{%s}", v, tex) end,
    print  = function (lp) print(lp); return lp end,
    lprint = function (lp) print(lp:tolatex()); return lp end,
    output = function (lp) output(lp:tolatex()); return lp end,
    --
    -- 2019apr28:
    -- (find-es "dednat" "LPicture.addrect")
    addrect4 = function (lp, x0, y0, x1, y1)
        return lp:addt("\\polygon(%s,%s)(%s,%s)(%s,%s)(%s,%s)",
                       x0,y0, x1,y0, x1,y1, x0,y1)
      end,
    addrect2 = function (lp, x0y0, x1y1)
        local x0,y0 = x0y0:to_x_y()
        local x1,y1 = x1y1:to_x_y()
        return lp:addt("\\polygon(%s,%s)(%s,%s)(%s,%s)(%s,%s)",
                       x0,y0, x1,y0, x1,y1, x0,y1)
      end,
    addrectr = function (lp, cxcy, rxry)
        return lp:addrect2(cxcy-rxry, cxcy+rxry)
      end,
    --
    -- 2019apr28. Calls this:
    --     (find-LATEX "edrxtikz.lua" "Line")
    --     (find-LATEX "edrxtikz.lua" "Line" "pictv =")
    -- or: (find-dn6 "tcgs.lua" "Line")
    --     (find-dn6 "tcgs.lua" "Line" "pictv =")
    addarrow = function (lp, A, B, t0, t1)
        lp:addtex(Line.newAB(A, B, t0, t1):pictv())
      end,
  },
}

-- «LPicture-tests» (to ".LPicture-tests")
--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "picture.lua"
lp = LPicture.new {cellfont="\\scriptsize"}
for l=0,2 do
  for r=0,3 do
    local pos=lr(l, r)
    lp:put(pos, pos:xy())
  end
end
= lp

 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "picture.lua"
-- (find-angg "LUA/lua50init.lua" "pformat")
V.__tostring = function (v) return format("(%.3f,%.3f)", v[1], v[2]) end
V.__tostring = function (v) return format("(%s,%s)", myntos(v[1]), myntos(v[2])) end
V.__tostring = function (v) return "("..myntos(v[1])..","..myntos(v[2])..")" end

= v(1/3, 2/3)
= tostring(v(1/3, 2/3))
LPicture.__index.addLine = function (lp, src, tgt)
    lp:addpoint(src)
    lp:addpoint(tgt)
    local Line = "  \\Line"..tostring(src)..tostring(tgt)
    lp.latex = lp.latex..Line.."\n"
  end
LPicture.__index.setthickness = function (lp, src, tgt)
    lp.latex = lp.latex.."  \linethickness{"..thickness.."}\n"
  end
lp = LPicture.new {}
x0, x1 = 0, 10
lp:addLine(v(x0, 1/3), v(x0, 2/3))
= lp

--]]








--   ___  _               _      _         
--  / _ \| |__  ___  ___ | | ___| |_ ___ _ 
-- | | | | '_ \/ __|/ _ \| |/ _ \ __/ _ (_)
-- | |_| | |_) \__ \ (_) | |  __/ ||  __/_ 
--  \___/|_.__/|___/\___/|_|\___|\__\___(_)
--                                         

--  ____  _      _                         _
-- |  _ \(_) ___| |_ _   _ _ __ ___    ___| | __ _ ___ ___
-- | |_) | |/ __| __| | | | '__/ _ \  / __| |/ _` / __/ __|
-- |  __/| | (__| |_| |_| | | |  __/ | (__| | (_| \__ \__ \
-- |_|   |_|\___|\__|\__,_|_|  \___|  \___|_|\__,_|___/___/
--
-- «Picture» (to ".Picture")
-- We can ":put" things one by one into a Picture object, and ":totex"
-- will generate a "\begin{picture}...\end{picture}" LaTeX block with
-- the right size and offset. Also, ":toascii" generates an ascii
-- rendering of that picture object, great for debugging and stuff.

Picture = Class {
  type    = "Picture",
  new     = function (opts)
      local p = {whats={}, other={}}                -- start empty
      for k,v in pairs(opts or {}) do p[k] = v end  -- copy options
      return Picture(p)                             -- set metatable
    end,
  __index = {
    adjustbounds = function (p, x, y)
        p.minx, p.maxx = Min(p.minx, x), Max(x, p.maxx)
        p.miny, p.maxy = Min(p.miny, y), Max(y, p.maxy)
      end,
    put = function (p, x, y, what, what0)
        p:adjustbounds(x, y)
        -- p.minx = p.minx and min(x, p.minx) or x
        -- p.miny = p.miny and min(y, p.miny) or y
        -- p.maxx = p.maxx and max(p.maxx, x) or x
        -- p.maxy = p.maxy and max(p.maxy, y) or y
        table.insert(p.whats, {x=x, y=y, what=what, what0=what0})
        return p
      end,
    lrput = function (p, l, r, what, what0)
        local x = r - l
        local y = r + l
        p:put(x, y, what, what0)
        return p
      end,
    lrputline = function (p, l, r, dxdy, len)
        return p:lrput(l, r, nil, format("\\line(%s){%s}", dxdy, len))
      end,
    togrid = function (p)
        local lines = {}
        for y=p.miny,p.maxy do lines[y] = {} end
        for _,what in ipairs(p.whats) do
          lines[what.y][what.x] = what.what
        end
        return lines
      end,
    toasciilines = function (p, whitespace)
        local asciilines = {}
        local grid = p:togrid()
        for y=p.miny,p.maxy do
          for x=p.minx,p.maxx do
            local ascii = grid[y][x] or whitespace or "  "
            asciilines[y] = (asciilines[y] or "")..ascii
          end
        end
        return asciilines
      end,
    toascii = function (p, whitespace)
        local asciilines = p:toasciilines(whitespace)
        local lines = {}
        for y=p.maxy,p.miny,-1 do
          table.insert(lines, asciilines[y])
        end
        return table.concat(lines, "\n")
      end,
    --
    -- (find-es "tex" "dags")
    -- (find-kopkadaly4page (+ 12 289) "13.1.3 The positioning commands")
    -- (find-kopkadaly4text (+ 12 289) "13.1.3 The positioning commands")
    -- (find-kopkadaly4page (+ 12 298) "\\put")
    -- (find-kopkadaly4text (+ 12 298) "\\put")
    totex1 = function (p, what)
        -- local fmt = "  \\put(%s,%s){%s}\n"
        if what.what0 then
          return format("  \\put(%s,%s){%s}\n", what.x, what.y, what.what0)
        end
        local fmt = "  \\put(%s,%s){\\hbox to 0pt{\\hss %s%s\\hss}}\n"
        return format(fmt, what.x, what.y, p.font or "", what.what)
      end,
    totexputs = function (p)
        local f = function (what) return p:totex1(what) end
        return mapconcat(f, p.whats)
      end,
    --
    -- (find-kopkadaly4page (+ 12 301) "13.1.6 Shifting a picture environment")
    -- (find-kopkadaly4text            "13.1.6 Shifting a picture environment")
    -- (find-texbookpage (+ 12 66) "\\raise")
    -- (find-texbooktext (+ 12 66) "\\raise")
    totex = function (p)
        local a = {}
        a.scale   = p.scale or "1ex"
        a.xdimen  = p.maxx - p.minx + 1
        a.ydimen  = p.maxy - p.miny + 1
        a.xoffset = p.minx - 0.5
        -- a.yoffset = (p.miny + p.maxy + 1) / 2
        a.yoffset = p.miny
        a.lower   = (p.maxy - p.miny) / 2
        -- a.body = p:totexputs()
        a.body    = p:totexputs()..table.concat(p.other)
        local fmt = "{\\unitlength=!scale\n"..
                    "\\lower!lower\\unitlength\\hbox{"..
                    "\\begin{picture}(!xdimen,!ydimen)(!xoffset,!yoffset)\n"..
                    "!body"..
                    "\\end{picture}\n"..
                    "}}"
        return (fmt:gsub("!([a-z]+)", a))
      end,
  },
}



-- «Picture-tests» (to ".Picture-tests")
--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "picture.lua"
p = Picture.new()
p:put(2, 3, "23")
p:put(4, 7, "47")
PP(p)
PP(p:togrid())
= p:toascii()
= p:totexputs()
p.scale = "10pt"
= p:totex()
-- (find-LATEX "tmp.tex")

f1 = function (p, lr)
    local l = lr:sub(1,1)+0
    local r = lr:sub(2,2)+0
    p:lrput(l, r, lr)
  end
f = function (p, str)
    for _,lr in ipairs(split(str)) do
      f1(p, lr)
    end
  end

p = Picture {whats={}}
f(p, "00 01 02 03 04")
f(p, "10 11 12 13 14")
f(p,       "22 23 24")
f(p,       "32 33 34")

= p:toascii()
p.scale = "10pt"
= p:totex()     -- broken

--]]



-- Local Variables:
-- coding: raw-text-unix
-- End:
