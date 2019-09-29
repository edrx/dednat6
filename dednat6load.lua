#!/usr/bin/env lua5.1
-- This is the file "dednat6load.lua" of Dednat6.
--   http://angg.twu.net/LATEX/dednat6load.lua.html
--   http://angg.twu.net/LATEX/dednat6load.lua
--                (find-LATEX "dednat6load.lua")
--
-- The homepage of dednat6 is:
--
--    http://angg.twu.net/dednat6.html
--
-- The usual way to load dednat6 is from Lua(La)TeX, like this
-- (look at the indented lines!):
--
--   \documentclass[oneside]{article}
--     \usepackage{proof}   % For derivation trees ("%:" lines)
--     \input diagxy        % For 2D diagrams ("%D" lines)
--     \xyoption{curve}     % For the ".curve=" feature in 2D diagrams
--   \begin{document}
--     \catcode`\^^J=10     % (find-es "luatex" "spurious-omega")
--     \directlua{dofile "dednat6load.lua"}
--     (...)
--   \end{document}
--
-- The first three indented lines load some packages that dednat6
-- uses, and that have to be loaded before the "\begin{document}". The
-- "\catcode`\^^J=10" is a workaround for a quirk in lualatex, and the
-- line "\directlua{dofile "dednat6load.lua"}" runs this file, that
-- loads all the rest of dednat6 and makes latex able to interpret the
-- "\pu" command. See the section 3 ("3. Semi-preprocessors") of the
-- TUGBoat article about dednat6:
--
--   https://tug.org/TUGboat/tb39-3/tb123ochs-dednat.pdf
--   http://angg.twu.net/dednat6/2018tugboat-rev2.pdf
--
-- That section ends with this paragraph:
--
--   `\pu' means "process until" - or, more precisely, _make dednat6
--   process everything until this point that it hasn't processed
--   yet_. The first \pu [in the example] processes the lines 1--26 of
--   foo.tex, and "outputs" - i.e., sends to TeX - the first
--   \defded{my-tree}; the second \pu processes the lines 28--34 of
--   foo.tex, and `outputs' the second \defded{my-tree}. Thus, it is
--   not technically true that TeX and dednat6 process foo.tex in
--   parallel; dednat6 goes later, and each \pu is a synchronization
--   point.
--
-- The _recommended_ way to use dednat6 is as a "semi-preprocessor" as
-- explained above, but this file also implements an _experimental
-- hack_ for when we have we have to use it as a "real" preprocessor
-- (as explained in the sections 1 and 3 of the article).


-- Load all the dednat6 modules.
-- Note the trick to "dednat6/" to package.path.
-- (find-dn6 "dednat6.lua")
-- (find-dn6 "dednat6.lua" "package.path" "dednat6dir")
dednat6dir = "dednat6/"            -- (find-dn6 "")
dofile(dednat6dir.."dednat6.lua")  -- (find-dn6 "dednat6.lua")
dofile(dednat6dir.."block.lua")    -- (find-dn6 "block.lua")


-- If dednat6load.lua is being run from lua(la)tex then we will have a
-- table called "tex". See:
--   (find-luatexrefpage (+ 4  11) "1 Basic TEX enhancements")
--   (find-luatexreftext (+ 4  11) "1 Basic TEX enhancements")
--   (find-luatexrefpage (+ 4  11)   "tex.enableprimitives")
--   (find-luatexreftext (+ 4  11)   "tex.enableprimitives")
--   (find-luatexrefpage (+ 4 160) "9.3 The tex library")
--   (find-luatexreftext (+ 4 160) "9.3 The tex library")
--
if tex then
  -- If tex is non-nil we behave in the default way, i.e., as a
  -- "semi-preprocessor". We run some initializations and return the
  -- control to luatex; then the calls to "\pu" will make dednat6
  -- process parts of the .tex file.
  -- See: (find-es "luatex" "status.filename")
  --      (find-dn6 "block.lua" "texfile0")
  --      (find-dn6 "output.lua" "output" "output_verbose =")
  --      (find-dn6 "preamble6.lua" "preamble1")
  --
  texfile0(status.filename)
  verbose()
  output(preamble1)
else
  -- If tex==nil then we're being run from a Lua interpreter outside
  -- of lua(la)tex. Process the command-line options according to the
  -- rules here:
  --   (find-dn6 "options6.lua")
  --   (find-dn6 "options6.lua" "dooptions_help")
  -- 
  -- (find-es "lua5" "setvbuf-stdout-stderr")
  io.stdout:setvbuf("no")
  dooptions(...)
end



