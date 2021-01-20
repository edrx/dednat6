#!/usr/bin/env lua5.1
-- This file:
-- http://angg.twu.net/dednat6/dednat6/dednat6.lua
-- http://angg.twu.net/dednat6/dednat6/dednat6.lua.html
--         (find-angg "dednat6/dednat6/dednat6.lua")
-- By Eduardo Ochs <eduardoochs@gmail.com>
-- Version: 2020nov17
--
-- This file adds "dednat6/" to the load path and loads all the
-- default modules of dednat6. See:
--   https://tug.org/TUGboat/tb39-3/tb123ochs-dednat.pdf
--   http://angg.twu.net/dednat6/tugboat-rev2.pdf
--   (find-LATEX "dednat6load.lua")


-- «.package.path»		(to "package.path")
-- «.luatex-require»		(to "luatex-require")
-- «.requires»			(to "requires")
-- «.utf8»			(to "utf8")
-- «.dooptions»			(to "dooptions")
-- «.run-tests-in-test-dir»	(to "run-tests-in-test-dir")




-- «package.path» (to ".package.path")
-- Add dednat6dir to package.path.
-- See: (find-es "lua5" "package.path")
--      (find-es "lua5" "add-to-package.path")
fnamedirectory    = function (fname) return fname:match"^(.*/)[^/]*$"  end
fnamenondirectory = function (fname) return fname:match     "([^/]*)$" end
dednat6dir        = dednat6dir or (arg and fnamedirectory(arg[0])) or ""
if dednat6dir ~= "" then package.path = dednat6dir.."?.lua;"..package.path end


-- «luatex-require» (to ".luatex-require")
-- If we're in Lua(La)TeX then make sure that require behaves luaish-ly enough
if tex then
  local require = function (stem)
      local fname = dednat6dir..stem..".lua"
      package.loaded[stem] = package.loaded[stem] or dofile(fname) or fname
    end
  --
  require "lualoader"   -- (find-dn6 "lualoader.lua")
  require "binloader"   -- (find-dn6 "binloader.lua")
  require "edrxlib"     -- (find-dn6 "edrxlib.lua")
end


-- «requires» (to ".requires")
-- (find-dn5file "build.lua" "stems = {")
--
-- Temporary, until I fix the package.searchers bug (2020nov06)
-- if true then require "edrxlib" end
-- if true then dofile "dednat6/edrxlib.lua" end
-- print(); REPL = Repl:new(); REPL:repl()



-- The four lowest-level modules (all independent):
require "eoo"          -- (find-dn6 "eoo.lua")
require "abbrevs"      -- (find-dn6 "abbrevs.lua")
require "parse"        -- (find-dn6 "parse.lua")
require "rect"         -- (find-dn6 "rect.lua")
require "stacks"       -- (find-dn6 "stacks.lua")

-- General functions to read and process ".tex" files:
require "output"       -- (find-dn6 "output.lua")
require "preamble6"    -- (find-dn6 "preamble6.lua")
require   "heads6"     -- (find-dn6 "heads6.lua")
-- require "texfile"   -- (find-dn6 "texfile.lua")
-- "texfile" was superseded by: (find-dn6 "block.lua")
-- See: (find-LATEXfile "dednat6load.lua" "block.lua")

-- Code for generating derivation trees from "%:" lines:
require "treetex"      -- (find-dn6 "treetex.lua")
require "treesegs"     -- (find-dn6 "treesegs.lua")

-- Code for generating diagxy diagrams from "%D" lines:
require "diagstacks"   -- (find-dn6 "diagstacks.lua")
require "diagtex"      -- (find-dn6 "diagtex.lua")
require "diagforth"    -- (find-dn6 "diagforth.lua")
require   "errors"     -- (find-dn6 "errors.lua")
require "diagmiddle"   -- (find-dn6 "diagmiddle.lua")

-- Code for generating diagrams with "\underbrace"s:
require "underbrace2d"  -- (find-dn6 "underbrace2d.lua")

-- Code for handling and drawing ZHAs:
require "picture"       -- (find-dn6 "picture.lua")
require "zhas"          -- (find-dn6 "zhas.lua")
require "zhaspecs"      -- (find-dn6 "zhaspecs.lua")
require "tcgs"          -- (find-dn6 "tcgs.lua")
require "luarects"      -- (find-dn6 "luarects.lua")

-- The REPL, for interaction (experimental):
-- require "luarepl"      -- (find-dn6 "luarepl.lua")
-- Superseded by:         -- (find-dn6 "edrxlib.lua" "Repl")

-- Obsolete modules:
-- require "wrap"       -- (find-dn5 "wrap.lua")
-- require "zha"        -- (find-dn5 "zha.lua")
-- require "zrect"      -- (find-dn5 "zrect.lua")
-- require "begriff"    -- (find-dn5 "begriff.lua")
-- require "zquotients" -- (find-dn6 "zquotients.lua")
-- require "underbrace" -- (find-dn6 "underbrace.lua")
-- Problem: istanbul-handouts.tex uses zrect!!!

-- «utf8» (to ".utf8")
-- (find-es "lua5" "utf8")
-- (find-angg "LUA/lua50init.lua" "strlen8")
-- (find-dn6 "parse.lua" "getword =")
getword_utf8 = getword

-- Support for command-line options.
-- This is only used when dednat6load.lua
-- is called as a standalone program.
-- See: (find-dednat6 "demo-preproc.tex")
require "options6"     -- (find-dn6 "options6.lua")

-- «dooptions» (to ".dooptions")
-- dooptions(...)




--[[
 «run-tests-in-test-dir» (to ".run-tests-in-test-dir")

 Copy the essential files from dednat6 to a test dir (/tmp/d6/)
 (eepitch-shell)
 (eepitch-kill)
 (eepitch-shell)
cd ~/dednat6/
(TZ=GMT date; date) | tee VERSION
cat dednat6.lua | grep "^ *require" | tr -d '"()'
cat dednat6.lua | grep "^ *require" | tr -d '"()' | awk '{print $5}' | tee /tmp/o
rm -Rv /tmp/d6/
mkdir  /tmp/d6/
mkdir  /tmp/d6/tests/
cp -v $(cat /tmp/o) dednat6.lua        /tmp/d6/
cp -v ~/LUA/lua50init.lua              /tmp/d6/edrxlib.lua
cp -v VERSION                          /tmp/d6/
cp -v tests/diagxy.tex tests/proof.sty /tmp/d6/tests/
cp -v tests/{0,2,3,4}.tex              /tmp/d6/tests/

# (find-dn6 "tests/")
# (find-fline "/tmp/d6/")

 Make /tmp/dednat6.zip
 (eepitch-shell)
 (eepitch-kill)
 (eepitch-shell)
# (find-sh "cd /tmp/d6/; find * | sort")
# (find-sh "cd /tmp/d6/; ls *.lua; ls tests/*")
DD="dednat6-$(date +%Y%m%d)"; echo $DD
rm -v /tmp/dednat6*.zip
rm -v /tmp/dednat6*.tgz
cd    /tmp/d6/
zip       /tmp/dednat6.zip VERSION *.lua tests/*
zip       /tmp/$DD.zip     VERSION *.lua tests/*
tar -cvzf /tmp/dednat6.tgz VERSION *.lua tests/*
tar -cvzf /tmp/$DD.tgz     VERSION *.lua tests/*

# (find-fline "/tmp/dednat6.zip")

 Run dednat6 in the test dir, check if everything works
 (eepitch-shell)
 (eepitch-kill)
 (eepitch-shell)
cd    /tmp/d6/tests/
lualatex 0.tex
lualatex 2.tex
lualatex 3.tex
lualatex 4.tex
# (find-fline "/tmp/d6/tests/")

 Upload
 (eepitch-shell)
 (eepitch-kill)
 (eepitch-shell)
DD="dednat6-$(date +%Y%m%d)"; echo $DD
cd /tmp/
laf       {dednat6,$DD}.{tgz,zip}
{
Scp-np -v {dednat6,$DD}.{tgz,zip} edrx@angg.twu.net:/home/edrx/slow_html/dednat6/
Scp-np -v {dednat6,$DD}.{tgz,zip} edrx@angg.twu.net:/home/edrx/public_html/dednat6/
cd /tmp/d6/tests/
Scp-np -v {0,2,3,4}.pdf           edrx@angg.twu.net:/home/edrx/slow_html/dednat6/tests/
Scp-np -v {0,2,3,4}.pdf           edrx@angg.twu.net:/home/edrx/public_html/dednat6/tests/
}



 Old & obsolete
 (eepitch-shell)
 (eepitch-kill)
 (eepitch-shell)
cd ~/dednat6/
cat dednat6.lua | grep "^ *require" | tr -d '"()' | awk '{print $5}' | tee /tmp/o
rm -Rv   /tmp/d6/
mkdir -p /tmp/d6/dednat6/
cp -v $(cat /tmp/o) dednat6.lua /tmp/d6/dednat6/
cp -v ~/LUA/lua50init.lua       /tmp/d6/dednat6/edrxlib.lua

(TZ=GMT date; date) | tee VERSION
rm -v     /tmp/dednat6-test*
tar -cvzf /tmp/dednat6-test.tgz *
zip -r    /tmp/dednat6-test.zip *

lualatex istanbul-july.tex
export LUA_INIT=
lualatex istanbul-july.tex

cd /tmp/
Scp-np -v dednat6-test.tgz dednat6-test.zip edrx@angg.twu.net:/home/edrx/slow_html/dednat6/
Scp-np -v dednat6-test.tgz dednat6-test.zip edrx@angg.twu.net:/home/edrx/public_html/dednat6/
# (find-twusfile "dednat6/")
# (find-angg ".zshrc" "Twus-and-Twup")

# (find-fline "/tmp/" "dednat6-test")
# (find-fline "/tmp/dednat6-test.tgz")
# (find-fline "/tmp/dednat6-test.zip")

--]]


--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "dednat6.lua"
PP(keys(package))
PP(keys(package.loaded))

-- (find-dn6 "options.lua")
-- (find-dn6 "dednat6.lua")
-- (find-dn6grep "grep -nH -e '_O = _O or {}' *")

--]]


-- Local Variables:
-- coding: utf-8-unix
-- End:
