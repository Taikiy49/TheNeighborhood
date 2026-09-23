# The Neighborhood

Roblox social sandbox. Target place: 111572448337932.

## Workflow
Source in `src/` is authoritative. Studio is the running verification target. `tools/package.ps1` emits an MCP installation payload. Apply through `execute_luau` in Edit mode only. `default.project.json` now supports Rojo 7.7.0, preserves unrelated Studio instances, and restricts live sync to place 111572448337932. Build with `rojo build default.project.json --output TheNeighborhood.rbxl`. The editable world snapshot lives in `assets/Neighborhood.model.json`; re-export it after intentional world changes. Do not edit duplicate script copies independently.

`src/shared` → ReplicatedStorage.Neighborhood.Shared
`src/server` → ServerScriptService.Neighborhood
`src/client` → StarterPlayer.StarterPlayerScripts.Neighborhood

WorldBuilder authors editable models in Workspace.Neighborhood. It refuses to overwrite an existing world. Original template parts are retained under ServerStorage.NeighborhoodBaseline.

## Testing
Run Studio Play and inspect Output. Use StudioTestService.ExecuteMultiplayerTestAsync with Name=FoundationAcceptance for two-client gameplay/regression checks or Name=CapacityAcceptance for eight-client plot/currency checks. Explicit automated multiplayer sessions use memory profiles; LiveStorageTests uses isolated, cleaned-up DataStore fixtures. Normal Studio Play uses TheNeighborhood_Development_v2; published servers use TheNeighborhood_Profiles_v2. Failed production loads never fall back to overwritable defaults. When Studio API access is unavailable, the HUD explicitly labels session-only mode.

Verified evidence is in docs/multiplayer-expansion-results.json, docs/capacity-results.json and docs/rejoin-results.json. The normal stop/rejoin test verified shutdown flushing and original item placement. SPEC-COVERAGE.md tracks all 239 numbered sections; the full specification is not yet complete.

For isolated visual/input QA, set Workspace.NeighborhoodVisualTest=true in Edit, then enter normal Play. The gated VisualAcceptance fixture uses memory profiles and supplies a car and pet. Clear the attribute after stopping. This mode is ignored outside Studio and must not be confused with persistence testing. No test attribute is enabled in the delivered project.

`tools/build-interiors.luau` authors the two furnished room layouts idempotently in Edit mode. `tools/export-world.luau` prepares a flat scene snapshot for chunked MCP export. Rebuild the Rojo place after changing scripts or world assets.

## Architecture
Small lifecycle bootstrap; shared configuration/types; server-only player, house, and interaction services; reusable client UI tokens/components. Clients request actions; server validates type, identity, distance, state and rate limit. No third-party scripts/assets.

## Source control
Local Git repository; no remote configured. Milestones are local checkpoints, not GitHub pushes. Master brief: user-provided roblox_codex.txt, read in full on 2026-09-22. Conversational artifacts are not requirements.

## September 23 expansion
Physical deliveries, the five-clue gnome trail, historical collections and shelter-aware weather are implemented. See docs/QA-SEPTEMBER23.md for executed tests, fixes and limitations. Additional StudioTestService names: ExplorationAcceptance (2 clients), NetworkAcceptance (2), LifecycleStress (2), DisconnectRaceAcceptance (2), CapacityAcceptance (8). These execute real server/client test sessions; storage fixtures remain isolated.

To inspect parcel/rain/phone UI with a memory profile, enable both NeighborhoodVisualTest and VisualExploration Workspace attributes before normal Play. Clear both afterwards.
