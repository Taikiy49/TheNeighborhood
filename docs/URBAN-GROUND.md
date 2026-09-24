# Urban ground

Published as **v105** on September 24, 2026 at **18:14:47 UTC**, confirmed by Studio's PublishSuccessful log and version note.

The broad town lawns are now asphalt. Both residential blocks have continuous paving, with back streets and footways. The central park is the deliberate large grass area; small planting beds, the lake and beach remain. Existing trees and lamps were moved out of the back-street carriageways.

![Urban paving in a Studio play session](../assets/screenshots/urban-ground-overview.png)

## Verification

- 11 broad ground parts converted to asphalt.
- Only ParkLawn remained in the visible, large, shallow grass-part scan (area over 100 square studs; this does not count small planters or terrain).
- Zero collidable obstacles in the two checked back-street clearance boxes after relocating trees and lamps.
- Zero coplanar candidates in the new UrbanGround folder under the existing surface audit.
- Final runtime overview inspected; Rojo build succeeded.

This is a scenery update. It does not add new gameplay or prove all map collisions or mobile performance. Published changes appear in fresh servers; Studio's authored edit view retains the base map because the modules build the final town at server startup.
