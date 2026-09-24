if not game:GetService("RunService"):IsStudio()then return end
local Test=game:GetService("StudioTestService");local args=Test:GetTestArgs()
if type(args)~="table"or (args.Name~="LifeAcceptance"and args.Name~="LifeCapacity")then return end
local function run()
 local Players=game:GetService("Players");local Data=require(script.Parent.Services.PlayerDataService)
 local S=require(script.Parent.Services.LifeService);local H=require(script.Parent.Services.HouseService)
 local D=require(game.ReplicatedStorage.Neighborhood.Shared.LifeDefinitions);local R=require(game.ReplicatedStorage.Neighborhood.Shared.LifeRules)
 local Schema=require(script.Parent.ProfileSchema);local expected=args.Name=="LifeCapacity"and 8 or 2;local deadline=os.clock()+80
 repeat task.wait(.2)until #Players:GetPlayers()==expected and workspace:GetAttribute("NeighborhoodReady")or os.clock()>deadline
 local players=Players:GetPlayers();assert(#players==expected and Data.SessionOnly,"Expected isolated clients")
 for _,p in ipairs(players)do repeat task.wait(.1)until Data:Get(p)and Data:Get(p)._Restored and p.Character and p.Character:FindFirstChild("HumanoidRootPart")or os.clock()>deadline;assert(Data:Get(p)and Data:Get(p)._Restored,"Profile unavailable");p.Character.HumanoidRootPart:SetNetworkOwner(nil)end
 local verified={};local checks=0;local now=os.time();local b={Unlocked={GardenRoom=true,Workshop=true,Garage=true}}
 local old=Schema.Default();old.Life=nil;assert(R.Valid(Schema.Migrate(old,players[1].UserId).Life));checks+=1
 for _,mutate in ipairs({function(v)v.XP=-1 end,function(v)v.Beds["5"]={}end,function(v)v.Flowers.Daisy=1000 end,function(v)v.OrderStep=4 end,function(v)v.Mystery="bad"end,function(v)v.Decor["Spring:Fake"]=true end,function(v)v.Endings["LostLantern:3"]=true end,function(v)v.Style="Coastal"end,function(v)v.Blueprints.Lantern=true end,function(v)v.Equipped="Spring:Flag"end})do
  local profile=Schema.Default();mutate(profile.Life);assert(not pcall(Schema.Migrate,profile,players[1].UserId),"Invalid life profile accepted");checks+=1
 end
 local function pure(l,action,arg,t,cash)local ok,msg,delta=R.Action(l,cash or 100000,action,arg or "",t or now,b);assert(ok,action..": "..tostring(msg));assert(R.Valid(l),"Invalid result: "..action);checks+=1;return delta end
 for round=1,200 do
  local l=R.Default()
  for i,kind in ipairs(D.FlowerOrder)do pure(l,"Plant",i..":"..kind);pure(l,"Water",tostring(i))end
  assert(not R.Action(l,100,"Harvest","1",now,b));checks+=1
  for i=1,3 do pure(l,"Harvest",tostring(i),now+100000);assert(not R.Action(l,100,"Harvest",tostring(i),now+100000,b));checks+=1 end
  l.Flowers={Daisy=10,Lavender=10,Sunflower=10};pure(l,"Arrange","Bouquet");pure(l,"Arrange","Planter")
  for _,business in ipairs({"Nursery","Furniture","Repair"})do
   pure(l,"Business",business);l.NextOrder=0;pure(l,"Order","",now)
   assert(not R.Action(l,100,"Work","Forged",now+50,b));checks+=1
   for i,step in ipairs(D.Businesses[business].Steps)do local delta=pure(l,"Work",step,now+i*4);if i==3 then assert(delta==90)end end
   assert(not R.Action(l,100,"Work",D.Businesses[business].Steps[3],now+50,b));assert(not R.Action(l,100,"Order","",now+13,b));checks+=2
  end
  for _,id in ipairs(D.CaseOrder)do for variant=1,3 do for ending=1,2 do
   pure(l,"Case",id);l.Variant=variant
   for clue=1,3 do pure(l,"Clue",tostring(clue))end
   assert(not R.Action(l,100,"Deduce","Nobody",now,b));pure(l,"Deduce",D.Cases[id].People[variant]);local first=not l.Endings[id..":"..ending];local delta=pure(l,"Ending",tostring(ending));assert(delta==(first and 50 or 0));checks+=1
  end end end
  for _,season in ipairs(D.Seasons)do
   l.NextHunt=0;pure(l,"Hunt",season);for i=1,4 do pure(l,"Token",tostring(i))end
   pure(l,"Decor",season..":Flag");assert(l.Tokens[season]==1);assert(not R.Action(l,100,"Decor",season..":Flag",now,b));pure(l,"Equip",season..":Flag");checks+=1
  end
  l.XP=500;for _,id in ipairs(D.BlueprintOrder)do pure(l,"Blueprint",id)end;for id in pairs(D.Styles)do pure(l,"Style",id)end
  local p=Schema.Default();p.Life=l;assert(R.Valid(Schema.Migrate(p,players[1].UserId).Life));checks+=1
 end
 table.insert(verified,"200 progression simulations: offline harvest, atomic recipes, all businesses, 18 case variants/endings, four seasons, mastery and schema round trips")
 local actions={"Plant","Water","Harvest","Arrange","Business","Order","Work","Blueprint","Style","Case","PutAway","Clue","Deduce","Ending","Theme","Tour","Hunt","Token","Decor","Equip"}
 local malformed=0
 for _,action in ipairs(actions)do for _,value in ipairs({false,{},0/0,math.huge,-1,string.rep("x",100)})do local l=R.Default();local ok,accepted=pcall(R.Action,l,100,action,value,now,b);assert(ok and not accepted,"Malformed input accepted/threw: "..action);malformed+=1 end end
 table.insert(verified,"120 malformed pure requests rejected without throwing")
 local p,q=players[1],players[2];local profile=Data:Get(p);local house=H.ByPlayer[p.UserId].Model
 local function at(player,part,offset)player.Character:PivotTo(part.CFrame*CFrame.new(offset or Vector3.new(0,3,-4)));task.wait(.05)end
 local function act(player,action,arg,success)
  S.LastAction[player.UserId]=nil;local ok,why=S:Action(player,action,arg or "");local extra="";if action=="Tour"then local target=H.ByPlayer[player.UserId].Model.NeighborhoodLife.TourSign;local root=player.Character.HumanoidRootPart;local ray=RaycastParams.new();ray.FilterDescendantsInstances={player.Character,target.Parent};local hit=workspace:Raycast(root.Position,target.Position-root.Position,ray);extra=" position="..tostring(root.Position).." target="..tostring(target.Position).." hit="..(hit and hit.Instance:GetFullName()or "none")end;assert(ok==(success~=false),action..": "..tostring(why)..extra);checks+=1;return why
 end
 for _,player in ipairs(players)do
  local pr=Data:Get(player);pr.Currency=100000;pr.Building.Unlocked={GardenRoom=true,Workshop=true,Garage=true};require(script.Parent.Services.BuildingService):Restore(player)
  pr.Life=R.Default();S:Home(player)
  local home=H.ByPlayer[player.UserId].Model.NeighborhoodLife
  at(player,home.GardenBed1);act(player,"Plant","1:Daisy");act(player,"Harvest","1",false);pr.Life.Beds["1"].Planted=now-500
  act(player,"Harvest","1");act(player,"Harvest","1",false)
  at(player,H.ByPlayer[player.UserId].Model.NeighborhoodLife.LifeCounter);act(player,"Business","Furniture");act(player,"Order")
  for _,step in ipairs(D.Businesses.Furniture.Steps)do pr.Life.OrderReady=0;act(player,"Work",step)end
  assert(pr.Currency==100055,"Business and seed debit mismatch")
  pr.Life.XP=600;for _,id in ipairs(D.BlueprintOrder)do act(player,"Blueprint",id)end;act(player,"Style","Coastal")
  assert(R.Valid(pr.Life));assert(pr.Life.Blueprints.Lantern)
 end
 table.insert(verified,expected.." independent homes grow flowers, complete orders and install mastery decorations")
 at(q,house.NeighborhoodLife.GardenBed1);local cash=Data:Get(q).Currency;act(q,"Plant","1:Daisy",false);assert(Data:Get(q).Currency==cash)
 at(p,house.NeighborhoodLife.TourSign);act(p,"Tour","Open");assert(H.ByPlayer[p.UserId].Open and not H.ByPlayer[p.UserId].Locked)
 at(q,house.NeighborhoodLife.TourSign);act(q,"Visit",tostring(p.UserId));act(p,"Tour","Close");act(q,"VisitStop","1",false)
 at(p,house.NeighborhoodLife.TourSign);act(p,"Tour","Open");assert(H:DoorAction(p,house.Lock,"Lock"));assert(not profile.Life.TourOpen and H.ByPlayer[p.UserId].Locked,"Lock must close tour immediately");H:DoorAction(p,house.Lock,"Lock")
 at(p,house.NeighborhoodLife.TourSign);act(p,"Theme","GardenRetreat");act(p,"Challenge","",false)
 local items=require(script.Parent.Services.ItemService);local lamp=items:Create(p,"Lamp");at(p,house.DisplaySlots.Slot1);assert(items:Place(p,lamp.Id,1));at(p,house.NeighborhoodLife.TourSign);act(p,"Challenge");assert(profile.Life.Banners.GardenRetreat);act(p,"Challenge","",false)
 table.insert(verified,"Neighbor garden edits rejected; tours require opt-in and invalidate on close; starter-item challenge rewards once")
 for _,id in ipairs(D.ProjectOrder)do
  for i=1,D.Projects[id].Goal do local player=players[(i-1)%#players+1];at(player,S.Stations[id]);Data:Get(player).Life.WorkReady=0;act(player,"Renovate",id);act(player,"FinishRenovation",id,false);S.Tasks[player.UserId].Ready=0;act(player,"FinishRenovation",id);act(player,"FinishRenovation",id,false)end
  assert(S.Totals[id]==D.Projects[id].Goal);local total=S.Totals[id];S:Merge(p);S:Merge(p);assert(S.Totals[id]==total,"Contribution counted twice")
  at(p,S.Stations[id]);profile.Life.WorkReady=0;act(p,"Social",id);act(p,"Social",id,false);assert(profile.Life.Renovations[id])
 end
 table.insert(verified,"45 co-op repair steps, preparation/cooldown/replay guards, rejoin merge idempotency, all three usable landmarks")
 for _,id in ipairs(D.CaseOrder)do act(p,"Case",id);for i=1,3 do at(p,S.Stops[tostring(i)]);S.Travel[p.UserId]=nil;act(p,"Clue",tostring(i))end;act(p,"Deduce",D.Cases[id].People[profile.Life.Variant]);act(p,"Ending","1");act(p,"Ending","1",false)end
 profile.Life.NextHunt=0;act(p,"Hunt","Winter");for i=1,4 do at(p,S.Stops[tostring(i)]);S.Travel[p.UserId]=nil;act(p,"Token",tostring(i))end;act(p,"Decor","Winter:Flag");act(p,"Decor","Winter:Flag",false)
 for i=1,9 do local player=players[(i-1)%#players+1];local n=tostring((i-1)%3+1);at(player,S.Stops[n]);S.Travel[player.UserId]=nil;act(player,"Relay",n)end
 assert(S.Relay==0 and profile.Life.NextRelay>now);at(p,S.Stops["1"]);act(p,"Relay","1",false)
 table.insert(verified,"Real service routes verify stories, seasonal shop and multiplayer relay rewards; fixtures reposition characters and shorten preparation")
 -- Explicit fast-travel rejection without clearing the server receipt.
 profile.Life.NextHunt=0;act(p,"Hunt","Summer");at(p,S.Stops["1"]);S.Travel[p.UserId]=nil;act(p,"Token","1");at(p,S.Stops["2"]);act(p,"Token","2",false)
 local n=#house.NeighborhoodLife:GetDescendants();for _=1,30 do S:Home(p)end;assert(#house.NeighborhoodLife:GetDescendants()==n,"Rendering leaks objects")
 local snap=Data:Snapshot(p);assert(R.Valid(Schema.Migrate(snap,p.UserId).Life));assert(snap.Life~=profile.Life,"Snapshot aliases life data")
 table.insert(verified,"Rapid route teleport rejected; 30 redraws retain exact instance count; full profile snapshot migrates without aliasing")
 local samples={};for _=1,120 do table.insert(samples,game:GetService("RunService").Heartbeat:Wait()*1000)end;table.sort(samples)
 return {Passed=true,Clients=expected,Checks=checks,MalformedRequests=malformed,Verified=verified,HeartbeatP95Ms=samples[114],PerformanceCertified=false,OnlineSaveRejoinTested=false}
end
local ok,result=pcall(run);Test:EndTest(ok and result or {Passed=false,Error=tostring(result)})
