# Architecture

`Bootstrap.server.luau` initializes services, loads players and routes requests through `ReplicatedStorage.Neighborhood.Remotes`. The server owns money, possessions, homes, progression and membership. Client actions are checked for type, ownership, distance, state and rate where appropriate.

Client `App`, `Screens`, `FriendsScreen` and `UI` render server snapshots. `Theme` owns visual tokens; `PlotLayout` defines the eight authored plot positions. Clients do not author saved inventory or circle membership.

| Domain | Main server modules |
|---|---|
| Saves | PlayerDataService, ProfileSchema, ProfileRepository |
| Homes | HouseService, CustomizationService |
| Possessions/economy | ItemService, ItemFactory, EconomyService |
| Mischief/investigation | RobberyService, EvidenceService, InvestigationService, ObservationService, PrankService |
| Activities | AdventureService, DeliveryService, DiscoveryService, EventService, ProgressionService, CommunityService |
| Car/pet | VehicleService, PetService |
| Environment | WeatherService, Environment, WorldBuilder, WorldInteractions, WorldPolish |
| Friends | FriendsService, NeighborhoodRepository, PlotLayout |

## Persistence

Profiles are keyed by Roblox user ID. The repository uses UpdateAsync, session-token leases, schema validation, bounded retries and write IDs. Periodic, departure and shutdown saves preserve original item identities and display slots. A sequenced outbox/inbox protects settlements from duplicate delivery and lost acknowledgements. Corrupt/future data and active leases are rejected, not overwritten.

## Saved circles

Circle records hold members, plot numbers, pending invitations and a reserved-server code. Per-user indexes point to saved/pending circles. Codes remain server-only and are omitted from client snapshots and player profiles.

Party members accept and ready up; roster/plot changes clear readiness. Defaults choose the nearest free plot to the founder. Chosen addresses are committed with the circle; later invitation acceptance atomically claims a free plot. Offline members retain reservations.

Travel blocks profile-changing requests, settles carried possessions and saves profiles before departure. The source retains its lease until departure; the destination waits briefly for release. Arrival membership is checked using the actual reserved-server ID, never trusted client teleport data. Save/transport failures restore local actions, and partial departures preserve the retry destination.

The circle persists as membership and plots, not an always-running simulation or offline furnished-house display. See [Friends and neighborhoods](FRIENDS-NEIGHBORHOODS.md).

## World and tests

The authored world is `assets/Neighborhood.model.json`; lighting is in `default.project.json`. Decorative geometry is anchored and excluded from gameplay collision/query/touch where verified. Authoring scripts run in Edit, not every player session. AdventureService creates its six story posts and noticeboard at runtime, then builds each shared park decoration once when that server completes its project. Saved album data lives in player profiles; live route clocks and shared project state do not.

Acceptance scripts exit unless Studio and matching explicit test arguments are present. Visual fixtures require Studio attributes. Live storage tests use separate stores and unique prefixes. GitHub CI builds source; it cannot substitute for Studio simulation or published-client travel tests.
