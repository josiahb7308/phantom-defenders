# Dev log

A dated record of what changed each day. The game itself lives in a Roblox place (scripts are not in this repo), so this log and `tools/` are the public record of the work.

## 2026-10-21
- **Balance:** found why two palaces (Despair and Doubt) could not be won even at low enemy health: their two lanes sat about 80 studs apart. Pulled the lanes together, eased their first waves, and re-tuned enemy health for every palace from Sloth to the Archipelago with the balance bot. Details and tables in `tools/balance_bot_results.md`.
- **Tutorial:** added a melee lesson and made players keep the tutorial team when they finish training. A human tester played it and said it works.
- **Daily rewards:** added a live countdown to the next reset on the Daily Rewards window.
- **Achievements:** replaced three unreachable S-rank achievements with kill-based ones (same IDs, so existing claims stay valid); added a "!" badge on the Hideout tab when something is ready to claim.
- **Mobile:** added a hold-to-swing MELEE button for phones and re-spaced the touch buttons so they fit short screens.
- **Persona previews:** previews in the hideout and market now fade in whole once their meshes load instead of popping in piece by piece.
- **Lobby look and sound:** softer tree colors and lighting, removed the large "Phantom Lounge" sign, new lobby music.
- **The Hideaway (safe room):** a large indoor lounge with a coffee-and-curry bar, a balcony and fire pit over the city skyline, working couches and booths, a stage with a jukebox, and a bartender. Players earn a slow trickle of Spins for staying, capped per day, with an idle-kick workaround so people can stay. About 750 parts, so it has little effect on performance.
- **Towers:** added three new tower types: Longshot (map-spanning sniper), Zone (lingering pools on the path) and Beam (a beam that ramps up while locked on), each with its own 3-path, 5-tier upgrade tree; seven personas moved onto them. Tier 5 is now rare: a player can have only one tier-5 copy of each persona at a time.
- **Balance pass (no items):** reran the bot through all 15 palaces with heart charms and smoke bombs switched off, using the new towers; most palaces became flawless wins and Greed and Doubt were too hard. Fixed the weak early Zone tower, retuned enemy health per palace, and added the full table to `tools/balance_bot_results.md`. Also moved three heroes onto the new tower types (artillery, frost beam, grave field).
- **Upgrade rewrite:** audited the upgrade data (54 of 77 personas had their own trees; 145 of 810 tiers were only numbers). Rewrote all 145 so every tier now changes how the tower plays (marks, burns, slows, stuns, extra targets, pierce, ricochet, kill chains, death blasts, per-wave income), with descriptions generated from the effects so text and behavior cannot drift apart. Gave the last seven shared-tree deck towers their own trees, so every deck tower now has a unique 3-path, 5-tier tree. Caught and reverted a mistake in my own change: three of the personas I had moved to the new types turned out to be heroes, so the new types now use real deck towers instead.
- **Docs:**  added `SYSTEMS.md`, a short write-up of each game system.
- **Lobby hub (six stations):** a Today board, a challenge giver, a team-finder board, a leaderboard wall, a trophy case, and a practice range that runs a free-play session with your own deck and no rewards.

## 2026-10-20
- Overnight balance runs for all 15 palaces; added early-game easing, income filters for rich palaces, and a redesigned braided two-lane Envy map plus a separate Sloth map.
- Fixed the roll-wheel drawing, made the parkour instructions appear only when you start the course, fixed unlit buildings near the lobby circle, and swapped in the new city models.
- Modelled eight gun models in Blender (exported for import into Studio).
- Rewrote the training tutorial into a compact coach card that teaches movement, the HUD, towers, and key mechanics.

## 2026-10-19
- Built the balance bot (`tools/balance_bot.lua`) and took the first measurements.
- Hideout fixes (scroll position, persona cards), a drop-down lobby menu, a melee weapon system, a better versus-AI win screen, and palace threat ratings.
