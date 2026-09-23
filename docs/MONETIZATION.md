# Maple Style Boutique

Implemented in Studio and source. **Both registered passes remain off sale. This revision has not been published to Roblox.**

Open Phone > Style Boutique. Each permanent pass unlocks three coordinated wall/floor finishes; players can switch owned styles or restore their everyday finishes. Choosing ordinary paint or flooring also removes the boutique overlay. Cosmetics never change cash, theft, locks or progression.

| Pass | Roblox pass ID | Included finishes | Suggested launch price |
| --- | --- | --- | --- |
| Cottage Atelier | 1989884747 | Lavender Linen, Rosewood, Sage Studio | 49 Robux |
| Coastal Collection | 1989248710 | Sea Glass, Blue Hour, Sandcastle | 49 Robux |

The suggested prices are not configured sale prices. Both passes currently use Roblox's default icon.

## Implementation

- `src/shared/BoutiqueCatalog.luau`: real pass IDs, coordinated colors/materials.
- `src/server/Services/BoutiqueService.luau`: server ownership checks, equip validation, restore, throttled refresh and departure cleanup.
- `src/client/BoutiqueScreen.luau`: player-specific product information, native Roblox purchase confirmation, no button for unavailable/off-sale passes.
- `House.Boutique`: saved selection only. Saved profile data never grants ownership; Roblox owns that record. Joining rechecks ownership; API errors fail closed for unverified ownership and preserve already verified session entitlements.
- Purchase completion triggers a fresh server ownership check; cancelling does not grant anything. No developer products, repeat purchases or receipt callback are involved.
- Existing free/in-game-money home customization remains available. Packs include every listed finish; there are no loot boxes or artificial urgency.

## Verification

Studio isolated-profile tests exercised six floor colors/materials, denied forged/unowned and malformed requests, checked unchanged currency, restored base flooring, blocked changes during travel and round-tripped selected style through profile serialization/migration. A client probe opened the boutique (13 rows) and confirmed no purchase buttons with unconfigured IDs. The rendered screen was visually inspected.

Run `BoutiqueAcceptance` and `NeighborhoodVisualTest` Workspace attributes together in Studio, start Play, then inspect `Workspace.BoutiqueTestResult`. Stop Play and clear both attributes afterward. These tests inject entitlements, spend no Robux and do not prove a completed purchase or live ownership restoration across separate Roblox servers.

## Release gate

1. Publish and verify this code in the intended experience before enabling sales.
2. Configure both passes at the chosen price in Creator Hub; suggested 49 Robux each. Verify icons and descriptions, and confirm regional pricing is displayed correctly by the native prompt.
3. Test purchase cancellation, ownership API outage/retry, successful purchase, immediate equip and rejoin restore with a separate account using Roblox's supported test flow. Any real-money test purchase must be user-controlled.
4. Verify a successful buyer receives all three advertised styles before broad release. Keep passes off sale if delivery cannot be verified.

Official references: [Passes](https://create.roblox.com/docs/production/monetization/passes), [MarketplaceService](https://create.roblox.com/docs/reference/engine/classes/MarketplaceService).
