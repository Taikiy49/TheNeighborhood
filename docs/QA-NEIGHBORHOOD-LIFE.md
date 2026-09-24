# Neighborhood Life verification — September 23, 2026

This report concerns the seven activity systems documented in [Neighborhood Life](NEIGHBORHOOD-LIFE.md), not completion of all master-spec requirements.

## Test methods

- `LifeAcceptance` and `LifeCapacity`: 200 deterministic progression simulations per suite, then actual server-service tests with two/eight connected clients. Cover schema migration, offline plant growth, recipes, three business workflows, all mystery variants and endings, four seasonal collections, mastery, malformed requests, foreign-owner rejection, renovation merge/reward receipts, tours and repeated rendering. Preparation timestamps and avatar positions are intentionally adjusted in these broad fixtures.
- `LifeWalkAcceptance`: actual Humanoid movement through 34 walking legs, four beds, the counter, all three tour highlights, three clue stations and the cafe. The cafe repair uses the real three-second preparation delay. Five setup teleports establish independent scenarios; the measured walking legs are not teleports.
- `NetworkAcceptance`: two clients send 830 requests through production remotes, including malformed Life requests and duplicate building purchases; four character reloads; weather and reduced-motion checks.
- `UIAcceptance`: 156 checks across two real clients, including all nine new Life views at 510px and 360px panel widths. Existing pending-state, clipping and non-overlapping notification checks remain. These are viewport checks, not physical mobile/controller tests.
- Existing building, adventures, foundation, friends, plot selection, exploration, lifecycle, disconnect races, art, boutique and storage suites are rerun for integration coverage. Exact final results are in [the regression log](qa/life-regression.json).

## Defects found and corrected

1. Soil/decoration geometry obstructed the garden bed's interaction ray. Life stations now exclude their own authored fixture from that ray while retaining range and surrounding-world checks.
2. Nearby avatars could obstruct shared activity signs. Life station rays ignore player characters.
3. The showcase checked stale serialized items rather than the live ItemService inventory. It now checks authoritative current ownership/display state.
4. The initial garden extended beyond the original rear fence. All four beds now fit inside it, with a central slate path; real walking verifies access without an expansion.
5. Locking an open tour needed an immediate consent-state update. The lock now closes the tour immediately, and its missing Players-service import was caught and fixed by the foundation regression.
6. Tour user IDs require a bounded finite integer before calling Roblox player lookup.

One Studio regression launch returned `null` and left an abandoned local test server. It was not counted as a pass. Only its verified child processes were stopped before retrying; editor processes were preserved.

## Limits

The connected QA experience is `NeighborhoodExpansionQA.rbxl`, PlaceId 0 / UniverseId 0. It uses session-only profiles. Profile snapshots/schema round trips pass locally, but the new online save/shutdown/rejoin fixture has not run against Roblox DataStores. It is extended in `RejoinAcceptance` for the next authenticated published-place test.

Eight-client local measurements vary substantially under the load of running Studio clients together. The recorded LifeCapacity heartbeat p95 values do not certify production or mobile performance. The earlier platform `CreatorType` issue remains documented in the [expansion retest](QA-EXPANSION-RETEST.md). No claim of a full production performance sign-off is made here.

No live publication, live friend teleport, purchase transaction or age-eligibility change is verified by these local tests. Saved renovations are personal contributions/receipts merged into the current server, not a global cross-server construction datastore.

## Final regression result

All 14 suites in the regression log passed after corrections, including the targeted foundation and two/eight-player Life reruns. The separate production-network suite passed 830 requests and four respawns; the real-walking result is recorded separately. The UI suite passed 156 checks. The local source/Studio comparison covers 85 scripts, with only normalized line-ending differences. Repository validation and a fresh Rojo build pass.

A separate normal single-client session loaded all eight homes with every expansion, furnishings, mature gardens and Life decorations. Across 240 server heartbeat samples, p50 was 16.92 ms and p95 17.99 ms (7,271 world descendants). The final eight-client test p95 was 229.32 ms on this workstation. These different local loads do not establish production eight-player or mobile performance; see the [loaded-world measurement](qa/life-loaded-world-performance.json).
