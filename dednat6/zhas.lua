-- zhas.lua: ZHAs, cuts, and mixed LaTeX/ascii pictures of ZHAs and cuts.
-- This file:
-- http://angg.twu.net/dednat6/zhas.lua
-- http://angg.twu.net/dednat6/zhas.lua.html
--  (find-dn6                 "zhas.lua")
--
-- See these links for what are ZHAs:
--   http://angg.twu.net/LATEX/2017planar-has-1.pdf
--   http://angg.twu.net/math-b.html#zhas-for-children-2
--



-- «.ZHA»			(to "ZHA")
-- «.ZHA-connectives»		(to "ZHA-connectives")
-- «.ZHA-getcuts»		(to "ZHA-getcuts")
-- «.ZHA-walls»			(to "ZHA-walls")
-- «.ZHA-shrinktop»		(to "ZHA-shrinktop")
-- «.ZHA-tests»			(to "ZHA-tests")
-- «.ZHA-tests-walls»		(to "ZHA-tests-walls")
-- «.ZHA-test-connectives»	(to "ZHA-test-connectives")
-- «.ZHA-test-generators»	(to "ZHA-test-generators")
-- «.ZHA-test-shrinktop»	(to "ZHA-test-shrinktop")
-- «.shortoperators»		(to "shortoperators")
-- «.shortoperators-tests»	(to "shortoperators-tests")
-- «.Cuts»			(to "Cuts")
-- «.Cuts-tests»		(to "Cuts-tests")
-- «.MixedPicture»		(to "MixedPicture")
-- «.mpnew»			(to "mpnew")
-- «.mpnewJ»			(to "mpnewJ")
-- «.MixedPicture-cuts»		(to "MixedPicture-cuts")
-- «.MixedPicture-zha»		(to "MixedPicture-zha")
-- «.MixedPicture-tests»	(to "MixedPicture-tests")
-- «.MixedPicture-zhalrf-tests»	(to "MixedPicture-zhalrf-tests")
-- «.MixedPicture-arch-tests»	(to "MixedPicture-arch-tests")
-- «.MixedPicture-zset-tests»	(to "MixedPicture-zset-tests")
-- «.MixedPicture-J-tests»	(to "MixedPicture-J-tests")
-- «.drawtwocolgraph»		(to "drawtwocolgraph")
-- «.drawtwocolgraph-tests»	(to "drawtwocolgraph-tests")
-- «.VCuts»			(to "VCuts")
-- «.VCuts-tests»		(to "VCuts-tests")
-- «.TCG»			(to "TCG")
-- «.TGC-tests»			(to "TGC-tests")
-- «.asciirectpoints»		(to "asciirectpoints")
-- «.asciirectpoints-tests»	(to "asciirectpoints-tests")

require "picture"      -- (find-dn6 "picture.lua")


checkrange = function(a, b, c, err)
    if a <= b and b <= c then return true end
    if err then error(format("%s", err, a, b, c)) end
  end
isint = function (n) return math.floor(n) == n end




--  ______   _    _
-- |__  / | | |  / \
--   / /| |_| | / _ \
--  / /_|  _  |/ ___ \
-- /____|_| |_/_/   \_\
--
-- «ZHA» (to ".ZHA")

specwidths = function (spec)
    local copydigit = function (s) return s:sub(1, 1):rep(#s) end
    return (spec:gsub("[1-9][LRV]+", copydigit))
  end
specx0 = function (spec) return -(ZHA.fromspec(spec).minx) end

ZHA = Class {
  type    = "ZHA",
  fromspec = function (spec)
      return ZHA.fromspec0(spec):calcminmaxlr()
    end,
  fromspec0 = function (spec, x0)
      x0 = x0 or 0
      local widths = specwidths(spec)
      local z = ZHA {spec=spec, widths=widths,
                     maxy=#spec-1, minx=x0, maxx=x0,
                     L={[0]=x0}, R={[0]=x0}}
      local getc = function (y) return spec  :sub(y+1, y+1)   end
      local getw = function (y) return widths:sub(y+1, y+1)+0 end
      local w, LR = 1, V{x0, x0}
      local getdeltaLRw = function (y)
          local c = getc(y)
          if c == "L"       then return V{-1, -1} end           -- move left
          if c == "R"       then return V{ 1,  1} end           -- move right
          if c == (w+1).."" then w = w+1; return V{-1,  1} end  -- become wider
          if c == (w-1).."" then w = w-1; return V{ 1, -1} end  -- become thinner
          error("Bad char: "..c.." in spec: "..z.spec)
        end
      for y=1,z.maxy do
        -- PP(y, getc(y), w)
        -- LR = LR + PP(getdeltaLRw(y))
        LR = LR + getdeltaLRw(y)
        local xL, xR = LR[1], LR[2]
        z.L[y], z.R[y] = xL, xR
        z.minx = min(z.minx, xL)
        z.maxx = max(z.maxx, xR)
      end
      return z
    end,
  --
  -- A high-level method that uses the class LR in zhaspecs.lua.
  -- See: (find-dn6 "zhaspecs.lua" "LR")
  --      (find-dn6 "zhaspecs.lua" "LR" "fromtcgspec =")
  --      (find-dn6 "zhaspecs.lua" "LR-fromtcgspec-tests")
  fromtcgspec = function (spec)
      return LR.fromtcgspec(spec):zha()
    end,
  --
  __tostring = function (z) return z:tostring() end,
  --
  __index = {
    -- PP = function (z) PP(z); return z end,
    PP = function (z) print(mytabletostring(z)); return z end,
    print = function (z) print(z); return z end,
    hasxy = function (z, x,y)
        local x, y = v(x, y):to12()
        local L, R = z.L[y], z.R[y]
        if not L then return false end
        if not checkrange(L, x, R) then return false end
        if not isint((x-L)/2) then return false end
        return true
      end,
    xycontents = function (z, x,y)
        local xy = v(x, y)
        if z:hasxy(xy) then return xy:xytolr():todd() end
      end,
    tolines = function (z)
        local lines = {}
        for y=z.maxy,0,-1 do
          local f = function (x) return z:xycontents(x, y) or "  " end
          table.insert(lines, mapconcat(f, seq(z.minx, z.maxx)))
        end
        return lines
      end,
    tostring = function (z) return table.concat(z:tolines(), "\n") end,
    --
    -- Compute minl[], maxl[], minr[], maxr[], lrtop
    -- (find-dn6file "zha.lua" "calclrminmax =")
    leftpoint  = function (z, y) return v(z.L[y], y) end,
    rightpoint = function (z, y) return v(z.R[y], y) end,
    setminmaxlr0 = function (z, v)
        local l, r = v:to_l_r()
        z.minl[r], z.maxl[r] = minmax(z.minl[r], l, z.maxl[r])
        z.minr[l], z.maxr[l] = minmax(z.minr[l], r, z.maxr[l])
      end,
    calcminmaxlr = function (z)
        z.minl, z.minr, z.maxl, z.maxr = {}, {}, {}, {}
        for y=0,z.maxy do
          z:setminmaxlr0(z:leftpoint(y))
          z:setminmaxlr0(z:rightpoint(y))
        end
        z.top = z:leftpoint(z.maxy)
        z.topl, z.topr = z.top:to_l_r()
        return z
      end,
    -- z:Imp(P,Q) uses ne and nw
    sw = function (z, v) local l,r = v:to_l_r(); return lr(l, z.minr[l]) end,
    ne = function (z, v) local l,r = v:to_l_r(); return lr(l, z.maxr[l]) end,
    se = function (z, v) local l,r = v:to_l_r(); return lr(z.minl[r], r) end,
    nw = function (z, v) local l,r = v:to_l_r(); return lr(z.maxl[r], r) end,
    --
    -- Generate all points and all arrows of the ZHA
    points = function (z)
        return cow(function ()
            for l=z.topl,0,-1 do
              for r=z.minr[l],z.maxr[l] do
                coy(lr(l, r))    -- coy returns: lr(l,r)
              end
            end
          end)
      end,
    arrows = function (z, usewhitemoves)
        local tar = texarrow_smart(usewhitemoves)
        return cow(function ()
            for y=z.maxy,1,-1 do
              for x=z.L[y],z.R[y],2 do
		if z:hasxy(x-1, y-1) then coy(v(x, y), -1, -1, tar.sw) end
		if z:hasxy(x+1, y-1) then coy(v(x, y),  1, -1, tar.se) end
                -- coy returns: v(x,y), dx, dy, tex
              end
            end
          end)
      end,
    --
    -- For left generators, genp returns "L"; for right generators, "R"
    genp = function (z, P)
        local x,y = P:to_x_y()
        if z.L[y] and z.L[y-1] then
          local la,ma,ra = z.L[y],   x, z.R[y]    -- above
          local lb,mb,rb = z.L[y-1], x, z.R[y-1]  -- below
          if la == ma and la + 1 == lb then return "L" end  -- left gen
          if ma == ra and rb + 1 == ra then return "R" end  -- right gen
        end
      end,
    pointslrg = function (z)
        return cow(function ()
            for P in z:points() do
              local gen, l, r = z:genp(P), P:to_l_r()
              coy(P, l, r, gen)
            end
          end)
      end,
    --
    -- «ZHA-connectives» (to ".ZHA-connectives")
    -- (to "ZHA-test-connectives")
    -- Logical operations: <=, T, F, &, v, ->, <->, not
    Le  = function (z, P, Q) return P:below(Q) end,
    T   = function (z)       return z.top end,
    F   = function (z)       return V{0, 0} end,
    And = function (z, P, Q) return P:And(Q) end,
    Or  = function (z, P, Q) return P:Or(Q) end,
    Imp = function (z, P, Q)
        if     P:below(Q)   then return z.top
        elseif P:leftof(Q)  then return z:ne(P:And(Q))
        elseif P:rightof(Q) then return z:nw(P:And(Q))
        else                     return Q
        end
      end,
    Bic = function (z, P, Q) return z:And(z:Imp(P, Q), z:Imp(Q, P)) end,
    Not = function (z, P)    return z:Imp(P, z:F()) end,
    --
    -- «ZHA-getcuts» (to ".ZHA-getcuts")
    -- See: (find-angg "LUA/lua50init.lua" "eval-and-L")
    -- For a J-operator J, test the points of the upper-left and
    -- upper-right walls to determine where are the cuts.
    getcuts = function (z, J)
        if type(J) == "string" then J = L(J) end
        local cuts = ""
        local add = function (c) cuts = cuts..c end
        local ltoP = function (l) return lr(l, z.maxr[l]) end
        local rtoP = function (r) return lr(z.maxl[r], r) end
        local isstable = function (P) return J(P):lr() == P:lr() end
        add(z.topl)
        for l=z.topl-1,0,-1 do
          if isstable(ltoP(l)) then add("/") end
          add(l)
        end
        add(" ")
        for r=0,z.topr-1 do
          add(r)
          if isstable(rtoP(r)) then add("|") end
        end
        add(z.topr)
        return cuts
      end,
    --
    -- «ZHA-walls» (to ".ZHA-walls")
    -- (to "ZHA-tests-walls")
    rightwallgenerators = function (z, all)
        local A = {}
        for r=1,z.topr do
          if all or z.minl[r-1] < z.minl[r] then
            table.insert(A, lr(z.minl[r], r))
          end
        end
        return A
      end,
    leftwallgenerators = function (z, all)
        local A = {}
        for l=1,z.topl do
          if all or z.minr[l-1] < z.minr[l] then
            table.insert(A, lr(l, z.minr[l]))
          end
        end
        return A
      end,
    totcgspec = function (z)
        local maxl = z.topl
        local maxr = z.topr
        local tolr = function (v) return v:lr() end
        local leftgens  = mapconcat(tolr, z:leftwallgenerators(),  " ")
        local rightgens = mapconcat(tolr, z:rightwallgenerators(), " ")
        return format("%s, %s; %s, %s", maxl, maxr, leftgens, rightgens)
      end,
    --
    rightwallcorners = function (z)
        local l, r = 0, 0
        local A = {}
        -- local dbg = function (str) PP(str, l, r) end
        local push = function () table.insert(A, lr(l, r)) end
        local nextoutercorner = function () r = z.maxr[l]; push() end
        local nextinnercorner = function ()
            if r < z.topr then l = z.minl[r+1]; push(); return true end
          end
        push()
        nextoutercorner()
        while nextinnercorner() do nextoutercorner() end
        l, r = z.topl, z.topr
        push()
        return A
      end,
    leftwallcorners = function (z)
        local l, r = 0, 0
        local A = {}
        -- local dbg = function (str) PP(str, l, r) end
        local push = function () table.insert(A, lr(l, r)) end
        local nextoutercorner = function () l = z.maxl[r]; push() end
        local nextinnercorner = function ()
            if l < z.topl then r = z.minr[l+1]; push(); return true end
          end
        push()
        nextoutercorner()
        while nextinnercorner() do nextoutercorner() end
        l, r = z.topl, z.topr
        push()
        return A
      end,
    --
    -- «ZHA-shrinktop» (to ".ZHA-shrinktop")
    -- These methods use the class LR in zhaspecs.lua.
    -- See: (find-dn6 "zhaspecs.lua" "LR")
    toLR = function (z)
        return LR.fromtcgspec(z:totcgspec())
      end,
    shrinktop = function (z, P)
        return z:toLR():shrinktop(P):zha()
      end,
  },
}

-- «ZHA-tests» (to ".ZHA-tests")
--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "zhas.lua"
ZHA.fromspec("12L1RRR2RL1"):PP():print()
ZHA.fromspec("123LLR432L1"):PP():print()
ZHA.fromspec("123RRL432R1"):PP():print()

 (ex "zha-fromspec")

 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "zhas.lua"
dofile "zhaspecs.lua"
= ZHA.fromspec("123RRL432R1")
= ZHA.fromspec("123RRL432R1"):totcgspec()
= ZHA.fromtcgspec("4, 6; 32, 15 36")

 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "zhas.lua"
z = ZHA.fromspec("123RRL432R1"):PP()
= z

for y=z.maxy-1,0,-1 do
  for x=z.minx,z.maxx do
    printf(z:xycontents(x, y) or "  ")
  end
  print()
end
= z
z:PP()

PPV(z:tolines())
PP(z:tostring())

= z:hasxy(0,0)
= z

 (ex "zha-tostring")



-- «ZHA-tests-walls» (to ".ZHA-tests-walls")
-- (to "ZHA-walls")
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
-- (find-dn6 "zha.lua" "ZHA")
dofile "zhas.lua"
pris = function (o) printf("%s ", tostring(o)) end
z = ZHA.fromspec("12RRL1LLRR")
= z
for y=z.maxy,0,-1 do pris(z:leftpoint(y):lr())  end; print()
for y=z.maxy,0,-1 do pris(z:rightpoint(y):lr()) end; print()
for _,P in ipairs(z:rightwallgenerators("all")) do pris(P:lr()) end; print()
for _,P in ipairs(z:rightwallgenerators())      do pris(P:lr()) end; print()
for _,P in ipairs(z:leftwallgenerators("all"))  do pris(P:lr()) end; print()
for _,P in ipairs(z:leftwallgenerators())       do pris(P:lr()) end; print()
for _,P in ipairs(z:rightwallcorners())         do pris(P:lr()) end; print()
for _,P in ipairs(z:leftwallcorners())          do pris(P:lr()) end; print()

--      45
--    44
--  43
--    33
--      23
--    22  13
--      12  03
--    11  02
--  10  01
--    00

 (ex "zha-walls")

-- «ZHA-test-connectives» (to ".ZHA-test-connectives")
-- (to "ZHA-connectives")
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
-- (find-dn6 "zha.lua" "ZHA")
dofile "zhas.lua"
z = ZHA.fromspec("12RRL1LLRR"):print()
= z:Imp(v"11", v"02"):lr()   --> 03
= z:Imp(v"03", v"12"):lr()   --> 22
= z:Imp(v"23", v"12"):lr()   --> 12
= z:Imp(v"12", v"23"):lr()   --> 45
= z:ne(v"10"):lr()           --> 13
= z:nw(v"02"):lr()           --> 22
= v"12":And(v"03"):lr()      --> 02

= v"11":And(v"02"):lr()
= z:ne(v"11":And(v"02")):lr()  --> 03
= v("11"):leftof(v"02")        
= v("11"):above(v"02")
= v("11"):below(v"02")
= v("23"):below(v"12")
= v("23"):above(v"12")

--      45
--    44
--  43
--    33
--      23
--    22  13
--      12  03
--    11  02
--  10  01
--    00

 (ex "zha-connectives")

-- «ZHA-test-generators» (to ".ZHA-test-generators")
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "zhas.lua"
z = ZHA.fromspec("123RRL432R1"):print()
for v in z:points() do printf("%s ", v:lr()) end; print()
ap = AsciiPicture.new("  ")
for v in z:points() do ap:put(v, v:lr()) end
= ap
ap = AsciiPicture.new("  ")
for P in z:points() do ap:put(P, P:And(v"23"):lr()) end
= ap

z = ZHA.fromspec("121L"):print()
for P,dx,dy,tex in z:arrows() do print(P:lr().."->"..(P+v(dx,dy)):lr(), tex) end

 (ex "zha-generators")

-- «ZHA-test-shrinktop» (to ".ZHA-test-shrinktop")
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "zhas.lua"
dofile "zhaspecs.lua"
z = ZHA.fromtcgspec("4, 5; 32, 14 25"):print()
z = ZHA.fromtcgspec("4, 5; 32, 14 25"):shrinktop("34"):print()

--]]



--      _                _                             _
--  ___| |__   ___  _ __| |_ ___  _ __   ___ _ __ __ _| |_ ___  _ __ ___
-- / __| '_ \ / _ \| '__| __/ _ \| '_ \ / _ \ '__/ _` | __/ _ \| '__/ __|
-- \__ \ | | | (_) | |  | || (_) | |_) |  __/ | | (_| | || (_) | |  \__ \
-- |___/_| |_|\___/|_|   \__\___/| .__/ \___|_|  \__,_|\__\___/|_|  |___/
--                               |_|
-- «shortoperators» (to ".shortoperators")
function shortoperators ()
    True  = function () return z:T() end
    False = function () return z:F() end
    And   = function (P, Q) return P:And(Q) end
    Or    = function (P, Q) return P:Or(Q) end
    Imp   = function (P, Q) return z:Imp(P, Q) end
    Not   = function (P) return Imp(P, False()) end
    Bic   = function (P, Q) return z:Bic(P, Q) end
    --
    Cloq  = function (A)    return function (P) return Or(A, P) end end
    Opnq  = function (A)    return function (P) return Imp(A, P) end end
    Booq  = function (A)    return function (P) return Imp(Imp(P, A), A) end end
    Forq  = function (A, B) return function (P) return And(Or(A, P), Imp(B, P)) end end
    Jand  = function (J, K) return function (P) return And(J(P), K(P)) end end
    --
    Mixq  = function (A)    return function (P) return Imp(Imp(P, A), P) end end
    Mixq2 = function (A)    return function (P) return Jand(Booq(A), Opnq(A))(P) end end
    Truq  = function ()     return function (P) return True() end end
    Falq  = function ()     return function (P) return P end end
  end

-- «shortoperators-tests» (to ".shortoperators-tests")
--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "zhas.lua"
shortoperators()
= mpnewJ({}, "1234567654321", Opnq(v"23")):zhaPs("23")
= mpnewJ({}, "1234567654321", Cloq(v"23")):zhaPs("23")
= mpnewJ({}, "1234567654321", Booq(v"23")):zhaPs("23")
= mpnewJ({}, "1234567654321", Forq(v"42", v"24")):zhaPs("42 24")
= mpnewJ({}, "1234567654321", Jand(Booq(v"21"), Booq(v"12"))):zhaPs("21 12")
= mpnewJ({}, "1234567654321", Mixq (v"33")):zhaPs("33")
= mpnewJ({}, "1234567654321", Mixq2(v"33")):zhaPs("33")
= mpnewJ({}, "1234567654321", Truq()):zhaPs("")
= mpnewJ({}, "1234567654321", Falq()):zhaPs("")

 (ex "zha-shortoperators")
--]]





--   ____      _
--  / ___|   _| |_ ___
-- | |  | | | | __/ __|
-- | |__| |_| | |_\__ \
--  \____\__,_|\__|___/
--
-- «Cuts» (to ".Cuts")

Cuts = Class {
  type    = "Cuts",
  new = function ()
      return Cuts {minicuts={}, asciibb=BoundingBox.new(),
                   latex="",    latexbb=BoundingBox.new()}
    end,
  __tostring = function (c) return c:tostring() end,
  __index = {
    get = function (c, v)
        return (c.minicuts[v[2]] or {})[v[1]] or " "
      end,
    tolines = function (c)
        local x0, x1, y0, y1 = c.asciibb:x0x1y0y1()
        local lines = {}
        for y=y1,y0,-1 do
          local s = ""
          for x=x0,x1 do
            local char = (c.minicuts[y] or {})[x] or " "
            s = s..char
          end
          table.insert(lines, s)
        end
        return lines
      end,
    tostring = function (c) return table.concat(c:tolines(), "\n") end,
    print = function (c) print(c); return c end,
    --
    -- Low-level functions for adding cuts
    addminicut = function (c, x, y, slash)
        c.minicuts[y] = c.minicuts[y] or {}
        c.minicuts[y][x] = slash
        c.asciibb:addpoint(v(x, y))
      end,
    addcut0 = function (c, src, tgt)
        c.latexbb:addpoint(src)
        c.latexbb:addpoint(tgt)
        --
        local x0, y0 = src:to_x_y()
        local x1, y1 = tgt:to_x_y()
        if y1 < y0 then x0, y0, x1, y1 = x1, y1, x0, y0 end
        local dx, dy = x1-x0, y1-y0
        if     dy == dx then  -- northeast, with "/"s
          for a=0.5,dy-0.5 do
            c:addminicut(x0+a, y0+a, "/")
          end
        elseif dy == -dx then -- northwest, with "\"s
          for a=0.5,dy-0.5 do
            c:addminicut(x0-a, y0+a, "\\")
          end
        else PP("dx=", dx, "dy=", dy); error()
        end
        c:addlatexcut(src, tgt) -- defined below
        return c
      end,
    addcuts0 = function (c, list)
        for i=1,#list-1 do c:addcut0(list[i], list[i+1]) end
        return c
      end,
    --
    -- Medium-level functions for adding cuts
    addcontour = function (c, zha)
        local leftwall  = zha:leftwallcorners()
        local rightwall = zha:rightwallcorners()
        local corners = {}
        table.insert(corners, leftwall[1]:s())
        for i=2,#leftwall-1 do table.insert(corners, leftwall[i]:w()) end
        table.insert(corners, leftwall[#leftwall]:n())
        for i=#rightwall-1,2,-1 do table.insert(corners, rightwall[i]:e()) end
        table.insert(corners, rightwall[1]:s())
        c:addcuts0(corners)
        return c
      end,
    addlcut = function (c, zha, l)
        if l+1 > zha.topl then return c end
        local westcell = lr(l+1, zha.minr[l+1])
        local eastcell = lr(l,   zha.maxr[l])
        c:addcut0(westcell:s(), eastcell:n())
        return c
      end,
    addrcut = function (c, zha, r)
        if r+1 > zha.topr then return c end
        local eastcell = lr(zha.minl[r+1], r+1)
        local westcell = lr(zha.maxl[r],   r)
        c:addcut0(westcell:n(), eastcell:s())
        return c
      end,
    --
    -- A high-level function for adding (all kinds of) cuts.
    addcuts = function (c, zha, str)
        if str:match"c" then c:addcontour(zha) end
        for l in str:gmatch"/(%d)" do c:addlcut(zha, l+0) end
        for r in str:gmatch"(%d)|" do c:addrcut(zha, r+0) end
        --
        local f = function (lr, dir) local P = v(lr); return P[dir](P) end
        local pat = "(%d%d)([ensw])-(%d%d)([ensw])"
        for src,sdir,tgt,tdir in str:gmatch(pat) do
          c:addcut0(f(src, sdir), f(tgt, tdir))
        end
        return c
      end,
    --
    -- Communication with Picture objects
    -- Similar to: (find-dn6 "zhas.lua" "LPicture" "addlineorvector =")
    addlatexcut = function (c, src, tgt)
        local x0, y0 = src:to_x_y()
        local x1, y1 = tgt:to_x_y()
        local dx, dy = x1-x0, y1-y0
        local len = math.abs(dx)
        local udx, udy = dx/len, dy/len
        -- (find-pict2epage 9 "\\Line( X1,Y1 )( X2,Y2 )")
        -- local put = "  \\put("..x0..","..y0..")"..
        --             "{\\line("..udx..","..udy.."){"..len.."}}"
        local put = "  \\Line("..x0..","..y0..")("..x1..","..y1..")"
        c.latex = c.latex..put.."\n"
      end,
    -- copylatexcuts = function (c, pic)
    --   end,
  },
}


--[[
-- «Cuts-tests» (to ".Cuts-tests")
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "zhas.lua"
c = Cuts.new()
z = ZHA.fromspec("12RRL1LLRR")
= z
= c:addcuts0{v"00":w(), v"01":n(), v"01":e()}
= mytabletostring(c)
= c:addcontour(z)
= c.latex

 (ex "zha-cuts-1")

 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "zhas.lua"
c = Cuts.new()
z = ZHA.fromspec("12RRL1LLRR")
= c:addcontour(z)
= c:addlcut(z, 0)
= c:addlcut(z, 1)
= c:addlcut(z, 2)

= c:addrcut(z, 0)
= c:addrcut(z, 1)
= c:addrcut(z, 2)

 (ex "zha-cuts-2")

 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "zhas.lua"
c = Cuts.new()
z = ZHA.fromspec("12RRL1LLRR"):print()
= c:addcuts(z, "c 432/1/0 0|1|2|345")

z = ZHA.fromspec("1234567654321"):print()
c = Cuts.new()
= c:addcuts(z, "c 01e-41n 40w-44n 14n-64n 11n-16n")

 (ex "zha-cuts-3")

--]]





--  __  __ _              _ ____  _      _
-- |  \/  (_)_  _____  __| |  _ \(_) ___| |_ _   _ _ __ ___
-- | |\/| | \ \/ / _ \/ _` | |_) | |/ __| __| | | | '__/ _ \
-- | |  | | |>  <  __/ (_| |  __/| | (__| |_| |_| | | |  __/
-- |_|  |_|_/_/\_\___|\__,_|_|   |_|\___|\__|\__,_|_|  \___|
--
-- «MixedPicture» (to ".MixedPicture")
-- A MixedPicture object has both an ascii representation and a LaTeX
-- representation. Most MixedPicture objects I use have a ZHA, and sometimes
-- a Cuts.

strtotex = function (str)  -- Used by MixedPicture:put(...)
    if str:match"^%.+$" then return "\\cdot" end
    if str:match"^%*+$" then return "\\bullet" end
    if str:match"^%o+$" then return "\\circ" end
  end
celltotex = function (str, f)  -- used by MixedPicture:addcells(...)
    return (type(f)=="table" and f[str])
        or (type(f)=="function" and f(str))
        or (str:gsub("!", "\\"))
  end

MixedPicture = Class {
  type    = "MixedPicture",
  new     = function (options, zha, J, asciirect)
      return MixedPicture {
        ap   = AsciiPicture.new(options.s or "  "),
        lp   = LPicture.new(options),
        cuts = Cuts.new(),
        zha  = zha,
        J    = J,
        ar   = asciirect,
      }
    end,
  __tostring = function (mp) return mp:tostring() end,
  __index = {
    tolines_mixed = function (mp)
        local  x0,  x1,  y0,  y1 = mp.ap       .bb:x0x1y0y1()
        local cx0, cx1, cy0, cy1 = mp.cuts.asciibb:x0x1y0y1()
        local lines = {}
        for y=max(y1, cy1),min(y0, cy0),-.5 do
          local line = ""
          for x=min(x0, cx0),max(x1, cx1),.5 do
            if isint(x)
            then line = line..mp.ap:get(v(x, y))
            else line = line..mp.cuts:get(v(x, y))
            end
          end
          table.insert(lines, line)
        end
        return lines
      end,
    tolines = function (mp)
        local hascuts  = mp.cuts.asciibb.x0y0
        local hasnodes = mp.ap.bb.x0y0
        if hasnodes and hascuts then return mp:tolines_mixed() end
        if hasnodes then return mp.ap:tolines() end
        if hascuts  then return mp.cuts:tolines() end
        return {"empty"}
      end,
    tostring = function (mp) return table.concat(mp:tolines(), "\n") end,
    tolatex = function (mp)
        local body = mp.cuts.latex .. mp.lp.latex
        local bb = BoundingBox.new():merge(mp.lp.bb):merge(mp.cuts.latexbb)
        return makepicture(mp.lp, bb, body)
      end,
    print  = function (mp) print(mp); return mp end,
    lprint = function (mp) print(mp:tolatex()); return mp end,
    output = function (mp) output(mp:tolatex()); return mp end,
    --
    put = function (mp, v, str, tex)
        mp.ap:put(v, str)
        mp.lp:put(v, tex or strtotex(str) or str)
        return mp
      end,
    --
    -- «MixedPicture-cuts» (to ".MixedPicture-cuts")
    addcontour = function (mp) mp.cuts:addcontour(mp.zha); return mp end,
    addlcut = function (mp, ...) mp.cuts:addlcut(mp.zha, ...); return mp end,
    addrcut = function (mp, ...) mp.cuts:addrcut(mp.zha, ...); return mp end,
    addcuts = function (mp, ...) mp.cuts:addcuts(mp.zha, ...); return mp end,
    addcutssub = function (mp, newtop, ...)
        mp.cuts:addcuts(mp.zha:shrinktop(newtop), ...)
        return mp
      end,
    --
    -- OBSOLETE.
    -- zfunction and zsetbullets were replaced by methods using 
    -- the ar field (which holds an AsciiRect)
    zfunction = function (mp, asciirect)
        for x,y,c in asciirectpoints(asciirect) do
          if c:match"%d" then
            mp:put(v(x, y), "#"..c)
            mp.lp.def = mp.lp.def.."#"..c
          end
        end
        return mp
      end,
    zsetbullets = function (mp, asciirect)
        for x,y,c in asciirectpoints(asciirect) do
          if c:match"%d" then mp:put(v(x, y), "**") end
        end
        return mp
      end,
    --
    -- New methods (2015sep06)
    -- points = function (mp, ...) return mp.zha:points() end,
    points = function (mp) return (mp.zha or mp.ar):points() end,
    arrows = function (mp, w) return (mp.zha or mp.ar):arrows(w) end,
    addarrows = function (mp, w)
        for v,dx,dy,tex in mp:arrows(w) do mp.lp:putarrow(v, dx, dy, tex) end
        return mp
      end,
    addarrowsexcept = function (mp, w, omit)
        if type(omit) == "string" then omit = Set.from(split(omit)) end
        if type(omit) == "table" then
          local o = omit
          omit = function (vdx) return o:has(vdx) end
        end
        for v,dx,dy,tex in mp:arrows(w) do
          if not omit(v:xy()..dx, v, dx) then mp.lp:putarrow(v, dx, dy, tex) end
        end
        return mp
      end,
    addbullets = function (mp)
        for v in mp:points() do mp:put(v, "**") end
        return mp
      end,
    adddots = function (mp)
        for v in mp:points() do mp:put(v, "..") end
        return mp
      end,
    addlrs = function (mp) -- for zhas
        for v in mp.zha:points() do mp:put(v, v:lr()) end
        return mp
      end,
    addgens = function (mp) -- for zhas
        for P,l,r,gen in mp.zha:pointslrg() do
          if     gen == "L" then mp:put(P, l.."_", l.."\\_")
          elseif gen == "R" then mp:put(P, "_"..r, "\\_"..r)
          else                   mp:put(P, "..")
          end
        end
        return mp
      end,
    addcells = function (mp, f) -- for asciirects
        for v,str in mp.ar:points() do mp:put(v, celltotex(str, f)) end
        return mp
      end,
    addxys = function (mp)
        for v,str in mp:points() do mp:put(v, v:xy()) end
        return mp
      end,
    --
    -- «MixedPicture-zha» (to ".MixedPicture-zha")
    zhabullets = function (mp)
        for v in mp.zha:points() do mp:put(v, "**") end
        return mp
      end,
    zhadots = function (mp)
        for v in mp.zha:points() do mp:put(v, "..") end
        return mp
      end,
    zhalr = function (mp)
        for v in mp.zha:points() do mp:put(v, v:lr()) end
        return mp
      end,
    zhaPs = function (mp, str)
        for _,w in ipairs(split(str)) do mp:put(v(w), w) end
        return mp
      end,
    --
    setz = function (mp) z = mp.zha; return mp end,  -- set the global z
    zhalrf0 = function (mp, f)
        if type(f) == "string" then f = L(f) end
        for v in mp.zha:points() do mp:put(v, tostring(f(v))) end
        return mp
      end,
    zhalrf = function (mp, f)
        if type(f) == "string" then f = L(f) end
        for v in mp.zha:points() do mp:put(v, f(v):lr()) end
        return mp
      end,
    zhaJ     = function (mp) return mp:zhalrf(mp.J) end,
    zhaJcuts = function (mp) return mp:addcuts(mp.zha:getcuts(mp.J)) end,
    --
    putpiledef = function (mp, v)
        local L, R = mp.zha.topl, mp.zha.topr
        local l, r = v:to_l_r()
        local pile = function (h, n) return ("0"):rep(h-n)..("1"):rep(n) end
        local piledef = function (A, B, a, b)
            return "\\foo{"..a..b.."}{"..pile(A, a).." "..pile(B, b).."}"
          end
        mp:put(v, v:lr(), piledef(L, R, l, r))
        return mp
      end,
    zhapiledefs = function (mp)
        for v in mp.zha:points() do mp:putpiledef(v) end
        return mp
      end,
    --
    -- (find-angg "LUA/lua50init.lua" "eval-and-L")
  },
}


--                                      
--  _ __ ___  _ __  _ __   _____      __
-- | '_ ` _ \| '_ \| '_ \ / _ \ \ /\ / /
-- | | | | | | |_) | | | |  __/\ V  V / 
-- |_| |_| |_| .__/|_| |_|\___| \_/\_/  
--           |_|                        
--
-- «mpnew» (to ".mpnew")
-- «mpnewJ» (to ".mpnewJ")
-- (to "MixedPicture-J-tests")
-- See: (find-dn6 "luarects.lua" "AsciiRect")
--      (find-dn6 "luarects.lua" "AsciiRect-tests")
--
-- Mpnew and mpnewJ are shorthands that create MixedPicture objects
-- with or without a J-operator...

mpnew = function (opts, spec, J, asciirect)
    local z  = ZHA.fromspec(spec)
    local mp = MixedPicture.new(opts, z, J, asciirect)
    return mp, z
  end

mpnewJ = function (opts, spec, J)
    return mpnew(opts, spec, J):setz():zhaJcuts():addcontour()
  end



-- «MixedPicture-tests» (to ".MixedPicture-tests")
--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "zhas.lua"
z = ZHA.fromspec("12RRL1LLRR"):print()
mp = MixedPicture.new({}, z)
mp = MixedPicture.new({bhbox=1, paren=1, scale="10pt", def="foo"}, z)
= mp:put(v"02", "02")
= mp:tolatex()
for v in z:points() do mp:put(v, v:lr()) end
= mp:addcontour()
= mp:addlcut(0):addrcut(2)
latex = mp:tolatex()
= latex
writefile("/tmp/o.tex", latex)  -- (find-fline "/tmp/o.tex")
-- (find-ist "-handouts.tex" "mixedpicture-tests")

 (ex "mixedpic-1")



 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "zhas.lua"
z = ZHA.fromspec("1234R3L21L"):print()
mp = MixedPicture.new({bhbox=1, paren=1, scale="10pt", def="foo"}, z)
mp = MixedPicture.new({def="foo"}, z)
  for v in z:points() do mp:put(v, v:lr()) end    -- optional
= mp:addcontour()
= mp:addrcut(0):addrcut(2)
= mp:addlcut(1)
= mp:put(v"20", "P")
= mp:put(v"30", "P*", "P^*")
= mp:put(v"11", "Q")
= mp:put(v"12", "Q*", "Q^*")
= mp:put(v"03", "R")
= mp:put(v"14", "R*", "R^*")
latex = mp:tolatex()
= latex
writefile("/tmp/o.tex", latex)  -- (find-fline "/tmp/o.tex")
-- (find-ist "-handouts.tex" "mixedpicture-tests")

 (ex "mixedpic-2")


 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "zhas.lua"
z = ZHA.fromspec("121L"):print()
mp = MixedPicture.new({bhbox=1, paren=1, scale="20pt", def="foo"}, z)
mp = MixedPicture.new({bhbox=1, scale="14pt", cellfont="\\scriptsize", def="foo"}, z)
-- for v in z:points() do mp:put(v, v:lr()) end
for v in z:points() do mp:put(v, v:xy()) end
= mp
for v,dx,dy in mp.zha:arrows() do print(v, dx, dy) end
for v,dx,dy in mp.zha:arrows() do
  local tex = (dx==-1) and "\\swarrow" or "\\searrow"
  mp.lp:putarrow(v, dx, dy, tex)
end
= mp.lp
latex = mp:tolatex()
latex = "\\def\\foo{"..latex.."}"
= latex
writefile("/tmp/o.tex", latex)  -- (find-fline "/tmp/o.tex")
-- (find-ist "-handouts.tex" "mixedpicture-tests")

 (ex "mixedpic-3")


-- «MixedPicture-zhalrf-tests» (to ".MixedPicture-zhalrf-tests")
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "zhas.lua"
z = ZHA.fromspec("123454321"):print()
mp = MixedPicture.new({}, z)
mp = mpnew({}, "123454321")
= mp:zhalrf0("lr -> 23")
= mp:zhalrf0("lr -> '23'")
= mp:zhalrf0("lr -> v'23'")
= mp:zhalrf0("lr -> v'23':lr()")
= mp:zhalrf0("lr -> otype(lr)")
= mp:zhalrf ("lr -> lr")
= mp:zhalrf0("lr -> lr:And(v'12'):lr()")
= mp:zhalrf ("lr -> lr:And(v'12')")
= mp:zhalrf0("P -> P:below(v'12') and 1 or 0")
= mp:zhalrf0("P -> P:And(v'22')")
= mp:zhalrf0("P -> P:And(v'22'):lr()")
= v"31":And(v"12"):lr()




-- «MixedPicture-arch-tests» (to ".MixedPicture-arch-tests")
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "zhas.lua"

-- The (v*) cube
mp = mpnew({def="orStarCubeArchetypal"}, "12321L"):addcuts("c 21/0 0|12")
mp:put(v"10", "P"):put(v"20", "P*", "P^*")
mp:put(v"01", "Q"):put(v"02", "Q*", "Q^*"):print()

-- The (&*) cube
mp = mpnew({def="andStarCubeArchetypal"}, "12321"):addcuts("c 2/10 01|2")
mp:put(v"20", "P"):put(v"21", "P*", "P^*")
mp:put(v"02", "Q"):put(v"12", "Q*", "Q^*"):print()

-- The (->*) cube
mp = mpnew({def="impStarCubeArchetypal"}, "12321"):addcuts("c 2/10 01|2")
mp:put(v"10", "P")
mp:put(v"00", "Q"):print()

-- (&R) is *-functorial
mp = mpnew({def="andRIsStarFunctorial"}, "1234R321"):addcuts("c 32/10 01|23|4")
mp:put(v"30", "P"):put(v"31", "P*", "P^*")
mp:put(v"22", "Q"):put(v"33", "Q*", "Q^*")
mp:put(v"04", "R"):put(v"14", "R*", "R^*"):print()

-- (Pv) is *-functorial
mp = mpnew({def="PvIsStarFunctorial"}, "1234R3L21L"):addcuts("c 5432/10 0|12|34")
mp:put(v"20", "P"):put(v"30", "P*", "P^*")
mp:put(v"11", "Q"):put(v"12", "Q*", "Q^*")
mp:put(v"03", "R"):put(v"14", "R*", "R^*"):print()

 (ex "mixedpic-cubes")


-- «MixedPicture-zset-tests» (to ".MixedPicture-zset-tests")
-- (find-dn6file "zhas.lua" "zfunction =")
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "zhas.lua"
z = ZHA.fromspec("12321L"):print()
house = ".1.|2.3|4.5"
mp = MixedPicture.new({def="dagHouse"}):zfunction(house):print():lprint()
mp = MixedPicture.new({def="dagHouse", meta="t", scale="5pt"}, z):zfunction(house):lprint()
mp = MixedPicture.new({def="House"}):zsetbullets(house):print():lprint()
mp = MixedPicture.new({def="Ten"}, z):zhabullets():print()
mp = MixedPicture.new({def="Ten"}, z):zhadots():print()
mp = MixedPicture.new({def="Ten"}, z):zhalr():print()

mp = mpnew({scale="15pt"}, "121L"):zhapiledefs():print():lprint()

 (ex "mixedpic-zsets-1")

 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "zhas.lua"
threefour = "..1|2.3|4.5|6.7"
MixedPicture.new({def="dagThreeFour", meta="s"}):zfunction(threefour):print():lprint()

 (ex "mixedpic-threefour")


-- «MixedPicture-J-tests» (to ".MixedPicture-J-tests")
-- (to "mpnewJ")
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "zhas.lua"
= mpnewJ({}, "1234RR321", "P -> z:Or(P, v'12')")
= mpnewJ({}, "1234RR321", "P -> z:Imp(v'12', P)")

mp = mpnewJ({}, "1234RR321", "P -> z:Imp(v'12', P)")
= mp.zha:getcuts(mp.J)

 (ex "mixedpic-J-1")

 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "zhas.lua"

--]]




--      _                    ____           _                       _     
--   __| |_ __ __ ___      _|___ \ ___ ___ | | __ _ _ __ __ _ _ __ | |__  
--  / _` | '__/ _` \ \ /\ / / __) / __/ _ \| |/ _` | '__/ _` | '_ \| '_ \ 
-- | (_| | | | (_| |\ V  V / / __/ (_| (_) | | (_| | | | (_| | |_) | | | |
--  \__,_|_|  \__,_| \_/\_/ |_____\___\___/|_|\__, |_|  \__,_| .__/|_| |_|
--                                            |___/          |_|          
--
-- «drawtwocolgraph» (to ".drawtwocolgraph")

dxyrunf = function (...) print("%D "..format(...)); dxyrun(format(...)) end

drawtwocolgraph = function (dx, dy, maxl, maxr, leftgens, rightgens, ltexs, rtexs)
    local D = dxyrunf
    local y = function (i) return 100+dy*(i-1) end
    local ltex = function (i) return ltexs and split(ltexs)[i] or i.."\\_" end
    local rtex = function (i) return rtexs and split(rtexs)[i] or "\\_"..i end
    D "(("
    for i=1,maxl do D("node: %d,%d L%d .tex= %s", 100,    y(i), i, ltex(i)) end
    for i=1,maxr do D("node: %d,%d R%d .tex= %s", 100+dx, y(i), i, rtex(i)) end
    for i=maxl,2,-1 do D("L%d L%d ->", i, i-1) end
    for i=maxr,2,-1 do D("R%d R%d ->", i, i-1) end
    for l,r in leftgens :gmatch "(%d)(%d)" do D("L%d R%d ->", l, r) end
    for l,r in rightgens:gmatch "(%d)(%d)" do D("L%d R%d <-", l, r) end
    D "))"
  end

-- «drawtwocolgraph-tests» (to ".drawtwocolgraph-tests")
--[==[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "zhas.lua"
dxyrunf = function (...) print("%D "..format(...)) end
drawtwocolgraph(40, 20, 4, 6, "24", "24 35")

--]==]






-- __     ______      _       
-- \ \   / / ___|   _| |_ ___ 
--  \ \ / / |  | | | | __/ __|
--   \ V /| |__| |_| | |_\__ \
--    \_/  \____\__,_|\__|___/
--                            
-- «VCuts» (to ".VCuts")
-- For drawing slashings as V-shaped diagrams.
-- (phap 27 "piccs-and-slashings")
-- (pha     "piccs-and-slashings")

VCuts = Class {
  type = "VCuts",
  new  = function (options, l, r)
      local vc = VCuts {mp=MixedPicture.new(options)}
      if l then vc:putls(l) end
      if r then vc:putrs(r) end
      return vc
    end,
  __tostring = function (vc) return tostring(vc.mp) end,
  __index = {
    tostring = function (vc) return tostring(vc.mp) end,
    tolatex  = function (vc) return vc.mp:tolatex() end,
    output   = function (vc) output(vc:tolatex()); return vc end,
    print = function (vc) print(tostring(vc)); return vc end,
    putl = function (vc, n) vc.mp:put(v((n+1).."0"), n.."", n..""); return vc  end,
    putr = function (vc, n) vc.mp:put(v("0"..(n+1)), n.."", n..""); return vc  end,
    cutl = function (vc, n) vc.mp:addcuts(format("%d0w-%d0n", n+1, n+1)); return vc end,
    cutr = function (vc, n) vc.mp:addcuts(format("0%dn-0%de", n+1, n+1)); return vc end,
    putls = function (vc, n) for i=0,n+0 do vc:putl(i) end; return vc end,
    putrs = function (vc, n) for i=0,n+0 do vc:putr(i) end; return vc end,
  },
}

-- «VCuts-tests» (to ".VCuts-tests")
--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "zhas.lua"

vc = VCuts.new({scale="7pt", def="foo"}, 4, 6)
= vc
vc:cutl(0)
vc:cutr(3):cutr(5)
= vc
= vc:tolatex()

--]]





--[==[

--  _____ ____ ____ 
-- |_   _/ ___/ ___|
--   | || |  | |  _ 
--   | || |__| |_| |
--   |_| \____\____|
--                  
-- «TCG» (to ".TCG")
-- Draw two-column graphs.
-- Code commented out! Too messy!
-- Moved to:
--   (find-LATEX "edrxpict.lua" "TCG")


TCG = Class {
  type = "TCG",
  new  = function (opts, def, l, r, lrarrows, rlarrows)
      local dims = opts                   -- was opts.dims
      local lp = LPicture.new(opts)
      lp.def = def
      local tcg = {lp=lp,   dh=dims.dh, dv=dims.dv, eh=dims.eh, ev=dims.ev,
                   l=l+0, r=r+0, lrarrows=lrarrows, rlarrows=rlarrows}
      return TCG(tcg)
    end,
  __tostring = function (tcg) return tcg:tostring() end,
  __index = {
    tostring = function (tcg)
        return format("(%s, %s, %q, %q)", tcg.l, tcg.r, tcg.lrarrows, tcg.rlarrows)
      end,
    tolatex = function (tcg) return tcg.lp:tolatex() end,
    L = function (tcg, y) return v(0,      tcg.dv*y) end,
    R = function (tcg, y) return v(tcg.dh, tcg.dv*y) end,
    arrow = function (tcg, A, B, e)
        tcg.lp:addtex(Line.newAB(A, B, e, 1-e):pictv())
      end,
    lrs = function (tcg)
        for y=1,tcg.l do tcg.lp:put(tcg:L(y), y.."\\_") end
        for y=1,tcg.r do tcg.lp:put(tcg:R(y), "\\_"..y) end
        return tcg
      end,
    bus = function (tcg)
        for y=1,tcg.l do tcg.lp:put(tcg:L(y), "\\bullet") end
        for y=1,tcg.r do tcg.lp:put(tcg:R(y), "\\bullet") end
        return tcg
      end,
    strs = function (tcg, strsl, strsr)
        if type(strsl) == "string" then strsl = split(strsl) end
        if type(strsr) == "string" then strsr = split(strsr) end
        for y,str in ipairs(strsl) do tcg.lp:put(tcg:L(y), str) end
        for y,str in ipairs(strsr) do tcg.lp:put(tcg:R(y), str) end
        return tcg
      end,
    cs = function (tcg, charsl, charsr)
        return tcg:strs(split(charsl, "."), split(charsr, "."))
      end,
    cq = function (tcg, charsl, charsr)
        local lc   = function (y) return charsl:sub(y, y) end
        local rc   = function (y) return charsr:sub(y, y) end
        local lstr = function (y) return lc(y)=="L" and y.."\\_" or lc(y) end
        local rstr = function (y) return rc(y)=="R" and "\\_"..y or rc(y) end
        for y=1,#charsl do tcg.lp:put(tcg:L(y), lstr(y)) end
        for y=1,#charsr do tcg.lp:put(tcg:R(y), rstr(y)) end
        return tcg
      end,
    vs = function (tcg)
        for y=1,tcg.l-1 do tcg:arrow(tcg:L(y+1), tcg:L(y), tcg.ev) end
        for y=1,tcg.r-1 do tcg:arrow(tcg:R(y+1), tcg:R(y), tcg.ev) end
        return tcg
      end,
    hs = function (tcg)
        for l,r in tcg.lrarrows:gmatch("(%d)(%d)") do
          tcg:arrow(tcg:L(l), tcg:R(r), tcg.eh)
        end
        for l,r in tcg.rlarrows:gmatch("(%d)(%d)") do
          tcg:arrow(tcg:R(r), tcg:L(l), tcg.eh)
        end
        return tcg
      end,
    print  = function (tcg) print(tcg); return tcg end,
    lprint = function (tcg) print(tcg:tolatex()); return tcg end,
    output = function (tcg) output(tcg:tolatex()); return tcg end,
  },
}

-- «TGC-tests» (to ".TGC-tests")
--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "zhas.lua"
-- dims = {dv=2, dh=3, ev=0.32, eh=0.2}
opts = {scale="10pt", dims={dv=2, dh=3, ev=0.32, eh=0.2}}
opts = {scale="10pt",       dv=2, dh=3, ev=0.32, eh=0.2 }
tcg = TCG.new(opts, "foo", 4, 6, "12", "23 34"):lrs():vs():hs():lprint()
= tcg
= tcg:tolatex()

--]]

--]==]








--                 _ _               _               _       _
--   __ _ ___  ___(_|_)_ __ ___  ___| |_ _ __   ___ (_)_ __ | |_ ___
--  / _` / __|/ __| | | '__/ _ \/ __| __| '_ \ / _ \| | '_ \| __/ __|
-- | (_| \__ \ (__| | | | |  __/ (__| |_| |_) | (_) | | | | | |_\__ \
--  \__,_|___/\___|_|_|_|  \___|\___|\__| .__/ \___/|_|_| |_|\__|___/
--                                      |_|
--
-- Asciirects are a good way to specify ZSets and ZFunctions - for
-- example, ".1.|2.3|4.5" is (reading order on) the "House" ZSet.
-- THIS IS OBSOLETE, and has been superseded by:
--   (find-dn6 "luarects.lua" "AsciiRect")
--
-- «asciirectpoints» (to ".asciirectpoints")
asciirectpoints = function (lines)
    return cow(function ()
        if type(lines) == "string" then
          lines = splitlines((lines:gsub("|", "\n")))
        end
        for y=#lines-1,0,-1 do
          local line = lines[#lines-y]
          for x=0,#line-1 do
            local c = line:sub(x+1, x+1)
            coy(x, y, c)
          end
        end
      end)
  end

-- «asciirectpoints-tests» (to ".asciirectpoints-tests")
--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "zhas.lua"
str = ".1.|2.3|4.5"
for x,y,c in asciirectpoints(str) do print(x, y, c) end
for x,y,c in asciirectpoints(str) do
  if c:match"%d" then
    local p = "#"..c
    print(v(x, y), c)
  end
end

opts = {def="dagHouse", scale="4pt", meta="p b s"}
mp = MixedPicture.new(opts)
PP(mp.lp)
for x,y,c in asciirectpoints(str) do
  if c:match"%d" then
    mp:put(v(x, y), "#"..c)
    mp.lp.def = mp.lp.def.."#"..c
  end
end
= mp
= mp:tolatex()

opts = {def="PvSTbullets", meta="p b s", scale="4pt"}
z = ZHA.fromspec("1234R3L21L"):print()
mp = MixedPicture.new(opts, z)
for v in z:points() do mp:put(v, "**") end
= mp
= mp:tolatex()

opts = {def="dagHouse", scale="4pt", meta="p b s"}
str = ".1.|2.3|4.5"
mp = MixedPicture.new(opts):zfunction(str)
= mp
= mp:tolatex()

mp = MixedPicture.new(opts):zsetbullets(str)
= mp
= mp:tolatex()

-- (find-istfile "1.org" "* 2-column graphs")
-- (find-istfile "1.org" "* 2-column graphs" "how to convert between proper")
z = ZHA.fromspec("12RR1234321L"):print()

--      56	             56
--        46                   ..
--      45  36               ..  ..
--    44  35  26           ..  ..  ..
--  43  34  25  16       43  ..  ..  16
--    33  24  15           33  ..  15
--      23  14               23  14
--        13                   ..
--      12  03               ..  03
--    11  02               ..  02
--  10  01	         10  01
--    00                   ..

-- (find-istfile "1.org" "* ZQuotients")
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "zhas.lua"
z = ZHA.fromspec("12345RR4321"):print()
z = ZHA.fromspec("1234543RR21"):print()
z = ZHA.fromspec("1234543RR21"):print()
z = ZHA.fromspec("1R2R3212RL1"):print()
mp = MixedPicture.new({def="foo"}, z):zhalr()
mp:addcuts("c 4321/0 0123|45|6"):print()

--]]





--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
-- See: (find-LATEX "istanbul-july.tex" "partitiongraph")
dofile "zhas.lua"
opts = {def="graphid", scale="6pt", meta="p b s"}
mp = MixedPicture.new(opts)
spec = "012345"
for y=0,5 do mp:put(v(-1, y), y.."") end
for x=0,5 do mp:put(v(x, -1), x.."") end
for a=0,5 do local aP = spec:sub(a+1, a+1)+0; mp:put(v(a, aP), "*") end
mp.lp:addlineorvector(v(0, 0), v(6, 0), "vector")
mp.lp:addlineorvector(v(0, 0), v(0, 6), "vector")
mp:put(v(7, 0), "a")
mp:put(v(0, 7), "aP", "a^P")
= mp.lp
= mp
= mp.lp
= mp

 (ex "partitiongraph")

 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "zhas.lua"
z = ZHA.fromspec("1R2R3212RL1"):print()
mp = MixedPicture.new({def="ZQ", scale="1pt", meta="b ss"}, z)
mp:zhadots()
mp:lprint()

 (ex "zha-very-small")

--]]








--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "zhas.lua"

--]]







-- Local Variables:
-- coding: raw-text-unix
-- End:
