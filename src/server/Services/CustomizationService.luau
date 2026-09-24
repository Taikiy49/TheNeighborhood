local Service={}
local Validation=require(game.ReplicatedStorage.Neighborhood.Shared.Validation)
local colors={Mint=Color3.fromRGB(175,202,185),Peach=Color3.fromRGB(223,178,144),Blue=Color3.fromRGB(154,187,205),Butter=Color3.fromRGB(226,211,157)}
local floors={Wood={Material=Enum.Material.SmoothPlastic,Color=Color3.fromRGB(177,145,107),Price=0},Tile={Material=Enum.Material.Marble,Color=Color3.fromRGB(223,225,210),Price=250},Carpet={Material=Enum.Material.Fabric,Color=Color3.fromRGB(127,153,142),Price=200}}
function Service:Init(context)self.Context=context end
function Service:Apply(player)
 local profile=self.Context.Data:Get(player);local house=self.Context.Houses.ByPlayer[player.UserId];if not profile or not house then return end
 local settings=profile.House;settings.UnlockedColors=settings.UnlockedColors or {};settings.UnlockedFloors=settings.UnlockedFloors or {Wood=true};settings.Permissions=settings.Permissions or {}
 local color=colors[settings.Color]
 for _,part in ipairs(house.Model:GetChildren())do
  if part:IsA("BasePart")and (part.Name:find("Wall")or part.Name=="FrontSill"or part.Name=="FrontHeader"or part.Name=="Gable")then
   if part:GetAttribute("EverydayOriginalColor")==nil then part:SetAttribute("EverydayOriginalColor",part.Color)end
   if not color then part.Color=part:GetAttribute("EverydayOriginalColor");for _,finish in ipairs(part:GetChildren())do if finish:IsA("Texture")and finish.Name:match("^HiggsfieldSiding")then finish.Color3=part.Color end end end
  end
 end
 if color then for _,p in ipairs(house.Model:GetChildren())do if p:IsA("BasePart") and (p.Name:find("Wall") or p.Name=="FrontSill" or p.Name=="FrontHeader" or p.Name=="Gable")then
  p.Color=color
  for _,finish in p:GetChildren()do if finish:IsA("Texture")and finish.Name:match("^HiggsfieldSiding")then finish.Color3=color end end
 end end end
 local floor=floors[settings.Floor or "Wood"];house.Model.Floor.Material=floor.Material;house.Model.Floor.Color=floor.Color
 if self.Context.Boutique then self.Context.Boutique:Apply(player)end
 local interior=house.Model:FindFirstChild("BuiltInInterior")
 if interior then for _,detail in ipairs(interior:GetChildren())do if detail:GetAttribute("FloorSeam")then detail.Transparency=house.Model.Floor.Material==Enum.Material.SmoothPlastic and 0 or 1 end end end
 if self.Context.Building then self.Context.Building:ApplyFinish(player)end
 house.Permissions=settings.Permissions;house.Model:SetAttribute("SecurityLevel",settings.SecurityLevel or 0)
end
function Service:Change(player,kind,id)
 local p=self.Context.Data:Get(player);local house=self.Context.Houses.ByPlayer[player.UserId]
 if not p or not house then return false,"Move into a house first."end
 self:Apply(player)
 if kind=="Color"then
  if not colors[id]then return false,"Unknown paint color."end
  local cost=p.House.UnlockedColors[id] and 0 or 150;if p.Currency<cost then return false,"Paint costs $150."end
  p.Currency-=cost;p.House.UnlockedColors[id]=true;p.House.Color=id
 elseif kind=="Floor"then
  local floor=floors[id];if not floor then return false,"Unknown flooring."end
  local cost=p.House.UnlockedFloors[id] and 0 or floor.Price;if p.Currency<cost then return false,"You need $"..cost.." for this flooring."end
  p.Currency-=cost;p.House.UnlockedFloors[id]=true;p.House.Floor=id
 elseif kind=="Security"then
  local level=p.House.SecurityLevel or 0;if level>=2 then return false,"Your lock is fully upgraded."end
  local cost=(level+1)*350;if p.Currency<cost then return false,"The next lock upgrade costs $"..cost.."."end
  p.Currency-=cost;p.House.SecurityLevel=level+1
 else return false,"Unknown house option."end
 if kind=="Color"or kind=="Floor"then p.House.Boutique=nil end
 self:Apply(player);self.Context.Record(player,"Customize");return true,"Home updated. Purchased finishes stay unlocked."
end
function Service:Permission(player,id,role)
 local target=tonumber(id);local profile=self.Context.Data:Get(player)
 if not profile or not Validation.UserId(target) or target==player.UserId or not game.Players:GetPlayerByUserId(target)then return false,"Choose a connected neighbor."end
 if role~="Visitor" and role~="Friend" and role~="Roommate"then return false,"Unknown permission level."end
 self:Apply(player);profile.House.Permissions[tostring(target)]=role~="Visitor" and role or nil
 return true,role=="Visitor" and "Special access removed." or role.." access granted. Your possessions remain yours."
end
return Service
