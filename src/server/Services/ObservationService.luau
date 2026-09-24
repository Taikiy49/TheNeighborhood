local Players=game:GetService("Players")
local Definitions=require(game.ReplicatedStorage.Neighborhood.Shared.ItemDefinitions)
local Service={Last={}}
function Service:Init(context)
 self.Context=context
 Players.PlayerRemoving:Connect(function(p)self.Last[p.UserId]=nil end)
 task.spawn(function()
  while true do
   task.wait(15)
   for _,player in ipairs(Players:GetPlayers())do local heat=player:GetAttribute("Heat") or 0;if heat>0 then player:SetAttribute("Heat",math.max(0,heat-1))end end
  end
 end)
end
function Service:Visible(player,part,range)
 local character=player.Character;local head=character and character:FindFirstChild("Head")
 local humanoid=character and character:FindFirstChildOfClass("Humanoid")
 if not head or not humanoid or humanoid.Health<=0 or (part.Position-head.Position).Magnitude>range then return false end
 local query=RaycastParams.new();query.FilterType=Enum.RaycastFilterType.Exclude;query.FilterDescendantsInstances={character}
 local hit=workspace:Raycast(head.Position,part.Position-head.Position,query)
 return not hit or hit.Instance==part or hit.Instance:IsDescendantOf(part.Parent) and part.Parent:IsA("Model") and part.Parent:GetAttribute("ItemId")~=nil
end
function Service:Survey(player,id)
 local house=self.Context.Houses.ById[id]
 local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
 if not house or not root or (root.Position-house.Model.Foundation.Position).Magnitude>90 then return false,"Walk over to that house before looking around."end
 if os.clock()-(self.Last[player.UserId] or -10)<3 then return false,"Take a moment to look around."end
 self.Last[player.UserId]=os.clock()
 local lines={};local seen=0
 for itemId,item in pairs(self.Context.Items.Items)do
  local model=self.Context.Items.Models[itemId]
  if item.HouseId==id and item.State=="Displayed" and model and model.PrimaryPart and self:Visible(player,model.PrimaryPart,70)then
   seen+=1;table.insert(lines,{Definitions[item.DefinitionId].Name,"Visible possession · "..Definitions[item.DefinitionId].Rarity})
  end
 end
 if seen==0 then table.insert(lines,{"No possessions in view","Walls and closed doors hide what you cannot see. Try another viewpoint."})end
 local camera=house.Model:FindFirstChild("SecurityCamera")
 if camera and self:Visible(player,camera,35)then table.insert(lines,{"Front camera spotted","A camera covers part of this home. A visible camera does not reveal its complete coverage."})end
 if self:Visible(player,house.Door,20)then table.insert(lines,{"Front entrance",house.Locked and "The front-door lock is engaged." or "The front-door lock is open."})end
 table.insert(lines,{"Unknown areas","Unseen rooms and possessions stay unknown. This report only describes your current view."})
 self.Context.Open(player,"Survey",{Name=house.Model:GetAttribute("Address"),Lines=lines})
 return true,"Observation recorded from your current viewpoint."
end
function Service:HouseValue(player)
 if not self.Context then return 0 end
 local house=self.Context.Houses.ByPlayer[player.UserId];if not house then return 0 end
 local value=0
 for _,item in pairs(self.Context.Items.Items)do if item.OwnerUserId==player.UserId and item.State=="Displayed" and item.HouseId==house.Model.Name then value+=Definitions[item.DefinitionId].Value end end
 local profile=self.Context.Data:Get(player)
 return value+(profile and (profile.House.SecurityLevel or 0)*350 or 0)
end
return Service
