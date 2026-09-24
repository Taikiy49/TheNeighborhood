---
version: alpha
name: The Neighborhood
description: Suburban address plaques meet playful physical mischief.
colors:
  primary: '#234F46'
  background: '#F4F5EC'
  text: '#20332F'
  muted: '#586962'
  warning: '#C18B28'
  danger: '#B5473C'
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
FredokaOne is reserved for titles; Gotham for readable body/actions. 14/18/24 sizes in the shared runtime theme. No long all-caps paragraphs.

## Layout
8px rhythm, 48px minimum action targets; respect Roblox safe insets. Panels adapt to narrow viewports. Normal HUD remains compact. Scrollable content owns its scroll.

## Elevation & Depth
Solid panels and a restrained outline. No backdrop blur. Houses have deep porches and chunky contrasting window trim.

## Shapes
10px interface corners; architecture relies on pitched roofs and window silhouettes rather than glow.

## Components
Canonical runtime owner: src/shared/Theme.luau → src/client/UI.luau → HUD, prompts, panels and notifications. This document mirrors runtime values (Model B); update both for durable decisions. Actions use TextButton.Activated, selection focus, hover tint and disabled state. Prompts use Roblox input handling with authored presentation. Notifications replace repeated status, no dead buttons. Motion is a short state transition, not perpetual bouncing.

## Do's and Don'ts
- Keep palette coherent across eight varied homes.
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
