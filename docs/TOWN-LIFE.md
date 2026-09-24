# Gardens, transport and progression

September 24, 2026. This extends the coastal districts; it does not replace the airport, carnival, school, jobs, house upgrades or saved neighborhoods.

## Personal gardens

All 12 homes have a fenced side yard, a clear path from the front, six decorating spaces, and rear space reserved for the existing gardening/workshop activities. Blueprints are reusable. Placement, quarter-turn rotation and ownership persist in `Yard`; packing retains the blueprint. The server restricts edits to the owner's garden and clears the display when that owner leaves.

| Blueprint | Cash | Resident level |
|---|---:|---:|
| Flowers | 40 | 1 |
| Bench | 90 | 1 |
| Picnic table | 300 | 3 |
| Ball rack | 400 | 3 |
| Trampoline | 900 | 5 |
| Lantern | 1,800 | 8 |
| Pergola | 5,000 | 12 |
| Fountain | 15,000 | 20 |
| Gold sculpture | 40,000 | 35 |

Seats are usable; the toy rack lends the existing ball, and the trampoline has a rate-limited bounce. Decorating uses named spaces and buttons instead of precision dragging.

## Garage economy

New players start with $250 and no vehicle. Existing balances and Compact ownership are preserved. Buy and sell at Coast Motors, with exact-price confirmation. Recall owned vehicles into the home garage; occupied/blocked garages reject replacement. Selling returns half the original catalog price and removes ownership. Duplicate/replayed sales cannot pay twice. Paint changes are free.

| Vehicle | Cash | Level | Speed (studs/sec) |
|---|---:|---:|---:|
| Bicycle | 350 | 1 | 22 |
| Compact | 2,400 | 3 | 28 |
| Trail wagon | 9,500 | 8 | 30 |
| Sunset roadster | 28,000 | 16 | 36 |
| Coast Grand Tourer | 125,000 | 30 | 40 |

These are arcade vehicles with shared driving physics and different geometry, colors and speeds. They are not licensed real-world cars. The current wagon has one driver seat; it is not a multiplayer passenger vehicle.

Resident level is `1 + floor(sqrt(XP/50))`. Level 5 needs 800 XP; 10 needs 4,050; 20 needs 18,050; 30 needs 42,050; 50 needs 120,050. Titles appear above players: New Resident, Good Neighbor, Town Regular, Master Builder, Coast Legend and Coast Icon. Repeated work earns 15 XP with a shared 20-second gate; one-time actions cannot be farmed repeatedly for XP. Achievements and onboarding grant additional XP. Jobs remain skill/activity-based; levels are not sold.

Delivery pays $90 with a 20-second minimum and 30-second cooldown. Factory work takes 20 seconds for $20. Carnival wins have a shared 20-second cash reward gate, with practice still available. Housing tiers cost $2,500 / $9,500 / $45,000 and require 8 / 35 / 180 completed work actions. Existing purchased tiers remain owned. These are initial balance settings, not evidence of months of retention; real player feedback must guide adjustment.

## Town activity

Four furnished snack venues: Palm Diner, Noodle Kitchen, Corner Convenience and Boardwalk Bakery. Counters use the established free-snack interaction. Fourteen taller layered trees and 24 extra cosmetic downtown pedestrians add height and movement.

Six low-speed traffic cars follow a road loop, stop for physical obstacles and resume when clear. Traffic collides with vehicles and scenery, but not player characters. Pedestrians remain noncolliding. Renovation buildings now retain their final coastal positions when rebuilt after joins/contributions, preventing the old greenhouse from blocking the road.

The elevated coastal tram has Sunset, Pier and Airport stations, four seats, free rides, an eight-second boarding window and automatic next-stop exits. Jumping off returns to the last station's safe street exit. Platform lifts are available. The rail is a single shuttle line, not a full train network.

Friend circles, visits and shared activities remain the social focus. No dating matchmaking or new Robux products were added.

## Menus

Every shared menu has a fixed 48px Close control; Escape and controller B close it. Wide screens dock the menu on the right. Smaller screens keep a bounded, scrollable panel. The NEXT UP card has Hide, and Goals restores it. Late state refreshes cannot reopen a closed panel. The guided camera tour is optional from Help and has Close tour; joining no longer automatically takes camera/control ownership.

Canonical owners: Theme → UI → Screens; GoalHUD alone owns the task card's visibility. YardScreen and VehicleScreen reuse shared rows/progress meters. Server services own money, unlocks and persistence. No new design-token namespace.

## Verification scope

See `town-life-results.json`, `town-repository-results.json` and the release test report. Repository storage simulations are injected-storage tests, not proof of a live DataStore rejoin. Native Studio checks cover menu dismissal, gameplay and visual layout. Twelve simultaneous clients, low-end physical phones and long-term retention require further validation; do not infer them from a single-client playtest.
