# Systems overview

Short write-ups of how each part of Phantom Defenders works. The game is a Persona-inspired tower defense in Roblox (Luau). The scripts live in the Roblox place, so these notes describe design and behavior rather than linking to code.

## Run loop and palaces
A run is a sequence of waves through one of 15 themed "palaces" (15 to 20 waves each, Normal and Hard difficulty, plus an endless mode). Each palace has its own map, enemy mix, health scaling and a boss wave. Enemies that reach the end cost lives (bosses cost many), and the run is lost at zero. Health, income and boss strength are tuned per palace with a balance bot (see `tools/`).

## Towers (Personas)
Players equip a deck of up to six Persona towers (77 in total). Each has an element, a role (single shot, area, chain, barrage, buff, curse or income), three upgrade paths and evolutions during the run. Placement is validated on the server (distance to the path, spacing, special pads and pools), so a modified client cannot place towers illegally.

## Weakness and All-Out
Hitting an enemy's weak element deals extra damage, briefly stuns it and fills the All-Out meter; resisted elements deal less. At a full meter the player can trigger an All-Out Attack that stuns and heavily damages everything on screen, with reduced effect on bosses.

## Heroes and the barracks
Each run a player can deploy one hero, who levels up during the run, gains active skills and an ultimate, and shapes the team build. A barracks lets the player mix troop types that fight along the path.

## The Phantom Thief (the player character)
The player also fights: aim and shoot with a gun, dash, use a character-specific special ability on a cooldown, swing a melee weapon, and carry limited items (smoke bomb, molotov, heart charm, adrenaline). Phones get on-screen buttons for dash, melee, hero and All-Out.

## Interrogation
After a boss falls, a short negotiation begins. The player answers a set of questions to build trust, then chooses to recruit the boss, extort them or spare them, with different rewards. It is server-validated so choices and rewards cannot be forged.

## Velvet Room: fusion and rolls
Personas can be fused using recipes, including hidden ones that are discovered by experimenting. New personas come from a roll wheel that spends Spins and Gems. Spins come from achievements, quests, the daily gift and the Hideaway.

## Armory and Hideout
The Armory sells guns, melee weapons and items for in-game currency. The Hideout is where players manage their deck, heroes, thieves, achievements and saved builds, with 3D previews of each persona that fade in once their meshes load.

## Progression
60 achievements (collection, fusion, power, palaces, teamwork) pay Treasure and Spins; quests and a daily and weekly challenge give recurring goals; a 7-day daily reward streak has a live countdown to the next reset. Achievements are tracked from saved stats and can be claimed from the Hideout.

## Teams and versus
Players can form teams of up to four, challenge a rival in head-to-head battles (1v1 and 2v2) or play against an AI opponent. A team board in the lobby lets players post which palace they want to clear and join each other without invites.

## Lobby, parkour and the lobby hub
The lobby is a city plaza with stations for every menu, a parkour tower and skyway with checkpoint rewards, and six hub stations: a Today board (featured palace, daily reward, quests), a challenge giver, the team board, a leaderboard wall, a trophy case where players can inspect each other, and a practice range that runs a free-play session with the player's own deck and no rewards.

## The Hideaway (safe room)
A large indoor lounge with a coffee-and-curry bar, a balcony over the city skyline, working couches and booths, a jukebox with selectable tracks and a bartender with dialogue. Staying inside pays a slow trickle of Spins (one every 12 minutes, up to 10 a day). The room is only loaded for players inside it, so it has little effect on lobby performance.

## Tutorial
A coach card walks a brand-new player through movement, the HUD, placing towers, upgrading, weakness, the special ability, All-Out, melee and a practice interrogation. It highlights the real UI elements it is talking about and reacts to what the player actually does.

## Data, security and analytics
Player data saves with retries and session locking. All server remotes were audited for input validation (NaN, range and ownership checks). Analytics track the onboarding funnel and run events (start, end, wave reached, quits) to find where new players drop off.

## Mobile
The UI scales to the viewport, windows shrink to fit phones, and run controls are available as touch buttons. Layout was checked at phone sizes in Studio; testing on real devices is still on the to-do list.

## Tools
- `tools/palace_designer.ps1`: measures how much of an enemy path each tower spot covers, to compare track layouts before building them.
- `tools/balance_bot.lua`: a Studio-only bot that plays palaces and records lives, income and spending so difficulty can be tuned from data. Results are in `tools/balance_bot_results.md`.
- Blender pipeline: low-poly angular models (personas, guns, melee weapons, city buildings) built in scripts and exported to Studio.
