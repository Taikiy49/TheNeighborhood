local Players=game:GetService("Players")
local player=Players.LocalPlayer
local UI=require(script.Parent.UI)
local Theme=UI.Theme
local remotes=game.ReplicatedStorage:WaitForChild("Neighborhood"):WaitForChild("Remotes")
local gui=UI.New("ScreenGui",{Name="NeighborhoodApp",ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},player:WaitForChild("PlayerGui"))
local plaque=UI.Panel(gui,UDim2.new(0,268,0,92),UDim2.new(0,16,0,16))
plaque.BackgroundColor3=Theme.Primary
local title=UI.Label(plaque,"THE NEIGHBORHOOD",UDim2.new(1,-24,0,20),UDim2.fromOffset(12,10),Theme.Small,Theme.Surface)
local address=UI.Label(plaque,"Finding your home...",UDim2.new(1,-24,0,30),UDim2.fromOffset(12,31),Theme.Title,Theme.Surface); address.Font=Theme.Display
local cash=UI.Label(plaque,"",UDim2.new(1,-24,0,20),UDim2.fromOffset(12,65),Theme.Small,Theme.Surface)
local hint=UI.Panel(gui,UDim2.new(0.85,0,0,60),UDim2.new(0.5,0,1,-80)); hint.AnchorPoint=Vector2.new(0.5,0)
UI.New("UISizeConstraint",{MaxSize=Vector2.new(480,60)},hint)
local hintText=UI.Label(hint,"This one's yours. Walk up to your front door.",UDim2.new(1,-24,1,-12),UDim2.fromOffset(12,6),Theme.BodySize)
local toast=UI.Panel(gui,UDim2.new(0.85,0,0,64),UDim2.new(0.5,0,0,120)); toast.AnchorPoint=Vector2.new(0.5,0); toast.Visible=false
UI.New("UISizeConstraint",{MaxSize=Vector2.new(440,64)},toast)
local toastText=UI.Label(toast,"",UDim2.new(1,-24,1,-12),UDim2.fromOffset(12,6),Theme.BodySize)
local notificationVersion=0
remotes.Notification.OnClientEvent:Connect(function(data)
    notificationVersion+=1; local version=notificationVersion
    toastText.Text=data.Text; toastText.TextColor3=data.Success and Theme.Text or Theme.Danger; toast.Visible=true
    task.delay(4,function() if version==notificationVersion then toast.Visible=false end end)
end)
remotes.State.OnClientEvent:Connect(function(state)
    address.Text=state.Address; cash.Text="$"..tostring(state.Currency).."  •  Your home"
end)
remotes.Request:FireServer("Sync")
