# Testing and evidence

## Run Studio acceptance tests

Open the current build in Studio, stop ordinary Play, and run the following in the Edit command bar (or through Studio MCP):

```lua
local result = game:GetService("StudioTestService"):ExecuteMultiplayerTestAsync(
    3, {Name = "PlotChoiceAcceptance"}
)
print(game:GetService("HttpService"):JSONEncode(result))
```

Run one session at a time. Inspect `Passed`, `Errors`, fixture-cleanup results and Output. Live-storage tests require Studio API access. Automated profiles are memory-isolated; real DataStore tests use separate GUID-prefixed fixtures. Never point fixtures at production profile keys.

| Test name | Clients | Scope |
|---|---:|---|
| BuildingAcceptance | 2 | Four expansions, crafting, 14 display spots, 15 furnishings, 22 physical walking legs, layouts and cleanup |
| BuildingCapacity | 8 | Same building contracts with all eight homes expanded and furnished |
| AdventureAcceptance | 2 | Six rumor trails, actual walks, checkpoint replays, shared park projects, trophies and saved album |
| FoundationAcceptance | 2 | Purchases, possessions, locks, theft/recovery, activities, car/pet, persistence |
| ArtAcceptance | 2 | Decoration constraints and 23 navigation routes |
| CapacityAcceptance | 8 | Independent homes/profiles, cars, pets, rain and server timing |
| FriendsAcceptance | 3 | Consent, readiness, directory, travel failures and partial departure |
| PlotChoiceAcceptance | 3 | Nearby defaults, choices, conflicts, saved plots and live directory storage |
| ExplorationAcceptance | 2 | Deliveries, discoveries, collection and weather |
| NetworkAcceptance | 2 | Remote/input adversarial probes and client lifecycle |
| LifecycleStress | 2 | Item lifecycle and invalid-transition stress |
| DisconnectRaceAcceptance | 2 | Departing-player races |
| BoutiqueRegression | 2 | Ownership outage/cancellation/race, 600 style equips, 800 invalid requests |
| UIAcceptance | 2 | 24 main screens plus four detail states at two panel widths on both clients (112 checks) |
| StorageStress | 1 | 20 seeded storage simulations, 5,000 settlement/spending cycles |

`FriendsAcceptance` accepts `SkipLiveDirectory=true` when the live-directory portion has already been verified separately. This skips that portion honestly; it does not count as a new live-storage pass.

## Latest expansion verification

[Home expansion QA](QA-HOME-EXPANSIONS.md) records the latest building, capacity, UI and regression checks. The local unpublished build cannot verify live Roblox storage; those results explicitly report Skipped and Passed=false inside the live-storage subsection. A surrounding gameplay pass is not a live-storage pass.

[Maple Adventures QA](QA-ADVENTURES.md) retains the preceding story/project and real restart evidence.

## Previous full regression

See [full QA report](QA-FULL-REGRESSION.md) and [machine-readable results](qa/full-regression-results.json). Earlier records below remain historical evidence. `tools/run-studio-suites.luau` reproduces all 15 named suites sequentially; real stop/rejoin is a separate two-phase procedure.

## Current evidence

| Evidence | Recorded outcome |
|---|---|
| [Plot choice](plot-choice-results.json) | Passed; three clients, 56 nearest-choice steps, reverse arrivals, conflicts and chosen-plot DataStore reload |
| [Friends regression after plot changes](plot-friends-regression.json) | Passed; transport mocked, directory live checks covered separately |
| [Friends live directory](friends-acceptance-results.json) | Passed; real fixture create/invite/accept/reload/decline, cleanup succeeded |
| [Friends final failure paths](friends-final-results.json) | Passed; save failure/exception and transport recovery |
| [Core gameplay](friends-core-results.json) | Passed; two clients, 239 injected storage requests and actual profile fixture tests |
| [Art navigation](garden-navigation-results.json) | Passed; 23 routes, 1,812 decorative parts, 320 siding textures, 104 mesh parts |
| [Garden capacity](garden-capacity-results.json) | Functional pass; local server mean ~16.7 ms, p95 ~18.1 ms |

Earlier capacity runs had materially worse spikes. One favorable local run is not a mobile or production performance pass. Tests do not prove that unfamiliar players find the game clear or fun.

## UI and assets

Actual Studio mouse input exercised Phone → Friends → create party → ready → travel refusal, plus plot choice and Back navigation. Narrow panel wrapping/scrolling was inspected; a narrow panel is not a real mobile device. VirtualInput rejected Escape/gamepad B injection as CoreGUI-bound, so those controls remain uncertified. Asset preload tests succeeded for the actual tree MeshPart instances and images.

## GitHub CI

`python tools/check_repository.py` checks required files, parses JSON and validates local links in every Markdown guide. CI also builds with Rojo 7.7.0 and uploads the result as an artifact. It does not run Studio, teleport players or publish the experience.

## Still required

Published-client teleports and lease handoff; invitation/privacy/cross-play behavior with real accounts; founder-offline return; adverse network/partial travel in Roblox clients; real touch/controller testing; device performance; production-scale budgets; human usability/fun testing. See [Release status](RELEASE.md).
