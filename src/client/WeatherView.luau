local Service={}
function Service.Init()
 local player=game.Players.LocalPlayer;local world=workspace:WaitForChild("Neighborhood")
 local folder=Instance.new("Folder");folder.Name="LocalRain";folder.Parent=workspace.CurrentCamera
 local drops={};local random=Random.new()
 for _=1,40 do
  local part=Instance.new("Part");part.Name="Drop";part.Size=Vector3.new(0.035,0.85,0.035);part.Color=Color3.fromRGB(179,208,214);part.Transparency=1;part.Anchored=true;part.CanCollide=false;part.CanQuery=false;part.CanTouch=false;part.CastShadow=false;part.Parent=folder
  table.insert(drops,{Part=part,Offset=Vector3.new(random:NextNumber(-16,16),random:NextNumber(0,18),random:NextNumber(-16,16))})
 end
 local lastProbe=0;local sheltered=true;local elapsed=0;local lastActive=nil
 game:GetService("RunService").Heartbeat:Connect(function(dt)
  elapsed+=dt;if elapsed<0.05 then return end;dt=math.min(elapsed,0.2);elapsed=0
  local character=player.Character;local root=character and character:FindFirstChild("HumanoidRootPart")
  if root and os.clock()-lastProbe>0.2 then
   lastProbe=os.clock();local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Exclude;ray.FilterDescendantsInstances={character,folder}
   sheltered=workspace:Raycast(root.Position,Vector3.new(0,80,0),ray)~=nil
  end
  local active=root~=nil and world:GetAttribute("Weather")=="Rain" and not sheltered and not player:GetAttribute("ReducedMotion")
  if active~=lastActive then lastActive=active;for _,drop in ipairs(drops)do drop.Part.Transparency=active and 0.45 or 1 end end
  if active then for _,drop in ipairs(drops)do
   local offset=drop.Offset-Vector3.new(0,38*dt,0)
   if offset.Y<0 then offset=Vector3.new(random:NextNumber(-16,16),18,random:NextNumber(-16,16))end
   drop.Offset=offset;drop.Part.Position=root.Position+offset
  end end
 end)
end
return Service
