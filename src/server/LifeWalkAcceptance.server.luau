if not game:GetService("RunService"):IsStudio()then return end
local Test=game:GetService("StudioTestService");local args=Test:GetTestArgs();if type(args)~="table"or args.Name~="LifeWalkAcceptance"then return end
local function run()
 local Players=game:GetService("Players");local Data=require(script.Parent.Services.PlayerDataService);local H=require(script.Parent.Services.HouseService);local S=require(script.Parent.Services.LifeService)
 local deadline=os.clock()+60;repeat task.wait(.2)until #Players:GetPlayers()==2 and workspace:GetAttribute("NeighborhoodReady")or os.clock()>deadline
 local players=Players:GetPlayers();local p,q=players[1],players[2]
 for _,player in ipairs(players)do repeat task.wait(.1)until Data:Get(player)and Data:Get(player)._Restored and player.Character and player.Character:FindFirstChild("HumanoidRootPart")or os.clock()>deadline;assert(Data:Get(player)and Data:Get(player)._Restored);player.Character.HumanoidRootPart:SetNetworkOwner(nil)end
 assert(Data.SessionOnly);local house=H.ByPlayer[p.UserId].Model;local basis=house.Foundation.CFrame;local legs=0
 local function walk(player,pos)
  local root=player.Character.HumanoidRootPart;local human=player.Character.Humanoid;local untilTime=os.clock()+12
  repeat human:MoveTo(pos);task.wait(.1)until (Vector3.new(root.Position.X,0,root.Position.Z)-Vector3.new(pos.X,0,pos.Z)).Magnitude<2.5 or os.clock()>untilTime
  assert((Vector3.new(root.Position.X,0,root.Position.Z)-Vector3.new(pos.X,0,pos.Z)).Magnitude<3,"Walk blocked to "..tostring(pos).." at "..tostring(root.Position));legs+=1
 end
 local function homeWalk(player,x,z)walk(player,basis:PointToWorldSpace(Vector3.new(x,.8,z)))end
 local function act(player,action,arg)local ok,why=S:Action(player,action,arg or "");assert(ok,action..": "..tostring(why));task.wait(.35)end
 p.Character:PivotTo(basis*CFrame.new(21,4,-23));task.wait(.5)
 homeWalk(p,16,4);homeWalk(p,16,14);homeWalk(p,20,14);
 for i,kind in ipairs({"Daisy","Lavender","Sunflower","Daisy"})do homeWalk(p,20,i<=2 and 17 or 23);act(p,"Plant",i..":"..kind)end
 for i=4,1,-1 do homeWalk(p,20,i<=2 and 17 or 23);act(p,"Water",tostring(i))end
 homeWalk(p,20,14);homeWalk(p,16.5,12);act(p,"Style","Meadow");homeWalk(p,21,-23);homeWalk(p,8,-23);act(p,"Tour","Open")
 -- Two avatars begin outside the home; all three tour highlights use actual walking.
 p.Character:PivotTo(basis*CFrame.new(-8,4,-23));q.Character:PivotTo(basis*CFrame.new(8,4,-25));task.wait(.4);act(q,"Visit",tostring(p.UserId))
 homeWalk(q,0,-19);act(q,"VisitStop","1");homeWalk(q,0,-8);homeWalk(q,0,0);act(q,"VisitStop","2")
 homeWalk(q,0,-19);homeWalk(q,21,-19);homeWalk(q,16,-19);homeWalk(q,16,14);homeWalk(q,20,14);homeWalk(q,20,21);act(q,"VisitStop","3");act(q,"Compliment","Lovely garden")
 assert(Data:Get(q).Life.Tours==1 and Data:Get(p).Life.Compliments==1)
 local pr=Data:Get(p);act(p,"Case","LostLantern");p.Character:PivotTo(CFrame.new(-12,4,-96));task.wait(.3)
 for _,n in ipairs({"1","2","3"})do local pos=S.Stops[n].Position;walk(p,Vector3.new(0,.8,pos.Z-4));walk(p,Vector3.new(pos.X,.8,pos.Z-4));act(p,"Clue",n)end
 act(p,"Deduce",require(game.ReplicatedStorage.Neighborhood.Shared.LifeDefinitions).Cases.LostLantern.People[pr.Life.Variant]);act(p,"Ending","1")
 p.Character:PivotTo(CFrame.new(-22,4,-111));task.wait(.3);walk(p,Vector3.new(-22,.8,-140));walk(p,Vector3.new(-22,.8,-143));act(p,"Renovate","Cafe");task.wait(3.1);act(p,"FinishRenovation","Cafe")
 S.Totals.Cafe=12;S:Project("Cafe");walk(p,Vector3.new(-22,.8,-140));walk(p,Vector3.new(-22,.8,-145));task.wait(5);act(p,"Social","Cafe")
 return {Passed=true,Clients=2,PhysicalWalkingLegs=legs,Verified={"Four side-yard beds reached, planted and watered on foot","Side counter reached and style applied","Guest physically walked porch, living room and garden; tour and compliment recorded","Three park clues collected after actual walking; deduction and ending claimed","North plaza crossed and cafe repair completed with real preparation delay"},SetupTeleports=5,OnlineSaveRejoinTested=false}
end
local ok,result=pcall(run);Test:EndTest(ok and result or {Passed=false,Error=tostring(result)})
