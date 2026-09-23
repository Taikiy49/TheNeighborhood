local Http=game:GetService("HttpService")
local Defs=require(game.ReplicatedStorage.Neighborhood.Shared.ItemDefinitions)
local Factory=require(script.Parent.Parent.ItemFactory)
local Service={Items={},Models={}}
function Service:Init(context) self.Context=context end
function Service:Create(player,definitionId)
 if not Defs[definitionId] then return nil end
 local id=Http:GenerateGUID(false)
 local item={Id=id,DefinitionId=definitionId,OwnerUserId=player.UserId,OriginalOwnerUserId=player.UserId,State="Stored",Provenance={{Kind="Acquired",Time=os.time()}}}
 self.Items[id]=item;table.insert(self.Context.Data:Get(player).Inventory,id);return item
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
 local p=Instance.new("ProximityPrompt");p.ActionText="Inspect / interact";p.ObjectText=Defs[item.DefinitionId].Name;p.MaxActivationDistance=10;p.RequiresLineOfSight=false;p:SetAttribute("Action","Item");p.Parent=root
 return model
end
function Service:Place(player,id,slotNumber)
 local item=self.Items[id];local house=self.Context.Houses.ByPlayer[player.UserId]
 if not item or item.OwnerUserId~=player.UserId or item.State~="Stored" then return false,"Choose an item from your inventory." end
 if not house or type(slotNumber)~="number" or slotNumber%1~=0 or slotNumber<1 or slotNumber>6 then return false,"Choose a display spot." end
 local slot=house.Model.DisplaySlots:FindFirstChild("Slot"..slotNumber)
 local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
 if not root or (root.Position-slot.Position).Magnitude>14 then return false,"Stand near that display spot." end
 for _,other in pairs(self.Items) do if other.HouseId==house.Model.Name and other.Slot==slotNumber and other.State=="Displayed" then return false,"That spot is occupied." end end
 item.State="Displayed";item.HouseId=house.Model.Name;item.Slot=slotNumber
 self:Render(item,slot.CFrame*CFrame.new(0,0.15,0))
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
