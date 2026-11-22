# Heli Empire - Game Design (draft v3)

## Core loop
1. Steal / collect helicopters on the map (steal-an-egg style map with levels).
2. Earn money from stolen helicopters.
3. Spend money on upgrades: **Speed**, **Health**, **Defense (flares)**.
4. Push further through the levels.

## Stealing costs coins (not Robux)
- Helicopters are stolen **from the map**, and each steal costs **coins** (in-game money).
- Why: stops a cheater teleporting to the end, grabbing a helicopter for free, and
  teleporting back to spawn.
- Rule: the **server** checks and deducts the coins, then grants the helicopter.
  The client can never grant itself one.
- **Price = exactly what the helicopter earns in 12 seconds** (Income x 12).
- 25 real helicopters (Id, income/s, price = income x 12):
  1. Robinson R22 - 1/s, 12 coins
  2. Robinson R44 - 2/s, 24 coins
  3. Bell 206 JetRanger - 3/s, 36 coins
  4. Airbus H125 - 5/s, 60 coins
  5. MD Helicopters MD 500 - 8/s, 96 coins
  6. Bell 407 - 12/s, 144 coins
  7. Airbus H135 - 18/s, 216 coins
  8. Bell UH-1 Huey - 27/s, 324 coins
  9. Airbus H145 - 40/s, 480 coins
  10. Aerospatiale SA 330 Puma - 60/s, 720 coins
  11. Leonardo AW139 - 90/s, 1080 coins
  12. Sikorsky S-76 - 135/s, 1620 coins
  13. Sikorsky UH-60 Black Hawk - 200/s, 2400 coins
  14. Bell AH-1 Cobra - 300/s, 3600 coins
  15. Eurocopter Tiger - 450/s, 5400 coins
  16. Kamov Ka-52 Alligator - 675/s, 8100 coins
  17. Boeing AH-64 Apache - 1000/s, 12000 coins
  18. Mil Mi-24 Hind - 1500/s, 18000 coins
  19. Mil Mi-8 Hip - 2250/s, 27000 coins
  20. Leonardo AW101 Merlin - 3400/s, 40800 coins
  21. Boeing CH-47 Chinook - 5000/s, 60000 coins
  22. Sikorsky CH-53K King Stallion - 7500/s, 90000 coins
  23. Sikorsky S-64 Skycrane - 11000/s, 132000 coins
  24. Mil Mi-26 Halo - 17000/s, 204000 coins
  25. Mil Mi-12 Homer - 25000/s, 300000 coins
- Models: low-poly (900-1,650 triangles each), built in Blender by a generator script, exported as GLB.
- Code lives in `scripts/` (copies of what is in the Studio place).

## Enemy
- Enemy helicopters chase and attack players to stop them stealing helicopters.
- The run to the end must take more than a minute.
- **Higher levels: faster enemy helicopters, faster missiles, and missiles that do more damage.**

## Upgrades
| Upgrade | Effect |
|---|---|
| Speed | Faster player movement |
| Health | More hits before reset |
| Defense | Flares that counter enemy missiles |

### Flare colours
- Every defense upgrade level unlocks a **new flare colour**.
- There is a **max level** (proposed: 10 levels, 10 colours - adjust later).
- At max level the flare stays on the final colour. It never wraps back to the
  starter colour, so players can't "reset" their colour by upgrading past the cap.

### Max level bar
- Each upgrade shows a progress bar toward max level.
- Reaching max shows a clear **MAX** state, so players can show they've maxed out
  and compete to be the best.

## Build order
1. Helicopter stealing + money
2. Upgrade shop (Speed / Health / Defense-flares, with max level + bar)
3. Enemy helicopters and missiles (scaling by level)
4. Level progression + UI (Figma)

## Spawning & areas (v4)
- 5 rarity tiers, 5 helicopters each: Common, Uncommon, Rare, Epic, Mythic (list order = income order).
- 10 pads in Workspace.HeliSpawns, each with a `Rarity` attribute. Columns left→right (x=-480..-120): Mythic, Epic, Rare, Uncommon, Common (pads 1/6 Mythic, 5/10 Common).
- `HeliSpawner` spawns a random model of the pad's rarity from ServerStorage.HeliModels; 120 s lifetime, 5 s respawn.
- `AreaDisplay` (client) shows "<Rarity> Area" on Hud.Area using Workspace.AreaZones.

## Turrets & hover (v5)
- Workspace.Turrets: 10 concrete box turrets with 4 holes each, `Level` 1-5 by area (Common=1 ... Mythic=5), 2 per area (north/south edge).
- Level scales range, fire rate, homing missile speed/turn and damage (8 → 36).
- Spawned helicopters bob up and down client-side (HeliHover).
