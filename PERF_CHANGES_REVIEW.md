# Performance changes made on 2026-10-24: review list

Everything here is already in the place and published. Backups of every edited script are in
`ServerStorage.ZZ_Backup` (names shown next to each script). None of this was measured on a Mac or a phone: the only numbers
come from solo Studio Play (`Stats.FrameRateManager`), so they show relative cost, not your real FPS.

Gameplay rules were not touched by any of these: damage, fire rates, targeting, rewards, wave timing and placement are unchanged.
The one server edit is cosmetic (shadows).

## A. Changes with NO script backup (properties set in the place)

| Change | Where | Before -> after | How to undo |
|---|---|---|---|
| Mesh quality | All 5,330 MeshParts | RenderFidelity Automatic -> Performance, CollisionFidelity Default -> Box | Set both back for all MeshParts (one Luau loop) |
| City meshes | SkylineNew, LobbyCityNew/V2, ArenaCity* | CanQuery true -> false, CanCollide/CanTouch false, CastShadow false | Set CanQuery true |
| Shadow casters | Lobby (3,242 parts), all Arena* | Lobby casters 3,242 -> 654; arenas ~60-80 each. Rule: parts under 8 studs, neon, see-through or thinner than 0.4 stop casting; then flat arena parts under 1.6 studs | Set CastShadow true on those parts |
| Sky cloud emitters | LobbySky (40 Bank + 20 GlowBase emitters) | Every second bank dropped (Enabled false, Rate 0); the rest Rate x0.8 and tagged `SkyTier`. ~2,710 -> ~1,084 particles alive | Original rates of the dropped ones are NOT stored: use Studio version history |
| Lobby fog banks | LobbyFog script | Rates 10/10/8 -> 5/5/4 | Edit the three numbers (see section B) |

If you want to undo any group exactly, the safest route is Studio's version history (File > Local Backups / the place's Version History on the Creator Hub), restoring the version from before 2026-10-24 ~17:00 local.

## B. Script changes (diff versus the backup)

### Game (server): backup `Game_pre_perf`
Cosmetic only: enemy parts (except the body) and small tower parts no longer cast shadows.
```
@@ near old line 699 (+1)
+ 			if d:IsA("BasePart") and d ~= body then d.CastShadow = false end -- only the body casts a shadow
@@ near old line 857 (+3)
+ 	for _, d in ipairs(model:GetDescendants()) do -- small decorative pieces do not need to cast shadows
+ 		if d:IsA("BasePart") and d ~= base and math.max(d.Size.X, d.Size.Y, d.Size.Z) < 3.5 then d.CastShadow = false end
+ 	end
```

### EnemyAnim (client): backup `EnemyAnim_pre_perf`
Limb animation at 30 Hz instead of every frame; enemies more than 190 studs from the camera are not animated.
```
- RunService.RenderStepped:Connect(function()
- 	local t = os.clock()
+ local acc = 0
+ RunService.RenderStepped:Connect(function(dt)
+ 	acc += dt
+ 	if acc < 1 / 30 then return end -- limb wiggles at 30 Hz
+ 	acc = 0
+ 	local t = os.clock()
+ 	local cam = workspace.CurrentCamera
+ 	local cp = cam and cam.CFrame.Position
...
+ 		elseif cp and (body.Position - cp):Dot(body.Position - cp) > 190 * 190 then
+ 			-- too far away to see the limbs move
```

### NeonTone (client): backup `NeonTone_pre_perf`
New parts are only toned if they are neon or lights (before: every new part triggered an ancestor walk).
```
- 		if (d:IsA("BasePart") or d:IsA("Light")) and isTarget(d) then task.defer(tone, d) end
+ 		if ((d:IsA("BasePart") and d.Material == Enum.Material.Neon) or d:IsA("Light")) and isTarget(d) then task.defer(tone, d) end
```

### CityLife (client): backup `CityLife_pre_perf`
Train and window flicker at 30 Hz, and only while the camera is within 700 studs (was every frame, 900).
```
- 	RunService.Heartbeat:Connect(function(dt)
- 		local cam = workspace.CurrentCamera
- 		if not cam or (cam.CFrame.Position - CEN).Magnitude > 900 then return end
+ 	local accC = 0
+ 	RunService.Heartbeat:Connect(function(dt0)
+ 		accC += dt0
+ 		if accC < 1 / 30 then return end
+ 		local dt = accC
+ 		accC = 0
+ 		local cam = workspace.CurrentCamera
+ 		if not cam or (cam.CFrame.Position - CEN).Magnitude > 700 then return end
```

### LobbySky (client): backup `LobbySky_pre_perf`
Sky animation (clouds, beams, cards, crows) at 30 Hz.
```
- 	RunService.RenderStepped:Connect(function(dt)
+ 	local accSky = 0
+ 	RunService.RenderStepped:Connect(function(dt0)
+ 		accSky += dt0
+ 		if accSky < 1 / 30 then return end
+ 		local dt = accSky
+ 		accSky = 0
```

### Client (client): backup `Client_pre_perf`
1. Tower orbit/flap numbers (attributes) read once at registration instead of ~6 attribute reads per part per frame.
2. Ambient animation (spin/bob/pulse parts): enemy parts are skipped before any work; updates at 30 Hz (20 Hz on phones), pulses at 15 Hz and stopped once quality drops; far-cull 300 -> 220 studs.
```
- 	local orbiters, orbSt = {}, {}
+ 	local orbiters, orbSt, orbData = {}, {}, {}
+ 	(orbData cached at registration, used in the per-frame loop instead of GetAttribute)
- 	workspace.DescendantAdded:Connect(function(d) task.defer(register, d) end)
+ 	local enemiesF = workspace:FindFirstChild("Enemies")
+ 	workspace.DescendantAdded:Connect(function(d)
+ 		if not d:IsA("BasePart") then return end
+ 		enemiesF = enemiesF or workspace:FindFirstChild("Enemies")
+ 		if enemiesF and d:IsDescendantOf(enemiesF) then return end
+ 		task.defer(register, d)
+ 	end)
- 		local FAR2 = 300 * 300
+ 		local FAR2 = 220 * 220
- 		if fr % 2 == 1 and Players.LocalPlayer:GetAttribute("Lite") then return end
+ 		accA += dt
+ 		local step = Players.LocalPlayer:GetAttribute("Lite") and (1 / 20) or (1 / 30)
+ 		if accA < step then return end
+ 		accA = 0
+ 		local doPulse = fr % 2 == 0 and (Players.LocalPlayer:GetAttribute("PerfTier") or 0) < 1
+ 		if not doPulse then return end   (before the pulse loop)
```

### MobileLite (client, phones): backup `MobileLite_pre_perf2`
Phones no longer detach the lobby/other palaces themselves: `PerfGovernor` does that for every device. Light culling stays.
```
- 				cullWorld(true)
- 		cullWorld(false) -- first, so the lobby floor is back before the character lands
```

### LobbyFog (client): backup `LobbyFog_pre_perf2`
Half the fog smoke; fog banks switch off when quality drops.
```
- bank(10, 18, 10, 90, 0.76)  /  bank(55, 40, 10, 120, 0.78)  /  bank(125, 70, 8, 160, 0.82)
+ bank(10, 18, 5, 90, 0.76)   /  bank(55, 40, 5, 120, 0.78)   /  bank(125, 70, 4, 160, 0.82)
- 	for _, e in ipairs(emitters) do e.Enabled = v end
+ 	for _, e in ipairs(emitters) do e.Enabled = v and (LP:GetAttribute("PerfTier") or 0) < 1 end
+ 	(plus a PerfTier change listener)
```

### Data (server): backup `Data_pre_gfx`
Saves the new GRAPHICS choice with the player profile (same whitelist style as the other settings; only four fixed strings are accepted).
```
+ 	if v.Gfx == "AUTO" or v.Gfx == "HIGH" or v.Gfx == "BALANCED" or v.Gfx == "FAST" then out.Gfx = v.Gfx end
```

### Settings (client): backup `Settings_pre_gfx`
GRAPHICS row in the GAME tab (AUTO / HIGH / BALANCED / FAST), default AUTO, sets the player attribute `GfxMode`.
Also the Studio-only test hook `DevOpenSettings` can now take a tab name (harmless in the live game).

### PerfGovernor (client, NEW LocalScript): backup of earlier version `PerfGovernor_v1`, `PerfGovernor_pre_gfx`
About 11,000 characters, read it at `StarterPlayerScripts.PerfGovernor`. It does five things:
1. World culler: in the lobby the palaces are detached from this client's view; in a run the lobby, city, sky and other palaces are. A folder it cannot measure is never hidden.
2. Light budget: only the nearest N lights stay on (28 / 14 / 8 / 4 by quality tier). It only switches things off; it never turns a light on that the game wanted off.
3. Emitter cull: ambient emitters far from the camera are switched off (sky clouds are excluded; they use the tier tags).
4. Auto quality: if FPS stays under 42 for two 4-second windows (after a 25-second grace period) it steps tier 0 -> 3 (tier 2 = no shadows and no bloom, tier 3 = also less haze and no colour correction, no emitters). AUTO never steps back up in a session. HIGH disables it; BALANCED starts at tier 1; FAST at tier 2.
5. In a run: towers, enemies, minions, effects and characters stop casting shadows (re-enabled for characters when you return to the lobby).

## C. What to check yourself

1. Lobby looks the same (fountain, ponds, stations), fog and clouds present.
2. Start a run: arena, towers, enemies, damage numbers all appear; return to the lobby and everything is back.
3. Settings > GAME > GRAPHICS cycles AUTO / HIGH / BALANCED / FAST; FAST visibly drops shadows and bloom.
4. Play a long run on your Mac with each mode and compare how it feels.

## D. Not verified

- FPS on your Mac or any phone (measured only in Studio, where GPU cost is much lower).
- Multiplayer (everything here was tested solo).
- Memory over many waves.
