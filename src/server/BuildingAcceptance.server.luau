local Space=require(game.ReplicatedStorage.Neighborhood.Shared.WorldSpace)
if not game:GetService("RunService"):IsStudio()then return end
local Test=game:GetService("StudioTestService");local args=Test:GetTestArgs()
if type(args)~="table"or (args.Name~="BuildingAcceptance"and args.Name~="BuildingCapacity")then return end
local function run()
 local Players=game:GetService("Players");local Data=require(script.Parent.Services.PlayerDataService)
 local B=require(script.Parent.Services.BuildingService);local Houses=require(script.Parent.Services.HouseService)
 local Items=require(script.Parent.Services.ItemService);local Vehicles=require(script.Parent.Services.VehicleService)
 local Schema=require(script.Parent.ProfileSchema);local D=require(game.ReplicatedStorage.Neighborhood.Shared.BuildingDefinitions)
 local R=require(game.ReplicatedStorage.Neighborhood.Shared.BuildingRules)
 local expected=args.Name=="BuildingCapacity"and 8 or 2;local deadline=os.clock()+70
 repeat task.wait(.2)until #Players:GetPlayers()==expected and workspace:GetAttribute("NeighborhoodReady")or os.clock()>deadline
 local players=Players:GetPlayers();assert(#players==expected and Data.SessionOnly,"Expected isolated clients: count="..#players..", sessionOnly="..tostring(Data.SessionOnly)..", ready="..tostring(workspace:GetAttribute("NeighborhoodReady")))
 for _,p in ipairs(players)do repeat task.wait(.1)until Data:Get(p)and Data:Get(p)._Restored and p.Character and p.Character:FindFirstChild("HumanoidRootPart")or os.clock()>deadline;assert(Data:Get(p)and Data:Get(p)._Restored,"Profile missing");p.Character.HumanoidRootPart:SetNetworkOwner(nil)end
 local p,q=players[expected==8 and 5 or 1],players[2];local profile=Data:Get(p);local h=Houses.ByPlayer[p.UserId].Model;local verified={}
 local function at(player,x,y,z)local house=Houses.ByPlayer[player.UserId].Model;player.Character:PivotTo(house.Foundation.CFrame*Space.Frame(x,y,z))end
 local function act(player,action,arg)local ok,why=B:Action(player,action,arg);assert(ok,action..": "..tostring(why))end
 local old=Schema.Default();old.Building=nil;assert(R.Valid(Schema.Migrate(old,p.UserId).Building))
 for _,mutate in ipairs({
  function(v)v.Building.Unlocked.Loft=true end,
  function(v)v.Building.Unlocked.Fake=true end,
  function(v)v.Building.Owned.Bench=49 end,
  function(v)v.Building.Placed.x={Zone="GardenRoom",Cell=1,Kind="Bench",Rotation=0}end,
  function(v)v.Building.Layouts["4"]={}end,
  function(v)v.Items={{Id="bad",DefinitionId="Lamp",OwnerUserId=p.UserId,State="Displayed",Slot=14}}end,
 })do local bad=Schema.Default();mutate(bad);assert(not pcall(Schema.Migrate,bad,p.UserId),"Corruption accepted")end
 table.insert(verified,"Old profiles gain defaults; six malformed saved profiles rejected")
 at(p,0,4,-20);local before=profile.Currency
 assert(not B:Action(p,"Buy","Loft"));assert(profile.Currency==before)
 profile.Currency=0;assert(not B:Action(p,"Buy","GardenRoom"));assert(not profile.Building.Unlocked.GardenRoom)
 profile.Currency=100000
 local malformed=0
 for i=1,100 do for _,v in ipairs({false,{},0/0,math.huge,-1,"",string.rep("x",200)})do for _,action in ipairs({"Buy","Craft","Place","Pack","SaveLayout","LoadLayout"})do
  local ok,accepted=pcall(function()return B:Action(p,action,v)end);assert(ok and not accepted,"Malformed action threw or succeeded");malformed+=1
 end end end
 assert(profile.Currency==100000 and not next(profile.Building.Unlocked))
 for _,player in ipairs(players)do
  local pr=Data:Get(player);pr.Currency=100000;at(player,0,4,-20)
  for _,id in ipairs(D.Order)do local cost=pr.Currency;act(player,"Buy",id);assert(pr.Currency==cost-D.Rooms[id].Price);assert(not B:Action(player,"Buy",id));assert(pr.Currency==cost-D.Rooms[id].Price)end
  local home=Houses.ByPlayer[player.UserId].Model
  assert(home.BackWall.CanCollide==false and #home.DisplaySlots:GetChildren()==14)
  at(player,0,4,42)
  for _,kind in ipairs(D.RecipeOrder)do for _=1,5 do act(player,"Craft",kind)end end
  for _,zone in ipairs(D.Order)do for cell=1,#D.Rooms[zone].Cells do act(player,"Place",{Zone=zone,Cell=cell,Kind=D.RecipeOrder[(cell-1)%4+1],Rotation=(cell-1)%4})end end
  assert(R.Valid(pr.Building));act(player,"SaveLayout","1")
  local n=0;for _ in pairs(pr.Building.Placed)do n+=1 end;assert(n==15,"Expected 15 furniture spots")
  local box,size=home.HomeExpansion:GetBoundingBox();assert(size.Magnitude<360,"Expansion exceeds plot scale")
  for _,part in ipairs(home.HomeExpansion:GetDescendants())do if part:IsA("BasePart")then
   local localPos=home.Foundation.CFrame:PointToObjectSpace(part.Position)
   assert(math.abs(localPos.X)+part.Size.X/2<=87.3,"Expansion crosses neighboring plot: "..part.Name)
  end end
 end
 table.insert(verified,"All expansions purchased once per owner; prerequisite, cash and 4,200 malformed request checks")
 table.insert(verified,expected.." homes independently built with 14 collectible spots and 15 crafted furnishings each")
 at(q,0,4,42);local qmoney=Data:Get(q).Currency
 local target=h.HomeExpansion:FindFirstChild("Cell_GardenRoom_1")
 assert(not B.Context.Interactions.Handlers.FurnishHome(q,target),"Neighbor gained furnishing access")
 q.Character:PivotTo(h.Foundation.CFrame*Space.Frame(0,4,42))
 assert(not B:Action(q,"Pack",{Zone="GardenRoom",Cell=1}),"Neighbor edited from another plot")
 assert(Data:Get(q).Currency==qmoney)
 at(p,0,4,42);local saved=game:GetService("HttpService"):JSONEncode(profile.Building.Placed)
 act(p,"Pack",{Zone="GardenRoom",Cell=1});assert(not profile.Building.Placed["GardenRoom:1"])
 act(p,"LoadLayout","1");assert(profile.Building.Placed["GardenRoom:1"].Kind=="Bench")
 profile.Building.Placed["GardenRoom:1"].Rotation=3;assert(profile.Building.Layouts["1"]["GardenRoom:1"].Rotation==0,"Layout aliases active furniture")
 act(p,"LoadLayout","1")
 local money=profile.Currency;assert(not B:Action(p,"Place",{Zone="GardenRoom",Cell=100,Kind="Bench",Rotation=0}))
 assert(not B:Action(p,"Place",{Zone="Loft",Cell=1,Kind="Bench",Rotation=0/0}))
 assert(profile.Currency==money)
 local original=profile.Building.Layouts["2"];profile.Building.Layouts["2"]={bad={Zone="GardenRoom",Cell=1,Kind="Bench",Rotation=0}}
 assert(not B:Action(p,"LoadLayout","2"));assert(profile.Building.Placed["GardenRoom:1"].Rotation==0);profile.Building.Layouts["2"]=original
 act(p,"Place",{Zone="GardenRoom",Cell=4,Kind="Bench",Rotation=0})
 assert(not B:Action(p,"Place",{Zone="Workshop",Cell=4,Kind="Bench",Rotation=0}),"Placed more copies than owned")
 act(p,"LoadLayout","1")
 local instanceCount=#h.HomeExpansion.Furnishings:GetDescendants()
 for _=1,50 do act(p,"Pack",{Zone="GardenRoom",Cell=1});act(p,"LoadLayout","1");assert(#h.HomeExpansion.Furnishings:GetDescendants()==instanceCount,"Repeated layouts leaked geometry")end
 local count=0;for _,n in pairs(profile.Building.Owned)do count+=n end
 for _=count+1,48 do act(p,"Craft","Planter")end
 money=profile.Currency;assert(not B:Action(p,"Craft","Planter"));assert(profile.Currency==money)
 table.insert(verified,"Owner isolation; atomic layout load; copied layouts; invalid cells/rotations; 48-piece cap without debit")
 -- Original collectible ownership and GUIDs remain separate from crafted decor.
 local item=Items:Create(p,"Lamp");local spot=h.DisplaySlots.Slot10
 p.Character:PivotTo(spot.CFrame*CFrame.new(0,3,0));assert(Items:Place(p,item.Id,10))
 act(p,"LoadLayout","1");assert(Items.Items[item.Id].State=="Displayed"and Items.Models[item.Id])
 local giant=require(script.Parent.ItemFactory).Create("GoldenToilet");local box,size=giant:GetBoundingBox();giant:Destroy()
 for slot=7,14 do local zone=D.SlotRoom(slot);local limits=D.Bounds[zone];local base=h.DisplaySlots["Slot"..slot].CFrame*CFrame.new(0,.15,0)*box
  for _,x in ipairs({-1,1})do for _,z in ipairs({-1,1})do local v=Space.Unpoint(h.Foundation.CFrame:PointToObjectSpace(base:PointToWorldSpace(Vector3.new(x*size.X/2,0,z*size.Z/2))));assert(v.X>limits[1]+.4 and v.X<limits[2]-.4 and v.Z>limits[3]+.4 and v.Z<limits[4]-.4,"Large collectible clips room: "..slot)end end
 end
 local snapshot=Schema.Migrate(Data:Snapshot(p),p.UserId);assert(snapshot.Building.Unlocked.Loft and snapshot.Building.Layouts["1"])
 local back=h.BackWall;B:Release(p);assert(back.CanCollide and back.Transparency<1 and #h.DisplaySlots:GetChildren()==6 and not h:FindFirstChild("HomeExpansion"))
 B:Restore(p);assert(h.DisplaySlots.Slot10 and h.HomeExpansion.Furnishings:FindFirstChild("Loft:1"))
 table.insert(verified,"Layouts preserve original collectible GUIDs; expansion snapshot validates; release restores cottage and rebuild retains furniture")
 -- Physical stairs and open doorways: real Humanoid movement, no teleport between waypoints.
 local walked=0
 local function walk(points)
  local human=p.Character.Humanoid;human.WalkSpeed=12
  for _,xyz in ipairs(points)do local world=h.Foundation.CFrame:PointToWorldSpace(Space.Point(Vector3.new(table.unpack(xyz))));human:MoveTo(world);local timeout=os.clock()+9
   repeat task.wait(.05)until (Vector3.new(p.Character.HumanoidRootPart.Position.X,world.Y,p.Character.HumanoidRootPart.Position.Z)-world).Magnitude<1.2 or os.clock()>timeout
   assert(os.clock()<timeout,"Blocked walk after "..walked.." legs at "..table.concat(xyz,",").."; actual="..tostring(h.Foundation.CFrame:PointToObjectSpace(p.Character.HumanoidRootPart.Position)).."; state="..human:GetState().Name);walked+=1
  end
 end
 -- Pack rugs near the stair approach so testing measures architecture, not deliberately placed furniture.
 profile.Building.Placed={};B:Restore(p)
 local houseRecord=Houses.ByPlayer[p.UserId]
 Houses:SetDoor(houseRecord,false);assert(h.HomeExpansion:FindFirstChild("GardenDoor",true).CanCollide,"Garden door ignores lock state")
 Houses:SetDoor(houseRecord,true);assert(not h.HomeExpansion:FindFirstChild("GardenDoor",true).CanCollide,"Garden door ignores open state")
 at(p,0,4,8);task.wait(.4)
 walk({{0,.7,18},{8,.7,15},{8,6.175,27},{3,6.175,27},{3,11.65,15.5},{-3,11.65,15.5},{-6,11.65,22}})
 assert(p.Character.HumanoidRootPart.Position.Y>12,"Loft was not reached vertically")
 walk({{-3,11.65,15.5},{3,11.65,15.5},{3,6.175,27},{8,6.175,27},{8,.7,15},{0,.7,18},{0,.7,8}})
 at(p,-20,4,-35);task.wait(.3);walk({{-20,.7,-24},{-20,.7,-35}})
 at(p,0,4,18);task.wait(.3);walk({{0,.7,29},{0,.7,33},{0,.7,39},{0,.7,33},{0,.7,29},{0,.7,18}})
 table.insert(verified,walked.." physical walking legs: cottage connection, loft up/down, garage and workshop")
 at(p,0,4,-20);profile.Vehicles={Compact=true,Color="Mint",Plate="BUILD-QA"};local ok,why=Vehicles:Spawn(p);assert(ok,why)
 assert((Vehicles.Cars[p.UserId].Body.Position-(h.Foundation.CFrame*Space.Frame(-20,3.5,-23)).Position).Magnitude<1)
 local car=Vehicles.Cars[p.UserId];local human=p.Character.Humanoid
 p.Character:PivotTo(car.Seat.CFrame*CFrame.new(0,2,0));car.Seat:Sit(human);task.wait(.5);car.Body:SetNetworkOwner(nil)
 assert(car.Seat.Occupant==human,"Garage driver could not sit")
 local drive=game:GetService("RunService").PreSimulation:Connect(function()car.Throttle=.5;car.Steer=0;car.LastInput=os.clock()end)
 local driveDeadline=os.clock()+10
 repeat task.wait(.1)until h.Foundation.CFrame:PointToObjectSpace(car.Body.Position).Z< -114 or os.clock()>driveDeadline
 drive:Disconnect();car.Throttle=0
 assert(h.Foundation.CFrame:PointToObjectSpace(car.Body.Position).Z< -114,"Car could not drive through the garage entrance: "..tostring(h.Foundation.CFrame:PointToObjectSpace(car.Body.Position)))
 assert(car.Body.AssemblyLinearVelocity.Magnitude<45,"Garage exit exceeded bounded speed")
 human.Sit=false;human.Jump=true;task.wait(.3);Vehicles:Remove(p)
 table.insert(verified,"Owned car recalls inside garage; actual seated driver physically exits through its doorway")
 for _,zone in ipairs(D.Order)do local xyz=D.Rooms[zone].Displays[1];assert(B:ContainsExpansion(Houses.ByPlayer[p.UserId],h.Foundation.CFrame:PointToWorldSpace(Space.Point(Vector3.new(table.unpack(xyz))))),"New room is outside robbery boundary")end
 assert(not B:ContainsExpansion(Houses.ByPlayer[p.UserId],h.Foundation.CFrame:PointToWorldSpace(Space.Point(Vector3.new(0,3,-50)))),"Street is inside expansion")
 local Robbery=require(script.Parent.Services.RobberyService)
 local lamp=Items:Create(p,"Lamp");p.Character:PivotTo(h.DisplaySlots.Slot14.CFrame*CFrame.new(0,3,0));assert(Items:Place(p,lamp.Id,14))
 q.Character:PivotTo(h.Foundation.CFrame*Space.Frame(7,3.7,43));assert(Robbery:Carry(q,lamp,Houses.ByPlayer[p.UserId]))
 local carry=Robbery.Sessions[q.UserId];carry.Started=os.clock()-100;Robbery:Step();assert(carry.State=="Escaping","Theft escaped while still inside workshop")
 Robbery:Return(carry,"Boundary test complete");assert(lamp.State=="Displayed"and lamp.Slot==14)
 at(p,0,4,-20);act(p,"LoadLayout","1")
 table.insert(verified,"Fifty pack/reload cycles retain exact geometry counts; owned-copy limits enforced; workshop theft cannot escape indoors")
 local samples={};for _=1,120 do table.insert(samples,game:GetService("RunService").Heartbeat:Wait()*1000)end;table.sort(samples)
 return {Passed=true,Verified=verified,Clients=expected,MalformedRequests=malformed,WalkedLegs=walked,Parts=#workspace.Neighborhood:GetDescendants(),HeartbeatP95Ms=samples[114],PerformanceCertified=false}
end
local ok,result=pcall(run);local errors={};if not ok then for _,entry in ipairs(game:GetService("LogService"):GetLogHistory())do if entry.messageType==Enum.MessageType.MessageError then table.insert(errors,entry.message)end end end;Test:EndTest(ok and result or {Passed=false,Error=tostring(result),ConsoleErrors=errors})
