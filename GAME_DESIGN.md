# Heli Empire - Game Design (draft v2)

## Core loop
1. Steal / collect helicopters on the map (steal-an-egg style map with levels).
2. Earn money from stolen helicopters.
3. Spend money on upgrades: **Speed**, **Health**, **Defense (flares)**.
4. Push further through the levels.

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
