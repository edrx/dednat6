-- This file:
-- http://angg.twu.net/dednat6/dednat6/underbrace2d.lua
-- http://angg.twu.net/dednat6/dednat6/underbrace2d.lua.html
--         (find-angg "dednat6/dednat6/underbrace2d.lua")
--
-- This module supersedes underbrace.lua, that used a stack language
-- to draw underbrace diagrams... this one uses a 2D ascii art syntax.
-- See this for an example:
--   http://angg.twu.net/dednat6/demo-underbrace.pdf
--   http://angg.twu.net/dednat6/demo-underbrace.tex
--   http://angg.twu.net/dednat6/demo-underbrace.tex.html
--
-- This is a hack that I wrote VERY quickly. It is badly written and
-- hard to debug when it yield errors! TODO: rewrite it cleanly.
--
-- Author and version: Eduardo Ochs <eduardoochs@gmail.com>, 2019dec08
-- License: GPL3

-- «.UB»	(to "UB")
-- «.UB-head»	(to "UB-head")
-- «.UB-tests»	(to "UB-tests")


--  _   _ ____     _   _           _           ____                     
-- | | | | __ )_  | | | |_ __   __| | ___ _ __| __ ) _ __ __ _  ___ ___ 
-- | | | |  _ (_) | | | | '_ \ / _` |/ _ \ '__|  _ \| '__/ _` |/ __/ _ \
-- | |_| | |_) |  | |_| | | | | (_| |  __/ |  | |_) | | | (_| | (_|  __/
--  \___/|____(_)  \___/|_| |_|\__,_|\___|_|  |____/|_|  \__,_|\___\___|
--                                                                      
-- «UB»  (to ".UB")
-- UB: a structure for interpreting UnderBrace diagrams.
--
UB = Class {
  type    = "UB",
  from = function (li)
      li = untabify8(li)
      local ub = UB {}
      -- (find-lua53manual "#pdf-utf8.charpattern")
      -- "[\0-\x7F\xC2-\xF4][\x80-\xBF]*"
      local pat = "[\1-\127\194-\244][\128-\191]*"
      local col = 1
      for c in li:gmatch(pat) do
        table.insert(ub, UB {L=col, R=col, c})
        col = col + 1
      end
      ub.L, ub.R = 1, #ub
      return ub
    end,
  fromlines = function (lines)
      lines = map(untabify8, lines)
      local ub = UB.from(lines[1])
      for i = 2,#lines,2 do ub:unds(lines[i], lines[i+1]) end
      return ub
    end,
  __tostring = function (ub)
      return mapconcat(function (i) return tostring(ub[i]) end, seq(1, #ub))
    end,
  __index = {
    tostring = function (ub) return tostring(ub) end,
    tolatex  = function (ub) return tostring(ub) end,
    defub    = function (ub, name)
        output(format("\\defub{%s}{%s}", name, ub:tolatex()))
      end,
    -- def = function (ub, name)
    --     return format("\\def\\%s{%s}", name, ub:tolatex())
    --   end,
    -- outputdef = function (ub, name) output(ub:def(name)) end,
    innerview = function (ub)
        local f = function (o)
            return format("%5s: \"%s\"", o.L.."-"..o.R, o[1])
          end
        return mapconcat(f, ub, "\n")
      end,
    --
    leftcol  = function (ub) return ub.L  end,
    rightcol = function (ub) return ub.R end,
    column_to_i = function (ub, col)
        for i=1,#ub do
          local a,b = ub[i]:leftcol(), ub[i]:rightcol()
          if a <= col and col <= b then return i end
        end
        return #ub
      end,
    columns_to_i_j_L_R_t = function (ub, col1, col2)
        local newub = UB {}
        local i = ub:column_to_i(col1)
        local j = ub:column_to_i(col2)
        local L,R = ub[i]:leftcol(), ub[j]:rightcol()
        local text = mapconcat(function (i) return tostring(ub[i]) end, seq(i, j))
        return i,j, L,R, text
      end,
    text_l_r = function (ub, l, r)
        local i,j, L,R, text = ub:columns_to_i_j_L_R_t(l, r-1)
        return text
      end,
    und = function (ub, col1, col2, undtext)
        local i,j, L,R, oldtext = ub:columns_to_i_j_L_R_t(col1, col2)
        local newtext = format("\\und{%s}{%s}", oldtext, undtext)
        local newub = UB {L=L, R=R, newtext}
        for k=i,j do table.remove(ub, i) end
        table.insert(ub, i, newub)
        return ub
      end,
    unds = function (ub, li2, li3)
        local ub3 = UB.from(li3)
        for l,r in li2:gmatch("()%-+()") do
          local undtext = ub3:text_l_r(l, r)
          ub:und(l, r-1, undtext)
        end
        return ub
      end,
  },
}



-- «UB-head»  (to ".UB-head")
-- (find-LATEX "2018tug-dednat6.lua" "myverbatim-head")
registerhead "%UB" {
  name   = "underbrace2d",
  action = function ()
      local i,j,lines = tf:getblock()
      ublast = UB.fromlines(lines)
      PP(ublast)
    end,
}

defub = function (name) ublast:defub(name) end



-- «UB-tests»  (to ".UB-tests")
--[==[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
loaddednat6()
dofile "underbrace2d.lua"
teststr = [[
  a b c d e f
  ---   ---
   g     h
  ---------
      i
]]
lines = splitlines(teststr)
PPV(lines)
ub = UB.from(lines[1])
for i=2,#lines,2 do
  ub:unds(lines[i], lines[i+1])
end
print(ub)
= ub:innerview()
PPV(ub)

ub = UB.fromlines(lines)
= ub

--]==]







-- Local Variables:
-- coding: utf-8-unix
-- End:
