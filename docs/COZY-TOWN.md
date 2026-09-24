# Cozy town redesign

## Direction and references

The town returns to a compact scale: 42 by 36.4 stud cottage foundations, 1.4 times the original horizontal dimensions, rather than the previous 3 times. The main ground is 672 by 560 studs. Avatar-scale doors, furniture and a broad central aisle preserve comfortable movement. Saved plot and furniture identifiers remain stable.

Reference research: [Brookhaven's official site](https://www.brookhavenrp.com/) highlights roleplay destinations, vehicles, community meeting points and discovery. [Adopt Me's village update](https://www.playadopt.me/news/welcome-to-mistletroll-village) integrates activities with the river and town landscape. These inform the design principles; no game assets or exact maps were copied. [Roblox thumbnail guidance](https://create.roblox.com/docs/production/publishing/thumbnails) calls for accurate representations of gameplay.

## Implemented

- Compact furnished cottages, one front door each, wall-side display locations and garden benches.
- Eight conversational neighbors near the houses, with gardening, lake, market and picnic guidance.
- Central driving loop with trimmed asphalt ends, pedestrian crossings and synchronized green/amber/red traffic lights. Signals are scenery for roleplay, without driving penalties.
- A clock landmark driven by the game clock, covered picnic seating, clearer noticeboard placement, corrected external cottage roof trim and softened surrounding cliffs.
- Recreation courts retain 100 named stations using ten reusable mechanics. Broad repeated paving has been removed. District signs face their approach paths. This is not 100 distinct gameplay systems or infinite content.
- A free, single-passenger 35-second Willow Launch cruise, with occupancy handling, early exit and cleanup.
- Tutorial streaming guard prevents controls being disabled while required house parts are unavailable.
- New original illustrated cover, saved as the experience icon through Creator Dashboard, at `assets/neighborhood-cover-cozy.png`. This is promotional illustration, not a gameplay screenshot.

## Verification and boundaries

Studio session-only test: all eight resized entrances were walked through by a test avatar. Full ferry boarding, movement, return and passenger release passed. Traffic phases were checked. The compact car recalled successfully into the driveway. The first station activation sweep passed 99/100 and found an orchard bench obstructing Activity091; its location was corrected and the focused retest passed. All 100 station activations therefore have passing evidence across the initial sweep and corrected retest. Tutorial missing-part safety, replay startup and camera restoration also passed; the final runtime log contained no script errors. Activation checks do not certify course completion, all multiplayer cases, live rejoin persistence or every previously implemented system.

The generated Rojo build applies CozyLayout at runtime to the stored scale-3 base asset. Studio's edit scene already has the same migration applied. Do not apply the horizontal migration twice; the CozyLayout marker protects against this.

## Release

Publication remains blocked after restarting Studio on September 23, 2026. Publish to Roblox As returns Fetch failed; fresh logs show 401 Unauthorized for the experience search and creator groups endpoints. A restart alone did not refresh Studio authentication. The last verified published place remains version 62. Creator Dashboard previously confirmed Publish to all ages and all three verification checks Done; eligibility is separate from the Studio authentication failure.

The reopened latest local build passed a session-only smoke test of relocated Activity001 (toy shelf), Activity002 (skittles), and Activity008 (community flower bed). All returned successful interaction responses. The runtime console contained only the ready message. Test flags were removed in Edit mode afterward. This does not certify live persistence or multiplayer behavior.

### Successful publication

After the user refreshed Studio authentication, the latest local build was published over the existing start place. Reopening the cloud place through Studio MCP confirmed PlaceId 111572448337932, UniverseId 10767699101, PlaceVersion 64, recreation-cozy-4, and no workspace test flags. Public access remains blocked by the required content maturity questionnaire (currently 0 of 17 sections completed, Unknown label); the public audience change was not saved. No questionnaire answers were guessed or submitted.


### Public access enabled

Completed and submitted all 17 content questionnaire sections after reviewing current gameplay and Roblox definitions. Roblox confirmed Questionnaire Completed, Minimal rating, descriptors None, and no non-compliant regions. Saved audience Public; dashboard confirmed Changes saved. Audience reach still reports Ages 16+ and trusted friends, while account publishing reach is All ages. The experience reach page lists a refundable publishing fee not submitted, highly engaged players not eligible (0/250), and optional expedited review for 50,000 Robux. No payment was initiated. Public does not yet mean unrestricted access for younger accounts.

