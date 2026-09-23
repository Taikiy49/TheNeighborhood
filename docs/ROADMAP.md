# Implementation tracker

- [x] Read complete specification and inspect empty repository/Studio
- [x] Baseline Play: one player, no console errors, screenshot inspected
- [x] Phase 1 foundation and two-client verification (session-only basic data)
- [ ] Phase 2: eight houses, shops, park, backyards, shortcuts and lighting built; environmental ambience remains basic
- [ ] Phase 3: all ten item definitions/models, inventory and fixed display placement implemented; voluntary drop/carry UX remains
- [x] Phase 4: starting money, authoritative purchases/sales and duplicate/ownership rejection verified
- [ ] Phases 5–6: physical weighted Golden Toilet theft, walking escape, recovery and fencing verified with two real clients; carry animation and subjective fun iteration remain
- [ ] Phases 7–10: timed locks, camera/alarm evidence, incident timelines, active cases and pawn recovery implemented; accusation and richer incident presentation remain
- [ ] Phases 11–12 durable persistence and honest offline recap
- [ ] Phases 13–17 UI/world/audio polish, device/multiplayer QA and fun iteration

Post-MVP content remains deferred per sections 60 and 147. Do not equate implemented scripts with verified acceptance criteria.

## Current blocker

Roblox rejects the read-only development DataStore probe with `StudioAccessToApisNotAllowed`. The experience owner must enable Studio Access to API Services in Game Settings → Security. No persistent store has been written. Session locks, migrations, retries, shutdown saves and honest persisted recaps remain unfinished. The HUD truthfully says progress resets.

## Verification evidence

See `multiplayer-results.json` for the latest two-client production-service acceptance run. Eighteen recorded verification groups passed, including real walking escape, timed lock cancellation, recovery history, teleport rejection and actual client departure. A first departure test checked too early; it now waits for the removal event with a bounded timeout.

Latest desktop Play: Inventory and Close activated through MCP input. Feedback audio loaded and played; alarm lights activated, stopped and temporary sounds were cleaned up. Fixed a streaming-related missing-door error and repeated Play with clean application Output. Earlier mobile portrait/landscape screenshots were inspected; touch activation and controller navigation are still unverified. Automated tests do not establish that unfamiliar human testers find the game clear or fun.

## Remaining before declaring MVP complete

Finish persistent profiles and rejoin/shutdown/failure tests; honest recap; accusation/recovery investigation UX; voluntary drop behavior; carry animation and broader audio; full onboarding progression; mobile/controller end-to-end interaction; capacity/concurrency/failure simulations; unfamiliar-user playtests and iteration. No launch or publication approval is implied by local checkpoints.
