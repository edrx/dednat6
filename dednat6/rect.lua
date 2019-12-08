-- rect.lua: concatenable ascii rectangles, for building trees in ascii.
-- This file:
-- http://angg.twu.net/dednat6/dednat6/rect.lua
-- http://angg.twu.net/dednat6/dednat6/rect.lua.html
--         (find-angg "dednat6/dednat6/rect.lua")
--
-- Example:
--
--   > = synttorect {[0]="+", {[0]="*", "2", "3"}, {[0]="*", "4", "5"}}
--   +_____.
--   |     |
--   *__.  *__.
--   |  |  |  |
--   2  3  4  5

-- «.Rect»			(to "Rect")
-- «.Rect-tests»		(to "Rect-tests")
-- «.Rect-ded-tests»		(to "Rect-ded-tests")
-- «.syntotorect»		(to "syntotorect")
-- «.synttorect-tests»		(to "synttorect-tests")
-- «.dedtorect»			(to "dedtorect")
-- «.dedtorect-tests»		(to "dedtorect-tests")



--  ____           _   
-- |  _ \ ___  ___| |_ 
-- | |_) / _ \/ __| __|
-- |  _ <  __/ (__| |_ 
-- |_| \_\___|\___|\__|
--                     
-- This is a total rewrite (different data structures, methods, etc) of:
-- (find-dn6 "gab.lua" "Rect")
-- «Rect» (to ".Rect")

copy = function (A)
    local B = {}
    for k,v in pairs(A) do B[k] = v end
    setmetatable(B, getmetatable(A))
    return B
  end

torect = function (o)
    if otype(o) == "Rect" then return o end
    if type(o) == "string" then return Rect.new(o) end
    error()
  end

Rect = Class {
  type = "Rect",
  new  = function (str) return Rect(splitlines(str)) end,
  rep  = function (str, n) local r=Rect{}; for i=1,n do r[i]=str end; return r end,
  __tostring = function (rect) return rect:tostring() end,
  __concat = function (r1, r2) return torect(r1):concat(torect(r2)) end,
  __index = {
    tostring = function (rect) return table.concat(rect, "\n") end,
    copy = function (rect) return copy(rect) end,
    width = function (rect) return foldl(max, 0, map(string.len, rect)) end,
    push1 = function (rect, str) table.insert(rect, 1, str); return rect end,
    push2 = function (rect, str1, str2) return rect:push1(str2):push1(str1) end,
    pad0  = function (rect, y, w, c, rstr)
        rect[y] = ((rect[y] or "")..(c or " "):rep(w)):sub(1, w)..(rstr or "")
        return rect
      end,
    lower = function (rect, n, str)
        for i=1,n do rect:push1(str or "") end
        return rect
      end,
    concat = function (r1, r2, w, dy)
        r1 = r1:copy()
        w = w or r1:width()
        dy = dy or 0
        for y=#r1+1,#r2+dy do r1[y] = "" end
        for y=1,#r2 do r1:pad0(y+dy, w, nil, r2[y]) end
        return r1
      end,
    prepend = function (rect, str) return Rect.rep(str, #rect)..rect end,
    --
    -- Methods for building syntax trees
    syn1 = function (r1, opname) return r1:copy():push2(opname or ".", "|") end,
    synconcat = function (r1, r2)
        return r1:copy():pad0(1, r1:width()+2, "_")..r2:copy():push2(".", "|")
      end,
    --
    -- Methods for building deduction trees
    dedconcat = function (r1, r2)
        local w = r1:width() + 2
        if #r1 <  #r2 then return r1:copy():lower(#r2-#r1):concat(r2, w) end
        if #r1 == #r2 then return r1:copy():concat(r2, w) end
        if #r1  > #r2 then return r1:copy():concat(r2, w, #r1-#r2) end
      end,
    dedsetbar = function (r, barchar, barname)
        if #r == 1 then table.insert(r, 1, "") end
        local trim = function (str) return (str:match("^(.-) *$")) end
        local strover  = trim(r[#r-2] or "")
        local strunder = trim(r[#r])
        local len = max(#strover, #strunder)
        r[#r-1] = (barchar or "-"):rep(len)..(barname or "")
        return r
      end,
    dedaddroot = function (r, rootstr, barchar, barname)
        table.insert(r, "")
        table.insert(r, rootstr)
        return r:dedsetbar(barchar, barname)
      end,
  },
}

-- «Rect-tests» (to ".Rect-tests")
--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "rect.lua"

r = Rect.new "a\nbb\nccc"
= r
PP(r)
= r:width()
= r:copy():pad0(1, 4, nil, "d")
= r:copy():pad0(1, 4, "_", "d")
= r:copy():push2("op", "|")
= r:copy():push2("op", "|"):pad0(1, r:width()+1, "_")
= r:copy():push2("op", "|"):pad0(1, r:width()+1, "_")..r:copy():push2(".", "|")
= "This => "..r.." <="

 (ex "rect-0")

-- «Rect-ded-tests» (to ".Rect-ded-tests")
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "rect.lua"
abc   = Rect.new("a  b\n----\nc")
defgh = Rect.new("   d\n   -\ne  f  g\n-------\nh")
= abc
= defgh
= abc:dedconcat(defgh)
= defgh:dedconcat(abc)
= defgh:dedconcat(abc):dedaddroot("i")
= defgh:dedconcat(abc):dedaddroot("i", "=")
= defgh:dedconcat(abc):dedaddroot("i", "=", "foo")
= defgh:dedconcat(abc):dedaddroot("iiiiiiiii", "=", "foo")
= defgh:dedconcat(abc):dedaddroot("iiiiiiiiii", "=", "foo")
= defgh:dedconcat(abc):dedaddroot("iiiiiiiiiii", "=", "foo")
= Rect.new("")
= Rect.new(""):dedaddroot("iiiii", "=", "foo")

 (ex "rect-1")

--]]



--                  _   _                      _   
--  ___ _   _ _ __ | |_| |_ ___  _ __ ___  ___| |_ 
-- / __| | | | '_ \| __| __/ _ \| '__/ _ \/ __| __|
-- \__ \ |_| | | | | |_| || (_) | | |  __/ (__| |_ 
-- |___/\__, |_| |_|\__|\__\___/|_|  \___|\___|\__|
--      |___/                                      
--
-- «syntotorect» (to ".syntotorect")

synttorect = function (o)
    if type(o) == "string" then return torect(o) end
    if type(o) == "table" then
      local r = synttorect(o[1]):syn1(o[0])
      for i=2,#o do r = r:synconcat(synttorect(o[i])) end
      return r
    end
    error()
  end

-- «synttorect-tests» (to ".synttorect-tests")
--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "rect.lua"
tree = {[0]="+", {[0]="*", "2", "3"}, {[0]="*", "4", "5"}}
tree = {[0]="+", {[0]="*", "2", "3"}, {[0]="*", "4", "5"}, bar="=", label="hi"}
= synttorect(tree)
= dedtorect (tree)

 (ex "rect-synt")

--]]


--      _          _ _                      _   
--   __| | ___  __| | |_ ___  _ __ ___  ___| |_ 
--  / _` |/ _ \/ _` | __/ _ \| '__/ _ \/ __| __|
-- | (_| |  __/ (_| | || (_) | | |  __/ (__| |_ 
--  \__,_|\___|\__,_|\__\___/|_|  \___|\___|\__|
--                                              
-- «dedtorect» (to ".dedtorect")
dedtorect = function (o)
    if type(o) == "string" then return torect(o) end
    if type(o) == "table" then
      if #o == 0 then
        local r = dedtorect(o[0])
        if o.bar or o.label then r:dedsetbar(o.bar, o.label) end
        return r
      else
        r = dedtorect(o[1])
        for i=2,#o do r = r:dedconcat(dedtorect(o[i])) end
        return r:dedaddroot(o[0] or "?", o.bar, o.label)
      end
    end
    error()
  end

-- «dedtorect-tests» (to ".dedtorect-tests")
-- See: (find-dn6 "treesegs.lua" "allsegments-tests")
--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "rect.lua"
= dedtorect "a"
= dedtorect {[0]="a"}
= dedtorect {[0]="a", "b", "c"}
= dedtorect {[0]="a", "b", {"c"}}
= dedtorect {[0]="a", "b", {[0]="c"}}
= dedtorect {[0]="a", "b", {[0]="c", bar="-"}}
= dedtorect {[0]="a", "b", {[0]="c", label="foo"}}
= dedtorect {[0]="a", "b", {[0]="c", "d", "e"}}

 (ex "rect-ded")

--]]



--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "rect.lua"

--]]


-- Local Variables:
-- coding: raw-text-unix
-- End:

