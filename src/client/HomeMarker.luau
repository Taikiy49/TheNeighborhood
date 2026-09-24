local UI=require(script.Parent.UI)
local Marker={}
function Marker.Init(app,screens)
 local player=game.Players.LocalPlayer
 local anchor=UI.New('Part',{Name='MyHomeMarkerAnchor',Anchored=true,CanCollide=false,CanTouch=false,CanQuery=false,Transparency=1,Size=Vector3.one},workspace)
 local badge=UI.New('BillboardGui',{Name='MyHomeMarker',ResetOnSpawn=false,Adornee=anchor,AlwaysOnTop=true,LightInfluence=0,Size=UDim2.fromOffset(156,64),Enabled=false,MaxDistance=0},player.PlayerGui)
 local panel=UI.Panel(badge,UDim2.fromScale(1,1),UDim2.new());panel.BackgroundColor3=UI.Theme.Primary
 local title=UI.Label(panel,'YOUR HOME',UDim2.new(1,-12,0,28),UDim2.fromOffset(6,3),18,UI.Theme.Surface);title.Font=UI.Theme.Display;title.TextXAlignment=Enum.TextXAlignment.Center
 local distance=UI.Label(panel,'',UDim2.new(1,-12,0,24),UDim2.fromOffset(6,31),16,UI.Theme.Surface);distance.TextXAlignment=Enum.TextXAlignment.Center
 Marker.Anchor=anchor;Marker.Badge=badge
 function Marker:Update()
  local state=screens.State;local p=state.HomePosition
  local root=player.Character and player.Character:FindFirstChild('HumanoidRootPart')
  local ready=state.HouseId~=nil and type(p)=='table' and #p==3 and root~=nil
  badge.Enabled=false
  if not ready then return end
  local home=Vector3.new(p[1],p[2],p[3]);local tier=state.Residence and state.Residence.Tier or 1;local floors=require(game.ReplicatedStorage.Neighborhood.Shared.ResidenceDefinitions).Tiers[tier].Floors;anchor.Position=home+Vector3.new(0,math.max(20,floors*12.4+3),0)
  badge:SetAttribute('HouseId',state.HouseId)
  local studs=math.floor((Vector3.new(root.Position.X,home.Y,root.Position.Z)-home).Magnitude+.5)
  distance.Text=studs..' studs away'
  badge.Enabled=studs>35 and app.Enabled and not screens.Panel.Visible
 end
 local elapsed=0
 local connection=game:GetService('RunService').Heartbeat:Connect(function(dt)elapsed+=dt;if elapsed>=.2 then elapsed=0;Marker:Update()end end)
 app.Destroying:Connect(function()connection:Disconnect();badge:Destroy();anchor:Destroy()end)
 return Marker
end
return Marker
