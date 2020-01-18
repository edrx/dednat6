-- This file:
-- http://angg.twu.net/dednat6/dednat6/underbrace.lua
-- http://angg.twu.net/dednat6/dednat6/underbrace.lua.html
--         (find-angg "dednat6/dednat6/underbrace.lua")
--
-- This is obsolete, and has been superseded by:
-- http://angg.twu.net/dednat6/dednat6/underbrace2d.lua
-- http://angg.twu.net/dednat6/dednat6/underbrace2d.lua.html
--         (find-angg "dednat6/dednat6/underbrace2d.lua")
--
-- This was a quick hack that I used in early versions of my paper
-- "Planar Heyting Algebras for Children", but I replaced all code
-- that used this by code that uses underbrace2d.
--
--
-- The easiest way to work with user-given expressions in dednat6 is
-- to build them as syntactic trees using a stack-based, Forth-like
-- language. We want to generate two kinds of output from these
-- expressions: 1) 2D ascii diagrams, 2) LaTeX output, mainly for
-- "underbrace structures" like this one:
--
--    P & Q -> P
--   \-/ \-/  \-/
--    0   1    0
--   \-----/
--      0
--   \----------/
--          1
--
-- THIS IS NOT USED "OFICIALLY" YET, because the class Stack defined
-- here may conflict with: (find-dn6 "diagstacks.lua" "Stack")
-- See:
--   (find-ist "-handouts.tex" "brute-force")
--   (find-ist "all.lua" "Stack")


-- «.synttotex»		(to "synttotex")
-- «.ubs»		(to "ubs")
-- «.ubs-tests»		(to "ubs-tests")

require "stacks"   -- (find-dn6 "stacks.lua")
require "rect"     -- (find-dn6 "rect.lua")

-- «synttotex» (to ".synttotex")
-- This is used by ubstex to generate LaTeX from a tree object.
synttotex = function (o)
    if type(o) == "string" then return o end
    if type(o) == "table" then
      return (o.tex:gsub("<([%d])>", function (n) return synttotex(o[n+0]) end))
    end
    error()
  end

--        _         
--  _   _| |__  ___ 
-- | | | | '_ \/ __|
-- | |_| | |_) \__ \
--  \__,_|_.__/|___/
--                  
-- «ubs» (to ".ubs")
ubs_doword = function (s, word)
    local o = function ()    return s:pop() end
    local u = function (obj) return s:push(obj) end
    if     word == "()"  then u {"(", o(), ")", tex="(<2>)"}
    elseif word == "u"   then u {[0]=o(), o(), tex="\\underbrace{\n<1>\n}_{<0>}"}
    elseif word == "bin" then u {[2]=o(), [3]=o(), [1]=o(), tex="<1> <2>\n <3>"}
    elseif word == "Bin" then u {[3]=o(), [2]=o(), [1]=o(), tex="<1> <2>\n <3>"}
    elseif word == "pre" then u {[1]=o(), [2]=o(), tex="<1> <2>"}
    elseif word == "Pre" then u {[2]=o(), [1]=o(), tex="<1> <2>"}
    elseif word == "def" then u {[1]=o(), [2]=o(), tex="\\def\\<1>{<2>}"}
    elseif word == "output" then output(synttotex(s:pick(0)))
    else   u(word)
    end
    return s
  end
ubs0 = function (bigstr) return Stack.dowords(ubs_doword, bigstr) end
ubstree = function (bigstr) return synttorect(ubs0(bigstr)) end
ubstex  = function (bigstr) return synttotex (ubs0(bigstr)) end

ubs = function (bigstr) return ubstex(bigstr) end  -- quiet
ubs = function (bigstr)
    print(ubstree(bigstr)); print()        -- verbose behavior: print the tree
    return ubstex(bigstr)                  -- and return the LaTeX code
  end
ubs = function (bigstr)
    local syntree = ubs0(bigstr)
    print(synttorect(syntree)); print()    -- verbose behavior: print the tree
    return synttotex(syntree)               -- and return the LaTeX code
  end


--[==[
-- «ubs-tests» (to ".ubs-tests")
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "underbrace.lua"
--
-- (find-istfile "1.org" "Some non-tautologies: DeMorgan")
--
-- !(P  & Q)->(! P v  ! Q)
--   10  01      10    01
--     00      02    20
-- 32              22
--          22
--
= ubs "P Q \\& bin () 2 + bin"
= ubs [[
  P 10 u   Q 01 u   \& bin 00 u    () \neg pre 32 u
  P 10 u   \neg pre 02 u   Q 01 u \neg pre 20 u   \lor bin 22 u ()
  \to bin 22 u
]]

PP(ubs("a () ()"))
= synttorect(ubs("a () ()"))
= synttorect(ubs([[ P 10 u ]]))
= synttorect(ubs([[ P 10 u Q 01 u \& bin ]]))
= synttorect(ubs([[ P 10 u Q 01 u \& bin 00 u    () \neg pre 32 u ]]))
= ubs [[ P 10 u Q 01 u \& bin 00 u    () \neg pre 32 u ]]

= ubstree [[ P 0 u Q 1 u \& bin 0 u ]] 
= ubstree  [[ P 0 u   Q 1 u   \& bin 0 u   P 0 u   -> bin 1 u ]] 
= ubs      [[ P 0 u   Q 1 u   \& bin 0 u   P 0 u   -> bin 1 u ]] 

 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "underbrace.lua"
-- (P <= Q & R) <-> (P <= Q) & (P <= R)
--       21 12           21         12
--       \---/       \----/     \----/
--         ?          \ra        \rb
-- \---------/      \-----------------/
--    \rd                   \rc
--
ubs_brute_force_and
= ubs [[
  P   Q 21 u   R 12 u  \& bin ? u   \le bin \rd u ()
  P   Q 21 u   \le bin \ra u ()
  P   R 21 u   \le bin \rb u ()
  \& bin \rc u
  \bij bin
]]
= ubs_brute_force_and

ubs_brute_force_imp
= ubs [[
  P   Q 21 u   R 12 u   \to bin ? u    \le bin \Rc u ()
  P   Q 21 u   \land bin \Ra u   R 12 u   \le bin \Rb u ()
  \bij bin
]]

 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "underbrace.lua"
output = function (str) print("<<"..str..">>") end
ubs0  [[ P 10 u   Q 01 u   \& bin 00 u   Foo def   output ]]
ubs   [[ P 10 u   Q 01 u   \& bin 00 u   Foo def   output ]]
= ubs [[ P 10 u   Q 01 u   \& bin 00 u   Foo def   output ]]

--]==]











-- Local Variables:
-- coding: utf-8-unix
-- End:

