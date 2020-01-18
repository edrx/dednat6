-- stacks.lua: the class Stacks, used by diagstacks and underbrace.
-- This file:
-- http://angg.twu.net/dednat6/dednat6/stacks.lua
-- http://angg.twu.net/dednat6/dednat6/stacks.lua.html
--         (find-angg "dednat6/dednat6/stacks.lua")
--
-- «.Stack»		(to "Stack")
-- «.Stack-tests»	(to "Stack-tests")

-- (find-angg "LUA/lua50init.lua" "Tos")
-- (find-angg "LUA/lua50init.lua" "Tos" "mytabletostring =")
-- This is somewhat similar to mytabletostring, but prints the top
-- element on the top...
mystacktostring = function (stack)
    local f = function (i) return {key=i, val=stack[i]} end
    local ps = map(f, seq(#stack, 1, -1))
    return (Tos{}):ps(ps, "\n")
  end


--  ____  _             _    
-- / ___|| |_ __ _  ___| | __
-- \___ \| __/ _` |/ __| |/ /
--  ___) | || (_| | (__|   < 
-- |____/ \__\__,_|\___|_|\_\
--                           
-- «Stack» (to ".Stack")
-- TODO: unify with: (find-dn6 "diagstacks.lua" "Stack")

push     = function (stack, o)         return stack:push(o)          end
pop      = function (stack)            return stack:pop()            end
popuntil = function (stack, depth)     return stack:dropuntil(depth) end
pick     = function (stack, offset)    return stack:pick(offset)     end
pock     = function (stack, offset, o) return stack:pock(offset, o)  end

Stack = Class {
  type    = "Stack",
  new     = function () return Stack {} end,
  dowords = function (f, bigstr) return Stack{doword=f}:dowords(bigstr):pop() end,
  --
  __tostring = function (s) return mystacktostring(s) end,
  __index = {
    push  = function (s, o) table.insert(s, o); return s end,
    --
    check     = function (s) assert(#s>0, s.msg or "Empty stack"); return s end,
    drop      = function (s) s:check(); s[#s]=nil; return s end,
    dropn     = function (s, n) for i=1,n  do s:drop() end; return s end,
    dropuntil = function (s, n) while #s>n do s:drop() end; return s end,
    clear     = function (s)    return s:dropn(#s) end,
    --
    pop  = function (s) return                            s[#s], s:dropn(1) end,
    pop2 = function (s) return                   s[#s-1], s[#s], s:dropn(2) end,
    pop3 = function (s) return          s[#s-2], s[#s-1], s[#s], s:dropn(3) end,
    pop4 = function (s) return s[#s-3], s[#s-2], s[#s-1], s[#s], s:dropn(4) end,
    --
    pick = function (s, offset) return s[#s-offset] end,
    pock = function (s, offset, o)     s[#s-offset] = o; return s end,
    --
    PP    = function (s) PP(s); return s end,
    print = function (s) print(s); return s end,
    --
    dowords = function (s, bigstr)
        for _,word in ipairs(split(bigstr)) do s:doword(word) end
        return s
      end,
  },
}

--[==[
-- «Stack-tests» (to ".Stack-tests")
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "stacks.lua"
s = Stack.new()
s:push(22):push(33):PP()
= s:clear():push(22):push(33):PP():push(44):PP():dropn(2)
= s:clear():push(22):push(33):PP():push(44):PP():dropn(2):PP():pop()
= Stack.new():push(11):push(22):push(33)

--]==]





-- Local Variables:
-- coding: utf-8-unix
-- End:

