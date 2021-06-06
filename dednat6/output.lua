-- This file:
-- http://angg.twu.net/dednat6/dednat6/output.lua
-- http://angg.twu.net/dednat6/dednat6/output.lua.html
--         (find-angg "dednat6/dednat6/output.lua")
--
-- Sending (Lua-produced) TeX code back to the TeX interpreter requires
-- some preprocessing... see:
--   (find-es "luatex" "comments-in-tex.print")
--   (find-es "luatex" "spurious-omega")
--
-- Usage:
--   \catcode`\^^J=10                     % (find-es "luatex" "spurious-omega")
--   \directlua{output = mytexprint}
--   \directlua{output =  printboth}
-- or: (...)

-- «.deletecomments»		(to "deletecomments")
-- «.Deletecomments-class»	(to "Deletecomments-class")
-- «.DeleteComments-tests»	(to "DeleteComments-tests")
-- «.output»			(to "output")
-- «.output_dnt»		(to "output_dnt")
-- «.write_dnt_file»		(to "write_dnt_file")
-- «.write_single_tex_file»	(to "write_single_tex_file")
-- «.formatt»			(to "formatt")
-- «.bprintt»			(to "bprintt")


-- «deletecomments» (to ".deletecomments")
-- (find-es "luatex" "comments-in-tex.print")
-- Old version:
--   deletecomments = function (str)
--       return (str:gsub("%%[^%%\n]*\n[ \t]*", ""))
--     end
-- The version below (from 2019apr29) is a bit better but still not
-- super-smart. It treats a "%" after a backslash as a comment sign!

deletecomments1 = function (line)
    return line:match"^([^%%]*)"
  end
deletecomments = function (bigstr)
    return (bigstr:gsub("([^\n]+)", deletecomments1))
  end

--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "output.lua"
= deletecomments "a % b % c"
= deletecomments "a % b % c\nd \\% e % f"

--]]



-- «Deletecomments-class»  (to ".Deletecomments-class")
-- New (2021jun05): the class Deletecomments implements a way to
-- delete comments that TRIES to simulate what TeX does. The TeXBook
-- explains in its pages 46--47 that the "eyes" and "mouth" of TeX
-- enter the "State S" (for "skipping blanks") after a "%"; we
-- simulate that by splitting bigstr in a certain way, and then after
-- each "%" we delete the "%..." part of that line plus the
-- whitespaces and newlines in (hopefully) the right places.
--
-- The default for "deletecomments" is still the simpler definition
-- above. To use version based on the DeleteComments class put this in
-- your .tex file:
--
--   %L deletecomments = function (bigstr) return DeleteComments.from(bigstr) end
--
-- See: (find-es "tex" "comments")
--
DeleteComments = Class {
  type  = "DeleteComments",
  split = function (bigstr)
      local A = {}
      for _,li in ipairs(splitlines(bigstr)) do
        local a,b = li:match("^([^%%]*)(.*)")
        table.insert(A, {a, b, "\n"})
      end
      return DeleteComments(A)
    end,
  from = function (bigstr)
      return DeleteComments.split(bigstr):delcomments():concat()
    end,
  __tostring = function (dc) return mytabletostring(dc) end,
  __index = {
      hascomment = function (dc, k) return dc[k][2] ~= "" end,
      endswithcmd = function (dc, k)
          return dc[k][1]:reverse():match("^[A-Za-z]+\\")
        end,
      addspaceaftercmd = function (dc, k)
          dc[k][1] = dc[k][1].." "
        end,
      valid = function (dc, k) return 1 <= k and k <= #dc end,
      ltrim = function (dc, k)
          dc[k][1] = dc[k][1]:match("^[ \t]*(.*)")
        end,
      delcomment = function (dc, k)
          if dc:endswithcmd(k) then dc:addspaceaftercmd(k) end
          dc[k][2] = ""		-- delete the "%..."
          dc[k][3] = ""		-- delete the newline
          if dc:valid(k+1) then dc:ltrim(k+1) end
        end,
      delcomments = function (dc)
          for k=1,#dc do if dc:hascomment(k) then dc:delcomment(k) end end
	  return dc
        end,
      concat = function (dc)
          local bigstr = ""
          for k=1,#dc-1 do bigstr = bigstr..dc[k][1]..dc[k][2]..dc[k][3] end
          if #dc > 0 then bigstr = bigstr..dc[#dc][1]..dc[#dc][2] end
          return bigstr
        end,
  },
}


-- «DeleteComments-tests»  (to ".DeleteComments-tests")
-- (find-es "dednat" "deletecomments-2021")
--[==[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "output.lua"

bigstr = [[
foo%12
  bar\plic%34
  qoo%56
  blep
  bletch
  %
  woo
]]

= deletecomments(bigstr)

dc = DeleteComments.split(bigstr)
= dc
= dc:delcomments()
= dc:concat()

= bigstr
= deletecomments(bigstr)
deletecomments = function (bigstr) return DeleteComments.from(bigstr) end
= deletecomments(bigstr)

--]==]





-- See: (to "write_dnt_file")
dnt_log = ""




--              _               _   
--   ___  _   _| |_ _ __  _   _| |_ 
--  / _ \| | | | __| '_ \| | | | __|
-- | (_) | |_| | |_| |_) | |_| | |_ 
--  \___/ \__,_|\__| .__/ \__,_|\__|
--                 |_|              
--
-- «output»  (to ".output")
-- `output(str)' is the main way to send TeX code from dednat6 to TeX.
-- The TUGBoat article explains this briefly in sec.3.1. See:
--
--   https://tug.org/TUGboat/tb39-3/tb123ochs-dednat.pdf
--   http://angg.twu.net/dednat6/tugboat-rev2.pdf
--
-- The article says:
-- 
--   We saw in sections 1 and 2.2 that the "output" of
--   a %:-block is a series of `\defded's and the "output"
--   of a %D-block is a series of `\defdiags's. We can
--   generalize this. For example, the "output" of
-- 
--     %L output [[\def\Foo{FOO}]]
--     %L output [[\def\Bar{BAR}]]
-- 
--   is:
-- 
--     \def\Foo{FOO}
--     \def\Bar{BAR}
--
-- The default behavior of `output(str)' is `output_verbose(str)',
-- that:
--
--   1) runs tex.print(deletecomments(str)),
--   2) appends str (with comments!) to dnt_log,
--   3) prints the current value of tf.nline to stdout,
--   4) prints str (with comments!) to stdout.
--
-- I always check the output of running `lualatex foo.tex' to see if
-- there were any errors. If there weren't any errors, one of the last
-- lines of the output will be something like
--
--   Output written on foo.pdf (42 pages, 1234567 bytes).
--
-- Making `output(str)' print to stdout means that all TeX code that
-- dednat6 produces is shown in the output of `lualatex foo.tex'; I
-- find that this helps debugging.

-- «output_dnt»  (to ".output_dnt")
-- (find-es "dednat" "output_dnt")
output_dnt = function (str)
    dnt_log = dnt_log..str.."\n"
  end

output_quiet = function (str)
    tex.print(deletecomments(str))
    output_dnt(str)
  end
output_verbose = function (str)
    print("% Running the \\pu at line "..tf.nline)
    output_quiet(str)
    print(str)
  end
output  = output_verbose
quiet   = function () output = output_quiet   end
verbose = function () output = output_verbose end




--                _ _              _       _        __ _ _      
-- __      ___ __(_) |_ ___     __| |_ __ | |_     / _(_) | ___ 
-- \ \ /\ / / '__| | __/ _ \   / _` | '_ \| __|   | |_| | |/ _ \
--  \ V  V /| |  | | ||  __/  | (_| | | | | |_    |  _| | |  __/
--   \_/\_/ |_|  |_|\__\___|___\__,_|_| |_|\__|___|_| |_|_|\___|
--                        |_____|            |_____|            
--
-- «write_dnt_file» (to ".write_dnt_file")
-- Use this to _sort of_ emulate the behavior of dednat4.
-- See: http://angg.twu.net/dednat6.html#no-lua
--      (find-LATEX "dednat6load.lua")
--      (find-dn6 "options6.lua")
--      (find-dn6file "options6.lua" "dooptions_t =")
-- The name of the current .tex file is stored in texlines.name:
--   (find-dn6 "block.lua" "texfile0")
--   (find-dn6 "block.lua" "TexLines")
--   (find-dn6 "block.lua" "TexLines" "read =")
--
write_dnt_file  = function (fname)
    fname = fname or texlines.name:gsub("%.tex$", "")..".dnt"
    print("% Writing: "..fname)
    writefile(fname, dnt_log)
  end

--                _ _               _             _      
-- __      ___ __(_) |_ ___     ___(_)_ __   __ _| | ___ 
-- \ \ /\ / / '__| | __/ _ \   / __| | '_ \ / _` | |/ _ \
--  \ V  V /| |  | | ||  __/   \__ \ | | | | (_| | |  __/
--   \_/\_/ |_|  |_|\__\___|___|___/_|_| |_|\__, |_|\___|
--                        |_____|           |___/        
--
-- «write_single_tex_file»  (to ".write_single_tex_file")
-- Experimental, 2019aug16
write_single_tex_file__pat = "^(.-\n)(%s*)(\\input\\jobname.dnt[^\n]*\n)(.*)$"
write_single_tex_file = function (fname_out)
    local fname_in = status.filename
    local bigstr_in = ee_readfile(fname_in)
    local a,spaces,inputdnt,b = bigstr_in:match(write_single_tex_file__pat)
    local header = format("%% Generated from %s\n"..
            "%% using write_single_tex_file(\"%s\")\n%%\n",
            fname_in, fname_out)
    local bigstr_out = header..a..spaces.."% "..inputdnt..dnt_log.."\n"..b
    print("% Writing: "..fname_out)
    ee_writefile(fname_out, bigstr_out)
  end




-- I don't use the functions below this point much...
-- I only use them to generate code for pict2e.

-- «formatt» (to ".formatt")
-- (find-es "lua5" "formatt-and-printt")
formatt = function (...)
    local A = {...}
    for i=1,#A do if type(A[i]=="table") then A[i] = tostring(A[i]) end end
    return format(unpack(A))
  end
printt  = function (...) print(formatt(...)) end
outputt = function (...) output(formatt(...)) end

--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "output.lua"
dofile "picture.lua"
p, q = v(3,4), v(5,6)
= formatt("%s--%s", p, q)  --> (3,4)--(5,6)

--]]




-- «bprintt» (to ".bprintt")
-- Usage in the REPL:
--   bprint, out = makebprint("verbose")
--   bprint("%s--%s", v(2,3), v(4,5))
--   bprint("%s--%s", v(20,30), v(40,50))
--   = out()
-- Usage in a function:
--   local bprint, out = makebprint()
--   bprint("%s--%s", v(2,3), v(4,5))
--   bprint("%s--%s", v(20,30), v(40,50))
--   return out()
makebprint = function (verbose)
    local buffer = {}
    local bprint = function (...) table.insert(buffer, formatt(...)) end
    local out    = function () return table.concat(buffer, "\n") end
    if verbose then
      local bprint0 = bprint
      bprint = function (...) printt(...); bprint0(...) end
    end
    return bprint, out, buffer
  end





-- Local Variables:
-- coding: utf-8-unix
-- End:

