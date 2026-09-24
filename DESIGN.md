---
version: alpha
name: The Neighborhood
description: Earn, build a home and belong to a lively neighborhood.
colors:
  primary: '#234F46'
  background: '#F4F5EC'
  text: '#20332F'
  muted: '#586962'
  warning: '#C18B28'
  danger: '#B5473C'
  track: '#D7E3DD'
  accent: '#F8CC5B'
typography:
  display:
    fontFamily: 'Fredoka One'
  body:
    fontFamily: 'Gotham'
rounded:
  DEFAULT: '10px'
spacing:
  unit: '8px'
  control: '48px'
components:
  button:
    rounded: '10px'
  panel:
    rounded: '10px'
---

## Overview
Product game HUD for Roblox players on desktop, touch and controller; English seed copy from the user brief, no inferred regional market. Signature: a compact street-address plaque shows your home. The world dominates the frame. No simulator button wall, purple gradients, or fake app buttons.

## Colors
Dark teal signs, off-white UI surfaces, dark readable text. Amber indicates risk and red denotes incidents. Labels accompany color.

## Typography
FredokaOne is reserved for titles; Gotham for readable body/actions, with bold row headings. 16/18/24 sizes in the shared runtime theme. No long all-caps paragraphs.

## Layout
8px rhythm, 48px minimum action targets; respect Roblox safe insets. Panels adapt to narrow viewports. Normal HUD remains compact. Scrollable content owns its scroll.

## Elevation & Depth
Solid panels and a restrained outline. No backdrop blur. Houses have deep porches and chunky contrasting window trim.

## Shapes
10px interface corners; architecture relies on pitched roofs and window silhouettes rather than glow.

## Components
Canonical runtime owner: src/shared/Theme.luau → src/client/UI.luau → HUD, prompts, panels and notifications. This document mirrors runtime values (Model B); update both for durable decisions. Actions use TextButton.Activated, selection focus, hover tint and disabled state. Prompts use Roblox input handling with authored presentation. Notifications replace repeated status, no dead buttons. Motion is a short state transition, not perpetual bouncing.

## Do's and Don'ts
- Keep palette coherent across twelve varied homes.
- Make ownership and risk readable in world space.
- Never put implementation jargon in ordinary player UI.
- Never imply unsaved data is persisted.

## Home expansion language

Garden rooms use glazed walls, cream structural trim, timber flooring and slate pitched roofs. A return staircase makes the upstairs a physical destination. The garage and backyard studio share the cottage's warm materials. Small furnishing rugs mark intentional placement areas while leaving circulation routes open. Phone building menus retain the canonical Theme → UI → Screens path and existing typography; no parallel control system or new HUD button wall is introduced.

## Neighborhood Life extension

Garden beds use painted timber, soil, small radial flowers and slate stepping stones inside the original side fence. The business counter uses alternating cream/accent awning strips. North-plaza pavilions use timber decks, cream posts and slate pitched roofs; restoration stages visibly add walls and roof. Seasonal signs reuse the four authored palettes. All new screens remain inside the existing phone panel and retain its 48px actions and reserved notification space.

## Clean cottage interiors

Use quiet sage cabinetry (#779387), oak joinery (#B1916B), pale walls (#E5E9E3), ivory trim (#F7F7EE), linen (#D5D6C5) and ink hardware (#364642). Signature: a fitted sage kitchen with a continuous oak shelf, matched to a window-side sitting nook and two botanical prints above the bed. No generated photographic textures inside the cottage. Thin wall liners separate outside paint from inside finishes. Repeated cabinet modules, level trim and subtle geometric floor joints replace scaled-up grain and busy decoration. Five low-output ceiling fixtures distribute warm light without washing out the walls.

Authoring owner: tools/clean-interiors.luau → assets/Neighborhood.model.json. Two mirrored plans retain the six saved display targets and generous central circulation. Furniture is at avatar scale. The rear lining hides with garden-room expansion and restores when the home is released; expansion connector walls retain the quiet interior finish. CustomizationService owns floor-joint visibility, hiding those details when another flooring style is equipped. UI tokens and interaction owners remain unchanged.

## Garden district expansion

Current world owner: WorldSpace.Scale = 3; authored ground 1440 × 1200, cottage foundations 90 × 78, floors 84 × 72, cottage height factor 1.3. Keep furniture, collectible pads and guides at useful avatar scale. Preserve the saved plot and cell identifiers.

The landscape uses a consistent pale-stone path, dark teal roof/hardware and muted green canopy palette. Connected promenades serve Willow Lake, Picnic Meadow, Maple Orchard and the market. The lake is a shallow ornamental landscape feature, with non-overlapping built-in geometry. Road lanes stay 36 studs wide. Sidewalks, street tree verges and crossings are distinct. Native seats support gathering in the meadow and by the water. No imported tree meshes or generated siding textures remain in the authored district scenery.

Authoring owners: expand-map-v3 and raise-cottage-roofs are one-time migrations; clean-interiors and beautify-district rebuild their own design systems. LightingPolicy and Environment own indoor/day-night/outage behavior, including fixtures created after startup. Indoor fixtures remain on during daytime; outdoor lights follow the evening cycle.

The neighborhood is enclosed by a persistent valley backdrop: 3,600 × 3,400 total footprint, layered granite ridges and grass foothills. Keep this separate from plot coordinate scaling. Rebuild with tools/build-valley.luau; preserve ModelStreamingMode when exporting.

Furnished cottage pass: use grouped dining/living furniture, restrained sage/oak/linen materials, wall-side storage and repeated stone-edged planting. Higgsfield concept provenance and scope are in docs/FURNISHED-COTTAGES.md. Authoring tool: tools/furnish-cottages.luau. All saved display slots must stay reachable; FurnishingAcceptance covers 48 routes and usable seats.

## Close-up detail standards

Arrival revision: one 6.4-stud front door per cottage, two vertically stacked panels, wall infill and one handle per face. Enlarging rooms must not enlarge doors, furniture or interaction controls. Destination signage is upright, supported, and concentrated at junctions; nearby activity plaques are secondary. ArrivalIntro reuses Theme → UI primitives in a 184px bottom dialogue panel with 48px Skip/Still views/Next actions. Four seven-second RPG camera views introduce the home and first objective; ReducedMotion uses still shots. Skip, finish and respawn restore camera, prompts and controls. Settings.IntroSeen persists dismissal; Phone can replay the introduction.

Authoring owner: tools/detail-cleanup.luau, run after the earlier world/interior/furnishing rebuilds, then export. Signs use proportional pixels-per-stud canvases, 5% horizontal and 8% vertical margins, restrained copy and supports behind their text planes. Shop lettering sits ahead of the awning; cottage numbers face outward from the porch fascia. Lamp mounts, shades and lenses form connected stacks. Roof halves meet at a ridge cap. Expansion stairs and pendants have visible support, with noncolliding detail parts. Quiet door panels remain attached to the moving door's SurfaceGui.

HUD owner remains App + InteractionController through UI/Theme: NavigationHint is hidden during an active interaction or open panel and restored when both close. InteractionCard sits 32px above the bottom edge, preserving 48px actions. UIAcceptance checks the actual controls at phone-sized layout fixtures. Audit evidence and known limits: docs/VISUAL-DETAIL-AUDIT.md.

## Goals and readable play

The current UI is for younger readers as well as older players. Preserve the street-sign identity, but show one next action instead of a list of systems. Signature: the NEXT UP card connects a short instruction to a visible destination marker. Goals, Bag and Menu are the three main HUD buttons. A warm yellow Goals button makes the starting point distinct without a screen full of competing colors.

Theme remains the runtime token owner (Model B). Theme.Track (#D7E3DD) and Theme.Primary form every shared UI.Progress meter; Theme.Accent (#F8CC5B) marks the active Goals tab and controller focus. Bars always pair with numbers or completion words. UI.Button owns the selection outline and disabled-handler guard. Screens.Row owns 16px body copy, bold headings and 48px actions. GoalHUD owns responsive task placement; TaskGuide owns task selection and local waypoint markers. Memory uses named shapes, so recognizing a symbol does not require reading a long word.

The introductory tour uses short sentences and waits for Next; Skip and reduced-motion still views remain available. This supersedes the historical auto-advance behavior above. Current world geometry is the Maple Heights release documented in docs/MAPLE-HEIGHTS.md; older expansion/valley sections above are historical design records.


## Housing progression
Four silhouettes grow vertically on one plot: cottage, townhouse, family residence, skyline residence. A stone apron replaces the raised lawn under foundations. Furnished floors, a readable lobby housing desk and private home marker explain ownership and progression. Mischief is an optional activity. See docs/RESIDENCES.md.

## Current coastal town and dismissible menus

The coastal district geometry in docs/COASTAL-WORLD.md supersedes the historical scale/valley layouts above. Personal side gardens reserve six front decorating spaces and a rear growing/workshop area. Use cream low fences, stone paths, oak furniture and muted planting; keep trees outside placement bounds. TownLifeExpansion adds small furnished venues, varied canopy heights, controlled traffic and a three-stop coastal tram. See docs/TOWN-LIFE.md.

GoalHUD is now the sole visibility owner of NEXT UP; its 48px Hide action persists for the session until Goals restores it. Screens owns one fixed Close header in every view, Escape/controller-B dismissal and right docking on wide screens. Subview Back actions live in the scrolling content. Panels remain bounded and scrollable on small screens. ArrivalIntro is opt-in from Help, with Close tour and still views. This supersedes automatic introduction and competing App/GoalHUD visibility behavior. Theme → UI remains the only token path; no token migration or new raw UI palette.

YardScreen and VehicleScreen use Screens.Row/UI.Progress and explicit empty, locked, price, owned and pending states. A server update refreshes an open menu but never reopens a closed one. Purchases and resale require server confirmation; vehicle transactions additionally use a price review. Verification: docs/town-ui-results.json and docs/TOWN-LIFE.md. Narrow panel fixtures are not physical-device certification.
