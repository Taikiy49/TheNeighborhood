# Room to grow

Open **Phone → Plan your home**, or **Home → View expansion plans**. Build while standing on your own plot. Review the price, then choose **Build**. Purchases use earned in-game cash, not Robux.

| Expansion | Cash | Prerequisite | Adds |
|---|---:|---|---|
| Garden room | $900 | None | Glazed rear room connected to the cottage hall |
| Upstairs loft | $1,800 | Garden room | Upper reading room with a return staircase |
| Carriage garage | $1,400 | None | Sheltered parking; car recall uses the new bay |
| Backyard workshop | $1,100 | Garden room | Crafting bench and backyard studio |

The garden room connects directly to the workshop through a rear doorway. The garden door follows the existing house open/lock state, so locking the home also closes this entrance. Window mullions and warm trim frame the two-storey glass room.

Every expansion adds two collectible display spots, for **14 total** including the original six. Collectibles keep the existing ownership, theft, recovery, reservation and selling rules. Construction is permanent; there is no room demolition that could strand a possession.

## Crafting and arranging

Stand beside your workshop bench and open **Crafting**. Recipes: fern planter ($60), cushioned bench ($90), writing desk ($120), and little library ($140). Crafted furniture is permanent decor, separate from stealable collectibles. Own up to 48 pieces; no selling or duplication through layouts.

There are 15 furnishing rugs: four in the garden room, four upstairs, three along the back of the garage, and four in the workshop. Interact with a rug or use **Arrange furniture** in the phone. Choose a room, rug, piece and quarter-turn rotation. **Pack furniture** returns it to your available collection. Changing a rug can reuse its currently placed piece.

**Saved layouts** has three slots. Save captures all crafted furniture placements. Loading changes only those placements, with no charges and no changes to collectible displays. Saving again replaces that slot. Empty layouts are valid. Saved layouts cannot grant more pieces than you own.

## Persistence and authority

- `BuildingDefinitions` owns prices, recipes, local plot positions, slot ranges and caps.
- `BuildingRules` validates placement counts, unlock prerequisites and bounded save shapes.
- `BuildingService` checks profile availability, living character, homeowner identity, own-plot location, prerequisites, funds, collection capacity and bench distance.
- `BuildingFactory` creates native geometry in each assigned house's coordinate frame. Expansions render before collectible restoration. Leaving removes expansion geometry and extra display spots and restores hidden cottage walls/fences.
- `ProfileSchema.Building` adds defaults for existing version-2 saves. Invalid expansion or furniture data is rejected through the existing safe profile load path.
- Roommates retain existing door/lock permissions; they cannot build or rearrange another homeowner's furniture.
- Saved progress follows the homeowner between servers and saved neighborhoods. Offline homes are not simulated.

This is a bounded home-building system, not infinite land or an unrestricted part editor. Fixed plot footprints, furnishing grids and collection limits keep neighboring homes separate and bound object counts.

## Verification entry points

`BuildingAcceptance` runs with two clients. `BuildingCapacity` uses eight. Both run the same purchasing, malformed-input, arrangement, physical walking and cleanup contracts. `ProfileTests` includes expansion save/reload. `RejoinAcceptance` includes a loft display and saved furniture layout for actual server restart verification when Roblox API access is available. The QA report records which checks actually ran; test source is not itself evidence of a pass.

Expanded rooms remain inside the robbery boundary: distance from the original front door alone cannot complete an escape from the workshop. The public backyard gnome clue sits outside the expandable rooms, so another player’s building purchases cannot lock the trail behind their door. Existing house paint and floor selections apply to the new structures.
