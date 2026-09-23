local Players=game:GetService("Players")
local Config=require(game.ReplicatedStorage.Neighborhood.Shared.Config)
local Defs=require(game.ReplicatedStorage.Neighborhood.Shared.ItemDefinitions)
local Service={Sessions={},Preparing={},Cooldowns={}}
function Service:Init(context)
 self.Context=context
 task.spawn(function()
  while true do task.wait(0.25);self:Step(0.25) end
 end)
end
function Service:Eligible(player,item)
 if not item or item.State~="Displayed" or item.OwnerUserId==player.UserId then return false,"Choose a neighbor's displayed possession." end
 if self.Sessions[player.UserId] or self.Preparing[player.UserId] then return false,"Your hands are already full." end
 local house=self.Context.Houses.ById[item.HouseId]
 if not house or house.Owner~=item.OwnerUserId then return false,"This property is unavailable." end
 if (house.Model:GetAttribute("ProtectedUntil") or 0)>os.time() then return false,"This neighbor has moving-in protection. Come back later." end
 if (self.Cooldowns[item.OwnerUserId] or 0)>os.time() then return false,"This neighbor is protected after a recent incident." end
 local model=self.Context.Items.Models[item.Id]
 if not model then return false,"This item has moved." end
 local valid,message=self.Context.Interactions:Validate(player,model.PrimaryPart)
 if not valid then return false,message end
 if house.Locked then return false,"The house is locked. Ask to visit or find an unlocked home." end
 return true,house
end
function Service:Begin(player,id)
 local item=self.Context.Items.Items[id]
 local ok,house=self:Eligible(player,item);if not ok then return false,house end
 self.Preparing[player.UserId]={ItemId=id,Started=os.clock(),Origin=player.Character.HumanoidRootPart.Position}
 self.Context.Notify(player,"Lifting it… stay close. The display alarm will notice.",true)
 task.delay(2.5,function()
  local pending=self.Preparing[player.UserId]
  if not pending or pending.ItemId~=id then return end
  self.Preparing[player.UserId]=nil
  if player.Parent~=Players then return end
  local stillValid,currentHouse=self:Eligible(player,item)
  if not stillValid then self.Context.Notify(player,currentHouse,false);return end
  self:Carry(player,item,currentHouse)
 end)
 return true,"Lifting…"
end
function Service:Carry(player,item,house)
 local character=player.Character;local root=character and character:FindFirstChild("HumanoidRootPart");local humanoid=character and character:FindFirstChildOfClass("Humanoid")
 if not root or not humanoid or humanoid.Health<=0 then return false end
 -- The no-yield transition ensures two simultaneous thieves cannot acquire the same item.
 if item.State~="Displayed" then return false end
 local model=self.Context.Items.Models[item.Id]
 local session={Item=item,House=house,OriginalCFrame=model:GetPivot(),Started=os.clock(),State="Escaping",LastPosition=root.Position,LastTime=os.clock(),OldWalkSpeed=humanoid.WalkSpeed,OldJumpPower=humanoid.JumpPower,OldJumpHeight=humanoid.JumpHeight,Player=player}
 session.Evidence=self.Context.Evidence:Observe(player,house,item)
 item.State="Carried";item.HolderUserId=player.UserId
 self.Sessions[player.UserId]=session;house.Model:SetAttribute("Alarm",true)
 local speed=math.clamp(Config.WalkSpeed/(1+Defs[item.DefinitionId].Weight/30),5,14)
 humanoid.WalkSpeed=speed;humanoid.JumpPower=0;humanoid.JumpHeight=0
 model:PivotTo(root.CFrame*CFrame.new(0,-1,-3.6))
 for _,p in ipairs(model:GetDescendants()) do if p:IsA("BasePart") then
  p.Anchored=false;p.Massless=true;p.CanCollide=false
  if p~=model.PrimaryPart then local w=Instance.new("WeldConstraint");w.Part0=model.PrimaryPart;w.Part1=p;w.Parent=p end
 end end
 local weld=Instance.new("WeldConstraint");weld.Name="CarryWeld";weld.Part0=root;weld.Part1=model.PrimaryPart;weld.Parent=model.PrimaryPart
 player:SetAttribute("Carrying",Defs[item.DefinitionId].Name)
 local owner=Players:GetPlayerByUserId(item.OwnerUserId)
 if owner then self.Context.Notify(owner,"Your display alarm is ringing. Catch the item to recover it!",false);self.Context.Sync(owner) end
 self.Context.Notify(player,"You're carrying "..Defs[item.DefinitionId].Name..". Reach the street and keep moving.",true)
 self.Context.Sync(player)
 return true
end
function Service:RestoreMovement(session)
 local player=session.Player;player:SetAttribute("Carrying",nil)
 local h=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
 if h then h.WalkSpeed=session.OldWalkSpeed;h.JumpPower=session.OldJumpPower;h.JumpHeight=session.OldJumpHeight end
end
function Service:Return(session,reason)
 self.Sessions[session.Player.UserId]=nil;self:RestoreMovement(session)
 session.Item.State="Displayed";session.Item.HolderUserId=nil
 self.Context.Items:Render(session.Item,session.OriginalCFrame)
 session.House.Model:SetAttribute("Alarm",false)
 if session.Incident then session.Incident.Status="Recovered" else self.Context.Evidence:Incident(session,"Recovered") end
 self.Context.Notify(session.Player,reason or "The item was recovered.",false)
 self.Context.Sync(session.Player)
 local owner=Players:GetPlayerByUserId(session.Item.OwnerUserId);if owner then self.Context.Sync(owner) end
end
function Service:Recover(player,item)
 if not item or item.OwnerUserId~=player.UserId or not item.HolderUserId then return false,"That is not your missing possession." end
 local session=self.Sessions[item.HolderUserId];if not session then return false,"The item is no longer being carried." end
 self:Return(session,"The homeowner recovered their possession.")
 return true,"Recovered. Back where it belongs."
end
function Service:Step()
 local now=os.clock()
 for userId,pending in pairs(self.Preparing) do
  local player=Players:GetPlayerByUserId(userId);local root=player and player.Character and player.Character:FindFirstChild("HumanoidRootPart")
  if not root or (root.Position-pending.Origin).Magnitude>4 then self.Preparing[userId]=nil;if player then self.Context.Notify(player,"Lift cancelled. Stay beside the item.",false) end end
 end
 for _,session in pairs(self.Sessions) do
  local p=session.Player;local root=p.Character and p.Character:FindFirstChild("HumanoidRootPart");local h=p.Character and p.Character:FindFirstChildOfClass("Humanoid")
  if not root or not h or h.Health<=0 then self:Return(session,"Carry interrupted. The item returned home.")
  else
   local elapsed=math.max(now-session.LastTime,0.01)
   if (root.Position-session.LastPosition).Magnitude>math.max(8,h.WalkSpeed*elapsed*2+3) then
    self:Return(session,"Carry interrupted by an invalid movement.")
   else
    session.LastPosition=root.Position;session.LastTime=now
    if session.State=="Escaping" and now-session.Started>=Config.EscapeSeconds and (root.Position-session.House.Door.Position).Magnitude>=Config.EscapeDistance then
     session.State="Escaped";session.Item.State="Escaped";session.House.Model:SetAttribute("Alarm",false)
     self.Cooldowns[session.Item.OwnerUserId]=os.time()+Config.VictimCooldown
     self.Context.Evidence:Incident(session,"Missing")
     self.Context.Notify(p,"Clear of the house. The pawn shop buys questionable things.",true);self.Context.Sync(p)
    end
   end
  end
 end
end
function Service:Fence(player)
 local session=self.Sessions[player.UserId]
 if not session or session.State~="Escaped" then return false,"Escape the property before making a deal." end
 if not self.Context.Economy:Near(player,"PawnShop") then return false,"Visit the pawn counter." end
 local item=session.Item;local def=Defs[item.DefinitionId];local payout=def.FenceValue or math.floor(def.Value*0.3)
 local buyer=self.Context.Data:Get(player)
 if not buyer then return false,"Your profile is unavailable." end
 -- One terminal state, one payout. No yields or client-supplied prices.
 self.Sessions[player.UserId]=nil;item.State="Sold";item.HolderUserId=nil;buyer.Currency+=payout
 local victim=self.Context.Data.Profiles[item.OwnerUserId]
 if victim then local at=table.find(victim.Inventory,item.Id);if at then table.remove(victim.Inventory,at) end end
 if session.Incident then session.Incident.Status="Fenced" end
 local model=self.Context.Items.Models[item.Id];if model then model:Destroy();self.Context.Items.Models[item.Id]=nil end
 self.Context.Items.Items[item.Id]=nil;self:RestoreMovement(session)
 return true,"Sold for $"..payout..". The paperwork is… somewhere."
end
function Service:Release(player)
 self.Preparing[player.UserId]=nil
 local own=self.Sessions[player.UserId];if own then self:Return(own,"Carry ended on disconnect.") end
 for _,s in pairs(self.Sessions) do if s.Item.OwnerUserId==player.UserId then self:Return(s,"The owner left. The item returned safely.") end end
end
return Service
