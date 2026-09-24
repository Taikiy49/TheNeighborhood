local A=require(script.Parent.CityArchitecture)
local M={}
function M.Build(W,context)
 local root=W.Root;local w=workspace.Neighborhood
 local function p(parent,n,s,x,y,z,c,mat,solid,class)return W.Part(parent,n,s,x,y,z,c,mat,solid,class)end
 local function localPart(m,n,size,x,y,z,color,mat,solid,class)
  local floor=m:FindFirstChild('Floor');local v=p(m,n,size,0,0,0,color,mat,solid,class);v.CFrame=floor.CFrame*CFrame.new(x,y-.2,z);return v
 end
 local furniture={Sofa=true,SofaBack=true,SofaFoot=true,CoffeeTable=true,CoffeeLeg=true,Bookcase=true,Book=true,TableTop=true,TableLeg=true,Seat=true,ChairBack=true,ChairLeg=true,StockShelf=true,Goods=true,ServiceCounter=true}
 local function clear(m)for _,v in ipairs(m:GetChildren())do if furniture[v.Name]then v:Destroy()end end end
 -- Purpose-built classrooms and a cinema replace generic lounge furnishing.
 local school=root.SchoolDistrict.CoastSchool;clear(school)
 for _,level in ipairs({0,12})do
  local board=localPart(school,'ClassBoard',{25,5,.2},0,level+6,15,A.Ink);A.Sign(board,'COAST SCHOOL - LEARN & PLAY')
  for _,x in ipairs({-17,-8,8,17})do for _,z in ipairs({-7,3})do localPart(school,'StudentDesk',{5,.4,3},x,level+2.7,z,A.Wood);localPart(school,'DeskBase',{.6,2.4,.6},x,level+1.3,z,A.Ink);localPart(school,'StudentChair',{2,.4,2},x,level+1.6,z-3,A.Ink,nil,true,'Seat')end end
 end
 local cinema=root.CommercialStrip.SunsetCinema;clear(cinema)
 local screen=localPart(cinema,'CinemaScreen',{30,8,.2},0,6,13,A.Ink);A.Sign(screen,'COAST PICTURES - THE NIGHT SKY')
 for _,y in ipairs({0,12})do for _,z in ipairs({-8,-2,4})do for _,x in ipairs({-13,-7,7,13})do localPart(cinema,'CinemaSeat',{3,.5,3},x,y+1.7,z,Color3.fromRGB(135,87,83),nil,true,'Seat');localPart(cinema,'CinemaSeatBack',{3,3,.3},x,y+3,z-1.6,A.Ink)end end end
 local upstairs=localPart(cinema,'UpperScreen',{30,8,.2},0,18,13,A.Ink);A.Sign(upstairs,'COMMUNITY SCREENING ROOM')
 local showroom=root.CommercialStrip.CarShowroom;clear(showroom)
 for _,x in ipairs({-12,12})do
  localPart(showroom,'DisplayCarBody',{6,2,10},x,2,0,Color3.fromRGB(137,174,159),Enum.Material.Metal)
  localPart(showroom,'DisplayCarRoof',{5,2,5},x,4,0,A.Cream,Enum.Material.Metal)
  for _,dx in ipairs({-3,3})do for _,z in ipairs({-3,3})do local wheel=localPart(showroom,'DisplayWheel',{1,2,2},x+dx,1,z,A.Ink);wheel.Shape=Enum.PartType.Cylinder end end
 end
 local keys=localPart(showroom,'CarSalesDesk',{8,3,3},0,2,9,A.Wood);A.Prompt(keys,'CoastalCarSales','Coast Motors','Browse cars')
 context.Interactions:Register('CoastalCarSales',function(player)context.Open(player,'Garage');return true end)
 local clothing=root.CommercialStrip.CoastalClothing
 local rail=localPart(clothing,'ClothingRail',{12,.3,.3},0,6,8,A.Ink,Enum.Material.Metal)
 for i=1,5 do localPart(clothing,'Shirt',{1.5,2,.2},-6+i*2,4.8,8,Color3.fromHSV(i*.15,.4,.85),Enum.Material.Fabric,false)end
 A.Prompt(rail,'CoastalBoutique','Coastal clothing','Browse boutique')
 context.Interactions:Register('CoastalBoutique',function(player)context.Open(player,'Boutique');return true end)
 local clinic=root.Downtown.SunsetHospital
 local help=localPart(clinic,'CareDesk',{6,3,3},-9,2,-5,A.Cream);A.Prompt(help,'CoastalCare','Coast clinic','Rest and recover')
 context.Interactions:Register('CoastalCare',function(player)local h=player.Character and player.Character:FindFirstChildOfClass('Humanoid');if not h then return false,'Your character is not ready.'end;h.Health=h.MaxHealth;return true,'Rested and ready to explore.'end)
 -- A neighborhood playground with usable swings, slide and climbing steps.
 local park=root.NeighborhoodPark
 p(park,'PlaySurface',{80,.2,42},-90,.15,10,Color3.fromRGB(178,153,116),Enum.Material.Sand)
 for _,x in ipairs({-115,-85})do
  for _,z in ipairs({-3,3})do p(park,'SwingSupport',{.6,12,.6},x,6,z,A.Wood)end
 end
 p(park,'SwingBeam',{30,.6,.6},-100,12,0,A.Wood)
 for _,x in ipairs({-108,-92})do p(park,'PlaySwingSeat',{4,.4,2},x,3,0,A.Ink,nil,true,'Seat');for _,dx in ipairs({-1.7,1.7})do p(park,'PlaySwingRope',{.1,9,.1},x+dx,7.5,0,A.Cream,nil,false)end end
 local slide=p(park,'Slide',{5,.5,17},-65,4,10,Color3.fromRGB(170,127,94),Enum.Material.Metal);slide.CFrame*=CFrame.Angles(math.rad(25),0,0)
 for i=1,12 do p(park,'SlideStep',{5,i*.5,1},-65,i*.25,24-i,A.Wood)end
 -- Tennis court and a baseball diamond complement the football and basketball grounds.
 p(root.SchoolDistrict,'TennisCourt',{55,.15,90},-600,.1,440,Color3.fromRGB(112,151,133),Enum.Material.Concrete)
 p(root.SchoolDistrict,'TennisNet',{50,3,.15},-600,2,440,A.Cream,Enum.Material.Fabric,false)
 for _,x in ipairs({-624,-576})do p(root.SchoolDistrict,'TennisLine',{.2,.02,82},x,.19,440,A.Cream,nil,false)end
 for _,z in ipairs({400,420,460,480})do p(root.SchoolDistrict,'TennisLine',{48,.02,.2},-600,.19,z,A.Cream,nil,false)end
 for _,data in ipairs({{-600,550},{-575,525},{-550,550},{-575,575}})do p(root.SchoolDistrict,'BaseballBase',{3,.2,3},data[1],.2,data[2],A.Cream)end
 local balls=p(root.SchoolDistrict,'SportsBallRack',{7,2,3},-340,1,375,A.Wood);A.Prompt(balls,'BeachBall','Sports court','Borrow a ball')
 -- Production job uses server time, distance validation and the existing saved economy.
 local factory=root.Industrial.CoastalWorks
 local machine=localPart(factory,'PackingMachine',{8,6,5},-14,3.5,8,Color3.fromRGB(140,161,165),Enum.Material.Metal)
 local conveyor=localPart(factory,'Conveyor',{18,1,4},0,2,7,A.Ink,Enum.Material.Metal)
 local panel=localPart(factory,'PackingControl',{2,2,.5},-14,4,5,A.Cream);A.Prompt(panel,'CoastalPacking','Packing station','Start / finish packing')
 local work={};context.Interactions:Register('CoastalPacking',function(player)
  local now=os.clock();if not work[player]then work[player]=now;return true,'Packing started. Come back to the control in 8 seconds.'end
  if now-work[player]<8 then return false,'The machine is still packing.'end
  local profile=context.Data:Get(player);if not profile then return false,'Your profile is still loading.'end
  work[player]=nil;profile.Currency=math.min(1000000000,profile.Currency+30);context.Record(player,'CityWork');context.Sync(player);return true,'Shipment packed! Earned $30.'
 end)
 game.Players.PlayerRemoving:Connect(function(player)work[player]=nil end)
 for _,x in ipairs({-200,-140})do
  p(root.Industrial,'TruckChassis',{8,3,21},x,2,565,A.Ink,Enum.Material.Metal);p(root.Industrial,'TruckCab',{8,7,7},x,6,556,Color3.fromRGB(158,174,155));p(root.Industrial,'TruckBox',{8,9,14},x,7,568,A.Cream)
  for _,dx in ipairs({-4,4})do for _,z in ipairs({558,573})do local wheel=p(root.Industrial,'TruckWheel',{1,3,3},x+dx,1.5,z,A.Ink);wheel.Shape=Enum.PartType.Cylinder end end
 end
 -- Replace solid campsite blocks with roofed tents that have actual entrances.
 local nature=root.Mountains
 for _,v in ipairs(nature:GetChildren())do if v.Name=='Tent'then v:Destroy()end end
 for _,x in ipairs({-140,-170,-200})do
  p(nature,'TentFloor',{12,.3,14},x,.2,-640,A.Wood)
  for _,side in ipairs({-1,1})do local roof=p(nature,'TentCanvas',{.3,10,14},x+side*3,4,-640,Color3.fromRGB(180,147,101),Enum.Material.Fabric);roof.CFrame*=CFrame.Angles(0,0,side*math.rad(37))end
  p(nature,'SleepingMat',{4,.25,9},x,.5,-640,Color3.fromRGB(99,139,129))
 end
 local fire=p(nature,'Campfire',{4,.5,4},-170,.5,-620,A.Wood);local glow=Instance.new('PointLight');glow.Color=Color3.fromRGB(255,186,104);glow.Range=15;glow.Brightness=.8;glow.Parent=fire
 for _,x in ipairs({-182,-158})do p(nature,'CampBench',{8,.4,2},x,1.6,-620,A.Wood,nil,true,'Seat')end
 -- Trail-side planting breaks up the bare district borders; keep road lanes empty.
 for _,x in ipairs({-620,-575,45,490})do for z=-540,550,70 do W.Tree(root.Land,x,z,x>0)end end
 for x=-500,450,90 do W.Tree(root.Land,x,-350,false)end
 -- Boardwalk links and continuous dock connections.
 p(root.Beach,'FishingPier',{125,.5,9},650,3,184,A.Wood,Enum.Material.WoodPlanks)
 for i=1,12 do p(root.Beach,'FishingAccessStep',{2,i*.25,7},563+i*2,i*.125,184,A.Wood)end
 p(root.Beach,'MarinaAccess',{45,.5,9},582.5,.6,240,A.Wood,Enum.Material.WoodPlanks)
 -- Keep legacy leisure rooms, with their actual service targets, in suitable districts.
 local life=w.Runtime.NeighborhoodLife
 if life:FindFirstChild('Cafe')then W.Move(life.Cafe,Vector3.new(-390,0,10),0)end
 if life:FindFirstChild('Clubhouse')then W.Move(life.Clubhouse,Vector3.new(-480,0,10),0)end
 if life:FindFirstChild('Greenhouse')then W.Move(life.Greenhouse,Vector3.new(-60,0,-470),0)end
 for _,v in ipairs(life:GetChildren())do if v:IsA('BasePart')then v.Position+=Vector3.new(-260,0,5)end end
 for i,gnome in ipairs(w.Runtime.GnomeTrail:GetChildren())do gnome:PivotTo(gnome:GetPivot()+Vector3.new(-260,0,0))end
 local old=w.MapleHeights.OldTown
 -- Preserve the roof route as two joined reading-room roofs, rather than separated buildings.
 W.Move(old.Brownstone1,Vector3.new(-510,0,380),0);W.Move(old.Brownstone2,Vector3.new(-474,0,380),0)
 old.RooftopBridge.Position=Vector3.new(-492,24.8,388);old.RouteStart.Position=Vector3.new(-450,2,364)
 local story=w.Runtime.MapleAdventures
 for _,v in ipairs(story:GetChildren())do if v.Name=='Maple Adventures'or v.Name=='BoardPost'then v.Position+=Vector3.new(-300,0,120)end end
 for _,v in ipairs(w:GetDescendants())do
  if v:IsA('BasePart')then
   if v:GetAttribute('CityJob')and v:GetAttribute('Step')==1 then w:SetAttribute('Job'..v:GetAttribute('CityJob'),v.Position)end
   if v:GetAttribute('Action')=='HousingDesk'then w:SetAttribute('HousingDesk',v.Position)end
  end
 end
 w:SetAttribute('JobDelivery',w.Map.CommunityBoard.Position)
 -- The pier is a finished promenade, with edge protection, lamps and food stalls.
 local beach=root.Beach
 for _,z in ipairs({-65,115})do p(beach,'PierRail',{180,3,.25},810,5,z,A.Cream,Enum.Material.Metal)end
 p(beach,'PierEndRail',{.25,3,180},900,5,25,A.Cream,Enum.Material.Metal)
 for _,z in ipairs({-44,80})do p(beach,'PierSideRail',{.25,3,42},720,5,z,A.Cream,Enum.Material.Metal)end
 for _,z in ipairs({-22.5,22.5})do p(beach,'ApproachRail',{125,3,.25},657.5,5,z,A.Cream,Enum.Material.Metal)end
 for x=610,890,35 do for _,z in ipairs({-63,113})do if x>=720 then
  p(beach,'PierLampPost',{.35,10,.35},x,8,z,A.Ink,Enum.Material.Metal)
  local lamp=p(beach,'PierLamp',{1,1.3,1},x,13,z,A.Cream,Enum.Material.Neon,false);local light=Instance.new('PointLight');light.Brightness=.55;light.Range=20;light.Color=Color3.fromRGB(255,220,164);light.Parent=lamp
 end end end
 for i=1,32 do local a=(i-1)*math.pi/16;local b=i*math.pi/16
  for _,z in ipairs({8,12})do local v1=Vector3.new(790+math.sin(a)*28,39+math.cos(a)*28,z);local v2=Vector3.new(790+math.sin(b)*28,39+math.cos(b)*28,z);local rim=p(beach,'FerrisRim',{.65,.65,(v2-v1).Magnitude+.15},0,0,0,Color3.fromRGB(229,189,118),Enum.Material.Neon,false);rim.CFrame=CFrame.lookAt((v1+v2)/2,v2)end
 end
 for _,z in ipairs({-15,30})do
  p(beach,'SnackCounter',{12,3,5},880,5,z,Color3.fromRGB(179,120,102));p(beach,'SnackCanopy',{16,.5,9},880,12,z,A.Cream)
  for _,x in ipairs({873,887})do p(beach,'SnackPost',{.4,9,.4},x,8,z,A.Ink)end
  local snack=p(beach,'PopcornBucket',{2,2,2},880,7.5,z,A.Cream);A.Prompt(snack,'CoastSnack','Pier refreshments','Take free popcorn')
 end
 context.Interactions:Register('CoastSnack',function(player)
  local bag=player:FindFirstChildOfClass('Backpack');if not bag then return false,'Your bag is not ready.'end
  if bag:FindFirstChild('Pier popcorn')or player.Character:FindFirstChild('Pier popcorn')then return false,'You already have popcorn.'end
  local tool=Instance.new('Tool');tool.Name='Pier popcorn';tool.CanBeDropped=false
  local handle=Instance.new('Part');handle.Name='Handle';handle.Size=Vector3.new(1,1.2,1);handle.Color=Color3.fromRGB(235,212,151);handle.CanCollide=false;handle.Parent=tool;tool.Parent=bag
  tool.Activated:Once(function()local h=player.Character and player.Character:FindFirstChildOfClass('Humanoid');if h then h.Health=math.min(h.MaxHealth,h.Health+5)end;tool:Destroy()end)
  return true,'Enjoy your popcorn!'
 end)
 for _,x in ipairs({765,810,850})do p(beach,'PierBench',{9,.5,3},x,5,100,A.Wood,nil,true,'Seat');p(beach,'PierBenchBack',{9,2,.3},x,6,101.5,A.Wood)end
 -- Distinct hotel silhouettes cluster on the northern entertainment boulevard.
 local resort=W.Building(root.Downtown,'PalmResort',175,-480,48,38,5,Color3.fromRGB(184,181,162),math.pi,'store')
 p(resort,'SetbackRoof',{32,8,26},175,64,-480,A.Cream,Enum.Material.Concrete)
 local gallery=W.Building(root.Downtown,'OceanGallery',400,-480,48,36,3,Color3.fromRGB(152,184,187),math.pi)
 local dome=p(gallery,'GalleryDome',{32,16,32},400,39,-480,Color3.fromRGB(150,195,200),Enum.Material.Glass,false);dome.Shape=Enum.PartType.Ball
 local theater=W.Building(root.Downtown,'SunsetTheatre',175,-410,48,32,2,Color3.fromRGB(193,144,123),math.pi)
 local marquee=p(theater,'Marquee',{38,3,2},175,9,-392,Color3.fromRGB(237,192,112),Enum.Material.Neon,false);marquee.CFrame*=CFrame.Angles(0,math.pi,0);A.Sign(marquee,'SUNSET LIVE')
 local fountain=p(root.Downtown,'FountainBasin',{35,1,25},400,.7,-410,A.Cream,Enum.Material.Marble)
 local water=p(root.Downtown,'FountainWater',{32,.15,22},400,1.3,-410,Color3.fromRGB(90,174,190),Enum.Material.Glass,false)
 for _,dx in ipairs({-10,0,10})do local jet=p(root.Downtown,'FountainJet',{.35,5,.35},400+dx,3.8,-410,Color3.fromRGB(164,218,223),Enum.Material.Glass,false);jet.Transparency=.3 end
 local lighthouse=W.Building(beach,'PacificLighthouse',615,-520,26,24,4,A.Cream,0)
 local lantern=p(lighthouse,'BeaconGlass',{16,8,16},615,53,-520,Color3.fromRGB(173,217,222),Enum.Material.Glass,false);lantern.Transparency=.35
 local beacon=Instance.new('PointLight');beacon.Range=55;beacon.Brightness=1;beacon.Color=Color3.fromRGB(255,233,175);beacon.Parent=lantern
 p(lighthouse,'BeaconCap',{20,2,20},615,58,-520,A.Ink)
 p(beach,'ConcertStage',{45,3,26},603,1.5,-230,A.Wood,Enum.Material.WoodPlanks)
 p(beach,'StageRoof',{48,1,28},603,18,-230,A.Cream)
 for _,x in ipairs({581,625})do p(beach,'StageColumn',{1,18,1},x,9,-238,A.Ink)end
 for i=1,6 do p(beach,'StageStep',{12,i*.5,2},603,i*.25,-210-i*2,A.Wood)end
 for _,z in ipairs({-190,-180})do for _,x in ipairs({588,604,620})do p(beach,'AudienceBench',{10,.5,3},x,1.7,z,A.Wood,nil,true,'Seat')end end
 for index,z in ipairs({210,310})do
  local hull=p(beach,'MooredBoat',{9,2,20},766,1,z,index==1 and Color3.fromRGB(156,183,176)or Color3.fromRGB(204,176,133),Enum.Material.WoodPlanks)
  p(beach,'BoatMast',{.35,24,.35},766,14,z,A.Wood);local sail=p(beach,'Sail',{.2,17,11},766,15,z+4,A.Cream,Enum.Material.Fabric,false)
  p(beach,'BoatSeat',{4,.5,3},766,3,z-6,A.Ink,nil,true,'Seat')
  for _,x in ipairs({761.7,770.3})do p(beach,'BoatRail',{.3,2,20},x,3,z,A.Cream)end
  p(beach,'BoatBoardingWalk',{34,.5,6},749,1.3,z-12,A.Wood,Enum.Material.WoodPlanks)
 end
 p(beach,'OuterMarinaWalk',{6,.5,120},733,1.3,255,A.Wood,Enum.Material.WoodPlanks)
 -- Parked trainer complements the flyable sightseeing plane.
 p(root.Airport,'TrainerFuselage',{6,5,22},230,4,420,Color3.fromRGB(192,154,108),Enum.Material.Metal)
 p(root.Airport,'TrainerWing',{32,.5,6},230,5,420,A.Cream,Enum.Material.Metal)
 p(root.Airport,'TrainerTail',{12,.5,4},230,7,429,A.Ink,Enum.Material.Metal)
 clear(root.Airport.HangarOne)
 for _,v in ipairs(root.Airport:GetChildren())do if v.Name:match('^Trainer')then v.Parent=root.Airport.HangarOne end end
 -- Tall signs sit on district sidewalks and communicate an actual destination.
 for _,s in ipairs({{'MAPLE / PALM / SUNSET LANES',-530,-285,0},{'SUNSET BOULEVARD',340,-350,0},{'COAST SCHOOL & SPORTS',-480,280,0},{'PACIFIC PIER & CARNIVAL',550,-35,-math.pi/2},{'AIRPORT',120,290,0},{'COUNTRY ROAD & TRAILS',-525,-560,0}})do W.Sign(root,'DistrictSign',s[1],s[2],s[3],s[4])end
end
return M
