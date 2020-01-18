-- options6.lua: process command-line options in standalone dednat6.
-- This file:
--   http://angg.twu.net/dednat6/dednat6/options.lua.html
--   http://angg.twu.net/dednat6/dednat6/options.lua
--           (find-angg "dednat6/dednat6/options.lua")
-- Author: Eduardo Ochs <eduardoochs@gmail.com>
-- Version: 2019may15
-- License: GPL3
--
-- Tests:
--   (find-es "dednat" "dednat6-dnt-from-lua")
--
-- Based on:
--   (find-dn5file "options.lua")
--   (find-dn5file "options6.lua")
--   (find-dn5file "options6.lua" "dooption_t =")
--   (find-dn5file "options6.lua" "dooptions =")
--   (find-blogme3 "options.lua" "dooptions")
--   (find-blogme3file "blogme3.lua" "dooptions(unpack(arg or {}))")
--   (find-blogme4 "options.lua")

-- See: (find-LATEX "2011ebl-slides.tex")
--      (find-LATEXfile "2011ebl-slides.tex" "dednat5 -t")
--      (find-dn6 "build.lua")

-- «.dooptions_help»	(to "dooptions_help")
-- «.dooptions_t»	(to "dooptions_t")
-- «.dooptions_4»	(to "dooptions_4")
-- «.dooptions»		(to "dooptions")



-- «dooptions_help»  (to ".dooptions_help")
dooptions_help = function ()
    print [[
At this moment dednat6load.lua can be called in
standalone mode in two ways:

  ./dednat6load.lua -4 somefile.tex
  ./dednat6load.lua -t somefile.tex

The way with "-4" behaves "as dednat4", i.e., "as a true
preprocessor", as explained in the section 2 of the TUGBoat article:
it creates a file "somefile.dnt" with the adequate headers.

The way with "-t" is a low-level version of "-4" that is mainly for
tests and debugging. You don't want to use it.
]]
    os.exit(1)
  end


-- «dooptions_t»  (to ".dooptions_t")
-- Low-level. Doesn't output the preamble, doesn't run write_dnt_file().
dooptions_t = function (fname)
    print("% Processing: "..fname)
    texfile0(fname)
    --
    tex = {print = function () end}
    output_quiet = function (str)
        -- tex.print(deletecomments(str))
        dnt_log = dnt_log..str.."\n"
      end
    --
    tf:processuntil(tf.j)
  end


-- «dooptions_4»  (to ".dooptions_4")
dooptions_4 = function (fname)
    print("% Processing: "..fname)
    texfile0(fname)
    --
    tex = {print = function () end}
    output_quiet = function (str)
        -- tex.print(deletecomments(str))
        dnt_log = dnt_log..str.."\n"
      end
    --
    output(preamble1)
    tf:processuntil(tf.j)
    write_dnt_file()
  end


-- «dooptions»  (to ".dooptions")
dooptions = function (arg1, arg2)
    if arg1 == "-t" then
      dooptions_t(arg2)
    elseif arg1 == "-4" then
      dooptions_4(arg2)
    else
      dooptions_help()
    end
  end






--[==[
 (eepitch-shell)
 (eepitch-kill)
 (eepitch-shell)
cd ~/LATEX/
./dednat6load.lua
./dednat6load.lua foo
./dednat6load.lua -t 
./dednat6load.lua -t 2019logicday.tex

--]==]


-- Local Variables:
-- coding:             utf-8-unix
-- End:
