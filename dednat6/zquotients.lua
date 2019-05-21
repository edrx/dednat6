-- zquotients.lua: handle (z)quotients of ZHAs
-- This file:
-- http://angg.twu.net/dednat6/zquotients.lua
-- http://angg.twu.net/dednat6/zquotients.lua.html
--  (find-angg        "dednat6/zquotients.lua")
--

todd = function (a, b) return a..b end
to_d_d = function (o)
    if type(o) == "string" then return o:sub(1,1)+0, o:sub(2)+0 end
    return o:to_l_r()
  end

Picc = Class {
  type    = "Picc",
  from = function (spicc)
      local n = spicc:sub(-1)+0
      local picc = Picc {spicc=spicc, n=n, qn=0, low={}, hi={}, trans={}}
      for digits in spicc:gmatch"%d+" do
        local low, hi = digits:sub(1, 1), digits:sub(-1)
        local range = low.."-"..hi
        for b=low+0,hi+0 do
          picc.low[b] = low+0
          picc.hi [b] = hi +0
        end
        picc.trans[picc.qn] = range
        picc.trans[range] = picc.qn
        picc.qn = picc.qn + 1
      end
      picc.qn = picc.qn - 1
      return picc
    end,
  __index = {
    down = function (picc, b) return picc.low[b] end,
    downoneup = function (picc, b)
        if b == 0 then return 0 end
        local a,c = picc.low[b-1], picc.low[b-1]
        if c == #picc.low then return 0 end
        return c
      end,
  },
}

-- Not used (?), and the demos are broken
ZQuotient = Class {
  type = "ZQuotient",
  from = function (leftspicc, rightspicc)
      local leftpicc  = Picc.from(leftspicc)
      local rightpicc = Picc.from(rightspicc)
      return ZQuotient {L=leftpicc, R=rightpicc}
    end,
  __index = {
    quot_lr2 = function (zq, l, r) return zq.L:down(l), zq.L:downoneup(r) end,
    quot_rl2 = function (zq, l, r) return zq.L:downoneup(l), zq.L:down(r) end,
    quot_lr1 = function (zq, ab) return todd(zq:quot_lr2(to_d_d(ab))) end,
    quot_rl2 = function (zq, ab) return todd(zq:quot_rl2(to_d_d(ab))) end,
    quotientarrows = function (zq, lrs, rls)
        local qlrs, qrls = {}
        for ab in lrs:gmatch"%d" do table.insert(qlrs, zq:quot_lr1(ab)) end
        for ab in rls:gmatch"%d" do table.insert(qrls, zq:quot_rl1(ab)) end
        qlrs = table.concat(qlrs, " ")
        qrls = table.concat(qrls, " ")
        return qlrs, qrls
      end,
  },
}




-- local a, b = ab:sub(1,1)+0, ab:sub(2)+0


--[[
 (eepitch-lua51)
 (eepitch-kill)
 (eepitch-lua51)
dofile "zquotients.lua"
PPV(Picc.from "01|234|56")

zq = ZQuotient.from("01|234|56", "01|234|56")
zq:quot_lr1()

zq = ZQuotient.from2("01|234|56", "01|234|56")
PPV(zq.L)
= zq:quotientarrow_lr(2, 2)
= zq:quotientarrow_lr(3, 3)
= zq:quotientarrow_lr(5, 5)
= zq:quotientarrow_lr(6, 5)

--]]


-- Local Variables:
-- coding: raw-text-unix
-- End:

