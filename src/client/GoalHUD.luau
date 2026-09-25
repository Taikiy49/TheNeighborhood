local UI=require(script.Parent.UI)
local Guide=require(script.Parent.TaskGuide)
local H={}
function H.Init(gui,screens)
 local player=game.Players.LocalPlayer
 H.Gui=gui;H.Screens=screens
 local card=UI.Panel(gui,UDim2.fromOffset(280,224),UDim2.fromOffset(12,110));card.Name='NavigationHint';H.Card=card
 H.Eyebrow=UI.Label(card,'NEXT UP',UDim2.new(1,-78,0,20),UDim2.fromOffset(12,8),16,UI.Theme.Muted)
 H.Hidden=false
 UI.Button(card,'Hide',UDim2.fromOffset(60,48),UDim2.new(1,-64,0,0),function()H.Hidden=true;card.Visible=false end)
 H.Title=UI.Label(card,'Getting ready…',UDim2.new(1,-82,0,48),UDim2.fromOffset(12,30),20);H.Title.Font=UI.Theme.Display
 H.Hint=UI.Label(card,'Your goals will appear here.',UDim2.new(1,-24,0,42),UDim2.fromOffset(12,78),16)
 H.Bar=UI.Progress(card,UDim2.new(1,-24,0,40),UDim2.fromOffset(12,124))
 H.Action=UI.Button(card,'Please wait',UDim2.new(1,-24,0,48),UDim2.new(0,12,1,-56),function()
  local task=Guide:Pick(screens.State,Guide:Attributes(player))
  if task.Loading then return end
  if task.View then screens:Open(task.View,task.Detail)elseif not Guide:Show(task,screens.State,player)then screens:Open('Activities','Tasks')end
 end)
 local nav=UI.New('Frame',{Name='HUDNavigation',Size=UDim2.fromOffset(108,160),Position=UDim2.new(1,-120,0,12),BackgroundTransparency=1},gui);H.Nav=nav
 for i,entry in ipairs({{'Goals','Activities'},{'Bag','Inventory'},{'Menu','Phone'}})do
  local b=UI.Button(nav,entry[1],UDim2.fromOffset(108,48),UDim2.fromOffset(0,(i-1)*56),function()if i==1 then H.Hidden=false end;screens.ReturnFocus=nav:FindFirstChild(entry[1]..'Button');if screens.Panel.Visible then screens:Close()else screens:Open(entry[2])end end)
  if i==1 then b.BackgroundColor3=UI.Theme.Accent;b.TextColor3=UI.Theme.Text end
 end
 function H:Layout(width,height)
  local landscape=height<440 and width>=600
  self.Card.Size=UDim2.fromOffset(landscape and math.min(280,width-384)or math.min(280,width-140),224)
  self.Card.Position=UDim2.fromOffset(landscape and 250 or 12,landscape and 12 or 110)
 end
 local function visibility()
  card.Visible=not H.Hidden and not screens.Panel.Visible and not gui:GetAttribute('InteractionActive') and not gui:GetAttribute('ToastActive')
  nav.Visible=not screens.Panel.Visible
 end
 screens.Panel:GetPropertyChangedSignal('Visible'):Connect(visibility)
 gui:GetAttributeChangedSignal('InteractionActive'):Connect(visibility)
 gui:GetAttributeChangedSignal('ToastActive'):Connect(visibility)
 local camera=workspace.CurrentCamera
 local function layout()H:Layout(camera.ViewportSize.X,camera.ViewportSize.Y)end
 camera:GetPropertyChangedSignal('ViewportSize'):Connect(layout);layout();visibility()
 local elapsed=0
 game:GetService('RunService').Heartbeat:Connect(function(dt)elapsed+=dt;if elapsed<.25 then return end;elapsed=0;H:Update()end)
 return H
end
function H:Update()
 local player=game.Players.LocalPlayer;local task=Guide:Pick(self.Screens.State,Guide:Attributes(player));self.Task=task
 self.Title.Text=task.Title;self.Hint.Text=task.Hint;self.Action.Text=task.Button or 'Show me';self.Action.Active=not task.Loading
 self.Bar.Frame.Visible=task.Total~=nil
 if task.Total then self.Bar:Set(task.Count or 0,task.Total,task.ProgressLabel or (task.Count or 0)..' / '..task.Total..' complete')end
 if Guide.Marker then
  local position=Guide:Position(task,self.Screens.State,player)
  if not position then Guide:ClearMarker()
  elseif Guide.MarkerKey~=task.Key or Guide.MarkerTitle~=task.Title then Guide:Show(task,self.Screens.State,player)
  else Guide.Marker.Position=position end
 end
end
return H
