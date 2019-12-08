-- lualoader.lua: make LuaTeX's "require" behave more like Lua's
-- This file:
-- http://angg.twu.net/dednat6/dednat6/lualoader.lua
-- http://angg.twu.net/dednat6/dednat6/lualoader.lua.html
--         (find-angg "dednat6/dednat6/lualoader.lua")
--
-- Loaded by:
--   (find-dn6 "dednat6.lua" "luatex-require")
--   (find-dn6 "dednat6.lua" "luatex-require" "lualoader")
-- Code taken from:
--   http://tug.org/pipermail/luatex/2015-February/005073.html
--   http://lua-users.org/wiki/LuaModulesLoader
--   (find-es "luatex" "require")
--   (find-LATEX "lualoader.lua")
--   (find-LATEXgrep "grep -nH -e lualoader *.tex")
--
-- Compatibility:
-- See: http://www.lua.org/manual/5.1/manual.html#pdf-package.loaders
--      http://www.lua.org/manual/5.2/manual.html#pdf-package.searchers
--      http://www.lua.org/manual/5.1/manual.html#pdf-loadstring
--      http://www.lua.org/manual/5.2/manual.html#8.2 loadstring is deprecated
package.loaders = package.loaders or package.searchers
loadstring = loadstring or load

local function lualoader(modulename)
  local errmsg = ""
  -- Find source
  local modulepath = string.gsub(modulename, "%.", "/")
  for path in string.gmatch(package.path, "([^;]+)") do
    local filename = string.gsub(path, "%?", modulepath)
    local file = io.open(filename, "rb")
    if file then
      -- Compile and return the module.
      -- Was:
      --   return assert(loadstring(assert(file:read("*a")), filename))
      -- but due to this issue,
      --   http://tug.org/pipermail/luatex/2017-July/006589.html
      --   http://tug.org/pipermail/luatex/2017-July/006590.html
      -- I had to change it to:
      file:close()
      return assert(loadfile(filename))
    end
    errmsg = errmsg.."\n\tno file '"..filename.."' (checked with custom loader)"
  end
  return errmsg
end

table.insert(package.loaders, 2, lualoader)




-- Local Variables:
-- coding: raw-text-unix
-- End:
