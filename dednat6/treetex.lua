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
--   http://angg.twu.net/dednat6/dednat6/treetex.lua.html
--   http://angg.twu.net/dednat6/dednat6/treetex.lua
--           (find-angg "dednat6/dednat6/treetex.lua")
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
-- «.tatsuta»			(to "tatsuta")
--   «.unabbrev_tatsuta»	(to "unabbrev_tatsuta")
--   «.TeX_subtree_tatsuta»	(to "TeX_subtree_tatsuta")
--   «.TeX_deftree_tatsuta»	(to "TeX_deftree_tatsuta")
--
-- «.ProofSty»			(to "ProofSty")
-- «.ProofSty-test»		(to "ProofSty-test")
-- «.BussProofs»		(to "BussProofs")
-- «.BussProofs-test»		(to "BussProofs-test")



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
-- Note that the TreeNode object format is much more strict than the
-- format that dedtorect() accepts. TreeNode.from(o) receives an
-- object o that dedtorect() accepts and converts it to a TreeNode
-- object. See:
--
--   (find-dn6 "rect.lua")
--   (find-dn6 "rect.lua" "dedtorect-tests")
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
= otype(tn)
= otype(tn[1])
= otype(ded)
= otype(ded[1])
= tn:TeX_subtree("")
= tn:TeX_subtree("  ")
= tn:TeX_deftree("foo", "?")

--]==]




--  _        _             _        
-- | |_ __ _| |_ ___ _   _| |_ __ _ 
-- | __/ _` | __/ __| | | | __/ _` |
-- | || (_| | |_\__ \ |_| | || (_| |
--  \__\__,_|\__|___/\__,_|\__\__,_|
--                                  
-- «tatsuta»  (to ".tatsuta")
-- This is the original way to convert a TreeNode to a \defded.
-- It is super-old (modulo minimal changes). It doesn't uses classes
-- and it uses the name "tatsuta" to refers to Makoto Tatsuta's
-- proof.sty package, instead of calling it "proof.sty". This code
-- will be obsoleted soon (where "now" = 2020aug24).




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





treetex_mapconcat = function (f, arr, sep, ifempty)
    if #arr > 0 then return mapconcat(f, arr, sep) end
    return ifempty   -- return this string if the array has length 0
  end




--  ____                   __ ____  _         
-- |  _ \ _ __ ___   ___  / _/ ___|| |_ _   _ 
-- | |_) | '__/ _ \ / _ \| |_\___ \| __| | | |
-- |  __/| | | (_) | (_) |  _|___) | |_| |_| |
-- |_|   |_|  \___/ \___/|_| |____/ \__|\__, |
--                                      |___/ 
--
-- «ProofSty»  (to ".ProofSty")
-- A class that converts a TreeNode to a \defded using Makoto
-- Tatsuta's proof.sty. This is intended as a replacement for the
-- functions TeX_subtree_tatsuta and TeX_deftree_tatsuta defined above.
-- Experimental. Version: 2020aug24.

ProofSty = Class {
  type = "ProofSty",
  new  = function () return ProofSty {} end,
  __index = {
    unabbrev = function (ps, str) return unabbrev(str) end,
    subtreetolatex = function (ps, tn, i)
        if not tn:hasbar() then
          return i.."\\mathstrut "..ps:unabbrev(tn:TeX_root())
        else
          local r_ = tn:TeX_root()
          local b_ = tn:barchar()
          local l_ = tn:TeX_label()
          local h_ = tn:hypslist()
          local r  = "\\mathstrut "..ps:unabbrev(r_)
          local b  = ({["-"]="infer",
                       ["="]="infer=",
                       [":"]="infer*",
                       ["."]="deduce"})[b_]
          local l  = (l_ and "[{"..ps:unabbrev(l_).."}]") or ""
          local i_ = i.." "
          local f  = function (tn) return ps:subtreetolatex(tn, i_) end
          local h  = treetex_mapconcat(f, h_, " &\n", " ")
          return i.."\\"..b..l.."{ "..r.." }{\n"..h.." }"
        end
      end,
    todefded = function (ps, tn, name, link)
        local comment = "   % "..(link or tf:hyperlink())
        return "\\defded{"..name.."}{"..comment.."\n"..
               ps:subtreetolatex(tn, " ").." }"
      end,
  },
}

proofsty = ProofSty.new()

-- To experiment with the new classes, do something like:
--
--   TreeNode.__index.TeX_deftree = function (tn, name, link)
--       return proofsty:todefded(tn, name, link)
--     end
--
-- or:
--
--   TreeNode.__index.TeX_deftree = function (tn, name, link)
--       return bussproofs:todefded(tn, name, link)
--     end
--
-- To replace a method in proofsty, do something like:
--
--   proofsty.unabbrev = function (ps, str)
--       return "?"..unabbrev(str)
--     end


-- «ProofSty-test»  (to ".ProofSty-test")
--[==[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
loaddednat6()
require "block"
bigstr = [[
%:                       H
%:  -                   ...
%:  A  B  C   E  F      \Pi
%:  =======r  ::::\phi  ...
%:     D       G         I
%:     -------------------
%:             J
%:
%:             ^bars
%:
]]
output = print
texlines = TexLines.new("test", bigstr)
tf = texlines:toblock()
tf:processuntil(texlines:nlines())
PP(headblocks)
= allsegments[9]
seg = allsegments[9][1]
name = "bars"
output(seg:rootnode():totreenode():TeX_deftree(name))
= seg:rootnode()
= seg:rootnode():totreenode()
tree = seg:rootnode():totreenode()
= tree
= tree[1]
PPV(tree)
PPV(tree[3][1][1])

print(bigstr)
= proofsty:subtreetolatex(tree, "")
= proofsty:todefded(tree, "NAME")

proofsty.unabbrev = function (ps, str) return "?"..unabbrev(str) end
= proofsty:todefded(tree, "NAME")

--]==]


--  ____                ____                   __     
-- | __ ) _   _ ___ ___|  _ \ _ __ ___   ___  / _|___ 
-- |  _ \| | | / __/ __| |_) | '__/ _ \ / _ \| |_/ __|
-- | |_) | |_| \__ \__ \  __/| | | (_) | (_) |  _\__ \
-- |____/ \__,_|___/___/_|   |_|  \___/ \___/|_| |___/
--                                                    
-- «BussProofs»  (to ".BussProofs")
-- A class that converts a TreeNode to a \defded using bussproofs.
-- Experimental. Version: 2020aug24.

BussProofs = Class {
  type = "BussProofs",
  new  = function () return BussProofs {} end,
  __index = {
    unabbrev = function (bp, str) return unabbrev(str) end,
    subtreetolatex = function (bp, tn, i)
        local i_,i__ = i.." ", i.."  "
        if not tn:hasbar() then
          local r_ = tn:TeX_root()
          return i.."\\AxiomC{$"..bp:unabbrev(r_).."$}"
        else
          local r_ = tn:TeX_root()
          local b_ = tn:barchar()
          local l_ = tn:TeX_label()
          local h_ = tn:hypslist()
          local r  = "\\mathstrut "..bp:unabbrev(r_)
          local s  = function (indent, str)
	                 return str and (indent..str.."\n") or ""
                       end
          local Lines = {["-"]=nil,
                         ["="]="\\doubleLine",
                         ["."]="\\noLine"}
          local Line  = Lines[b_]
          local Label = l_ and l_ ~= "" and format("\\RightLabel{$%s$}", l_)
          local Infs  = {[0] = "\\UnaryInfC",
                         "\\UnaryInfC",
                         "\\BinaryInfC",
                         "\\TrinaryInfC",
                         "\\QuaternaryInfC",
                         "\\QuinaryInfC"}
          local Inf   = format("%s{$%s$}", Infs[#h_], bp:unabbrev(r_))
          local f  = function (tn) return bp:subtreetolatex(tn, i__) end
          local Hyps  = treetex_mapconcat(f, h_, i__.."\n", i__.."\\AxiomC{}")
          return Hyps.."\n"..s(i_,Line)..s(i_,Label)..i..Inf
        end
      end,
    treetolatex = function (bp, tn, i)
        return i.."\\hbox{$\n"..
               bp:subtreetolatex(tn, i).."\n"..
	       i.."\\DisplayProof\n"..
               i.."$}\n"
      end,
    todefded = function (bp, tn, name, link)
        local comment = "   % "..(link or tf:hyperlink())
        return "\\defded{"..name.."}{"..comment.."\n"..
	       bp:treetolatex(tn, "  ")..
               " }"
      end,
  },
}

bussproofs = BussProofs.new()

-- «BussProofs-test»  (to ".BussProofs-test")
--[==[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
loaddednat6()
require "block"
bigstr = [[
%:                       H
%:  -                   ...
%:  A  B  C   E  F      \Pi
%:  =======r  ::::\phi  ...
%:     D       G         I
%:     -------------------
%:             J
%:
%:             ^bars
%:
]]
output = print
output("foo")
texlines = TexLines.new("test", bigstr)
tf = texlines:toblock()
PP(headblocks)
tf:processuntil(texlines:nlines())
PP(headblocks)
= allsegments[9]
seg = allsegments[9][1]
name = "bars"
output(seg:rootnode():totreenode():TeX_deftree(name))
= seg:rootnode()
= seg:rootnode():totreenode()
tree = seg:rootnode():totreenode()
= tree
= tree[1]
= tree[3]
= tree[3][1]
= tree[3][1][1]
PPV(tree)
PPV(tree[3][1][1])

bp = BussProofs.new()
= bp:subtreetolatex(tree, "")
= bp:treetolatex(tree, "")
= bp:todefded(tree, "NAME")

--]==]



-- Local Variables:
-- coding: utf-8-unix
-- End:
