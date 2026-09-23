# Home expansion QA — September 23, 2026

## Delivery and account status

Four permanent home upgrades, four crafting recipes, 15 furnishing positions, three saved layouts and 14 collectible display spots are implemented in source and the local Studio build. Construction uses earned game cash. There is no infinite plot growth or unrestricted part editor. See [player guide](HOME-EXPANSIONS.md).

Creator Dashboard showed **Age check: Done** and **Publishing status: Ages 16+ and trusted friends**. The experience remained **Private** and **Unrated**, with the maturity/compliance questionnaire outstanding. Studio subsequently reported Access Denied (RCC-273) and 401 User is not authenticated. No new live publication is claimed.

## Executed expansion checks

- BuildingAcceptance passed with two actual Studio clients.
- BuildingCapacity passed with eight actual Studio clients and all eight homes fully expanded, each with 15 furnishings and 14 display spots.
- Each run rejected 4,200 malformed actions, checked prerequisites and exact prices, duplicate purchase rejection, owner isolation, crafting capacity, owned-copy limits, invalid placement/rotation and atomic layout validation.
- Each run completed 22 real Humanoid walking legs through the cottage connection, upstairs and downstairs, garage and workshop. Entry points between separate route groups were staged; movement within each route was physical.
- Fifty pack/load cycles retained exact furniture instance counts. Saved layouts were independent copies. Loading preserved collectible identity. Release restored the base cottage; rebuilding retained furniture.
- The largest collectible bounds fit all eight added display positions. Car recall used the garage. Theft could not complete an escape while the carrier remained inside the workshop.
- UIAcceptance passed **112 checks**: 24 main views and four detail states, two panel widths, two clients. Checks included wrapping, scrolling, action sizes, request correlation and failed-request recovery. Panel-width testing is not real touch-device certification.
- StorageStress passed **20 seeds, 5,000 settlement/spending cycles and 20,800 injected storage requests**, including expansion profile save/reload. This uses an injected store, not Roblox DataStore.

## Regression and evidence

[Raw attempts](qa/building-regression.json) retain failures, null results, subsequent passes and explicit online skips. A null result is not a pass. [UI static audit](qa/building-ui-audit.json) records the source audit.

The foundation regression initially failed its heavy-item walking escape. Several abandoned Studio test processes were found and closed. The rerun passed without relaxing its gameplay assertions; cleanup is a plausible contributor, not a proven root cause. Adventure, friends and exploration suites initially stopped at real DataStore calls in the unpublished local place. Their online helpers now explicitly report Skipped=true and Passed=false for that subsection. Local gameplay success must not be interpreted as online persistence success.

Other passing checks included 368 production remote requests across two clients and four character reloads; 100 complete collectible lifecycle cycles and 600 invalid transitions; actual disconnect during a delayed save; 23 navigation routes; 600 cosmetic equips, 800 malformed cosmetic requests and 24,000 texture checks. The older navigation suite checks base homes; expansion traversal is covered by the building suites.

Actual mouse input completed Phone → Plan your home → Review $900 → Build $900. The server confirmed the garden-room unlock and an exact balance change from $20,000 to $19,100 in a memory-only preview. A single-client staged expansion preview measured approximately 18 ms p95 heartbeat after abandoned sessions were cleared; this is a different load from the eight-client tests and is not production certification.

Actual mouse input also saved layout 2 and loaded layout 1; server checks confirmed the saved placement and restored furniture. Three unedited Studio captures appear in the README. All 78 source scripts matched the tested local Studio edit model. The Rojo build and repository link/JSON checks passed.

The separate CapacityAcceptance run (eight cars, eight pets and rain) did not complete successfully. Studio’s named test call returned null; the existing eight-client session was then checked with the original capacity assertions through an explicit Studio-only harness. It failed on Roblox CoreGui PlayerPermissionsModule / CreatorType errors. This is an unresolved local-session failure, not a capacity pass. Ended test processes were cleaned up.

## Problems fixed during this change

- Unpublished local play previously requested a DataStore before selecting memory-only mode. Local Studio preview now chooses isolation first; published production storage remains unchanged.
- Expansion UI string concatenation parsed incorrectly and was corrected.
- The local build defaulted to legacy chat and produced a Roblox CoreScript registration error. The project explicitly selects TextChatService; the rebuilt UI suite reported no application errors.
- Stair landing clearance and large collectible alcoves were refined during traversal/bounds tests. The waypoint arrival tolerance was adjusted from 0.9 to 1.2 studs after a Humanoid stopped 0.9045 studs from its target; vertical loft arrival assertions remain.
- Visual review exposed a narrow gap between the garden room and workshop. A rear doorway and continuous threshold now connect them; garden-door collision follows the existing house open/lock state. Tests walk through the whole connection rather than starting at the workshop entrance.
- Robbery escape now includes purchased room bounds, preventing a workshop carrier from escaping merely by being far from the original front door.
- The public backyard clue moved outside the expansion footprint. Purchased cottage finishes also apply to new rooms.

## Limits and pending checks

The fully expanded local runs measured p95 server heartbeat of approximately **320 ms with two clients** and **538 ms with eight clients** while other test processes were present. A later two-client run after the doorway revision measured approximately **442 ms**, and the revised eight-client run measured approximately **767 ms**. These are poor timings and are not a performance pass. Removing abandoned sessions does not establish a production or device performance budget.

The real save/rejoin fixture has been extended to include all rooms, a crafted loft bench, a saved layout and a collectible in an added display slot. **That new fixture has not run against Roblox DataStore** because live Studio authentication is blocked. Earlier save evidence does not validate the new fields. Published-client teleports, cross-server handoff, real mobile/controller input, performance and unfamiliar-player usability remain open. The master specification remains incomplete.

Final local result: **14 suites passed their gameplay assertions; CapacityAcceptance failed with Roblox CoreGui errors**. The foundation suite passed again after the final rear-door integration. Online storage, published-client travel and performance certification remain excluded.
