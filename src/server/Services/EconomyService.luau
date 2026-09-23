local Defs=require(game.ReplicatedStorage.Neighborhood.Shared.ItemDefinitions)
local Config=require(game.ReplicatedStorage.Neighborhood.Shared.Config)
local Service={}
function Service:Init(context) self.Context=context end
function Service:Near(player,shopName)
 local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
 local humanoid=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
 return root and humanoid and humanoid.Health>0 and (root.Position-workspace.Neighborhood.Shops[shopName].Counter.Position).Magnitude<14
end
function Service:Buy(player,id)
 local def=Defs[id];local data=self.Context.Data:Get(player)
 if not def or not data then return false,"Unknown item." end
 if not self:Near(player,"GeneralStore") then return false,"Visit Maple & Co. to buy this." end
 if #data.Inventory>=Config.MaxInventory then return false,"Your inventory is full." end
 local price=math.floor(def.Value*math.clamp(workspace.Neighborhood:GetAttribute("SaleMultiplier") or 1,0.5,1))
 if data.Currency<price then return false,"You need $"..price.." for this item." end
 -- No yields between validation, debit and item creation.
 local item=self.Context.Items:Create(player,id)
 if not item then return false,"Purchase failed. Your money was not spent." end
 data.Currency-=price
 self.Context.Record(player,"Buy")
 return true,"Purchased "..def.Name..". Place it at home."
end
function Service:Sell(player,id)
 local item=self.Context.Items.Items[id];local data=self.Context.Data:Get(player)
 if not item or item.OwnerUserId~=player.UserId or item.State~="Stored" then return false,"Only stored items you own can be sold." end
 if not self:Near(player,"PawnShop") then return false,"Visit the pawn counter first." end
 local def=Defs[item.DefinitionId];local payout=math.floor(def.Value*0.4)
 item.State="Sold";data.Currency+=payout
 local at=table.find(data.Inventory,id);if at then table.remove(data.Inventory,at) end
 self.Context.Items.Items[id]=nil
 self.Context.Record(player,"Sell")
 return true,"Sold "..def.Name.." for $"..payout.."."
end
return Service
