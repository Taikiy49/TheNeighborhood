# A roomier neighborhood

The authored world and home architecture are twice as wide and twice as deep. The ground is 720 × 700 studs; each cottage foundation is 60 × 52 studs and its floor is 56 × 48. Floor area is four times the previous layout. Wall heights, characters, beds, kitchen fixtures, pets and cars retain their normal scale.

Expanded rooms, stairs, streets, plot centers, route markers, clues, gardens, home tours and vehicle parking use the same horizontal coordinate conversion. Interaction distances and walking speed remain unchanged. Doors hinge from their actual width. Theft escape requires leaving the cottage as well as its extensions, preventing a larger indoor distance from counting as an escape.

Saved plot, expansion, furnishing and layout identifiers remain unchanged. This update changes placement, not the profile schema. Live online save/rejoin testing remains pending an authenticated published Studio session.

The one-time migration is tools/enlarge-neighborhood.luau. It refuses repeat expansion. The committed authored asset already contains the expansion; do not apply it again. WorldSpace maps original authored coordinates into the larger world for runtime content.

See qa/spacious-regression.json for the recorded local multiplayer results. This is a development build, not a claim that the entire master specification or production performance certification is complete.

## Verification on September 23, 2026

Eight local multiplayer suites passed: SpaciousAcceptance, BuildingAcceptance, LifeWalkAcceptance, LifeAcceptance, PlotChoiceAcceptance, FoundationAcceptance, AdventureAcceptance and ExplorationAcceptance. Together the explicitly counted routes include 84 physical walking legs. LifeAcceptance also ran 200 progression simulations with 41,276 checks; BuildingAcceptance rejected 4,200 malformed requests; AdventureAcceptance rejected 2,100. FoundationAcceptance exercised driving, pets, doors, theft, escape, evidence and disconnect cleanup. Its persistence checks use an injected storage backend.

UIAcceptance failed its final error-log assertion on Roblox CoreGui CreatorType/module errors in the unpublished PlaceId 0 session. It is not reported as a pass. Real online save/rejoin and public publication remain unverified. The initial spacious boundary fixture used an open door and did not exceed the intended distance; closing the door made the fixture valid. Foundation door-proximity fixtures now use the moving door position and await its closure. The final recorded gameplay reruns pass.

All 87 Studio source scripts match the repository after normalizing line endings. The Rojo development build was rebuilt successfully. Screenshots in the README are actual edit-viewport captures, with older compact-layout images explicitly labeled.
