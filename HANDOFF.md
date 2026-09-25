# Codex handoff — start here

## Authoritative state

- Repository: https://github.com/Taikiy49/the-neighborhood (private), branch **main**. The original local checkout calls its branch `master`; push mapping was `master:main`.
- Experience: The Neighborhood, owner taikiyama49 (UserId 2868186764).
- Place **111572448337932**, universe **10767699101**.
- Published **v158**, confirmed by Studio at **2026-09-25T08:38:05.160Z**. See docs/RELEASE.md. No force-shutdown of running servers.
- Editable source: src/server, src/client, src/shared. Imported assets: assets/*.rbxm and assets/*.model.json. Everything needed for a Rojo build is tracked.
- Portable latest place: builds/TheNeighborhood.rbxl. Roblox place IDs are not automatically established by opening a local build; verify the destination before publishing.

## Continue on another computer

1. Authenticate GitHub as an account with access, clone this repository, and check out/pull main.
2. Read this file, README.md, DESIGN.md and docs/RELEASE.md. Original specification is docs/specification/roblox_codex.txt; newer user choices below supersede conflicting old robbery/scale requirements.
3. Open the cloud place in Roblox Studio and connect Studio MCP. Discover the current Studio ID; do not reuse a previous machine's ID.
4. To rebuild locally, use `rojo build default.project.json -o builds/TheNeighborhood.rbxl`. The tracked build can also be opened directly for inspection. `python tools/check_repository.py` checks repository documents/assets.
5. The town is constructed at server startup. A sparse Edit view does not necessarily mean the runtime town is missing. Play and inspect the generated district before changing geometry.
6. For isolated Studio tests set Workspace.NeighborhoodVisualTest=true and disable ServerScriptService.Neighborhood.VisualAcceptance (the latter is an optional fixture). Never use test profile mutations against real saved data. Stop Play, clear NeighborhoodVisualTest and VisualExploration, and restore VisualAcceptance before publishing. Its own guard prevents running in production.
7. Source edits must be synced to Edit, not just Server/Client Play copies. Publish to the existing place, verify Studio's PublishSuccessful/version log, update docs, commit and push main.

## Latest user direction

A coherent, attractive coastal town with suburban homes, downtown, beach/pier/carnival, real water, garages, usable venues and connected roads. Prefer vetted external art to crude assembled blocks. Preserve gameplay when swapping visual models; strip untrusted scripts from imports.

The core loop is now peaceful: paid work and skill activities earn money for home, yard, furniture and vehicle progression. The user no longer wants robbing people as the game's objective. Do not reintroduce theft based on the old master specification. Twelve nearby houses first, not a 100-player expansion. Keep menus dismissible, goals legible for children, and player home markers private.

Latest requested details: meaningful rooms/bedrooms instead of random walls; larger usable garages; fix bicycle exits; autonomous traffic obeying lights; NPC dog walkers. The user authorized publishing and GitHub updates and specifically requested this cross-computer handoff.

## Implemented in v158

- Config.RobberyEnabled=false; six server entry points reject theft, lock tampering, carrying/resuming stolen items and fencing. Legacy recovery/data retained.
- TaskGuide/GoalHUD/ActivitiesScreen: explain the earn→upgrade loop, expose paid jobs, add first shift to onboarding, show bicycle/home savings using catalog prices and required job counts. Existing playground gets a private destination marker. Theft actions, survey menu and paid security upgrade offer removed from primary UI.
- HomeComfort creates one enclosed rear-left bedroom in each base cottage, an operable six-stud doorway, wardrobe/bedside furnishing, and preserves the open kitchen/living route. Removes the two freestanding HallPartition parts.
- GaragesAndCove/CoastalWorld: 20×28 garage floor, 17.5-stud clear door leaf, wider driveway. Garage sign removed. Bicycle recall is on the driveway.
- VehicleService: vertical AlignPosition suspension replaces the unstable frame-delayed spring; narrower bicycle ground samples. Existing imported vehicle art retained.
- ResidentNeighbors/PetService: shared dog model factory and four dog-walking neighbors when their plots are vacant, with leashes and pedestrian crossing waits. Occupied plots remove the NPC and dog.
- StreetDressing: 40-second cycle with dedicated all-red pedestrian interval. TownLifeExpansion traffic additionally yields to players; movement step capped to avoid large frame jumps.

## Evidence and limits

- Peaceful progression: six server rejection checks; an actual three-station pizza shift paid exactly $45 and recorded progression; duplicate payout rejected. Six savings/goal cases, menu open/close and narrow HUD layout fixtures passed. Strict design audit had zero findings.
- Existing connectivity regression: 40 routes, 758 samples, ten humanoid entrance walks, 228 paving pieces; no blocked route/grass gaps; basketball and soccer scoring passed. This run preceded the garage changes and is not an exhaustive new map-art audit.
- New home/traffic test: 12 bedrooms/garages present, actual bedroom-door walk-through, four dog walkers, 400 signal-phase samples passed.
- New vehicle test: Bicycle, Compact and CoastGT drove 52–69 studs from the assigned plot without the former high bouncing (maximum observed body height 2.41). Only one plot/player was exercised; all twelve garage exits and physical-mobile controls remain follow-up coverage.
- Test scripts: tools/test-peaceful-progression.server.luau and tools/test-home-traffic.server.luau; execute as temporary server Scripts in isolated Studio Play, not by requiring service modules from a separate MCP cache.
- JSON evidence: docs/qa/peaceful-progression.json and docs/qa/home-traffic.json.
- Rojo build and repository validation passed. Two harmless existing top-level Name warnings in JSON asset models remain.
- One temporary screenshot fixture used the wrong PlayerGui name and errored; corrected camera fixture worked. Neither fixture is part of the published scripts.

## Remaining work — do not claim finished

1. Continue visual house polish and screenshot walkthroughs: current rooms are functional, but furniture/art and displayed-item placement need further review for overlaps. Validate each vehicle at all 12 plots and on a real mobile client.
2. Observe complete NPC home→park→home dog walks and traffic intersections under load; phase tests are not full multiplayer traffic certification. Dogs currently reuse the existing stylized Biscuit model, not a new external dog mesh.
3. Earlier requested external crane/building improvements, shorter overly long entrance setbacks, and meaningful bridges over water/terrain are not completed in this release. Four exploratory candidate imports were removed before publishing; they were not adopted or exported.
4. Audit remaining crime-themed historical copy/content, promotional images and old regression tests. Theft runtime actions are disabled, but old cases/recovery and historical documentation remain intentionally. Some old acceptance suites explicitly require robbery or obsolete large-house dimensions and must not be treated as current product requirements.
5. Do not claim the entire original specification or whole-map aesthetic is complete. Follow newest user priorities and verify changes in game.

No credentials, API keys or local authentication sessions are required in this repository. Authenticate separately on the new computer.
