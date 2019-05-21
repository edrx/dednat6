-- treetex.lua: derivation trees and functions to convert them to TeX.
-- Here we define the TreeNode class: a TreeNode object has a
-- "conclusion" and may have a bar, a bar label, and hypotheses (that
-- are also TreeNode objects). TreeNode objects can be converted to
-- LaTeX code using the commands from Makoto Tatsuta's "proof.sty"
-- package, and to Rects for debugging. If you are interested in
-- generating code for other proof packages - e.g., Sam Buss's -
-- please get in touch! That should be easy to do, but I need help
-- with the syntax...
--
-- This file:
--   http://angg.twu.net/LATEX/dednat6/treetex.lua.html
--   http://angg.twu.net/LATEX/dednat6/treetex.lua
--                    (find-dn6 "treetex.lua")
-- Author: Eduardo Ochs <eduardoochs@gmail.com>
-- Version: 2019jan18
-- License: GPL3
--
-- Old versions:
--   (find-angg "dednat4/dednat4.lua" "tree-out")
--   (find-angg "dednat/dednat3.lua" "tatsuta")
--   (find-angg "dednat/dednat2.lua" "tatsuta_do_node")
--   (find-angg "dednat/dednat.lua" "tatsuta_donode")

-- «.TreeNode»			(to "TreeNode")
-- «.TreeNode-tests»		(to "TreeNode-tests")
-- «.unabbrev_tatsuta»		(to "unabbrev_tatsuta")
-- «.TeX_subtree_tatsuta»	(to "TeX_subtree_tatsuta")
-- «.TeX_deftree_tatsuta»	(to "TeX_deftree_tatsuta")



require "eoo"       -- (find-dn6 "eoo.lua")
require "abbrevs"   -- (find-dn6 "abbrevs.lua")
require "rect"      -- (find-dn6 "rect.lua")



-- «TreeNode» (to ".TreeNode")
-- A TreeNode object "tn" has fields:
--
--   [0]: the tree root (a string)
--   bar: the strings "-", "=", or ":" if tn has a bar, nil otherwise
--   label: the label at the right of the bar (as a string), or nil
--   [1], [2], ..., [#tn]: other TreeNode objects; each one is a hypothesis.
--
-- The TreeNode object format is much more strict than the format that
-- dedtorect() accepts. TreeNode.from(o) receives an object o that
-- dedtorect() accepts and converts it to a TreeNode object.
--
TreeNode = Class {
  type = "TreeNode",
  from = function (o)
      if type(o) == "string" then return TreeNode {[0]=o} end
      if type(o) == "table"  then
        local tn = {[0]=o[0], bar=o.bar, label=o.label}
        for i=1,#o do tn[i] = TreeNode.from(o[i]) end
        if #tn > 0 then tn.bar = tn.bar or "-" end
        return TreeNode(tn)
      end
      Error("TreeNode.from(o) failed")
    end,
  __tostring  = function (tn) return tostring(tn:torect()) end,
  __index = {
    torect    = function (tn) return dedtorect(tn) end,
    hasbar    = function (tn) return tn.bar ~= nil end,
    barchar   = function (tn) return tn.bar end,
    TeX_root  = function (tn) return tn[0] end,
    TeX_label = function (tn) return tn.label end,
    nhyps     = function (tn) return #tn end,
    hypslist  = function (tn) return tn end,
    TeX_subtree = function (tn, i_)
        return TeX_subtree_tatsuta(tn, i_)
      end,
    TeX_deftree = function (tn, name, link)
        return TeX_deftree_tatsuta(tn, name, link)
      end,
  },
}

-- «TreeNode-tests» (to ".TreeNode-tests")
-- See: (find-dn6 "rect.lua" "dedtorect-tests")
--[==[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
require "treetex"
ded = {[0]="a", "b", {[0]="c", "d",      "e",           bar="=", label="foo"}}
ded = {[0]="a", "b", {[0]="c", "d", {[0]="e", bar="-"}, bar="=", label="foo"}}
= dedtorect(ded)
tn = TreeNode.from(ded)
PPV(ded)
PPV(tn)
= tn
= tn:TeX_subtree("")
= tn:TeX_subtree("  ")
= tn:TeX_deftree("foo", "?")

--]==]



-- «unabbrev_tatsuta» (to ".unabbrev_tatsuta")
-- One easy way to change the way that tree nodes are converted from
-- ascii to TeX is to change this function temporarily.
unabbrev_tatsuta = unabbrev



-- «TeX_subtree_tatsuta» (to ".TeX_subtree_tatsuta")
TeX_subtree_tatsuta = function (tn, i_)
    if not tn:hasbar() then
      return i_.."\\mathstrut "..unabbrev_tatsuta(tn:TeX_root())
    else
      local r_ = tn:TeX_root()
      local b_ = tn:barchar()
      local l_ = tn:TeX_label()
      local h_ = tn:hypslist()
      local r  = "\\mathstrut "..unabbrev_tatsuta(r_)
      -- local b  = ({["-"]="", ["="]="=", [":"]="*"})[b_]
      local b  = ({["-"]="infer",
                   ["="]="infer=",
                   [":"]="infer*",
                   ["."]="deduce"})[b_]
      local l  = (l_ and "[{"..unabbrev(l_).."}]") or ""
      local i  = i_.." "
      local f  = function (tn) return TeX_subtree_tatsuta(tn, i) end
      local h  = mapconcat(f, h_, " &\n")
      -- return i_.."\\infer"..b..l.."{ "..r.." }{\n"..h.." }"
      return i_.."\\"..b..l.."{ "..r.." }{\n"..h.." }"
    end
  end

-- «TeX_deftree_tatsuta» (to ".TeX_deftree_tatsuta")
TeX_deftree_tatsuta = function (tn, name, link)
    local comment = "   % "..(link or tf:hyperlink())
    return "\\defded{"..name.."}{"..comment.."\n"..
           TeX_subtree_tatsuta(tn, " ").." }"
  end




-- Local Variables:
-- coding:             raw-text-unix
-- ee-anchor-format:   "«%s»"
-- End:
