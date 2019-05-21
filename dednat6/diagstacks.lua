-- diagstacks.lua: the stack, the metastack, and the arrays "nodes" and "arrows".
-- This file:
--   http://angg.twu.net/dednat6/diagstacks.lua.html
--   http://angg.twu.net/dednat6/diagstacks.lua
--                    (find-dn6 "diagstacks.lua")
-- Author: Eduardo Ochs <eduardoochs@gmail.com>
-- Version: 2015aug16
-- License: GPL3
--



-- «.Stack»		(to "Stack")
-- «.MetaStack»		(to "MetaStack")
-- «.nodes»		(to "nodes")
-- «.arrows»		(to "arrows")


require "stacks"   -- (find-dn6 "stacks.lua")


-- «Stack»  (to ".Stack")
-- TODO: unify with: (find-dn6 "stacks.lua" "Stack")
--[==[
push = function (stack, o) table.insert(stack, o) end
pop  = function (stack, msg)
    assert(#stack > 0, msg or "Empty stack")
    return table.remove(stack)
  end
popuntil = function (stack, depth) while #stack > depth do pop(stack) end end
pick = function (stack, offset) return stack[#stack - offset] end
pock = function (stack, offset, o)     stack[#stack - offset] = o end

Stack = Class {
  type    = "Stack",
  __tostring = function (s) return mytabletostring(s) end,
  __index = {
    push     = push, 
    pop      = pop,
    popuntil = popuntil,
    clear    = function (s) s:popuntil(0) end,
    pick     = pick,
    pock     = pock,
  },
}
-- Current fragilities: pushing a nil is a no-op;
-- and pick and pock do not check depth.
-- Beware: in dednat4 we stored the stack elements in the "wrong"
-- order just to make pick and pock trivial to implement (tos was
-- ds[1] in dednat4)... Now the conventions are:
--   ds:pick(0)       returns the tos ("top of stack")
--   ds:pick(1)       returns the element below tos
--   ds:pock(0, "a")  replaces the tos by "a"
--   ds:pock(1, "b")  replaces the element below tos by "b"
--]==]

ds = Stack {}     -- (find-miniforthgempage 3  "DS={ 5 }")






-- «MetaStack»  (to ".MetaStack")
-- (find-dn6 "diagforth.lua" "metastack")
MetaStack = ClassOver(Stack) {
  type    = "MetaStack",
  __tostring = function (s) return mytostring(s) end,
  __index = {
    ppush = function (ms) push(ms, #(ms.stack)) end,
    ppop  = function (ms) popuntil(ms.stack, pop(ms)) end,
    metapick = function (ms, offset) return ms.stack[ms:pick(0) + offset] end,
  },
}
depths = MetaStack {stack=ds, msg="Empty metastack"}








-- «nodes»  (to ".nodes")
nodes = VerticalTable {}        -- has numeric and string indices
storenode = function (node)
    table.insert(nodes, node)
    node.noden = #nodes         -- nodes[node.noden] == node
    if node.tag then            -- was: "and not nodes[node.tag]"...
      nodes[node.tag] = node    -- nodes[node.tag] == node
    end
    return node
  end

-- «arrows»  (to ".arrows")
arrows = VerticalTable {}       -- has numeric and string indices
storearrow = function (arrow)
    table.insert(arrows, arrow)
    arrow.arrown = #arrows      -- arrows[arrow.arrown] == arrow
    if arrow.tag then           -- (unused at the moment)
      arrows[arrow.tag] = arrow -- arrows[arrow.tag] == arrow
    end
    return arrow
  end



-- dump-to: tests
--[==[
--]==]

-- Local Variables:
-- coding:             raw-text-unix
-- ee-anchor-format:   "«%s»"
-- End:
