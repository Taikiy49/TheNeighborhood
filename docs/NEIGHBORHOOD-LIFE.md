# Neighborhood Life

Open **Phone → Neighborhood Life**. The seven activity families share personal mastery and save through the existing profile repository. This update does not complete the entire master specification or certify a public release.

## Activities

| System | Playable behavior | Limits and save behavior |
|---|---|---|
| Gardening | Four side-yard beds; Daisy, Lavender and Sunflower; watering; six regular/hybrid discoveries; bouquets and planters | Plants mature while offline and never wilt. Water once beside a different species to produce a hybrid. Flower and arrangement storage caps at 999 each. |
| Home businesses | Nursery, furniture workshop and repair shop; named NPC customers; three server-timed work steps; cash and mastery rewards | Required rooms: GardenRoom, Workshop and Garage. Nursery consumes an arrangement; other commissions cost $25 supplies. Completion pays $90. Orders and cooldowns save. No player-to-player purchases in this update. |
| Co-op renovation | Restore the Corner Cafe, Maple Clubhouse and Community Greenhouse through 12, 18 and 15 repairs | Shared construction belongs to the current server. Saved personal contributions merge once per visitor, with reconnect watermarks. Completion receipts restore a finished place in later servers. Contributors earn 20 mastery XP once. |
| Community places | Serve tea for mastery, feature a decorating theme for a banner, collect three daisy cuttings | All three activities share a saved one-minute cooldown. The cafe is a simple service interaction, not a separate cooking simulation. |
| Mysteries | Three cases, three weekly clue variants per case, three physical clues, deduction and two endings each | Six ending stamps. Each new ending pays $50 and 20 mastery XP once. Saved clues have no expiry. Wrong deductions have no penalty; changing cases discards only the unfinished case. |
| Home tours | Explicit owner opt-in, online listings, three visitor highlights, preset compliments, three theme banners | Opening unlocks the home; locking ends the tour. Existing theft rules still apply to displayed possessions. Any displayed possession qualifies for the cosmetic showcase, including starter items. No public free-text reviews or wealth ranking. |
| Building mastery | Lifetime XP, displayed level, four crafted blueprints and three accent styles | Blueprint thresholds: 30/100/250/500 XP. Coastal accents require 150; Autumn 350. Styles affect the new garden and counter, preserving boutique finishes. No unbounded plot expansion. |
| Seasonal festivals | Four seasonal palettes, four-stop lantern hunts, nine-pass cooperative relay, twelve token cosmetics | Current season follows UTC month. All archived hunts remain available. Hunt cooldown 180 seconds; relay rewards at most once per 180 seconds per profile. No Robux or random paid rewards. |

## Finding everything

- Garden beds and the awning counter sit beside your cottage. Plant and water at the bed; arrange flowers, run orders and craft blueprints at the counter.
- The home gallery sign is near the front porch. Open a tour, select a theme or enter the showcase there. Visitors see the porch, living room and side garden.
- Numbered park lanterns run north to south: 1 near the north park entrance, 2 in the north half, 3 in the south half, 4 near the shops. Mysteries use the first three; hunts use all four. Relays repeat 1 → 2 → 3 three times and can be completed solo.
- Cafe and clubhouse pavilions are north of the cross street. The greenhouse is between the two shops at the south end. Begin a repair at its counter, stay nearby for three seconds, then finish it.

## Architecture and authority

`LifeDefinitions` owns authored catalogues and world locations. `LifeRules` validates saved data and implements synchronous resource mutations. `LifeService` checks profile availability, living/on-foot state, ownership, physical range, line of sight, request pacing and route travel time. `LifeFactory` builds bounded native geometry. `LifeScreen` uses the existing phone, row, pending-action and notification components.

The `Life` profile field defaults safely for older version-2 profiles. Existing snapshot and repository code saves it without a separate datastore. Invalid saved catalog IDs, counts, timestamps, unlocks and receipts fail validation. A completed order clears its active step in the same synchronous call that awards cash; ending receipts and cosmetic ownership prevent repeated payouts or charges.

Physical route checks reject implausibly fast successive claims, but are not a universal movement anti-cheat. Automated test fixtures explicitly shorten preparation or reposition avatars in the broad state-machine suites. `LifeWalkAcceptance` separately exercises actual walking and normal preparation time.

## Scope boundaries

The seven systems are implemented at the scope above. Finite authored content remains finite: three businesses, three cases, three renovation places, four mastery decorations and twelve festival cosmetics. Personal mastery continues after these unlocks; this is not an infinite content generator.

Live Roblox persistence/rejoin, cross-server travel and publication must be verified against an authenticated published Studio experience. The connected QA file has PlaceId 0 and uses session-only profiles. The online rejoin fixture includes the new fields but must not be reported as passing until it actually runs online.
