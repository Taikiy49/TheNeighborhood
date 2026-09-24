# Finished venues and usable cafés

September 24, 2026. This pass replaces eleven destination shells plus three renovation-project structures with sourced buildings. Eighteen additional public interiors use imported booth furniture instead of the repeated block sofas and tables. Existing service object identities, saved progress, shop purchases and repair rewards remain connected.

## Replaced destinations

| Destination | Imported building and purpose |
| --- | --- |
| Corner Café | Furnished café, free consumable tea and paid barista timing job |
| Park Café | Furnished café from the first visit; community upgrades remain available |
| Palm Diner | Furnished diner seating and tea counter |
| Sunset Café (internal NoodleKitchen) | Furnished café and tea counter |
| Boardwalk Bakery | Brick three-storey building, pastry display, counter and seating |
| Maple & Co. | Stocked market, existing furniture purchasing menu |
| Corner Convenience | Stocked convenience store and tea counter |
| Fuel and Snacks | Stocked market beside existing fuel pumps |
| Second Chance Pawn | Brick shop, display shelving, existing resale counter |
| Maple Repairs | Brick workshop with imported tool workbench; existing timing activity |
| Coast Bait & Tackle | Brick waterfront shop with existing fishing information |
| Orchard Farm Market | Glass greenhouse and two imported produce stalls; free apple interaction |
| Maple Clubhouse | Finished brick clubhouse; community renovation progression |
| Community Greenhouse | Glass greenhouse, planted interior, renovation progression |

Renovations now improve finished venues instead of making every new server start with unbuilt pillars. Saved contribution requirements and project rewards still apply. Public-room furniture is sourced, but not every remaining building shell in the world has been replaced by this pass.

## Creator Store sources

All were free Creator Store listings when inspected. Attribution reflects the listing; it is not an independent certification of the uploader's authorship. No paid assets or plugins were purchased.

| Asset | Listing creator | Use |
| --- | --- | --- |
| [Small Cafe Food Restaurant Interior Relax](https://create.roblox.com/store/asset/122326682604038) | XxScarl3ttSparklyStr | Full café, booth furniture, pastry display, counter, tea cup |
| [Bakery](https://create.roblox.com/store/asset/16438349425) | Myzicx | Brick shop shells with stairs; clubhouse, bakery, repair and pawn/tackle shops |
| [Convenience Store](https://create.roblox.com/store/asset/367794210) | EndorsedModel | Three stocked market buildings |
| [Greenhouse](https://create.roblox.com/store/asset/235766234) | EndorsedModel | Community greenhouse and farm market |
| [Workbench tools workshop hardware](https://create.roblox.com/store/asset/119227303977130) | Ic3X7Sparkly37Blizza | Repair shop and industrial workshop |
| [Fruit Stand 1](https://create.roblox.com/store/asset/4331699102) | Sr.Dank Followers Group | Two orchard produce stalls |

Imported scripts, remotes, click detectors, prompts, sounds, joints and package links were removed before use. Geometry is anchored; seats remain usable. Original tool containers became inert displays. Model scale stays uniform. Native binary serialization retains unions and meshes in [VenueArt.rbxm](../assets/VenueArt.rbxm). Door leaves were opened/removed where necessary for passage. Imported giver labels were removed, storefront names adapted, greenhouse floors finished, and two intersecting street trees cleared.

## Café gameplay

Tea is free, limited to one café snack at a time, lasts at most three minutes and disappears when consumed. Its visual is the imported cup. It is not a saved inventory/economy item.

Corner Café offers a barista timing activity. Begin brewing, wait four seconds for READY, then serve within three seconds. A successful order pays $15 through the existing server economy and records CityWork. Successful orders have a sixty-second cooldown; early, late and duplicate requests cannot award money. Existing interaction profile/distance/line-of-sight validation applies.

## Verification

- Eleven regular venue service requests passed through the real InteractionService.
- Three renovation buildings rebuilt and opened their project interaction successfully.
- Barista early submission denied; correct completion added exactly $15; immediate repeat denied.
- Imported tea collected, duplicate denied, equipped and activated from the client; server confirmed it was consumed.
- Physical Humanoid walking succeeded through café, general market, bakery, greenhouse, orchard, tackle, repair and pawn entrances. Tests used a setup teleport outside each building, then actual walking through its doorway.
- Curated library contained zero executable scripts or remotes.
- Clean Studio startup, native geometry export and Rojo build.

Tests used an isolated in-memory Studio profile. They do not constitute a full multiplayer load test, mobile FPS benchmark or a new production save/rejoin test. Existing town systems outside these venues were not exhaustively retested. The reproducible service test is [test-venue-renewal.server.luau](../tools/test-venue-renewal.server.luau); inject only during an isolated test, never as an unguarded production script.

## Actual Studio Play screenshots

Screenshots show the running game with its local HUD hidden for inspection, not generated concept art.

![Furnished café interior](../assets/screenshots/venue-cafe-interior.png)
![Orchard farm market](../assets/screenshots/venue-orchard-market.png)
