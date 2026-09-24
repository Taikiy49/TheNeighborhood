# The Neighborhood

A Roblox social sandbox about settling into Maple Street, making friends, collecting unusual possessions, and investigating the trouble next door.

**Development build — the complete master specification is not finished.** This repository contains the editable game, authored world, generated artwork, Studio build, and recorded test evidence. Passing Studio tests is not a production-release certification.

## A roomier neighborhood

The map is now **720 × 700 studs**. Cottages and their expansions are twice as wide and deep, giving homes **four times the floor area** while keeping furniture and characters normal-sized. Streets, gardens, plot choices and activity destinations follow the new layout.

[Layout changes and compatibility](docs/SPACIOUS-NEIGHBORHOOD.md) · [Local regression results](docs/qa/spacious-regression.json)

### Updated spacious layout

Actual Studio edit-viewport captures of the enlarged authored map and cottage interior. Runtime activities and player furniture are omitted in these architectural views.

| Larger neighborhood | Wider cottage interior |
|---|---|
| ![Expanded 720 by 700 stud neighborhood](assets/screenshots/spacious-overview.png) | ![Wide cottage floor and hallway](assets/screenshots/spacious-interior.png) |

## Screenshots

Actual 1920 × 1079 captures from a temporary Roblox Studio play session on September 23, 2026. Scenic views use a free camera with the HUD hidden. The preview fixture supplies the car, pet and test balance without changing saved player progress. The gallery below records the earlier compact layout; updated spacious-layout captures appear separately.

**A walk down Maple Street**

![Tree-lined Maple Street with cottages and the community park](assets/screenshots/street.jpg)

| The whole neighborhood | A home on Maple Street |
|---|---|
| ![Aerial view of the eight homes, park and shops](assets/screenshots/overview.jpg) | ![101 Maple Street with a mint car in the driveway](assets/screenshots/cottage.jpg) |

| Gardens and a companion | The community park |
|---|---|
| ![Porch garden, front path and Biscuit the dog](assets/screenshots/garden.jpg) | ![Park fountain, benches, trees and a neighborhood character](assets/screenshots/park.jpg) |

| Shopping on Maple Street | Inside the general store |
|---|---|
| ![General store and pawn shop storefronts](assets/screenshots/shops.jpg) | ![General store counter and collectible displays](assets/screenshots/general-store.jpg) |

| Home interior and display spaces | The kitchen |
|---|---|
| ![Wood floors and display spaces inside a cottage](assets/screenshots/living-room.jpg) | ![Cottage kitchen with cabinets, cooktop and sink](assets/screenshots/kitchen.jpg) |

| The bedroom | Your phone |
|---|---|
| ![Cottage bedroom with bed, quilt and botanical artwork](assets/screenshots/bedroom.jpg) | ![In-game phone with friends, progress and home controls](assets/screenshots/phone.jpg) |

**Maple Style Boutique — optional home finishes**

![Maple Style Boutique showing owned cosmetic finishes during the playtest](assets/screenshots/boutique.jpg)

## Neighborhood Life

Actual Studio play-session previews with temporary local progression and daylight staging; these do not change saved accounts.

| Your garden and business counter | The restored Corner Cafe |
|---|---|
| ![Four flowering garden beds and the nursery counter](assets/screenshots/life-garden.jpg) | ![Completed Corner Cafe pavilion facing the street](assets/screenshots/life-cafe.jpg) |

![Neighborhood Life phone activities](assets/screenshots/life-phone.jpg)


Grow a four-bed garden, serve NPC business orders, restore three community places, solve branching mysteries, host home tours, earn maker blueprints and join seasonal lantern festivals. Open **Phone → Neighborhood Life**. Personal progress uses the existing save system; live save/rejoin verification for this update is still pending.

See the [feature guide](docs/NEIGHBORHOOD-LIFE.md) for exact gameplay, rewards and limits, and the [verification report](docs/QA-NEIGHBORHOOD-LIFE.md) for test methods and release limits.

## Maple Adventures

Follow six neighborhood rumors, save their endings in a story album, replay walking routes for personal bests, and earn three display trophies. Deliveries, discoveries, events and completed trails also build shared flower beds, a little library and lanterns in Maple Green. Chapters and personal rewards stay saved; the shared park build lasts for the current server.

[How to play Maple Adventures](docs/MAPLE-ADVENTURES.md) · [Expansion verification](docs/QA-ADVENTURES.md)

| Saved story album | Shared park projects |
|---|---|
| ![Story chapter restored after a real Studio restart](assets/screenshots/adventures-album.jpg) | ![Completed shared park projects in a controlled Studio preview](assets/screenshots/adventures-park.jpg) |

These are actual Studio captures: the album uses an isolated restart fixture; park completion is staged in a memory-only preview.

## Room to grow

Build a glazed garden room, an upstairs loft with a real staircase, a carriage garage and a backyard workshop. Craft four kinds of furniture, arrange 15 furnishing spaces and save three layouts. Expanded homes have 14 collectible display spots. Upgrades use earned cash. This is bounded home expansion, not infinite land or unrestricted building.

[Home expansion guide](docs/HOME-EXPANSIONS.md) · [Expansion QA and limitations](docs/QA-HOME-EXPANSIONS.md)

![Expanded cottage with framed garden room, loft, garage and workshop](assets/screenshots/home-expansion.jpg)

| Upstairs loft | Three saved layouts |
|---|---|
| ![Crafted furnishings and return staircase in the upstairs loft](assets/screenshots/home-loft.jpg) | ![Saved furniture layouts in the actual game interface](assets/screenshots/home-layouts.jpg) |

Actual Studio captures of the expansion build. Rooms, furniture and cash were staged in a memory-only preview; scenic views use a free camera. These images do not claim online publication.

## Systems in this build

- Eight furnished homes, two shops, gardens, a community park, deliveries and a five-clue collectible trail.
- Server-authoritative money, purchases, item ownership, display placement, storage and pawn sales.
- Physical theft and carrying, locks, protection rules, evidence, investigations and recovery of original possessions.
- House customization, a purchasable car, a companion dog, weather, community activities and progression.
- Persistent player profiles with session leases, retries, migration and separate development/production storage.
- Friend parties, invitations, ready checks and saved invite-only neighborhoods. Nearby plots are picked automatically; players can choose an unclaimed address before moving in. Saved addresses stay reserved while members are offline.
- A phone interface for inventory, activities, settings, friends and neighborhood invitations.

Friend-travel orchestration is implemented and tested with an injected transport adapter. **Published-client teleports, native friend/privacy behavior and cross-server profile handoff remain to be verified.**

## Open or build

Download [builds/TheNeighborhood.rbxl](builds/TheNeighborhood.rbxl), then open it in Roblox Studio. This is an openable snapshot; source and the Rojo project are the maintainable version.

Rebuild with [Rojo 7.7.0](https://github.com/rojo-rbx/rojo/releases/tag/v7.7.0):

```sh
rojo build default.project.json --output builds/TheNeighborhood.rbxl
```

Read [Build and Studio setup](docs/BUILDING.md) before live sync or persistence testing. No Roblox credentials or reserved access codes are required to build.

## Documentation

| Guide | Contents |
|---|---|
| [Documentation index](docs/INDEX.md) | Current guides and historical evidence |
| [Build and Studio setup](docs/BUILDING.md) | Dependencies, Rojo, storage and fixtures |
| [Architecture](docs/ARCHITECTURE.md) | Services, authority, saves and travel |
| [Testing](docs/TESTING.md) | Repeatable tests and latest results |
| [Release status](docs/RELEASE.md) | Publication status and release gates |
| [Friends and neighborhoods](docs/FRIENDS-NEIGHBORHOODS.md) | Parties, invitations, plot choice and recovery |
| [Art redesign](docs/GARDEN-REDESIGN.md) | Environment changes and art QA |
| [Asset inventory](docs/ASSETS.md) | Provenance and portability |
| [Specification coverage](docs/SPEC-COVERAGE.md) | All 239 numbered sections, including open work |
| [Original specification](docs/specification/roblox_codex.txt) | Preserved user-supplied master brief |
| [Roadmap](docs/ROADMAP.md) | Milestones and outstanding work |

## Layout

```text
src/shared/       Configuration, definitions, theme and plot geometry
src/server/       Gameplay services, persistence and gated tests
src/client/       HUD, phone screens, input, feedback and weather
assets/           Editable world snapshot and art
marketing/        Experience icon and covers
builds/           Openable Roblox Studio snapshot
tools/            Authoring, export, packaging and repository checks
docs/             Guides, requirements coverage and QA evidence
default.project.json   Rojo source-to-service mapping
```

## Verification and release boundary

Recorded checks include three-client friends/plot tests, 56 nearest-plot choices, 23 navigation routes, eight-client functional capacity, gameplay regression, storage fault tests and real DataStore fixture save/reload tests. See [Testing](docs/TESTING.md) for limitations.

GitHub Actions validates repository files and builds a downloadable `.rbxl` with a pinned Rojo release. It **does not run Studio gameplay tests or publish the game**.

Target place: `111572448337932` · Universe: `10767699101`.

The last verified published version was **37**. Later environment, friends and plot-selection revisions are in source/Studio and this build; they have not been published. The September 23 Creator Dashboard check shows the account age check complete and publishing eligibility for ages 16+ and trusted friends. The experience is still Private and Unrated, with its maturity/compliance questionnaire outstanding. Studio subsequently lost authentication; the home expansion is in the local build, not verified in the live place. The full specification, device testing, public-client travel and unfamiliar-player playtests remain incomplete.

## Ownership

Private project repository. No open-source license has been selected. Generated images, Roblox-hosted assets and dependencies remain subject to their applicable terms and permissions. See [Asset inventory](docs/ASSETS.md) before reusing under another Roblox owner.

## Optional cosmetic passes

[Maple Style Boutique](docs/MONETIZATION.md) adds six home finishes across two registered permanent passes. Passes remain off sale until this revision is published and live delivery is verified.

## Latest verification

[Latest regression retest](docs/QA-EXPANSION-RETEST.md) records the mobile notification fix, expanded remote/garage tests and remaining platform/performance failures. [Home expansion QA](docs/QA-HOME-EXPANSIONS.md) records the preceding building checks. [Maple Adventures QA](docs/QA-ADVENTURES.md) records the preceding 13-suite regression and saved-story restart checks.

The preceding [full regression report](docs/QA-FULL-REGRESSION.md) records 12 passing named suites, isolated live save/rejoin, stress counts, fixes and remaining production/device checks. Studio functional passes do not mean the full master specification is complete.
