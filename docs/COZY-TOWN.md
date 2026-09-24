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

This pass is not yet verified published. The current Studio File menu disables Save to Roblox and Publish to Roblox; its recent logs contain repeated 401 Unauthorized errors. The publish shortcut did not produce a success state. The last verified published place remains version 62. Roblox's Creator Dashboard currently reports eligibility for **16+ and trusted friends**, with age check complete, but identity verification and 2-step verification incomplete. All-ages access cannot be claimed from this state. Further visual refinement and multiplayer regression remain before calling this a complete release.
