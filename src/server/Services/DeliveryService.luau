local Players=game:GetService("Players")
local Config=require(game.ReplicatedStorage.Neighborhood.Shared.Config)
local Service={Jobs={},Last={}}
function Service:Cancel(player)
 local job=self.Jobs[player.UserId];self.Jobs[player.UserId]=nil
 if job and job.Parcel then job.Parcel:Destroy()end
 player:SetAttribute("DeliveryAddress",nil)
 if player.Character and not player:GetAttribute("Carrying")then player.Character:SetAttribute("CarryPose",false)end
 return job~=nil
end
function Service:Start(player)
 if self.Jobs[player.UserId]then return false,"Deliver or cancel your current parcel first."end
 if player:GetAttribute("Carrying") or self.Context.Robbery.Preparing[player.UserId]then return false,"Finish carrying that possession first."end
 local valid,why=self.Context.Interactions:Validate(player,workspace.Neighborhood.Map.CommunityBoard)
 if not valid then return false,why end
 if os.clock()-(self.Last[player.UserId] or -60)<Config.DeliveryCooldown then return false,"The next parcel is being sorted. Explore a little first."end
 local houses=workspace.Neighborhood.Houses:GetChildren();table.sort(houses,function(a,b)return a.Name<b.Name end)
 local house=houses[math.random(1,#houses)]
 local root=player.Character.HumanoidRootPart
 local parcel=Instance.new("Part");parcel.Name="DeliveryParcel";parcel.Size=Vector3.new(2.4,1.7,1.7);parcel.Color=Color3.fromRGB(183,141,90);parcel.Material=Enum.Material.Cardboard;parcel.CanCollide=false;parcel.CanTouch=false;parcel.CanQuery=false;parcel.Massless=true;parcel.CFrame=root.CFrame*CFrame.new(0,-0.2,-1.5);parcel.Parent=player.Character
 local tape=Instance.new("Part");tape.Name="Tape";tape.Size=Vector3.new(0.35,1.72,1.72);tape.Color=Color3.fromRGB(230,208,149);tape.CanCollide=false;tape.CanTouch=false;tape.CanQuery=false;tape.Massless=true;tape.CFrame=parcel.CFrame;tape.Parent=parcel
 local tapeWeld=Instance.new("WeldConstraint");tapeWeld.Part0=parcel;tapeWeld.Part1=tape;tapeWeld.Parent=tape
 local weld=Instance.new("WeldConstraint");weld.Part0=root;weld.Part1=parcel;weld.Parent=parcel
 self.Jobs[player.UserId]={HouseId=house.Name,Started=os.clock(),Parcel=parcel,LastPosition=root.Position,LastTime=os.clock()}
 self.Last[player.UserId]=os.clock();player:SetAttribute("DeliveryAddress",house:GetAttribute("Address"));player.Character:SetAttribute("CarryPose",true)
 return true,"Deliver this parcel to "..house:GetAttribute("Address")..". Use its mailbox."
end
function Service:Complete(player,target)
 local job=self.Jobs[player.UserId]
 if not job then return false,"Pick up a parcel at the community board."end
 local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
 if not root or (root.Position-job.LastPosition).Magnitude>Config.DeliveryTravelSpeed*(os.clock()-job.LastTime)+12 then self:Cancel(player);return false,"The parcel route was interrupted."end
 local valid,why=self.Context.Interactions:Validate(player,target);if not valid then return false,why end
 local house=self.Context.Houses.ById[job.HouseId]
 if not house or target~=house.Model.Mailbox.Box then return false,"Check the address. This is not the right mailbox."end
 if os.clock()-job.Started<Config.DeliveryMinimumSeconds then return false,"That delivery was too fast. Try again in a moment."end
 local profile=self.Context.Data:Get(player);if not profile then return false,"Profile unavailable."end
 self:Cancel(player);profile.Currency+=Config.DeliveryReward;self.Context.Record(player,"Delivery")
 return true,"Delivered. You earned $"..Config.DeliveryReward.." — honestly, for once."
end
function Service:Step()
 for id,job in pairs(self.Jobs)do
  local player=Players:GetPlayerByUserId(id);local root=player and player.Character and player.Character:FindFirstChild("HumanoidRootPart")
  local humanoid=root and player.Character:FindFirstChildOfClass("Humanoid")
  local now=os.clock()
  if not root or not humanoid or humanoid.Health<=0 or not job.Parcel.Parent then if player then self:Cancel(player)else self.Jobs[id]=nil end
  elseif (root.Position-job.LastPosition).Magnitude>Config.DeliveryTravelSpeed*(now-job.LastTime)+12 then
   self:Cancel(player);self.Context.Notify(player,"The parcel route was interrupted. Pick up another at the board.",false)
  else job.LastPosition=root.Position;job.LastTime=now end
 end
end
function Service:Init(context)
 self.Context=context
 context.Interactions:Register("Delivery",function(player)return self:Start(player)end)
 context.Interactions:Register("Deliver",function(player,target)return self:Complete(player,target)end)
 local function added(player)player.CharacterRemoving:Connect(function()self:Cancel(player)end)end
 Players.PlayerAdded:Connect(added);for _,player in ipairs(Players:GetPlayers())do added(player)end
 Players.PlayerRemoving:Connect(function(player)self:Cancel(player);self.Last[player.UserId]=nil end)
 task.spawn(function()while true do task.wait(0.25);self:Step()end end)
end
return Service
