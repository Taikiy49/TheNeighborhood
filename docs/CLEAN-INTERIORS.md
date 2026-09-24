# Clean cottage interiors

All eight spacious cottages now have coordinated fitted kitchens, window-side sitting areas, properly proportioned double beds with paired nightstands, subtle plank flooring, small botanical prints, consistent trim and soft ceiling lighting. Exterior siding is covered on the inside by independent plain liners. Old stretched interior decorations are removed; the exterior landscape remains intact. Six display targets retain their IDs and positions, with quieter translucent markers.

The default wood finish uses flat oak color and thin geometric board joints. Tile, carpet and boutique floor finishes hide those joints. The rear liner hides when a garden room is purchased and restores on release, preserving the expansion passage. Paid exterior paint does not recolor the independent interior liners.

The deterministic Edit-only authoring tool is tools/clean-interiors.luau; the exported world already contains its results. It rebuilds its own interior folder, removes the prior rear liner and interior-only decoration, and does not touch player saves. No new purchases or economy changes were introduced.

The README screenshots are actual Studio edit-viewport captures, not render concepts. They omit player-owned items and runtime HUD. The added geometry and lighting have not received an eight-client performance certification; live save/rejoin and publication remain pending an authenticated published place.

Recorded multiplayer results: [interior regressions](qa/clean-interiors-regression.json).

## Verification

Three multiplayer suites passed with two real Studio clients: SpaciousAcceptance (24 walking legs, all eight authored homes checked), BuildingAcceptance (22 walking legs through additions, actual garage driving, 4,200 malformed requests, 50 pack/reload cycles), and BoutiqueRegression (600 style equips, 24,000 siding checks, 800 malformed requests). The finish regression explicitly checks the clean interior liner color and floor-joint visibility across every cosmetic style and reset. No actual Robux purchases were made; ownership uses the injected test adapter.

The two-client building sample reported an 18.02 ms heartbeat p95; this is a local sample, not a general performance certification. All 87 sources were synchronized, the exported asset contains the expected eight mirrored interiors, and the Rojo build and repository checks pass. An initial test-harness syntax error was corrected before the recorded successful runs.
