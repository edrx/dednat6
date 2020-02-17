-- -*- coding: utf-8-unix; backup-by-copying: t -*-
-- This file: http://angg.twu.net/LUA/lua50init.lua.html
--            http://angg.twu.net/LATEX/dednat6/edrxlib.lua.html
--            http://angg.twu.net/dednat4/edrxlib.lua.html
--            http://angg.twu.net/blogme3/edrxlib.lua.html
--
-- 2017ago05: see: (find-es "emacs" "merge")
-- (find-sh "tkdiff ~/LUA/lua50init.lua   ~/LATEX/dednat6/edrxlib.lua")
-- (find-sh "tkdiff ~/LUA/lua50init.lua ~/dednat6/dednat6/edrxlib.lua")
-- (find-sh0 "cp -v ~/LUA/lua50init.lua   ~/LATEX/dednat6/edrxlib.lua")
-- (find-sh0 "cp -v ~/LUA/lua50init.lua ~/dednat6/dednat6/edrxlib.lua")
-- (find-sh0 "cp -v ~/LUA/lua50init.lua         ~/blogme3/edrxlib.lua")
--
-- On my system ~/LUA/lua50init.lua the two "edrxlib.lua"s
-- USED TO BE hard linked:
--   (find-sh0 "cp -flv ~/LUA/lua50init.lua ~/dednat4/edrxlib.lua")
--   (find-sh0 "cp -flv ~/LUA/lua50init.lua ~/blogme3/edrxlib.lua")
--   (find-sh0 "ls -li  ~/LUA/lua50init.lua ~/{dednat4,blogme3}/edrxlib.lua")
--   (find-tkdiff "~/LUA/lua50init.lua" "~/dednat4/edrxlib.lua")
--   (find-tkdiff "~/LUA/lua50init.lua" "~/dednat4/blogme3.lua")
--   (find-elnode "Rename or Copy" "hard links")
--   (find-elnode "Rename or Copy" "backup-by-copying")
--
-- This is my "init file" for Lua. As I have LUA_INIT set
-- to "@$HOME/LUA/lua50init.lua", the Lua interpreter loads
-- this on start-up.
-- See: (find-angg ".zshrc" "lua" "LUA_INIT")
--      (find-luamanualw3m "#6" "LUA_INIT" "@filename")
--      (find-man "1 lua50" "LUA_INIT")
--      (find-man "1 lua51" "LUA_INIT")
--      (find-lua51w3m "doc/lua.html" "LUA_INIT")
--      http://www.lua.org/manual/5.1/lua.html
--      http://linux.die.net/man/1/lua
-- Author: Eduardo Ochs <eduardoochs@gmail.com>
-- Version: 2019feb11   <- don't trust this date
-- Public domain.
--
-- Note: "dednat4.lua" and "dednat6.lua" try to load this at startup,
-- with 'require "edrxlib"', just after setting the path; if this has
-- already been loaded by LUA_INIT, then the 'require "edrxlib"' is a
-- no-op, because of the "package.loaded.edrxlib = ..." at the end of
-- this file - otherwise it is loaded, probably from the "~/dednat4/"
-- or "~/LATEX/dednat6/" dirs. See this for the details:
--      (find-dn4 "dednat4.lua" "edrxlib")
--      (find-dn6 "dednat6.lua" "requires")
--
-- Blogme3 does the same trick:
--      (find-blogme3 "blogme3.lua" "edrxlib")
--
-- This file used to work both on lua-5.0 and lua-5.1 -
-- but now I have stopped using lua-5.0, and I'm trying
-- (slowly!) to make this more readable, remove the
-- cruft, some 5.0-isms, some obsolete loaders, etc.


-- «.escripts»		(to "escripts")
-- «.build-lua»		(to "build-lua")
-- «.compat»		(to "compat")
-- «.dformat»		(to "dformat")
-- «.string-methods»	(to "string-methods")
-- «.otherfunctions»	(to "otherfunctions")
-- «.printf»		(to "printf")
-- «.pack-and-unpack»	(to "pack-and-unpack")
-- «.0-based»		(to "0-based")
-- «.P»			(to "P")
-- «.PP»		(to "PP")
-- «.PPP»		(to "PPP")
-- «.tests»		(to "tests")
-- «.over0»		(to "over0")
-- «.eoo»		(to "eoo")
-- «.over»		(to "over")
-- «.follow»		(to "follow")
-- «.NamedFunction»	(to "NamedFunction")
-- «.Tos»		(to "Tos")
-- «.VerticalTable»	(to "VerticalTable")
-- «.envsubst»		(to "envsubst")
-- «.readfile»		(to "readfile")
-- «.writefile»		(to "writefile")
-- «.fileexists»	(to "fileexists")
-- «.mytostring»	(to "mytostring")
-- «.mysortedpairs»	(to "mysortedpairs")
-- «.mytostringk2»	(to "mytostringk2")
-- «.trim»		(to "trim")
-- «.split»		(to "split")
-- «.ee_expand»		(to "ee_expand")
-- «.ee_dofile»		(to "ee_dofile")
-- «.ee_loadlib»	(to "ee_loadlib")
-- «.ee_ls»		(to "ee_ls")
-- «.strlen8»		(to "strlen8")
-- «.untabify»		(to "untabify")
-- «.untabify8»		(to "untabify8")
-- «.utf8tohtml»	(to "utf8tohtml")
-- «.u8c_to_l1»		(to "u8c_to_l1")
-- «.u8_to_l1»		(to "u8_to_l1")
-- «.toslashhex»	(to "toslashhex")
-- «.divmod»		(to "divmod")
-- «.min-and-max»	(to "min-and-max")
-- «.load_dednat4»	(to "load_dednat4")
-- «.load_rex»		(to "load_rex")
-- «.load_posix»	(to "load_posix")
-- «.load_PP»		(to "load_PP")
-- «.PPeval»		(to "PPeval")
-- «.loadswigso»	(to "loadswigso")
-- «.loadcinvoke»	(to "loadcinvoke")
-- «.loadlpeg»		(to "loadlpeg")
-- «.loadbitlib»	(to "loadbitlib")
-- «.autoload»		(to "autoload")
-- «.loadtcl»		(to "loadtcl")
-- «.loadldb»		(to "loadldb")
-- «.loadpeek»		(to "loadpeek")
-- «.loadalarm»		(to "loadalarm")
-- «.loadposix»		(to "loadposix")
-- «.getoutput»		(to "getoutput")
-- «.curl»		(to "curl")
-- «.preparef2n»	(to "preparef2n")
-- «.map»		(to "map")
-- «.fold»		(to "fold")
-- «.gformat»		(to "gformat")
-- «.each2»		(to "each2")
-- «.splitlines»	(to "splitlines")
-- «.splitlines-5.3»	(to "splitlines-5.3")
-- «.translatechars»	(to "translatechars")
-- «.sbeconcat»		(to "sbeconcat")
-- «.concatbestrings»	(to "concatbestrings")
-- «.lpeg_togsub»	(to "lpeg_togsub")
-- «.lpeg_gsub»		(to "lpeg_gsub")
-- «.lpeg_gsub_»	(to "lpeg_gsub_")
-- «.lpeg_balanced»	(to "lpeg_balanced")
-- «.mytraceback»	(to "mytraceback")
-- «.errorfb_line»	(to "errorfb_line")
-- «.ee_template»	(to "ee_template")
-- «.ee_into»		(to "ee_into")
-- «.chdir»		(to "chdir")
-- «.package.require»	(to "package.require")
-- «.userocks»		(to "userocks")
-- «.loadblogme3»	(to "loadblogme3")
-- «.hms_to_s»		(to "hms_to_s")
-- «.s_to_hms»		(to "s_to_hms")
-- «.icollect»		(to "icollect")
-- «.interactor»	(to "interactor")
-- «.Repl»		(to "Repl")
-- «.loadluarepl»	(to "loadluarepl")
-- «.replaceranges»	(to "replaceranges")
-- «.string.replace»	(to "string.replace")
-- «.Rect»		(to "Rect")
-- «.syntree»		(to "syntree")
-- «.re_expand_INFIX»	(to "re_expand_INFIX")
-- «.math-grammar»	(to "math-grammar")
-- «.cow-and-coy»	(to "cow-and-coy")
-- «.eval-and-L»	(to "eval-and-L")
--
-- «.Sexp»		(to "Sexp")
-- «.youtube_make_url»	(to "youtube_make_url")
-- «.youtube_split»	(to "youtube_split")
-- «.url_split»		(to "url_split")
-- «.Blogme»		(to "Blogme")
--
-- «.EevIntro»		(to "EevIntro")
-- «.ELispH»		(to "ELispH")
-- «.ELispHF»		(to "ELispHF")
-- «.getsexp»		(to "getsexp")
-- «.SexpSkel»		(to "SexpSkel")
-- «.ELispInfo»		(to "ELispInfo")
--
-- «.getsexpskel»	(to "getsexpskel")
-- «.SexpLine»		(to "SexpLine")
--
-- «.Set»		(to "Set")
-- «.SetL»		(to "SetL")
-- «.fsize»		(to "fsize")
-- «.loaddednat6»	(to "loaddednat6")
-- «.loadfbcache2»	(to "loadfbcache2")
-- «.loadluarocks»	(to "loadluarocks")
-- «.capitalize»	(to "capitalize")
-- «.getinscritos»	(to "getinscritos")
-- «.trailing-zeroes»	(to "trailing-zeroes")
-- «.pformat»		(to "pformat")
-- «.findxxxpdf_parse»	(to "findxxxpdf_parse")


-- «escripts»  (to ".escripts")
-- «build-lua»  (to ".build-lua")
-- (find-es "lua5" "install-5.1.2")

-- «compat»  (to ".compat")
-- On Lua 4.x these functions had the short names on the left;
-- on Lua-5.0.x a file etc/compat.lua could be used to make the short
-- names work, but on Lua-5.1.x this compat.lua has been dropped...
-- I still like the short names, so:

-- (find-lua51file "src/lstrlib.c" "{\"find\", str_find},")
-- (find-lua50file "etc/compat.lua" "strfind = str.find")
write    = io.write        -- (find-lua51manual "#pdf-io.write")
format   = string.format   -- (find-lua51manual "#pdf-string.format")
gsub     = string.gsub     -- (find-lua51manual "#pdf-string.gsub")
strfind  = string.find     -- (find-lua51manual "#pdf-string.find")
strlen   = string.len      -- (find-lua51manual "#pdf-string.len")
strsub   = string.sub      -- (find-lua51manual "#pdf-string.sub")
concat   = table.concat    -- (find-lua51manual "#pdf-table.concat")
tinsert  = table.insert    -- (find-lua51manual "#pdf-table.insert")
tremove  = table.remove    -- (find-lua51manual "#pdf-table.remove")

-- foreachi = table.foreachi -- (find-lua51manual "#7.2" "table.foreachi")
getn     = table.getn        -- (find-lua51manual "#7.2" "table.getn")

toint    = math.floor      -- for 5.3


-- «dformat»  (to ".dformat")
-- (find-es "lua5" "dformat")
if _VERSION:sub(5) < "5.3" then
  dformat_fmt = function (fmt) return fmt end
  string.dformat = string.format
  dformat        = string.format
else
  dformat_fmt = function (fmt) return (fmt:gsub("%%d", "%%.0f")) end
  string.dformat = function (fmt, ...)
      return string.format(dformat_fmt(fmt), ...)
    end
  dformat = string.dformat
end



-- «string-methods»  (to ".string-methods")
-- A note about "string methods": if s is a string, then a piece of
-- code like "s:rep(2)" works like "string.rep(s, 2)"; this is a
-- Lua-5.1-ism that is not described in the first edition of PiL - the
-- one that is online, that covers only Lua 5.0. When we do
--
--   s = "foo"
--   print(s:rep(2))
--
-- then the "s:rep(2)" is syntax sugar for 's["rep"](s,2)'. At first
-- sight, the table access s["rep"] should fail, but in 5.1 strings
-- have a metatable like this:
--
--   setmetatable("str", {__index = string})
--
-- and so instead of failing Lua does something else... the s["rep"]
-- becomes getmetatable(s).__index["rep"], and that is just
-- string["rep"], i.e., string.rep; so, s:rep(2) works like
-- string.rep(s, 2).
--
-- See:
-- (find-lua51manual "#2.2"   "a.name as syntactic sugar")
-- (find-lua51manual "#2.5.8" "v:name(args)" "v.name(v,args)")
-- (find-lua51manual "#2.8" "Tables and userdata have individual metatables")
-- (find-lua51manual "#2.8" "table[key]" "h = metatable(table).__index")
-- (find-lua51manual "#5.4" "object-oriented style" "s:byte(i)")
-- (find-lua51manual "#pdf-string.rep")
-- (find-pilw3m "13.4.1.html" "The __index Metamethod")



-- «otherfunctions»  (to ".otherfunctions")

-- «printf»  (to ".printf")
-- printf = function (...) write(format(unpack(arg))) end
printf = function (...) write(format(...)) end


-- «pack-and-unpack»  (to ".pack-and-unpack")
-- (find-es "lua5" "pack-and-unpack")
-- (find-es "lua5" "LUA_COMPAT_VARARG")
-- (find-lua51manual "#pdf-unpack")
-- (find-lua51manual "#7.1" "pseudo-argument arg")
-- (find-lua51manual "#pdf-unpack")
-- (find-lua52manual "#pdf-table.unpack")
-- (find-lua52manualw3m "#pdf-table.pack")
-- (find-lua51manualw3m "#pdf-select")
-- (find-lua52manualw3m "#pdf-select")
-- 5.1 only:
-- pack     = function (...) return arg end
-- myunpack = function (arg) return unpack(arg, 1, arg.n) end

-- These definitions should work both on 5.1 and on 5.2:
-- pack  = table.pack or function (...) return arg end   -- 5.1 and 5.2
pack     = table.pack or function (...) return {n=select("#", ...), ...} end
unpack   = unpack or table.unpack
myunpack = function (arg) return unpack(arg, 1, arg.n) end

-- New:
-- pack   = table.pack or function (...) return {n=select("#", ...), ...} end
-- unpack = function (T) return table.unpack(T, 1, T.n)

-- Examples:
--      PP(pack(nil, 22, nil, 44, nil))        -->  {2=22, 4=44, "n"=5}
--   PP(unpack({nil, 22, nil, 44, nil, n=5}))  -->  <nil> 22
-- PP(myunpack({nil, 22, nil, 44, nil, n=5}))  -->  <nil> 22 <nil> 44 <nil>



-- «0-based»  (to ".0-based")
-- (find-es "lua5" "0-based")
-- 0-based string functions.
-- (To do: remove this! I think I only use 0-based string functions at
-- dednat4 - and now I'm almost getting used to the 1-based
-- conventions...)
-- (find-sh "lua -e \"print(substr0('abcdef', 2, 3)) --> cde\"")
substr0 = function (str, start0, len)
    return string.sub(str, start0 + 1, len and start0 + len)
  end



-- «P»  (to ".P")
-- Like "print", but distinguishing strings from numbers, and using "<>"s.
-- See: (find-lua51manual "#pdf-type")
-- Examples:
--  print(nil, 22, "33", {}, false, print)
-->  nil   22   33   table: 0x806da60   false   function: 0x806b388
--  P(nil, 22, "33", {}, false, print)
-->  <nil> 22 "33" <table> <boolean> <function>
--
P = function (...)
    local arg = arg or pack(...)   -- for Lua 5.2
    for i=1,arg.n do
      local v = arg[i]
      if     type(v)=="number" then printf(" %d", v)
      elseif type(v)=="string" then printf(" %q", v)
      else printf(" <%s>", type(v))
      end
    end
    print()
  end

-- Note: "table.foreach(t, print)" is often enough for inspecting tables.
-- Ref: http://lua-users.org/lists/lua-l/2008-02/msg00932.html
--      http://lua-users.org/lists/lua-l/2008-02/msg00944.html


-- «PP»  (to ".PP")
-- 2015aug20: oveeriden by: (to "Tos")
-- (to "mytostring")
-- My favourite function for inspecting data!
-- This is like "print" too, but it uses "mytostring" to print the
-- contents of tables recursively. The output format is compact,
-- human-friendly, and simple to understand and to implement. Note: on
-- cyclic structures "mytostring" will loop and break; and metatables
-- are ignored (I use them very rarely, btw).
-- Examples:
--  PP(nil, true, false, 22, "22", "a\nb", print, nil)
-->   <nil> <true> <false> 22 "22" "a\
--    b" <function: 0x806b388> <nil>
--
--  PP({44, 55, nil, 77, [{a=11}]={[22]="b"}, [{}]={}, [{}]={}})
-->    {1=44, 2=55, 4=77, {"a"=11}={22="b"}, {}={}, {}={}}
--
PP = function (...)
    -- local arg = arg or pack(...)   -- for Lua 5.2
    local arg = pack(...)
    for i=1,arg.n do printf(" %s", mytostring(arg[i])) end
    printf("\n")
    return myunpack(arg)    -- todo: change to "..." (a 5.1-ism)
  end

-- «PPP»  (to ".PPP")
-- Useful for debugging sometimes.
-- I don't use this much.
-- PP(string.rep("ab", 4))
-->              "abababab"
-- PP(string.rep(PPP("rep:")("ab", 4)))
-->                   (rep: "ab" 4)"abababab"
PPP = function (idstr)
    return function (...)
        printf("(%s", idstr)
        for i=1,arg.n do printf(" %s", mytostring(arg[i])) end
        printf(")")
        return unpack(arg)
      end
  end

-- «tests»  (to ".tests")
-- P(string.find("0123456789", "3(45)(67)", 4))  --> 4 8 "45" "67"
-- P(string.find("0123456789", "3(45)(67)", 5))  --> <nil>

-- «over0»  (to ".over0")
-- Example:
-- A = {a=22}
-- B = over(A, {b=33})
-- PP(B, A, B.b, B.a)
--   --> {"b"=33} {"a"=22} 33 22
--[[
over = function (bottomtable, toptable)
    return setmetatable(toptable or {}, {__index = bottomtable})
  end
--]]

-- «eoo» (to ".eoo")
-- For a documented version, see:
--   (find-dn6 "eoo.lua")
--   (find-dn6 "eoo.lua" "Vector")
Class = {
    type   = "Class",
    __call = function (class, o) return setmetatable(o, class) end,
  }
setmetatable(Class, Class)

otype = function (o)  -- works like type, except on my "objects"
    local  mt = getmetatable(o)
    return mt and mt.type or type(o)
  end

-- «over» (to ".over")
-- (find-es "lua5" "over")
over = function (B)
    return function (A)
        return setmetatable(A, {__index=B})
      end
  end
Over = function (class)
    return over(class.__index)
  end

-- «follow» (to ".follow")
follow = function (o, str)
    local w, rest = str:match("(%S+)%s*(.*)")
    if not w then return o end
    if w == "()" then return follow(o(), rest) end
    if w == "{}" then return follow(o{}, rest) end
    if w == "mt" then return follow(getmetatable(o), rest) end
    return follow(o[w], rest)
  end

-- «NamedFunction» (to ".NamedFunction")
-- (find-es "lua5" "NamedFunction")
NamedFunction = Class {
  type    = "NamedFunction",
  __tostring = function (o) return o.name end,
  __call     = function (o, ...) return o.f(...) end,
  __index = {
  },
}
lambda = function (str)
    local vars,rest = str:match "^ *([%w_,]*)[ .:]*(.-) *$"
    local body = rest:gsub("=>", " return ")
    local code = "return function ("..vars..")\n"..body.."\nend"
    local name = "("..vars..": "..rest..")"
    local f = assert(loadstring(code))()
    -- return NamedFunction {name=name, f=f}
    return NamedFunction {name=name, code=code, f=f}
  end


-- «Tos» (to ".Tos")
-- Tests: (find-es "lua5" "Tos")
Tos = Class {
  type    = "Tos",
  __index = {
    --
    -- object->string:
    o = function (tos, o, sep)
        local ty = type(o)
        if ty=="number" then return tostring(o) end
        if ty=="string" then return format("%q", o) end
        if ty=="table"  then return tos:t(o, sep) end
        return "<"..tostring(o)..">"
      end,
    --
    -- table->string:
    -- (subfunctions: pairs/pair/key->string, getsortedpairs)
    t = function (tos, T, a, sep, b)
        local body = tos:ps(tos:getsortedpairs(T), sep)
        return (a or "{")..body..(b or "}")
      end,
    ps = function (tos, ps, sep)
        local tos_p = function (p) return tos:p(p) end
        return mapconcat(tos_p, ps, sep or ", ")
      end,
    p = function (tos, p) return tos:k(p.key).."="..tos:o(p.val) end,
    k = function (tos, k) return tos:o(k) end,
    --
    -- See: (find-es "lua5" "Tos-indented")
    indented = function (tos, o, ind)
        ind = ind or ""
        local ty = type(o)
        if ty=="number" then return tostring(o) end
        if ty=="string" then return format("%q", o) end
        if ty=="table"  then
          local ps = tos:getsortedpairs(o)
          local p_tos = function (p)
              return tos:k(p.key).."="..tos:indented(p.val, ind.."  ")
            end
          return "{\n  "..ind..mapconcat(p_tos, ps, ",\n  "..ind).."\n"..ind.."}"
        end
        return "<"..tostring(o)..">"
      end,
    --
    getsortedpairs = function (tos, T)
        local ps = {}
        for k,v in pairs(T) do table.insert(ps, {key=k, val=v}) end
        -- return ps
        return sorted(ps, tos.comparepairs)
      end,
    comparepairs = function (pair1, pair2)
        local key1,  key2  = pair1.key,  pair2.key
        local type1, type2 = type(key1), type(key2)
        if type1 == type2 then
          if type1 == "number" then return key1 < key2 end
          if type1 == "string" then return key1 < key2 end
          return tostring(key1) < tostring(key2)  -- fast
        else
          return type1 < type2   -- numbers before strings before tables, etc
        end
      end,
    --
    PP = function (tos, ...)
        local T = pack(...)
        for i=1,T.n do printf(" %s", tos:o(T[i])) end
        print()
        return ...
      end
  },
}

PP              = function (...) return (Tos{}):PP(...)             end
mytostring      = function (o)   return (Tos{}):o(o)                end
mytabletostring = function (o)   return (Tos{}):t(o, "{ ", ",\n  ", "\n}") end
PPV             = function (o)   print(mytabletostring(o)); return o end

-- «VerticalTable» (to ".VerticalTable")
-- Tests: (find-es "lua5" "VerticalTable")
VerticalTable = Class {
  type    = "VertTable",
  __tostring = function (vt) return mytabletostring(vt) end,
  __index = {
  },
}




-- «envsubst»  (to ".envsubst")
-- (find-es "lua5" "envsubst")
setenv_ = {}
setenv = function (varname, value) setenv_[varname] = value end
getenv = function (varname) return setenv_[varname] or os.getenv(varname) end
envsubst = function (str)
     return string.gsub(str, "%$([%a_][%w_]*)", function (e)
         return getenv(e) or ""
       end)
   end

-- «readfile»  (to ".readfile")
-- «writefile»  (to ".writefile")
-- (find-es "lua5" "readfile")
-- (find-lua51manual "#pdf-io.open")
-- (find-lua51manual "#pdf-file:read")
-- (find-lua51manual "#pdf-file:write")
readfile = function (fname)
    local f = assert(io.open(fname, "r"))
    local bigstr = f:read("*a")
    f:close()
    return bigstr
  end
writefile = function (fname, bigstr)
    local f = assert(io.open(fname, "w+"))
    f:write(bigstr)
    f:close()
  end

-- «fileexists» (to ".fileexists")
fileexists = function (fname)
    local f, err = (io.open(fname, "r"))
    if f then io.close(f); return true end
    return false
  end

-- (find-blogme3file "youtube.lua" "ee_readfile =")
ee_readfile  = function (fname) return readfile(ee_expand(fname)) end
ee_writefile = function (fname, str) return writefile(ee_expand(fname), str) end

filecontents0 = function (fname)
    local ok,contents = pcall(function () return ee_readfile(fname) end)
    if ok then return contents end
  end

-- (find-dn4 "dednat4.lua" "dednat4dir")
fnamedirectory    = function (fname) return fname:match"^(.*/)[^/]*$"  end
fnamenondirectory = function (fname) return fname:match     "([^/]*)$" end

-- «mytostring»  (to ".mytostring")
-- 2015aug12: new version: (to "Tos")
-- 2011apr10: Rewrote all this in a hurry.
-- These functions are used by: (to "PP")
-- (find-es "lua5" "mytostring")
-- Possible replacements:
--   (find-angg "LUA/tos.lua")
--   (find-angg "LUA/tos2.lua")
--   (find-dn5 "tos.lua")
tos_compare_pairs = function (pair1, pair2)
    local key1,  key2  = pair1.key,  pair2.key
    local type1, type2 = type(key1), type(key2)
    if type1 == type2 then
      if type1 == "number" then return key1 < key2 end
      if type1 == "string" then return key1 < key2 end
      return tostring(key1) < tostring(key2)  -- fast
    else
      return type1 < type2   -- numbers before strings before tables, etc
    end
  end
tos_sorted_pairs = function (T)
    local Tpairs = {}
    for key,val in pairs(T) do
      table.insert(Tpairs, {key=key, val=val})
    end
    return sorted(Tpairs, tos_compare_pairs)
  end
tos_table_orig = function (T, sep)
    return "{"..mapconcat(tos_pair, tos_sorted_pairs(T), sep or ", ").."}"
  end
tos_table = tos_table_orig
tos = function (o)
    local t = type(o)
    if t=="number" then return tostring(o) end
    if t=="string" then return format("%q", o) end
    if t=="table"  then return tos_table(o) end
    return "<"..tostring(o)..">"
  end
tos_key = tos              -- change this to print string keys differently
tos_pair = function (pair)
    return tos_key(pair.key).."="..tos(pair.val)
  end

mysort = tos_sorted_pairs   -- compatibility
mytostring = tos            -- compatibility
mytostring_arg = function (T, sep)
    return mapconcat(tos, T, sep or " ", T.n)
  end

-- Tools for building extensions
tos_good_string_key = function (key)
    return type(key) == "string" and key:match("^[A-Za-z_][A-Za-z_0-9]*$")
  end
tos_has_tostring = function (o)
    return getmetatable(T) and getmetatable(T).__tostring
  end
tos_has_eootype = function (o)
    return type(o) == "table" and getmetatable(o) and getmetatable(o).type
  end



-- mysort = function (T)
--     local Tpairs = {}
--     for key,val in pairs(T) do
--       table.insert(Tpairs, {key=key, val=val})
--     end
--     return sorted(Tpairs, mysort_lt)
--   end

-- mytostring_table_orig = function (T, sep)
--     return "{"..mapconcat(mytostring_pair, mysort(T), sep or ", ").."}"
--   end
-- mytostring_table_new = function (T, sep)
--     if getmetatable(T) and getmetatable(T).__tostring then return tostring(T) end
--     return mytostring_table_orig(T, sep)
--   end
-- mytostring_table = mytostring_table_new
--
-- mytostring = function (o)
--     local t = type(o)
--     if t=="number" then return tostring(o) end
--     if t=="string" then return format("%q", o) end
--     if t=="table"  then return mytostring_table(o) end
--     return "<"..tostring(o)..">"
--   end


-- mytostringk = mytostring   -- change this to print string keys differently
--
-- mytostring_arg = function (arg, sep)
--     local images = {}
--     for i=1,arg.n do images[i] = mytostring(arg[i]) end
--     return table.concat(images, sep or " ")
--   end

-- mytostring_arg({n=4, nil, 22, 33, nil})
-->                   "<nil> 22 33 <nil>"

-- «mysortedpairs»  (to ".mysortedpairs")
-- This is useful in iteractive scripts. The name is bad, I know.
-- (find-pilw3m "7.1.html" "simple iterator")
mysortedpairs = function (T)
    local T = mysort(T)
    local i,n = 0,#T
    return function ()
        i = i + 1
        if i <= n then return T[i].key,T[i].val end
      end
  end

-- «mytostringk2»  (to ".mytostringk2")
-- Experimental. Usage:
--   mytostringk = mytostringk2
mytostringk2 = function (o)
    if type(o) == "string" and o:match("^[A-Za-z_][A-Za-z_0-9]*$") then
      return o
    else
      return mytostring(o)
    end
  end


-- «trim» (to ".trim")
-- (to "string-methods")
-- (find-lua51manual "#5.4.1" "Patterns")
ltrim = function (str) return str:match"^%S*(.*)$" end
rtrim = function (str) return str:reverse():ltrim():reverse() end
bitrim = function (str) return str:ltrim():rtrim() end
string.ltrim = ltrim
string.rtrim = rtrim
string.bitrim = bitrim


-- «split»  (to ".split")
-- (find-es "lua5" "split")
split = function (str, pat)
    local arr = {}
    string.gsub(str, pat or "([^%s]+)", function (word)
        table.insert(arr, word)
      end)
    return arr
  end

-- «ee_expand»  (to ".ee_expand")
-- (find-eev "eev.el" "ee-expand")
ee_expand = function (path)
    path = string.gsub(path, "^~$", "$HOME/", 1)
    path = string.gsub(path, "^~/", "$HOME/", 1)
    path = string.gsub(path, "^%$(%w+)", os.getenv, 1)
    return path
  end

-- «ee_dofile»  (to ".ee_dofile")
-- «ee_loadlib»  (to ".ee_loadlib")
ee_dofile  = function (path) return dofile(ee_expand(path)) end
ee_loadlib = function (libname, funcname)
    return assert(package.loadlib(ee_expand(libname), funcname))()
  end

-- «ee_ls» (to ".ee_ls")
-- (find-es "lua5" "posix-ls")
ee_ls = function (dir)
    userocks()
    require "posix"
    return (posix.dir(ee_expand(dir)))
  end



-- «strlen8» (to ".strlen8")
-- (find-es "lua5" "utf8")
string.len8 = function (str) return str:gsub("[\128-\191]+", ""):len() end
strlen8 = string.len8

-- «untabify»  (to ".untabify")
-- Note: to untabify strings in encodings where chars can be more than
-- 1-byte long, change the "strlen" below... (I never had to do that,
-- though).
untabify_table =
  {"        ", "       ", "      ", "     ", "    ", "   ", "  ", " "}
--{"--------", "-------", "------", "-----", "----", "---", "--", "-"}
untabify_strtab = function (strbeforetab)
    return strbeforetab ..
      untabify_table[math.fmod(strlen(strbeforetab), 8) + 1]
  end
untabify = function (str)
    return (gsub(str, "([^\t\r\n]*)\t", untabify_strtab))
  end

-- «untabify8» (to ".untabify8")
untabify8_strtab = function (strbeforetab)
    return strbeforetab ..
      untabify_table[math.fmod(strlen(strbeforetab), 8) + 1]
  end
untabify8 = function (str)
    return (gsub(str, "([^\t\r\n]*)\t", untabify_strtab))
  end


-- «utf8tohtml» (to ".utf8tohtml")
-- (find-es "lua5" "utf8-to-html")
utf8pat   = "[\192-\253][\128-\191]+"
utf8ctohtml = function (u)
    local a, b = u:byte(1, 2)
    local code = (a-192)*64+(b-128)
    return format("&#x%X;", code)
  end
utf8tohtml0 = function (str)
    return (str:gsub(utf8pat, utf8ctohtml))
  end
utf8tohtml = function (str)
    local str2 = str:gsub("[&<>]", {["&"]="&amp;", ["<"]="&lt;", [">"]="&gt;"})
    return utf8tohtml0(str2)
  end

-- «u8c_to_l1» (to ".u8c_to_l1")
-- (find-es "charsets" "l1_to_u8")
u8c_l1_pat = "[\194-\195][\128-\191]"
u8c_to_code = function (u)
    local a, b = u:byte(1, 2)
    return (a-192)*64+(b-128)
  end
u8c_to_l1 = function (u)
    return string.char(u8c_to_code(u))
  end
measure_utf8_ness = function (bigstr)
    local bigstr_, n_u8_l1_pairs = bigstr:gsub(u8c_l1_pat, "")
    local bigstr__, n_other_l1s = bigstr_:gsub("[\128-\255]", "")
    return n_u8_l1_pairs, n_other_l1s
  end

-- «u8_to_l1» (to ".u8_to_l1")
-- (find-es "charsets" "u8_to_l1")
-- (ee-insert '(128 255))
-- (find-einsert '((128 255)))
-- (find-einsert '((128 191)))
-- (find-einsert '((196 255)))
-- u8_to_l1 = function (str)
--     local f = function (cc) return string.char(cc:byte(2)+64) end
--     return (str:gsub("\195[\128-\191]", f))
--   end
u8_to_l1 = function (bigstr)
    return (bigstr:gsub(u8c_l1_pat, u8c_to_l1))
  end
u8_to_l1_maybe = function (bigstr)
    local ngoodpairs, nbadchars = measure_utf8_ness(bigstr)
    if ngoodpairs > 0 and nbadchars == 0 then return u8_to_l1(bigstr) end
    return bigstr
  end


-- «toslashhex» (to ".toslashhex")
toslashhex1 = function (c) return format("\\%d", string.byte(c)) end
toslashhex  = function (str) return (str:gsub("[\128-\255]", toslashhex1)) end

-- «divmod» (to ".divmod")
-- http://lars.nocrew.org/forth2012/core/DivMOD.html
divmod = function (a, b) return (a-(a%b))/b, a%b end



-- «min-and-max» (to ".min-and-max")
-- (find-lua51manual "#pdf-math.min")
-- (find-lua51manual "#pdf-math.max")
-- PP(math.min("22", "200"))  --> 22
--      PP(min("22", "200"))  --> "200"
min = function (a, b)
    if a < b then return a else return b end
  end
max = function (a, b)
    if a < b then return b else return a end
  end

Min = function (a, b) return (a and b and min(a, b)) or a or b end
Max = function (a, b) return (a and b and max(a, b)) or a or b end

minmax = function (a, b, c) return Min(a, b), Max(b, c) end




-- «load_dednat4»  (to ".load_dednat4")
-- (find-angg ".emacs" "eepitch-dednat4")
-- (find-es    "xypic" "eepitch-dednat4")
-- (find-dn4 "dednat4.lua" "diag-head")
-- (find-dn4 "dednat4.lua" "abbrev-head")
-- (find-dn4 "dednat4.lua" "tree-head" "treeheadcode1")
-- (find-dn4 "dednat4.lua" "processfile")
-- (defun eepitch-dednat4 () (interactive) (eepitch-comint "dednat4" "lua51 -e load_dednat4() -i"))
-- (eepitch-kill)
-- (eepitch-dednat4)
load_dednat4 = function ()
    dednat4dir = dednat4dir or ee_expand("~/dednat4/")
    print("Loading: " .. dednat4dir .. "dednat4.lua")
    dofile(dednat4dir .. "dednat4.lua")
    A  = function (abbrev, expansion) addabbrev(abbrev, expansion) end
    D  = function (linestr) dofs(untabify(linestr)) end
    DX = function (linestr) dxy2Dx(untabify(linestr)) end
    D2 = function (linestr) dxy2D(untabify(linestr)) end
  end


-- «load_rex»  (to ".load_rex")
-- (find-es "lua5" "rexlib")
-- Usage: if not rex then load_rex() end
-- Note (2007): I haven't used this in ages!
-- Lpeg is much better, and nowadays I would try to use "require" here
-- instead of loadlib...
load_rex = function ()
    assert(loadlib(getenv("HOME").."/.lua50/lrexlib.so", "luaopen_rex"))()
    setmetatable(rex,
      {__call = function (self, p, cf, lo) return self.newPOSIX(p, cf, lo) end})
    function rex.find(s, p, st)   return rex(p):match(s, st) end
    function rex.gsub(s, p, f, n) return rex(p):gmatch(s, f, n) end
  end

-- «load_posix»  (to ".load_posix")
-- This is for lua-5.0, for 5.1 see: (to "loadposix")
-- (find-es "lua5" "load_posix")
-- (find-es "lua5" "posix-install")
load_posix = function ()
    userocks(); require "posix"
    -- assert(loadlib(getenv("HOME").."/.lua50/lposix.so", "luaopen_posix"))()
  end

-- «load_PP»  (to ".load_PP")
-- Load PP.so, that defines a C function called PP for inspecting the stack.
-- Old version, for lua-5.0:
-- -- (find-angg ".lua50/PP.c")
--    load_PP = function ()
--        assert(loadlib(getenv("HOME").."/.lua50/PP.so", "PP_init"))()
--      end
-- New version, for lua-5.1:
load_PP = function ()
    assert(package.loadlib(getenv("HOME").."/.lua51/PP.so", "PP_init"))()
  end
-- 2008dec01: load_PP is not needed for debugging anymore!...
-- The user-defined GDB command `PP' used to call the C function `PP',
-- that was defined in PP.c/PP.so - but I changed the GDB `PP' to make
-- it run directly all the calls to Lua that the C `PP' used to make.
-- See: (find-angg ".lua51/PP.c")
--      (find-angg ".lua51/PP.gdb")

-- «PPeval»  (to ".PPeval")
-- (find-angg ".lua51/PP.gdb" "PPeval")
-- (find-lua51file "src/lua.c" "first line starts with `=' ?")
PPeval = function (str)
    local e, code = string.match(str, "^(=?=?)(.*)$")
    local eval = function (str) return assert(loadstring(str))() end
    if     e == "==" then    PP(eval("return "..code))
    elseif e == "="  then print(eval("return "..code))
    else   return eval(code)
    end
  end

-- «loadswigso»  (to ".loadswigso")
-- (find-es "swig" "myswiglua")
-- Example: loadswigso("C", "./myparser.so", "parser", "countwords")
loadswigso = function (modulename, fname_so, ...)
    assert(loadlib(fname_so, modulename.."_Init"))()
    local module = _G[modulename]
    for i=1,arg.n do
      _G[arg[i]] = module[arg[i]]  -- export to the table of globals
    end
  end

-- «loadcinvoke»  (to ".loadcinvoke")
-- (find-es "lua5" "cinvoke")
loadcinvoke = function ()
    local oldcpath = package.cpath
    package.cpath = ee_expand("~/usrc/cinvoke-1.0/bindings/lua/?.so")
    require "cinvoke_lua"
    package.cpath = oldcpath
  end

-- «loadlpeg»  (to ".loadlpeg")
-- (find-es "lua5" "lpeg-0.7")
-- (find-es "lua5" "lpeg-0.8.1")
-- (find-es "lua5" "lpeg-0.9")
-- (find-es "lua5" "lpeg")
loadlpeg = function ()
    local oldcpath = package.cpath
    -- package.cpath = ee_expand("~/usrc/lpeg-0.4/?.so")
    -- package.cpath = ee_expand("~/usrc/lpeg-0.5/?.so")
    -- package.cpath = ee_expand("~/usrc/lpeg-0.7/?.so")..";"..oldcpath
    -- (find-lua51manual "#pdf-package.cpath")
    -- (find-sh0 "lua51 -e 'print(package.path)'")
    -- (find-sh0 "lua51 -e 'print(package.cpath)'")
    -- package.cpath = ee_expand("~/usrc/lpeg-0.8.1/?.so")..";"..oldcpath
    package.cpath = ee_expand("~/usrc/lpeg-0.9/?.so")..";"..oldcpath
    require "lpeg"
    package.cpath = oldcpath
    lpeg.test  = function (pat, str) PP(pat:C():match(str)) end
    lpeg.testt = function (pat, str) PP(pat:Ct():match(str)) end
    lpeg.togsub   = lpeg_togsub     -- (to "lpeg_togsub")
    lpeg.gsub     = lpeg_gsub       -- (to "lpeg_gsub")
    lpeg.gsub_    = lpeg_gsub_      -- (to "lpeg_gsub_")
    lpeg.Balanced = lpeg_balanced   -- (to "lpeg_balanced")
  end

-- «loadbitlib»  (to ".loadbitlib")
-- (find-es "lua5" "bitlib-51")
loadbitlib = function (fname)
    if bit then return "bitlib already loaded" end
    fname = fname or "~/usrc/bitlib-25/lbitlib.so"
    assert(package.loadlib(ee_expand(fname), "luaopen_bit"))()
  end

-- «autoload»  (to ".autoload")
-- Like in elisp. For global functions only.
-- (find-lua51manual "#pdf-require")
--
autoload = function (funname, loader)
    _G[funname] = function (...)
        loader()
        return _G[funname](unpack(arg)) -- todo: change to "..." (a 5.1-ism)
      end
  end

tcl = function (...)   -- <-- this is a kind of autoload
    local filename = ee_expand("~/.lua51/luatclbridge.so")
    local initname = "luaopen_luatclbridge"
    tcl = assert(package.loadlib(filename, initname))()
    return tcl(unpack(arg))             -- todo: change to "..." (a 5.1-ism)
  end

-- «loadtcl»  (to ".loadtcl")
-- (find-es "lua5" "luatclbridge")
-- (find-angg "LUA/luatclbridge.c")
-- loadtcl = function ()
--     local filename = ee_expand("~/LUA/tlbridge.so")
--     local initname = "luaopen_tlbridge"
--     tcl = tcl or assert(package.loadlib(filename, initname))()
--   end
loadtcl = function ()
    -- local filename = ee_expand("~/LUA/luatclbridge.so")
    local filename = ee_expand("~/.lua51/luatclbridge.so")
    local initname = "luaopen_luatclbridge"
    if not tcl then
      tcl, tclfindexecutable = assert(package.loadlib(filename, initname))()
      tclfindexecutable("/home/edrx/usrc/tk8.4/tk8.4-8.4.12/unix/wish") -- test
    end
  end
loadtk     = function () loadtcl(); return tcl("package require Tk") end
loadexpect = function () loadtcl(); return tcl("package require Expect") end
loadsnack  = function () loadtcl(); return tcl("package require sound") end
-- (find-es "tcl" "snack")
-- (find-anggfile "TCL/piano.tcl")

-- «loadldb»  (to ".loadldb")
-- (find-es "lua5" "ldb-from-tgz")
-- (find-es "lua5" "ldb")
loadldb = function ()
    local oldpath = package.path
    -- package.path = ee_expand("$S/http/primero.ricilake.net/lua/?.lua")
    -- package.path = ee_expand("~/LUA/?.lua")
    package.path = ee_expand("~/usrc/ldb/?.lua")
    ldb = require "ldb"
    package.path = oldpath
  end

-- «loadpeek»  (to ".loadpeek")
-- (find-angg "DAVINCI/peek.c")
-- (find-angg "DAVINCI/peek.lua")
loadpeek = function ()
    if not peek then
      assert(package.loadlib(ee_expand("~/DAVINCI/peek.so"), "peek_init"))()
    end
  end
getaddr = function (obj)
    return tonumber(string.match(tostring(obj), " 0x([0-9A-Za-z]+)"), 16)
  end

-- «loadalarm»  (to ".loadalarm")
-- (find-es "lua5" "signal")
loadalarm = function ()
    if not alarm then
      assert(package.loadlib(ee_expand("~/usrc/alarm/lalarm.so"), "luaopen_alarm"))()
    end
  end

-- «loadposix»  (to ".loadposix")
-- New way (active below):  (find-es "lua5" "luaposix")
-- old way (commented out): (find-es "lua5" "posix-lua51")
loadposix = function ()
    userocks(); require "posix"
    -- if not posix then
    --   -- assert(package.loadlib(ee_expand("~/usrc/posix/lposix.so"), "luaopen_posix"))()
    --   ee_loadlib("~/usrc/luaposix-5.1.4/posix.so", "luaopen_posix")
    -- end
  end

-- «getoutput»  (to ".getoutput")
-- (find-es "lua5" "getoutput")
getoutput = function (command)
    local pipe = assert(io.popen(command))
    local output = pipe:read("*a")
    pipe:close()
    return output
  end

-- «curl» (to ".curl")
-- (find-man "1 curl" "-s, --silent")
curl = function (url)
    local cmd = format("curl -s '%s'", url)
    return getoutput(cmd)
  end


-- «preparef2n»  (to ".preparef2n")
-- (find-es "lua5" "functionnames")
-- preparef2n: create a table with names of functions.
-- Example:
--   f2n = preparef2n()
--   print(f2n(loadstring)) --> "loadstring"
--
-- This is new (2007mar11), and not very well-tested.
-- Note: there's no support yet for submodules (like "socket.http").
-- I wrote this for my traceback functions...
--
preparef2n__ = function (fun2name, dictname, dictnamedot, dict)
    for name,value in pairs(dict or _G) do
      if type(value) == "function" then
        if string.match(name, "^[A-Za-z_][0-9A-Za-z_]*$") then
          fun2name[value] = dictnamedot..name
        else
          fun2name[value] = string.format("%s[%q]", dictname, name)
        end
      end
    end
  end

preparef2n_ = function (fun2name, dictnames)
    for _,dn in ipairs(split(dictnames)) do
      if dn == "_G"
      then preparef2n__(fun2name, "_G", "",      _G)
      else preparef2n__(fun2name, dn,   dn..".", _G[dn])
      end
    end
  end

preparef2n = function (otherdictnames)
    local f2n = {}
    local standarddicts = " coroutine debug io math os package string table "
    preparef2n_(f2n, standarddicts .. (otherdictnames or "") .. " _G ")
    return f2n
  end


-- «map»  (to ".map")
--------[ keys, map, seq, nop, each2, splitlines, chartranslator ]--------

keys = function (tbl)
    local ks = {}
    for k,_ in pairs(tbl) do tinsert(ks,k) end
    return ks
  end

map = function (f, arr, n)
    local brr = {}
    for i=1,(n or #arr) do tinsert(brr, (f(arr[i]))) end
    return brr
  end

seq = function (a, b, c)
    local arr = {}
    for i=a,b,(c or 1) do tinsert(arr, i) end
    return arr
  end

nop = function () end
id  = function (...) return ... end

shallowcopy = function (A, B)
    B = B or {}
    for k,v in pairs(A) do B[k] = v end
    return B
  end

uniq = function (A)
    local B = {}
    for i=1,#A do if A[i] ~= A[i-1] then table.insert(B, A[i]) end end
    return B
  end

-- (find-lua51manual "#pdf-table.sort")
-- http://lua-users.org/lists/lua-l/2011-04/msg00406.html
sorted = function (tbl, lt) table.sort(tbl, lt); return tbl end

-- (find-efunctiondescr   'mapconcat)
-- (find-elnode "Index" "* mapconcat:")
-- (find-es "lua5" "table.concat")
mapconcat = function (f, tbl, sep, n)
    return table.concat(map(f, tbl, n), sep)
  end

maplines = function (f, bigstr)
    return mapconcat(f, splitlines(bigstr), "\n")
  end

-- «fold»  (to ".fold")
-- (find-hugsbasefile "Prelude.hs" "\nfoldl ")
-- foldl :: (a -> b -> a) -> a -> [b] -> a
foldl = function (f, a, B, i, j)
    for k=(i or 1),(j or #B) do a = f(a, B[k]) end
    return a
  end



-- «gformat»  (to ".gformat")
-- A variant of "format" that uses "string.gsub".
-- This is surprisingly useful. 8-)
--           gformat "<%1_%1>" "foo"                   --> <foo_foo>
-- mapconcat(gformat "<%1_%1>", split "foo bar", ", ") --> <foo_foo>, <bar_bar>
-- See also: (find-es "emacs" "ee-gformat")
gformat = function (fmt, pat)
    return function (str)
        return (str:gsub((pat or "^.*$"), fmt))
      end
  end



-- «each2»  (to ".each2")
-- (find-es "lua5" "each2")
-- (find-pilw3m "7.1.html" "Iterators and Closures")
each2 = function (tbl)
    local i = 1
    return function ()
        if i <= getn(tbl) then
          i = i + 2
          return tbl[i - 2], tbl[i - 1]
        end
      end
  end

-- «splitlines»  (to ".splitlines")
splitlines = function (bigstr)
    local arr = split(bigstr, "([^\n]*)\n?")
    table.remove(arr)
    return arr
  end
isplitlines = function (bigstr)
    return ipairs(splitlines(bigstr))
  end

-- «splitlines-5.3»  (to ".splitlines-5.3")
-- (find-es "lua5" "splitlines-5.3")
splitlines = function (bigstr)
    local arr = split(bigstr, "([^\n]*)\n?")
    if _VERSION:sub(5) < "5.3" then
      table.remove(arr)
    end
    return arr
  end

-- «translatechars»  (to ".translatechars")
-- (find-node "(coreutils)Translating")
translatechars = function (str, re, tbl)
    return (gsub(str, re, function (c) return tbl[c] or c end))
  end

-- chartranslator = function (re, tbl)
--     return function (str)
--         return gsub(str, re, function (c) return tbl[c] or c end)
--       end
--   end
--
-- sgmlify = chartranslator(sgmlify_re, sgmlify_table)

-- «sbeconcat»  (to ".sbeconcat")
-- Concatenate a table with strings and with begin/end pairs
-- Example:
--   sbeconcat("abfoocd"){1, 3, "FOO", 6, 8}   --> "abFOOcd"
-- This is ugly! concatbestrings, below, is much clearer.
--
sbeconcat = function (subj, f)
    f = f or function (str) return str end
    return function (table1)
        local table2, i, n = {}, 1, table.getn(table1)
        while i <= n do
          local obj = table1[i]
          if type(obj) == "string" then
            tinsert(table2, obj)
            i = i + 1
          else
	    local str = string.sub(subj, obj, table1[i+1] - 1)
            tinsert(table2, f(str))    --< sgmlify?
            i = i + 2
          end
        end
        return table.concat(table2)
      end
  end



-- «concatbestrings»  (to ".concatbestrings")
-- A "table of bestrings" is a table containing pairs of numbers
-- (begin/end pairs) and strings. Example:
--   concatbestrings("abfoocd", nil, {1, 3, "FOO", 6, 8})   --> "abFOOcd"
--         (a table of bestrings) -> \-----------------/
--
concatbestrings = function (subj, f, bestrings)
    f = f or function (s) return s end
    local table2, i = {}, 1
    while i <= #bestrings do
      local obj = bestrings[i]
      if type(obj) == "string" then
        table.insert(table2, obj)
        i = i + 1
      else
	local str = string.sub(subj, obj, bestrings[i+1] - 1)
        table.insert(table2, f(str))
        i = i + 2
      end
    end
    return table.concat(table2)
  end

curriedconcatbestrings = function (subj, f)
    return function (bestrings)
        return concatbestrings(subj, f, bestrings)
      end
  end


-- «lpeg_togsub»  (to ".lpeg_togsub")
-- «lpeg_gsub»    (to ".lpeg_gsub")
-- A pattern that returns a string can be "Kleene-starred with
-- the least possible filling" to create a pattern that works
-- somewhat like a gsub, but that returns a table of bestrings...
-- Roughly, that would be like converting "(pat)" into
-- "\\(().-()(pat)\\)*().-()", where the "\\(...\\)" is a "shy
-- group" - i.e., its parentheses do not return a capture.
--
-- Actually this returns a sequence of captures, not a table; use Ct()
-- to pack them in to a table, and then a concatbestrings.
--
-- The logic: the pattern PosPosWord, below, works like this:
--
--    -> Pos -----+1--> Pos --> Word -->
--             ^  2
--             |  \---> Anychar ->\
--             |                  |
--             \------------------/
--
-- where each "Pos" returns a number, and "Word" returns a string.
-- The "1" and the "2" indicate the order in which the branches are
-- tried (at the "+"). The rest of the function shouldn't be hard to
-- understand.
--
-- (find-es "lua5" "lpeg-quickref")
lpeg_togsub = function (Word)
    local Pos        = lpeg.Cp()
    local AnyChar    = lpeg.P(1)
    local BeRest     = Pos * AnyChar^0 * Pos
    local PosPosWord = Pos * lpeg.P { Pos * Word + AnyChar * lpeg.V(1) }
    return PosPosWord^0 * BeRest
  end

lpeg_gsub = function (Word, subj, f)
    f = f or function (...) return ... end
    return concatbestrings(subj, f, Word:togsub():Ct():match(subj))
  end

-- Example:
-- loadlpeg()
-- Word        = lpeg.R("AZ")^1 / function (s) return "<"..s..">" end
-- = Word:gsub("abFOOcdBAR", function (s) return "_"..s.."_" end)
--         --> "_ab_<FOO>_cd_<BAR>__"


-- «lpeg_gsub_»  (to ".lpeg_gsub_")
-- An alternative (faster but more complex):
-- With gsub_ we can reuse a prebuilt :togsub():Ct() pattern,
-- without having to build it anew each time.
-- loadlpeg()
-- WordTogsubCt = Word:togsub():Ct()
-- = WordTogsubCt:gsub_("abFOOcdBAR", function (s) return "_"..s.."_" end)
--         --> "_ab_<FOO>_cd_<BAR>__"
--
lpeg_gsub_ = function (WordTogsubCt, subj, f)
    f = f or function (...) return ... end
    return concatbestrings(subj, f, WordTogsubCt:match(subj))
  end



-- «lpeg_balanced»  (to ".lpeg_balanced")
-- (find-angg "LUA/preproc.lua")
lpeg_balanced = function (Open, MidChars, Close)
    local Middle
    Open     = lpeg.P(Open)
    Close    = lpeg.P(Close)
    MidChars = MidChars or (1 - (Open + Close))^1
    Middle   = lpeg.P { (MidChars + Open * lpeg.V(1) * Close)^0 }
    return Open * Middle:C() * Close, Middle
  end




-- «mytraceback»  (to ".mytraceback")
-- (find-es "lua5" "xpcall" "mytraceback =")
-- (find-lua51manual "#pdf-xpcall")
-- (find-lua51manual "#pdf-debug.traceback")
-- (find-lua51manual "#pdf-error")
mytraceback = function (errmsg)
    io.output():flush()
    print(debug.traceback(errmsg, 2))
  end
xxcall = function (f)
    if not xpcall(f, mytraceback) then error() end
  end


-- «errorfb_line»  (to ".errorfb_line")
-- (find-es "lua5" "traceback")
-- (find-lua51file "src/ldblib.c" "{\"traceback\", db_errorfb},")
-- (find-lua51file "src/ldblib.c" "static int db_errorfb")
-- (find-lua51file "src/ldblib.c" "static int db_errorfb" "lua_getinfo")
-- http://www.lua.org/source/5.1/ldblib.c.html#db_errorfb
-- http://www.lua.org/source/5.1/ldblib.c.html#dblib
-- (find-es "lua5" "loadstring_and_eof")
-- http://lua-users.org/lists/lua-l/2011-11/msg00110.html
-- (find-es "lua5" "lua_getstack")

errorfb_line = function (ar)
    local s = "\t"
    local p = function (...) s = s..format(...) end
    p("%s:", ar.short_src)
    if ar.currentline > 0 then p("%d:", ar.currentline) end
    if ar.namewhat ~= ""  then p(" in function '%s'", ar.name) else
      if ar.what == "main" then p(" in main chunk")
      elseif ar.what == "C" or ar.what == "tail" then p(" ?")
      else p(" in function <%s:%d>", ar.short_src, ar.linedefined)
      end
    end
    return s
  end
errorfb_lines = function (a, b, step, f)
    local T = {}
    for level=a,b,(step or 1) do
      T[#T+1] = (f or errorfb_line)(debug.getinfo(level))
    end
    return table.concat(T, "\n")
  end



-- «ee_template»  (to ".ee_template")
-- (find-eev "eev-insert.el" "ee-template")
-- ee_template({a="<AA>", b="<BB>"}, "foo{a}bar{c}plic")
--   --> "foo<AA>bar{c}plic"
ee_template = function (pairs, templatestr)
    return (string.gsub(templatestr, "{([^{}]+)}", pairs))
  end

-- «ee_into»  (to ".ee_into")
-- ee_into("a b c", "<AA> <BB>")
--   --> {"a"="<AA>", "b"="<BB>"}
ee_into = function (fieldnames, data)
    if type(fieldnames) == "string" then fieldnames = split(fieldnames) end
    if type(data)       == "string" then data       = split(data)       end
    local o = {}
    for i=1,#fieldnames do o[fieldnames[i]] = data[i] end
    return o
  end

-- «chdir»  (to ".chdir")
-- 2008may23 / 2020jan17
-- See: (find-es "lua5" "luaposix-git")
chdir = function (dir)
    loadposix()
    if not posix.chdir then posix.chdir = posix.unistd.chdir end
    return assert(posix.chdir(ee_expand(dir)))
  end

-- «package.require»  (to ".package.require")
-- Make package.require consider that this file has been loaded when
-- it was loaded by LUA_INIT=@.../LUA/lua50init.lua (see the comments
-- at the top of this file) so that we can do 'require "lua50init"' or
-- 'require "edrxlib"'...
--   (find-lua51manual "#pdf-require")
--   (find-lua51file "")
--   (find-lua51file "src/loadlib.c" "static int ll_require ")
package.loaded.lua50init =
  package.loaded.lua50init or "(loaded by LUA_INIT=@...)"
package.loaded.edrxlib =
  package.loaded.edrxlib or "(loaded by LUA_INIT=@...)"


-- «userocks»  (to ".userocks")
-- (find-angg ".emacs" "luarocks")
-- (find-lua51manual "#pdf-require")
-- (find-lua51manual "#pdf-package.path")
-- (find-lua51manual "#pdf-package.cpath")
-- (find-fline "~/usrc/luarocks/share/lua/5.1/")
-- (find-fline "~/usrc/luarocks/lib/lua/5.1/")
userocks = function ()
    local luarocksdir = ee_expand "~/usrc/luarocks"
    package.path  = package.path ..";"..luarocksdir.."/share/lua/5.1/?.lua"
    package.cpath = package.cpath..";"..luarocksdir.."/lib/lua/5.1/?.so"
    req = function (pkgname) return function () require(pkgname) end end
    loadposix  = req "posix"
    load_posix = req "posix"
  end

-- «loadblogme3» (to ".loadblogme3")
-- (find-es "blogme" "interactive")
-- (find-angg ".emacs" "blogme3")
loadblogme3 = function (msg)
    blogmedir = ee_expand "~/blogme3/"
    ee_dofile "~/blogme3/blogme3.lua"
    b = doblogme
    if msg then print 'See: (find-es "blogme" "interactive")' end
  end
loadblogme3rest = function ()
    pathtoroot    = getpathtoroot("")
    eevarticle    = pathto("eev-article.html")
    eepitchreadme = pathto("eev-current/eepitch.readme.html")
    eepitch_el    = pathto("eev-current/eepitch.el.html")
    eevintrosdir  = pathto("eev-intros/")
    require "angglisp"
  end
loadblogme3all = function (msg)
    loadblogme3(msg)
    loadblogme3rest()
  end

-- «hms_to_s» (to ".hms_to_s")
-- «s_to_hms» (to ".s_to_hms")
hms_to_s = function (hms)
    local zeros = "00:00:00"
    hms = zeros:sub(1, #zeros-#hms)..hms
    return hms:sub(1, 2)*3600 + hms:sub(4, 5)*60 + hms:sub(7, 8)
  end
s_to_hms = function (s)
    local f = function (n) local a = math.fmod(n, 60); return a, (n-a)/60 end
    local s,m = f(s)
    local m,h = f(m)
    if h > 0
    then return format("%d:%02d:%02d", h, m, s)
    else return format(     "%d:%02d",    m, s)
    end
  end

-- «icollect» (to ".icollect")
-- (find-es "lua5" "icollect")
-- http://lua-users.org/lists/lua-l/2012-12/msg00661.html
-- http://lua-users.org/lists/lua-l/2012-12/msg00713.html
-- http://lua-users.org/lists/lua-l/2012-12/msg00739.html
icollect_helper = function (t, i, n, f, s, var_1, ...)
    if var_1 ~= nil then
      t[i] = select(n, var_1, ...)
      return icollect_helper(t, i+1, n, f, s, f(s, var_1))
    end
    return t, i-1
  end
icollect = function (n, f, s, var)
    return icollect_helper({}, 1, n, f, s, f(s, var))
  end



-- «interactor»  (to ".interactor")
-- This is obsolete.
-- The new version is at: (find-angg "LUA/reader.lua")
-- (find-es "lua5" "interactor")
-- (find-TH "repl")
-- Example:
--   compiled, errmsg = interactor():read(".>"):complete()
-- Some explanations:
--   interactor() returns a table that is "over" interactor_metatable,
--   I:read(".>") reads the first line with prompt ".>",
--   I:complete() tries to run loadstring(I:body()); while that is
--                not a complete Lua chunk, keep reading. When either
--                the input becomes complete or another error besides
--                "incomplete" occurs, return I.compiled and I.errmsg.
-- Notes:
--   On "abort" (i.e., either reading a line with just ".", or getting
--     an eof), I:complete() returns two nils. In all the other cases
--     exactly one of I.compiled, I.errmsg will be non-nil, and
--     assert(I.compiled, I.errmsg)() would do what's expected.
--   I'm planning the treat an abort at the first line specially -
--     meaning "return from the interactor loop".
--   This doesn't do much at this moment - I'm experimenting with loops
--     around interactor():read(".>"):complete(), but the code for
--     these experiments is elsewhere...
--
--[[
interactor_metatable = {
  concat = function (self) return table.concat(self, "\n") end,
  body   = function (self) return self:concat() end,  -- overriddable
  prompt = function (self) return ">> " end,          -- overriddable
  abort = function (self) end,                        -- overriddable; message
  load = function (self)
      if self.line then
        self.compiled, self.errmsg = loadstring(self:body())
        self.incomplete = self.errmsg and
          string.find(self.errmsg, ": unexpected symbol near '<eof>'$")
      else
        self.compiled, self.errmsg, self.incomplete = nil, nil, nil
      end
      return self
    end,
  read = function (self, prompt)
      io.write(prompt or self:prompt())
      self.line = io.read()
      if self.line == "." then self:abort(); self.line = nil end
      if self.line then table.insert(self, self.line) end
      return self
    end,
  complete = function (self)
      while self.line and self.incomplete do self:read(); self:load() end
      return self
    end,
}

interactor = function () return over(interactor_metatable) end
--]]

-- «Repl» (to ".Repl")
-- (find-es "lua5" "Repl")
-- This is obsolete.
Repl = Class {
  type    = "Repl",
  __index = {
    incompletep0 = function (r, str)
        return str:find(": unexpected symbol near '<eof>'$")
      end,
    incompletep = function (r, str)
        local f, err = loadstring(str)
        return f == nil and r:incompletep0(err)
      end,
    read0 = function (r, prompt) io.write(prompt); return io.read() end,
    read1 = function (r) return r:read0 ">>> "  end,
    read2 = function (r) return r:read0 "... " end,
    complete = function (r, str)
	while r:incompletep(str) do str = str.."\n"..r:read2() end
	return str
      end,
    split = function (r, str) return str:match "^(=?=?)(.*)$" end,
    printers = {[""]=id, ["="]=print, ["=="]=PP},
    prepends = {[""]="", ["="]="return ", ["=="]="return "},
    read_ = function (r) return r:complete(r:read1()) end,
    read = function (r, str00)
        local prefix, str0 = r:split(str00 or r:read1())
        local printer, prepend = r.printers[prefix], r.prepends[prefix]
        local str = r:complete(prepend..str0)
        return printer, str
      end,
    evalprint = function (r, printer, str)
        local f, err = loadstring(str)
        return printer(f())
      end,
    rep = function (r, str00) return r:evalprint(r:read(str00)) end,
    repp = function (r)
        local str00 = r:read1()
        if str00 == "!" then return false end
        r:rep(str00)
        return true
      end,
    repl = function (r) while r:repp() do end end,
  },
}

-- «loadluarepl» (to ".loadluarepl")
-- (find-es "lua5" "lua-repl-0.8")
-- (find-dednat6 "dednat6/luarepl.lua")
loadluarepl = function (dir)
    if repl then return "lua-repl-0.8 already loaded (it seems)" end
    -- repldir   = ee_expand(dir or "~/usrc/lua-repl-0.8/")
    repldir      = ee_expand(dir or "~/dednat6/dednat6/lua-repl/")
    package.path = repldir.."?/init.lua;"..package.path
    package.path = repldir.."?.lua;"     ..package.path
    repl         = require "repl"
    sync         = require "repl.sync"
    function sync:showprompt() print ">>>" end
    function sync:showprompt() io.write ">>> " end
    function sync:showprompt(n) print(n); io.write ">>> " end
    function sync:showprompt(p) io.write(p == ">" and ">>> " or ">>>> ") end
    function sync:lines() return io.stdin:lines() end
    function sync:displayerror(err) print(err) end
    function sync:displayresults(results)
        if results.n == 0 then return end
        print(unpack(results, 1, results.n))
      end
    -- luarepl = function () print(); print(); sync:run() end
    luarepl = function () sync:run() end
    return "Loaded lua-repl-0.8"
  end


-- «replaceranges» (to ".replaceranges")
-- str = "(foo bar)"
-- ranges = {{6,9,"BAR"}, {2,5, string.upper}}
-- = replaceranges(str, ranges)
replaceranges_ = function (str, ranges, spos, rpos, f)
    local range = ranges[rpos]
    if not range then return str:sub(spos) end
    local a, b, s_or_f = range[1], range[2], range[3]
    local s = (type(s_or_f) == "string")
                and s_or_f
                or  s_or_f(str:sub(a, b-1))
    return f(str:sub(spos, a-1)) .. s ..
           replaceranges_(str, ranges, b, rpos+1, f)
  end
replaceranges = function (str, ranges, f)
    table.sort(ranges, function (a, b) return a[1]<b[1] end)
    return replaceranges_(str, ranges, 1, 1, f or id)
  end


-- «string.replace» (to ".string.replace")
-- a = "abcdefg"
-- a:replace(2, "CDE")     --> "abCDEfg"
-- a:replace(2, "CDE", 4)  --> "abCDE g"
--
string.leftof = function (s, w)
    if     #s >  w then return s:sub(1, w)
    elseif #s == w then return s
    else return s..string.rep(" ", w - #s)
    end
  end
string.rightof = function (s, w)
    if #s <= w then return ""
    else return s:sub(w+1)
    end
  end
string.replace = function (s, x, r, w)
    w = w or #r
    r = r:leftof(w)
    return s:leftof(x)..r..s:rightof(x + #r)
  end


-- «Rect» (to ".Rect")
-- See: (find-es "lua5" "Rect")
Rect = Class {
  type    = "Rect",
  new     = function (A) return Rect(A or {""}) end,
  from    = function (o)
      if otype(o) == "Rect" then return o end
      return Rect.new(splitlines(tostring(o)))
    end,
  __index = {
    copy = function (rect) return Rect(shallowcopy(rect)) end,
    width = function (rect)
        local w = 0
        for i=1,#rect do w = max(w, #rect[i]) end
        return w
      end,
    replace1 = function (rect, x, y, r, w)
        while #rect < y do table.insert(rect, "") end
        rect[y] = rect[y]:replace(x, r, w)
      end,
    replace = function (rect1, x, y, rect2, w)
        w = w or rect2:width()
        for i=1,#rect2 do
          rect1:replace1(x, y, rect2[i], w)
          y = y + 1
        end
        return rect1
      end,
    -- For syntax trees:
    syntree1 = function (rect, op, hchar, vchar)
        rect = rect:copy()
        op = op or "."
        if hchar then
          op = op .. string.rep(hchar, rect:width() + 2 - #op)
        end
        table.insert(rect, 1, vchar or "|")
        table.insert(rect, 1, op)
        return rect
      end,
  },
  __concat = function (r1, r2)
      return Rect.new():replace(0, 1, r1):replace(r1:width(), 1, r2)
    end,
  __tostring = function (rect)
      return table.concat(rect, "\n")
    end,
}

-- «syntree» (to ".syntree")
-- (find-es "lua5" "syntax-trees")
-- (find-es "lua-intro" "lpeg-re-1")
syntree0 = function (op, rects)
    local rf = function (i, op, h)
        return Rect.from(rects[i]):syntree1(op, h)
      end
    if #rects == 1 then return rf(1, op) end
    if #rects > 1 then
      local r = rf(1, op, "_")
      for i=2,#rects-1 do r = r..rf(i, ".", "_") end
      r = r..rf(#rects, ".")
      return r
    end
  end

syntreeg = function (...)
    local A = {...}
    local rf = function (i, op, h)
        return Rect.from(A[i]):syntree1(op, h)
      end
    if #A == 1 then return A[1] end
    r = rf(#A)
    for i=#A-2,1,-2 do
      r = rf(i, A[i+1], "_")..r
    end
    return r
  end

-- «re_expand_INFIX» (to ".re_expand_INFIX")
-- (find-es "lua-intro" "lpeg-re-infix-2")
re_expand_INFIX_0 = function (parenstr)
    local components = split(parenstr:sub(2, -2))
    local e     = table.remove(components, 1)
    local sep   = table.remove(components, 1)
    local ops   = components
    local quote = function (str) return '"'..str..'"' end
    local oneop = function (ops) return mapconcat(quote, ops, " / ") end
    local tbl   = {E=e, SEP=sep, OP=oneop(ops)}
    local re    = string.gsub("(E s ({OP} SEP E)*)", "[A-Z]+", tbl)
    return re
  end
re_expand_INFIX = function (gram)
    return (string.gsub(gram, "INFIX(%b())", re_expand_INFIX_0))
  end

-- «math-grammar» (to ".math-grammar")
-- (find-gab "gab.lua" "lpeg-parser")
-- (find-gabfile "gab.lua" "Expr.__index.infix =")
-- Missing: _, __, (), {|,,}, {,,}, Fa/Ex/Lambda, :, not, unary-
math_grammar_0 = [[
  e75 <- INFIX( e70 s   |                ) -> f_nonassoc
  e70 <- INFIX( e65 s   ,                ) -> f_nary
  e65 <- INFIX( e60 s   <-               ) -> f_nonassoc
  e60 <- INFIX( e55 s   ->               ) -> f_nonassoc
  e55 <- INFIX( e50 s   or               ) -> f_left
  e50 <- INFIX( e45 s   &                ) -> f_left
  e45 <- INFIX( e40 s   not              ) -> f_OOOOOOOOOOOOPS
  e40 <- INFIX( e35 s   in               ) -> f_nonassoc
  e35 <- INFIX( e30 s   <= < == != >= >  ) -> f_nary
  e30 <- INFIX( e25 s   + -              ) -> f_left
  e25 <- INFIX( e20 s   // / *           ) -> f_left
  e20 <- INFIX( e15 s   ^                ) -> f_right
]]



-- «cow-and-coy» (to ".cow-and-coy")
-- (find-es "lua5" "cow-and-coy")
coy = coroutine.yield
cow = coroutine.wrap

-- «eval-and-L» (to ".eval-and-L")
-- (find-LATEX "2014-1-GA-P2-gab.lua")
eval = function (str) return assert(loadstring(str))() end
expr = function (str) return eval("return "..str) end
L00 = function (args, body)
    return string.format("function (%s) return %s end", args, body)
  end
L0 = function (str)
    str = str:gsub("^%s*(%S+)%s+->", "%1 ")
    local args, body = str:match("^%s*(%S+)%s+(.*)$")
    return L00(args, body)
  end
L = function (str) return expr(L0(str)) end




-- 2013jan16; to be moved to blogme3 / blogme4
string.revgsub = function (str, ...)
    return str:reverse():gsub(...):reverse()
  end
underlinify = function (s)
    return s:sub(1, 1)..string.rep("_", #s-2)..s:sub(#s)
  end

intro_url = function (stem)
    return anggurl("eev-intros/find-"..stem.."-intro.html")
  end

angg_url  = function (fname) return "../"..fname end
intro_url = function (stem) return string.upper(stem) end
isdir     = function (fname) return fname=="" or fname:sub(-1)=="/" end
suffixing = function (fname, suffix, anchor)
    return (isdir(fname) and fname or fname..suffix) ..
           (anchor and "#"..anchor or "")
  end

meta_find_angg = function (anggdir, suffix, intro_stem)
    return function (fname, tag)
        local target = fname and
          angg_url(anggdir)..suffixing(fname, suffix or ".html")
        if target and tag then target = target.."#"..tag end
        return target, intro_url(intro_stem or "code-c-d")
      end
  end



-- «Sexp» (to ".Sexp")
-- Used here: (find-blogme3 "anggdefs.lua" "Sexp")
elisp = {}
elisp["find-angg"] = meta_find_angg("")
elisp["find-es"]   = meta_find_angg("e/", ".e.html")

elispSPECIAL = {}

Sexp = Class {
  type    = "Sexp",
  __index = {
    getsexp = function (sexp)
        local line = sexp.line
        if line:sub(#line) ~= ")" then return end
        local len = #line
        local skel = line:gsub("\\.", "__")              -- backslash+c -> __
        skel = skel:revgsub("\"[^\"]*\"", underlinify)   -- "abc" -> "___"
        skel = skel:sub(1, len-1):revgsub("%b)(", underlinify)..skel:sub(len)
        local revsexp = line:reverse():match("^%b)(")
        if not revsexp then return end
        sexp.sexp = revsexp:reverse()
        sexp.pre  = line:sub(1, len-#sexp.sexp)
        -- sexp.sexpskel = skel:sub(#sexp.pre+1)
        sexp.midskel = skel:sub(#sexp.pre+2, len-1)
        sexp.head    = sexp.midskel:match("^%S*")
        return sexp.head
      end,
    getsexpargs = function (sexp)
        local n = 0
        sexp.ranges = {}
        for i,j in sexp.midskel:gmatch("()%S+()") do
          n = n + 1
          sexp[n] = sexp.sexp:sub(i+1, j)
          sexp.ranges[n] = {i+1, j+1}
        end
      end,
    string = function (sexp, n)
        return sexp[n] and sexp[n]:match '^"(.*)"$'
      end,
    --
    Q = function (text) return text end,
    hrefto = function (sexp, url)
        return function (text)
            return '<a href="'..url..'">'..sexp.Q(text)..'</a>'
          end
      end,
    setrange = function (sexp, a, b, s_or_f)
          table.insert(sexp.htmlranges, {a, b, s_or_f})
      end,
    sethelp = function (sexp, url)
        local r = sexp.ranges[1]
        if url then sexp:setrange(r[1], r[2], sexp:hrefto(url)) end
        -- table.insert(sexp.htmlranges, {r[1], r[2], sexp:hrefto(url)})
        -- end
      end,
    settarget = function (sexp, url)
        local len = #sexp.sexp
        if url then sexp:setrange(len-1, len+1, sexp:hrefto(url)) end
        -- table.insert(sexp.htmlranges, {len-1, len+1, sexp:hrefto(url)})
        -- end
      end,
    tohtml0 = function (sexp)
        return replaceranges(sexp.sexp, sexp.htmlranges or {}, sexp.Q)
      end,
    getsexphtml = function (sexp)
        sexp.htmlranges = {}
        if not sexp.head then return end
        if elispSPECIAL[sexp.head] then    -- for all kinds of special hacks
          elispSPECIAL[sexp.head](sexp)
          return
        end
        local find_aaa = elisp[sexp.head]
        if not find_aaa then return end
        sexp:getsexpargs()
        sexp.target, sexp.help = find_aaa(sexp:string(2), sexp:string(3))
        sexp:sethelp(sexp.help)
        sexp:settarget(sexp.target)
        sexp.sexphtml = sexp:tohtml0()
      end,
    getlinehtml = function (sexp)
        if sexp:getsexp() then sexp:getsexphtml() end
        if sexp.sexphtml
        then sexp.linehtml = sexp.Q(sexp.pre)..sexp.sexphtml
        else sexp.linehtml = sexp.Q(sexp.line)
        end
        return sexp.linehtml
      end,
  },
}

-- «youtube_make_url»  (to ".youtube_make_url")
-- (find-es "youtube" "time-syntax")
youtube_make_url = function (hash, time)
    return "http://www.youtube.com/watch?v=" .. hash .. youtube_time(time)
  end
youtube_time = function (time)
    if type(time) ~= "string" then return "" end
    local mm,ss = time:match("^(%d?%d):(%d%d)$")
    if ss then return "&t="..(mm*60+ss) end
    return ""
  end

-- «youtube_split» (to ".youtube_split")
-- I was using this at too many places - including one-shot programs...
-- (find-angg "LUA/youtube-tags.lua")
-- (find-angg "LUA/youtube.lua")
-- (find-blogme3 "youtube.lua")
youtube_split_url0 = function (li)
    local a, url, b, title, c = li:match "^(.-)(https?://%S*)(%s*)(.-)(%s*)$"
    if not url then return end
    local hash, time
    for key,value in url:gmatch "[?&](%w*)=([^?&#'()]*)" do
      if key == "v" then hash = value end
      if key == "t" then time = value end  -- not being used now
    end
    if not hash then return end
    return a, hash, b, title, c
  end
youtube_split_url = function (li)
    local a, hash, b, title, c = youtube_split_url0(li)
    if a then return hash, youtube_make_url(hash), title end
  end


-- «url_split» (to ".url_split")
-- Used here: (find-angg "LUA/redirect.lua")
url_percent_decode  = function (str)
    local f = function (hh) return string.char(tonumber(hh, 16)) end
    return (str:gsub("%%(%x%x)", f))
  end
url_query_split = function (query)
    local Q = {}
    for key,value in query:gmatch "[?&](%w*)=([^?&#'()]*)" do
      Q[key] = url_percent_decode(value)
    end
    return Q
  end
--
url_split_re  = nil
url_split_re0 = function ()
    userocks()
    require "re"     -- (find-es "lua5" "lpeg-re")
    return re.compile [=[
        {|       {:scheme: [a-z]+ :} "://"
                 {:host:   [^/]+  :}
           ( "/" {:path:   [^?#]* :} ) ?
           ( "?" {:query:  [^#]*  :} ) ?
           ( "#" {:anchor: [^#]*  :} ) ?
        |}
      ]=]
  end
url_split = function (url)
    url_split_re = url_split_re or url_split_re0()
    local parts  = url_split_re:match(url)
    if parts and parts.query then parts.q = url_query_split("?" .. parts.query) end
    return parts
  end


-- «Blogme» (to ".Blogme")
-- An attempto to reimplement this: (find-blogme3 "brackets.lua")
-- as a class.
Blogme = Class {
  type    = "Blogme",
  __index = {
    ps = function (bme)  -- parse space chars
        local s, p = bme.str:match("^([ \t\n]+)()", bme.pos)
        if s then bme.pos = p; return s end
      end,
    pw = function (bme)  -- parse word chars (i.e., no spaces, no brackets)
        local s, p = bme.str:match("^([^%[%] \t\n]+)()", bme.pos)
        if s then bme.pos = p; return s end
      end,
    pr = function (bme)  -- parse regular chars (i.e., no brackets)
        local s, p = bme.str:match("^([^%[%]]+)()", bme.pos)
        if s then bme.pos = p; return s end
      end,
    pb0 = function (bme) -- parse bracket (without evaluation)
        local b, e = bme.str:match("^()%b[]()", bme.pos)
        if b then bme.pos = e; return b+1, e-1 end
      end,
    pqarg0 = function (bme) -- parse a quoted argument (without evaluation)
        bme:ps()
        local b = bme.pos
        while bme:pb0() or bme:pw() do end
        return b, bme.pos
      end,
    sub = function (bme, b, e) return b and bme.str:sub(b, e-1) end,
  },
}






-- (find-blogme3 "anggdefs.lua" "basic-words-for-html" "HREF")
HREF  = function (url, str) return format('<a href="%s">%s</a>', url, str) end
HREF1 = function (url, str) return url and HREF(url, str) or str end

-- «EevIntro» (to ".EevIntro")
-- (find-es "lua5" "EevIntro")
EevIntro = Class {
  type = "EevIntro",
  from = function (stem, sec)
      return EevIntro {stem=stem, sec=sec}
    end,
  fromshort = function (short)
      if short:match"#"
      then return EevIntro.from(short:match"^(.-)#(.*)")
      else return EevIntro.from(short)
      end
    end,
  fromheadposspec = function (head, posspec)
      local stem = head:match "^find%-(.*)%-intro$"
      local sec = posspec and posspec:match "^(%d[%d%.]*)%. "
      return EevIntro.from(stem, sec)
    end,
  fromsexp = function (li)
      local head, rest = li:match "^%s*%(([!-~]+)(.*)%)%s*$"
      local posspec = rest:match "^%s+\"(.*)\"$"
      return EevIntro.fromheadposspec(head, posspec)
    end,
  __tostring = function (ei) return mytostring(ei) end,
  __index = {
    url = function (ei)
        return format("eev-intros/find-%s-intro.html%s",
                      ei.stem, ei.sec and "#"..ei.sec or "")
      end,
    short = function (ei)
        return ei.stem .. (ei.sec and "#"..ei.sec or "")
      end,
  },
}

introhtml = function (stem, sec)
    return EevIntro.from(stem, sec):url()
  end



-- «ELispH» (to ".ELispH")
-- See: (find-es "lua5" "ELispH")
--      (find-es "lua5" "ELispH-tests")
--
-- An ELispH object holds data that can generate a "help url" and
-- a "target url". For example:
--
--   eh = ELispH({intro="eev-quick", target="index.html", anchor="eev"})
--   eh:gethelp()   --> "eev-intros/find-eev-quick-intro.html"
--   eh:gettarget() --> "index.html#eev"
--
-- The :sexphtml(...) method connects this to SexpSkel.
--
ELispH = Class {
  type    = "ELispH",
  __tostring = function (eh) return mytabletostring(eh) end,
  __index = {
    gethelp = function (eh)
        if eh.intro then
          local stem,section = eh.intro:match("^(.-)#(.*)")
          if section then return introhtml(stem, section) end
          return introhtml(eh.intro)
        end
	return eh.help
      end,
    gettarget = function (eh)
        return eh.target and (eh.target .. (eh.anchor and "#"..eh.anchor or ""))
      end,
    sexphtml = function (eh, hzer, a, head, b, qp)
        hzer = hzer or id
        local help   = eh:gethelp()
        local target = eh:gettarget()
        return hzer(a) .. HREF1(help,   hzer(head)) ..
               hzer(b) .. HREF1(target, hzer(qp))
      end,
    --
    test = function (eh)
        local outt = {help=eh:gethelp(), target=eh:gettarget()}
        return tostring(eh) .. " ->\n" .. mytabletostring(outt)
      end,
  },
}


-- «ELispHF» (to ".ELispHF")
-- (find-es "lua5" "ELispHF")
-- (find-es "lua5" "ELispHF-tests")
-- An ELispHF object holds an "elisp hyperlink function", that when
-- called produces an ElispH object.
--
ELispHF = Class {
  type    = "ELispHF",
  newangg = function (head, d, suffix)
      return ELispHF {head=head, d=d, suffix=suffix, f="angg"}
    end,
  newintro = function (head)
      return ELispHF {head=head, f="intro"}
    end,
  newnode = function (head, c, manual)
      return ELispHF {head=head, c=c, manual=manual, f="node"}
    end,
  __tostring = function (ehf) return mytabletostring(ehf) end,
  __call = function (ehf, ...) return ehf[ehf.f](ehf, ...) end,
  __index = {
    angg = function (ehf, a, b, c)
        local target = suffixing(ehf.d..(a or ""), ehf.suffix, b)
        return ELispH {intro="eev-quick#9", target=target}
      end,
    intro = function (ehf, a)
        local ei = EevIntro.fromheadposspec(ehf.head, a)
        return ELispH {intro=ei.stem, target=ei:url()}
        -- return ELispH {intro=ei:short(), target=ei:url()}
      end,
    node = function (ehf, a)
        local manual, section = ehf.manual, a
        local target = ELispInfo{}:mstohtml(manual, section)
        return ELispH {intro="eev-quick#9.2", target=target}
      end,
  },
}

_EHF = VerticalTable {}

code_c_d_angg = function (c, d, suffix)
    local find_c     = "find-"..c
    local find_cfile = "find-"..c.."file"
    _EHF[find_c    ] = ELispHF.newangg(find_c, d, suffix or ".html")
    _EHF[find_cfile] = ELispHF.newangg(find_c, d, ".html")
  end

-- (find-blogme3 "angglisp.lua" "code_c_m_b_s")
-- (find-angg "LUA/lua50init.lua" "ELispHF")
-- (find-es "blogme" "code_c_m_b")
infomanual_basedir = VerticalTable {}

code_c_m_b = function (c, manual, basedir)
    infomanual_basedir[manual] = basedir
    local find_cnode = "find-"..c.."node"
    _EHF[find_cnode] = ELispHF.newnode(find_cnode, c, manual)
  end




-- «getsexp» (to ".getsexp")
-- (find-es "lua5" "getsexp")
-- (find-blogme3 "sexp.lua" "getsexp")
-- Version: 2019jan08.
-- A low-level function that splits a line into a sexp, a skel, and other stuff.
-- If    str  = 'Hello  (find-xpdfpage "~/LATEX/foo.pdf" (+ 2 3))'
-- then  sexp =        '(find-xpdfpage "~/LATEX/foo.pdf" (+ 2 3))',
--       skel =        '(find-xpdfpage "_______________" (_____))',
--       head =         'find-xpdfpage',
--       left = 'Hello '.
getsexp = function (str)
    if str:sub(-1) ~= ")" then return end
    local rep = string.rep
    local simpq = function (s) return '"'..rep("_", #s-2)..'"' end  -- simplify '"'s
    local simpp = function (s) return '('..rep("_", #s-2)..')' end  -- simplify parens
    local leks = str:gsub("\\.", "__"):reverse():gsub('"[^"]*"', simpq):match("^%b)(")
    if not leks then return end
    local skel = leks:reverse()
    local sexp = str:sub(-#skel)
    local head = sexp:match("^%(([^ ()\"]+)")
    local skel = "(" .. skel:sub(2):gsub("%b()", simpp)
    local left = str:sub(1, -1-#skel)
    return sexp, head, skel, left
  end

-- «SexpSkel» (to ".SexpSkel")
-- (find-es "lua5" "SexpSkel")
-- (find-es "lua5" "SexpSkel-test")
-- A user-friendly class based on getsexp with a nice printing function.
SexpSkel = Class {
  type    = "SexpSkel",
  fromline = function (line)
      local str,right = line:match("^(.-%))([%s]*)$")
      if not str then return SexpSkel {line=line} end
      local sexp,head,skel,left = getsexp(str)
      if not sexp then return SexpSkel {line=line} end
      return SexpSkel {line=line, left=left, sexp=sexp, right=right,
                       skel=skel, head=head}
    end,
  __tostring = function (ss)
      if not ss.sexp then return ss.line.."\n[no sexp]" end
      local spacify = function (s, c) return string.rep(c or " ", #s) end
      local left0  = spacify(ss.left)
      local right0 = spacify(ss.right, ".")
      return ss.line                .."\n"..
             left0..ss.sexp..right0 .."\n"..
             left0..ss.skel         .."\n"..
             left0.." "..ss.head
    end,
  __index = {
    splitsexp = function (ss)
        local sexpmid = ss.sexp:sub(2, -2)   -- without the '(' and the ')'
        local skelmid = ss.skel:sub(2, -2)   -- without the '(' and the ')'
        local A = {}
        local f = function (p0, p1)                 -- positions from skelmid
            table.insert(A, sexpmid:sub(p0, p1-1))  -- substring from sexpmid
            -- PP(sexpmid:sub(p0, p1-1), skelmid:sub(p0, p1-1))
          end
        skelmid:gsub("()[^%s]+()", f)
        return A
      end,
    parsestrargs = function (ss)
        local A = ss:splitsexp()
        local f = function (str) return str and str:match("^\"(.*)\"$") end
        return f(A[2]), f(A[3]), f(A[4])
      end,
    parseq = function (ss)
        local headpat = "("..string.rep(".", #ss.head)..")"
        local qppat   = "(\"?%))"   -- optional last quote, closing parenthesis
        local a,head,b,qp  = ss.sexp:match("^(.)"..headpat.."(.-)"..qppat.."$")
        -- print(table.concat({a,head,b,qp}, "|"))
        return a,head,b,qp
      end,
    --
    -- (find-es "lua5" "SexpSkel")
    -- Interface with ELispH and ELispHF:
    ehtosexphtml = function (ss, eh, hzer)
        return eh:sexphtml(hzer, ss:parseq())
      end,
    ehftoeh = function (ss, ehf)
        return ehf(ss:parsestrargs()) end,
    toehf = function (ss)
        return _EHF[ss.head] end,
    toeh = function (ss)
        local ehf = ss:toehf(); return ehf and ss:ehftoeh(ehf)
      end,
    totarget = function (ss)
        local eh = ss:toeh(); return eh and eh:gettarget()
      end,
    tohelp = function (ss)
        local eh = ss:toeh(); return eh and eh:gethelp()
      end,
    tosexphtml = function (ss, hzer)
        local eh = ss:toeh(); return eh and ss:ehtosexphtml(eh, hzer)
      end,
  },
}



-- «ELispInfo» (to ".ELispInfo")
-- (find-es "lua5"  "ELispInfo")
-- (find-blogme3 "sexp.lua" "find-xxxnodes")
ELispInfo = Class {
  type = "ELispInfo",
  new  = function (c, manual, basedir)
      infomanual_basedir[manual] = basedir
      return ELispInfo {c=c, manual=manual}
    end,
  __index = {
    -- convert [s]ection name to [h]tml
    shre    = "([-'/ &])",
    shtable = {["-"] = "_002d", ["'"] = "_0027", ["/"] = "_002f",
               [" "] = "-",     ["&"] = "-"},
    shexpand = function (eli, section)
        return section:gsub("%s+", " "):gsub(eli.shre, eli.shtable)
      end,
    --
    -- convert a pair (manual, section) to html
    mstohtml = function (eli, manual, section)
        if not manual or not section then return end
        local basedir = infomanual_basedir[manual]
        if not basedir then return end
        local sectionh = eli:shexpand(section)
        return basedir..sectionh..".html"
      end,
    -- a "nodename" is a string like "(libc)I/O Overview"
    nodenametohtml = function (eli, nodename)
        if not nodename then return end
        local manual, section = string.match(nodename, "^%(([^()]+)%)(.*)$")
        return eli:mstohtml(manual, section)
      end,
    --
    -- -- convert a section name to html
    -- stohtml = function (eli, section)
    --     return eli:mstohtml(eli.manual, section)
    --   end,
    -- -- convert a (manual, section) pair or a section to an ELispH
    -- mstoeh = function (eli, manual, section)
    --     return ELispH {intro="eev-quick#3", target=eli:mstohtml(manual, section)}
    --   end,
    -- stoeh = function (eli, section)
    --     return ELispH {intro="eev-quick#9.2", target=eli:stohtml(section)}
    --   end,
    --
  },
}




-- _E = {}
-- _E["to"] = ElispHF {intro="anchors", calctarget=calctarget_to}
-- _E["find-angg"] = ElispHF {intro="anchors", d=""}

-- «getsexpskel» (to ".getsexpskel")
-- Olbsolete.
-- Algorithm and tests: (find-es "lua5" "getsexpskel")
--
-- getsexpskel = function (str)
--     if str:sub(-1) ~= ")" then return end
--     local f = function (s) return '"'..string.rep("_", #s-2)..'"' end
--     local g = function (s) return ')'..string.rep("_", #s-2)..'(' end
--     local str2 = str:gsub("\\.", "__")      -- backslash+c -> __
--     local str3 = str2:reverse()
--     local str4 = str3:gsub('"[^"]*"', f)
--     local skel1 = str4:match("%b)(");    if not skel1 then return end
--     local skel2 = skel1:sub(2, -2):gsub("%b)(", g)
--     local skel3 = skel2:reverse()
--     return skel3
--   end

-- «SexpLine» (to ".SexpLine")
-- Obsolete.
-- Tests: (find-es "lua5" "SexpLine")
-- This was intended to replace some parts of: (find-blogme3 "escripts.lua")
--
-- SexpLine = Class {
--   type = "SexpLine",
--   from = function (src)
--       return SexpLine {src=src, skel=getsexpskel(src)}
--     end,
--   __tostring = function (sl) return mytabletostring(sl) end,
--   __index = {
--     skelf = function (sl) return sl.skel:match"^(%S+)" end,
--     split = function (sl)
--         local f       = sl:skelf()
--         local len     = #sl.src
--         local lensexp = #sl.skel + 2
--         local lena    = len - lensexp
--         local lenb    = 1
--         local lenc    = #f
--         local lene    = (sl.src:sub(-2, -2) == "\"") and 2 or 1
--         local lend    = len - lena - lenb - lenc - lene
--         sl.a = sl.src:sub(1, lena)
--         sl.b = "("
--         sl.c = f
--         sl.d = sl.src:sub(lena + lenb + lenc + 1, lena + lenb + lenc + lend)
--         sl.e = sl.src:sub(-lene)
--         local p1, p2 = sl.skel:match"^%S+%s+()%S+()"
--         if p1 then
--           local offset = lena + 1
--           sl.arg1 = sl.src:sub(offset + p1, offset + p2):match"^\"(.*)\"$"
--         end
--         return sl
--       end,
--     splitt = function (sl)    -- for tests
--         return sl.a.."|"..sl.b.."|"..sl.c.."|"..sl.d.."|"..sl.e
--       end,
--     splitsexp = function (sl)
--         sl.nth = {}
--         for p1,p2 in sl.skel:gmatch("()%S+()") do
--           local b, e = #sl.a + 1 + p1, #sl.a + p2
--           local raw = sl.src:sub(b, e)
--           local str = raw:match"^\"(.*)\"$"
--           table.insert(sl.nth, {b=b, e=e, raw=raw, str=str})
--         end
--         return sl
--       end,
--     n      = function (sl)    return #sl.nth end,
--     rawarg = function (sl, n) return (sl.nth[n] or {}).raw end,
--     arg    = function (sl, n) return (sl.nth[n] or {}).str end,
--     --
--     q = function (sl, body) return body end,
--     r = function (sl, url, body)
--         return url and format('<a href="%s">%s</a>', url, body) or body
--       end,
--     sethtml = function (sl)
--         sl.f        = sl.skel and sl:skelf()
--         sl.ef       = sl.f and _E[sl.f]
--         if not sl.ef then
--           sl.html   = sl:q(sl.src)
--         else
--           sl:split()
--           sl:splitsexp()
--           sl.help     = sl.ef:calchelp()
--           sl.target   = sl.ef:calctarget(sl:arg(2), sl:arg(3))
--           sl.sexphtml = sl.b..
--                         sl:r(sl.help, sl.c)..
--                         sl:q(sl.d)..
--                         sl:r(sl.target, sl.e)
--           sl.html     = sl:q(sl.a) .. sl.sexphtml
--         end
--         return sl
--       end,
--   },
-- }






-- «Set» (to ".Set")
Set = Class {
  type    = "Set",
  new = function () return Set {_={}} end,
  from = function (L) return Set.fromarray(L) end,
  fromarray = function (L)
      local C = Set.new()
      for i,v in ipairs(L) do C._[v]=v end
      return C
    end,
  __add = function (A, B)   -- union
      local C = Set.new()
      for k,v in pairs(A._) do C._[k]=v end
      for k,v in pairs(B._) do C._[k]=v end
      return C
    end,
  __sub = function (A, B)   -- difference
      local C = Set.new()
      for k,v in pairs(A._) do C._[k]=v end
      for k,v in pairs(B._) do C._[k]=nil end
      return C
    end,
  __mul = function (A, B)     -- intersection
      local C = Set.new()
      for k,v in pairs(A._) do if B._[k] then C._[k]=v end end
      return C
    end,
  __len = function (A) print"!" return #(keys(A._)) end,  -- number of elements
  __tostring = function (A)
      return "(Set with "..A:n().." elements)"
    end,
  --
  -- Methods
  __index = {
    has = function (A, k) return A._[k] end,
    n   = function (A) return #keys(A._) end,
    k   = function (A) return  keys(A._) end,
    ks  = function (A) return sorted(keys(A._)) end,
    ksc = function (A, sep) return table.concat(A:ks(), sep or "\n") end,
    gen = function (A)
        return cow(function ()
            for i,v in ipairs(A:ks()) do coy(v) end
          end)
      end,
    add = function (A, key, val)
        A._[key] = val or key
        return A
      end,
    del = function (A, key)
        A._[key] = nil
        return A
      end,
  },
}


-- «SetL» (to ".SetL")
-- For the new version of ydb. Work in progress.
-- Some tests: (find-fline "~/lakhesys/TODO" "SetL =")
--             (find-es "lua5" "SetL")

SetL = Class {
  type = "SetL",
  new  = function () return SetL {keys={}, list={}} end,
  from = function (L) return Set.fromarray(L) end,
  fromarray = function (L)
      local C = Set.new()
      for i,k in ipairs(L) do C:add(k) end
      return C
    end,
  __len = function (setl) return setl:n() end,
  __tostring = function (setl)
      return format("(SetL with %d elements)", setl:n())
    end,
  __add = function (A, B)   -- union
      local C = SetL:new()
      for k,v in A:gen() do C:add(k, v) end
      for k,v in B:gen() do C:add(k, v) end
      return C
    end,
  __mul = function (A, B)   -- intersection
      local C = SetL:new()
      for k,v in A:gen() do if B:has(k) then C:add(k, v) end end
      return C
    end,
  __sub = function (A, B)   -- difference
      local C = SetL.new()
      for k,v in A:gen() do if not B:has(k) then C:add(k, v) end end
      return C
    end,
  --
  -- Methods
  __index = {
    has = function (setl, key) return setl.keys[key] end,
    val = function (setl, key) return setl.keys[key] end,
    n   = function (setl) return #setl.list end,
    k   = function (setl) return setl.list end,
    ks  = function (setl) return sorted(keys(setl.keys)) end,
    ksc = function (setl, sep) return table.concat(setl:ks(), sep or "\n") end,
    gen = function (setl) return cow(function ()
        for i,k in ipairs(setl.list) do coy(k, setl:val(k)) end
      end) end,
    add = function (setl, key, val)
        if not setl:has(key) then
          setl.keys[key] = val or key
          table.insert(setl.list, key)
        end
        return setl
      end,
  },
}



-- «fsize» (to ".fsize")
-- (find-es "lua5" "lua-posix-wheezy")
-- require "posix"
readlink = function (fname)
    while posix.readlink(fname) do fname = posix.readlink(fname) end
    return fname
  end
fsize = function (fname)
    return posix.stat(fname).size
  end
roundblock = function (size, blocksize)
    local m = math.fmod(size, blocksize)
    if m ~= 0 then size = size - m + blocksize end
    return size
  end
fsizeb = function (fname, blocksize)
    return roundblock(fsize(readlink(fname)), blocksize or 8192)
  end

ydb_sort = function (bigstr)
    local lines = splitlines(bigstr)
    local ord   = {}
    local lt    = function (li1, li2) return ord[li1] < ord[li2] end
    for _,li in ipairs(lines) do
      ord[li] = li:gsub("http://www.youtube.com/watch[^ ]+", "")
    end
    return table.concat(sorted(lines, lt), "\n")
  end
ydb_sort1 = function () print(ydb_sort(io.read("*a"))) end
--[[
--]]


-- «loaddednat6» (to ".loaddednat6")
-- loaddednat6 = function ()
--     -- dednat6dir = "/home/edrx/dednat6/"     -- (find-dn6 "")
--     dednat6dir = os.getenv"HOME".."/dednat6/" -- (find-dn6 "")
--     dofile(dednat6dir.."dednat6.lua")         -- (find-dn6 "dednat6.lua")
--   end
loaddednat6 = function (dir)
    dednat6dir = ee_expand(dir or "~/LATEX/dednat6/") -- (find-dn6 "")
    dofile(dednat6dir.."dednat6.lua")                 -- (find-dn6 "dednat6.lua")
  end

-- «loadfbcache2» (to ".loadfbcache2")
loadfbcache2 = function ()
    chdir "~/fbcache/"      -- (find-fbcache "")
    dofile "fbcache2.lua"   -- (find-fbcache "fbcache2.lua")
  end

-- «loadluarocks» (to ".loadluarocks")
-- (find-es "lua5" "luarocks.loader")
-- (find-es "lua5" "luarocks-interactively")
-- (find-fline "/usr/bin/luarocks")
loadluarocks = function ()
    package.path = "/usr/share/lua/5.1//?.lua;/usr/share/lua/5.1//?/init.lua;"..package.path
    command_line = require("luarocks.command_line")
    program_name = "luarocks"
    program_description = "LuaRocks main command-line interface"
    commands          = {}
    commands.help     = require("luarocks.help")
    commands.pack     = require("luarocks.pack")
    commands.unpack   = require("luarocks.unpack")
    commands.build    = require("luarocks.build")
    commands.install  = require("luarocks.install")
    commands.search   = require("luarocks.search")
    commands.list     = require("luarocks.list")
    commands.remove   = require("luarocks.remove")
    commands.make     = require("luarocks.make")
    commands.download = require("luarocks.download")
    commands.path     = require("luarocks.path")
    commands.show     = require("luarocks.show")
    commands.new_version = require("luarocks.new_version")
  end


-- «capitalize» (to ".capitalize")
-- Capitalize Brazilian names.
capitalize = function (text, smallwords)
    smallwords = smallwords or Set.fromarray(split("de da do das dos e"))
    local capitalize1 = function (word)
        word = word:lower()
        if smallwords:has(word) then return word end
        return word:sub(1,1):upper()..word:sub(2):lower()
      end
    return (text:gsub("%a+", capitalize1))
  end

-- «getinscritos» (to ".getinscritos")
-- (find-angg ".emacs" "getinscritos")
getinscrito = function (li)
    local mat,cpf,nome,email = li:match("^%s*(%d+)%s+(%d+)%s+(.-)%s%s+(%S+)")
    if not mat then return end
    local Nome = capitalize(nome)
    local dest = format("%-60s <%s>,", '"'..Nome..'"', email)
    local inscrito = {li=li, mat=mat, cpf=cpf, nome=nome, email=email,
      Nome=Nome, dest=dest}
    return inscrito
  end
getinscritos = function ()
    for li in io.lines() do
      if getinscrito(li) then print(getinscrito(li).dest) end
    end
  end


-- «trailing-zeroes» (to ".trailing-zeroes")
-- «pformat» (to ".pformat")
-- (find-es "lua5" "string.format")
-- (find-es "lua5" "pformat")
trunc0 = function (str) return str:reverse():gsub("^0*%.?", ""):reverse() end
truncn = function (n) return trunc0(string.format("%.3f", n)) end
myntos = function (n) return trunc0(string.format("%.3f", n)) end
pformat1 = function (o)
    if type(o) == "number" then return truncn(o) end
    return tostring(o)
  end
pformatargs = function (...)
    local n = select("#", ...)
    return unpack(map(pformat1, {...}, n), 1, n)
  end
pformat = function (fmt, ...)
    return format(fmt, pformatargs(...))
  end
pformatexpr = function (exprstr)
    return table.concat(map(pformat1, {expr(exprstr)}))
  end




-- «findxxxpdf_parse» (to ".findxxxpdf_parse")
-- (find-angg "LUA/book-index.lua")
-- (find-angg ".emacs" "book-index")
--
findxxxpdf_parse = function (li, stem, adj)
    li = untabify(li)
    li = li:gsub(" [ .]* ", " ")
    li = li:match("^ *(.-) *$")
    local str,p = li:match("^(.*) ([0-9]+)$")
    if str then
      if stem and adj then
        printf(";; (find-%spage (+ %d %d) \"%s\")\n", stem, adj, p, str)
      elseif str and (not adj) then
        printf(";; (find-%spage %d \"%s\")\n",        stem,      p, str)
      end
    end
    return str,p
  end
findxxxpdf_parse_file = function (fname, stem, adj)
    for _,li in ipairs(splitlines(ee_readfile(fname))) do
      findxxxpdf_parse(li, stem, adj)
    end
  end





-- Local Variables:
-- coding:               utf-8-unix
-- End:
