# Art pass and publication evidence — September 23, 2026

## Delivered
- Editable art pass: 694 decorative parts, anchored and excluded from collision, touch, and raycasts. Flower boxes, porch/roof trim, shutters, interior accents, striped shop awnings, fountain court, planting, varied tree crowns, meadow perimeter, warmer lighting and restrained post-processing.
- Decorative shadows disabled after the first capacity run. Existing gameplay/world geometry retains its shadow behavior.
- Updated source-controlled world snapshot and portable Rojo build.
- Roblox listing description and icon saved, Higgsfield promotional cover uploaded and activated, eight-player limit saved, Roleplay & Avatar Sim / Life genre saved.
- Version 37 verified in Creator Dashboard with the published-only filter. Public launch remains blocked by account eligibility; experience audience is Private.

## Executed checks
`art-navigation-results.json`: PASS, 23 pathfinding routes (eight mailboxes, eight entrances, five clues, two shops), all six display slots retained in every house, decoration budget and collision/query exclusions verified.

`respawn-network-results.json`: PASS, 328 actual malformed/burst remote requests, four actual character reloads across two clients, balances/original inventory IDs/homes preserved, one HUD per client, rain/shelter/reduced-motion checks, no application errors.

`art-capacity-results.json`: functional PASS with eight actual clients, independent homes and balances, eight cars, eight pets, forty rain streaks per client, no application errors. This is NOT a performance pass. Local server mean frame time was 23.08 ms / p95 80.51 ms at baseline, and 102.51 ms / p95 372.33 ms with cars, pets and rain. Eight clients and the Studio server shared this computer. Production/mobile performance is not established.

Additional single-player observation: 300 server frames over five seconds, mean 16.663 ms and p95 18.042 ms. SceneAnalysisService observations: street view 30 draw calls / 58,752 triangles including UI; shop view 107 / 104,202 including shadows (80 / 76,631 after subtracting shadow rows). These are viewpoint-specific observations, not device certification or a replacement for the capacity result.

## Limits
The full master specification is still incomplete; see SPEC-COVERAGE.md. This art/marketing update does not implement missing trading, bounties, planted-evidence, seasonal, garage, or other roadmap systems. The cover is an illustration rather than a gameplay screenshot. No public user sessions, monetization purchases, or production-device performance were verified in this release pass.

## Publishing blocker
Roblox reported “You don't have permission to publish to this audience.” The account eligibility matrix showed personal-use publishing available, camera age check missing for 16+ reach, and government-ID verification, camera age check, and two-step verification missing for all-ages reach. The owner must complete these account requirements. No authentication or identity verification was automated.
