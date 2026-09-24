# Town-life release verification

## Passed in Studio

- 30 catalog, duplicate purchase, insufficient funds/level, remote-showroom, five-vehicle spawn/resale, nine-blueprint placement, invalid slot/rotation, migration and level-boundary checks. `town-life-results.json`.
- 21 menu/layout combinations across 510×560, 360×480 and 360×220, plus a late-refresh dismissal check. Yard, Garage, transaction review, Goals, Help, Progress and Friends opened and closed with readable labels. `town-ui-results.json`.
- Native input: task-card Hide; Goals open/Close; garden world prompt; Escape from garden; optional tour Close restored Custom camera and prompts. These checks use actual Studio UI, not a mocked browser.
- Injected profile repository: 1,000 settlement/spending cycles, 4,040 store requests, lease conflicts, retry exhaustion, lost commit responses and reload, preserving the new yard and vehicle fields. `town-repository-results.json`.
- Five vehicles drove more than 40 studs in short controlled server-physics samples. This is not full multiplayer driving certification. `town-final-world-results.json`.
- Traffic stopped for a placed obstacle and resumed after removal. Six vehicles moved after the renovation-location fix. Tram completed a full stop-to-stop ride with safe exit; early exit clears the passenger and remains stable through the next arrival. `town-mobility-results.json`.
- Road regression: 45 connected nodes, 64 edges, 12 houses on three streets, 12 garage spawns, eight shuttle destinations, zero static lane blockers. Dynamic traffic is intentionally excluded from the static lane scan.
- Furnished garden has no bounding-box overlaps with existing home gardening/workshop parts; release clears its display, restore reconstructs six saved slots, remote placement rejects. Screenshot: `assets/screenshots/town-personal-yard.png`.
- Repeated work XP shares a reward cooldown; repeating a one-time yard event does not farm XP.

## Fixed during testing

Old garden shade trees occupied new placement spaces. Gardens now reserve rear room for flower beds/workshops, with shade beyond the fence. Renovation rebuilds returned Cafe, Clubhouse and Greenhouse to legacy positions; rebuilds now retain their district destinations. The greenhouse had stopped traffic. Early tram departures retained passenger state/unstable seat motion; departure now clears membership and restores the player safely. A malformed garden rotation expression prevented the new menu loading; corrected and all UI cases rerun.

## Build and design checks

Rojo build succeeded. Strict premium UI audit reports no findings (`town-ui-audit.json`). DESIGN.md lint reports zero errors and six existing orphaned-document-token warnings; runtime Theme/UI references these colors. The JSON/link checker passes. No web/DOM accessibility certification is implied for native Roblox GUI.

## Limits

Tests used an isolated, session-only Studio player. No real currency or profile was overwritten. Simulated storage reloads do not replace a published live save/rejoin test. No twelve-client soak, physical low-end phone run, comprehensive traffic jam simulation or months-long economy/retention study was performed. Airport, carnival and other coastal features retain their previous release checks; they were not all exhaustively replayed for this change. Private friend circles still cap at eight even though the public map has twelve houses.

## Reproduction

Run `tools/town-life-checks.luau`, `tools/town-ui-checks.luau` and `tools/town-mobility-checks.luau` as normal Scripts/LocalScripts in an isolated Studio session with `NeighborhoodVisualTest=true` and automatic VisualAcceptance disabled. Scripts deliberately alter only the session fixture. Run them sequentially, with a fresh starter fixture for the catalog checks. Never publish these injected scripts or the test flag.
