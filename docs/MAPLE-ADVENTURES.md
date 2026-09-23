# Maple Adventures

An expansion built around the specification's curiosity, neighborhood stories, collections and shared world changes. Everything is available permanently; there are no login streaks, paid shortcuts or expiring story rewards.

## Play

Open **Phone → Maple Adventures**, or use the green board beside the north entrance. Pick one of six rumors, then walk to the story posts described by each clue. Read three chapters to earn the ending in your album. The HUD carries the current clue while you walk.

| Story | Premise |
|---|---|
| The Great Teaspoon Heist | A missing spoon has a much smaller purpose. |
| The Biscuit Bandit | Investigate an unusually edible evidence trail. |
| Midnight on Maple FM | Find the source of a doorbell-only radio station. |
| The Invisible Parade | Track down a flamingo's ambitious public event. |
| The Book That Borrowed You | Correct a rather personal library clerical error. |
| Operation Moon Cheese | Follow a gnome space program with modest ambitions. |

Each first ending awards $90 and 30 XP, in addition to ordinary activity XP. Replays award no further first-completion cash; they contribute to the park and track personal bests. There is no time limit. Only an uninterrupted run can set a best time. Pause whenever you like; chapters persist across saving and rejoining. Death or interrupted movement pauses the trail. Resume on foot, with your hands free, from the phone.

The album keeps all six endings, completion counts and best times. Abandoning an unfinished run never removes earned stamps or rewards.

## Build the park together

Completed parcel deliveries, finished rumor trails, newly discovered gnome notes and earned community-event rewards contribute toward three shared improvements at the shop end of Maple Green:

1. Flower beds (six contributions).
2. A little free library (six more).
3. Warm garden lanterns (six more).

Players pool their contributions automatically. A solo player can complete all three. These are visible decorative improvements, not donation payments or purchasable boosts. The library is a visual park feature, not a player-written book editor.

**The park build is scoped to the running server.** Its state is not a cross-server saved neighborhood construction system. Personal lifetime contributions, story progress and trophy receipts persist with the player's profile, even after all three server projects are finished.

## Earned possessions

| Trophy | Requirement |
|---|---|
| Curiosity Compass | Finish one different rumor. |
| Maple Story Owl | Finish all six rumors. |
| Good Neighbor Lantern | Make 12 lifetime contributions. |

Claim each trophy once from Adventures or Projects. A full inventory defers the claim without losing eligibility. Trophies can be displayed, stored, stolen/recovered or sold through the normal possession systems. Selling does not reset the claim receipt. The collection book remembers them. They cannot be bought from the ordinary shop.

## Implementation

`AdventureDefinitions` contains the authored story routes, landmarks and rewards. `AdventureService` creates the board/posts, owns chapter validation and rewards, samples travel, builds park improvements and exposes snapshots. `AdventureScreen` renders Adventures and Projects through the existing responsive screen components.

The server checks profile availability, character life, seating/carrying state, exact authored marker identity, distance, line of sight and chapter order. Travel sampling rejects obvious position jumps and pauses the run; it is not a universal anti-cheat guarantee. A two-second server contribution debounce prevents closely repeated activity signals from counting repeatedly. No client can submit its own completion, time, contribution total or cash amount.

New `Adventures` fields are backward-compatible defaults in the existing version-two profile schema. Migration validates route IDs, chapter bounds, counters, best times and reward receipts. The active checkpoint is saved, while the live stopwatch is deliberately session-only.

## Verification

Run `AdventureAcceptance` with two Studio clients using the procedure in [Testing](TESTING.md). It covers physical walking, rewards, malformed actions, interruptions, checkpoint replays, project geometry, full inventories, trophy exclusivity, profile closing/death and an isolated real DataStore reload. `UIAcceptance` includes both new screens; repository fault tests also retain the new album across release/reload.

See [expansion QA results](QA-ADVENTURES.md) for executed results and remaining checks. Authored content is finite: six stories and three projects do not establish long-term retention. Player feedback and further authored episodes are still needed.
