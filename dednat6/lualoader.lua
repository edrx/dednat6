-- lualoader.lua: make LuaTeX's "require" behave more like Lua's
-- This file:
-- http://angg.twu.net/dednat6/dednat6/lualoader.lua
-- http://angg.twu.net/dednat6/dednat6/lualoader.lua.html
--         (find-angg "dednat6/dednat6/lualoader.lua")
-- By Eduardo Ochs <eduardoochs@gmail.com>
-- Version: 2020nov06
--
-- Loaded by:
--   (find-dn6 "dednat6.lua" "luatex-require")
--   (find-dn6 "dednat6.lua" "luatex-require" "lualoader")

-- «.compatibility»		(to "compatibility")
-- «.dednatlualoader»		(to "dednatlualoader")
-- «.adddednatlualoader»	(to "adddednatlualoader")
-- «.temporary-fix»		(to "temporary-fix")



-- «compatibility»  (to ".compatibility")
-- Compatibility stuff.
-- See: http://www.lua.org/manual/5.1/manual.html#pdf-package.loaders
--      http://www.lua.org/manual/5.2/manual.html#pdf-package.searchers
--      http://www.lua.org/manual/5.1/manual.html#pdf-loadstring
--      http://www.lua.org/manual/5.2/manual.html#8.2 loadstring is deprecated
--      http://www.lua.org/manual/5.2/manual.html#8.2 .loaders -> .searchers
package.searchers = package.searchers or package.loaders
loadstring = loadstring or load



-- «dednatlualoader»  (to ".dednatlualoader")
-- Based on: http://lua-users.org/wiki/LuaModulesLoader
-- See: http://tug.org/pipermail/luatex/2015-February/005071.html (problem)
--      http://tug.org/pipermail/luatex/2015-February/005073.html (solution)
--      (find-es "luatex" "require")
--
dednatlualoader = function (modulename)
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



-- «adddednatlualoader»  (to ".adddednatlualoader")
-- The default action is to add dednatlualoader to package.searchers,
-- but the "if" below lets me hack that while I don't I find a solution
-- to this problem:
--   https://tug.org/pipermail/luatex/2020-November/007426.html
--   https://github.com/latex3/lualibs/issues/4
if adddednatlualoader then
  adddednatlualoader()
else
  table.insert(package.searchers, 2, dednatlualoader)
end



-- «temporary-fix»  (to ".temporary-fix")
-- % If you are using TeXLive/MikTeX/whateverTeX 2020
-- % and dednat6 doesn't work there, a ___TEMPORARY SOLUTION___
-- % is to install a new dednat6 from
-- % 
-- %   http://angg.twu.net/dednat6.zip
-- % 
-- % and then add this to your .tex file:
--
-- \directlua{adddednatlualoader = function ()
--     require = function (stem)
--         local fname = dednat6dir..stem..".lua"
--         package.loaded[stem] = package.loaded[stem] or dofile(fname) or fname
--       end
--   end}
--
-- % just before the:
--
-- \catcode`\^^J=10
-- \directlua{dofile "dednat6load.lua"}  % (find-LATEX "dednat6load.lua")





-- Local Variables:
-- coding: raw-text-unix
-- End:
