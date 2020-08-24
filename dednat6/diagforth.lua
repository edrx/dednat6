-- diagforth.lua: interpreting the words in "%D" lines in dednat6 files.
-- This file:
--   http://angg.twu.net/dednat6/dednat6/diagforth.lua.html
--   http://angg.twu.net/dednat6/dednat6/diagforth.lua
--           (find-angg "dednat6/dednat6/diagforth.lua")
-- Author: Eduardo Ochs <eduardoochs@gmail.com>
-- Version: 2020jul30
-- License: GPL3
--


-- (find-blogme4 "eval.lua" "parse_pattern")
-- (find-angg "LUA/lua50init.lua" "untabify")
-- (find-blogme4 "eval.lua" "readvword")



-- «.metastack»		(to "metastack")
-- «.diag-head»		(to "diag-head")
-- «.diagram»		(to "diagram")
-- «.enddiagram»	(to "enddiagram")
-- «.BOX»		(to "BOX")
-- «.nodes»		(to "nodes")
-- «.arrow-modifiers»	(to "arrow-modifiers")
-- «.dxyren»		(to "dxyren")
-- «.arrows»		(to "arrows")
-- «.2D-and-2Dx»	(to "2D-and-2Dx")

-- «.run»		(to "run")
-- «.forths»		(to "forths")

-- «.relplace»		(to "relplace")

-- «.high-level-tests»	(to "high-level-tests")
-- «.low-level-tests»	(to "low-level-tests")

require "diagtex"    -- (find-dn6 "diagtex.lua")
require "parse"      -- (find-dn6 "parse.lua")
-- require "process" -- (find-dn6 "process.lua")
require "errors"     -- (find-dn6 "errors.lua")


forths = {}


-- «metastack»  (to ".metastack")
-- (find-dn6 "diagstacks.lua" "MetaStack")
forths["(("] = function () depths:ppush() end
forths["))"] = function () depths:ppop() end
forths["@"] = function () ds:push(depths:metapick(1 + getwordasluaexpr())) end



-- «run»  (to ".run")

-- «diag-head»  (to ".diag-head")
-- (find-dn6file "segments.lua" "tosegments =")
dxyrun = function (str, pos)
    setsubj(str, pos or 1)
    while getword() do
      -- PP(word)
      if    forths[word] then forths[word]()
      elseif nodes[word] then ds:push(nodes[word])
      else Error("Unknown word: "..word)
      end
    end
  end

-- Moved to: (find-dn6 "heads6.lua" "diag-head")
-- registerhead "%D" {
--   name = "diag",
--   action = function ()
--       dxyrun(untabify(linestr), 3)
--     end,
-- }



-- «diagram»  (to ".diagram")
-- «enddiagram»  (to ".enddiagram")
forths["diagram"] = function ()
    diagramname = getword() or derror("No diagram name")
    xys = {}
    nodes  = VerticalTable {}
    arrows = VerticalTable {}
    lasty = nil
  end
forths["enddiagram"] = function ()
    output(arrows_to_defdiag(diagramname, tf:hyperlink()))
  end




-- «BOX»  (to ".BOX")
-- (find-es "dednat" "BOX-dednat6")
-- Note: THIS IS A HACK!!! We even redefine "enddiagram"!
--
mybox_bodies = {}
forths["enddiagram"] = function ()
    if #mybox_bodies == 0 then
      output(arrows_to_defdiag(diagramname, tf:hyperlink()))
    else
      output(arrows_to_defdiagprep(diagramname, mybox_preps(), tf:hyperlink()))
      mybox_bodies = {}
    end
  end
mybox_names = {
  "\\myboxa", "\\myboxb", "\\myboxc", "\\myboxd",
  "\\myboxe", "\\myboxf", "\\myboxg", "\\myboxh"
}
mybox_prep1 = function (boxname, body)
    return format("  \\savebox{%s}{$%s$}\n", boxname, body)
  end
mybox_preps = function ()
    prep = ""
    for i,body in ipairs(mybox_bodies) do
      prep = prep .. mybox_prep1(mybox_names[i], body)
    end
    return prep
  end
forths["BOX"] = function ()
    tinsert(mybox_bodies, node_to_TeX(ds:pick(0)))
    ds:pick(0).tex = format("\\usebox{%s}", mybox_names[#mybox_bodies])
  end





-- «2D-and-2Dx»  (to ".2D-and-2Dx")
-- (find-dn4file "dednat4.lua" "dxy2Dx =")
torelativenumber = function (prevn, str)
    local sign, strn = str:match("^([-+]?)([0-9.]+)$")
    if not sign then return end           -- fail
    local n = tonumber(strn)
    if sign == "" then return n end
    if sign == "+" then return prevn + n else return prevn - n end
  end

dxy2Dx = function ()
    xs = {}
    local lastx = nil
    while getword() do
      local n = torelativenumber(lastx, word)
      if n then
        xs[startcol] = n
        lastx = n
      end
    end
  end
forths["2Dx"] = dxy2Dx

firstxin = function (s, e)
    for i=s,e do if xs[i] then return xs[i] end end
  end
dxy2Ddo = function (y, word)
    if word == "#" then getrestofline(); return end
    local x = firstxin(startcol, endcol-1)
    if not x then return end
    storenode {x=x, y=y, tag=word}
  end
dxy2D = function ()
    if not getword() then return end
    thisy = torelativenumber(lasty, word)
    if not thisy then getrestofline(); return end
    while getword() do dxy2Ddo(thisy, word) end
    lasty = thisy
  end
forths["2D"]  = dxy2D



-- «forths»  (to ".forths")
forths["#"] = function () getrestofline() end

-- «nodes»  (to ".nodes")
forths["node:"] = function ()
    local x,y = getwordasluaexpr()
    local tag = getword()
    ds:push(storenode {x=x, y=y, tag=tag})
  end
forths[".tex="] = function () ds:pick(0).tex = getword() or werror() end
forths[".TeX="] = function () ds:pick(0).TeX = getword() or werror() end

-- «arrow-modifiers»  (to ".arrow-modifiers")
-- (find-dn4 "dednat4.lua" "diag-arrows")
forths[".p="] = function () ds:pick(0).placement = getword() or werror() end
forths[".slide="] = function () ds:pick(0).slide = getword() or werror() end
forths[".curve="] = function () ds:pick(0).curve = getword() or werror() end
forths[".label="] = function () ds:pick(0).label = getword() or werror() end
forths[".plabel="] = function ()
    ds:pick(0).placement = getword() or error()
    ds:pick(0).label     = getword() or error()
  end
-- (find-dn4 "dednat4.lua" "lplacement")
forths[".PLABEL="] = function ()
    ds:pick(0).lplacement = getword() or error()
    ds:pick(0).label      = getword() or error()
  end

-- «dxyren» (to ".dxyren")
dxyren = function (li)
    local a, b = li:match("^(.*) =+> (.*)$")
    if not a then error("No '==>': "..li) end
    local A, B = split(a), split(b)
    if #A ~= #B then error("Bad args to ren: "..li) end
    for i=1,#A do
      local tag, node = A[i], nodes[A[i]]
      if not node then error("No node with this tag: "..tag) end
      node.tex = B[i]
    end
  end
forths["ren"] = function () dxyren(getrestofline()) end

-- «arrows» (to ".arrows")
pusharrow = function (shape)
    local from, to = ds:pick(1), ds:pick(0)
    ds:push(storearrow(DxyArrow {from=from.noden, to=to.noden, shape=shape}))
  end

forths["->"] = function () pusharrow("->") end
forths["=>"] = function () pusharrow("=>") end
forths[".>"] = function () pusharrow(".>") end
forths[":>"] = function () pusharrow(":>") end
forths["|.>"] = function () pusharrow("|.>") end
forths["-->"] = function () pusharrow("-->") end
forths["==>"] = function () pusharrow("==>") end
forths["|->"] = function () pusharrow("|->") end
forths[">->"] = function () pusharrow(" >->") end
forths["`->"] = function () pusharrow("^{ (}->") end
forths[">-->"] = function () pusharrow(" >-->") end
forths["|-->"] = function () pusharrow("|-->") end

forths["<-"]  = function () pusharrow("<-") end
forths["<="]  = function () pusharrow("<=") end
forths["<."]  = function () pusharrow("<.") end
forths["<.|"] = function () pusharrow("<.|") end
forths["<--"] = function () pusharrow("<--") end
forths["<=="] = function () pusharrow("<==") end
forths["<-|"] = function () pusharrow("<-|") end
forths["<-<"] = function () pusharrow("<-< ") end
forths["<-'"] = function () pusharrow("<-^{) }") end
forths["<--|"] = function () pusharrow("<--|") end

forths["<->"] = function () pusharrow("<->") end
forths["="]   = function () pusharrow("=") end

forths["sl^^"] = function () ds:pick(0).slide =    "5pt" end
forths["sl^"]  = function () ds:pick(0).slide =  "2.5pt" end
forths["sl_"]  = function () ds:pick(0).slide = "-2.5pt" end
forths["sl__"] = function () ds:pick(0).slide =   "-5pt" end

defarrows = function (bigstr)
    for _,spec in ipairs(split(bigstr)) do
      forths[spec] = function () pusharrow(spec) end
    end
  end

forths["place"] = function ()
    ds:push(storearrow(DxyPlace {ds:pick(0)}))
  end

-- (find-es "diagxy" "loop")
forths["loop"] = function ()
    ds:push(storearrow(DxyLoop {ds:pick(0), dTeX=getword()}))
  end


-- (find-dn6grep "grep -nH -e forths diagforth.lua")
-- (find-LATEXgrep "grep -nH -e forths *.tex")
forths["x+="] = function () ds:pick(0).x = ds:pick(0).x + getwordasluaexpr() end
forths["y+="] = function () ds:pick(0).y = ds:pick(0).y + getwordasluaexpr() end

forths["xy+="] = function ()
    local dx,dy = getwordasluaexpr(), getwordasluaexpr()
    ds:pick(0).x = ds:pick(0).x + dx
    ds:pick(0).y = ds:pick(0).y + dy
  end

-- «relplace»  (to ".relplace")
-- (find-LATEXfile "2017elephant.tex" "relplace")
forths["relplace"] = function ()
    local x, y = ds:pick(0).x, ds:pick(0).y
    local dx, dy = getwordasluaexpr(), getwordasluaexpr()
    local TeX = getword()
    ds:push(storearrow(DxyPlace {{x=x+dx, y=y+dy, tex=TeX}}))
  end




-- «high-level-tests» (to ".high-level-tests")
--[==[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
require "diagforth"
forths["PP"] = function () PP(getwordasluaexpr()) end
run = dxyrun
run [[ 2Dx     100     +20 ]]
run [[ 2D 100 a,b <=== a   ]]
run [[ 2D      -       -   ]]
run [[ 2D      |  <->  |   ]]
run [[ 2D      v       v   ]]
run [[ 2D +20  c ==> b|->c ]]
PP(xs)
PP(lasty)                 --> 120
= nodes
run [[ (( a,b a c b|->c    ]]
= ds
PP(ds:pick(0))            --> b|->c
PP(ds:pick(1))            --> c
PP(ds:pick(2))            --> a
= depths
PP(depths:metapick(0))
PP(depths:metapick(1))    --> a,b
PP(depths:metapick(2))    --> a
PP(depths:metapick(3))    --> c

run [[    @ 1 @ 0 =>       ]]
print(arrows_to_defdiag("foo"))


 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
require "diagforth"
forths["PP"] = function () PP(getwordasluaexpr()) end
run = dxyrun
run [[ node: 110,120 a    ]]
run [[ (( node: 120,130 b ]]
run [[    =>   a b |->    ]]
print(arrows_to_TeX())
run [[    PP ds         ]]
run [[ ))               ]]
run [[ PP ds            ]]
= ds
= depths
print(arrows_to_TeX())
print(arrows_to_defdiag("foo"))
run [[ )) ]]

--]==]



-- «low-level-tests» (to ".low-level-tests")
--[==[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
require "diagforth"
storenode {TeX="a", tag="a", x=100, y=100}
storenode {TeX="b", tag="b", x=140, y=100}
= nodes







storearrow(DxyArrow {from="a", to="b", shape="|->",
                     slide="5pt", label="up",
                     placement="a"})
storearrow(DxyArrow {from="a", to="b", shape=".>"})
storearrow(DxyPlace {nodes["a"]})
storearrow(DxyLiteral {"literal foobar"})
-- (find-dn6 "diags.lua")
= arrows

print(arrow_to_TeX(arrows[1]))
print(arrows[2]:TeX())
print(arrows[3]:TeX())
print(arrows[4]:TeX())
print(arrows_to_TeX())

--]==]

-- Local Variables:
-- coding:             utf-8-unix
-- End:
