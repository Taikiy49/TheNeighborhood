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
local Intro=require(script.Parent.ArrivalIntro).Init(gui)
local requestSequence=0
Screens:Init(gui,function(action,id,argument)
 requestSequence+=1
 if Screens.Pending then Screens.Pending.RequestId=requestSequence end
 remotes.Request:FireServer(action,id,argument,requestSequence)
end)
local plaque=UI.Panel(gui,UDim2.new(1,-144,0,92),UDim2.new(0,12,0,12));plaque.Name='HomePlaque'
UI.New("UISizeConstraint",{MaxSize=Vector2.new(224,92)},plaque)
plaque.BackgroundColor3=Theme.Primary
local title=UI.Label(plaque,"MY HOME",UDim2.new(1,-24,0,20),UDim2.fromOffset(12,10),Theme.Small,Theme.Surface)
local address=UI.Label(plaque,"Finding your home...",UDim2.new(1,-24,0,30),UDim2.fromOffset(12,31),Theme.Title,Theme.Surface); address.Font=Theme.Display
address.TextScaled=true
UI.New("UITextSizeConstraint",{MinTextSize=14,MaxTextSize=24},address)
local cash=UI.Label(plaque,"",UDim2.new(1,-24,0,20),UDim2.fromOffset(12,65),Theme.Small,Theme.Surface)
local HUD=require(script.Parent.GoalHUD).Init(gui,Screens)
require(script.Parent.HomeMarker).Init(gui,Screens)
local hint=HUD.Card
local toast=UI.Panel(gui,UDim2.new(0.85,0,0,64),UDim2.new(0.5,0,0,120)); toast.AnchorPoint=Vector2.new(0.5,0); toast.Visible=false
toast.ZIndex=30
toast:GetPropertyChangedSignal("Visible"):Connect(function()gui:SetAttribute("ToastActive",toast.Visible)end)
UI.New("UISizeConstraint",{MaxSize=Vector2.new(440,64)},toast)
local toastText=UI.Label(toast,"",UDim2.new(1,-24,1,-12),UDim2.fromOffset(12,6),Theme.BodySize)
local notificationVersion=0
Screens.Panel:GetPropertyChangedSignal("Visible"):Connect(function()
 plaque.Visible=not Screens.Panel.Visible
 if Screens.Panel.Visible and toast.Visible then
  Screens:ShowNotice(toastText.Text,toastText.TextColor3==Theme.Text);toast.Visible=false
 end
end)
local function updateHint()HUD:Update()end
local playtest=UI.Label(gui,"PLAYTEST · Progress resets when the server stops",UDim2.new(0.8,0,0,24),UDim2.new(0.1,0,1,-26),12,Theme.Surface)
local recapShown=false
player:GetAttributeChangedSignal("SaveStatus"):Connect(function()if not Screens.State.SessionOnly then playtest.Text="Progress · "..(player:GetAttribute("SaveStatus") or "Loading")end end)
playtest.TextXAlignment=Enum.TextXAlignment.Center
remotes.Notification.OnClientEvent:Connect(function(data)
    if data.RequestId then Screens:Resolve(data.Success,data.RequestId)end
    notificationVersion+=1; local version=notificationVersion
    if Screens.Panel.Visible then
        toast.Visible=false;Screens:ShowNotice(data.Text,data.Success)
    else
        toastText.Text=(data.Success and "✓ " or "! ")..data.Text;toastText.TextColor3=data.Success and Theme.Text or Theme.Danger;toast.Visible=true
    end
    task.delay(4,function()if version==notificationVersion then toast.Visible=false;Screens:ClearNotice()end end)
end)
remotes.State.OnClientEvent:Connect(function(state)
    require(script.Parent.ActivitiesScreen).Update(state)
    Screens.State=state
    if Screens.Panel.Visible and not Screens.Pending and (Screens.CurrentView:sub(1,4)=="Life"or Screens.CurrentView=="Building"or Screens.CurrentView=="Crafting"or Screens.CurrentView=="Furnish"or Screens.CurrentView=="Layouts"or Screens.CurrentView=="Friends"or Screens.CurrentView=="InviteFriends"or Screens.CurrentView=="ChoosePlot")then
        local scroll=Screens.List.CanvasPosition
        local selection=game:GetService("GuiService").SelectedObject
        local rowName=selection and selection.Parent and selection.Parent.Name
        Screens:Open(Screens.CurrentView,Screens.CurrentDetail);Screens.List.CanvasPosition=scroll
        local row=rowName and Screens.List:FindFirstChild(rowName)
        if row then game:GetService("GuiService").SelectedObject=row:FindFirstChildWhichIsA("TextButton")end
    end
    if Screens.Panel.Visible and not Screens.Pending and (Screens.CurrentView=="Yard" or Screens.CurrentView=="Garage" or Screens.CurrentView=="Residence" or Screens.CurrentView=="Activities" or Screens.CurrentView=="Boutique" or Screens.CurrentView=="Weather" or Screens.CurrentView=="Journal" or Screens.CurrentView=="Adventures" or Screens.CurrentView=="Projects")then local scroll=Screens.List.CanvasPosition;local selection=game:GetService("GuiService").SelectedObject;local name=selection and selection.Name;Screens:Open(Screens.CurrentView,Screens.CurrentDetail);Screens.List.CanvasPosition=scroll;if name then game:GetService("GuiService").SelectedObject=Screens.List:FindFirstChild(name,true)end end
    if state.Settings then player:SetAttribute("MusicEnabled",state.Settings.Music~=false);player:SetAttribute("SoundEnabled",state.Settings.Sound);player:SetAttribute("ReducedMotion",state.Settings.ReducedMotion)end
    playtest.Text=state.SessionOnly and "PLAYTEST · Progress resets when the server stops" or "Progress · "..(player:GetAttribute("SaveStatus") or "Loading")
    address.Text=state.Address; cash.Text="$"..tostring(state.Currency).."  •  Your home"
    updateHint()
    Intro:Consider(state)
    if state.Recap and not recapShown then recapShown=true end
end)
local drop=UI.Button(gui,"Set down",UDim2.fromOffset(110,48),UDim2.new(1,-122,0,184),function()remotes.Request:FireServer("Drop","")end)
drop.Visible=player:GetAttribute("Carrying")~=nil
player:GetAttributeChangedSignal("Carrying"):Connect(function()drop.Visible=player:GetAttribute("Carrying")~=nil end)
remotes.View.OnClientEvent:Connect(function(view,detail)Screens:Open(view,detail)end)
remotes.Request:FireServer("Sync")
require(script.Parent.InteractionController).Init(gui)
require(script.Parent.Feedback).Init()
require(script.Parent.CarryPose).Init()
require(script.Parent.VehicleControls)()
require(script.Parent.WeatherView).Init()
player:GetAttributeChangedSignal("DeliveryAddress"):Connect(updateHint)
player:GetAttributeChangedSignal("Carrying"):Connect(updateHint)

player:GetAttributeChangedSignal("AdventureHint"):Connect(updateHint)

require(script.Parent.BackgroundMusic).Init()
