# NPC home routines

Published as **v106**, confirmed by Studio PublishSuccessful on September 24, 2026 at **18:19:12 UTC**.

NPC residents now begin inside their own vacant house, pause at home, open the real front door before leaving, walk their existing park route, and return through the same doorway. Interior and exterior points are calculated from each house foundation and closed door, supporting both street orientations. NPC-opened doors close after traversal, with closure deferred while a player is near the doorway. Player ownership removes the NPC before further movement or door operations.

## Studio verification

One player occupied a house, leaving 11 NPC homes. Test scripts accelerated the doorway segments of the live routines: all 11 inside/outside containment checks passed, all 11 residents exited and returned, and a simulated ownership assignment immediately removed its NPC. A separate doorway raycast check passed for all 11 homes with their doors open. The first clearance attempt raced against the active closing routine; the isolated rerun paused the routine and passed.

Rojo build succeeded. These are lightweight waypoint routines, not general-purpose pathfinding or a full autonomous household simulation. Long-duration roaming and player-proximity door deferral were not separately stress-tested in this change.
