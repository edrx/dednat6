-- eoo.lua: Edrx'x simple OO scheme, with explanations.
-- This file:
--   http://angg.twu.net/LATEX/dednat6/eoo.lua.html
--   http://angg.twu.net/LATEX/dednat6/eoo.lua
--                          (find-dn6 "eoo.lua")
-- Author: Eduardo Ochs <eduardoochs@gmail.com>
-- Version: 2019feb22
-- License: GPL3
--
-- A very simple object system.
-- The metatable of each object points to its class;
-- classes are callable, and act as creators.
-- New classes can be created with, e.g.:
--   Circle = Class { type = "Circle", __index = {...} }
-- then:
--   Circle {size = 1}
-- sets the metatable of the table {size = 1} to Circle,
-- and returns the table {size = 1} (with its __mt modified).
-- See the box diagrams below.
--
-- Originally from: (find-angg "LUA/canvas2.lua"  "Class")
-- A tool:          (find-angg ".emacs.templates" "class")

-- «.Class»		(to "Class")
-- «.otype»		(to "otype")

-- «.__mt»		(to "__mt")
-- «.__mt-box»		(to "__mt-box")
-- «.lambda»		(to "lambda")
-- «.Class-short»	(to "Class-short")
-- «.Vector»		(to "Vector")
-- «.Vector-box»	(to "Vector-box")
-- «.Vector-reductions»	(to "Vector-reductions")
-- «.Class-boxes»	(to "Class-boxes")



-- «Class» (to ".Class")
-- The code for "Class" is just these five lines.
Class = {
    type   = "Class",
    __call = function (class, o) return setmetatable(o, class) end,
  }
setmetatable(Class, Class)


-- «otype» (to ".otype")
-- This is useful sometimes.
-- "otype(o)" works like "type(o)", except on my "objects".
otype = function (o)
    local  mt = getmetatable(o)
    return mt and mt.type or type(o)
  end


-- «over» (to ".over")
-- Code for inheritance.
-- Note: I have used this only a handful of times!
-- See: (find-dn6 "diagstacks.lua" "MetaStack")
--      (find-dn6 "diagstacks.lua" "MetaStack" "MetaStack = ClassOver(Stack) {")
over = function (uppertable)
    return function (lowertable)
        setmetatable(uppertable, {__index=lowertable})
        return uppertable
      end
  end

ClassOver = function (upperclassmt)
    return function (lowerclass)
        setmetatable(upperclassmt.__index, {__index=lowerclass.__index})
        return Class(upperclassmt)
      end
  end




-- The first section was adapted from:
--   http://angg.twu.net/__mt.html
--             (find-TH "__mt")
--[[


  «__mt» (to ".__mt")

1. The __mt notation
====================
Metatables are explained in detail in section 2.8 of the Lua manual,

  (find-lua51manual "#2.8" "Metatables")
  (find-lua51manual "#pdf-setmetatable")
  
but I found out that a certain abuse of language - writing "A.__mt"
for the metatable of A - simplifies a lot the description of what
happens in the cases where the metatables are used.

Let's use the squiggly arrow, "-~->", for _rewritings_. The three
rewritings below are standard:

                     T.__foo  -~->  T["foo"]
                foo:bar(...)  -~->  foo.bar(foo, ...)
  function foo (...) ... end  -~->  foo = function (...) ... end

They are described in these sections of the manual:

  (find-lua51manual "#2.2"   "a.name")
  (find-lua51manual "#2.3"   "var.Name")
  (find-lua51manual "#2.5.8" "v:name(args)")
  (find-lua51manual "#2.5.9" "function f () body end")

If A and B are tables having the same non-nil metatable, then, modulo
details (error conditions, etc), we have:

  A + B        -~->  A.__mt.__add(A, B)
  A - B        -~->  A.__mt.__sub(A, B)
  A * B        -~->  A.__mt.__mul(A, B)
  A / B        -~->  A.__mt.__div(A, B)
  A % B        -~->  A.__mt.__mod(A, B)
  A ^ B        -~->  A.__mt.__pow(A, B)
  - A          -~->  A.__mt.__unm(A, A)
  A .. B       -~->  A.__mt.__concat(A, B)
  #A           -~->  A.__mt.__len(A, A)
  A == B       -~->  A.__mt.__eq(A, B)
  A ~= B       -~->  not (A == B)
  A < B        -~->  A.__mt.__lt(A, B)
  A <= B       -~->  A.__mt.__le(A, B)
                     (or not (B < A) in the absence of __le)
  A[k]         -~->  A.__mt.__index(A, k)
  A[k] = v     -~->  A.__mt.__newindex(A, k, v)
  A(...)       -~->  A.__mt.__call(A, ...)
  tostring(A)  -~->  A.__mt.__tostring(A)

Note that the listing above is a translation to the __mt notation of
the _cases involving metatables_ that are mentioned in these sections
of the manual:

  (find-lua51manual "#2.8" "op1 + op2")
  (find-lua51manual "#pdf-tostring")

and we follow the order in which these cases are listed in the manual.




 «__mt-box» (to ".__mt-box")

2. The __mt notation in box diagrams
====================================
We can depict the values of a and b after these assignments

  a = {10, 20, 30}
  b = {11, a, "foo", print}

as:

      /---+---------\         /---+----\
  b = | 1 :    11   |     a = | 1 : 10 |
      | 2 :     * ----------> | 2 : 20 |
      | 3 :  "foo"  |         | 3 : 30 |
      | 4 : <print> |         \---+----/
      \---+---------/

and if after that we do this, using the __mt notation above,

  T = {__index = b}
  a.__mt = T

we will have:

      /---+---------\         /---+----\
  b = | 1 :    11   |     a = | 1 : 10 |
      | 2 :     * ----------> | 2 : 20 |
      | 3 :  "foo"  |         | 3 : 30 |
      | 4 : <print> |         \mt-+----/
      \---+---------/           |
           ^                    v
           |                 /-----------+----\
           |             T = | "__index" : * -----\
           |                 \-----------+----/   |
           |                                      |
           \--------------------------------------/

The pointer to the metatable is represented as a "mt" at the floor
instead of as a (key, value) pair/line inside the box, Compare:

      /---+----\                     /--------+----\
  a = | 1 : 10 |	 	 a = |    1   : 10 |
      | 2 : 20 |   instead of: 	     |    2   : 20 |
      | 3 : 30 |		     |    3   : 30 |
      \mt-+----/		     | "__mt" :  * -----> T
        |                            \--------+----/
        \----> T

Using these diagrams it is easy to calculate a[4] by a series of
reductions. Without metatables we would have a[4] = nil, so:

  a[4]  -~->  a.__mt.__index[4]
        -~->       T.__index[4]
        -~->               b[4]
        -~->              print




 «lambda» (to ".lambda")

3. A lambda notation for Lua functions
======================================
Gavin Wraith implemented two shorthands in his RiscLua: "\" is a
shorthand for "function" and "=>" is a shorthand for "return". With
them we can write, for example,

  square = \(x) => x*x end

instead of:

  square = function (x) return x*x end

See:
  http://www.wra1th.plus.com/lua/notes/Scope.html
  (find-es "lua5" "risclua")

We will also use the notation [var := value] for substituion of a
single variable, and [var1 := value1, var2 := value2 ...] for
simultaneous substitution. A beta-reduction can be calculated in two
steps:

  (\(x) => x*x end)(5)  -~->  (x*x)[x:=5]
                        -^->   5*5



 «Class-short» (to ".Class-short")

4. "Class" with shorthands
==========================
Remember that "Class" and "otype" were defined as:

  Class = {
      type   = "Class",
      __call = function (class, o) return setmetatable(o, class) end,
    }
  setmetatable(Class, Class)

  otype = function (o)  -- works like type, except on my "objects"
      local  mt = getmetatable(o)
      return mt and mt.type or type(o)
    end

With the shorthands for __mt and lambda we can rewrite these as:

  Class = { type   = "Class",
            __call = \(class, o) o.__mt = class; => o end,
          }
  Class.__mt = Class
  otype = \(o) local mt = o.__mt; => (mt and mt.type or type(o)) end




 «Vector» (to ".Vector")

5. A class "Vector"
===================
Consider this demo code:

--[=[

 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "eoo.lua"   -- this file
Vector = Class {
  type       = "Vector",
  __add      = function (V, W) return Vector {V[1]+W[1], V[2]+W[2]} end,
  __tostring = function (V) return "("..V[1]..","..V[2]..")" end,
  __index    = {
    norm = function (V) return math.sqrt(V[1]^2 + V[2]^2) end,
  },
}
v = Vector  {3,  4}  --  v = { 3,  4, __mt = Vector}
w = Vector {20, 30}  --  w = {20, 30, __mt = Vector}
print(v)             --> (3,4)
print(v + w)         --> (23,34)
print(v:norm())      --> 5
print( type(v))      --> table
print(otype(v))      --> Vector
print( type(""))     --> string
print(otype(""))     --> string

--]=]

After running the line "w = ..." we will have this:

  Class  = {
    type       = "Class",
    __call     = \(class, o) => o.__mt = class end,
    __mt       = Class,
  }
  Vector = {
    type       = "Vector",
    __add      = \(V, W) => {V[1]+W[1], V[2]+W[2]} end,
    __tostring = \(V) => "("..V[1]..","..V[2]..")" end,
    __index    = { norm = \(V) => math.sqrt(V[1]^2+V[2]^2) end },
    __mt       = Class,
  }
  v = {
    3,
    4,
    __mt = Vector,
  }
  w = {
    20,
    30,
    __mt = Vector,
  }



 «Vector-box» (to ".Vector-box")

6. The "Vector" demo in box diagrams
====================================
...or, in box diagrams:

   <fcal> = function (class, o) return setmetatable(o, class) end
   <fadd> = function (V, W)     return Vector {V[1]+W[1], V[2]+W[2]} end
   <ftos> = function (V)        return "("..V[1]..","..V[2]..")" end,
   <fnor> = function (V)        return math.sqrt(V[1]^2 + V[2]^2) end
 
            /---+---\       /---+----\
        v = | 1 : 3 |   w = | 1 : 20 |
            | 2 : 4 |       | 2 : 30 |
            \mt-+---/       \mt-+----/
              :  ............/
              : /
              vv
            /--------------+----------\
   Vector = | "type"       : "Vector" |
            | "__add"      : <fadd>   |
            | "__tostring" : <ftos>   |    /--------+--------\
            | "__index"    :    * .......> | "norm" : <fnor> |
            \mt------------+----------/    \--------+--------/
              :
              v
            /----------+---------\
    Class = | "type"   : "Class" |
            | "__call" : <fcal>  |
            \mt--------+---------/
              :    ^
              \..../



 «Vector-reductions» (to ".Vector-reductions")

7. The "Vector" demo: reductions
================================
We can use reductions to understand "Vector {3, 4}" and "v:norm()".
Being slightly informal at some points, we have:

        Vector {3, 4}
  --~-> Vector({3, 4})
  --~-> Vector.__mt.__call(Vector, {3, 4})
  --~->       Class.__call(Vector, {3, 4})
  --~->             <fcal>(Vector, {3, 4})
  --~-> (\(class, o) o.__mt=class; => o) (Vector, {3, 4})
  --~->             (o.__mt=class; => o) [o:={3, 4}), class:=Vector]
  --~->                                      {3, 4, __mt=Vector}

        v = Vector {3, 4}
  --~-> v =        {3, 4, __mt=Vector}

and:
  
  v:norm()
  --~->  {3, 4, __mt=Vector}:norm()
  --~->  {3, 4, __mt=Vector}.norm             ({3, 4, __mt=Vector})
  --~->  {3, 4, __mt=Vector}.__mt.__index.norm({3, 4, __mt=Vector})
  --~->                    Vector.__index.norm({3, 4, __mt=Vector})
  --~-> (\(V) => math.sqrt(V[1]^2+V[2]^2) end)({3, 4, __mt=Vector})
  --~->         (math.sqrt(V[1]^2+V[2]^2)) [V:={3, 4, __mt=Vector}]
  --~->          math.sqrt(   3^2+   4^2)
  --~->          math.sqrt(           25)
  --~->                                5
 


 «Class-boxes» (to ".Class-boxes")

6. Class boxes
==============
Here's another convention that becomes practical when we get used to
the notations above: the "Class box". A Class box for "Vector" depicts
Vector on top of Vector.__index, with a horizontal line separating
them, and the "__index" and "__class" entries of Vector become
implicit in the Class box. We get:

            /---+---\       /---+----\
        v = | 1 : 3 |   w = | 1 : 20 |
            | 2 : 4 |       | 2 : 30 |
            \mt-+---/       \mt-+----/
              :  ............/
              : /
              vv
            /-Class--------+----------\
   Vector = | "type"       : "Vector" |
            | "__add"      : <fadd>   |
            | "__tostring" : <ftos>   |
            +--------------+----------|
            | "norm"       : <fnor>   |
            \--------------+----------/

--]]






-- Local Variables:
-- coding:             raw-text-unix
-- ee-anchor-format:   "«%s»"
-- End:
