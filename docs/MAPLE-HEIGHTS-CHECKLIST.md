# Maple Heights redesign

Scope: attached city redesign plus the request for a smaller, defined central neighborhood park. Existing twelve homes, saved progress and working gameplay must survive.

Baseline: commit `3e06361`, published v77. Studio connects to place `111572448337932`; baseline play reports ready with persistent profiles and no console errors.

| Requirement | Status | Evidence / remaining work |
|---|---|---|
| Inspect original specification, attachment, source and live scene | Tested | Read full specification; baseline Studio play and overhead inspection |
| Compact central park and public plaza | Implemented, inspected | Bounded green with low walls/hedges, existing activities, shop and hotel frontages |
| Twelve furnished homes, ownership, spawning, vacancy routines | Tested | Eight real clients; all twelve slots exercised; owner labels, interior arrival and four vacancy NPCs |
| Cafe, general store, pawnshop, repair shop, deli and laundromat | Implemented, tested | Existing stores retained; furnished pizza and laundry with ordered paid shifts; entrances walked |
| Old Town brownstones, courtyard, fire escape and playable roof | Tested | Two furnished floors each; real humanoid climbed and crossed roofs |
| Uptown library, apartment and hotel with usable floors | Tested | Library retained; three apartment lounge floors and hotel reception/two rooms furnished; lifts exercised |
| Water, ferry, fishing, tackle and warehouse deliveries | Implemented, tested | Existing water/ferry/fishing retained; swimming tested; warehouse physical parcel start/cancel tested |
| Skyline, bridge, transit details, coherent street edges | Implemented, inspected | Skyline replaces mountains; connected outer roads and turning courts; cove bridge physically traversed |
| Clear destinations and first-session guidance | Implemented, inspected | Park boards, destination signs, arrival text and occluded home-marker correction |
| Actual server capacity verified | Tested | Creator Dashboard saved and reloaded Maximum Visitor Count = 12 |
| Joining, saving/rejoining, respawn, ownership and purchases | Tested | Real isolated DataStore restart/rejoin; two-client foundation suite; 830 remote requests and four character reloads passed |
| Robbery protections, vehicles, swimming, jobs and cooldowns | Tested | Two-client robbery/evidence/recovery suite, driving, swimming and four job suites passed |
| Actual multiplayer clients | Tested | Eight simultaneous clients passed renewal suite; twelve simultaneous clients remain untested |
| District pedestrian and overhead visual QA | Tested | Eleven actual Studio screenshots reviewed; 38 new entrance/sidewalk regions clear in final obstruction scan; final interior support/ceiling-clearance fixes |
| Recoverable build, README, documentation and GitHub | Delivered | Rojo build, scene export, 11 screenshots, README and QA pushed to GitHub main in de6a44a |
| Publish and verify successful version | Verified | Studio PublishSuccessful at 2026-09-24 12:02:58 UTC; publish notes linked to v85 |

Statuses distinguish implementation from observed testing. No completion is inferred from source code alone.
