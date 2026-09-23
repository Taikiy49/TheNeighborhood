local Players=game:GetService("Players")
local player=Players.LocalPlayer
-- Roblox's default player list covers touch actions on narrow device viewports.
-- Player reporting and chat remain available in the platform menu.
game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList,false)
local UI=require(script.Parent.UI)
local Theme=UI.Theme
local remotes=game.ReplicatedStorage:WaitForChild("Neighborhood"):WaitForChild("Remotes")
local gui=UI.New("ScreenGui",{Name="NeighborhoodApp",ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},player:WaitForChild("PlayerGui"))
local Screens=require(script.Parent.Screens)
Screens:Init(gui,function(...) remotes.Request:FireServer(...) end)
local plaque=UI.Panel(gui,UDim2.new(0.58,-24,0,92),UDim2.new(0,16,0,16))
UI.New("UISizeConstraint",{MaxSize=Vector2.new(268,92)},plaque)
plaque.BackgroundColor3=Theme.Primary
local title=UI.Label(plaque,"THE NEIGHBORHOOD",UDim2.new(1,-24,0,20),UDim2.fromOffset(12,10),Theme.Small,Theme.Surface)
local address=UI.Label(plaque,"Finding your home...",UDim2.new(1,-24,0,30),UDim2.fromOffset(12,31),Theme.Title,Theme.Surface); address.Font=Theme.Display
address.TextScaled=true
UI.New("UITextSizeConstraint",{MinTextSize=14,MaxTextSize=24},address)
local cash=UI.Label(plaque,"",UDim2.new(1,-24,0,20),UDim2.fromOffset(12,65),Theme.Small,Theme.Surface)
local hint=UI.Panel(gui,UDim2.new(0.85,0,0,60),UDim2.new(0.5,0,1,-80)); hint.AnchorPoint=Vector2.new(0.5,0)
UI.New("UISizeConstraint",{MaxSize=Vector2.new(480,60)},hint)
local hintText=UI.Label(hint,"This one's yours. Walk up to your front door.",UDim2.new(1,-24,1,-12),UDim2.fromOffset(12,6),Theme.BodySize)
local toast=UI.Panel(gui,UDim2.new(0.85,0,0,64),UDim2.new(0.5,0,0,120)); toast.AnchorPoint=Vector2.new(0.5,0); toast.Visible=false
toast.ZIndex=30
UI.New("UISizeConstraint",{MaxSize=Vector2.new(440,64)},toast)
local toastText=UI.Label(toast,"",UDim2.new(1,-24,1,-12),UDim2.fromOffset(12,6),Theme.BodySize)
local notificationVersion=0
local function updateHint()
 local destination=player:GetAttribute("DeliveryAddress")
 local carrying=player:GetAttribute("Carrying")
 hintText.Text=carrying and ("Carrying "..carrying.." · Reach the street, then the pawn shop.") or destination and ("Parcel delivery → "..destination.." mailbox") or "Visit a display spot inside to place your starter furniture."
end
local playtest=UI.Label(gui,"PLAYTEST · Progress resets when the server stops",UDim2.new(0.8,0,0,24),UDim2.new(0.1,0,1,-26),12,Theme.Surface)
playtest.TextXAlignment=Enum.TextXAlignment.Center
remotes.Notification.OnClientEvent:Connect(function(data)
    Screens:Resolve(data.Success)
    notificationVersion+=1; local version=notificationVersion
    toastText.Text=data.Text; toastText.TextColor3=data.Success and Theme.Text or Theme.Danger; toast.Visible=true
    task.delay(4,function() if version==notificationVersion then toast.Visible=false end end)
end)
remotes.State.OnClientEvent:Connect(function(state)
    Screens.State=state
    address.Text=state.Address; cash.Text="$"..tostring(state.Currency).."  •  Your home"
    updateHint()
end)
UI.Button(gui,"Inventory",UDim2.fromOffset(110,48),UDim2.new(1,-126,0,16),function()Screens:Open("Inventory")end)
UI.Button(gui,"Cases",UDim2.fromOffset(110,48),UDim2.new(1,-126,0,72),function()Screens:Open("Cases")end)
remotes.View.OnClientEvent:Connect(function(view,detail)Screens:Open(view,detail)end)
remotes.Request:FireServer("Sync")
require(script.Parent.InteractionController).Init(gui)
require(script.Parent.Feedback).Init()
player:GetAttributeChangedSignal("DeliveryAddress"):Connect(updateHint)
player:GetAttributeChangedSignal("Carrying"):Connect(updateHint)
