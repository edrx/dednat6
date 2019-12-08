-- texfile.lua: the TexFile class for dednat6 (obsolete).
-- This file:
--   http://angg.twu.net/dednat6/dednat6/texfile.lua
--   http://angg.twu.net/dednat6/dednat6/texfile.lua.html
--           (find-angg "dednat6/dednat6/texfile.lua")
-- Superseded by:
--   http://angg.twu.net/dednat6/dednat6/block.lua
--   http://angg.twu.net/dednat6/dednat6/block.lua.html
--           (find-angg "dednat6/dednat6/block.lua")
--
-- Idea: we read each .tex file into a TexFile object.
-- Older version: (find-angg "LUA/picture.lua" "Texfile")
-- Newer version: (find-dn6 "block.lua")
--                (find-dn6 "block.lua" "texfile0" "tf = ")
--
-- «.TexFile»		(to "TexFile")
-- «.texfile0»		(to "texfile0")
-- «.processbigstr»	(to "processbigstr")
-- «.texfiletest»	(to "texfiletest")
-- «.TexFile-tests»	(to "TexFile-tests")


require "heads6"       -- (find-dn6 "heads6.lua")


--  _____          __ _ _             _
-- |_   _|____  __/ _(_) | ___    ___| | __ _ ___ ___
--   | |/ _ \ \/ / |_| | |/ _ \  / __| |/ _` / __/ __|
--   | |  __/>  <|  _| | |  __/ | (__| | (_| \__ \__ \
--   |_|\___/_/\_\_| |_|_|\___|  \___|_|\__,_|___/___/
--
-- «TexFile» (to ".TexFile")

TexFile = Class {
  type = "TexFile",
  new = function (name, bigstr)
      return TexFile({name=name}):setlines(bigstr)
    end,
  read = function (fname)
      -- fname = fname or tex.jobname
      return TexFile.new(fnamenondirectory(fname), ee_readfile(fname))
    end,
  fromstr = function (bigstr, name)
      return TexFile.new(name or "(no name)", bigstr)
    end,
  __index = {
    setlines = function (tf, bigstr)
        tf.lines = splitlines(bigstr)
        tf.lines.abbrev  = {}
        tf.lines.begriff = {}
        tf.lines.diag    = {}
        tf.lines.lua     = {}
        tf.lines.tree    = {}
        tf.lines.zrect   = {}
        tf.blocks = {}
        tf.nline = 1
        return tf
      end,
    head = function (tf, i)
        local li = tf.lines[i or tf.nline]
        local p = function (len) return heads[li:sub(1, len)] end
        return li and (p(3) or p(2) or p(1) or p(0))
      end,
    nexthead  = function (tf)    return tf:head(tf.nline + 1) end,
    valid     = function (tf, i) return (i or tf.nline) <= #(tf.lines) end,
    nextvalid = function (tf)    return (tf.nline + 1)  <= #(tf.lines) end,
    eof       = function (tf)    return not tf:valid() end,
    advance   = function (tf)    tf.nline = tf.nline + 1 end,
    getij = function (tf)
        local i = tf.nline
        tf.thishead = tf:head()
        while tf:nextvalid() and tf:nexthead() == tf.thishead do tf:advance() end
        local j = tf.nline
        return i,j
      end,
    getrest = function (tf, i)
        local headstr = tf.thishead.headstr
        return untabify(tf.lines[i]):sub(#headstr+2)
      end,
    getblock = function (tf)
        local i,j = tf:getij()
        local name = tf.thishead.name
        local rests = {}
        for k=i,j do
          local rest = tf:getrest(k)
          if tf.lines[name] then tf.lines[name][k] = rest end
          table.insert(rests, rest)
        end
        table.insert(tf.blocks, {i=i, j=j, name=name})
        return i,j,rests
      end,
    process1 = function (tf)
        linestr = tf.lines[tf.nline]
        -- PP(tf:head().headstr, linestr)
        local action = tf:head().action
        if action then action() end
        tf:advance()
      end,
    process = function (tf) while not tf:eof() do tf:process1() end end,
    processuntil = function (tf, nline)
        nline = nline or tex.inputlineno
        while not tf:eof() and tf.nline < nline do tf:process1() end
      end,
    --
    hyperlink = function (tf)
        return format(tf.fmt or hyperlinkfmt or "Line %s", tf.nline)
      end,
    --
    addline = function (tf, li)
        table.insert(tf.lines, li)
        return tf
      end,
    processuntilend = function (tf) tf:processuntil(#tf.lines + 1) end,
  },
}

-- «texfile0» (to ".texfile0")
texfile0 = function (fname) tf = TexFile.read(fname) end
texfile = function (fname) texfile0(fname..".tex") end
pu = function () tf:processuntil() end

-- «processbigstr» (to ".processbigstr")
-- (find-es "dednat" "processbigstr")
processbigstr = function (bigstr)
    output = print
    tf = TexFile.new(immed, bigstr)
    tf:processuntilend()
  end

-- «texfiletest» (to ".texfiletest")
-- See: (find-dn6 "heads6.lua" "heads-test")
texfiletest = function ()
    tf  = TexFile.new("test", "")
    add = function (li) tf:addline(li) end
    pu  = function () tf:processuntilend() end
    output = print
  end

-- «Texfile-tests» (to ".Texfile-tests")
--[==[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "texfile.lua"

-- (find-LATEX "2008dclosed.tex")
tf = TexFile.read "~/LATEX/2008dclosed.tex"
-- while tf.nline <= #tf.lines do
while not tf:eof() do
  tf:getblock()
  local nb = #tf.blocks
  PP(nb, tf.blocks[nb])
  tf:advance()
end
= tf.nline
= #tf.lines


 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "texfile.lua"
tf = TexFile.new("1", [[
One
%L print(2,
%L  22)
Two
%L print(3)
End
]])
tf:process()
PP(tf.blocks)
PP(tf)

while tf.nline <= #tf.lines do
  tf:getblock()
  local nb = #tf.blocks
  PP(nb, tf.blocks[nb])
  tf:advance()
end

--]==]






-- Local Variables:
-- coding: raw-text-unix
-- End:
