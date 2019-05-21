-- This file:
-- http://angg.twu.net/LATEX/dednat6/abbrevs.lua
-- http://angg.twu.net/LATEX/dednat6/abbrevs.lua.html
--                        (find-dn6 "abbrevs.lua")
--
-- This is a rewrite of:
--   (find-dn6 "prefixes.lua")
--   (find-dn4 "dednat4.lua" "abbrevs")
--   (find-dn4 "dednat4.lua" "standardabbrevs")
-- See:
--   (find-dn6 "heads6.lua" "abbrev-head")
--
-- I had to use abbrevs a lot in dednat4, that did suppport UTF-8.
-- In dednat6 this is a fossil feature, kept for situations where
-- backward compatibily is necessary.



Abbrevs = Class {
  type = "Abbrevs",
  new  = function () return Abbrevs {dict={}} end,
  __tostring = function (ab) return mytabletostring(ab.dict) end,
  __index = {
    add = function (ab, abbrev, expansion, ...)
        local dict = ab.dict
        for i=1,#abbrev-1 do                -- for each prefix of abbrev
          local prefix = abbrev:sub(1, i)   --
          dict[prefix] = dict[prefix] or 0  -- store a "keep trying"
        end
        dict[abbrev] = expansion          -- for abbrev itself, store expansion
        if select("#", ...) > 0 then   -- more abbrev/expansion pairs?
          ab:add(...)                  -- add them too (using recursion)
        end
        return ab
      end,
    del = function (ab, abbrev)
        ab.dict[abbrev] = 0            -- 0 means "keep trying"
        return ab
      end,
    --
    longestprefix = function (ab, str, j)
        local dict = ab.dict
        local longest = nil            -- longest prefix having an expansion
        for k=j,#str do
          local candidate = str:sub(j, k)
          local e = dict[candidate]
          if e == nil then break end   -- if e==nil we can stop
          if e ~= 0 then               -- if e==0 we keep trying
            longest = candidate        -- if e~=nil and e~=0 we record the match
          end
        end
        return longest, dict[longest]  -- return best match and its "expansion"
      end,
    findfirstexpansion = function (ab, str, i)
        for j=i,#str do
          local longest, expansion = ab:longestprefix(str, j)
          if longest then return j, longest, expansion end
        end
      end,
    unabbrev = function (ab, str, i)
        i = i or 1
        local j, longest, expansion = ab:findfirstexpansion(str, i, pt)
        if j then
          return str:sub(i, j-1) ..               -- the unexpandable part, then
                 expansion ..                     -- the expansion, then...
                 ab:unabbrev(str, j+#longest, pt) -- recurse!
        end
        return str:sub(i)                      -- or all the rest of the string.
      end,
  },
}


abbrevs = Abbrevs.new()
unabbrev   = function (str)       return abbrevs:unabbrev(str) end
addabbrev  = function (a, e)      return abbrevs:add(a, e) end
addabbrevs = function (a, e, ...) return abbrevs:add(a, e, ...) end
delabbrev  = function (a)         return abbrevs:del(a) end

standardabbrevs = function ()
    addabbrevs(
      "->^", "\\ton ",   "`->", "\\ito ", "-.>", "\\tnto ",
      "=>",  "\\funto ", "<->", "\\bij ", "->",  "\\to ",
      "|-",  "\\vdash ", "|->", "\\mto ", "\"",  " ")
  end



--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "abbrevs.lua"
abbrevs = Abbrevs.new()
addabbrevs("->", "\\to ", "<->", "\\bij ")
=  abbrevs
=  abbrevs:longestprefix("a->b<->c", 1)
=  abbrevs:longestprefix("a->b<->c", 2)
PP(abbrevs:longestprefix("a->b<->c", 2))
PP(abbrevs:findfirstexpansion("a->b<->c", 1))
PP(abbrevs:unabbrev("a->b<->c", 6))
PP(abbrevs:unabbrev("a->b<->c", 5))
PP(abbrevs:unabbrev("a->b<->c", 4))
PP(abbrevs:unabbrev("a->b<->c", 3))
PP(abbrevs:unabbrev("a->b<->c", 2))
PP(abbrevs:unabbrev("a->b<->c", 1))
PP(abbrevs:unabbrev("a->b<->c"))
= unabbrev("a->b<->c")

 (ex "abbrevs")

--]]


-- Local Variables:
-- coding: raw-text-unix
-- End:

