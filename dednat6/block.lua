-- block.lua: implement the class Block, that is used for texfile
-- blocks, publocks and head blocks. This file supersedes and replaces
-- texfile.lua...
--
-- In may 2018 I realized that three data structures in dednat6 could
-- be unified into a single one, the "Block"; they are the "texfile
-- blocks", the "pu blocks", and the "head blocks".
--
-- The algorithm is described here:
-- http://angg.twu.net/LATEX/2018tugboat-rev1.pdf
--   (turp 4 "heads-and-blocks" "Heads and blocks")
--   (tur    "heads-and-blocks" "Heads and blocks")
--
-- This file:
-- http://angg.twu.net/LATEX/dednat6/block.lua
-- http://angg.twu.net/LATEX/dednat6/block.lua.html
--                        (find-dn6 "block.lua")
-- It replaces this:
-- http://angg.twu.net/LATEX/dednat6/texfile.lua
-- http://angg.twu.net/LATEX/dednat6/texfile.lua.html
--                        (find-dn6 "texfile.lua")
--
-- Suppose that we have a .tex file with 1000 lines, with a "\pu" at
-- line 200, another "\pu" at line 300, and with lines with the "%D"
-- head from lines 210 to 215. Then we would have these objects at
-- different points of the execution of the program:
--
--     texbl  = Block {i=1,  j=1000, nline=1}
--     publ   = Block {i=1,   j=199}
--     publ   = Block {i=201, j=299}
--     headbl = Block {i=210, j=215, head="%D"}
--
-- «.TexLines»	(to "TexLines")
-- «.Block»	(to "Block")
-- «.texfile0»	(to "texfile0")


-- (find-LATEXfile "dednat6load.lua" "texfile0(status.filename)")
-- (find-dn6 "texfile.lua" "texfile0")
-- (find-dn6 "heads6.lua" "lua-head")
-- (find-dn6 "heads6.lua" "lua-head" "= tf:getblock()")
-- (find-dn6 "texfile.lua" "TexFile")
-- (find-dn6 "texfile.lua" "TexFile" "getblock =")
-- (find-dn6 "texfile.lua" "TexFile" "head =")
-- (find-dn6 "texfile.lua" "TexFile" "process1 =")


--  _____         _     _                        _               
-- |_   _|____  _| |   (_)_ __   ___  ___    ___| | __ _ ___ ___ 
--   | |/ _ \ \/ / |   | | '_ \ / _ \/ __|  / __| |/ _` / __/ __|
--   | |  __/>  <| |___| | | | |  __/\__ \ | (__| | (_| \__ \__ \
--   |_|\___/_/\_\_____|_|_| |_|\___||___/  \___|_|\__,_|___/___/
--                                                               
-- «TexLines» (to ".TexLines")
-- The TexLines class.
-- The contents of the current .tex file are stored in a TexLines object,
-- in the global variable "texlines".
--
-- Internally, a TexLines object is a just a table returned by
-- splitlines(ee_readfile("foo.tex")) with a "name=" field and a
-- nice metatable.

TexLines = Class {
  type = "TexLines",
  new  = function (name, lines)
      return TexLines({name=name}):setlines(lines)
    end,
  read = function (fname)
      return TexLines.new(fnamenondirectory(fname), ee_readfile(fname))
    end,
  test = function (str)
      local tr = {["L"]="%L", ["D"]="%D", [":"]="%:", ["p"]="\\pu"}
      local tl = TexLines {name="(test)"}
      for c in str:gmatch"." do table.insert(tl, tr[c] or c) end
      return tl
    end,
  __tostring = function (tl) return tl:tostring() end,
  __index = {
    setlines = function (tl, lines)
        if type(lines) == "string" then lines = splitlines(lines) end
        for i=1,#lines do tl[i] = lines[i] end
        return tl
      end,
    nlines = function (tl) return #tl end,
    line = function (tl, i) return tl[i] end,
    --
    head = function (tl, i)
        local li = tl:line(i)
        local p = function (len)
            local s = li:sub(1, len)
            return heads[s] and s
          end
        return li and (p(3) or p(2) or p(1) or p(0))
      end,
    nohead = function (tl, i)
        return tl:line(i):sub(#tl:head(i) + 2)
      end,
    --
    tostring1 = function (tl, i) return format("%3d: %s", i, tl:line(i)) end,
    tostring  = function (tl, i, j)
        local T = {}
        for k=(i or 1),(j or tl:nlines()) do
          table.insert(T, tl:tostring1(k))
        end
        return table.concat(T, "\n")
      end,
    --
    toblock = function (tl)
        return Block {i=1, j=#tl, nline=1, name=tl.name}
      end,
  },
}


--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "block.lua"
heads = {["%L"]={}, ["%D"]={}, ["%:"]={}}

tl = TexLines.test "p DD::: DD DD LLL:::p::p "
= tl
= tl:head(4)
= tl:head(8)

--]]



--  ____  _            _           _               
-- | __ )| | ___   ___| | __   ___| | __ _ ___ ___ 
-- |  _ \| |/ _ \ / __| |/ /  / __| |/ _` / __/ __|
-- | |_) | | (_) | (__|   <  | (__| | (_| \__ \__ \
-- |____/|_|\___/ \___|_|\_\  \___|_|\__,_|___/___/
--                                                 
-- «Block» (to ".Block")
-- The Block class, that is used to represent texfile blocks, head
-- blocks, pu blocks and arbitrary (non-bad) blocks, as described in
-- the section "Heads and blocks" of the article about Dednat6 on
-- TUGBoat:
--   http://angg.twu.net/LATEX/2018tugboat.pdf
--   (tubp 4 "heads-and-blocks")
--   (tub    "heads-and-blocks")
--
-- Internally, a Block object always has fields "i" and "j"; a texfile
-- block also has a field "nline" and a field "name", and a head block
-- has a field "head". So:
--    Block {i=1, j=100, nline=42, name="foo.tex"} --> a texfile block
--    Block {i=5, j=7, head="%:"}                  --> a head block
--    Block {i=2, j=20}                            --> an arbitrary/pu block
--
-- The texfile block for the current file is stored in the global
-- variable "tf", and there is legacy code in other modules of dednat6
-- that does this:
--    i,j,lualines = tf:getblock()
--    chunkname = tf.name..":%L:"..i
--
-- Implementation: "tf:getblock()" uses the global block variable
-- "lastheadblock" (that is set by bl:processheadblock()), reads the
-- lines from i to j from texlines using texlines:line(k), and
-- concatenates them in a string with newlines. There is a method
-- ":getblock()" in TexLines and another in Block - ugly but works!

headblocks = {}   -- a "log" of all the head blocks processed so far

Block = Class {
  type    = "Block",
  __tostring = mytostring,
  __index = {
    firstheadblockin = function (bl, i0, j0)
        local i,j
        for i1=i0,j0 do
          if texlines:head(i1) then i=i1; break end 
        end
        if not i then return end
        local head = texlines:head(i)
        for j1=i+1,j0 do
          if texlines:head(j1) ~= head then
            return Block {i=i, j=j1-1, head=head}
          end 
        end
        return Block {i=i, j=bl.j, head=head}
      end,
    --
    processheadblock = function (bl)
        lastheadblock = bl                    -- for ":getblock()"s
        table.insert(headblocks, bl)
        local action = heads[bl.head].action  -- uses "tf:getblock()"
        if action then action() else print("No action for "..bl.head) end
      end,
    processarbitraryblock = function (bl)
        -- print("process arbitrary:", mytostring(bl))
        local i0 = bl.i
        while true do
          local headbl = bl:firstheadblockin(i0, bl.j)
          if not headbl then return end
          headbl:processheadblock()
          i0 = headbl.j + 1
        end
      end,
    process = function (bl)
        -- print("process:", mytostring(bl))
        if bl.head
        then bl:processheadblock(bl)
        else bl:processarbitraryblock(bl)
        end
      end,
    --
    processuntil = function (bl, puline)
        local publock = Block {i=bl.nline, j=puline-1}
        publock:process()
        bl.nline = puline+1
        return bl
      end,
    --
    getblock = function (bl)
        local i,j,head = lastheadblock.i, lastheadblock.j, lastheadblock.head
        local A = {}
        for k=i,j do
            table.insert(A, texlines:line(k):sub(#head+1))
          end
        return i,j,A
      end,
    getblockstr = function (bl)
        local i,j,A = tf:getblock()
        return i,j,table.concat(A, "\n")
      end,
    -- hyperlink = function (bl)
    --     return "Line "..lastheadblock.i
    --   end,
    hyperlink = function (bl)
        return format("In the \"%s\"-block in lines %d--%d",
                      lastheadblock.head, lastheadblock.i, lastheadblock.j)
      end,
  },
}


--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "block.lua"
heads = {["%L"]="%L", ["%D"]="%D", ["%:"]="%:"}
Block.__index.processheadblock = function (bl) print(mytostring(bl)) end

texlines = TexLines.test "p DD::: DD DD LLL:::p:p"
tf = texlines:toblock()

= texlines
= tf
= tf:processuntil(1)
= tf:processuntil(21)
= tf:processuntil(23)

texlines = TexLines.test "p DD::: DD DD LLL:::p:p"
tf = texlines:toblock()
tf:process()    -- process the whole file

--]]



--  _             __ _ _       ___  
-- | |_ _____  __/ _(_) | ___ / _ \ 
-- | __/ _ \ \/ / |_| | |/ _ \ | | |
-- | ||  __/>  <|  _| | |  __/ |_| |
--  \__\___/_/\_\_| |_|_|\___|\___/ 
--                                  
-- «texfile0» (to ".texfile0")
-- texfile0 and texfile: high-level words to read a .tex file.
-- Replaces this:
--   (find-dn6 "texfile.lua" "texfile0")

texfile0 = function (fname)
    texlines = TexLines.read(fname)
    tf = texlines:toblock()
  end
texfile = function (fname)
    texfile0(fname..".tex")
  end

pu = function (puline) tf:processuntil(puline or tex.inputlineno) end



--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "block.lua"
texfile0("../2018tugboat.tex")
= tf
PP(getmetatable(tf))
= texlines
heads = {
  ["%L"]={action = function (...) PP(tf:getblock()) end},
  ["%D"]={action = function (...) PP(tf:getblock()) end},
  ["%:"]={action = function (...) PP(tf:getblock()) end},
}
tf:process()
tf:processuntil(110)



--]]



-- Local Variables:
-- coding: raw-text-unix
-- End:

