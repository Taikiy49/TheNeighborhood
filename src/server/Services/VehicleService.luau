local Space=require(game.ReplicatedStorage.Neighborhood.Shared.WorldSpace)
local Players=game:GetService("Players")
local Run=game:GetService("RunService")
local Physics=game:GetService("PhysicsService")
local Service={Cars={},InputTimes={}}
local colors={Mint=Color3.fromRGB(111,166,141),Peach=Color3.fromRGB(220,149,109),Blue=Color3.fromRGB(104,150,186),Butter=Color3.fromRGB(224,193,100)}
function Service:Init(context)
 self.Context=context
 pcall(function()Physics:RegisterCollisionGroup("NeighborhoodCars")end)
 pcall(function()Physics:RegisterCollisionGroup("NeighborhoodCharacters")end)
 Physics:CollisionGroupSetCollidable("NeighborhoodCars","NeighborhoodCharacters",false)
 local function character(character)
  local function part(v)if v:IsA("BasePart")then v.CollisionGroup="NeighborhoodCharacters"end end
  character.DescendantAdded:Connect(part);for _,v in ipairs(character:GetDescendants())do part(v)end
 end
 local function added(p)p.CharacterAdded:Connect(character);if p.Character then character(p.Character)end end
 Players.PlayerAdded:Connect(added);for _,p in ipairs(Players:GetPlayers())do added(p)end
 Players.PlayerRemoving:Connect(function(p)self:Remove(p);self.InputTimes[p.UserId]=nil end)
 context.Interactions:Register("DriveCar",function(player,target)
  local car=self.Cars[player.UserId]
  if not car or car.Seat~=target then return false,"Only the owner has these car keys."end
  if player:GetAttribute("Carrying")then return false,"Set the possession down before driving."end
  car.Seat:Sit(player.Character.Humanoid);car.Body:SetNetworkOwner(nil)
  return true,"Use your movement controls to drive. Jump to get out."
 end)
 local remotes=game.ReplicatedStorage.Neighborhood.Remotes
 local drive=remotes:FindFirstChild("Drive") or Instance.new("RemoteEvent");drive.Name="Drive";drive.Parent=remotes
 drive.OnServerEvent:Connect(function(player,throttle,steer)self:Input(player,throttle,steer)end)
 Run.Heartbeat:Connect(function(dt)self:Step(math.min(dt,0.1))end)
end
function Service:Input(player,throttle,steer)
 local car=self.Cars[player.UserId]
 if not car or not car.Seat.Occupant or car.Seat.Occupant.Parent~=player.Character then return false end
 if type(throttle)~="number" or type(steer)~="number" or throttle~=throttle or steer~=steer or math.abs(throttle)>1 or math.abs(steer)>1 then return false end
 local now=os.clock();if now-(self.InputTimes[player.UserId] or 0)<0.08 then return false end
 self.InputTimes[player.UserId]=now;car.Throttle=throttle;car.Steer=steer;car.LastInput=now;return true
end
function Service:Remove(player)
 local car=self.Cars[player.UserId];if car then if car.Seat.Occupant then car.Seat.Occupant.Sit=false end;car.Model:Destroy();self.Cars[player.UserId]=nil end
end
function Service:Spawn(player)
 local profile=self.Context.Data:Get(player);local house=self.Context.Houses.ByPlayer[player.UserId]
 if not profile or not profile.Vehicles.Compact or not house then return false,"Buy a Maple Compact first."end
 local previous=self.Cars[player.UserId];if previous and previous.Seat.Occupant then return false,"Get out before recalling the car."end
 local cf=house.Model.Foundation.CFrame*(profile.Building.Unlocked.Garage and Space.Frame(-20,3.5,-23)or Space.Frame(-12,3.5,-25))
 local query=OverlapParams.new();query.FilterType=Enum.RaycastFilterType.Exclude;query.FilterDescendantsInstances={player.Character,previous and previous.Model or house.Model};query.RespectCanCollide=true
 if #workspace:GetPartBoundsInBox(cf,Vector3.new(7,4,10),query)>0 then return false,"Clear the driveway before recalling your car."end
 self:Remove(player)
 local model=Instance.new("Model");model.Name="MapleCompact_"..player.UserId;model.ModelStreamingMode=Enum.ModelStreamingMode.Atomic;model:SetAttribute("OwnerUserId",player.UserId)
 local color=colors[profile.Vehicles.Color] or colors.Mint
 local function part(name,size,offset,tint,class)
  local p=Instance.new(class or "Part");p.Name=name;p.Size=size;p.CFrame=cf*CFrame.new(offset);p.Color=tint;p.Anchored=false;p.CanTouch=false;p.CollisionGroup="NeighborhoodCars";p.CustomPhysicalProperties=PhysicalProperties.new(0.7,0.1,0.1,1,1);p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=model;return p
 end
 local body=part("Body",Vector3.new(6,1.4,9),Vector3.zero,color);model.PrimaryPart=body
 local seat=part("DriverSeat",Vector3.new(2,0.7,2),Vector3.new(0,1.05,0),Color3.fromRGB(50,65,60),"VehicleSeat");seat.HeadsUpDisplay=false;seat.MaxSpeed=28;seat.CanCollide=false
 part("Hood",Vector3.new(5.8,1,2.7),Vector3.new(0,1,-3),color)
 part("Rear",Vector3.new(5.8,1,1.8),Vector3.new(0,1,3.3),color)
 for _,x in ipairs({-3.2,3.2})do for _,z in ipairs({-2.8,2.8})do local wheel=part("Wheel",Vector3.new(0.8,2.2,2.2),Vector3.new(x,-0.8,z),Color3.fromRGB(40,46,44));wheel.Shape=Enum.PartType.Cylinder;wheel.CanCollide=false end end
 for _,x in ipairs({-2,2})do part("Headlight",Vector3.new(1,0.5,0.15),Vector3.new(x,0.5,-4.55),Color3.fromRGB(255,231,172)).Material=Enum.Material.Neon end
 local plate=part("Plate",Vector3.new(2.4,0.7,0.1),Vector3.new(0,-0.1,4.6),Color3.fromRGB(244,235,204));plate.CanCollide=false
 local sign=Instance.new("SurfaceGui");sign.Face=Enum.NormalId.Back;sign.CanvasSize=Vector2.new(240,70);sign.Parent=plate
 local text=Instance.new("TextLabel");text.Size=UDim2.fromScale(1,1);text.BackgroundTransparency=1;text.Font=Enum.Font.GothamBold;text.TextSize=30;text.TextColor3=Color3.fromRGB(35,79,70);text.Text=profile.Vehicles.Plate;text.Parent=sign
 for _,p in ipairs(model:GetChildren())do if p:IsA("BasePart") and p~=body then p.Massless=true;local weld=Instance.new("WeldConstraint");weld.Part0=body;weld.Part1=p;weld.Parent=p end end
 local attachment=Instance.new("Attachment");attachment.Parent=body
 local force=Instance.new("VectorForce");force.Attachment0=attachment;force.RelativeTo=Enum.ActuatorRelativeTo.World;force.ApplyAtCenterOfMass=true;force.Parent=body
 local turn=Instance.new("AlignOrientation");turn.Attachment0=attachment;turn.Mode=Enum.OrientationAlignmentMode.OneAttachment;turn.MaxTorque=100000;turn.Responsiveness=12;turn.Parent=body
 local _,yaw=cf:ToOrientation()
 model.Parent=workspace.Neighborhood.Runtime;body:SetNetworkOwner(nil)
 self.Cars[player.UserId]={Model=model,Body=body,Seat=seat,Force=force,Turn=turn,Yaw=yaw,Throttle=0,Steer=0,LastInput=0}
 seat:SetAttribute("Action","DriveCar");seat:SetAttribute("VehicleOwner",player.UserId)
 local prompt=Instance.new("ProximityPrompt");prompt.Style=Enum.ProximityPromptStyle.Custom;prompt.ActionText="Drive";prompt.ObjectText="Maple Compact";prompt.MaxActivationDistance=10;prompt.RequiresLineOfSight=false;prompt:SetAttribute("Action","DriveCar");prompt.Parent=seat
 return true,"Your Maple Compact is in the driveway."
end
function Service:Action(player,action,argument)
 local profile=self.Context.Data:Get(player);if not profile then return false,"Profile unavailable."end
 if action=="Buy"then
  if profile.Vehicles.Compact then return false,"You already own a Maple Compact."end
  if profile.Currency<2400 then return false,"A Maple Compact costs $2400."end
  profile.Currency-=2400;profile.Vehicles.Compact=true;profile.Vehicles.Color="Mint";profile.Vehicles.Plate="MAP-"..game:GetService("HttpService"):GenerateGUID(false):sub(1,5):upper()
  self.Context.Record(player,"Vehicle");local spawned,message=self:Spawn(player);return true,spawned and message or "Purchased. Clear the driveway, then recall it from your phone."
 elseif action=="Recall"then return self:Spawn(player)
 elseif action=="Color"then
  if not profile.Vehicles.Compact or not colors[argument]then return false,"Choose an available car color."end
  profile.Vehicles.Color=argument;local car=self.Cars[player.UserId];if car then for _,part in ipairs(car.Model:GetChildren())do if part.Name=="Body" or part.Name=="Hood" or part.Name=="Rear"then part.Color=colors[argument]end end end
  return true,"Car repainted."
 end
 return false,"Unknown garage action."
end
function Service:Step(dt)
 for _,car in pairs(self.Cars)do
  local occupied=car.Seat.Occupant~=nil;local fresh=os.clock()-car.LastInput<0.8
  local throttle=occupied and fresh and car.Throttle or 0;local steer=occupied and fresh and car.Steer or 0
  local velocity=car.Body.AssemblyLinearVelocity;local flat=Vector3.new(velocity.X,0,velocity.Z)
  car.Yaw-=steer*dt*1.7*math.clamp(flat.Magnitude/12,0,1)*(throttle<0 and -1 or 1)
  car.Turn.CFrame=CFrame.Angles(0,car.Yaw,0)
  local target=car.Body.CFrame.LookVector*(throttle*28);target=Vector3.new(target.X,0,target.Z)
  -- Four ground samples provide arcade suspension; decorative rigid wheels cannot snag curbs.
  local query=RaycastParams.new();query.FilterType=Enum.RaycastFilterType.Exclude;query.FilterDescendantsInstances={car.Model};query.CollisionGroup="NeighborhoodCars";query.RespectCanCollide=true
  local ground=0;local samples=0
  for _,x in ipairs({-2.3,2.3})do for _,z in ipairs({-2.8,2.8})do
   local origin=car.Body.CFrame:PointToWorldSpace(Vector3.new(x,0.5,z))
   local hit=workspace:Raycast(origin,Vector3.new(0,-4,0),query)
   if hit and hit.Normal.Y>0.65 then ground+=hit.Position.Y;samples+=1 end
  end end
  local lift=0
  if samples>=2 then lift=math.clamp(workspace.Gravity+(ground/samples+1.9-car.Body.Position.Y)*65-velocity.Y*12,0,workspace.Gravity*3)end
  car.Force.Force=((target-flat)*5+Vector3.new(0,lift,0))*car.Body.AssemblyMass
  if car.Body.Position.Y<-20 then car.Force.Force=Vector3.zero end
 end
end
return Service
