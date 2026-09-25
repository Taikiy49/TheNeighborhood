local F=require(script.Parent.RecreationFactory)
local M={}
local cream=Color3.fromRGB(231,221,199)
local green=Color3.fromRGB(57,89,76)
local wood=Color3.fromRGB(158,123,87)
local function prompt(p,action,text,title)
 p:SetAttribute('Action',action)
 local q=Instance.new('ProximityPrompt');q.Style=Enum.ProximityPromptStyle.Custom;q.ActionText=text;q.ObjectText=title;q.MaxActivationDistance=10;q:SetAttribute('Action',action);q.Parent=p
end
function M.Garages(w)
 for _,h in ipairs(w.Houses:GetChildren())do
  local old=h:FindFirstChild('BaseGarage');if old then old:Destroy()end
  local m=Instance.new('Model');m.Name='BaseGarage';m.ModelStreamingMode=Enum.ModelStreamingMode.Atomic;m.Parent=h
  local basis=h.Foundation.CFrame*CFrame.new(-32,-.5,0)
  for _,v in ipairs(w.GardenDetails:GetChildren())do if v:IsA('BasePart')then local at=basis:PointToObjectSpace(v.Position);if math.abs(at.X)<9 and at.Z> -45 and at.Z<13 then v:Destroy()end end end
  local function p(n,s,x,y,z,c,solid)return F.Part(m,n,Vector3.new(table.unpack(s)),basis*CFrame.new(x,y,z),c,solid)end
  p('Floor',{20,.6,28},0,.3,0,Color3.fromRGB(163,163,151)).Material=Enum.Material.Concrete
  for _,x in ipairs({-10,10})do p('SideWall',{.4,12,28},x,6,0,cream)end
  p('RearWall',{20,12,.4},0,6,14,cream)
  p('Roof',{21,.6,29},0,12.3,0,green).Material=Enum.Material.Slate
  for _,x in ipairs({-9.4,9.4})do p('FrontPier',{1,12,.6},x,6,-14,cream)end
  p('Header',{18,1,.6},0,11.5,-14,cream)
  local door=p('RollerDoor',{17.5,10.5,.3},0,6,-13.7,green,false);door.Transparency=.15
  -- Roller door is parked overhead; the car entrance always remains clear.
  door.Size=Vector3.new(17.5,.3,10.5);door.CFrame=basis*CFrame.new(0,11,-8.5)
  for z=-13,-4,1 do p('DoorSlat',{17.5,.12,.12},0,10.8,z,cream,false)end
  p('RearShelf',{12,.3,2},0,6,12.5,wood)
  local lamp=p('GarageLight',{3,.15,1},0,10.5,2,cream,false);lamp.Material=Enum.Material.Neon
  local light=Instance.new('PointLight');light.Range=16;light.Brightness=.5;light.Parent=lamp
  local panel=p('GaragePanel',{1.2,2,.3},-8,3,-14.4,green,false);panel:SetAttribute('HouseId',h.Name);prompt(panel,'HomeGarage','Open garage menu','Your garage')
  p('Driveway',{18,.2,21},0,.15,-24.5,Color3.fromRGB(171,168,157)).Material=Enum.Material.Concrete
  local spawn=p('CarSpawn',{1,.1,1},0,3.5,0,cream,false);spawn.Transparency=1;spawn.CanQuery=false;spawn.CanTouch=false
 end
end
function M.Water()
 local region=Region3.new(Vector3.new(-100,-16,-280),Vector3.new(100,0,-240)):ExpandToGrid(4)
 local size=region.Size/4;local low=region.CFrame.Position-region.Size/2
 local mats,occ={},{}
 for x=1,size.X do mats[x]={};occ[x]={};for y=1,size.Y do mats[x][y]={};occ[x][y]={};for z=1,size.Z do
  local at=low+Vector3.new(x-.5,y-.5,z-.5)*4
  local shore=math.min(100-math.abs(at.X),-240-at.Z)
  local depth=shore<6 and 2 or shore<12 and 4 or shore<18 and 8 or 12
  mats[x][y][z]=at.Y>=-depth and Enum.Material.Water or Enum.Material.Sand;occ[x][y][z]=1
 end end end
 workspace.Terrain:WriteVoxels(region,4,mats,occ)
end
function M.Cove(w)
 M.Water()
 local old=w:FindFirstChild('SunsetCove');if old then old:Destroy()end
 local m=Instance.new('Model');m.Name='SunsetCove';m.ModelStreamingMode=Enum.ModelStreamingMode.Atomic;m.Parent=w
 local function p(n,s,x,y,z,c,solid,class)return F.Part(m,n,Vector3.new(table.unpack(s)),CFrame.new(x,y,z),c,solid,class)end
 local ground=w.Map:FindFirstChild('VillageGroundEast')
 if ground then
  local color=ground.Color;ground:Destroy()
  local function g(n,sx,sz,x,z)local a=F.Part(w.Map,n,Vector3.new(sx,4,sz),CFrame.new(x,-2,z),color);a.Material=Enum.Material.Grass end
  g('CoveGroundSouth',562,520,55,20);g('CoveGroundWest',126,40,-163,-260);g('CoveGroundEast',236,40,218,-260)
 end
 p('Beach',{220,.25,29},0,.12,-225.5,Color3.fromRGB(222,204,153)).Material=Enum.Material.Sand
 p('Boardwalk',{224,.25,7},0,.14,-207,wood).Material=Enum.Material.WoodPlanks
 p('TownConnection',{8,.2,10},0,.1,-199,cream).Material=Enum.Material.Pavement
 for _,x in ipairs({-64,0,64})do p('BeachAccess',{6,.15,14},x,.22,-217,wood).Material=Enum.Material.WoodPlanks end
 local sign=p('CoveName',{21,3,.4},0,7,-204,green,false);F.Sign(sign,'SUNSET COVE\nSwimming - beach games - relax')
 for _,x in ipairs({-11,11})do p('SignPost',{.4,8,.4},x,4,-204,wood)end
 for _,x in ipairs({-83,-42,38})do
  p('UmbrellaPole',{.25,8,.25},x,4,-226,wood)
  local canopy=p('Umbrella',{11,.6,11},x,8,-226,x<0 and cream or Color3.fromRGB(157,190,176),false);canopy.Shape=Enum.PartType.Ball
  for _,dx in ipairs({-3,3})do
   p('Lounger',{2.4,.5,6},x+dx,1,-229,cream,true,'Seat')
   local back=p('LoungerBack',{2.4,2.5,.35},x+dx,2,-226.5,wood);back.CFrame*=CFrame.Angles(math.rad(-20),0,0)
   p('LoungerBase',{1.5,.7,4},x+dx,.4,-229,wood)
  end
 end
 -- A fully accessible changing hut with two open alcoves.
 p('HutFloor',{18,.3,12},84,.15,-219,wood)
 p('HutRear',{18,9,.5},84,4.5,-225,cream)
 for _,x in ipairs({75,84,93})do p('HutPartition',{.5,9,12},x,4.5,-219,cream)end
 p('HutRoof',{20,.5,14},84,9.3,-219,green)
 for _,x in ipairs({79.5,88.5})do p('ChangingBench',{5,.4,2},x,1.5,-222,wood,true,'Seat');p('BenchBase',{4,1,1},x,.6,-222,green)end
 local hutSign=p('ChangingSign',{17,1.5,.2},84,8,-212.6,green,false);hutSign.CFrame*=CFrame.Angles(0,math.pi,0);F.Sign(hutSign,'CHANGING HUT - REST & REGROUP')
 p('LifeguardSeat',{3,.5,3},-14,2,-231,green,true,'Seat')
 p('LifeguardPlatform',{5,.5,5},-14,1,-231,wood)
 local rules=p('SafetyBoard',{10,4,.4},-14,6,-233,green,false);rules.CFrame*=CFrame.Angles(0,math.pi,0);F.Sign(rules,'SWIM WITH FRIENDS\nShallows near the sand\nUse Return to shore if stuck')
 prompt(rules,'CoveReturn','Return to shore','Sunset Cove')
 -- Swim buoys mark the deep-water boundary, without an invisible wall.
 for x=-88,88,22 do local buoy=p('SwimBuoy',{1.5,1.5,1.5},x,.4,-257,Color3.fromRGB(237,160,79),false);buoy.Shape=Enum.PartType.Ball end
 local rack=p('BallRack',{4,2,2},16,1,-213,wood);prompt(rack,'BeachBall','Borrow beach ball','Free beach games')
 local gameSign=p('BallSign',{9,2,.2},16,4,-214,green,false);gameSign.CFrame*=CFrame.Angles(0,math.pi,0);F.Sign(gameSign,'BEACH BALLS\nOne per player - tap to toss')
 -- Keep the northern promenade, beach and water free of trees and old decorative objects.
 local remove={}
 for _,v in ipairs(w.ArtDirection.GardenDistrict:GetDescendants())do
  if v:IsA('Model')and v:FindFirstChild('Trunk')then local at=v:GetPivot().Position;if math.abs(at.X)<121 and at.Z< -198 then remove[v]=true end end
 end
 for v in pairs(remove)do v:Destroy()end
 return m
end
function M.Init(context)
 M.Garages(workspace.Neighborhood);M.Cove(workspace.Neighborhood)
 context.Interactions:Register('HomeGarage',function(player,target)
  if player:GetAttribute('HouseId')~=target:GetAttribute('HouseId')then return false,'This garage belongs to another home.'end
  context.Open(player,'Garage');return true
 end)
 context.Interactions:Register('CoveReturn',function(player)
  if player:GetAttribute('Carrying')then return false,'Set down your carried item first.'end
  player.Character:PivotTo(CFrame.new(600,4,230));return true,'Back on the sand.'
 end)
 local balls={}
 context.Interactions:Register('BeachBall',function(player)
  if balls[player]and balls[player].Parent then return false,'You already borrowed a beach ball.'end
  local tool=Instance.new('Tool');tool.Name='Beach ball';tool.CanBeDropped=false
  local b=Instance.new('Part');b.Name='Handle';b.Shape=Enum.PartType.Ball;b.Size=Vector3.new(2,2,2);b.Material=Enum.Material.SmoothPlastic;b.Color=Color3.fromRGB(239,189,77);b.CanCollide=false;b.Massless=true;b.Parent=tool
  balls[player]=tool;local used=false
  tool.Activated:Connect(function()
   if used or not context.Data:CanAct(player)then return end
   local hrp=player.Character and player.Character:FindFirstChild('HumanoidRootPart');if not hrp then return end
   if math.abs(hrp.Position.X)>112 or hrp.Position.Z> -201 or hrp.Position.Z< -280 then context.Notify(player,'Beach balls stay at Sunset Cove.',false);return end
   used=true;local ball=b:Clone();ball.Name='BeachBall';ball.CanCollide=true;ball.CanTouch=false;ball.Massless=false;ball.CustomPhysicalProperties=PhysicalProperties.new(.2,.3,.65,1,1);ball.CFrame=hrp.CFrame*CFrame.new(0,1,-4);ball.Parent=workspace.Neighborhood.Runtime;ball:SetNetworkOwner(nil);ball.AssemblyLinearVelocity=hrp.CFrame.LookVector*28+Vector3.new(0,16,0);balls[player]=ball;tool:Destroy();game:GetService('Debris'):AddItem(ball,25)
  end)
  tool.Parent=player.Backpack;game:GetService('Debris'):AddItem(tool,120);return true,'Equip the ball on the beach and tap to toss. It floats in water.'
 end)
 game.Players.PlayerRemoving:Connect(function(player)if balls[player]then balls[player]:Destroy();balls[player]=nil end end)
end
return M
