# The Neighborhood

Roblox social sandbox. Target place: 111572448337932.

## Workflow
Source in `src/` is authoritative. Studio is the running verification target. No existing Rojo configuration or binary was present at baseline. `tools/package.ps1` emits an MCP installation payload. Apply that payload through `execute_luau` in Edit mode only. Do not edit duplicate script copies independently. A future Rojo migration must preserve the world and adopt the same mapping.

`src/shared` → ReplicatedStorage.Neighborhood.Shared
`src/server` → ServerScriptService.Neighborhood
`src/client` → StarterPlayer.StarterPlayerScripts.Neighborhood

WorldBuilder authors editable models in Workspace.Neighborhood. It refuses to overwrite an existing world. Original template parts are retained under ServerStorage.NeighborhoodBaseline.

## Testing
Run Studio Play and inspect Output. Use StudioTestService.ExecuteMultiplayerTestAsync for real simulated clients where available. Runtime tests exercise production services, not separate toy implementations. Studio sessions use isolated in-memory profiles until persistent storage is explicitly implemented and verified. Never claim this mode saves between sessions.

## Architecture
Small lifecycle bootstrap; shared configuration/types; server-only player, house, and interaction services; reusable client UI tokens/components. Clients request actions; server validates type, identity, distance, state and rate limit. No third-party scripts/assets.

## Source control
Local Git repository; no remote configured. Milestones are local checkpoints, not GitHub pushes. Master brief: user-provided roblox_codex.txt, read in full on 2026-09-22. Conversational artifacts are not requirements.
