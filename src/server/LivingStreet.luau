local S={Walkers={}}
local residents={
 {"Jo","Gardener",Color3.fromRGB(138,162,106),"I'm planting the beds by the path. Your front door is just behind you; the green is across the street."},
 {"Theo","Lake walker",Color3.fromRGB(192,145,109),"I'm taking the scenic route. The lake path starts on the west side of the neighborhood."},
 {"Rae","Market regular",Color3.fromRGB(128,155,177),"The shops are at the south end of the street. You can earn spending money delivering parcels from the post board."},
 {"Mina","Picnic planner",Color3.fromRGB(179,145,167),"I saved a spot in the meadow. Head east from the green for a picnic, or visit a playfield for free activities."},
}
function S:Build(w)
 local old=w:FindFirstChild("LivingStreet");if old then old:Destroy()end
 local root=Instance.new("Folder");root.Name="LivingStreet";root.Parent=w
 self.Walkers={}
 local template=w.GuideCharacters.Mabel
 local homes=w.Houses:GetChildren();table.sort(homes,function(a,b)return a.Name<b.Name end)
 for i,h in ipairs(homes)do
  local d=residents[(i-1)%#residents+1];local b=h.Foundation.CFrame
  local model=template:Clone();model.Name=d[1]..i;model.Parent=root
  local origin=b:PointToWorldSpace(Vector3.new(12,0,-31));local oldPos=model.Torso.Position-Vector3.new(0,3.6,0)
  model:PivotTo(model:GetPivot()+(origin-oldPos));model.Torso.Color=d[3]
  local sign=model.Head:FindFirstChildWhichIsA("BillboardGui");if sign then sign.MaxDistance=24;sign.Size=UDim2.fromOffset(180,30);sign.TextLabel.Text=d[1].." · "..d[2].." (NPC)"end
  model.Torso:SetAttribute("Action","NeighborChat");model.Torso:SetAttribute("ResidentIndex",(i-1)%#residents+1)
  local prompt=model.Torso:FindFirstChildWhichIsA("ProximityPrompt");prompt:SetAttribute("Action","NeighborChat");prompt.ObjectText=d[1].." · "..d[2];prompt.ActionText="Say hello"
  table.insert(self.Walkers,{Model=model,Home=model:GetPivot(),Direction=b.RightVector,Phase=i*1.2})
  local function p(name,size,pos,color,solid)
   local part=Instance.new(name=="GardenBench" and "Seat" or "Part");part.Name=name;part.Size=size;part.CFrame=b*CFrame.new(pos);part.Anchored=true;part.CanCollide=name=="GardenBench" or solid;part.CanTouch=false;part.Material=Enum.Material.SmoothPlastic;part.Color=color;part.Parent=root;return part
  end
  -- Grouped front gardens frame, rather than obstruct, the arrival path.
  for _,side in ipairs({-1,1})do
   p("FrontGardenBed",Vector3.new(6,.6,2.8),Vector3.new(side*11,.3,-24),Color3.fromRGB(165,155,128),false)
   for j=-1,1 do local shrub=p("FloweringShrub",Vector3.new(2,1.7,1.8),Vector3.new(side*11+j*1.7,1.3,-24),Color3.fromRGB(109,142,94),false);shrub.Shape=Enum.PartType.Ball
    local bloom=p("Flowers",Vector3.new(1.1,.6,1.1),Vector3.new(side*11+j*1.7,2.1,-24),i%2==0 and Color3.fromRGB(227,186,154)or Color3.fromRGB(192,173,200),false);bloom.Shape=Enum.PartType.Ball
   end
  end
  p("GardenBench",Vector3.new(5,.35,1.7),Vector3.new(-14,1.7,-29),Color3.fromRGB(177,145,107),false)
  for _,x in ipairs({-15.8,-12.2})do p("BenchLeg",Vector3.new(.3,1.4,1.6),Vector3.new(x,.8,-29),Color3.fromRGB(58,78,66),false)end
  p("BenchBack",Vector3.new(5,1.3,.25),Vector3.new(-14,2.4,-28.2),Color3.fromRGB(177,145,107),false)
 end
 return root
end
function S:Init(context)
 self:Build(workspace.Neighborhood)
 context.Interactions:Register("NeighborChat",function(player,target)
  local d=residents[target:GetAttribute("ResidentIndex")];if not d then return false,"This neighbor is busy."end
  context.Open(player,"Guide",{Name=d[1].." · "..d[2].." (NPC)",Lines={{"Hello, neighbor",d[4]}}});return true
 end)
 local clock=0
 game:GetService("RunService").Heartbeat:Connect(function(dt)
  clock+=dt;if clock<.08 then return end;clock=0
  for _,walker in ipairs(self.Walkers)do
   local nearby=false;for _,p in ipairs(game.Players:GetPlayers())do local hrp=p.Character and p.Character:FindFirstChild("HumanoidRootPart");if hrp and(hrp.Position-walker.Model.Torso.Position).Magnitude<12 then nearby=true;break end end
   if not nearby then walker.Phase+=.06;walker.Model:PivotTo(walker.Home+walker.Direction*math.sin(walker.Phase)*3)end
  end
 end)
end
return S
