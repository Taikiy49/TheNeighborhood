# Release status

Recorded September 23, 2026. This document distinguishes local/source milestones from Roblox publication.

| Item | Status |
|---|---|
| Place | `111572448337932` |
| Universe | `10767699101` |
| Last verified published version | 37 |
| Later environment redesign | In source, Studio edit state and included build; not published |
| Friends and plot choices | In source, Studio edit state and included build; not published |
| Public access | Age check Done; publishing eligibility Ages 16+ and trusted friends; experience Private and Unrated (September 23 dashboard check) |
| Style boutique | Two real passes registered; off sale, code not published, live purchase test pending |
| GitHub upload | Source delivery, not a Roblox publication |

Earlier dashboard work saved an icon, Higgsfield cover, description, genre and eight-player limit. The recorded audience was Private. Camera age check, identity verification and two-factor requirements were reported by Roblox at that time; platform requirements/status may change. Do not infer current eligibility from this historical note.

## Latest account and local build check

The Creator Dashboard shows the age check complete. Identity verification and two-step verification still show Start. The experience remains Private and Unrated; its maturity/compliance questionnaire is outstanding. This does not mean the experience was published or made public.

Studio then disconnected with Access Denied (RCC-273), with logs reporting 401 User is not authenticated. Home expansions are implemented and tested in an unpublished local Studio build. Their real DataStore restart, live synchronization and publication remain unverified until Studio is authenticated again. Older live persistence evidence does not establish that the new Building fields survive a real restart.

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
