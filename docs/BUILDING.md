# Build and Studio setup

## Requirements

Roblox Studio, edit access to the intended experience, and Rojo CLI **7.7.0**. The Rojo Studio plugin is needed only for live sync. Python 3 runs repository validation, not gameplay tests.

Download `builds/TheNeighborhood.rbxl` through GitHub's download/raw control and open it in Studio. It includes the world and scripts; Roblox-hosted textures/meshes still require asset access.

From the repository root:

```sh
python tools/check_repository.py
rojo build default.project.json --output builds/TheNeighborhood.rbxl
```

For sync, run `rojo serve default.project.json` and connect the Studio plugin. The project is restricted to place `111572448337932`. Change that restriction deliberately for an authorized separate test experience; do not sync a different live game accidentally.

| Source | Destination |
|---|---|
| `src/shared` | `ReplicatedStorage.Neighborhood.Shared` |
| `src/server` | `ServerScriptService.Neighborhood` |
| `src/client` | `StarterPlayer.StarterPlayerScripts.Neighborhood` |
| `assets/Neighborhood.model.json` | `Workspace.Neighborhood` |

Source is authoritative for scripts. Re-export intentional Studio world edits into the committed model snapshot before rebuilding. The configured ignore settings preserve unrelated instances, but do not replace backups or review.

## Persistence

Enable **Studio Access to API Services** in the experience's security settings for real DataStore tests.

| Purpose | Store |
|---|---|
| Studio player profiles | `TheNeighborhood_Development_v2` |
| Published profiles | `TheNeighborhood_Profiles_v2` |
| Studio saved circles | `NeighborhoodGroups_Development_v1` |
| Published circles | `NeighborhoodGroups_v1` |
| Profile fixtures | `TheNeighborhood_AutomatedTests_v2` |
| Isolated stop/rejoin fixtures | `TheNeighborhood_RejoinFixtures_v1` |
| Circle fixtures | `NeighborhoodGroups_AutomatedTests_v1` |

Explicit automated sessions use memory profiles. Live-storage modules separately create GUID-prefixed fixtures and remove them. Normal Studio Play uses development persistence when access succeeds; otherwise the HUD announces session-only mode. Production load failures never silently replace a saved profile with defaults.

## Visual fixtures and authoring

Set `Workspace.NeighborhoodVisualTest=true` in Edit before Play for a memory-profile preview with car/pet. Also set `VisualExploration` for parcel/weather fixtures. Stop Play and clear both attributes afterward. These are not persistence tests.

- `tools/package.ps1`: emits an MCP script-installation payload; does not publish.
- `tools/build-interiors.luau`, `art-pass.luau`, `garden-redesign.luau`: Edit-time world authoring. Do not blindly rerun an older pass over newer edits.
- `tools/export-world.luau`: prepares a flat scene export for chunked MCP retrieval and conversion into the model JSON.
- `WorldBuilder`: initial scene generator; refuses to overwrite an existing world. The committed snapshot is the current design.

Build, sync, local save and **Publish to Roblox** are separate operations. See [Release status](RELEASE.md).
