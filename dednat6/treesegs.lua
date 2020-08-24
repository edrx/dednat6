-- treesegs.lua: handle the whitespace-sparated "segments" in "%:"-blocks.
-- This file:
--   http://angg.twu.net/dednat6/dednat6/treesegs.lua.html
--   http://angg.twu.net/dednat6/dednat6/treesegs.lua
--           (find-angg "dednat6/dednat6/treesegs.lua")
-- Author: Eduardo Ochs <eduardoochs@gmail.com>
-- Version: 2020aug24
-- License: GPL3
--
-- «.allsegments»	(to "allsegments")
-- «.segtotreenode»	(to "segtotreenode")
-- «.Segment»		(to "Segment")
-- «.Segments»		(to "Segments")
-- «.tosegments»	(to "tosegments")
-- «.allsegments-tests»	(to "allsegments-tests")


require "eoo"      -- (find-dn6 "eoo.lua")
require "parse"    -- (find-dn6 "parse.lua")
require "treetex"  -- (find-dn6 "treetex.lua")
require "rect"     -- (find-dn6 "rect.lua")
                   -- (find-dn6 "rect.lua" "dedtorect")


intersects = function (start1, end1, start2, end2)
    if end1 <= start2 then return false end
    if end2 <= start1 then return false end
    return true
  end




-- «allsegments» (to ".allsegments")
allsegments = VerticalTable {}
-- For example, allsegment[5] is a Segments object containing the list
-- of all Segment objects at line 5 of the current file (or nil).

-- An expression like allsegments[5][1] returns either a Segment
-- object or nil; an expression like allsegments[5][1]:segsabove()
-- returns a list of Segment objects. Note that Segment and Segments
-- are different classes!




-- «segtotreenode» (to ".segtotreenode")
-- (find-dn6 "treetex.lua" "TreeNode")
segtotreenode = function (seg)
    local bar = seg:firstsegabove()
    if bar then
      local bart = bar.t
      local barchars = bart:match("-+") or
                       bart:match("=+") or
                       bart:match(":+") or
                       bart:match(".+")
      if not barchars then Error("Bad bar: "..bart) end
      local barchar = bart:sub(1, 1)
      local label = bart:sub(1 + #barchars)
      local hyps = bar:segsabove()
      local T = map(segtotreenode, hyps)
      T[0] = seg.t
      T.bar = barchar
      T.label = label
      return TreeNode(T)
    end
    return TreeNode {[0]=seg.t}
  end

-- «Segment» (to ".Segment")
Segment = Class {
  type    = "Segment",
  -- __tostring = function (seg) return seg:torect():tostring() end,
  __tostring = function (seg) return mytostring(seg) end,
  __index = {
    iswithin = function (seg, l, r)
        return intersects(seg.l, seg.r, l, r)
      end,
    intersects = function (seg1, seg2)
        return intersects(seg1.l, seg1.r, seg2.l, seg2.r)
      end,
    segsabove_ = function (seg, dy)
        return allsegments[seg.y - dy] or Segments {}
      end,
    segsabove = function (seg)
        return seg:segsabove_(1):allintersecting(seg)
      end,
    firstsegabove = function (seg) return seg:segsabove()[1] end,
    rootnode = function (seg)
        return seg:segsabove_(2):firstwithin(seg.l, seg.l + 1)
      end,
    totreenode = function (seg) return segtotreenode(seg) end,
    torect = function (seg) return dedtorect(seg:totreenode()) end,
  },
}

-- «Segments» (to ".Segments")
Segments = Class {
  type    = "Segments",
  __tostring = function (segs) return mytostring(segs) end,
  __index = {
    allwithin = function (segs, l, r)
        local T = {}
        for _,seg in ipairs(segs) do
          if seg:iswithin(l, r) then table.insert(T, seg) end
        end
        return T
      end,
    firstwithin = function (segs, l, r)
        return segs:allwithin(l, r)[1]
      end,
    allintersecting = function (segs, seg)
        return segs:allwithin(seg.l, seg.r)
      end,
    firstintersecting = function (segs, seg)
        return segs:allwithin(seg.l, seg.r)[1]
      end,
  },
}


-- «tosegments» (to ".tosegments")
-- Uses functions and variables from: (find-dn6 "parse.lua")
tosegments = function (str, y)
    local T = {}
    setsubj(untabify(str))
    while getword() do
      table.insert(T, Segment {l=startcol, r=endcol, t=word, y=y, i=#T+1})
    end
    return Segments(T)
  end

-- For tests
treesegtest = function (bigstr)
    y = 1
    for _,li in ipairs(splitlines(bigstr)) do
      allsegments[y] = tosegments(li, y)
      y = y + 1
    end
    return allsegments[y - 1][1]   -- return first segment from last line
  end


-- «allsegments-tests»  (to ".allsegments-tests")
-- See: (find-dn6 "rect.lua" "dedtorect-tests")
--[==[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
require "treesegs"
= tosegments(" a    bb ccc ")
= tosegments("  a   bb ccc ")
= s

r = treesegtest [[
%:  a  b 
%:  ----?
%:    c     
]]
= allsegments
= r
PP(r)
PP(r:totreenode())
tn = r:totreenode()


 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
require "treesegs"
foo = function (str)
    allsegments[y] = tosegments(str, y)
    y = y + 1
  end
y = 4
foo "%:  a  b   "
foo "%:  ----?  "
foo "%:    c    "   
foo "%:         "
foo "%:    ^t   "

= allsegments
PP(allsegments[5])
PP(allsegments[5][1])
PP(allsegments[5][1]:segsabove())
PP(allsegments[8][1])
PP(allsegments[8][1]:rootnode())
PP(allsegments[4][1]:segsabove())
PP(allsegments[4][1]:firstsegabove())

=     allsegments[6][1]
PP   (allsegments[6][1])
PP   (allsegments[6][1]:totreenode())
print(allsegments[6][1]:totreenode():TeX_subtree("  "))
print(allsegments[6][1]:totreenode():TeX_deftree("t"))  -- err

--]==]



-- Local Variables:
-- coding: utf-8-unix
-- End:
