local A=require(script.Parent.CityArchitecture)
local D=require(game.ReplicatedStorage.Neighborhood.Shared.YardCatalog)
local Levels=require(game.ReplicatedStorage.Neighborhood.Shared.VehicleCatalog)
local S={}
function S:Init(context)
 self.Context=context
 for _,v in ipairs(workspace.Neighborhood.CoastalWorld.Landscape:GetChildren())do if v.Name=='BackPatio'or v.Name=='GardenFence'or v.Name=='GardenFencePost'then v:Destroy()end end
 for _,h in ipairs(workspace.Neighborhood.Houses:GetChildren())do
  local f=Instance.new('Model');f.Name='PersonalYard';f.ModelStreamingMode=Enum.ModelStreamingMode.Atomic;f.Parent=h
  local b=h.Foundation.CFrame
  local function p(n,size,x,y,z,c)local v=A.Part(f,n,size,Vector3.zero,c);v.CFrame=b*CFrame.new(x,y,z);return v end
  p('YardLawn',{20,.2,64},33,-.35,8,Color3.fromRGB(110,151,99)).Material=Enum.Material.Grass
  p('GardenPath',{3,.22,64},23,-.3,8,A.Cream).Material=Enum.Material.Pavement
  for _,z in ipairs({-24,40})do p('FenceRail',{18,2,.3},34,1,z,A.Cream)end
  p('FenceRail',{.3,2,64},43,1,8,A.Cream)
  for _,z in ipairs({-24,-8,8,24,40})do p('FencePost',{.5,3,.5},43,1.2,z,A.Wood)end
  local board=p('YardBoard',{5,2,.3},22,4,-20,A.Ink);A.Sign(board,'GARDEN');A.Prompt(board,'YardOpen','Garden','Decorate yard');board:SetAttribute('HouseId',h.Name)
 end
 context.Interactions:Register('YardOpen',function(player,target)if player:GetAttribute('HouseId')~=target:GetAttribute('HouseId')then return false,'This garden belongs to your neighbor.'end;context.Open(player,'Yard');return true end)
 local last={};context.Interactions:Register('YardBounce',function(player)
  if os.clock()-(last[player]or 0)<2 then return false,'Wait a moment before bouncing again.'end
  local c=player.Character;local r=c and c:FindFirstChild('HumanoidRootPart');local h=c and c:FindFirstChildOfClass('Humanoid');if not r or not h or h.Sit then return false,'Stand beside the trampoline.'end
  last[player]=os.clock();h.Jump=true;r.AssemblyLinearVelocity=Vector3.new(0,48,0);return true,'Boing!'
 end)
 game.Players.PlayerRemoving:Connect(function(p)last[p]=nil end)
end
function S:Restore(player)
 local profile=self.Context.Data:Get(player);local h=self.Context.Houses.ByPlayer[player.UserId];if not profile or not h then return end
 local yard=h.Model.PersonalYard;local old=yard:FindFirstChild('Decor');if old then old:Destroy()end
 local root=Instance.new('Folder');root.Name='Decor';root.Parent=yard
 for slot,v in pairs(profile.Yard.Slots)do
  local n=tonumber(slot);local cf=h.Model.Foundation.CFrame*CFrame.new(n%2==1 and 28 or 38,0,-16+math.floor((n-1)/2)*11)*CFrame.Angles(0,v.Rotation*math.pi/2,0)
  local model=Instance.new('Model');model.Name='Slot'..slot;model.Parent=root
  local function p(name,size,x,y,z,c,mat,solid,class)local t=A.Part(model,name,size,Vector3.zero,c,mat,solid,class);t.CFrame=cf*CFrame.new(x,y,z);return t end
  if v.Id=='Flowers'then
   p('Planter',{6,1,5},0,.2,0,A.Wood);for i=-1,1 do local flower=p('Flowers',{1.7,2,1.7},i*1.7,1.3,0,Color3.fromRGB(204,158+i*25,128),Enum.Material.Grass,false);flower.Shape=Enum.PartType.Ball end
  elseif v.Id=='Bench'or v.Id=='Picnic'then
   p('Bench',{6,.4,2},0,1.5,0,A.Wood,nil,true,'Seat');p('Back',{6,2,.25},0,2.4,1,A.Ink)
   for _,x in ipairs({-2,2})do p('Leg',{.4,1.5,2},x,.7,0,A.Wood)end
   if v.Id=='Picnic'then p('Table',{7,.4,3},0,2.5,-3,A.Cream);p('TableBase',{1,2.5,1},0,1.2,-3,A.Wood);p('SecondBench',{6,.4,2},0,1.5,-6,A.Wood,nil,true,'Seat')end
  elseif v.Id=='BallRack'then local rack=p('BallRack',{5,2,3},0,1,0,A.Wood);A.Prompt(rack,'BeachBall','Garden toys','Borrow a ball')
  elseif v.Id=='Trampoline'then
   local t=p('BounceMat',{7,.5,7},0,1,0,A.Ink);A.Prompt(t,'YardBounce','Trampoline','Bounce')
   for _,x in ipairs({-3,3})do for _,z in ipairs({-3,3})do p('Leg',{.4,1,.4},x,.4,z,A.Cream)end end
  elseif v.Id=='Lantern'then
   p('Post',{.5,9,.5},0,4,0,A.Wood);local light=p('Lantern',{2,2,2},0,9,0,A.Cream,Enum.Material.Neon,false);local l=Instance.new('PointLight');l.Brightness=.5;l.Range=20;l.Color=Color3.fromRGB(255,221,162);l.Parent=light
  elseif v.Id=='Pergola'then
   for _,x in ipairs({-3,3})do for _,z in ipairs({-4,4})do p('Post',{.5,9,.5},x,4,z,A.Wood)end end
   for x=-4,4,2 do p('RoofSlat',{.5,.4,10},x,9,0,A.Cream)end;p('LoungeSeat',{5,.4,2},0,1.5,2,A.Ink,nil,true,'Seat')
  elseif v.Id=='Fountain'then
   p('Basin',{7,1,7},0,.5,0,A.Cream,Enum.Material.Marble);local water=p('Water',{6,.15,6},0,1.1,0,Color3.fromRGB(93,181,203),Enum.Material.Glass,false);water.Transparency=.35
   p('Column',{1,4,1},0,2.5,0,A.Cream,Enum.Material.Marble);p('Bowl',{4,.3,4},0,4.5,0,A.Cream)
  else
   p('Plinth',{5,2,5},0,1,0,A.Ink,Enum.Material.Marble);local orb=p('GoldenSculpture',{4,6,4},0,5,0,Color3.fromRGB(226,184,86),Enum.Material.Metal);orb.Shape=Enum.PartType.Ball
  end
 end
end
function S:Release(player)
 local h=self.Context.Houses.ByPlayer[player.UserId]
 local decor=h and h.Model.PersonalYard:FindFirstChild('Decor')
 if decor then decor:Destroy()end
end
function S:Action(player,action,arg)
 local p=self.Context.Data:Get(player);local h=self.Context.Houses.ByPlayer[player.UserId];local r=player.Character and player.Character:FindFirstChild('HumanoidRootPart')
 if not p or not h or not r or(r.Position-h.Model.PersonalYard.YardLawn.Position).Magnitude>65 then return false,'Go to your own garden first.'end
 if type(arg)~='string'or #arg>80 then return false,'Choose a garden item.'end
 if action=='Buy'then local d=D.Items[arg];if not d or p.Yard.Owned[arg]then return false,'Choose a new garden blueprint.'end
  if Levels.Level(p.XP)<d.Level then return false,'Reach level '..d.Level..' first.'end
  if p.Currency<d.Price then return false,'You need $'..d.Price..'.'end
  p.Currency-=d.Price;p.Yard.Owned[arg]=true;self.Context.Record(player,'Yard');return true,'Blueprint unlocked. Place it in a garden space.'
 elseif action=='Place'then
  local slot,id,rotation=arg:match('^([1-6]):(%a+):([0-3])$');if not slot or not p.Yard.Owned[id]then return false,'Choose an owned blueprint and garden space.'end
  p.Yard.Slots[slot]={Id=id,Rotation=tonumber(rotation)}
 elseif action=='Clear'then if not arg:match('^[1-6]$')then return false,'Choose a garden space.'end;p.Yard.Slots[arg]=nil
 else return false,'Choose a garden action.'end
 self:Restore(player);return true,'Garden layout saved.'
end
return S
