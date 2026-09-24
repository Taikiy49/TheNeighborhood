if not game:GetService("RunService"):IsStudio()then return end
local Test=game:GetService("StudioTestService");local args=Test:GetTestArgs();if type(args)~="table"or args.Name~="SpaciousAcceptance"then return end
local function run()
 local Players=game:GetService("Players");local Data=require(script.Parent.Services.PlayerDataService);local H=require(script.Parent.Services.HouseService)
 local Space=require(game.ReplicatedStorage.Neighborhood.Shared.WorldSpace);local Layout=require(game.ReplicatedStorage.Neighborhood.Shared.PlotLayout)
 local B=require(script.Parent.Services.BuildingService);local Items=require(script.Parent.Services.ItemService);local Robbery=require(script.Parent.Services.RobberyService)
 local deadline=os.clock()+60;repeat task.wait(.2)until #Players:GetPlayers()==2 and workspace:GetAttribute("NeighborhoodReady")or os.clock()>deadline
 local players=Players:GetPlayers();assert(#players==2 and Data.SessionOnly)
 for _,p in ipairs(players)do repeat task.wait(.1)until Data:Get(p)and Data:Get(p)._Restored and p.Character and p.Character:FindFirstChild("HumanoidRootPart")or os.clock()>deadline;p.Character.HumanoidRootPart:SetNetworkOwner(nil)end
 local world=workspace.Neighborhood;assert(world.Map.VillageGround.Size==Vector3.new(1440,4,1200));local homes=0
 for _,h in ipairs(world.Houses:GetChildren())do
  homes+=1;assert(h.Foundation.Size==Vector3.new(90,1,78));assert(h.BuiltInInterior.BedFrame.Size==Vector3.new(7.2,.55,8),"Bed became giant")
  local expected=Layout.Position(tonumber(h.Name:match("%d+")));assert((Vector2.new(h.Foundation.Position.X,h.Foundation.Position.Z)-expected).Magnitude<.01,"Plot directory disagrees with map")
  assert(h.BuiltInInterior.HallPartition.Size.Z==33 and math.abs(h.BuiltInInterior.HallPartition.Size.Y-13.845)<.001,"Hall must widen without becoming taller")
 end
 assert(homes==8);
 for _,h in ipairs(world.Houses:GetChildren())do
  assert(h:GetAttribute("InteriorDesignVersion")=="clean-cottage-2")
  assert(h.InteriorBackFinish.Transparency==0 and h.BuiltInInterior.SofaSeat.CanCollide)
  for _,v in ipairs(h.BuiltInInterior:GetDescendants())do assert(not v:IsA("Decal"),"Generated wall texture returned");if v:GetAttribute("FloorSeam")then assert(not v.CanCollide and not v.CanQuery)end end
  for _,slot in ipairs(h.DisplaySlots:GetChildren())do assert(slot.Transparency>=.85 and slot:FindFirstChildOfClass("ProximityPrompt"),"Display target lost")end
 end
 assert(world.GuideCharacters.Mabel.Torso.Size==Vector3.new(2.2,2.6,1),"Guide was enlarged")
 local walked=0
 local function walk(p,xyz)
  local h=H.ByPlayer[p.UserId].Model;local goal=h.Foundation.CFrame:PointToWorldSpace(Space.Point(Vector3.new(table.unpack(xyz))));local root=p.Character.HumanoidRootPart;local humanoid=p.Character.Humanoid
  local untilTime=os.clock()+10;repeat humanoid:MoveTo(goal);task.wait(.1)until (Vector3.new(root.Position.X,goal.Y,root.Position.Z)-goal).Magnitude<1.3 or os.clock()>untilTime
  assert((Vector3.new(root.Position.X,goal.Y,root.Position.Z)-goal).Magnitude<1.5,"House route blocked at "..table.concat(xyz,",").." actual "..tostring(h.Foundation.CFrame:PointToObjectSpace(root.Position)));walked+=1
 end
 for _,p in ipairs(players)do
  local house=H.ByPlayer[p.UserId];H:SetDoor(house,true);p.Character:PivotTo(house.Model.Foundation.CFrame*Space.Frame(0,4,-20));task.wait(.3)
  for _,xyz in ipairs({{0,.7,-10},{0,.7,-2},{0,.7,7},{0,.7,-2},{9,.7,-2},{9,.7,6},{9,.7,-2},{-9,.7,-2},{-9,.7,6},{-9,.7,-2},{0,.7,-2},{0,.7,-20}})do walk(p,xyz)end
  local pr=Data:Get(p);pr.Currency=10000;assert(B:Action(p,"Buy","GardenRoom"));assert(B:Action(p,"Buy","Workshop"));assert(house.Model.InteriorBackFinish.Transparency==1,"New wall liner blocks expansion")
  local pnt=house.Model.Foundation.CFrame*Space.Frame(0,3.5,40);assert(B:ContainsExpansion(house,pnt.Position))
  local snapshot=Data:Snapshot(p);local migrated=require(script.Parent.ProfileSchema).Migrate(snapshot,p.UserId);assert(migrated.Building.Unlocked.Workshop,"Saved room IDs changed")
 end
 local p,q=players[1],players[2];local house=H.ByPlayer[p.UserId];local item=Items:Create(p,"Lamp")
 p.Character:PivotTo(house.Model.DisplaySlots.Slot1.CFrame*CFrame.new(0,3,0));assert(Items:Place(p,item.Id,1));assert(Robbery:Carry(q,item,house))
 H:SetDoor(house,false);task.wait(.4)
 q.Character:PivotTo(house.Model.Foundation.CFrame*Space.Frame(0,3.5,11));local session=Robbery.Sessions[q.UserId];session.Started=os.clock()-100;session.LastPosition=q.Character.HumanoidRootPart.Position;session.LastTime=os.clock()
 assert((session.LastPosition-house.Door.Position).Magnitude>45,"Interior test must exceed old escape distance")
 Robbery:Step();assert(session.State=="Escaping","Thief escaped from inside the larger cottage");Robbery:Return(session,"Interior boundary verified")
 return {Passed=true,Homes=homes,PhysicalWalkingLegs=walked,MapStuds={1440,1200},FoundationStuds={90,78},FloorAreaMultiplier=9,Verified={"All eight plot centers match saved-circle layout","Beds and NPCs retain normal size","Two players physically traverse entrance, hall, kitchen and bedroom","Expansion placement and snapshot migration retain saved IDs","Greater distance inside the cottage cannot prematurely complete a theft escape"},OnlineSaveRejoinTested=false}
end
local ok,result=pcall(run);Test:EndTest(ok and result or {Passed=false,Error=tostring(result)})
