-- luarects.lua: a preprocessor tho let us use literal rectangles in Lua code.
-- This file:
-- http://angg.twu.net/dednat6/dednat6/luarects.lua
-- http://angg.twu.net/dednat6/dednat6/luarects.lua.html
--         (find-angg "dednat6/dednat6/luarects.lua")
--
-- This is a hack that I wrote for my "Planar Heyting Algebras for
-- Children" paper, that is at:
--   http://angg.twu.net/math-b.html#zhas-for-children-2
--   http://angg.twu.net/LATEX/2017planar-has-1.pdf
--   http://angg.twu.net/LATEX/2017planar-has-1.tgz (full source)
--
-- To see examples of how I use this, download the .tgz above and look
-- for the "%R"-blocks in 2017planar-has-1.tex.
--   (find-LATEXgrep "grep --color -nH --null -e '%R' 2017planar-has-1.tex")
--   http://catb.org/jargon/html/Y/You-are-not-expected-to-understand-this.html
--
-- Here's a brief low-level view of how it works.
-- When this code in a .tex file is executed by a \pu,
--
--   %R A = 1/ a \;  B = 2/abcd\;
--   %R      |b c|        \efgh/   C = 1/o o \
--   %R      | d |                      | o o|
--   %R      \  e/                      \o o /
--   %R 
--   %R foo(A, B, C)
--
-- The effect is the same as executing this "%L"-block:
--
--   %L local aR0 = AsciiRect.new(1, {" a ", "b c", " d ", "  e"})
--   %L local aR1 = AsciiRect.new(2, {"abcd", "efgh"})
--   %L local aR2 = AsciiRect.new(1, {"o o ", " o o", "o o "})
--   %L A = aR0   ;  B = aR1    ;
--   %L                            C = aR2    
--   %L                                       
--   %L foo(A, B, C)
--


-- «.AsciiRect»			(to "AsciiRect")
-- «.AsciiRect-tests»		(to "AsciiRect-tests")
-- «.LuaWithRects»		(to "LuaWithRects")
-- «.luarecteval»		(to "luarecteval")
-- «.LuaWithRects-tests»	(to "LuaWithRects-tests")
-- «.ZHAFromPoints»		(to "ZHAFromPoints")
-- «.ZHAFromPoints-tests»	(to "ZHAFromPoints-tests")


trim  = function (s) return s and (s:match"^(.-)[ \t]*$") end
trim1 = function (s) s = s and trim(s); if s ~= "" then return s end end

linestomatrixbody = function (lines)
    if type(lines) == "string" then lines = splitlines(lines) end
    local celltotex = function (str)
        if str == "." then return "" end
        return unabbrev((str:gsub("!", "\\")))
      end
    local linetotex = function (i)
        return mapconcat(celltotex, split(lines[i]), " & ")
      end
    local tex = linetotex(1).." \\\\ \\hline\n"
    for i=2,#ar.lines do
      tex = tex..linetotex(i).." \\\\\n"
    end
    return tex
  end



--     _             _ _ ____           _   
--    / \   ___  ___(_|_)  _ \ ___  ___| |_ 
--   / _ \ / __|/ __| | | |_) / _ \/ __| __|
--  / ___ \\__ \ (__| | |  _ <  __/ (__| |_ 
-- /_/   \_\___/\___|_|_|_| \_\___|\___|\__|
--                                          
-- «AsciiRect» (to ".AsciiRect")
-- Note: this class is for rectangles from which we want to READ their
-- cells. Compare with rect.lua,
--   (find-dn6 "rect.lua")
-- which is for write-only-ish rectangles glueable in several ways,
-- and with AsciiPicture:
--   (find-dn6 "picture.lua" "AsciiPicture")
--
-- Example of use:
--   for x,y,c in AsciiRect.new(1, " a  |b c | d e|  f "):gen() do ... end

AsciiRect = Class {
  type = "AsciiRect",
  new  = function (w, lines, x0)
      if type(lines) == "string" then
        lines = splitlines((lines:gsub("|", "\n")))
      end
      return AsciiRect {w=w, lines=lines, x0=x0 or 0}
    end,
  __tostring = function (ar)
      return format("w=%d x0=%d\n%s", ar.w, ar.x0, table.concat(ar.lines, "\n"))
    end,
  __index = {
    linetoy = function (ar, l) return #ar.lines - l end,
    ytoline = function (ar, y) return #ar.lines - y end,
    coltopos = function (ar, c) return ar.w*c + 1 end,
    postocol = function (ar, p) return (p - 1)/ar.w end,
    coltox = function (ar, c) return c - ar.x0 end,
    xtocol = function (ar, x) return x + ar.x0 end,
    --
    read_linepos = function (ar, l, p)
        return (ar.lines[l] or ""):sub(p, p+ar.w-1)
      end,
    read_ycol = function (ar, y, c)
        return ar:read_linepos(ar:ytoline(y), ar:coltopos(c))
      end,
    read_xy = function (ar, x, y) return ar:read_ycol(y, ar:xtocol(x)) end,
    read_linepos1 = function (ar, l, p) return trim1(ar:read_linepos(l, p)) end,
    read_ycol1    = function (ar, y, c) return trim1(ar:read_ycol(y, c)) end,
    read_xy1      = function (ar, x, y) return trim1(ar:read_xy(x, y)) end,
    hasxy         = function (ar, x, y) return trim1(ar:read_xy(x, y)) end,
    --
    setx0 = function (ar)
        local lastline = ar.lines[#ar.lines]
        ar.x0 = #(lastline:match"^ *") / ar.w
        return ar
      end,
    --
    maxline = function (ar) return #ar.lines[l] end,
    maxcol = function (ar, l) return (#ar.lines[l] / ar.w)-1 end,
    minx = function (ar) return -ar.x0 end,
    maxx = function (ar, y) return ar:maxcol(ar:ytoline(y)) - ar.x0 end,
    maxy = function (ar) return #ar.lines - 1 end,
    --
    gen = function (ar)
        return cow(function ()
            for line=1,#ar.lines do
              for col=0,(#ar.lines[line] / ar.w)-1 do
                local str = ar:read_linepos(line, ar:coltopos(col))
                if not str:match"^ *$" then
                  coy(ar:coltox(col), ar:linetoy(line), str)
                end
              end
            end
          end)
      end,
    --
    -- Generate all points and all arrows (the black moves) of the zrect.
    -- Similar to: (find-dn6 "newrect.lua" "ZHA" "points =")
    --        and: (find-dn6 "newrect.lua" "ZHA" "arrows =")
    points = function (ar) -- TODO
        return cow(function ()
            for y=ar:maxy(),0,-1 do
              for x=ar:minx(y),ar:maxx(y) do
                local str = ar:read_xy1(x, y)
                if str then coy(v(x, y), str) end
              end
            end
          end)
      end,
    arrows = function (ar, usewhitemoves)
        local tar = texarrow_smart(usewhitemoves)
        return cow(function ()
            for y=ar:maxy(),1,-1 do
              for x=ar:minx(y),ar:maxx(y) do
                if ar:hasxy(x, y) then
		  if ar:hasxy(x-1, y-1) then coy(v(x, y), -1, -1, tar.sw) end
		  if ar:hasxy(x,   y-1) then coy(v(x, y),  0, -1, tar.s ) end
		  if ar:hasxy(x+1, y-1) then coy(v(x, y),  1, -1, tar.se) end
                  -- coy returns: v(x,y), dx, dy, tex
                end
              end
            end
          end)
      end,
    --
    toexpr = function (ar)
        local f = function (s) return format("%q", s) end
        local body = mapconcat(f, ar.lines, ", ")
        return format("AsciiRect.new(%d, {%s})", ar.w, body)
      end,
    --
    -- Uses the ZHAFromPoints class defined below
    spec = function (ar)
        local z = ZHAFromPoints.new()
        for x,y,str in ar:gen() do z:putxy(x, y) end
        return z:spec()
      end,
    -- See: (find-dn6 "newrect.lua" "MixedPicture-tests")
    zhatomixedpicture0 = function (ar, opts)
        return mpnew(opts, ar:spec())
      end,
    zhatomixedpicture = function (ar, opts)
        local mp = mpnew(opts, ar:spec())
        for x,y,str in ar:setx0():gen() do mp:put(v(x, y), str) end
        return mp
      end,
    tomixedpicture = function (ar, opts)
        return MixedPicture.new(opts, nil, nil, ar)
      end,
    --
    tomp  = function (ar, opts)
        return MixedPicture.new(opts, nil,       nil, ar)
      end,
    tozmp = function (ar, opts)
        -- return MixedPicture.new(opts, ar:spec(), nil, ar)
        return MixedPicture.new(opts, ZHA.fromspec(ar:spec()), nil, ar:setx0())
      end,
    --
    tomatrix = function (ar, def)
        local tex = linestomatrixbody(ar.lines)
        tex = "\\begin{matrix}\n"..tex.."\\end{matrix}"
        tex = "\\def\\"..def.."{\n"..tex.."}"
        output(tex)
      end,
  },
}

-- «AsciiRect-tests» (to ".AsciiRect-tests")
--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "luarects.lua"
ar = AsciiRect.new(1, " a  |b c | d e|  f ")
= ar
for x,y,str in ar:gen() do printf("(%d,%d):%s\n", x, y, str) end
= ar:setx0()
for x,y,str in ar:gen() do printf("(%d,%d):%s\n", x, y, str) end
PPV(ar)

 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "luarects.lua"
dofile "picture.lua"
ar = AsciiRect.new(1, " a  |b c | d e|  f ")
for v,str in ar:points() do printf("%s:%s\n", v:xy(), str) end
for v,dx,dy,tex in ar:arrows() do printf("%s,%d,%d,%s\n", v:xy(), dx, dy, tex) end
= ar:setx0()
for x,y,str in ar:gen() do printf("(%d,%d):%s\n", x, y, str) end
PPV(ar)

 (ex "asciirect")

--]]




--  _              __        ___ _   _     ____           _       
-- | |   _   _  __ \ \      / (_) |_| |__ |  _ \ ___  ___| |_ ___ 
-- | |  | | | |/ _` \ \ /\ / /| | __| '_ \| |_) / _ \/ __| __/ __|
-- | |__| |_| | (_| |\ V  V / | | |_| | | |  _ <  __/ (__| |_\__ \
-- |_____\__,_|\__,_| \_/\_/  |_|\__|_| |_|_| \_\___|\___|\__|___/
--                                                                
-- «LuaWithRects» (to ".LuaWithRects")

LuaWithRects = Class {
  type = "LuaWithRects",
  new  = function (lines)
      if type(lines) == "string" then lines = splitlines(lines) end
      return LuaWithRects {lines=lines, defs="", ars={}}
    end,
  __tostring = function (lwr) return lwr:tostring() end,
  __index = {
    body = function (lwr) return table.concat(lwr.lines, "\n") end,
    tostring = function (lwr) return lwr.defs..lwr:body() end,
    --
    read = function (lwr, nline, pos1, pos2)
        return lwr.lines[nline]:sub(pos1, pos2-1)
      end,
    readasciirect = function (lwr, w, nline1, nline2, pos1, pos2)
        local ar = AsciiRect.new(w, {})
        for y=nline1,nline2 do table.insert(ar.lines, lwr:read(y, pos1, pos2)) end
        return ar
      end,
    --
    replace = function (lwr, nline, pos1, pos2, newstr, spc)
        local line = lwr.lines[nline]
        local a, b, c = line:sub(1, pos1-1), line:sub(pos1, pos2-1), line:sub(pos2)
        newstr = newstr .. (spc or " "):rep(pos2-pos1)
        newstr = newstr:sub(1, (pos2-pos1))
        lwr.lines[nline] = a..newstr..c
        return lwr
      end,
    replacerect = function (lwr, nline1, nline2, pos1, pos2, newstr, spc)
        lwr:replace(nline1, pos1, pos2, newstr, spc)
        for y=nline1+1,nline2 do lwr:replace(y, pos1, pos2, "", spc) end
        return lwr
      end,
    --
    matchasciirect = function (lwr, nline1)
        local pos1, w, pos2 = lwr.lines[nline1]:match "()(%d)/[^\\]+\\()"
        if pos1 then
          local yc = function (y) return lwr.lines[y]:sub(pos1+1, pos1+1) end
          local nline2 = nline1 + 1
          while yc(nline2) == "|" do nline2 = nline2 + 1 end
          if yc(nline2) == "\\" then
            return w+0, nline1, nline2, pos1, pos2
          else
            error("Rectangle starting at line "..nline1..", "..
                  "column "..pos1.." does not close")
          end
        end
      end,
    extractasciirect = function (lwr, w, nline1, nline2, pos1, pos2, newstr)
        local ar = lwr:readasciirect(w, nline1, nline2, pos1+2, pos2-1)
        lwr:replacerect(nline1, nline2, pos1, pos2, newstr)
        return ar
      end,
    ntoname = function (lwr, n) return "aR"..n end,
    extractasciirects = function (lwr)
        for nline = 1,#lwr.lines do
          while true do
            local w, y1, y2, pos1, pos2 = lwr:matchasciirect(nline)
            if not w then break end
            local name = lwr:ntoname(#lwr.ars)
            local ar = lwr:readasciirect(w, y1, y2, pos1+2, pos2-1)
            lwr:extractasciirect(w, y1, y2, pos1, pos2, name)
            table.insert(lwr.ars, {name, ar})
            lwr.defs = lwr.defs .. format("local %s = %s\n", name, ar:toexpr())
          end
        end
        return lwr
      end,
  },
}

-- «luarecteval» (to ".luarecteval")
-- See: (find-dn6 "heads6.lua" "luarect-head")
luarectexpand = function (bigstr)
    return LuaWithRects.new(bigstr):extractasciirects():tostring()
  end
luarecteval = function (bigstr, verbose)
    local code = luarectexpand(bigstr)
    if verbose then print(code) end
    return eval(code)
  end
luarectexpr = function (bigstr) return luarecteval("return\n"..bigstr) end

-- «LuaWithRects-tests» (to ".LuaWithRects-tests")
--[==[
-- High-level tests:
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "luarects.lua"
bigstr = [[
A = 1/ a \;  B = 2/abcd\;
     |b c|        \efgh/   C = 1/o o \
     | d |                      | o o|
     \  e/                      \o o /
]]
lwr = LuaWithRects.new(bigstr)
= lwr
= lwr:extractasciirects()
= lwr:body()
= lwr.defs
= mytabletostring(lwr.ars)
= lwr.ars[1][2]

 (ex "luawithrects-1")

 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "luarects.lua"
bigstr = [[
for x,y,str in 2/  ..      \:setx0():gen() do print(x,y,str) end
                |    ..    |
                |  ..  12  |
                |..  11  02|
                |  ..  01  |
                \    ..    /
]]
luarecteval(bigstr)

=    LuaWithRects.new(bigstr)
=    LuaWithRects.new(bigstr):extractasciirects()
=    LuaWithRects.new(bigstr):extractasciirects():tostring()
eval(LuaWithRects.new(bigstr):extractasciirects():tostring())
luarecteval(bigstr)

 (ex "luawithrects-2")

-- Low-level tests:
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "luarects.lua"
bigstr = [[
1/ a \
 |b c|
 | d |
 \  e/
]]
lwr = LuaWithRects.new(bigstr)
= lwr
= lwr:read            (2,    3, 6)
= lwr:readasciirect(9, 2, 4, 3, 6)
= lwr:readasciirect(9, 1, 4, 3, 6)
= lwr:replace         (2,    3, 6, "!", ".")
= lwr:replacerect     (1, 4, 3, 6, "!", ".")

lwr = LuaWithRects.new(bigstr)
= lwr:matchasciirect(1)
= lwr:readasciirect(9, 1, 4, 3, 6)
w, y1, y2, pos1, pos2 = lwr:matchasciirect(1)
ar = lwr:extractasciirect(w, y1, y2, pos1, pos2, "foo")
= ar
= lwr

 (ex "luawithrects-3")

--]==]




--  ______   _    _    _____                    ____       _       _       
-- |__  / | | |  / \  |  ___| __ ___  _ __ ___ |  _ \ ___ (_)_ __ | |_ ___ 
--   / /| |_| | / _ \ | |_ | '__/ _ \| '_ ` _ \| |_) / _ \| | '_ \| __/ __|
--  / /_|  _  |/ ___ \|  _|| | | (_) | | | | | |  __/ (_) | | | | | |_\__ \
-- /____|_| |_/_/   \_\_|  |_|  \___/|_| |_| |_|_|   \___/|_|_| |_|\__|___/
--                                                                         
-- «ZHAFromPoints» (to ".ZHAFromPoints")
-- The core was copied to: (find-dn6 "zhas.lua" "spec-tools")
-- To be moved to: (find-dn6 "zhaspecs.lua" "spec-tools")

ZHAFromPoints = Class {
  type = "ZHAFromPoints",
  new  = function () return ZHAFromPoints {L={}, R={}, W={}} end,
  __index = {
    putxy = function (zfp, x, y)
        zfp.L[y], zfp.R[y] = minmax(zfp.L[y], x, zfp.R[y])
        return zfp
      end,
    spec = function (zfp)
        local s = "1"
        local L, R, W = zfp.L, zfp.R, {}
        for y=0,#L do W[y] = toint((R[y] - L[y])/2) + 1 end
        for y=1,#L do
          if W[y] == W[y-1]
          then s = s..((L[y]<L[y-1]) and "L" or "R")
          else s = s..W[y]
          end
        end  
        return s
      end,
  },
}

-- «ZHAFromPoints-tests» (to ".ZHAFromPoints-tests")
--[==[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "luarects.lua"

luarecteval [[
r = 2/  32      \
     |    22    |
     |  21  12  |
     |20  11  02|
     |  10  01  |
     \    00    /
]]
= r
= r:spec()    --> 12321L

luarecteval [[
ra, rb, rc =
2/                48        \, 2/            48        \, 2/            48    \
 |              47  38      |   |          47  38      |   |          47  38  |
 |            46  37  28    |   |        46  37  28    |   |        46  37    | 
 |          45  36  27  18  |   |      45  36  27  18  |   |          36      |
 |        44  35  26  17  08|   |    44  35  26  17  08|   |        35  26    |
 |      43  34  25  16  07  |   |  43  34  25  16  07  |   |      34  25  16  |
 |    42  33  24  15  06    |   |    33  24  15  06    |   |    33  24  15  06| 
 |  41  32  23  14  05      |   |      23  14  05      |   |      23  14  05  |
 |40  31  22  13  04        |   |    22  13  04        |   |    22  13  04    |
 |  30  21  12  03          |   |  21  12  03          |   |  21  12  03      |
 |    20  11  02            |   |20  11  02            |   |20  11  02        | 
 |      10  01              |   |  10  01              |   |  10  01          |
 \        00                /   \    00                /   \    00            /
print(ra:spec(), rb:spec(), rc:spec())
--> 12345RRRR4321	123RRR45R4321	123RRR43212R1
]]

--]==]






-- Local Variables:
-- coding: utf-8-unix
-- End:
