-- errors.lua:
-- This file:
--   http://angg.twu.net/dednat6/dednat6/errors.lua.html
--   http://angg.twu.net/dednat6/dednat6/errors.lua
--           (find-angg "dednat6/dednat6/errors.lua")
-- Author: Eduardo Ochs <eduardoochs@gmail.com>
-- Version: 2011feb27?
-- License: GPL3
--

require "eoo"         -- (find-dn6 "eoo.lua")

error_ = function (str)
    print((fname or "<nil>")..":"..(nline or "<nil>")..":"..(str or "?"))
    printf(" (find-fline %q %d)", (fname or "<nil>"), (nline or 0))
    error()
  end
Error = function (str) -- generic error
    error_(" "..(str or "?"))
  end
FError = function (str)  -- error in a Forth word
    error_((word or "<nil>")..": "..(str or "?"))
  end
FGetword = function (str)
    return getword() or FError(str or "missing argument")
  end


FGetword  = function () return getword() or FError("missing argument") end
FGetword1 = function () return getword() or FError("missing 1st argument") end
FGetword2 = function () return getword() or FError("missing 2nd argument") end




-- Local Variables:
-- coding:             utf-8-unix
-- End:
