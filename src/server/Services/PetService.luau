local Players=game:GetService("Players")
local Pathfinding=game:GetService("PathfindingService")
local Service={Pets={}}
function Service:Init(context)
 self.Context=context
 Players.PlayerRemoving:Connect(function(player)local pet=self.Pets[player.UserId];if pet then pet.Model:Destroy();self.Pets[player.UserId]=nil end end)
 task.spawn(function()while true do task.wait(0.1);self:Step(0.1)end end)
end
function Service:Spawn(player)
 if self.Pets[player.UserId]then return end
 local house=self.Context.Houses.ByPlayer[player.UserId];if not house then return end
 local model=Instance.new("Model");model.Name="Biscuit_"..player.UserId;model.ModelStreamingMode=Enum.ModelStreamingMode.Atomic
 local base=house.Model.Foundation.CFrame*CFrame.new(-9,0,-19)
 local function part(name,size,position,color,round)
  local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=CFrame.new(position);p.Color=color;p.Anchored=true;p.CanCollide=false;p.CanQuery=false;p.CanTouch=false;if round then p.Shape=Enum.PartType.Ball end;p.Parent=model;return p
 end
 local fur=Color3.fromRGB(174,121,72);local dark=Color3.fromRGB(78,57,40)
 local root=part("Body",Vector3.new(1.5,1.3,2.8),Vector3.new(0,1.35,0),fur,false);model.PrimaryPart=root
 part("Head",Vector3.new(1.4,1.4,1.4),Vector3.new(0,2,-1.3),fur,true)
 part("Muzzle",Vector3.new(0.9,0.65,0.9),Vector3.new(0,1.8,-2),Color3.fromRGB(226,193,149),false)
 part("Nose",Vector3.new(0.4,0.3,0.25),Vector3.new(0,1.95,-2.5),dark,true)
 for _,x in ipairs({-0.7,0.7})do part("Ear",Vector3.new(0.35,1.1,0.7),Vector3.new(x,1.8,-1.2),dark,true);part("Eye",Vector3.new(0.15,0.2,0.15),Vector3.new(x*0.6,2.2,-1.9),dark,true)end
 for _,x in ipairs({-0.55,0.55})do for _,z in ipairs({-0.9,0.9})do part("Leg",Vector3.new(0.4,1.1,0.5),Vector3.new(x,0.55,z),fur)end end
 part("Collar",Vector3.new(1.5,0.22,0.7),Vector3.new(0,1.55,-1.05),Color3.fromRGB(35,79,70))
 part("Tail",Vector3.new(0.35,0.4,1.1),Vector3.new(0,1.8,1.8),fur,false)
 for _,p in ipairs(model:GetChildren())do if p:IsA("BasePart") and p~=root then
  p.Anchored=false;p.Massless=true;local weld=Instance.new("WeldConstraint");weld.Part0=root;weld.Part1=p;weld.Parent=p
 end end
 model:PivotTo(base*CFrame.new(0,1.35,0));model.Parent=workspace.Neighborhood.Runtime
 local label=Instance.new("BillboardGui");label.Size=UDim2.fromOffset(100,24);label.StudsOffset=Vector3.new(0,2.5,0);label.MaxDistance=40;label.Parent=root
 local text=Instance.new("TextLabel");text.Size=UDim2.fromScale(1,1);text.BackgroundTransparency=1;text.TextColor3=Color3.fromRGB(244,245,236);text.TextStrokeTransparency=0.5;text.Text="Biscuit";text.Font=Enum.Font.GothamBold;text.TextSize=14;text.Parent=label
 self.Pets[player.UserId]={Model=model,Root=root,NextPath=0,Path={},Waypoint=1,LastAlert=0,Computing=false}
end
function Service:Action(player,action)
 local profile=self.Context.Data:Get(player);if not profile then return false,"Profile unavailable."end
 if action=="Adopt"then
  if profile.Pets.Dog then return false,"Biscuit already lives with you."end
  if profile.Currency<600 then return false,"Adoption supplies cost $600."end
  profile.Currency-=600;profile.Pets.Dog=true;profile.Pets.Mode="Follow";self:Spawn(player);self.Context.Record(player,"Pet")
  return true,"Biscuit is your neighbor now. Your phone switches between follow and stay."
 elseif action=="Follow" or action=="Stay"then
  if not profile.Pets.Dog then return false,"Adopt a companion first."end
  profile.Pets.Mode=action;local pet=self.Pets[player.UserId];if pet then pet.NextPath=0 end
  return true,action=="Follow" and "Biscuit will follow you." or "Biscuit will watch the front yard."
 end
 return false,"Unknown pet command."
end
function Service:Step(dt)
 for id,pet in pairs(self.Pets)do
  local player=Players:GetPlayerByUserId(id);local profile=player and self.Context.Data:Get(player);local house=self.Context.Houses.ByPlayer[id]
  local root=player and player.Character and player.Character:FindFirstChild("HumanoidRootPart")
  if profile and house and root then
   local goal=profile.Pets.Mode=="Stay" and (house.Model.Foundation.CFrame*CFrame.new(-9,1,-19)).Position or (root.CFrame*CFrame.new(3,-1,4)).Position
   if os.clock()>pet.NextPath and not pet.Computing and (goal-pet.Root.Position).Magnitude>3 then
    pet.NextPath=os.clock()+2;pet.Computing=true
    task.spawn(function()
     local path=Pathfinding:CreatePath({AgentRadius=1,AgentHeight=3,AgentCanJump=false,WaypointSpacing=3})
     local ok=pcall(function()path:ComputeAsync(pet.Root.Position,goal)end)
     if ok and path.Status==Enum.PathStatus.Success then pet.Path=path:GetWaypoints();pet.Waypoint=math.min(2,#pet.Path)end
     pet.Computing=false
    end)
   end
   local waypoint=pet.Path[pet.Waypoint]
   if waypoint then
    local target=waypoint.Position+Vector3.new(0,1.35,0);local delta=target-pet.Root.Position
    if delta.Magnitude<0.6 then pet.Waypoint+=1
    else local nextPosition=pet.Root.Position+delta.Unit*math.min(8*dt,delta.Magnitude);local facing=Vector3.new(delta.X,0,delta.Z);if facing.Magnitude>0.01 then pet.Model:PivotTo(CFrame.lookAt(nextPosition,nextPosition+facing.Unit))end end
   end
   if profile.Pets.Mode=="Stay" and os.clock()-pet.LastAlert>30 then
    for _,visitor in ipairs(Players:GetPlayers())do local visitorRoot=visitor.Character and visitor.Character:FindFirstChild("HumanoidRootPart")
     if visitor~=player and visitorRoot and (visitorRoot.Position-house.Door.Position).Magnitude<15 and not (house.Permissions and house.Permissions[tostring(visitor.UserId)])then
      pet.LastAlert=os.clock();house.Model:SetAttribute("PetLastAlert",os.time());self.Context.Notify(player,"Biscuit noticed someone near your front door. A visitor, perhaps?",true);break
     end
    end
   end
  end
 end
end
return Service
