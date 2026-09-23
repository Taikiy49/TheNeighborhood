local Service={Jobs={},Last={}}
function Service:Init(context)
 self.Context=context
 context.Interactions:Register("Delivery",function(player)
  if self.Jobs[player.UserId] then return false,"Deliver the parcel to the address in your notification first." end
  if os.clock()-(self.Last[player.UserId] or -60)<20 then return false,"The next parcel is being sorted. Explore a little first." end
  local houses=workspace.Neighborhood.Houses:GetChildren();table.sort(houses,function(a,b)return a.Name<b.Name end)
  local house=houses[math.random(1,#houses)]
  self.Jobs[player.UserId]={HouseId=house.Name,Started=os.clock()};self.Last[player.UserId]=os.clock()
  player:SetAttribute("DeliveryAddress",house:GetAttribute("Address"))
  return true,"Deliver a parcel to "..house:GetAttribute("Address")..". Use its mailbox."
 end)
 context.Interactions:Register("Deliver",function(player,target)
  local job=self.Jobs[player.UserId]
  if not job then return false,"Pick up a parcel at the community board." end
  if job.HouseId~=target:GetAttribute("HouseId") then return false,"Check the address. This is not the right mailbox." end
  if os.clock()-job.Started<8 then return false,"That delivery was too fast. Try again in a moment." end
  self.Jobs[player.UserId]=nil;player:SetAttribute("DeliveryAddress",nil)
  self.Context.Data:Get(player).Currency+=180
  self.Context.Record(player,"Delivery")
  return true,"Delivered. You earned $180 — honestly, for once."
 end)
 game.Players.PlayerRemoving:Connect(function(player)self.Jobs[player.UserId]=nil;self.Last[player.UserId]=nil end)
end
return Service
