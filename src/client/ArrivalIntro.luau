local Players=game:GetService("Players")
local Run=game:GetService("RunService")
local UI=require(script.Parent.UI)
local T=UI.Theme
local Intro={Active=false,Considered=false}
function Intro:Finish(markSeen)
 if not self.Active then return end
 self.Active=false
 if self.Connection then self.Connection:Disconnect();self.Connection=nil end
 if self.Death then self.Death:Disconnect();self.Death=nil end
 if self.Respawn then self.Respawn:Disconnect();self.Respawn=nil end
 if self.Keys then self.Keys:Disconnect();self.Keys=nil end
 self.PanelGui:Destroy();self.App.Enabled=self.AppWasEnabled
 game:GetService("ProximityPromptService").Enabled=self.PromptsWereEnabled
 if self.Controls then self.Controls:Enable()end
 local camera=workspace.CurrentCamera
 camera.FieldOfView=self.OldFOV;camera.CameraType=Enum.CameraType.Custom
 local human=Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
 if human then camera.CameraSubject=human end
 local selection=self.OldSelection;if selection and selection.Parent then game:GetService("GuiService").SelectedObject=selection else game:GetService("GuiService").SelectedObject=nil end
 if markSeen then game.ReplicatedStorage.Neighborhood.Remotes.Request:FireServer("IntroDone","")end
end
function Intro:Start(state)
 if self.Active then return end
 local player=Players.LocalPlayer;local house=workspace.Neighborhood.Houses:FindFirstChild(state.HouseId or "")
 local char=player.Character;local human=char and char:FindFirstChildOfClass("Humanoid")
 if not house or not human or human.Health<=0 then return false end
 -- Streamed house models can arrive before their parts; never disable controls until all shots are available.
 if not house:FindFirstChild("Foundation") or not house:FindFirstChild("Door") or not house:FindFirstChild("Arrival") then return false end
 self.Active=true;self.OldFOV=workspace.CurrentCamera.FieldOfView;self.AppWasEnabled=self.App.Enabled;self.App.Enabled=false
 self.PromptsWereEnabled=game:GetService("ProximityPromptService").Enabled;game:GetService("ProximityPromptService").Enabled=false
 local module=player.PlayerScripts:FindFirstChild("PlayerModule")
 if module then local ok,controls=pcall(function()return require(module):GetControls()end);if ok then self.Controls=controls;controls:Disable()end end
 self.OldSelection=game:GetService("GuiService").SelectedObject
 local gui=UI.New("ScreenGui",{Name="ArrivalIntroduction",ResetOnSpawn=false,DisplayOrder=100,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},player.PlayerGui);self.PanelGui=gui
 local panel=UI.Panel(gui,UDim2.new(.94,0,0,184),UDim2.new(.5,0,1,-18));panel.AnchorPoint=Vector2.new(.5,1)
 UI.New("UISizeConstraint",{MaxSize=Vector2.new(640,184)},panel)
 local progress=UI.Label(panel,"",UDim2.new(1,-32,0,20),UDim2.fromOffset(16,10),T.Small,T.Muted)
 local title=UI.Label(panel,"",UDim2.new(1,-32,0,30),UDim2.fromOffset(16,32),T.Title);title.Font=T.Display;title.TextScaled=true
 local body=UI.Label(panel,"",UDim2.new(1,-32,0,56),UDim2.fromOffset(16,66),16);body.TextScaled=true;UI.New("UITextSizeConstraint",{MaxTextSize=18,MinTextSize=12},body)
 local still=state.Settings and state.Settings.ReducedMotion==true
 local index,elapsed=1,0
 local basis=house.Foundation.CFrame
 local compact=house.Foundation.Size.X/90
 local function view(v)return basis:PointToWorldSpace(Vector3.new(v.X*compact,v.Y,v.Z*compact))end
 local shots={
  {Title="This is your home",Text="You start inside your own cottage. The green YOUR HOME marker and your name on the mailbox identify it.",From=view(Vector3.new(20,9,-83)),At=house.Door.Position},
  {Title="Make it yours",Text="Inventory holds your possessions. Inside, approach a display spot to place one. Phone has home upgrades and decorating.",From=view(Vector3.new(-16,7,-66)),At=house.Door.Position+Vector3.new(0,2,0)},
  {Title="Find your next stop",Text="Tall signs at path junctions point to the park, shops, lake and meadow. Phone → Adventures gives you a clear goal.",From=view(Vector3.new(35,22,-105)),At=house.Arrival.Position},
  {Title="Start with your front door",Text="Decorate your home, then try meadow trials for medals, cash and XP. Meet real players and labelled NPC neighbors.",From=view(Vector3.new(0,8,-72)),At=house.Door.Position},
 }
 local nextButton
 local function render()
  elapsed=0;progress.Text="WELCOME TO MAPLE STREET  ·  "..index.." / "..#shots
  title.Text=shots[index].Title;body.Text=shots[index].Text
  nextButton.Text=index==#shots and "Let's play"or "Next"
 end
 UI.Button(panel,"Skip tour",UDim2.new(.28,-12,0,48),UDim2.new(0,12,1,-58),function()self:Finish(true)end)
 local motion
 motion=UI.Button(panel,still and "Animate"or "Still views",UDim2.new(.36,-12,0,48),UDim2.new(.28,6,1,-58),function()still=not still;motion.Text=still and "Animate"or "Still views"end)
 nextButton=UI.Button(panel,"Next",UDim2.new(.36,-18,0,48),UDim2.new(.64,6,1,-58),function()if index==#shots then self:Finish(true)else index+=1;render()end end)
 render();game:GetService("GuiService").SelectedObject=nextButton
 self.Keys=game:GetService("UserInputService").InputBegan:Connect(function(input,processed)if not processed and input.KeyCode==Enum.KeyCode.ButtonB then self:Finish(true)end end)
 self.Death=human.Died:Connect(function()self:Finish(false)end)
 self.Respawn=player.CharacterRemoving:Connect(function()self:Finish(false)end)
 self.Connection=Run.RenderStepped:Connect(function(dt)
  if not self.Active then return end
  elapsed+=dt;local shot=shots[index];local camera=workspace.CurrentCamera;camera.CameraType=Enum.CameraType.Scriptable;camera.FieldOfView=60
  local offset=still and Vector3.zero or basis.RightVector*(math.min(elapsed/6,1)*2-1)
  camera.CFrame=CFrame.lookAt(shot.From+offset,shot.At)
  if elapsed>=7 then if index==#shots then self:Finish(true)else index+=1;render()end end
 end)
 return true
end
function Intro:Consider(state)
 self.State=state
 if self.Considered or state.Settings and state.Settings.IntroSeen then return end
 local RunService=game:GetService("RunService")
 -- Automated gameplay suites opt into the cinematic explicitly; normal play still shows it.
 if RunService:IsStudio()and workspace:GetAttribute("SkipArrivalIntroTest")then return end
 if self:Start(state)then self.Considered=true end
end
function Intro.Init(app)Intro.App=app;return Intro end
return Intro
