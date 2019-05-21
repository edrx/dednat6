-- This file:
--   http://angg.twu.net/dednat6/myverbatim.lua
--   http://angg.twu.net/dednat6/myverbatim.lua.html
--                (find-dednat6 "myverbatim.lua")
--           See: (find-dednat6 "myverbatim.tex")
--
-- (defun e () (interactive) (find-fline "~/dednat6/myverbatim.tex"))
-- (defun l () (interactive) (find-fline "~/dednat6/myverbatim.lua"))
--
-- This is a verbatim mode extension for Dednat6. It was implemented
-- as a VERY quick hack; I needed something that I could bootstrap in
-- just a few minutes and then extend it quickly as I would think of
-- new functionalities that I wanted. I wrote it to use it for the
-- verbatim blocks in the slides for my presentation about Dednat6 at
-- the TUG conference in Rio de Janeiro in july, 2018, as a
-- quick-and-dirty prototype that I would rewrite later. Links:
--
--   http://angg.twu.net/dednat6/tugboat-rev2.pdf  (TUGboat article)
--   http://angg.twu.net/dednat6/tug-slides.pdf    (slides)
--   http://angg.twu.net/math-b.html#tug-2018
--
--   (find-pdf-page "~/dednat6/tugboat-rev2.pdf")
--   (find-pdf-page "~/dednat6/tug-slides.pdf")
--   (find-dednat6 "tug-slides.tex" "verbatim")
--
-- Usage: when Dednat6 "processes" (in the sense of section 3.1 of the
-- article for TUGBoat) a %V-block, it simply stores the contents of
-- the %V-block in the global table "verbalast"; then we run a
-- verbact("...") in a %L-line to transform verbalast in several ways
-- and output a "\def". After a while I discovered that I was always
-- using the same series of transformations, and wrote a function
-- verbdef() for running them. See the eepitch block at the end of
-- this file for tests.
--
--   Eduardo Ochs <eduardoochs@gmail.com>, 2018. Public domain.


-- «.myverbatim-head»	(to "myverbatim-head")



verbapat = "[\n #$%%&\\^_{}~]"
verbadict = {["\n"]="\\\\\n"}
verbaset_b  = function (c) verbadict[c] = "\\"..c end
verbaset_c  = function (c) verbadict[c] = "\\char"..string.byte(c).." " end
verbaexpand = function (str) return (string.gsub(str, verbapat, verbadict)) end
gchars      = function (str) return string.gmatch(str, ".") end
for c in gchars(" \\%&^_{}~") do verbaset_c(c) end
for c in gchars("#$")         do verbaset_b(c) end

verbalast = {}       -- contents of the last verbatim block
verbact = function (str)
    local doe   = function (A) return map(verbaexpand, A) end
    local doh1  = function (s) return format("\\verbahbox{%s}", s) end
    local doh   = function (A) return map(doh1, A) end
    local doc   = function (A) return table.concat(A, "%\n") end
    local dov   = function (s) return format("\\vbox{%%\n%s%%\n}", s) end
    local dobg  = function (s) return format("\\bgbox{%s}", s) end
    local dodef = function (s, action)
        local name = action:match":(.*)"
        return format("\\def\\%s{%s}", name, s)
      end
    --
    for _,action in ipairs(split(str)) do
      if     action == "e" then verbalast = doe(verbalast)
      elseif action == "h" then verbalast = doh(verbalast)
      elseif action == "c" then verbalast = doc(verbalast)
      elseif action == "v" then verbalast = dov(verbalast)
      elseif action == "bg" then verbalast = dobg(verbalast)
      elseif action:match"^def:" then verbalast = dodef(verbalast, action)
      elseif action == "o" then output(verbalast)
      elseif action == "P" then PP(verbalast)
      else   error("Unrecognized action: "..action)
      end
    end
  end

verbdef = function (name) verbact("e h c v bg def:"..name.." o") end


-- «myverbatim-head»  (to ".myverbatim-head")
-- (find-dn6 "heads6.lua" "lua-head")
-- (find-dn6 "heads6.lua" "lua-head" "= tf:getblock()")
-- (find-dn6 "texfile.lua" "TexFile")
-- (find-dn6 "texfile.lua" "TexFile" "getblock =")
registerhead "%V" {
  name   = "myverbatim",
  action = function ()
      local i,j,origlines = tf:getblock()
      verbalast = origlines
      PPV(origlines)
    end,
}



--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
registerhead = function () return function () end end
dofile "myverbatim.lua"
output = print

str = "Hello #$%&\\^_{}~!!!\n  Hey  hey"
print(verbaexpand(str))

verbalast = {"a", "bb", "ccc"}
verbact("P")

verbalast = {"a", "bb", "ccc"}
verbact("e h c P")
verbalast = {"a", "b b", "ccc"}
verbact("e h c v def:foo o")

verbalast = {"a", "b b", "ccc"}
verbdef("foo")


--]]
