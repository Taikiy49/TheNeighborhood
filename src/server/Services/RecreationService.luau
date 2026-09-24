local Players=game:GetService("Players")

local Run=game:GetService("RunService")

local Physics=game:GetService("PhysicsService")

local D=require(game.ReplicatedStorage.Neighborhood.Shared.RecreationDefinitions)

local F=require(script.Parent.Parent.RecreationFactory)

local S={Held={},Rides={},Courses={},Cooldown={},Busy={},Completed={},Projectiles={},RewardAt={}}

function S:Model(id)local d=D.Activities[id];return d and self.World[d.Zone]:FindFirstChild(id)end

function S:Release(player)

 local held=self.Held[player];if held then held.Tool:Destroy();self.Held[player]=nil end

 local ride=self.Rides[player];if ride then

  if ride.Seat.Occupant then ride.Seat.Occupant.Sit=false end

  ride.Seat.Disabled=true;ride.Seat.CFrame=ride.Home;ride.Back.CFrame=ride.BackHome;self.Busy[ride.Id]=nil;self.Rides[player]=nil

 end

 self.Courses[player]=nil

end

function S:Complete(player,id)

 local done=self.Completed[player]or {};self.Completed[player]=done;done[id]=true

 local n=0;for _ in pairs(done)do n+=1 end

 player:SetAttribute("RecreationVisited",n)

 return n

end

function S:TrialReward(player,id,seconds)

 local profile=self.Context.Data:Get(player);if not profile or not self.Context.Data:CanAct(player)then return end

 local ms=math.clamp(math.floor(seconds*1000),1,35000);local progress=profile.Trials

 local prior=progress.Best[id];progress.Best[id]=math.min(prior or ms,ms);progress.Wins[id]=(progress.Wins[id]or 0)+1

 local gold=id=="Activity006"and 3.0 or 4.5;local silver=gold+2

 local medal=seconds<=gold and "Gold"or seconds<=silver and "Silver"or "Bronze"

 local now=os.clock();local reward=0

 if now>=(self.RewardAt[player]or 0)then

  reward=medal=="Gold"and 75 or medal=="Silver"and 50 or 30

  profile.Currency=math.min(1000000000,profile.Currency+reward);profile.XP+=15;progress.XP+=15;self.RewardAt[player]=now+60;self.Context.Record(player,"Trial")

 end

 self.Context.Notify(player,string.format("%s · %.2fs · best %.2fs%s",medal,seconds,progress.Best[id]/1000,reward>0 and (" · $"..reward.." +15 XP")or " · reward ready after a short break"),true)

 self.Context.Sync(player)

end

function S:Give(player,d)

 if self.Held[player]then return false,"Throw or put away your current toy first."end

 local tool=Instance.new("Tool");tool.Name=d.Toy;tool.CanBeDropped=false;tool:SetAttribute("RecreationToy",true);tool.ToolTip="Equip, face a clear space, then click/tap to throw. Free toys return after use."

 local handle=F.Part(tool,"Handle",Vector3.new(1.6,1.6,1.6),CFrame.new(),d.Color,false);handle.Anchored=false;handle.Massless=true;handle.Shape=d.Variant%3==0 and Enum.PartType.Block or Enum.PartType.Ball

 tool.Parent=player.Backpack;self.Held[player]={Tool=tool,Definition=d,Expires=os.clock()+120}

 player.Character.Humanoid:EquipTool(tool)

 return true,"Free "..d.Toy.."! Face where you want to throw, then click or tap. Toys do not hurt players."

end

function S:Action(player,action)

 if action~="Throw"and action~="PutAway"then return false,"Unknown toy action."end

 if not self.Context.Data:CanAct(player)then return false,"Please wait for your profile."end

 local h=self.Held[player];local char=player.Character;local hrp=char and char:FindFirstChild("HumanoidRootPart");local hum=char and char:FindFirstChildOfClass("Humanoid")

 if not h or not hrp or not hum or hum.Health<=0 then return false,"Grab a free toy at a playfield."end

 if action=="PutAway"then h.Tool:Destroy();self.Held[player]=nil;return true,"Toy returned."end

 if h.Tool.Parent~=char or hum.Sit or player:GetAttribute("Carrying")then return false,"Equip the toy and stand before throwing."end

 if (hrp.Position-h.Definition.Position).Magnitude>180 then return false,"Bring the toy back near its playfield."end

 if #self.Projectiles>=24 then return false,"Let the current toys settle first."end

 local direction=hrp.CFrame.LookVector;local origin=hrp.Position+Vector3.new(0,1,0)

 local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude;params.FilterDescendantsInstances={char};params.RespectCanCollide=true

 if workspace:Raycast(origin,direction*4,params)then return false,"Face a clear space before throwing."end

 local d=h.Definition;h.Tool:Destroy();self.Held[player]=nil

 local ball=F.Part(self.World,"ThrownToy",Vector3.new(1.6,1.6,1.6),CFrame.new(origin+direction*3),d.Color,true);ball.Shape=d.Variant%3==0 and Enum.PartType.Block or Enum.PartType.Ball;ball.Anchored=false;ball.CollisionGroup="RecreationToys";ball.CustomPhysicalProperties=PhysicalProperties.new(.4,.5,.55)

 ball:SetNetworkOwner(nil);ball:ApplyImpulse((direction*d.Speed+Vector3.new(0,23,0))*ball.AssemblyMass)

 table.insert(self.Projectiles,{Part=ball,Expires=os.clock()+14,Origin=origin})

 self:Complete(player,d.Id);return true,"Nice throw! "..player:GetAttribute("RecreationVisited").."/"..D.Count.." park activities tried this visit."

end

function S:Use(player,target)

 local d=D.Activities[target:GetAttribute("ActivityId")];if not d or target~=self:Model(d.Id).Interact then return false,"Unknown activity."end

 local char=player.Character;local hum=char and char:FindFirstChildOfClass("Humanoid");local hrp=char and char:FindFirstChild("HumanoidRootPart")

 if not hum or not hrp or hum.Health<=0 or hum.Sit or player:GetAttribute("Carrying")then return false,"Stand up and put carried possessions down first."end

 if self.Rides[player]or self.Courses[player]then return false,"Finish your activity first, or jump off your ride."end

 local key=tostring(player.UserId)..":"..d.Id;local now=os.clock()

 if now<(self.Cooldown[key]or 0)then return false,"Give this activity a moment to reset."end

 if self.Busy[d.Id]then return false,"A neighbor is using this. Try another activity."end

 local m=self:Model(d.Id);local kind=d.Kind

 self.Cooldown[key]=now+2

 if kind=="Toss"then return self:Give(player,d)

 elseif kind=="Ride"then

  local seat=m.RideSeat;self.Busy[d.Id]=true;self.Rides[player]={Id=d.Id,Seat=seat,Back=m.RideBack,Home=seat.CFrame,BackHome=m.RideBack.CFrame,Center=d.Position,Started=now}

  seat.Disabled=false;seat:Sit(hum)

  return true,"A 15-second orbit. Jump any time to leave."

 elseif kind=="Bounce"then

  hrp.CFrame=CFrame.new(d.Position+Vector3.new(0,4,0));hrp.AssemblyLinearVelocity=Vector3.new(0,d.Height,0)

 elseif kind=="Balance"or kind=="Sprint"then

  self.Courses[player]={Id=d.Id,Started=now,Last=hrp.Position,Phase="Start",Best=0,Model=m}

  return true,kind=="Balance"and "Step onto the white start, cross the raised trail, then reach the dark finish."or "Touch the white start, run to the dark finish, then return to the white start."

 elseif kind=="Lantern"then

  local phase=((m:GetAttribute("Phase")or 0)+1)%4;m:SetAttribute("Phase",phase)

  for i=1,3 do local lamp=m["Glow"..i];lamp.Color=Color3.fromHSV((phase*.22+i*.1+d.Variant*.03)%1,.5,1);lamp.Material=phase==0 and Enum.Material.SmoothPlastic or Enum.Material.Neon;lamp.PointLight.Color=lamp.Color;lamp.PointLight.Enabled=phase~=0 end

 elseif kind=="Water"then

  local growth=math.min(3,(m:GetAttribute("Growth")or 0)+1);m:SetAttribute("Growth",growth)

  for i=1,5 do local flower=m["Bloom"..i];flower.Size=Vector3.one*(.8+growth*.45);flower.Position=d.Position+Vector3.new((i-3)*1.5,2.4+growth*.25,0)end

 elseif kind=="Dig"then

  self.Busy[d.Id]=true;m.Treasure.Transparency=0

  task.delay(8,function()if m.Parent then m.Treasure.Transparency=1 end;self.Busy[d.Id]=nil end)

 elseif kind=="Domino"then

  self.Busy[d.Id]=true

  task.spawn(function()

   local homes={};for i=1,8 do local tile=m["Domino"..i];homes[i]=tile.CFrame;tile.CFrame=tile.CFrame*CFrame.new(0,-.9,.8)*CFrame.Angles(math.rad(72),0,0);task.wait(.12)end

   task.wait(3);for i=1,8 do if m.Parent then m["Domino"..i].CFrame=homes[i]end end;self.Busy[d.Id]=nil

  end)

 elseif kind=="Bowl"then

  self.Busy[d.Id]=true

  local homes={};for i=1,6 do local pin=m["Pin"..i];homes[i]=pin.CFrame;pin.CollisionGroup="RecreationToys";pin.Anchored=false;pin:SetNetworkOwner(nil)end

  local ball=F.Part(m,"BowlingBall",Vector3.one*2,CFrame.new(d.Position+Vector3.new((d.Variant%3-1)*.5,1.7,-7)),d.Color,true);ball.Shape=Enum.PartType.Ball;ball.Anchored=false;ball.CollisionGroup="RecreationToys";ball:SetNetworkOwner(nil);ball:ApplyImpulse(Vector3.new(0,0,23)*ball.AssemblyMass)

  task.delay(3,function()

   if not m.Parent then return end

   local score=0;for i=1,6 do local pin=m["Pin"..i];if math.abs(pin.CFrame.RightVector.Y)<.75 or (pin.Position-homes[i].Position).Magnitude>1 then score+=1 end;pin.Anchored=true;pin.CFrame=homes[i];pin.AssemblyLinearVelocity=Vector3.zero;pin.AssemblyAngularVelocity=Vector3.zero end

   ball:Destroy();self.Busy[d.Id]=nil;self.Context.Notify(player,"Skittles down: "..score.." / 6. Try another lane!",true)

  end)

 end

 self:Complete(player,d.Id)

 return true,d.Name.." — "..player:GetAttribute("RecreationVisited").."/"..D.Count.." tried this visit."

end

function S:Step(dt)

 local now=os.clock()

 for player,h in pairs(self.Held)do if now>h.Expires or not player.Character or h.Tool.Parent~=player.Character and h.Tool.Parent~=player:FindFirstChild("Backpack")then h.Tool:Destroy();self.Held[player]=nil end end

 for player,r in pairs(self.Rides)do

  local human=player.Character and player.Character:FindFirstChildOfClass("Humanoid")

  local elapsed=now-r.Started

  if not human or human.Health<=0 or elapsed>15 or elapsed>.8 and r.Seat.Occupant~=human then

   local completed=elapsed>15;self:Release(player);if completed then self:Complete(player,r.Id);self.Context.Notify(player,"Ride complete! Jump off and explore the next activity.",true)end

  else

   local a=elapsed*.6;r.Seat.CFrame=CFrame.new(r.Center+Vector3.new(math.cos(a)*5,2.6,math.sin(a)*5))*CFrame.Angles(0,-a,0);r.Back.CFrame=r.Seat.CFrame*CFrame.new(0,1.1,1.3)

  end

 end

 for player,c in pairs(self.Courses)do

  local char=player.Character;local hrp=char and char:FindFirstChild("HumanoidRootPart");local human=char and char:FindFirstChildOfClass("Humanoid")

  if not hrp or not human or human.Health<=0 or now-c.Started>35 or (hrp.Position-c.Last).Magnitude>math.max(8,dt*45)then self.Courses[player]=nil;self.Context.Notify(player,"Trail ended. Return to its start to try again.",false)

  else

   c.Last=hrp.Position;local d=D.Activities[c.Id];local localPos=hrp.Position-d.Position

   local function near(p)return(Vector3.new(hrp.Position.X,0,hrp.Position.Z)-Vector3.new(p.X,0,p.Z)).Magnitude<3.2 end

   if c.Phase=="Start"and near(c.Model.Start.Position)then c.Phase="Out";c.Started=now;self.Context.Notify(player,"Go! Reach the dark finish.",true)

   elseif c.Phase=="Out"then

    if math.abs(localPos.X)>7 or math.abs(localPos.Z)>13 then self.Courses[player]=nil;self.Context.Notify(player,"Stay inside the course and try again.",false)

    elseif d.Kind=="Balance"and localPos.Z>-5 and localPos.Z<6 and (human.FloorMaterial==Enum.Material.Air or hrp.Position.Y<3.3)then c.Best+=dt;if c.Best>1 then self.Courses[player]=nil;self.Context.Notify(player,"Step across the raised trail without leaving it.",false)end

    elseif near(c.Model.Finish.Position)and now-c.Started>1 then if d.Kind=="Sprint"then c.Phase="Return";self.Context.Notify(player,"Now run back to white!",true)else self.Courses[player]=nil;self:Complete(player,c.Id);self:TrialReward(player,c.Id,now-c.Started)end end

   elseif c.Phase=="Return"and near(c.Model.Start.Position)then self.Courses[player]=nil;self:Complete(player,c.Id);self:TrialReward(player,c.Id,now-c.Started)end

  end

 end

 for i=#self.Projectiles,1,-1 do local b=self.Projectiles[i];if not b.Part.Parent or now>b.Expires or b.Part.Position.Y< -20 or (b.Part.Position-b.Origin).Magnitude>150 then b.Part:Destroy();table.remove(self.Projectiles,i)end end

end

function S:Init(context)

 self.Context=context;self.World=F.Build(workspace.Neighborhood)

 pcall(function()Physics:RegisterCollisionGroup("RecreationToys")end)

 Physics:CollisionGroupSetCollidable("RecreationToys","NeighborhoodCharacters",false)

 Physics:CollisionGroupSetCollidable("RecreationToys","NeighborhoodCars",false)

 context.Interactions:Register("Recreation",function(player,target)return self:Use(player,target)end)

 local function added(player)player.CharacterRemoving:Connect(function()self:Release(player)end)end

 Players.PlayerAdded:Connect(added);for _,p in ipairs(Players:GetPlayers())do added(p)end

 Players.PlayerRemoving:Connect(function(p)self:Release(p);self.Completed[p]=nil;self.RewardAt[p]=nil;for k in pairs(self.Cooldown)do if k:sub(1,#tostring(p.UserId)+1)==tostring(p.UserId)..":"then self.Cooldown[k]=nil end end end)

 Run.Heartbeat:Connect(function(dt)self:Step(dt)end)

end

return S

