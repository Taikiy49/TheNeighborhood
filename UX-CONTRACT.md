# UI behavior

Canonical owners: Theme (visual tokens), UI (labels/buttons/panels/toast), InteractionController (context prompts), App (screens). Roblox GUI replaces browser semantics; no HTML forms/tables are in scope.

Server requests retain the existing screen during processing; success updates from the server snapshot, failures produce useful text. No optimistic currency or ownership. Buttons remain the same size while pending. Empty inventory/case views explain the next physical action. A close action restores gameplay; controller buttons use Roblox selection. No user-entered public text.

Touch targets at least 48px. HUD respects safe insets and narrow width. Prompt actions work with E, gamepad X and touch through ProximityPrompt. Readability cannot depend on color or sound alone.

## Friends flow

Source: the user's September 23 request to implement friend parties, group travel and saved neighborhoods; server authority lives in FriendsService and NeighborhoodRepository.

| Capability | Canonical owner | Behavior |
|---|---|---|
| Party and circle lists | FriendsScreen via Screens.Row | Bounded membership (eight), saved/incoming index (32), paginated Roblox friends |
| Buttons and text | UI and shared Theme | Existing colors, typography, 48px targets and controller selection |
| Notifications | App Notification listener | Request-correlated feedback; no optimistic membership or save claims |
| Pending state | Screens.Pending | Fixed geometry; Friends stays open on success, unlike purchase screens |
| Scroll | Screens.List | Internal scrolling; retain position on server state refresh |
| Platform invitations | SocialService prompt | Explicit player button, permission checked; unavailable state explained |

An invitation is not consent. Party members accept and then ready up; changing party membership clears readiness. Joining a saved circle requires acceptance, and travel is a separate action. Only the founder may send saved-circle invitations, and recipients must be their Roblox friends. No editable public names or message fields are introduced.

Plot selection is a move-in decision. Party members start on the nearest free plot to the founder and can select an unclaimed alternative before the circle is saved. Changing a plot clears everyone's readiness. Existing party selections cannot be displaced. Saved-circle invitations offer an explicit plot choice or nearest-available assignment; selection and acceptance commit atomically. Once saved, plots remain reserved even for offline members. There is no live relocation or unilateral swap flow. A lost race refreshes available options instead of silently substituting another address. The shared PlotLayout module matches authored house coordinates; tests detect map drift.

Saved circles retain membership and plot assignments, not an offline simulation of every house. Profile possessions and finishes follow each player. Travel failures restore actions and offer retry; a failed save prevents departure. Access codes are server-only. Reserved-server arrivals must match directory membership, independent of client-supplied teleport data.

Roblox GUI is the runtime; browser-only DOM/ARIA, CSS and URL routing rules do not apply. Friends uses the existing non-modal phone panel, Close/Escape/gamepad B, and shared TextButton selection behavior. Touch and keyboard checks must use Roblox, not a browser mockup.

Friends subviews (plot selection and Roblox friend selection) use the fixed header Back button to return to Friends; the Friends root retains Close. Plot selection stays open after success so the chosen address is visible. The parent party roster updates from the server snapshot.
