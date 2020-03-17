-- diagtikz.lua:
-- This file:
--   http://angg.twu.net/dednat6/dednat6/diagtikz.lua.html
--   http://angg.twu.net/dednat6/dednat6/diagtikz.lua
--           (find-angg "dednat6/dednat6/diagtikz.lua")
-- Author: Eduardo Ochs <eduardoochs@gmail.com>
-- Version: 2020feb16
-- License: GPL3

-- The default back-end for 2D diagrams in dednat6 is the file
-- "diagtex.lua", that generates code for diagxy. This is an
-- alternative back-end that generates code for Tikz instead of
-- diagxy. Note: THIS IS A SKELETON/PROTOTYPE, and it is not
-- loaded by default!
--
-- See: (find-angg "dednat6/dednat6/diagtex.lua")

-- «.tikzdiagram»	(to "tikzdiagram")
-- «.endtikzdiagram»	(to "endtikzdiagram")
-- «.tikzshape»		(to "tikzshape")
-- «.tikzshapes-test»	(to "tikzshapes-test")
-- «.tikzcoords»	(to "tikzcoords")
-- «.defdiagtikz»	(to "defdiagtikz")
-- «.tikzdiagram-test»	(to "tikzdiagram-test")







-- require "diagtex"    -- (find-dn6 "diagtex.lua")
require "diagforth"     -- (find-dn6 "diagforth.lua")



-- «tikzdiagram»  (to ".tikzdiagram")
-- «endtikzdiagram»  (to ".endtikzdiagram")
-- See: (find-dednat6 "dednat6/diagforth.lua" "diagram")
--      (find-dednat6 "dednat6/diagforth.lua" "enddiagram")
--      (to "defdiagtikz")
--
forths["tikzdiagram"] = function ()
    diagramname = getword() or derror("No diagram name")
    xys = {}
    nodes  = VerticalTable {}
    arrows = VerticalTable {}
    lasty = nil
  end
forths["endtikzdiagram"] = function ()
    -- output(arrows_to_defdiag(diagramname, tf:hyperlink()))
    output(defdiagtikz())
    -- print(arrows)
  end




-- «tikzshape»  (to ".tikzshape")
-- One of the optional arguments to the diagxy macro "\morphism" is
-- called "shape", and it is given like this: "/|->/"...
--   (find-diagxypage 7 "The shape parameter sh")
--   (find-diagxytext 7 "The shape parameter sh")
--   (find-dednat6 "dednat6/diagforth.lua" "arrows")
--   (find-dednat6 "dednat6/diagforth.lua" "arrows")
--
tikzshapes   = VerticalTable {}
tikzshape    = function (diagxysh) return tikzshapes[diagxysh].to end
tikzshapedef = function (word, diagxysh, tikzarrowspec)
    local sh = diagxysh or word   -- can be better
    tikzshapes[sh] = {word=word, from=sh, to=tikzarrowspec}
  end

tikzshapedef("->",   nil,       "->")
tikzshapedef("|->",  nil,       "{|}-{>}")
tikzshapedef("=>",   nil,       "{}-{>},double")
tikzshapedef("`->",  "^{ (}->", "{}-{>},double")

-- «tikzshapes-test»  (to ".tikzshapes-test")
--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "diagtikz.lua"
= tikzshapes
= tikzshape  "^{ (}->"

--]]



-- «tikzcoords»  (to ".tikzcoords")
-- Convert diagxy coordinates to tikz coordinates.
tikzx = function (x) return (x - 100) / 20 end
tikzy = function (y) return (100 - y) / 20 end
tikznodename = function (node)
    return node.x.." "..node.y
  end
tikznodedef = function (node)
    local tex = node.tex or node.tag
    local TeX = node.TeX or (tex and unabbrev(tex))
    return format("    \\node (%s) at (%s,%s) {$%s$};",
                  tikznodename(node),
                  tikzx(node.x), tikzy(node.y),
                  TeX)
  end
tikznodedefs = function ()
    local A = {}
    for i=1,#nodes do
      table.insert(A, tikznodedef(nodes[i]).."\n")
    end
    return table.concat(A)
  end


tikzarrow0 = function (arrowspec, nodenamefrom, nodenameto)
    return format("    \\draw [%s] (%s) -- (%s);",
                  arrowspec, nodenamefrom, nodenameto)
  end
tikzarrow = function (arrow)
    local nodefrom     = nodes[arrow.from]
    local nodeto       = nodes[arrow.to]
    local nodenamefrom = tikznodename(nodefrom) 
    local nodenameto   = tikznodename(nodeto) 
    local arrowspec    = tikzshape(arrow.shape)
    return tikzarrow0(arrowspec, nodenamefrom, nodenameto)
  end
tikzarrows = function ()
    local A = {}
    for i=1,#arrows do
      table.insert(A, tikzarrow(arrows[i]).."\n")
    end
    return table.concat(A)
  end

tikzdiagram = function ()
    return "  \\begin{tikzpicture}\n"..
      tikznodedefs()..
      tikzarrows()..
      "  \\end{tikzpicture}"
  end



-- «defdiagtikz»  (to ".defdiagtikz")
-- (find-dn6 "diagtex.lua" "arrows_to_defdiag")
defdiagtikz0 = function (name, hyperlink)
    return format("\\defdiagtikz{%s}{   %% %s\n%s}",
                  name, hyperlink or "",
                  tikzdiagram())
  end
defdiagtikz = function ()
    return defdiagtikz0(diagramname, tf and tf:hyperlink())
  end



-- «tikzdiagram-test»  (to ".tikzdiagram-test")
-- (find-dednat6 "dednat6/diagforth.lua" "high-level-tests")

--[==[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "diagtikz.lua"
forths["endtikzdiagram"] = function () print(arrows) end

dxyrun [[ tikzdiagram NAME           ]]
dxyrun [[ 2Dx     100   +40          ]]
dxyrun [[ 2D  100 A --> B            ]]
dxyrun [[ 2D            |            ]]
dxyrun [[ 2D  +30       C            ]]
dxyrun [[ 2D                         ]]
dxyrun [[ (( A B ->  .plabel= a foo  ]]
dxyrun [[    B C =>  .plabel= r bar  ]]
dxyrun [[    A C |-> .plabel= m plic ]]
dxyrun [[                            ]]
dxyrun [[ ))                         ]]
dxyrun [[ endtikzdiagram             ]]

-- (find-dednat6 "dednat6/diagtex.lua" "arrows_to_defdiag")
-- (find-dednat6 "dednat6/diagtex.lua" "arrow_to_TeX")

print(arrows)
PP(arrows[1])
PP(arrows[1].from)
PP(arrows[1].to)
PP(nodes[arrows[1].from])
PP(nodes[arrows[1].to])

= tikznodedef(nodes[arrows[1].to])
= tikzarrow(arrows[1])
= nodes
= tikznodedefs()
= arrows
= tikzarrows()
= defdiagtikz0("foo", "hyper")
= defdiagtikz0("foo")
= defdiagtikz()

--]==]






-- Local Variables:
-- coding:             utf-8-unix
-- End:
