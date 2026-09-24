# Current release

Latest: Maple Heights city redesign published as **v85**, confirmed by Studio `PublishSuccessful` at **12:02:58 UTC on September 24, 2026**, followed by `Add publish notes to v85`. Existing place: `111572448337932`. [Districts, screenshots and verification](MAPLE-HEIGHTS.md). Creator Dashboard capacity saved and reloaded as 12; eight actual simultaneous Studio clients tested. No audience/age-eligibility change was made in this release.

## Previous release

Latest: Activities update published as v77, confirmed by Studio at 11:20:06 UTC on September 24, 2026. [Features and tests](ACTIVITIES.md).

## Previous release

Latest: garages and Sunset Cove published as v75, confirmed by Studio at 11:11:22 UTC on September 24, 2026. [Features and tests](GARAGES-AND-COVE.md).

## Previous release

September 24, 2026: side destinations and twelve-home renewal published. Studio reported PublishSuccessful at 11:00:11 UTC and linked notes to v73. [Current features and verification](SIDE-DESTINATIONS.md). Server capacity remains last verified at eight. No audience/age-eligibility change was performed in this release.

# Historical release record

# Release status

Recorded September 23, 2026. This document distinguishes local/source milestones from Roblox publication.

| Item | Status |
|---|---|
| Place | `111572448337932` |
| Universe | `10767699101` |
| Last verified published version | **62** — September 23, 2026 Hawaii time |
| Later environment redesign | Published in version 62 |
| Friends and plot choices | Published in version 62 |
| Public access | Age check Done; publishing eligibility Ages 16+ and trusted friends; experience Private and Unrated (September 23 dashboard check) |
| Style boutique | Two real passes registered; off sale, code published in version 62, live purchase test pending |
| GitHub upload | Source delivery, not a Roblox publication |

Earlier dashboard work saved an icon, Higgsfield cover, description, genre and eight-player limit. The recorded audience was Private. Camera age check, identity verification and two-factor requirements were reported by Roblox at that time; platform requirements/status may change. Do not infer current eligibility from this historical note.

## Verified publication

Studio authentication recovered after restarting and signing in. `Publish to Roblox As` overwrote the existing place; the Studio publication state reached `PublishSuccessful` at 2026-09-24 08:15:40 UTC. The reopened cloud place reports version 62, place 111572448337932 and universe 10767699101. All 92 scripts matched source commit `15b41d6`, with `detail-cleanup-1` present. [Recorded verification](qa/publication-v62.json).

This includes expanded and furnished cottages, the garden district and mountain valley, sign/fixture/roof cleanup and the interaction-hint fix. Publication did not change the Private audience. Actual Roblox-client rejoin and multiplayer persistence of new Building fields still require live verification; prior Studio results are not that verification.

## Earlier account and local build check (historical)

The Creator Dashboard shows the age check complete. Identity verification and two-step verification still show Start. The experience remains Private and Unrated; its maturity/compliance questionnaire is outstanding. Those checks predated the successful version 62 publication above; public access has not been enabled.

Studio then disconnected with Access Denied (RCC-273), with logs reporting 401 User is not authenticated. At that point, home expansions were implemented and tested only in the local Studio build. Publication and authentication are now verified above; real DataStore restart and live synchronization remain unverified for the new fields. Older live persistence evidence does not establish that the new Building fields survive a real restart.

## Release sequence

1. Review the latest build, source diff, specification ledger and test evidence.
2. Confirm ownership/access, eight-player limit, external asset permissions and production store names.
3. Save a recoverable place version and publish the intended source/build to the intended place.
4. Test in actual Roblox clients with authorized accounts: party creation, privacy/invites, reserved travel, partial failures, founder-offline return and cross-server profile restoration.
5. Test target devices, input methods, load and unfamiliar-player onboarding. Fix material failures.
6. Check Creator Dashboard eligibility/access and complete any required human account verification. Choose the intended public audience deliberately.
7. Verify store-page art/copy accurately reflects the build, then monitor errors, saves and player feedback after release.

Do not call the complete specification done: [SPEC-COVERAGE](SPEC-COVERAGE.md) tracks 239 numbered sections. Trading/auctions, deeper social/evidence/world-memory systems, expanded content and other listed work remain partial or open.

## Rollback and storage

Keep prior source commits and Roblox place versions. A place rollback does not roll back DataStores. Do not delete/reset production keys to solve deployment problems. Schema compatibility, asset permissions and datastore changes need explicit review before replacing a live version.

The GitHub build workflow has read-only repository permissions and no Roblox credentials. It cannot publish or change production progress.

Latest QA: [full regression report](QA-FULL-REGRESSION.md). Passing Studio tests does not enable sales or change the public release state.
