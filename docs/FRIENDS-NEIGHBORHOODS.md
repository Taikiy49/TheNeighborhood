# Friends and saved neighborhoods

Entry point: **Phone → Friends**. This feature extends the current eight-player neighborhood without changing individual profile storage.

## Player flow

1. Create a party and invite neighbors in the current server. Each neighbor accepts; all members explicitly ready up.
2. The leader moves the party into a reserved neighborhood. A solo player can also create a circle this way.
3. Membership and plot numbers are saved. Returning players use **Visit neighborhood**, even when the founder is offline. Arrival order does not change their plots.
4. The founder can choose Roblox friends from a paginated list and send a saved-circle invitation. Friends can accept it from any server through Phone → Friends → Refresh invitations. Invitations expire after 24 hours.
5. The Roblox invitation button opens the platform's permission-controlled game invite dialog. It does not automatically send messages or bypass privacy restrictions.

Circles are generated names, contain up to eight members, and use the same map. Saved membership is distinct from Roblox's paid/VIP private-server product. Up to 32 saved or pending directory entries are retained per player; overflow is rejected without discarding existing circles. Expired invitations can be declined to clear their entries.

The circle persists as membership and home assignments. Individual money, item identities, display slots, finishes, cars, pets and progression continue to use the existing profile system. It does not simulate or display absent members' furnished homes offline, preserve every transient weather/event state, or guarantee identical running server instances across Roblox cross-play pools.

## Authority and recovery

- Directory records and reserved access codes live only in server DataStores. Client views omit access codes.
- Membership is checked against the reserved server's actual PrivateServerId. TeleportData only correlates a failed travel request; it does not authorize entry or supply profile data.
- Friend invitations require founder authority and a Roblox friendship check. Accepting a fabricated, expired or full-circle invitation fails. Atomic UpdateAsync assigns an available slot and makes duplicate acceptance harmless.
- The party freezes progression actions, settles carried items, and saves every profile before departure. A failed save or transport request leaves the group in the source server with actions restored.
- The source profile lease is released on actual departure. Destination profile loading waits briefly for that handoff instead of stealing the lock.
- A partial departure preserves the original saved destination and transfers leadership to a remaining party member. Retry reuses the reservation. Asynchronous failures and a bounded timeout restore local actions; Roblox cannot guarantee atomic teleport of an entire group.
- Development directories and isolated test fixtures are separate from production directories. No production data was fabricated for the tests.

## Verification and release gate

Three actual Studio clients exercise party authority, explicit consent, readiness reset, reserved transport payloads, save failure recovery, transport failure recovery, partial departure, retry, and stable plots. An injected transport adapter is used because Studio cannot perform real Roblox teleports.

Independent repository tests cover fabricated invitations, founder-only invitations, duplicate acceptance, the eight-member cap, competition for the last slot, expiry, decline and directory overflow preservation. Actual Roblox DataStore tests verify group creation, cross-repository invitations, acceptance, durable membership/plots and decline; fixtures are removed afterward.

Real-client release checks remain: native Roblox friend/privacy behavior, group TeleportAsync, partial network failure, cross-server profile handoff, and return while the founder is offline. These require publishing the updated place and using Roblox clients/accounts with experience access. Do not describe mocked transport as a successful live cross-server test.

### Recorded results

- `friends-acceptance-results.json`: three actual clients, 101 injected directory requests and successful real DataStore directory tests; no application errors and all live fixtures removed.
- `friends-final-results.json`: final failure-path rerun also includes a thrown save exception; actions recover and no transport is attempted. The previously verified live directory test is intentionally not repeated.
- `friends-core-results.json`: two-client gameplay regression passed, including cars, pets, possessions, paint, robbery/recovery, disconnect cleanup, 239 injected persistence requests and live profile save/reload tests.
- `friends-ui-audit.json`: strict static UI audit has zero findings. This does not certify runtime accessibility.
- Actual Studio mouse-input flow: Phone → Friends → Create party → Ready to move → Move party together. Server responses updated the same open panel; Studio travel refusal preserved the party. Close returned to gameplay. Screenshots: `assets/art/friends-party.jpg` and `assets/art/friends-narrow.jpg`.
- A 360 × 480 panel was visually checked for wrapping and internal scrolling; this is not a real mobile-device test. Escape and gamepad B injection were rejected by Roblox's VirtualInput CoreGUI restrictions, so those controls were not runtime-certified. Mouse input produced automation/CoreGUI diagnostics, separate from the error-free automated gameplay test logs.
- Rojo built the updated portable place successfully and `git diff --check` passed. The live Studio edit state has the updated scripts, Play is stopped, and visual fixture attributes are cleared. This feature revision has not been published.

References: [Roblox teleports](https://create.roblox.com/docs/projects/teleport), [reserved servers](https://create.roblox.com/docs/reference/engine/classes/TeleportService/ReserveServerAsync), [invitation prompts](https://create.roblox.com/docs/reference/engine/classes/SocialService), [DataStore cache controls](https://create.roblox.com/docs/reference/engine/classes/DataStoreGetOptions).
