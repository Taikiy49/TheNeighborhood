# Visual detail cleanup — September 23, 2026

This pass inspected the **local Studio development build**, corrected visible overlaps and unsupported details, and saved actual screenshots. It is **not published to the live experience**. The most recent publish attempt failed with Roblox authentication error 401; no successful publication has been verified.

The existing Higgsfield cottage-and-garden concept informed the restrained sage, linen, oak and dark hardware palette. No new generated image was substituted for game evidence. [Concept provenance](FURNISHED-COTTAGES.md).

## What changed

| Finding | Correction |
|---|---|
| Shop awnings covered the sign's upper line; stretched lettering ran across the frontage | Both shop signs now sit above and in front of their awnings with proportional text and brackets |
| Oversized community boards visually collided; supports crossed the lettering | Separate, narrower boards, shorter copy, consistent margins and posts behind the faces |
| House numbers were concealed beneath the porch roof | All eight address plaques moved onto its visible front edge |
| Ceiling mount, shade and diffuser floated apart | Joined all 40 fixture stacks to their ceilings, retaining vertical cylinders |
| Home-gallery boards floated | Added grounded posts behind the boards |
| Pavilion roof halves crossed at the ridge | Recomputed matching slopes, added a ridge cap and tie beams |
| Small cottage roof apex seams | Added eight continuous ridge caps |
| Expansion lamps and return stair treads lacked visible support | Added pendant stems and paired stair stringers without new collision obstacles |
| Large entrance doors looked like blank slabs | Added quiet panel detailing on both faces, attached directly to each moving door |
| Bottom navigation hint overlapped the interaction card | Hide the hint while a prompt is active; restore it afterward. Place the card above the bottom edge |

Authored and runtime signs use proportional pixels-per-stud canvases with margins. The AdventureService and VehicleService sign builders were included so later-created labels follow the same treatment.

## Before and after

Actual Studio play-session captures with a free camera. The avatar position differs in the community-board pair; both show the same authored board.

| General store — before | General store — after |
|---|---|
| ![Awning obscuring stretched shop text](../assets/screenshots/detail-before-shops-play.png) | ![Correctly proportioned shop sign above awning](../assets/screenshots/detail-after-shops-play.png) |

| Community boards — before | Community boards — after |
|---|---|
| ![Oversized boards and posts crossing text](../assets/screenshots/detail-before-post-play.png) | ![Clear board with supports behind lettering](../assets/screenshots/detail-after-post-play.png) |

| Pavilion — before | Pavilion — after |
|---|---|
| ![Crossed pavilion roof halves](../assets/screenshots/detail-audit-pavilion.png) | ![Aligned pavilion roof and supporting beams](../assets/screenshots/detail-after-pavilion.png) |

| Bedroom fixture — before | Bedroom fixture — after |
|---|---|
| ![Bedroom fixture before joint correction](../assets/screenshots/detail-before-bedroom-play.png) | ![Flush ceiling fixture](../assets/screenshots/detail-after-bedroom-fixture.png) |

## Final detail views

| Cottage entrance, number and home-gallery sign | Loft stair supports |
|---|---|
| ![Finished cottage entrance](../assets/screenshots/detail-after-porch-final.png) | ![Return stair stringers](../assets/screenshots/detail-after-loft.png) |

| Willow Lake lettering | Completed cafe inspection |
|---|---|
| ![Readable Willow Lake sign](../assets/screenshots/detail-after-lake.png) | ![Completed cafe stage](../assets/screenshots/detail-audit-completed-cafe.png) |

The cafe completion and unlocked loft were staged **only inside disposable Play sessions** to inspect their geometry. These screenshots are not evidence of live purchases or saved progression. Gameplay progression was exercised separately by the regression suites below.

[Orchard inspection](../assets/screenshots/detail-audit-orchard.png) · [Previous floating tour board](../assets/screenshots/detail-before-tour-play.png) · [Previous unsupported loft treads](../assets/screenshots/detail-audit-loft.png) · [Previous lake lettering](../assets/screenshots/detail-before-lake-sign.png) · [Earlier hidden house plaque in Edit view](../assets/screenshots/detail-before-house-sign.png)

## All eight house-front inspections

These were captured after plaque corrections and **before** the final ridge-cap and door-panel pass. The final cottage image above shows the latter changes; the same authoring routine applies them to all eight homes.

| House 01 | House 02 |
|---|---|
| ![House 01](../assets/screenshots/detail-audit-House01.png) | ![House 02](../assets/screenshots/detail-audit-House02.png) |

| House 03 | House 04 |
|---|---|
| ![House 03](../assets/screenshots/detail-audit-House03.png) | ![House 04](../assets/screenshots/detail-audit-House04.png) |

| House 05 | House 06 |
|---|---|
| ![House 05](../assets/screenshots/detail-audit-House05.png) | ![House 06](../assets/screenshots/detail-audit-House06.png) |

| House 07 | House 08 |
|---|---|
| ![House 07](../assets/screenshots/detail-audit-House07.png) | ![House 08](../assets/screenshots/detail-audit-House08.png) |

## Recorded verification

[Raw Studio results](qa/visual-detail-regression.json) · [Source parity](qa/detail-source-parity.json) · [UI static audit](qa/detail-ui-static.json)

- **DetailAcceptance:** passed; 40 joined ceiling fixtures, 46 startup text signs with proportional canvases, eight visible porch addresses. Repeated after the final door and ridge details.
- **Sightline audit:** no blockers found in 320 sampled rays across 64 front/back surfaces: 48 sign faces plus 16 decorative door faces. This is an oriented-box screen from a fixed approach distance, not proof of visibility from every camera angle.
- **BuildingAcceptance:** passed with two clients, 22 physical walking legs, garage driving, 4,200 malformed-request checks and 50 pack/reload cycles.
- **LifeWalkAcceptance:** passed with two clients and 34 physical walking legs covering gardens, a guest tour, the cafe and park clues. Five setup teleports were recorded; the walking legs themselves used character movement.
- **ArtAcceptance:** passed 23 navigation routes, including all eight house entrances and deliveries, both stores and five clue locations.
- **UIAcceptance:** passed 162 checks across two rendered clients. The real hint/card pair was checked in 854 × 393, 390 × 844 and 640 × 360 layout fixtures. This does not certify physical phone or controller input.
- **Source parity:** all 92 local source files match Studio after line-ending/trailing-whitespace normalization.
- **Repository/build:** final 6,312-instance authored scene exported; Rojo build and repository JSON/link checks passed.

Building, life and UI regressions preceded the final decorative ridge caps/door surfaces; those additions do not change collision or gameplay code. Final detail geometry and sightlines were checked afterward. Frame timing is recorded for context, not performance certification. Live saves/rejoins, authentication, publication and every possible player-created arrangement were outside this visual pass.

## Reproducing the cleanup

1. Sync the source and load the authored scene from this repository.
2. If rebuilding earlier art systems, run their tools first, then run **tools/detail-cleanup.luau** in Edit mode. It replaces its own DetailCorrections folder and door surfaces.
3. Export with tools/export-world.luau, preserve instance properties, and rebuild with Rojo.
4. Run DetailAcceptance through StudioTestService. The maintained tools/run-studio-suites.luau list includes it.
5. In Play, run tools/audit-sign-sightlines.luau and inspect actual screenshots before treating any bounding-box finding as a defect.

Canonical owners remain Theme → UI → App/InteractionController/Screens for the HUD, LifeFactory/AdventureService/VehicleService for generated signs, and BuildingFactory for expansion structures.
