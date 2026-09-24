# Personal home grant and sign cleanup

Requested by taikiyama49 on September 24, 2026. The server verifies UserId 2868186764; usernames and client requests cannot trigger the grant for anyone else.

- Removes the 12 physical GARDEN boards, retaining invisible yard interaction anchors and ownership checks.
- Removes the redundant Coast Gardens board and default Garden workshop labels. Actual business signs remain. Home-tour boards appear only when a tour is open.
- Grants the owner a Sunset roadster, bicycle, dog, six furniture types, and six yard blueprints/decorations. Existing ownership, selected vehicle, occupied display slots, yard placements, currency and progression are preserved.
- Applies once after profile load and house assignment, before restoration. Statistics.OwnerHomeV1 is the saved receipt. No client grant endpoint, offline datastore overwrite, cash grant or paid entitlement change is involved.

The owner must join a fresh production server to receive the grant. Studio verification used an isolated session-only profile, not the production save. A production save/rejoin has not been observed for this release.

## Verification

Live Studio checks passed: owner grant on load; no changes for another UserId; repeated grant does not duplicate gifts; schema save/load roundtrip; live ItemService snapshot; existing vehicle selection, custom plate, yard rotation and currency preserved; 12 hidden yard anchors; garden proximity prompt retained; six restored yard decorations; spawned owner-only roadster with expected speed 36. Closed-tour board hidden. Visual yard inspection completed. Rojo build passed.

`tools/test-owner-home.server.luau` contains the core repeatable checks; inject only into an isolated Studio playtest. All temporary scripts and test flags were removed before publishing.
