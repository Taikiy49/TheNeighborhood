local Players=game:GetService("Players")
local Marketplace=game:GetService("MarketplaceService")
local Catalog=require(game.ReplicatedStorage.Neighborhood.Shared.BoutiqueCatalog)
local Service={Owned={},Busy={},Recheck={},LastRefresh={}}
-- Server-only adapter; acceptance tests replace it without spending Robux.
function Service:OwnsPass(player,passId)
 return Marketplace:UserOwnsGamePassAsync(player.UserId,passId)
end
function Service:PurchaseFinished(player,passId,purchased)
 if purchased~=true or player.Parent~=Players then return false end
 for _,pack in pairs(Catalog)do if pack.PassId>0 and pack.PassId==passId then
  local ok,message=self:Refresh(player)
  if player.Parent==Players then self.Context.Sync(player)end
  return ok,message
 end end
 return false
end
function Service:Init(context)
 self.Context=context
 Marketplace.PromptGamePassPurchaseFinished:Connect(function(player,passId,purchased)
  self:PurchaseFinished(player,passId,purchased)
 end)
 Players.PlayerRemoving:Connect(function(player)self.Owned[player]=nil;self.LastRefresh[player]=nil;self.Recheck[player]=nil end)
end
function Service:Refresh(player)
 if self.Busy[player]then self.Recheck[player]=true;return false,"Checking ownership. Please wait."end
 self.Busy[player]=true
 local owned={};for key,value in pairs(self.Owned[player]or {})do owned[key]=value end
 local allOk=true
 repeat
 self.Recheck[player]=nil;allOk=true
 for key,pack in pairs(Catalog)do
  if pack.PassId>0 then
   local ok,value=pcall(function()return self:OwnsPass(player,pack.PassId)end)
   if ok then owned[key]=value==true else allOk=false end
  else owned[key]=false end
 end
 until not self.Recheck[player]or player.Parent~=Players
 self.Busy[player]=nil
 if player.Parent~=Players then return false,"Player left."end
 self.Owned[player]=owned
 self.Context.Customization:Apply(player)
 self.Context.Sync(player)
 return allOk,allOk and "Purchases checked."or "Roblox ownership check unavailable. Please retry."
end
function Service:View(player)
 local owned={};for key,value in pairs(self.Owned[player]or {})do owned[key]=value end
 local profile=self.Context.Data:Get(player)
 return {Owned=owned,Selected=profile and profile.House.Boutique}
end
function Service:Apply(player)
 local profile=self.Context.Data:Get(player);local house=self.Context.Houses.ByPlayer[player.UserId]
 if not profile or not house then return end
 local choice=profile.House.Boutique
 if type(choice)~="string"then return end
 local packKey,styleKey=choice:match("^(%w+):(%w+)$")
 local pack=Catalog[packKey];local style=pack and pack.Styles[styleKey]
 if not style or not (self.Owned[player]or {})[packKey]then return end
 for _,part in ipairs(house.Model:GetChildren())do
  if part:IsA("BasePart")and (part.Name:find("Wall")or part.Name=="FrontSill"or part.Name=="FrontHeader"or part.Name=="Gable")then
   part.Color=style.Wall
   for _,texture in ipairs(part:GetChildren())do if texture:IsA("Texture")and texture.Name:match("^HiggsfieldSiding")then texture.Color3=style.Wall end end
  end
 end
 house.Model.Floor.Color=style.Floor;house.Model.Floor.Material=style.Material
end
function Service:Action(player,action,choice)
 if not self.Context.Data:CanAct(player)then return false,"Your profile is not ready."end
 if action=="Refresh"then
  if os.clock()-(self.LastRefresh[player]or -100)<10 then return false,"Please wait before checking again."end
  self.LastRefresh[player]=os.clock();return self:Refresh(player)
 end
 local profile=self.Context.Data:Get(player)
 if action=="Reset"then profile.House.Boutique=nil;self.Context.Customization:Apply(player);return true,"Original home finishes restored."end
 if action~="Equip"or type(choice)~="string"or #choice>60 then return false,"Unknown style."end
 local packKey,styleKey=choice:match("^(%w+):(%w+)$")
 local pack=Catalog[packKey]
 if not pack or not pack.Styles[styleKey]then return false,"Unknown style."end
 if not (self.Owned[player]or {})[packKey]then return false,"This finish requires its permanent style pass."end
 profile.House.Boutique=choice;self.Context.Customization:Apply(player)
 return true,"Home style applied. Your choice saves with your progress."
end
return Service
