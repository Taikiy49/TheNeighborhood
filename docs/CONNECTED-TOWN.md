# Connected streets and sports grounds

September 24, 2026. Public buildings now have authored door-to-sidewalk approaches after imported venues reach their final positions. Forty public entrances are covered, plus the library tower approach, school promenade and sports walking loop. Existing house drives, door paths and roads remain.

The routes follow the street grid. Narrow entrance links reach the actual imported floor; wider paving joins the sidewalk or boardwalk. Overlapping rectangles are subtracted before rendering, preventing coplanar path flicker. Approaches avoid the fuel pumps, building corners, a relocated lamp and the timed training equipment. Park grass, playing turf and planted areas remain intentional green space.

The isolated park bowling lane, toy shelf, flower-watering station and small carousel have been retired. The dedicated pier carnival remains. The two timed trials remain beside the school sports grounds with their saved records intact. Their freestanding advertisements are gone; interactions remain nearby. The duplicate park-direction board and beach-ball advertisement are hidden, while functional community, transit and safety signs remain.

## Sports

The school grounds contain an imported basketball court and soccer field with two hoops and two netted goals. Two shared, server-controlled balls support a nearby Kick/Shoot interaction (face the direction to aim), physical movement, match scores, a two-second reset after scoring and an automatic return when a ball leaves its play area. This is informal shared play; there is no team matchmaking or persistent sports league. No cash or paid rewards are attached.

## Creator Store sources

| Imported art | Creator | Asset |
| --- | --- | --- |
| Basketball Court | Ninjas11232 | [10541782424](https://create.roblox.com/store/asset/10541782424) |
| Soccer Field | JackisAmazing223 | [14664980900](https://create.roblox.com/store/asset/14664980900) |
| Textured Soccer ball/Football | P_ristine | [1042510761](https://create.roblox.com/store/asset/1042510761) |
| BasketBall Ball Basketball Team Pass | XxVip3rCod3St3althxX | [89848453017115](https://create.roblox.com/store/asset/89848453017115) |

Assets were retrieved as free Creator Store models. Geometry was normalized and scaled to the sports plots. The soccer model's giant invisible enclosure and duplicate markings were removed. Imported scripts, remotes and interactive components were stripped; custom game-owned code implements interactions. Native RBXM export preserves CSG/mesh art in `assets/SportsArt.rbxm`.

## Verification

See [machine-readable playtest results](qa/town-connections.json) and `tools/test-town-connections.server.luau`. The isolated Studio test checks 40 entrance routes, surface coverage, obstacles, coplanar paving, the full width of the sports promenade, eight actual Humanoid walks, server-owned ball physics, remote interaction rejection, shot cooldowns, score detection, duplicate-score prevention, resets and removal of the four retired stations. Score-crossing checks deliberately place balls across each trigger plane; they do not claim a human played a complete match. Multiplayer load and mobile device performance were not certified in this pass.
