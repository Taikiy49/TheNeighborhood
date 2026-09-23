# Expansion and regression evidence — September 23

Implemented in live Studio and local sources: physical carried delivery parcels, cancellation and movement validation; five discoverable gnome clues and a once-only Moonlight Gnome reward; historical collection records; rotating clear/overcast/rain weather, shelter-aware client rain and reduced-motion support; journal and forecast phone pages; two additional achievements.

## Executed tests

| Evidence | Scope and outcome |
|---|---|
| exploration-results.json | Passed 10 feature groups, 18 malformed service requests and six isolated actual DataStore groups. Includes physical walking delivery, cancellation/death/teleport rejection, all five discoveries, reward replay/full-inventory checks and historical collection persistence. |
| network-results.json | Passed 328 actual remote requests across two clients, including invalid types, NaN/infinity, oversized IDs and bursts. Rain visible outside, hidden under roofs and reduced motion, with reusable allocation. |
| lifecycle-stress-results.json | Passed 100 complete purchase/place/store/sell cycles across ten shop definitions and 600 invalid ownership/replay/state transitions. Exact currency, GUID and inventory invariants; runtime descendant count unchanged. |
| storage-stress-results.json | Passed 12 injected storage groups, 239 storage calls, including 50 seeded credit/spending cycles and repeated lost save acknowledgments. |
| capacity-rain-results.json | Eight clients, eight cars, eight pets and rain visible on every client. No captured application errors. Mean server frame time 32.36 ms / p95 111.55 ms with fixtures, versus 34.14 ms / 115.49 ms warmed baseline. Functional pass; local frame spikes remain. |
| disconnect-race-results.json | Actual owner departure while another player carried their possession, with four-second injected save delay. Carry returned before saving, closing profile/home protected, plot cleaned and delayed callbacks stayed cancelled. |
| core-regression-september23.json | Core two-client regression and storage coverage; see recorded checks and outcome. |

## Bugs found and corrected

- A committed save whose acknowledgments were lost could later overwrite inbox income with stale memory. Cumulative durable credit totals now merge unseen income while preserving subsequent local spending. The fault test reproduces this exact sequence.
- A departing owner remained targetable while the final save yielded. Profiles now enter a closing state before cleanup/saving; interactions and robbery reject closing owners.
- Social target IDs now reject nonfinite/noninteger/oversized values before player lookup.
- Event notifications now point to the actual Phone → Event menu.

## Desktop visual/input checks

An isolated memory-profile Play fixture displayed the welded parcel and carry pose, rain, readable five-clue journal and forecast. MCP mouse clicks opened Journal and Weather and cancelled a delivery through Progress. After cancellation, delivery address and carry pose were cleared and the panel closed. Screenshots were inspected. Scroll position was set programmatically to expose offscreen menu rows; this does not establish touch-scroll usability. Test attributes were cleared after stopping Play.

## Limits

These are bounded tests, not proof against every exploit or concurrency sequence. Eight local Studio clients do not establish production load or low-end mobile performance. Real touch/controller coverage, unfamiliar-player usability/fun, long-duration soak tests and production release validation remain. The entire master specification is still incomplete; SPEC-COVERAGE.md retains outstanding features instead of claiming completion.
