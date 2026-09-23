local Players=game:GetService("Players")
local Config=require(game.ReplicatedStorage.Neighborhood.Shared.Config)
local Defs=require(game.ReplicatedStorage.Neighborhood.Shared.ItemDefinitions)
local Service={Sessions={},Preparing={},Cooldowns={},Breaching={}}
function Service:Init(context)
 self.Context=context
 task.spawn(function()
  while true do task.wait(0.25);self:Step(0.25) end
 end)
end
function Service:Eligible(player,item)
 if player:GetAttribute("DeliveryAddress") then return false,"Deliver or cancel your parcel before lifting a possession."end
 if not item or item.State~="Displayed" or item.OwnerUserId==player.UserId then return false,"Choose a neighbor's displayed possession." end
 if item.RecoveryProtected then return false,"Recovered property is protected for the rest of this playtest." end
 if self.Sessions[player.UserId] or self.Preparing[player.UserId] or self.Breaching[player.UserId] then return false,"Finish your current action first." end
 local house=self.Context.Houses.ById[item.HouseId]
 if not house or house.Owner~=item.OwnerUserId then return false,"This property is unavailable." end
 local owner=Players:GetPlayerByUserId(house.Owner)
 if not owner or not self.Context.Data:CanAct(owner)then return false,"That neighbor is leaving; their home is protected."end
 if (house.Model:GetAttribute("ProtectedUntil") or 0)>os.time() then return false,"This neighbor has moving-in protection. Come back later." end
 if (self.Cooldowns[item.OwnerUserId] or 0)>os.time() then return false,"This neighbor is protected after a recent incident." end
 local model=self.Context.Items.Models[item.Id]
 if not model then return false,"This item has moved." end
 local valid,message=self.Context.Interactions:Validate(player,model.PrimaryPart)
 if not valid then return false,message end
 local permission=house.Permissions and house.Permissions[tostring(player.UserId)]
 if house.Locked and permission~="Friend" and permission~="Roommate" and (house.CompromisedUntil or 0)<os.clock() then return false,"The house is locked. The front door needs to be breached first." end
 return true,house
end
function Service:Breach(player,id)
 local house=self.Context.Houses.ById[id]
 if not house or not house.Owner or house.Owner==player.UserId or not house.Locked then return false,"Choose a neighbor's locked front door." end
 local activeOwner=Players:GetPlayerByUserId(house.Owner)
 if not activeOwner or not self.Context.Data:CanAct(activeOwner)then return false,"That neighbor is leaving; their home is protected."end
 if self.Sessions[player.UserId] or self.Preparing[player.UserId] or self.Breaching[player.UserId] then return false,"Finish your current action first." end
 if (house.Model:GetAttribute("ProtectedUntil") or 0)>os.time() or (self.Cooldowns[house.Owner] or 0)>os.time() then return false,"This neighbor is currently protected." end
 local valid,why=self.Context.Interactions:Validate(player,house.Door);if not valid then return false,why end
 local pending={House=house,Owner=house.Owner,Origin=player.Character.HumanoidRootPart.Position}
 self.Breaching[player.UserId]=pending
 local owner=Players:GetPlayerByUserId(house.Owner);if owner then self.Context.Notify(owner,"Someone is tampering with your front door!",false) end
 local duration=4+(house.Model:GetAttribute("SecurityLevel") or 0)*2
 task.delay(duration,function()
  if self.Breaching[player.UserId]~=pending then return end
  self.Breaching[player.UserId]=nil
  local nearby=self.Context.Interactions:Validate(player,house.Door)
  if player.Parent~=Players or not nearby or house.Owner~=pending.Owner or not house.Locked or (house.Model:GetAttribute("ProtectedUntil") or 0)>os.time() or (self.Cooldowns[house.Owner] or 0)>os.time() then self.Context.Notify(player,"Door tampering interrupted.",false);return end
  house.CompromisedUntil=os.clock()+45;self.Context.Houses:SetDoor(house,true)
  self.Context.Record(player,"Breach")
  self.Context.Notify(player,"The lock gave way. You have 45 seconds before it resets.",true)
  task.delay(45,function()if house.Owner==pending.Owner and house.Locked and (house.CompromisedUntil or 0)<=os.clock() then self.Context.Houses:SetDoor(house,false) end end)
 end)
 return true,"Working on the lock… stay beside the door for "..duration.." seconds."
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
 session.Pose={}
 for _,joint in ipairs(character:GetDescendants())do if (joint:IsA("Motor6D") or joint:IsA("AnimationConstraint")) and joint.Name:lower():find("shoulder")then
  table.insert(session.Pose,{Joint=joint})
 end end
 character:SetAttribute("CarryPose",true)
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
 if session.Player.Character then session.Player.Character:SetAttribute("CarryPose",false)end
 local player=session.Player;player:SetAttribute("Carrying",nil)
 local h=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
 if h then h.WalkSpeed=session.OldWalkSpeed;h.JumpPower=session.OldJumpPower;h.JumpHeight=session.OldJumpHeight end
end
function Service:Drop(player)
 local session=self.Sessions[player.UserId]
 if not session or session.State=="Dropped"then return false,"You're not carrying a possession."end
 local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
 if not root then return false,"Your character is not ready."end
 local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude;params.FilterDescendantsInstances={player.Character,self.Context.Items.Models[session.Item.Id]}
 local offset=root.CFrame.LookVector*2
 local forward=workspace:Raycast(root.Position,offset,params)
 local origin=forward and root.Position or root.Position+offset
 local hit=workspace:Raycast(origin,Vector3.new(0,-12,0),params)
 if not hit then return false,"Find solid ground before setting it down."end
 session.BeforeDrop=session.State;session.State="Dropped";session.DroppedAt=os.clock();session.Item.State="Dropped"
 self:RestoreMovement(session);self.Context.Items:Render(session.Item,CFrame.new(hit.Position+Vector3.new(0,0.15,0)))
 return true,"Set down. Pick it up within 30 seconds or it returns home."
end
function Service:Resume(player,id)
 local session=self.Sessions[player.UserId]
 if not session or session.Item.Id~=id or session.State~="Dropped"then return false,"That isn't your current carry."end
 local model=self.Context.Items.Models[id];local valid,why=self.Context.Interactions:Validate(player,model and model.PrimaryPart)
 if not valid then return false,why end
 local original=session.OriginalCFrame;local incident=session.Incident;local evidence=session.Evidence;local previous=session.BeforeDrop;local started=session.Started
 session.Item.State="Displayed";self.Sessions[player.UserId]=nil
 if not self:Carry(player,session.Item,session.House)then self:Return(session,"Carry could not resume.");return false,"Could not pick up the possession."end
 local resumed=self.Sessions[player.UserId];resumed.OriginalCFrame=original;resumed.Incident=incident;resumed.Evidence=evidence;resumed.State=previous;resumed.Started=started
 resumed.Item.State=previous=="Escaped" and "Escaped" or "Carried"
 return true,"Back in your hands."
end
function Service:Return(session,reason)
 self.Sessions[session.Player.UserId]=nil;self:RestoreMovement(session)
 session.Item.State="Displayed";session.Item.HolderUserId=nil
 self.Context.Items:Render(session.Item,session.OriginalCFrame)
 session.House.Model:SetAttribute("Alarm",false)
 if session.Incident then self.Context.Evidence:Transition(session.Incident,"Recovered","The possession was returned home.") else self.Context.Evidence:Incident(session,"Recovered") end
 self.Context.Notify(session.Player,reason or "The item was recovered.",false)
 self.Context.Sync(session.Player)
 local owner=Players:GetPlayerByUserId(session.Item.OwnerUserId);if owner then self.Context.Sync(owner) end
end
function Service:Recover(player,item)
 if not item or item.OwnerUserId~=player.UserId or not item.HolderUserId then return false,"That is not your missing possession." end
 local session=self.Sessions[item.HolderUserId];if not session then return false,"The item is no longer being carried." end
 self:Return(session,"The homeowner recovered their possession.")
 self.Context.Record(player,"Recovery")
 return true,"Recovered. Back where it belongs."
end
function Service:Step()
 local now=os.clock()
 for userId,pending in pairs(self.Breaching) do
  local player=Players:GetPlayerByUserId(userId);local root=player and player.Character and player.Character:FindFirstChild("HumanoidRootPart")
  if not root or (root.Position-pending.Origin).Magnitude>4 then self.Breaching[userId]=nil;if player then self.Context.Notify(player,"Door tampering cancelled because you moved away.",false) end end
 end
 for userId,pending in pairs(self.Preparing) do
  local player=Players:GetPlayerByUserId(userId);local root=player and player.Character and player.Character:FindFirstChild("HumanoidRootPart")
  if not root or (root.Position-pending.Origin).Magnitude>4 then self.Preparing[userId]=nil;if player then self.Context.Notify(player,"Lift cancelled. Stay beside the item.",false) end end
 end
 for _,session in pairs(self.Sessions) do
  local p=session.Player;local root=p.Character and p.Character:FindFirstChild("HumanoidRootPart");local h=p.Character and p.Character:FindFirstChildOfClass("Humanoid")
  if session.State=="Dropped"then
   if now-session.DroppedAt>=30 then self:Return(session,"The unattended possession returned home.")end
  elseif not root or not h or h.Health<=0 then self:Return(session,"Carry interrupted. The item returned home.")
  else
   local elapsed=math.max(now-session.LastTime,0.01)
   if (root.Position-session.LastPosition).Magnitude>math.max(8,h.WalkSpeed*elapsed*2+3) then
    self:Return(session,"Carry interrupted by an invalid movement.")
   else
    session.LastPosition=root.Position;session.LastTime=now
    if session.State=="Escaping" and not (self.Context.Building and self.Context.Building:ContainsExpansion(session.House,root.Position)) and now-session.Started>=Config.EscapeSeconds and (root.Position-session.House.Door.Position).Magnitude>=Config.EscapeDistance then
     session.State="Escaped";session.Item.State="Escaped";session.House.Model:SetAttribute("Alarm",false)
     self.Cooldowns[session.Item.OwnerUserId]=os.time()+Config.VictimCooldown
     self.Context.Evidence:Incident(session,"Missing")
     self.Context.Record(p,session.Item.DefinitionId=="GoldenToilet" and "GoldenEscape" or "Escape")
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
 self.Sessions[player.UserId]=nil;item.State="Fenced";item.HolderUserId=nil
 table.insert(item.Provenance,{Kind="Fenced",Time=os.time()});while #item.Provenance>12 do table.remove(item.Provenance,1)end
 if session.Incident then self.Context.Evidence:Transition(session.Incident,"Fenced","A matching possession appeared at the pawn counter.") end
 local model=self.Context.Items.Models[item.Id];if model then model:Destroy();self.Context.Items.Models[item.Id]=nil end
 self:RestoreMovement(session)
 local owner=Players:GetPlayerByUserId(item.OwnerUserId);if owner then self.Context.Notify(owner,"The pawn counter has a possession matching your case. Visit to reclaim it.",true);self.Context.Sync(owner) end
 local settled=owner and self.Context.Data:Transfer(owner,player.UserId,payout)
 if not settled then return true,"Sale recorded; payment is pending a safe save."end
 return true,"Sold for $"..payout..". The paperwork is… somewhere."
end
function Service:Reclaim(player,id)
 local item=self.Context.Items.Items[id]
 if not item or item.OwnerUserId~=player.UserId or item.State~="Fenced" then return false,"No matching property is waiting for you." end
 if not self.Context.Economy:Near(player,"PawnShop") then return false,"Visit the pawn counter to identify your property." end
 local profile=self.Context.Data:Get(player)
 if not profile then return false,"Your profile is unavailable." end
 -- Preserve the original ID and prevent repeated fence/reclaim currency farming.
 item.State="Stored";item.HouseId=nil;item.Slot=nil;item.RecoveryProtected=true
 table.insert(item.Provenance,{Kind="Recovered",Time=os.time()});while #item.Provenance>12 do table.remove(item.Provenance,1)end
 for _,incident in ipairs(profile.Incidents) do if incident.ItemId==id and incident.Status~="Recovered" then self.Context.Evidence:Transition(incident,"Recovered","The homeowner reclaimed the original possession at the pawn counter.") end end
 self.Context.Record(player,"Recovery")
 return true,"Reclaimed. This item is protected from theft for the rest of the playtest."
end
function Service:Release(player)
 self.Preparing[player.UserId]=nil
 self.Breaching[player.UserId]=nil
 local own=self.Sessions[player.UserId];if own then self:Return(own,"Carry ended on disconnect.") end
 for _,s in pairs(self.Sessions) do if s.Item.OwnerUserId==player.UserId then self:Return(s,"The owner left. The item returned safely.") end end
end
return Service
