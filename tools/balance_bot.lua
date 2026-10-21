_G.BOT_CFG = { speed = 2, capMul = 1, hero = true }
local R = game.ReplicatedStorage.Remotes
local C = require(game.ReplicatedStorage.Config)
local Pe = require(game.ReplicatedStorage.Personas)
local P = game.Players.LocalPlayer
local S = game.ReplicatedStorage.GameState
local ORDER = { "Pride", "Greed", "Envy", "Wrath", "Sloth", "Lust", "Gluttony", "Abyss", "Time", "Doubt", "Tides", "Dominion", "Carnival", "Echoes", "Archipelago" }
if _G.BOT then _G.BOT.stop = true end
_G.BOT = { results = {}, search = {}, status = "idle", log = {}, stop = false }
local B = _G.BOT
local function note(s) B.log[#B.log + 1] = os.date("%H:%M:%S ") .. s if #B.log > 300 then table.remove(B.log, 1) end end
local function waitFor(f, t) local e = 0 while not f() and e < t do task.wait(0.25) e += 0.25 end return f() end
local function inRun() return P:GetAttribute("InRun") == true end
local function leave()
	pcall(function() R.Continue:FireServer() end)
	R.LeaveRun:FireServer()
	waitFor(function() return not inRun() end, 25)
	task.wait(3)
end
local ELEMENTS = { "Phys", "Fire", "Ice", "Elec", "Psy", "Nuke", "Bless", "Curse", "Gun" }
local function elementMul(realm)
	local sum, total = {}, 0
	for _, el in ipairs(ELEMENTS) do sum[el] = 0 end
	for wave = 1, 15 do
		local ok, list = pcall(C.BuildWave, wave, realm)
		if ok then
			for _, e in ipairs(list) do
				local def = C.Enemies[e[1]]
				if def and not def.IsBoss then
					local wgt = def.Hp * C.HpMult(wave, realm)
					total += wgt
					for _, el in ipairs(ELEMENTS) do
						local m = (def.Weak and def.Weak[el]) and 1.5 or ((def.Resist and def.Resist[el]) and 0.5 or 1)
						sum[el] += wgt * m
					end
				end
			end
		end
	end
	local mul = {}
	for _, el in ipairs(ELEMENTS) do mul[el] = total > 0 and sum[el] / total or 1 end
	return mul
end
local function setDeck(k, realm)
	local d = R.GetData:InvokeServer()
	for _, u in ipairs(d.Loadout) do R.Shop:InvokeServer("Unequip", u) end
	d = R.GetData:InvokeServer()
	local seen, cands = {}, {}
	for _, x in ipairs(d.Owned) do
		local def = Pe.Personas[x.id]
		if def and not seen[x.id] and not def.Aquatic and def.Tier and def.Cost then
			seen[x.id] = true
			cands[#cands + 1] = { uid = x.uid, id = x.id, def = def }
		end
	end
	local KM = { Single = 1, AOE = 2.2, Chain = 2.5, Barrage = 2, Cleave = 1.8 }
	local emul = elementMul(realm)
	local cap = (220 + k * 100) * ((_G.BOT_CFG and _G.BOT_CFG.capMul) or 1)
	local pool = {}
	for _, c in ipairs(cands) do
		local def = c.def
		if (def.Damage or 0) > 0 and def.Cost <= cap then
			c.score = def.Damage * (KM[def.Kind] or 1.2) * (1 + (def.Crit or 0)) / math.max(def.Cooldown or 1, 0.2) * (emul[def.Element] or 1) ^ 2
			c.value = c.score / math.sqrt(def.Cost)
			pool[#pool + 1] = c
		end
	end
	table.sort(pool, function(a, b) return a.value > b.value end)
	local deck, el, cheap = {}, {}, 0
	local function take(c) el[c.def.Element] = (el[c.def.Element] or 0) + 1 deck[#deck + 1] = c if c.def.Cost <= 200 then cheap += 1 end end
	for _, c in ipairs(pool) do
		if c.def.Cost <= 200 and cheap < 2 and (el[c.def.Element] or 0) < 2 then take(c) end
	end
	for _, c in ipairs(pool) do
		if #deck < 6 and (el[c.def.Element] or 0) < 2 and not table.find(deck, c) then take(c) end
	end
	for _, c in ipairs(deck) do R.Shop:InvokeServer("Equip", c.uid) end
	return deck
end
local function spotPicker(realm)
	local map = C.GetMap(realm)
	local samples = {}
	for _, pts in ipairs(map.Paths or { map.Pts }) do
		for i = 2, #pts do
			local a, b = pts[i - 1], pts[i]
			local len = (b - a).Magnitude
			for s = 0, len, 4 do samples[#samples + 1] = a + (b - a) * (s / len) end
		end
	end
	local cands = {}
	local off = map.Offset
	for dx = -100, 100, 2 do
		for dz = -100, 100, 2 do
			local p = Vector3.new(off.X + dx, 0, off.Z + dz)
			local dd = C.DistToPath(p, map)
			if dd >= 9 and dd <= 26 and not C.PadAt(p, map) and C.IsValidSpot(p, {}, map, false) then cands[#cands + 1] = { p, dd } end
		end
	end
	local used = {}
	local function pick(def)
		local r = (def.Range or 24) * 0.95
		local best, bs
		for _, c in ipairs(cands) do
			local p = c[1]
			local ok = true
			for _, u in ipairs(used) do if (u - p).Magnitude < 10 then ok = false break end end
			if ok then
				local score = 0
				for _, q in ipairs(samples) do if (Vector3.new(q.X, 0, q.Z) - p).Magnitude <= r then score += 1 end end
				score = score - c[2] * 0.02
				if not bs or score > bs then best, bs = p, score end
			end
		end
		return best
	end
	return pick, used
end
local function myTowers()
	local list = {}
	for _, m in ipairs(workspace.Towers:GetChildren()) do
		if m:GetAttribute("OwnerId") == P.UserId and not m:GetAttribute("IsHero") then list[#list + 1] = m end
	end
	return list
end
local function tryUpgrade(yen)
	local best
	for _, m in ipairs(myTowers()) do
		local def = Pe.Personas[m:GetAttribute("Persona")]
		local ps = tostring(m:GetAttribute("Paths") or "000")
		local paths = { tonumber(ps:sub(1, 1)) or 0, tonumber(ps:sub(2, 2)) or 0, tonumber(ps:sub(3, 3)) or 0 }
		local stage = m:GetAttribute("Stage") or 1
		for p = 1, 3 do
			local ok = Pe.CanUpgrade(paths, p, stage)
			if ok then
				local tier = paths[p] + 1
				local cost = Pe.PathCost(def, tier, 0)
				local pri = paths[p] * 1000 + (m:GetAttribute("Kills") or 0)
				if cost <= yen and (not best or pri > best.pri) then best = { id = m:GetAttribute("TowerId"), p = p, cost = cost, pri = pri, name = m:GetAttribute("Persona") } end
			end
		end
	end
	if best then
		R.BuyPerk:FireServer(best.id, best.p)
		return best
	end
end
local function playRun(realm, strat, k, budget)
	local rec = { realm = realm, strat = strat, budget = budget, t0 = os.clock(), perWave = {}, upgrades = 0, upgSpent = 0, towSpent = 0, earned = 0, minLives = 99 }
	B.current = rec
	leave()
	local deck = setDeck(k, realm)
	rec.roster = {}
	for _, c in ipairs(deck) do rec.roster[#rec.roster + 1] = c.id end
	R.JoinRun:FireServer(realm, "Normal")
	if not waitFor(function() return inRun() and S:GetAttribute("Phase") == "Prep" end, 40) then rec.result = "NOJOIN" B.results[#B.results + 1] = rec return rec end
	local pick, used = spotPicker(realm)
	local order = {}
	for _, c in ipairs(deck) do order[#order + 1] = c end
	table.sort(order, function(a, b) return a.def.Cost < b.def.Cost end)
	local placed = 0
	local lastYen = P:GetAttribute("Yen") or 0
	rec.start = lastYen
	_G.BOT_ROOM = budget or math.huge
	local hrp0 = P.Character and P.Character:FindFirstChild("HumanoidRootPart")
	local home = pick({ Range = 30 })
	if hrp0 and home then hrp0.CFrame = CFrame.new(home.X, 4, home.Z + 4) end
	local shootOn = true
	task.spawn(function()
		while shootOn and not B.stop do
			local hrp = P.Character and P.Character:FindFirstChild("HumanoidRootPart")
			local ef = workspace:FindFirstChild("Enemies")
			if hrp and ef and S:GetAttribute("Phase") == "Combat" then
				local best, bd = nil, 65
				for _, e in ipairs(ef:GetChildren()) do
					local pp = e:GetPivot().Position
					local d = Vector3.new(pp.X - hrp.Position.X, 0, pp.Z - hrp.Position.Z).Magnitude
					if d < bd then best, bd = e, d end
				end
				if best then
					local pp = best:GetPivot().Position
					local dir = Vector3.new(pp.X - hrp.Position.X, 0, pp.Z - hrp.Position.Z)
					if dir.Magnitude > 0.5 then
						dir = dir.Unit
						hrp.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + dir)
						R.Shoot:FireServer(dir)
					end
				end
			end
			task.wait(0.15)
		end
	end)
	local lastWave, deadline, prepFor = 0, os.clock() + 1500, 0
	local conn = P:GetAttributeChangedSignal("Yen"):Connect(function()
		local y = P:GetAttribute("Yen") or 0
		if y > lastYen then rec.earned += y - lastYen end
		lastYen = y
	end)
	while os.clock() < deadline and not B.stop do
		local phase = S:GetAttribute("Phase")
		local lives = S:GetAttribute("Lives") or 0
		rec.minLives = math.min(rec.minLives, lives)
		local w = S:GetAttribute("Wave") or 0
		if w ~= lastWave then
			rec.perWave[#rec.perWave + 1] = { w = w, yen = lastYen, lives = lives, t = math.floor(os.clock() - rec.t0), earned = math.floor(rec.earned) }
			lastWave = w
		end
		local want = (_G.BOT_CFG and _G.BOT_CFG.speed) or 2
		if (S:GetAttribute("Speed") or 1) ~= want then R.SetSpeed:FireServer(want) end
		if phase == "Report" or phase == "Idle" or not inRun() then break end
		if phase == "Prep" or phase == "Combat" then
			local acted = true
			while acted do
				acted = false
				local yen = P:GetAttribute("Yen") or 0
				local room = (budget or math.huge) - (rec.start + rec.earned - yen)
				_G.BOT_ROOM = room
				local nxt = order[placed + 1]
				local spot = nxt and yen >= nxt.def.Cost and nxt.def.Cost <= room and pick(nxt.def)
				if spot then
					R.PlaceTower:FireServer(nxt.uid, spot)
					task.wait(0.5)
					local y2 = P:GetAttribute("Yen") or 0
					placed += 1
					if y2 < yen then used[#used + 1] = spot rec.towSpent += yen - y2 acted = true end
				elseif strat == "full" and placed >= math.min(#order, 4) then
					local u = tryUpgrade(math.min(yen, room))
					if u then
						task.wait(0.4)
						rec.upgrades += 1 rec.upgSpent += u.cost acted = true
					end
				end
			end
			if phase == "Prep" then
				prepFor += 1
				if prepFor >= 8 then R.SkipWave:FireServer() prepFor = 0 end
			else
				prepFor = 0
			end
		end
		task.wait(0.4)
	end
	conn:Disconnect()
	shootOn = false
	rec.endLives = S:GetAttribute("Lives") or 0
	rec.waveReached = S:GetAttribute("Wave") or 0
	rec.waves = S:GetAttribute("Waves")
	rec.result = (rec.endLives > 0 and (S:GetAttribute("Phase") == "Report" or rec.waveReached >= (rec.waves or 99))) and "WIN" or "LOSS"
	rec.left = math.floor(P:GetAttribute("Yen") or 0)
	rec.earnedTotal = math.floor(rec.start + rec.earned)
	rec.spent = rec.earnedTotal - rec.left
	rec.unspentPct = math.floor(100 * rec.left / math.max(1, rec.earnedTotal))
	rec.secs = math.floor(os.clock() - rec.t0)
	B.results[#B.results + 1] = rec
	return rec
end
function _G.BOT_SEARCH(realms, noSearch)
	B.stop, B.status = false, "starting"
	task.spawn(function()
		R.DevCmd:FireServer("max")
		task.wait(1.5)
		R.DevCmd:FireServer("personas")
		task.wait(3)
		for _, realm in ipairs(realms) do
			if B.stop then break end
			local k = table.find(ORDER, realm) or 1
			B.status = ("search %s: unlimited run"):format(realm)
			local ok0, r0 = pcall(playRun, realm, "full", k, nil)
			local entry = { realm = realm, runs = {} }
			B.search[realm] = entry
			if ok0 and r0 then
				entry.full = { result = r0.result, spent = r0.spent, earned = r0.earnedTotal, left = r0.left, wave = r0.waveReached, hearts = r0.endLives, minLives = r0.minLives }
				if r0.result == "WIN" and not noSearch then
					local lo, hi = 0, r0.spent
					for step = 1, 3 do
						if B.stop then break end
						local mid = math.floor((lo + hi) / 2 / 50) * 50
						B.status = ("search %s: budget %d (step %d)"):format(realm, mid, step)
						local ok, r = pcall(playRun, realm, "full", k, mid)
						if ok and r then
							entry.runs[#entry.runs + 1] = { budget = mid, result = r.result, spent = r.spent, wave = r.waveReached, hearts = r.endLives }
							if r.result == "WIN" then hi = math.min(hi, math.max(r.spent, mid)) else lo = mid end
						else break end
					end
					entry.need = hi
					entry.excess = r0.earnedTotal - hi
					entry.excessPct = math.floor(100 * entry.excess / math.max(1, r0.earnedTotal))
				end
			else
				note("ERR " .. realm .. " " .. tostring(r0))
			end
			local lv = {} for _, w in ipairs((r0 and r0.perWave) or {}) do lv[#lv + 1] = w.w .. ":" .. w.lives end
			note(("%s: full %s hearts=%s wave=%s spent=%s earned=%s need~%s | lives by wave %s"):format(realm, tostring(entry.full and entry.full.result), tostring(entry.full and entry.full.hearts), tostring(entry.full and entry.full.wave), tostring(entry.full and entry.full.spent), tostring(entry.full and entry.full.earned), tostring(entry.need), table.concat(lv, " ")))
		end
		B.status = "DONE"
	end)
end
_G.BOT_HELP = false
_G.BOT_HERO = false
_G.BOT_NEG = false
task.wait(1.4)
_G.BOT_HELP = true
_G.BOT_NEG = true
task.spawn(function()
	local lastTry = 0
	while _G.BOT_NEG do
		if S:GetAttribute("Phase") == "Interrogation" and os.clock() - lastTry > 6 then
			lastTry = os.clock()
			local ok, view = pcall(function() return R.Negotiate:InvokeServer("start") end)
			local guard = 0
			while ok and type(view) == "table" and view.stage == "ask" and guard < 8 do
				guard += 1
				local res = R.Negotiate:InvokeServer("pick", 1)
				if not res then break end
				view = res.next
				task.wait(0.2)
			end
			if ok and type(view) == "table" and view.stage == "final" then
				local id
				for _, ch in ipairs(view.choices) do if ch.enabled and ch.id ~= "recruit" then id = ch.id break end end
				pcall(function() R.Negotiate:InvokeServer("final", id or view.choices[#view.choices].id) end)
			end
		end
		task.wait(1)
	end
end)
task.spawn(function()
	local charms, smokes, lastLives, lastMax, lastGod = 0, 0, 20, 0, 0
	while _G.BOT_HELP do
		local ph = S:GetAttribute("Phase")
		local cur = _G.BOT and _G.BOT.current
		if P:GetAttribute("InRun") and (ph == "Prep" or ph == "Combat") then
			local lives = S:GetAttribute("Lives") or 20
			local hum = P.Character and P.Character:FindFirstChildOfClass("Humanoid")
			if hum and hum.MaxHealth < 1e8 and os.clock() - lastGod > 2 then R.DevCmd:FireServer("god") lastGod = os.clock() end
			if os.time() >= (P:GetAttribute("ThiefReadyAt") or 0) then
				R.ThiefCmd:FireServer("Cast")
				if cur then cur.thief = (cur.thief or 0) + 1 end
				task.wait(1)
			end
			if lives <= 8 and charms < 2 then R.UseItem:FireServer("Charm") charms += 1 end
			if lives < lastLives - 2 and smokes < 4 and ph == "Combat" then R.UseItem:FireServer("Smoke") smokes += 1 end
			lastLives = lives
		else
			if not P:GetAttribute("InRun") then
				charms, smokes, lastLives = 0, 0, 20
				if os.clock() - lastMax > 4 then R.DevCmd:FireServer("max") lastMax = os.clock() end
			end
		end
		task.wait(1)
	end
end)
_G.BOT_HERO = true
task.spawn(function()
	local selected, leveled, comp, lastAH, lastUlt, lastRally = false, false, false, 0, 0, 0
	while _G.BOT_HERO do
		if not (_G.BOT_CFG and _G.BOT_CFG.hero) then task.wait(2) continue end
		local inrun = P:GetAttribute("InRun")
		local ph = S:GetAttribute("Phase")
		if not inrun then
			leveled, comp = false, false
			if not selected and ph == "Idle" then R.Shop:InvokeServer("SelectHero", "Masaru") selected = true end
		elseif ph == "Prep" or ph == "Combat" then
			selected = false
			if not P:GetAttribute("HeroPlaced") then
				local yen = P:GetAttribute("Yen") or 0
				local pts, taken = {}, {}
				for _, m in ipairs(workspace.Towers:GetChildren()) do
					if m:GetAttribute("OwnerId") == P.UserId and not m:GetAttribute("IsHero") then pts[#pts + 1] = m:GetPivot().Position taken[#taken + 1] = m:GetPivot().Position end
				end
				if yen >= 520 and #pts >= 2 and (_G.BOT_ROOM or math.huge) >= 520 then
					local ctr = Vector3.zero
					for _, p in ipairs(pts) do ctr += p end
					ctr /= #pts
					local map = C.GetMap(P:GetAttribute("RunMap") or S:GetAttribute("Realm"))
					local best, bs
					for dx = -30, 30, 3 do
						for dz = -30, 30, 3 do
							local p = Vector3.new(ctr.X + dx, 0, ctr.Z + dz)
							local dd = C.DistToPath(p, map)
							if dd >= 9 and C.IsValidSpot(p, taken, map, false) then
								local s = -dd - (p - ctr).Magnitude * 0.3
								if not bs or s > bs then best, bs = p, s end
							end
						end
					end
					if best then R.PlaceHero:FireServer(best) task.wait(1) end
				end
			else
				if not leveled then R.DevHeroLv:FireServer() leveled = true task.wait(0.5) end
				if not comp then
					R.BarracksSet:FireServer({ Guard = 0, Gunner = 2, Bomber = 0, Assassin = 7 }, "Fire")
					comp = true
					task.wait(0.5)
					R.HeroAbility:FireServer(2)
					lastAH = os.clock()
				end
				local hrp = P.Character and P.Character:FindFirstChild("HumanoidRootPart")
				local aim = hrp and hrp.Position or Vector3.zero
				if os.clock() - lastAH > 24 then R.HeroAbility:FireServer(2) lastAH = os.clock() end
				if os.clock() - lastRally > 20 then R.HeroAbility:FireServer(1, aim) lastRally = os.clock() end
				if os.clock() - lastUlt > 62 and ph == "Combat" then R.HeroAbility:FireServer(3, aim) lastUlt = os.clock() end
			end
		end
		task.wait(1)
	end
end)
