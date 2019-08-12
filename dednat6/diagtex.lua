-- diagtex.lua:
-- This file:
--   http://angg.twu.net/dednat6/diagtex.lua.html
--   http://angg.twu.net/dednat6/diagtex.lua
--                    (find-dn6 "diagtex.lua")
-- Author: Eduardo Ochs <eduardoochs@gmail.com>
-- Version: 2019aug12
-- License: GPL3

-- «.coords»		(to "coords")
-- «.arrow_to_TeX»	(to "arrow_to_TeX")
-- «.arrow_to_TeX-test»	(to "arrow_to_TeX-test")
-- «.DxyArrow»		(to "DxyArrow")
-- «.DxyPlace»		(to "DxyPlace")
-- «.DxyLiteral»	(to "DxyLiteral")
-- «.DxyLoop»		(to "DxyLoop")
-- «.arrows_to_defdiag»	(to "arrows_to_defdiag")
-- «.arrows-tests»	(to "arrows-tests")


require "eoo"         -- (find-dn6 "eoo.lua" "over")
-- require "prefixes" -- (find-dn6 "prefixes.lua" "unabbrev")

require "diagstacks"  -- (find-dn6 "diagstacks.lua")
require "abbrevs"     -- (find-dn6 "abbrevs.lua")



-- «coords»  (to ".coords")
-- (find-dn4 "dednat4.lua" "diag-out" "dxyorigx =")
dxyorigx = 100
dxyorigy = 100
dxyscale = 15
realx = function (x) return  dxyscale * (x - dxyorigx) end
realy = function (y) return -dxyscale * (y - dxyorigy) end
realxy = function (x, y) return realx(x), realy(y) end

-- «arrow_to_TeX»  (to ".arrow_to_TeX")
-- (find-diagxypage  6 "2"   "  The basic syntax")
-- (find-diagxytext    "2"   "  The basic syntax")
-- (find-diagxypage  6         "\\morphism(x,y)|p|/{sh}/<dx,dy>[N`N;L]")
-- (find-diagxytext            "\\morphism(x,y)|p|/{sh}/<dx,dy>[N`N;L]")
-- (find-diagxypage  7         "@{shape}")
-- (find-diagxytext            "@{shape}")
-- (find-diagxypage 23 "4.3" "  Empty placement and moving labels")
-- (find-diagxytext    "4.3" "  Empty placement and moving labels")
-- (find-dn4 "dednat4.lua" "diag-out" "arrowtoTeX =")
-- (find-dn4 "dednat4.lua" "lplacement")
node_to_TeX = function (node)
    local tex = node.tex or node.tag
    local TeX = node.TeX or (tex and unabbrev(tex))
    return (TeX and "{"..TeX.."}") or ""
  end
arrow_to_TeX = function (arrow)
    local node1 = nodes[arrow.from]
    local node2 = nodes[arrow.to]
    local x1, y1 = realxy(node1.x, node1.y)
    local x2, y2 = realxy(node2.x, node2.y)
    local dx, dy = x2 - x1, y2 - y1
    local N1 = node_to_TeX(node1)
    local N2 = node_to_TeX(node2)
    --
    -- Calculate p, sh, L.
    -- In several complex cases the "placement" p and the "label" L
    -- are moved into the "shape" parameter sh; see:
    --   (find-es "diagxy" "shape")
    local p, sh, L = arrow_to_TeX_pshL(arrow)  -- defined below
    --
    return dformat("\\morphism(%d,%d)%s%s<%d,%d>[%s`%s;%s]",
                  x1, y1, p, sh, dx, dy, N1, N2, L)
  end

arrow_to_TeX_pshL = function (arrow)
    local Label = arrow.Label or (arrow.label and unabbrev(arrow.label))
    local L = Label and "{"..Label.."}" or ""
    local p = arrow.placement and "|"..arrow.placement.."|" or ""
    local lplace = arrow.lplacement and arrow.lplacement.."{"..Label.."}"
    --
    local shape = arrow.shape or "->"
    local slide = arrow.slide and "@<"..arrow.slide..">"
    local curve = arrow.curve and "@/"..arrow.curve.."/"
    local modifier
    if slide or curve or lplace then
      modifier = (lplace or "")..(slide or "")..(curve or "")
    end
    if arrow.modifier then modifier = arrow.modifier end -- temp hack
    if modifier then
      sh = format("/{@{%s}%s}/", shape, modifier)
    else
      sh = "/"..shape.."/"
    end
    if lplace then p = "||"; L = "" end
    return p, sh, L
  end


-- «arrow_to_TeX-test» (to ".arrow_to_TeX-test")
-- (find-es "diagxy" "shape")
--[==[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
require "diagtex"
test = function (A) print(arrow_to_TeX(A)) end
storenode {TeX="a", tag="a", x=100, y=100}
storenode {TeX="b", tag="b", x=140, y=100}
test {from="a", to="b", shape="|->"}
test {from="a", to="b", shape="|->", label="up", placement="a"}
test {from="a", to="b", shape="|->", label="up", placement="a", slide="5pt"}
test {from="a", to="b", shape="|->", label="up", lplacement="_(0.42)"}  -- err?

 (ex "diagtex-0")

--]==]




-- The kinds of things that we store in the array "arrows".
-- (find-dn6 "diagstacks.lua" "arrows")
-- «DxyArrow»  (to ".DxyArrow")
DxyArrow = Class {
  type    = "DxyArrow",
  __index = {
    TeX = function (ar) return arrow_to_TeX(ar) end,
  },
}
-- «DxyPlace»  (to ".DxyPlace")
DxyPlace = Class {
  type    = "DxyPlace",
  __index = {
    TeX = function (pseudoar)
        local node = pseudoar[1]
        local x, y = realxy(node.x, node.y)
        return dformat("\\place(%d,%d)[{%s}]", x, y, node_to_TeX(node))
      end,
  },
}
-- «DxyLiteral»  (to ".DxyLiteral")
DxyLiteral = Class {
  type    = "DxyLiteral",
  __index = {
    TeX = function (pseudoar) return pseudoar[1] end,
  },
}
-- «DxyLoop»  (to ".DxyLoop")
-- (find-es "diagxy" "loop")
DxyLoop = Class {
  type    = "DxyLoop",
  __index = {
    TeX = function (pseudoar)
        local node, dTeX = pseudoar[1], pseudoar.dTeX
        local x, y = realxy(node.x, node.y)
        return dformat("\\Loop(%d,%d){%s}%s", x, y, node_to_TeX(node), dTeX)
      end,
  },
}


-- «arrows_to_defdiag»  (to ".arrows_to_defdiag")
arrows_to_TeX = function (prefix)
    local f = function (ar) return (prefix or "  ")..ar:TeX().."\n" end
    return mapconcat(f, arrows, "")
  end
arrows_to_defdiag = function (name, hyperlink)
    return format("\\defdiag{%s}{   %% %s\n%s}",
                  name, hyperlink or "",
                  arrows_to_TeX("  "))
  end
arrows_to_defdiagprep = function (name, prep, hyperlink)
    return format("\\defdiagprep{%s}{   %% %s\n%s}{\n%s}",
                  name, hyperlink or "",
                  prep,
                  arrows_to_TeX("  "))
  end




-- «arrows-tests» (to ".arrows-tests")
--[==[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
require "diagtex"
storenode {TeX="a", tag="a", x=100, y=100}
storenode {TeX="b", tag="b", x=140, y=100}
= nodes
storearrow(DxyArrow {from="a", to="b", shape="|->",
                     slide="5pt", label="up", placement="a"})
storearrow(DxyArrow {from="a", to="b", shape=".>"})
storearrow(DxyPlace {nodes["a"]})
storearrow(DxyLiteral {"literal foobar"})
= arrows
print(arrow_to_TeX(arrows[1]))
print(arrows[2]:TeX())
print(arrows[3]:TeX())
print(arrows[4]:TeX())
print(arrows_to_TeX())
print(arrows_to_defdiag("??", "  % foo"))

 (ex "diagtex-1")

--]==]



-- Local Variables:
-- coding:             raw-text-unix
-- ee-anchor-format:   "«%s»"
-- End:
