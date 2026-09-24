local Space=require(game.ReplicatedStorage.Neighborhood.Shared.WorldSpace)
local D=require(game.ReplicatedStorage.Neighborhood.Shared.BuildingDefinitions)
local Rules=require(game.ReplicatedStorage.Neighborhood.Shared.BuildingRules)
local Schema=require(script.Parent.Parent.ProfileSchema)
local Factory=require(script.Parent.Parent.BuildingFactory)
local Service={Hidden={}}
function Service:Init(context)
 self.Context=context
 for _,action in ipairs({"CraftHome","FurnishHome"})do context.Interactions:Register(action,function(player,target)
  local h=context.Houses.ByPlayer[player.UserId]
  if not h or target:GetAttribute("HouseId")~=h.Model.Name or not target:IsDescendantOf(h.Model)then return false,"Only the homeowner can build here."end
  context.Open(player,action=="CraftHome"and "Crafting"or "Furnish",{Zone=target:GetAttribute("Zone"),Cell=target:GetAttribute("Cell")});return true
 end)end
end
function Service:View(player)
 local p=self.Context.Data:Get(player);return p and Schema.Copy(p.Building)or Rules.Default()
end
function Service:Restore(player)
 local p=self.Context.Data:Get(player);local h=self.Context.Houses.ByPlayer[player.UserId];if not p or not h then return end
 local m=Factory.Create(h.Model,p.Building)
 Factory.Arrange(m,h.Model,p.Building)
 if p.Building.Unlocked.GardenRoom then
  local hidden=self.Hidden[player.UserId]or {};self.Hidden[player.UserId]=hidden
  for _,v in ipairs(h.Model:GetChildren())do if v:IsA("BasePart")and (v.Name=="BackWall"or v.Name=="RearFence")and not hidden[v]then
   hidden[v]={v.Transparency,v.CanCollide,v.CanQuery};v.Transparency=1;v.CanCollide=false;v.CanQuery=false
   for _,t in ipairs(v:GetChildren())do if t:IsA("Texture")or t:IsA("Decal")then hidden[t]={t.Transparency};t.Transparency=1 end end
  end end
 end
 local old=h.Model:FindFirstChild("HomeExpansion");if old then old:Destroy()end;m.Parent=h.Model
 Factory.AddDisplays(h.Model,p.Building)
 self:ApplyFinish(player)
 self:SetDoor(h,h.Open)
end
function Service:SetDoor(house,open)
 local model=house.Model:FindFirstChild("HomeExpansion");local door=model and model:FindFirstChild("GardenDoor",true)
 if not door then return end
 door.CanCollide=not open;door.CanQuery=not open;door.Transparency=open and 1 or .35
 local handle=model:FindFirstChild("GardenHandle",true);if handle then handle.Transparency=open and 1 or 0 end
end
function Service:ContainsExpansion(house,position)
 local profile=self.Context.Data.Profiles[house.Owner];if not profile then return false end
 local v=Space.Unpoint(house.Model.Foundation.CFrame:PointToObjectSpace(position))
 for id in pairs(profile.Building.Unlocked)do local b=D.Bounds[id];if v.X>=b[1]and v.X<=b[2]and v.Z>=b[3]and v.Z<=b[4]and v.Y>=b[5]and v.Y<=b[6]then return true end end
 return false
end
function Service:ApplyFinish(player)
 local h=self.Context.Houses.ByPlayer[player.UserId];local m=h and h.Model:FindFirstChild("HomeExpansion");if not m then return end
 for _,v in ipairs(m:GetDescendants())do if v:IsA("BasePart")then
  if v.Name=="CottageBack"or v.Name=="CottageHeader"or v.Name=="Front"or ((v.Name=="Wall"or v.Name=="Back")and v.Material~=Enum.Material.Glass)then v.Color=h.Model.BackWall.Color end
  if v.Name=="Floor"or v.Name=="LoftFloor"then v.Color=h.Model.Floor.Color;v.Material=h.Model.Floor.Material end
 end end
end
function Service:Release(player)
 for v,props in pairs(self.Hidden[player.UserId]or {})do if v.Parent then v.Transparency=props[1];if v:IsA("BasePart")then v.CanCollide=props[2];v.CanQuery=props[3]end end end
 self.Hidden[player.UserId]=nil
 local h=self.Context.Houses.ByPlayer[player.UserId];if not h then return end
 local m=h.Model:FindFirstChild("HomeExpansion");if m then m:Destroy()end
 for _,v in ipairs(h.Model.DisplaySlots:GetChildren())do if v:GetAttribute("Expansion")then v:Destroy()end end
end
function Service:Action(player,action,arg)
 if not self.Context.Data:CanAct(player)then return false,"Your profile is loading or closing."end
 local p=self.Context.Data:Get(player);local h=self.Context.Houses.ByPlayer[player.UserId]
 local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
 local human=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
 if not p or not h or h.Owner~=player.UserId or not root or not human or human.Health<=0 then return false,"Your home is not ready."end
 local position=Space.Unpoint(h.Model.Foundation.CFrame:PointToObjectSpace(root.Position))
 if math.abs(position.X)>29 or position.Z< -36 or position.Z>51 or position.Y< -2 or position.Y>29 then return false,"Return to your own home to build."end
 if player:GetAttribute("Carrying")then return false,"Set down the possession before building."end
 local b=p.Building
 if action=="Buy"then
  local r=type(arg)=="string"and D.Rooms[arg]
  if not r then return false,"Choose an expansion from the plans."end
  if b.Unlocked[arg]then return false,"You already own this expansion."end
  if r.Requires and not b.Unlocked[r.Requires]then return false,"Build the "..D.Rooms[r.Requires].Name:lower().." first."end
  if p.Currency<r.Price then return false,"You need $"..r.Price.." in game cash."end
  -- Rendering is synchronous; rollback ownership and currency if construction fails.
  b.Unlocked[arg]=true
  local ok,why=pcall(function()self:Restore(player)end)
  if not ok then b.Unlocked[arg]=nil;warn("[BUILDING] "..tostring(why));self:Restore(player);return false,"Construction failed. Your cash was not spent."end
  p.Currency-=r.Price;if self.Context.Life then self.Context.Life:Earn(player,30)end;self.Context.Record(player,"Customize")
  return true,r.Name.." built. Your expansion follows you to other neighborhoods."
 elseif action=="Craft"then
  local recipe=type(arg)=="string"and D.Recipes[arg]
  if not recipe or not b.Unlocked.Workshop then return false,"Build your backyard workshop to craft furniture."end
  local bench=h.Model.HomeExpansion:FindFirstChild("CraftBench")
  if not bench or (root.Position-bench.Position).Magnitude>14 then return false,"Stand beside your workshop bench to craft."end
  local total=0;for _,n in pairs(b.Owned)do total+=n end
  if total>=D.MaxOwned then return false,"Your furniture collection is full. Rearrange the pieces you own."end
  if p.Currency<recipe.Price then return false,"You need $"..recipe.Price.." in game cash."end
  p.Currency-=recipe.Price;if self.Context.Life then self.Context.Life:Earn(player,2)end;b.Owned[arg]=(b.Owned[arg]or 0)+1
  return true,recipe.Name.." crafted. Choose a room and a rug to place it."
 elseif action=="Place"or action=="Pack"then
  if type(arg)~="table"or type(arg.Zone)~="string"then return false,"Choose a room and a rug."end
  local room=D.Rooms[arg.Zone]
  if not room or not b.Unlocked[arg.Zone]or not Rules.Integer(arg.Cell,1,#room.Cells)then return false,"That furnishing spot is unavailable."end
  local key=Rules.Key(arg.Zone,arg.Cell);local nextPlaced=Schema.Copy(b.Placed)
  if action=="Pack"then if not nextPlaced[key]then return false,"That rug is already empty."end;nextPlaced[key]=nil
  else
   if type(arg.Kind)~="string"or not D.Recipes[arg.Kind]or not Rules.Integer(arg.Rotation,0,3)then return false,"Choose furniture and a quarter-turn rotation."end
   nextPlaced[key]={Zone=arg.Zone,Cell=arg.Cell,Kind=arg.Kind,Rotation=arg.Rotation}
  end
  if not Rules.Placements(b,nextPlaced)then return false,"All copies of that furniture are already placed. Pack one or craft another."end
  b.Placed=nextPlaced;Factory.Arrange(h.Model.HomeExpansion,h.Model,b)
  return true,action=="Pack"and "Furniture packed. You still own it."or "Furniture placed. Walk over to see your room."
 elseif action=="SaveLayout"or action=="LoadLayout"then
  if arg~="1"and arg~="2"and arg~="3"then return false,"Choose layout 1, 2 or 3."end
  if action=="SaveLayout"then b.Layouts[arg]=Schema.Copy(b.Placed);return true,"Layout "..arg.." saved."end
  local layout=b.Layouts[arg]
  if not Rules.Placements(b,layout)then return false,"Save an available layout in this slot first."end
  b.Placed=Schema.Copy(layout);Factory.Arrange(h.Model.HomeExpansion,h.Model,b)
  return true,"Layout "..arg.." restored. Your collectible displays stay where they are."
 end
 return false,"Choose an available building action."
end
return Service
