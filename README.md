# The Neighborhood

A Roblox social sandbox about settling into Maple Street, making friends, collecting unusual possessions, and investigating the trouble next door.

**Development build — the complete master specification is not finished.** This repository contains the editable game, authored world, generated artwork, Studio build, and recorded test evidence. Passing Studio tests is not a production-release certification.

## Screenshots

Actual 1920 × 1079 captures from a temporary Roblox Studio play session on September 23, 2026. Scenic views use a free camera with the HUD hidden. The preview fixture supplies the car, pet and test balance without changing saved player progress. These show the current development build.

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

The last verified published version was **37**. Later environment, friends and plot-selection revisions are in source/Studio and this build; they have not been published. Public availability was previously blocked by Roblox account eligibility and must be rechecked in Creator Dashboard. The full specification, device testing, public-client travel and unfamiliar-player playtests remain incomplete.

## Ownership

Private project repository. No open-source license has been selected. Generated images, Roblox-hosted assets and dependencies remain subject to their applicable terms and permissions. See [Asset inventory](docs/ASSETS.md) before reusing under another Roblox owner.

## Optional cosmetic passes

[Maple Style Boutique](docs/MONETIZATION.md) adds six home finishes across two registered permanent passes. Passes remain off sale until this revision is published and live delivery is verified.

## Latest verification

[Full regression report](docs/QA-FULL-REGRESSION.md) records 12 passing named suites, isolated live save/rejoin, stress counts, fixes and remaining production/device checks. Studio functional passes do not mean the full master specification is complete.
