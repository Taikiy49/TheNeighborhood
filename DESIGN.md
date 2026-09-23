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
    borderRadius: '10px'
  panel:
    borderRadius: '10px'
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
