if not game:GetService("RunService"):IsStudio()then return end
local Test=game:GetService("StudioTestService");local args=Test:GetTestArgs()
if type(args)~="table"or args.Name~="RecreationAcceptance"then return end
local function run()
 local Players=game:GetService("Players");local Data=require(script.Parent.Services.PlayerDataService)
 local S=require(script.Parent.Services.RecreationService);local I=require(script.Parent.Services.InteractionService)
 local D=require(game.ReplicatedStorage.Neighborhood.Shared.RecreationDefinitions)
 local deadline=os.clock()+65
 repeat task.wait(.2)until workspace:GetAttribute("NeighborhoodReady")and #Players:GetPlayers()==2 or os.clock()>deadline
 local players=Players:GetPlayers();assert(#players==2 and Data.SessionOnly,"Need two isolated clients")
 for _,p in ipairs(players)do repeat task.wait(.1)until Data:Get(p)and Data:Get(p)._Restored and p.Character and p.Character:FindFirstChild("HumanoidRootPart")or os.clock()>deadline;assert(Data:Get(p)and p.Character);p.Character.HumanoidRootPart:SetNetworkOwner(nil)end
 local p,q=players[1],players[2];local root=p.Character.HumanoidRootPart;local hum=p.Character.Humanoid
 local checked,throws,rides,walks,roadSamples,blocked=0,0,0,0,0,{}
 local world=workspace.Neighborhood;local roads=world.Recreation.RoadNetwork
 -- Sample the whole drivable width, including turning junctions, not just the centerline.
 local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude;params.FilterDescendantsInstances={p.Character,q.Character};params.RespectCanCollide=true
 for _,road in ipairs(roads:GetChildren())do if road.Material==Enum.Material.Asphalt then
  for z=-road.Size.Z/2+18,road.Size.Z/2-18,12 do for _,x in ipairs({-12,0,12})do
   local pos=road.CFrame:PointToWorldSpace(Vector3.new(x,8,z));local hit=workspace:Raycast(pos,Vector3.new(0,-14,0),params)
   assert(hit,"Missing road surface");if hit.Position.Y>1 then table.insert(blocked,{Part=hit.Instance:GetFullName(),Position=tostring(hit.Position)})end;roadSamples+=1
  end end
 end end
 assert(#blocked==0,game:GetService("HttpService"):JSONEncode(blocked))
 local function approach(player,m)
  S:Release(player);player.Character.Humanoid.Sit=false;player.Character:PivotTo(CFrame.new(m.Interact.Position+Vector3.new(0,2,-4)));player.Character.HumanoidRootPart.AssemblyLinearVelocity=Vector3.zero;task.wait(.12)
 end
 local function use(player,m)
  I.Last[player.UserId]=nil;S.Cooldown[tostring(player.UserId)..":"..m.Name]=nil
  local ok,why=I:Request(player,m.Interact,"Recreation");assert(ok,m.Name..": "..tostring(why));return why
 end
 local function walk(goal)
  local finish=os.clock()+8
  repeat hum:MoveTo(goal);task.wait(.1)until (Vector3.new(root.Position.X,0,root.Position.Z)-Vector3.new(goal.X,0,goal.Z)).Magnitude<1.5 or os.clock()>finish
  assert((Vector3.new(root.Position.X,0,root.Position.Z)-Vector3.new(goal.X,0,goal.Z)).Magnitude<2.2,"Cannot walk to "..tostring(goal));walks+=1
 end
 for index=1,100 do
  local id=string.format("Activity%03d",index);local d=assert(D.Activities[id]);local m=assert(S:Model(id))
  approach(p,m);use(p,m)
  if d.Kind=="Toss"then
   assert(S.Held[p]and S.Held[p].Tool.Parent==p.Character)
   root.CFrame=CFrame.lookAt(root.Position,root.Position+Vector3.new(0,0,-1))
   local ok,why=S:Action(p,"Throw");assert(ok,why);assert(not S.Held[p]);assert(not S:Action(p,"Throw"),"Duplicate throw")
   local ball=S.Projectiles[#S.Projectiles].Part;assert(ball:GetNetworkOwner()==nil and ball.CollisionGroup=="RecreationToys");local origin=ball.Position;task.wait(.2);assert((ball.Position-origin).Magnitude>1,"Toy failed to move");throws+=1
  elseif d.Kind=="Ride"then
   task.wait(.25);assert(m.RideSeat.Occupant==hum,"Ride failed to seat")
   local start=m.RideSeat.Position;task.wait(.3);assert((m.RideSeat.Position-start).Magnitude>.3,"Ride not moving")
   approach(q,m);I.Last[q.UserId]=nil;assert(not I:Request(q,m.Interact,"Recreation"),"Ride double-booked")
   S:Release(p);task.wait(.15);assert(not S.Rides[p]and not S.Busy[id]);rides+=1
  elseif d.Kind=="Bounce"then task.wait(.15);assert(root.Position.Y>4,"No bounce lift")
  elseif d.Kind=="Lantern"then assert(m:GetAttribute("Phase")==1 and m.Glow1.PointLight.Enabled)
  elseif d.Kind=="Water"then assert(m:GetAttribute("Growth")==1 and m.Bloom1.Size.X>1)
  elseif d.Kind=="Dig"then assert(m.Treasure.Transparency==0 and S.Busy[id])
  elseif d.Kind=="Domino"then task.wait(.2);assert(m.Domino1.CFrame.UpVector.Y<.5,"Domino did not tip")
  elseif d.Kind=="Bowl"then assert(m:FindFirstChild("BowlingBall")and not m.Pin1.Anchored)
  elseif d.Kind=="Sprint"or d.Kind=="Balance"then
   walk(m.Start.Position+Vector3.new(0,3,0));task.wait(.2)
   if d.Kind=="Balance"then for i=1,5 do walk(m["BalanceStep"].Position)break end end
   -- Balance steps share a name: visit each in ascending forward position.
   if d.Kind=="Balance"then local steps={};for _,v in ipairs(m:GetChildren())do if v.Name=="BalanceStep"then table.insert(steps,v)end end;table.sort(steps,function(a,b)return a.Position.Z<b.Position.Z end);for _,v in ipairs(steps)do walk(v.Position+Vector3.new(0,3,0))end end
   walk(m.Finish.Position+Vector3.new(0,3,0));task.wait(.2)
   if d.Kind=="Sprint"then walk(m.Start.Position+Vector3.new(0,3,0));task.wait(.2)end
   assert(S.Completed[p]and S.Completed[p][id],"Course not completed: "..id)
  end
  checked+=1;workspace:SetAttribute("RecreationTestProgress",checked)
 end
 task.wait(9)
 for id,d in pairs(D.Activities)do local m=S:Model(id)
  if d.Kind=="Bowl"then assert(not m:FindFirstChild("BowlingBall")and m.Pin1.Anchored)
  elseif d.Kind=="Domino"then assert(m.Domino1.CFrame.UpVector.Y>.99)
  elseif d.Kind=="Dig"then assert(m.Treasure.Transparency==1)end
 end
 approach(p,S:Model("Activity001"));local target=S:Model("Activity001").Interact
 p.Character:PivotTo(CFrame.new(0,4,0));I.Last[p.UserId]=nil;assert(not I:Request(p,target,"Recreation"),"Remote interaction accepted")
 for i=1,500 do assert(not S:Action(p,i%2==0 and "Bogus"or "Throw"))end
 approach(p,S:Model("Activity001"));use(p,S:Model("Activity001"));S:Release(p);assert(not S.Held[p],"Disconnect cleanup")
 for _,b in ipairs(S.Projectiles)do b.Expires=0 end;S:Step(.1);assert(#S.Projectiles==0,"Expired toys retained")
 local Physics=game:GetService("PhysicsService");assert(not Physics:CollisionGroupsAreCollidable("RecreationToys","NeighborhoodCharacters"))
 return {Passed=true,Clients=2,ActivitiesExercised=checked,Mechanics=10,PhysicalThrows=throws,RideOccupancyChecks=rides,WalkedCourseLegs=walks,RoadSurfaceSamples=roadSamples,MalformedToyRequests=500,ResetChecks=30,SessionOnly=true,DevicePerformanceCertified=false}
end
local ok,result=pcall(run);Test:EndTest(ok and result or {Passed=false,Error=tostring(result),Progress=workspace:GetAttribute("RecreationTestProgress")})
