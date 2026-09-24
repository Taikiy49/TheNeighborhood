# A larger garden district

The authored map is now **1,440 × 1,200 studs**. Each of the eight homes has a **90 × 78-stud foundation** and **84 × 72-stud floor**. Compared with the previous spacious build, that is 2.25 times the floor area. Cottage walls and ceilings are 30% taller, with matching roof geometry. Beds, sofas, cabinets, guides, vehicles and collectible targets retain their useful scale.

## Layout

- **Maple Green:** central paths, planted courts, shade trees and a small fountain plaza.
- **Willow Lake:** an ornamental shallow water feature, shoreline promenade, benches and a viewing deck. It is scenery, not a swimming or boating system.
- **Picnic Meadow:** connected paths, an open-sided pavilion, picnic tables and usable seats.
- **Maple Orchard:** southern tree rows with clear walking alleys.
- **Market Street:** consistent shop finishes and a shared paved apron.
- **Residential streets:** wider plots, coherent cottage trim, window divisions, native-scale mailboxes, planted verges and warm street lighting.

The outer promenades connect these areas to the existing neighborhood. The road lanes remain at vehicle scale instead of growing into oversized highways. Existing gameplay destinations remain in their corresponding parts of town.

## Compatibility

WorldSpace now maps original authoring coordinates at a horizontal scale of three. Plot, slot, room and saved-layout IDs remain stable; this update does not reset possessions or progression. The existing theft guard still requires leaving the cottage and its extensions. Observation and camera coverage follow the larger home footprint; ordinary interaction ranges remain unchanged.

The taller rear connector matches the cottage wall height, and its interior finish hides correctly when a garden room is built. Floor choices and boutique finishes retain their existing ownership checks. New scenery uses built-in geometry instead of downloaded tree meshes or generated siding images. The master specification remains incomplete; this update is a world expansion and visual pass.

## Authoring

The committed asset already includes these changes. Do not apply scaling migrations again:

1. `tools/expand-map-v3.luau` migrates the previous scale-two world once.
2. `tools/raise-cottage-roofs.luau` raises cottage architecture once, preserving floor elevations.
3. `tools/clean-interiors.luau` rebuilds the coordinated interior at the current map and height scale.
4. `tools/beautify-district.luau` rebuilds its own landscape, cottage trim and shop finishes.

The last two authoring tools are deterministic refreshes. Run them in Edit mode. Runtime building and activity factories use the matching palette and coordinate conversion.

## Verification and release limits

See [multiplayer results](qa/district-expansion-regression.json) for actual suite outcomes. Studio screenshots document the authored world; they are not generated concepts. Local tests do not establish live Roblox DataStore save/rejoin, public publication, or an eight-client performance certification. This remains the local development build until it is published through an authenticated Studio session.

The preview also exposed and fixed daytime indoor-light shutdown. LightingPolicy now distinguishes interior fixtures from outdoor lamps, registers later-created lights, and restores them after a power outage. The navigation audit caught a buried shop clue and an over-tilted awning; the clue is now beside the store, and the awning has adequate clearance. Roof/awning surface-corner checks cover the corrected scaling calculation.

The final authored scene contains 4,736 instances, compared with 5,296 before this pass. This reduction does not substitute for device-specific performance testing.

Ten Studio suites passed, including 100 counted physical walking legs and 23 separate navigation routes. The final district rerun used two clients and verified daytime indoor lighting, dynamically added fixtures and power-outage restoration. Save/reload and commerce checks use injected test storage/ownership, not real online purchases or rejoin. All 89 Studio source files match the repository; see [source parity](qa/district-source-parity.json) and [surface geometry](qa/district-surface-geometry.json).
