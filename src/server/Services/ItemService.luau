local Http=game:GetService("HttpService")
local Defs=require(game.ReplicatedStorage.Neighborhood.Shared.ItemDefinitions)
local Factory=require(script.Parent.Parent.ItemFactory)
local Service={Items={},Models={}}
function Service:Init(context) self.Context=context end
function Service:Restore(player,profile,house)
 for _,item in ipairs(profile.Items or {})do
  self.Items[item.Id]=item
  if item.State=="Displayed"then item.HouseId=house.Model.Name;local slot=house.Model.DisplaySlots:FindFirstChild("Slot"..item.Slot);self:Render(item,slot.CFrame*CFrame.new(0,0.15,0))end
 end
 if profile.FirstVisit then self:Create(player,"BasicChair");self:Create(player,"Lamp");profile.FirstVisit=false end
 house.Locked=profile.House.Locked==true;house.Model:SetAttribute("Locked",house.Locked)
 profile._Restored=true
end
function Service:Create(player,definitionId)
 if not Defs[definitionId] then return nil end
 local id=Http:GenerateGUID(false)
 local item={Id=id,DefinitionId=definitionId,OwnerUserId=player.UserId,OriginalOwnerUserId=player.UserId,State="Stored",Provenance={{Kind="Acquired",Time=os.time()}}}
 local profile=self.Context.Data:Get(player)
 self.Items[id]=item;table.insert(profile.Inventory,id);profile.Collection[definitionId]=profile.Collection[definitionId] or os.time();return item
end
function Service:Owned(player)
 local result={}
 for _,item in pairs(self.Items) do if item.OwnerUserId==player.UserId and item.State~="Sold" then
  table.insert(result,{Id=item.Id,DefinitionId=item.DefinitionId,State=item.State,Slot=item.Slot})
 end end
 table.sort(result,function(a,b)return a.DefinitionId<b.DefinitionId end);return result
end
function Service:Render(item,cf)
 if self.Models[item.Id] then self.Models[item.Id]:Destroy() end
 local model=Factory.Create(item.DefinitionId);model.Name=item.Id;model:SetAttribute("ItemId",item.Id);model:SetAttribute("DefinitionId",item.DefinitionId)
 model:PivotTo(cf);model.Parent=workspace.Neighborhood.Runtime;self.Models[item.Id]=model
 local root=model.PrimaryPart;root:SetAttribute("ItemId",item.Id);root:SetAttribute("Action","Item")
 local p=Instance.new("ProximityPrompt");p.Style=Enum.ProximityPromptStyle.Custom;p.ActionText="Inspect / interact";p.ObjectText=Defs[item.DefinitionId].Name;p.MaxActivationDistance=10;p.RequiresLineOfSight=false;p:SetAttribute("Action","Item");p.Parent=root
 return model
end
function Service:Place(player,id,slotNumber)
 local item=self.Items[id];local house=self.Context.Houses.ByPlayer[player.UserId]
 if not item or item.OwnerUserId~=player.UserId or item.State~="Stored" then return false,"Choose an item from your inventory." end
 if not house or type(slotNumber)~="number" or slotNumber%1~=0 or slotNumber<1 or slotNumber>6 then return false,"Choose a display spot." end
 local slot=house.Model.DisplaySlots:FindFirstChild("Slot"..slotNumber)
 local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
 local humanoid=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
 if not root or not humanoid or humanoid.Health<=0 or (root.Position-slot.Position).Magnitude>14 then return false,"Stand near that display spot." end
 for _,other in pairs(self.Items) do if other.HouseId==house.Model.Name and other.Slot==slotNumber and (other.State=="Displayed" or other.State=="Carried" or other.State=="Escaped" or other.State=="Dropped") then return false,"That spot is occupied or reserved for a missing possession." end end
 item.State="Displayed";item.HouseId=house.Model.Name;item.Slot=slotNumber
 self:Render(item,slot.CFrame*CFrame.new(0,0.15,0))
 if not item.PlacedBefore then item.PlacedBefore=true;self.Context.Record(player,"Place")end
 return true,"Displayed "..Defs[item.DefinitionId].Name.."."
end
function Service:Store(player,item)
 if item.OwnerUserId~=player.UserId or item.State~="Displayed" then return false,"This item cannot be stored." end
 item.State="Stored";item.HouseId=nil;item.Slot=nil
 if self.Models[item.Id] then self.Models[item.Id]:Destroy();self.Models[item.Id]=nil end
 return true,"Item returned to protected inventory."
end
function Service:Release(player)
 for id,item in pairs(self.Items) do if item.OwnerUserId==player.UserId then
  if self.Models[id] then self.Models[id]:Destroy();self.Models[id]=nil end
  self.Items[id]=nil
 end end
end
return Service
