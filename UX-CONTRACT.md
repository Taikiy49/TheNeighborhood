# UI behavior

Canonical owners: Theme (visual tokens), UI (labels/buttons/panels/toast), InteractionController (context prompts), App (screens). Roblox GUI replaces browser semantics; no HTML forms/tables are in scope.

Server requests retain the existing screen during processing; success updates from the server snapshot, failures produce useful text. No optimistic currency or ownership. Buttons remain the same size while pending. Empty inventory/case views explain the next physical action. A close action restores gameplay; controller buttons use Roblox selection. No user-entered public text.

Touch targets at least 48px. HUD respects safe insets and narrow width. Prompt actions work with E, gamepad X and touch through ProximityPrompt. Readability cannot depend on color or sound alone.
