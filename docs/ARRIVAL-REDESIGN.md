# Clear entrances and arrival

Implemented in source and Studio; this revision has not been verified as published. Last verified Roblox publication remains version 62.

Each of the eight cottage fronts now has one 6.4 × 9.5-stud door. Two stacked panels replace the three repeated columns. Matching wall infill closes the excess opening, the bell and lock sit beside the frame, and recoloring follows the home finish. Room sizes and saved plot coordinates are unchanged.

Two tall, double-sided directories mark the north and south junctions. Existing district signs are raised three studs with lengthened supports. Story clues and festival trail labels stand on proper above-ground posts; their interactions remain available. This is a targeted wayfinding cleanup, not a claim that every decorative label has been removed.

A four-scene, 28-second introduction uses gentle RPG-style camera movement and the existing interface palette. Skip, Next and Still views are always available. Reduced Motion starts with still shots. Completion, skipping and character removal restore the camera, controls, prompts and HUD. Dismissal is saved as Settings.IntroSeen; replay is available from Phone. The ordinary HUD now follows the first unfinished getting-started objective.

## Verification

- Eight doors opened/closed with correct collision changes.
- The test avatar physically entered and exited all eight homes: 16 walking legs. An initial attempt seated the avatar in a nearby test car; removing that fixture and unseating the avatar allowed the complete pass.
- Introduction replay, exit cleanup, still-camera behavior and three 48px actions at a 360px-wide phone layout passed in Studio.
- The final 28-second camera sequence automatically completed and restored the normal HUD and camera. All ten story/trail signs passed the minimum above-ground face-height check.
- The server received IntroDone; its flag survived profile serialization/migration, and new profiles remain unseen. These checks used isolated session profiles, not production DataStores or a live rejoin.
- Strict UI static audit passed. Rojo build passed.

The previous road/recreation additions remain a separate unfinished verification effort: 100 stations use ten shared mechanics. They are not 100 distinct gameplay systems, and their full multiplayer acceptance has not passed. Do not describe that work as a verified release.

Runtime owners: ArrivalPolish runs before HouseService initialization; ArrivalIntro is coordinated by App and replayed through Screens. Source model data stays reproducible through these idempotent startup passes.
