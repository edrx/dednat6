-- heads6.lua: override the dednat5-ish heads with dednat6-ish ones.
-- This file:
-- http://angg.twu.net/dednat6/dednat6/heads6.lua
-- http://angg.twu.net/dednat6/dednat6/heads6.lua.html
--         (find-angg "dednat6/dednat6/heads6.lua")
--
-- (find-dn6 "diagforth.lua" "diag-head")
-- (find-dn6 "treehead.lua"  "tree-head")
-- (find-dn6 "begriff.lua"   "begriff_head")
-- heads = heads or {}
-- heads["%"] = nil

-- «.registerhead»	(to "registerhead")
-- «.abbrev-head»	(to "abbrev-head")
-- «.lua-head»		(to "lua-head")
-- «.luarect-head»	(to "luarect-head")
-- «.tree-head»		(to "tree-head")
-- «.diag-head»		(to "diag-head")
-- «.zrect-head»	(to "zrect-head")
-- «.heads-test»	(to "heads-test")



heads = {}

-- «registerhead» (to ".registerhead")
-- (find-dn6grep "grep -nH -e registerhead *.lua")
-- (find-dn6 "texfile.lua" "Texfile")
-- (find-dn6 "texfile.lua" "Texfile" "process1 =")
registerhead = function (headstr)
    return function (head)
        head.headstr = headstr
        heads[headstr] = head
      end
  end
-- registerhead "" {}



-- «abbrev-head» (to ".abbrev-head")
-- (find-dn6 "process6.lua" "abbrev-head")
-- (find-dn6 "block.lua")
registerhead "%:" {
  name="abbrev",
  action = function ()
      local i,j,abbrevlines = tf:getblock()
      for n=i,j do
        local abbrev, expansion = texlines:line(n):match("^%%:(.-)(.-)")
        -- PP("New abbrev:", abbrev, expansion)
        assert(abbrev)
        addabbrev(abbrev, expansion)
      end
    end,
}


-- «lua-head» (to ".lua-head")
-- (find-dn6 "process.lua" "lua-head")
registerhead "%L" {
  name   = "lua",
  action = function ()
      local i,j,luacode = tf:getblockstr(3)
      local chunkname = tf.name..":%L:"..i.."-"..j
      -- local luacode = table.concat(lualines, "\n")
      assert(loadstring(luacode, chunkname))()
    end,
}

-- «zrect-head» (to ".zrect-head")
-- Old, obsolete, deleted! See:
-- (find-angg "dednat6/zrect.lua" "zrectdefs_get")
-- (find-angg "dednat6/zrect.lua" "zrectdefs_get" "zrectdefs_get =")


-- «luarect-head» (to ".luarect-head")
-- See: (find-dn6 "luarects.lua" "luarecteval")
registerhead "%R" {
  name   = "luarect",
  action = function ()
      print "HELLO"
      local i,j,luarectlines = tf:getblock()
      local chunkname = tf.name..":%R:"..i.."-"..j
      local luacode = luarectexpand(luarectlines)
      print(luacode)    -- verbose
      assert(loadstring(luacode, chunkname))()
    end,
}

-- «tree-head» (to ".tree-head")
-- (find-dn6 "treesegs.lua" "allsegments")
-- (find-dn6 "treesegs.lua" "tosegments")
-- (find-dn6 "treesegs.lua" "Segment")
-- (find-dn6 "treesegs.lua" "Segment" "rootnode =")
-- (find-dn6 "treesegs.lua" "Segment" "totreenode =")
-- (find-dn6 "treetex.lua" "TreeNode")
-- (find-dn6 "treetex.lua" "TreeNode" "TeX_deftree =")
--
registerhead "%:" {
  name   = "tree",
  action = function ()
      local i,j,treelines = tf:getblock()
      local chunkname = tf.name..":%R:"..i.."-"..j
      for n=i,j do
        allsegments[n] = tosegments(texlines:line(n), n)
        for _,seg in ipairs(allsegments[n]) do
          local name = seg.t:match("^%^(.*)")
          if name then
            output(seg:rootnode():totreenode():TeX_deftree(name))
          end
        end
      end
    end,
}

-- «diag-head» (to ".diag-head")
-- (find-dn6 "diagforth.lua" "dxyrun")
registerhead "%D" {
  name = "diag",
  action = function ()
      local i,j,diaglines = tf:getblock()
      for n=i,j do dxyrun(untabify(texlines:line(n)), 3, n) end
    end,
}




-- «heads-test» (to ".heads-test")
-- See: (find-dn6 "texfile.lua" "texfiletest")
--[==[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "texfile.lua"
dofile "luarects.lua"
texfiletest()
add [[%L print(2, ]]
add [[%L       22)]]
pu()
add [[%R a = 2/a b \ ]]
add [[%R      \ c d/ ]]
pu()
= a

 (ex "heads-0")

--]==]





--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "heads6.lua"
= mytabletostring(heads)

--]]



-- Local Variables:
-- coding: utf-8-unix
-- End:

