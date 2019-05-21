-- luarepl.lua: load Rob Hoelz's lua-repl.
-- This file:
-- http://angg.twu.net/LATEX/dednat6/luarepl.lua
-- http://angg.twu.net/LATEX/dednat6/luarepl.lua.html
--  (find-angg        "LATEX/dednat6/luarepl.lua")
--
-- The e-script that downloads lua-repl and copies some of its files in the
-- dednat6 tree is here:
--   (find-es "lua5" "luarepl-2017")
--   http://angg.twu.net/e/lua5.e.html#luarepl-2017
--
-- Tests:
--   From Lua (see the test block below):
--     (find-angg "LUA/lua50init.lua" "loaddednat6")
--     (find-angg "LUA/lua50init.lua" "loadluarepl")
--   From LuaLaTeX:
--     (find-es "lua5" "luarepl-2017-latex")
--     (find-es "luatex" "show")
--     (find-LATEXfile "2017planar-has-1.tex" "\\repl")
--
-- (find-anggsh "find LATEX/dednat6/ | grep rep")
-- (find-fline "~/LATEX/dednat6/lua-repl/")

luarepl = function () print(); print(); sync:run() end
return loadluarepl(dednat6dir.."lua-repl/")


--[==[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
loaddednat6("~/LATEX/dednat6/")
= dednat6dir
loadluarepl(dednat6dir.."lua-repl/")
= repl

 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
loaddednat6("~/LATEX/dednat6/")
= require "luarepl"
= require "luarepl"
sync:run()

 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
loaddednat6("~/LATEX/dednat6/")
luarepl()

--]==]

