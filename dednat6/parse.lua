-- parse.lua: functions to parse words keeping track of the column.
-- These functions are used to parse tree segments (in "%:" lines)
--   and 2D grids (in both "%D 2Dx" and "%D 2D" lines).
-- This file:
--   http://angg.twu.net/dednat6/parse.lua.html
--   http://angg.twu.net/dednat6/parse.lua
--                    (find-dn6 "parse.lua")
-- Author: Eduardo Ochs <eduardoochs@gmail.com>
-- Version: 2015aug22
-- License: GPL3
--
-- Based on:
-- http://angg.twu.net/miniforth-article.html
-- http://angg.twu.net/miniforth/miniforth-article.pdf

-- «.getword»	(to "getword")



setsubj = function (subj_, pos_)
    subj = subj_
    pos  = pos_ or 3
    startcol, endcol = 1, pos
  end

-- «getword» (to ".getword")
-- (find-dn5file "parse.lua" "getword =")
-- (find-dn5 "dednat6.lua" "utf8")
getword = function ()
    local spaces, word_, newpos = subj:match("( *)([^ ]+)()", pos)
    if spaces then
      startcol = endcol + #spaces
      endcol   = endcol + #spaces + word_:len8()   -- UTF-8
      word     = word_
      pos      = newpos
      return word
    end
  end

getwordasluaexpr = function ()
    local expr = getword()
    local code = "return "..expr
    return assert(loadstring(code))()
  end

getrestofline = function ()
    local spaces, word_, newpos = subj:match("( *)(.*)()", pos)
    if spaces then
      startcol = endcol + #spaces
      endcol   = endcol + #spaces + #word_   -- change for UTF-8
      word     = word_
      pos      = newpos
      return word
    end
  end



--[==[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "parse.lua"
run = function (str)
    setsubj(str)
    while getword() do PP(startcol, endcol, pos, word) end
  end
run "%Dfoo bar  plic"

 (ex "parse")

--]==]

-- Local Variables:
-- coding:             raw-text-unix
-- ee-anchor-format:   "«%s»"
-- End:
