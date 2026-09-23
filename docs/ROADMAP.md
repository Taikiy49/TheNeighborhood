# Implementation tracker

Current overview: start with [README](../README.md), [Testing](TESTING.md), and [Release status](RELEASE.md). The milestone prose below is historical. Subsequent work added the garden redesign, friend parties, saved circles, cross-server invitation orchestration and persistent move-in plot choices. These features and their remaining published-client checks are documented in [Friends and neighborhoods](FRIENDS-NEIGHBORHOODS.md). GitHub now hosts the source/build history; this does not mean the later revisions were published to Roblox or all specification sections were completed.

- [x] Read complete specification and inspect empty repository/Studio
- [x] Baseline Play: one player, no console errors, screenshot inspected
- [x] Phase 1 foundation and two-client verification (session-only basic data)
- [ ] Phase 2: eight houses, shops, park, backyards, shortcuts and lighting built; environmental ambience remains basic
- [x] Phase 3 baseline: ten item definitions/models, inventory, fixed display placement, voluntary drop/resume
- [x] Phase 4: starting money, authoritative purchases/sales and duplicate/ownership rejection verified
- [ ] Phases 5–6: physical weighted Golden Toilet theft, walking escape, recovery, fencing and carry pose verified; subjective fun iteration remains
- [ ] Phases 7–10: timed locks, camera/alarm/witness evidence, incident timelines, evidence-checked accusations and pawn recovery implemented; richer investigation/presentation remain
- [x] Phases 11–12 basic durable persistence, failure checks, actual shutdown/rejoin and honest offline recap
- [ ] Phases 13–17 UI/world/audio polish, device/multiplayer QA and fun iteration

The user expanded the scope to all sections, including originally deferred content. `SPEC-COVERAGE.md` lists all 239 numbered sections. Do not equate implemented scripts with verified acceptance criteria.

## Persistence milestone

The owner enabled Studio API access. Persistent profiles now use separate development/production stores, UpdateAsync session leases, schema migration, bounded retries, periodic saves, shutdown flushing and corruption rejection. A sequenced outbox/inbox protects pawn payments from replay. Ten injected-storage scenarios and five actual Roblox DataStore checks passed. A normal Studio stop/rejoin retained currency, original item identity, display placement, lock state, and a change made after the explicit save, exercising shutdown flushing. The returning-player recap displayed successfully. See `rejoin-results.json` and `multiplayer-expanded-results.json`.

## Verification evidence

See `multiplayer-expansion-results.json` for the latest two-client production-service acceptance run. Twenty-seven gameplay groups passed, plus ten injected storage groups and five real DataStore groups. Coverage includes walking escape, timed lock cancellation, drop/resume, recovery history, teleport rejection, actual departure, vehicle physics/input validation, pet paths, community consent/rewards, physical patrols, prank protections and house-observation occlusion.

Latest desktop Play: Inventory and Close activated through MCP input. Feedback audio loaded and played; alarm lights activated, stopped and temporary sounds were cleaned up. Fixed a streaming-related missing-door error and repeated Play with clean application Output. Earlier mobile portrait/landscape screenshots were inspected; touch activation and controller navigation are still unverified. Automated tests do not establish that unfamiliar human testers find the game clear or fun.

## Remaining before declaring MVP complete

Newly implemented: evidence-checked accusations, quest checklist and achievements, voluntary drop/resume, carry pose for current and legacy avatar joints, phone/collection/preferences, house paint/flooring and lock upgrades, friend/roommate entry permissions, authored guide NPCs, event-based newspaper, and temporary opt-out yard pranks. These require continued UI/device/regression coverage. Eight actual Studio clients passed independent house, starter-kit and currency checks without server errors.

New expansion baseline: purchasable compact car with server-owned suspension, paint/recall and native controls; companion dog with path following, stay and visitor observations; four rotating community events; line-of-sight house casing; heat decay; neighbor cards; and eight furnished interiors with two mirrored layouts. Actual keyboard driving exposed a curb snag missed by the initial fixture. Raycast suspension fixed it: the vehicle crossed the curb and travelled 48.5 studs, peaked near 28 studs/sec, and stopped on key release. Actual mouse input applied paint; jump exited the seat. Visual fixtures explicitly use memory profiles, and their Edit-mode activation attribute was cleared afterwards.

Eight actual clients also exercised eight cars and eight pets. Functional capacity passed. A warmed comparison measured 29.65 ms mean / 89.85 ms p95 server frames before expansion fixtures, versus 30.12 ms mean / 98.08 ms p95 with eight cars and pets. Both have spikes. These local Studio observations are not a mobile or production performance pass; see `capacity-results.json`. Actual keyboard steering changed heading by 49.09 degrees; see `desktop-input-results.json`.

Still open: durable player trading/garage sales/auctions, bounties, planted evidence, gadgets, expanded secrets/legends, seasonal content, expanded neighborhoods, garages and broader house customization, advanced social/content systems, broader security/device testing, unfamiliar-user playtests and release operations. The full TXT is not yet implemented; all 239 sections remain accountable in the coverage ledger. No launch or publication approval is implied by local checkpoints.

## September 23 expansion and fault testing
Physical parcels and cancellation, five discoverable gnome clues with an exclusive collectible, historical collection records, rain/overcast/clear weather with shelter/reduced-motion support, journal/forecast screens and eight total achievements are now implemented. See QA-SEPTEMBER23.md for the latest evidence and scope. Twelve injected storage groups, six actual DataStore groups, 100 item lifecycle cycles, 600 rejected invalid transitions and 328 actual remote probes passed. Lost-save-acknowledgment income loss and a departing-owner targeting race were reproduced and fixed. Eight clients exercised cars, pets and rain; server frame spikes remain. Earlier counts above describe earlier milestones.

## Maple Adventures expansion

Six permanent rumor trails, saved story endings and checkpoints, optional uninterrupted walking records, three earned display trophies, and three cooperative park decorations are implemented. Personal progress persists; construction state belongs to the current server. See [Maple Adventures](MAPLE-ADVENTURES.md) and [QA](QA-ADVENTURES.md). This adds replayable exploration and cooperation without claiming the full master specification or long-term retention is complete.
