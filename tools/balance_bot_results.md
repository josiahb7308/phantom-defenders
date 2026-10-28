# Balance bot results (in progress, 2026-10-19/20)

Bot: tools/balance_bot.lua. It plays with Masaru at level 25 (7 assassins + 2 gunners barracks; assassins already nerfed), shoots, uses Makoto's thief ability, heart charms and smoke bombs, and runs with a Studio-only /god mode so boss attacks cannot end the run. Normal difficulty. No yen pouches (removed from the game).

**Yen needed search**: one unlimited run, then a budget cap is bisected (the bot may spend at most that many yen on towers, upgrades and the hero). "Needed" = smallest cap that still wins. "Excess" = yen earned minus yen needed.

| Palace | Unlimited run | Earned | Spent (unlimited) | Yen needed (approx) | Excess |
|---|---|---|---|---|---|
| Pride | WIN, 20/20 hearts | 10,945 | 9,437 | about 5,700-5,850 (5,703 spent and won with 9 hearts; 4,700 cap lost at the boss) | about 46% |
| Greed | LOSS wave 3 | - | - | (run at 4x speed; too fast for the bot, to be redone at 2x) | - |
| Envy | LOSS wave 3 | - | - | (same, to be redone at 2x) | - |
| Wrath | WIN, 15/20 hearts | 33,056 | 22,258 | between 5,550 (lost wave 3, too poor early) and 8,016 (won, 14 hearts) | about 75% |

Lust (palace 6): unlimited run WIN 15/15 hearts, earned 31,512, spent 24,877; a 12,400 cap also WON with 15/15 hearts (spent 12,224, earned 32,095), so the real need is lower still (6,200 was being tested when the bot was paused). Excess is already above 60%.
Sloth (palace 5): unlimited run LOSS at wave 8/20, earned only 4,981 (two-lane map; to be compared with Envy/Abyss/Doubt at 2x).

Raw runs so far (budget = spending cap, nil = unlimited): Pride nil W 9,437 / 4,700 L / 7,050 W 6,798 / 5,850 W 5,703 (9 hearts). Wrath nil W 22,258 / 11,100 W 10,879 / 5,550 L (wave 3, 1,506 spent) / 8,300 W 8,016 (14 hearts).

## Overnight measurements (hero + assassins, 2x speed, new opening yen, Envy easier early waves)
| Palace | Unlimited run | Earned | Spent | Yen needed (bot) | Excess |
|---|---|---|---|---|---|
| Envy (HP 1.2x, first 4 waves -30%, start 1,000) | WIN, 10/20 hearts | 17,207 | 15,787 | ~11,000-11,800 (9,800 cap and 7,850 cap both died at wave 5 with only ~2k spent; 11,800 won with 11 hearts) | ~31% |
| Greed | WIN, 11/20 hearts | 14,241 | 12,933 | ~7,000-8,000 (8,050 cap won with 9 hearts; 6,450 died at wave 10) | ~45% (matches the player's own win with 6,700 unspent) |
| Pride (RealmYen 0.85) | WIN, 20/20 hearts | 10,397 | 9,431 | ~3,500-4,600 (4,700 cap won with 10 hearts; 2,350 lost at the boss) | ~60% |
Findings: RealmYen only scales kill yen and wave bonus, so cutting it 15% only cut Pride's total income about 5% (thief ability, hero abilities etc. pay on top). Envy's early deaths were the wave 5 heavy wave (Hollow Knight + 13 phantoms). Plan: a total-income filter per palace (Config.YenGain) that applies to every yen source and ramps in from wave 3 to wave 8, so early waves keep full income.

## Late-ramp income filter run (2026-10-20 morning, Masaru + 7 assassins, 2x speed)
Config.YenGain ramps in from wave 8 to wave 13, so early waves keep full income. Test values were Pride 0.55, Greed 0.4, Envy 0.5, Wrath 0.35, Lust 0.35.
| Palace | Unlimited run | Earned | Spent | Yen needed (bot) | Spare |
|---|---|---|---|---|---|
| Envy (HP 0.8) | WIN, 10/20 hearts | 13,288 | 12,856 | unclear: three capped runs (6.4k, 9.6k, 11.2k) all died at wave 7 having spent about 3.2k, so wave 7 is variance, not yen | 3% |
| Greed | LOSS wave 13 | 6,847 | 6,393 | not measured (filter 0.4 starved it) | none |
| Sloth (HP 1.3) | LOSS | 16,404 | 15,734 | not measured | none |
| Wrath | WIN, 15/20 hearts | 17,848 | 16,915 | about 6,300 (4,200 cap lost at the boss) | 64% |
| Pride | WIN, 20/20 hearts | 8,675 | 8,077 | about 6,000 (4,000 cap lost at the boss) | 30% |
| Lust | WIN, 15/15 hearts | 16,600 | 15,334 | about 7,400 (3,800 and 5,700 caps lost at the boss) | 55% |
| Sloth (HP 1.0) | LOSS wave 15 | 17,617 | 16,594 | not yen limited: it still died with 1k unspent | none |
| Gluttony | WIN, 15/15 hearts | 36,928 | 28,706 | about 10,750 (14,350 cap won, 7,150 cap lost at wave 16) | 70% |
| Abyss | LOSS wave 5 | 2,607 | 2,510 | not measured: dies at the heavy wave 5 on a 1,400 start | none |
| Time | WIN, 1/15 hearts | 40,780 | 24,676 | 12,300 cap lost at the boss; unspent 16k in the unlimited run | n/a (HP limited) |

Applied afterwards: Greed and Pride filters removed, Envy 0.75, Lust 0.4, Sloth HP 1.0.

## Late palaces (2026-10-20 afternoon, current settings, single full-spend run each)
| Palace | Result | Earned | Spent | Lives by wave |
|---|---|---|---|---|
| Sloth (0.9x, boss 75k) | LOSS at the wave 20 boss | 41.9k | 25.9k | 15 until wave 10, 8 at wave 11, 11 afterwards |
| Abyss | LOSS wave 6 | 3.4k | 3.1k | 15, 15, 11, 10, 10, 3 |
| Doubt | LOSS wave 5 | 3.1k | 3.1k | 15, 15, 15, 11, 11 |
| Time | WIN 15/15 | 42.9k | 23.7k | 15 at every wave |
| Dominion | WIN 15/15 | 50.5k | 33.8k | 15 at every wave |
| Carnival | WIN 15/15 | 48.7k | 45.3k | 15 at every wave |
| Echoes | WIN 15/15 | 59.1k | 33.8k | 15 at every wave |
| Archipelago | WIN 15/15 | 64.1k | 31.2k | 15 at every wave |
Reading: Pride through Lust and Gluttony through Archipelago are not limited by yen (the bot never spends more than about 60% of what it earns after Gluttony) and the late palaces are flawless for the bot, so their enemy health can rise modestly. Abyss and Doubt (Envy wave recipe) collapse at waves 5-6 and need early-wave easing. Sloth is only beaten by its wave 20 boss. After a boss dies the run waits for the Interrogation conversation (Remotes.Negotiate: start, pick, final) and the bot has to answer it.

## Envy and Sloth map redesign (2026-10-20)
The two-lane Envy hall was hard to defend because the lanes sat about 170 studs apart, so no tower spot covered both. Envy now uses a braided serpentine (5 rows, 60 studs wide, the two lanes 12 studs apart, 667 studs per lane against 475 before). A good tower spot covers about 70% more path. Sloth no longer shares Envy's hall: it has its own single meandering lane (614 studs, two sine waves) and a "Hall of Slumber" built with the palace builder.
| Palace | Health x | Result (bot, full spend, Masaru) | Lives by wave |
|---|---|---|---|
| Envy braid | 1.4 | WIN 20/20 | 20 at every wave |
| Envy braid | 2.0 | LOSS wave 6 | 20 until wave 3, 17 at waves 4-5, 1 at wave 6 |
| Envy braid | 1.7 | WIN 20/20, earned 16.2k, spent 15.8k | 20 at every wave (kept) |
| Sloth meander | 1.6 | LOSS at the wave 20 boss | 15 until wave 13 |
| Sloth meander | 1.3 | LOSS at the boss, earned 41.9k, spent 23.4k | 15 until wave 15, 3 at wave 16, 6 afterwards |
| Sloth meander | 1.0 | LOSS at the boss, earned 42.1k, spent 28.2k | 15 until wave 15, 8 at wave 16, 11 afterwards |
Sloth's late waves (16-20) and the Slumber Queen (leak 30, resists Curse/Ice/Psy) are what beats the bot, not the opening or the health multiplier. Applied: Sloth health 0.9x and the Slumber Queen base health 105,000 to 75,000. This last setting was not finished testing.

Bug found while doing this: the editor's cached Config made the builder draw Envy's old track (13 of 18 track pieces off the real lanes). Fixed by rebuilding through a builder copy that loads a fresh Config, then checking every Path part against the lane data (0 off track for Envy, EnvyB and Sloth).

## Yen changes applied (Config.RealmYen, provisional, 2026-10-19 evening)
| Palace | Old multiplier | New | Why |
|---|---|---|---|
| Pride | 1.0 (none) | 0.85 | needs about 5.8k of 10.9k; cut kept small because it is the onboarding palace and early-wave income matters most |
| Wrath | 1.5 | 0.5 | needs 5.5-8k of 33.9k |
| Lust | 1.5 | 0.75 | wins on a 12.4k cap of 32k; true need still being measured, so the cut is conservative |
Not changed yet (waiting on measurements): Greed, Envy, Sloth, Gluttony, Abyss, Time, Doubt, Tides, Dominion, Carnival, Echoes, Archipelago. Opening yen per palace (Greed 400 ... Archipelago 2,800) is unchanged.

Notes
- 4x speed matches 2x for Pride (spent 9,437 vs 9,673 earlier) but the bot loses Greed and Envy in wave 3 at 4x (reaction time too slow for the early rush waves). The remaining palaces run at 2x.
- Wrath earns about 33k yen but needs about 8k: the palace pays roughly 4x what a win requires. Late palaces multiply kill yen by 1.5-2.2x while the yen you can usefully spend is capped by tower count and upgrade path rules.
- Earlier full-spend runs without the hero (pouch era): Pride and Greed reached the boss with 3-15% yen unspent; late palaces were unwinnable from a 250-yen start (fixed by the new opening yen: Greed 400, Wrath 900 ... Archipelago 2,800).

## Abyss and Doubt redesign (2026-10-21)
Both palaces share the Envy wave recipe and had two lanes 80 studs apart (mean gap), so no tower covered both lanes. The bot (full spend, Masaru) collapsed at waves 5-8 even when health was cut to 1.3x. Fix: the lanes are squeezed toward the middle (x * 0.55; Doubt pads moved with them), plus `Config.EarlyEase` (first waves start at 40% / 35% health and climb to full by wave 8).
| Palace | Setting | Result (bot) | Lives by wave |
|---|---|---|---|
| Abyss, old map | HP 3.3 | LOSS wave 7 | 15, 15, 13, 11, 11, 9, 3 |
| Abyss, old map | HP 2.2 | LOSS wave 8 | 15, 15, 15, 12, 12, 9, 8, 4 |
| Abyss, old map | HP 1.3 | LOSS wave 11 (earned 8.6k) | 15, 15, 15, 10 ... 6 |
| Abyss, squeezed lanes | HP 2.2 | WIN 13/15 hearts, earned 38.5k, spent 28.9k | 13 from wave 4 to the end |
| Doubt, old map | HP 4.6 / 2.8 / 1.6 | LOSS waves 5 / 7 / 6 | |
| Doubt, squeezed lanes | HP 2.8 | LOSS wave 15 (earned 15.9k, spent 15.6k) | 15 until wave 7, 9-13 after |
| Doubt, squeezed lanes | HP 2.3 | WIN 15/15, earned 41.7k, spent 31.8k | 15 at every wave |
The bot script now lives in the place as StarterPlayerScripts.ZZ_BalanceBot (disabled; remove before publishing) and as tools/balance_bot.lua. Run it with workspace attribute BOT_PLAN and read BotStatus / BotLog / BotResults from the player's attributes.

## Final pass (2026-10-21 overnight, bot: Masaru + 7 assassins, 2x speed, full spend)
Settings kept: Abyss 2.2, Doubt 2.6, Time 4.7, Tides 7.4, Dominion 7.9, Carnival 8.4, Echoes 9.0, Archipelago 9.6, Slumber Queen base health 38,000.
| Palace | Health x | Result | Earned | Spent |
|---|---|---|---|---|
| Abyss | 2.2 | WIN 13/15 (earlier run, new lanes) | 38.5k | 28.9k |
| Doubt | 2.6 | WIN 10/15 | 39.0k | 27.0k |
| Sloth | 0.9, boss 38k | WIN 1/15 | 42.9k | 25.3k |
| Time | 4.7 | WIN 11/15 (5.2 lost at wave 10) | 42.0k | 24.6k |
| Tides | 7.4 | WIN 15/15 | 40.6k | 26.5k |
| Dominion | 7.9 | WIN 15/15 | 49.2k | 33.8k |
| Carnival | 8.4 | WIN 15/15 | 48.7k | 31.9k |
| Echoes | 9.0 | WIN 5/15 | 57.3k | 36.8k |
| Archipelago | 9.6 | WIN 15/15 | 65.1k | 38.8k |
Notes: the bot has max-level dev personas, a level-25 hero and perfect tower placement, so it is stronger than a real player; flawless wins from Tides on leave room to raise health further once real playtest data exists. Earlier in the night Sloth lost at wave 10 once at the same settings it later won with (bot variance). Doubt at 2.8 lost at wave 15.

## Full pass with the new towers, upgrades and heroes, no items (2026-10-21)
Bot: Masaru + assassins, 2x speed, full spend. This pass used NO heart charms or smoke bombs (winning must come from towers, upgrades, the hero and the thief ability). The deck picker now counts Zone and Beam towers.
| Palace | Result | Earned | Spent |
|---|---|---|---|
| Pride | WIN 20/20 hearts | 11.6k | 9.5k |
| Greed | LOSS wave 5 (hearts 20, 12, 7, 7, 7) | 2.0k | 2.0k |
| Envy | WIN 20/20 | 16.7k | 16.1k |
| Wrath | WIN 12/15 | 16.9k | 16.6k |
| Sloth | WIN 15/15 | 52.8k | 29.9k |
| Lust | WIN 15/15 | 18.2k | 18.1k |
| Gluttony | WIN 15/15 | 37.6k | 27.5k |
| Abyss | WIN 1/15 | 35.0k | 33.5k |
| Time | WIN 15/15 | 41.9k | 24.3k |
| Doubt | LOSS wave 9 | 6.0k | 5.5k |
| Tides | WIN 15/15 | 42.3k | 40.5k |
| Dominion | WIN 15/15 | 52.4k | 37.1k |
| Carnival | WIN 15/15 | 49.8k | 44.9k |
| Echoes | WIN 15/15 | 57.2k | 41.0k |
| Archipelago | WIN 15/15 | 64.0k | 58.1k |
Reading: with the new towers most palaces became flawless wins (too easy), while Greed and Doubt are too hard without items. Greed's first loss traced to Ghoul (a new Zone tower) being too weak to open with; it now always slows enemies in its pools and hits harder. Provisional tuning applied afterwards: enemy health x -20% for Greed, Doubt -23%; +20-30% for the flawless palaces (Envy 2.2, Sloth 1.4, Lust 3.9, Gluttony 3.9, Time 6.0, Tides 9.0, Dominion 9.6, Carnival 10.0, Echoes 10.6, Archipelago 11.2) and the Slumber Queen base health 38k to 55k. A verification pass is still needed.

## 2026-10-28: Hard difficulty and Special Realms (bot at 2x, unlimited spend, hero + thief on)
Hard = enemy HP x1.8, hearts x0.75, rewards x3. Only two Special Realms exist (Wrath, Sloth). The bot is a rough stand-in for a player.

| Realm | Difficulty | Result | Hearts left | Earned | Spent |
|---|---|---|---|---|---|
| Wrath | Normal | WIN | 15/15 | 17,749 | 16,863 (5% unspent) |
| Sloth | Normal | WIN | 15/15 | 51,845 | 28,731 (45% unspent: too generous) |
| Wrath | Hard | WIN (narrow) | 2/15 | 17,077 | 17,055 |
| Sloth | Hard | LOSS at final boss (w20) | 0 | 35,504 | 34,355 |
| Pride | Hard | LOSS at wave 10 | 0 | 4,383 | 4,341 |
| Greed | Hard | LOSS at wave 12 | 0 | 8,589 | 8,198 |

Readings: Wrath is well balanced on both difficulties. Sloth swings from trivial (Normal) to unbeatable (Hard): the Normal yen is too high, the Hard boss is too strong. Pride and Greed on Hard drop several hearts in the first waves and are unwinnable for the bot; the early waves on Hard need an early-wave ease like Abyss/Doubt got (Config.EarlyEase). No values were changed.

Hard, batch 2:

| Realm | Result | Hearts left | Earned | Spent |
|---|---|---|---|---|
| Envy | LOSS at wave 5 | 0 | 1,879 | 1,874 |
| Lust | WIN | 9/11 | 16,883 | 16,412 (3% unspent) |
| Gluttony | WIN | 9/11 | 34,744 | 30,133 (13% unspent) |
| Abyss | LOSS at wave 7 | 0 | 3,587 | 3,188 |

Hard, batch 3:

| Realm | Result | Hearts left | Earned | Spent |
|---|---|---|---|---|
| Time | LOSS at wave 6 | 0 | 4,094 | 3,837 |
| Doubt | LOSS at wave 7 | 0 | 4,238 | 4,151 |
| Tides | WIN (flawless) | 11/11 | 40,804 | 30,168 (26% unspent: too easy for Hard) |
| Dominion | LOSS at wave 15 (11 hearts to 0 in one wave: a spike) | 0 | 22,497 | 22,116 |

Hard, batch 4:

| Realm | Result | Hearts left | Earned | Spent |
|---|---|---|---|---|
| Carnival | WIN (flawless) | 11/11 | 47,679 | 47,208 (1% unspent: good fit) |
| Echoes | WIN (flawless) | 11/11 | 56,689 | 50,020 (12% unspent) |
| Archipelago | LOSS at the final boss (wave 20), flawless until then | 0 | 61,009 | 58,674 |

### Hard summary (13 realms + 2 special; bot, 2x speed)
- Good fit (win, little yen left): Wrath (narrow), Lust, Carnival, Gluttony, Echoes.
- Too easy: Tides (flawless, 26% unspent).
- Early-wave loss (waves 5-12): Envy (w5), Time (w6), Doubt (w7), Abyss (w7), Pride (w10), Greed (w12). Same pattern as Abyss/Doubt on Normal earlier: the first waves on Hard hit too hard for the economy. EarlyEase is the existing lever.
- Late spike / boss loss: Dominion (w15, 11 hearts to 0 in one wave), Archipelago (boss), Sloth (boss).
- Special realms on Normal: Wrath good, Sloth far too generous (45% unspent).
- Caveats: one run per realm/difficulty, a bot that never plays like a person, 2x speed. Treat as a map of where to look, not exact numbers. No game values were changed.

### 2026-10-28 tuning attempt (reverted)
Tried lowering Hard's share of extra enemy health (`Config.HardEase`: Pride .6, Envy .35, Greed/Abyss/Doubt/Time .3, Dominion .65). Result: Envy still lost at wave 5, Time at wave 8, Doubt at wave 7, Abyss at wave 5. Tried Hard enemy speed 1.0 instead of 1.12: Envy and Abyss still lost at wave 5. Neither lever helps, so both edits were reverted (Config is back to the published values).

Control run on Normal (Envy): LOSS at wave 5 (earned 2,363). So the early loss is NOT a Hard problem. The Envy wave recipe (also used by Sloth, Abyss, Doubt, Archipelago) has a heavy wave 5 (about 9,800 HP Hollow, nine Phantoms, three Shard Mothers) that the bot fails now. Envy used to be a flawless bot win (2026-10-20), so something regressed since: most likely the tower-type/upgrade rewrite or the bot's deck/placement choices. Greed on Normal is fine (20/20 hearts at wave 12), so Greed's Hard loss (wave 12) IS Hard-specific.

Next steps to look at (not done): (1) check what the bot's deck and spots are on Envy and whether Phantoms (stealth/phase) need a revealing tower the bot lacks; (2) if a real player can't beat Envy wave 5 with a normal deck, that is a real regression to fix in `Config.BuildWave` / `HpMult` for the Envy recipe; (3) only then re-tune Hard.

### 2026-10-28 Envy investigation (inconclusive, no game changes kept)
- Envy REALM_HP was 1.7 when the bot last won it flawlessly (2026-10-20); it is 2.2 now. Temporarily setting it back to 1.7: the bot still LOSES on Normal (wave 9 instead of wave 5; hearts 20 -> 17 at wave 4, -> 7 at wave 6). So the 2.2 bump is not the whole story. Reverted.
- Wave 5 (heavy) has one Hollow Knight (2000 base HP, leaks 10 hearts); Greed's heavy wave has one Golem (1700 HP, leaks 10), similar in size and the bot beats Greed. The Envy PHASE waves (wave 6: 14 fast Phantoms, 3 Wraiths, reflectors) cost 10 hearts at once.
- Cheap towers (<= 520 yen in-run) with the right elements (Fire, Psy, Bless) have very low damage (14-17/s); the strong ones cost 640-1000. Elec Chain towers (Titania 330 / 95 dps, CuChulainn 470 / 96 dps) are the best affordable picks.
- Conclusion: Envy-recipe realms (Envy, Sloth, Abyss, Doubt, Archipelago) are likely too hard in waves 5-9 for the early economy, or the bot's deck is unsuitable. Only a human playtest of Envy on Normal can tell which. Suggested: have someone try Envy wave 5-9 with a normal deck; if they struggle, ease Envy's PHASE waves (fewer Phantoms) and re-measure.
