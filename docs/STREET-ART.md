# Imported streetscape

The street pass adds 29 suspended four-way signals at actual road-graph junctions, with 58 poles outside the asphalt. Opposing directions use a 28-second cycle: ten seconds green, three amber, one all-red, then the other axis. NPC road traffic consults the same phase controller and waits on approach; player drivers remain free to drive normally.

401 imported trees/palms replace existing primitive crowns and add street rows, including 22–31-stud palms downtown and along the coast and broadleaf trees in the residential districts. This count includes replacements, not 401 additional trees. Placement of additional trees rejects road margins and expanded building footprints. Eight picnic-table/planter pockets give the park and downtown pedestrian areas gathering places. Existing floor plans, house ownership and roads remain intact.

## Sources

Free Creator Store listings inspected September 24, 2026:

| Asset | Listing creator | Use |
|---|---|---|
| [Hanging Traffic Light — 595305565](https://create.roblox.com/store/asset/595305565) | pthompso201 | Signal head and support geometry; locally authored suspension cables and signal controller |
| [Tree — 580221169](https://create.roblox.com/store/asset/580221169) | SheriffTaco | Broadleaf street trees |
| [Palm tree mesh — 1274475057](https://create.roblox.com/store/asset/1274475057) | NothingFamous | Downtown/coastal palms |
| [Park Bench City Street Furniture Asset Pack RP — 88053823492789](https://create.roblox.com/store/asset/88053823492789) | NoraChaosBeast2010 | Picnic-table geometry |

All imported code, remotes, constraints, sounds and bundled lights were removed. These assets use this project's controllers and are stored in CuratedArt.model.json. No paid assets/plugins were purchased. A second signal and several tree candidates were rejected: the first tree looked too angular, another had forest foliage unsuited to the boulevard. Marketplace names alone were not treated as reliable quality indicators. The initial signal's twelve lights per instance were removed after visual inspection exposed excessive glow.

## Verification

- 280 phase samples: no opposing green directions.
- 58 pole positions: none inside an asphalt road footprint.
- Red/green approach decisions tested against the controller.
- Actual NPC traffic sample: zero movement during one second of red, then 36.27 studs during two seconds of green.
- Final isolated Studio startup: normal Ready output, no runtime errors or asset-permission errors.
- No imported executable code or bundled Light objects in the generated streetscape.

This is Studio verification, not a physical low-end phone or full-server performance benchmark. Imported foliage increases render cost; further device testing remains necessary. Some existing bridges, interiors, vehicles and props still use the prior geometry. This pass does not claim all game assets were replaced.

![Hanging signals and imported palms downtown](../assets/screenshots/street-hanging-signals.png)
![Imported trees along the residential streets](../assets/screenshots/street-residential-trees.png)
