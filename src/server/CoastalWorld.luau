-- One final district layout, applied after legacy gameplay systems have registered.
local A=require(script.Parent.CityArchitecture)
local W={Buildings={},Districts={},Nodes={},Edges={}}
local grass=Color3.fromRGB(119,149,104);local sand=Color3.fromRGB(229,210,161)
local asphalt=Color3.fromRGB(65,72,76);local pavement=Color3.fromRGB(201,192,174)
local function folder(parent,name)local f=Instance.new('Folder');f.Name=name;f.Parent=parent;return f end
function W.Part(parent,name,size,x,y,z,color,material,solid,class)
 return A.Part(parent,name,size,Vector3.new(x,y,z),color,material,solid,class)
end
function W.Move(model,center,yaw)
 local basis=model:FindFirstChild('Floor')or model:FindFirstChild('Foundation')
 local old=basis and CFrame.new(basis.Position.X,0,basis.Position.Z)or CFrame.new(model:GetPivot().Position.X,0,model:GetPivot().Position.Z)
 local t=CFrame.new(center)*CFrame.Angles(0,yaw or 0,0)*old:Inverse()
 model:PivotTo(t*model:GetPivot())
 for _,v in ipairs(model:GetDescendants())do for key,val in pairs(v:GetAttributes())do if typeof(val)=='Vector3'and(key=='Destination'or key=='Entry'or key=='FireEscape')then v:SetAttribute(key,t*val)end end end
 local entry=model:GetAttribute('Entry');if typeof(entry)=='Vector3' then model:SetAttribute('Entry',t*entry)end
 return t
end
function W.Sign(parent,name,text,x,z,yaw)
 local p=W.Part(parent,name,{18,3,.35},x,7,z,A.Ink,Enum.Material.Metal,false)
 p.CFrame*=CFrame.Angles(0,yaw or 0,0);A.Sign(p,text)
 for _,d in ipairs({-7,7})do local at=p.CFrame*Vector3.new(d,-4,0);W.Part(parent,'SignPost',{.3,5,.3},at.X,at.Y,at.Z,A.Ink,Enum.Material.Metal)end
 return p
end
function W.Building(parent,name,x,z,width,depth,floors,color,yaw,kind)
 local m,p=A.Building(parent,name,Vector3.new(x,0,z),width,depth,floors,color,name:gsub('(%l)(%u)','%1 %2'):upper())
 local levels={};for i=0,floors-1 do table.insert(levels,i*12);A.Lounge(p,i*12);if width>=30 then A.Table(p,6,i*12,-5)end end
 A.Lifts(p,levels,name)
 if kind=='store' then p('ServiceCounter',{10,3,3},7,1.9,4,A.Ink);p('StockShelf',{9,6,2},7,3.4,10,A.Wood);for i=1,6 do p('Goods',{.8,1.2,.6},3+i,3,8.8,Color3.fromHSV(i/8,.35,.85),nil,false)end end
 if kind=='clinic'then p('ExamBed',{5,1,9},5,2,-3,A.Cream);p('MedicalCabinet',{4,6,2},8,3.4,10,A.Cream)end
 W.Move(m,Vector3.new(x,0,z),yaw or 0);table.insert(W.Buildings,m);return m,p
end
function W.Road(parent,x1,z1,x2,z2,name)
 local a=Vector3.new(x1,.12,z1);local b=Vector3.new(x2,.12,z2);local delta=b-a
 assert(delta.Magnitude>28,'road too short')
 local key=function(x,z)return x..':'..z end
 for _,pos in ipairs({a,b})do local k=key(pos.X,pos.Z);if not W.Nodes[k]then
  W.Nodes[k]=pos;W.Part(parent,'IntersectionPaving',{44,.18,44},pos.X,.03,pos.Z,pavement,Enum.Material.Pavement)
  W.Part(parent,'Junction',{28,.18,28},pos.X,.12,pos.Z,asphalt,Enum.Material.Asphalt)
 end end
 local cf=CFrame.lookAt((a+b)/2,b);local len=delta.Magnitude-28
 local road=A.Part(parent,name,{28,.18,len},cf.Position,asphalt,Enum.Material.Asphalt);road.CFrame=cf
 for _,side in ipairs({-1,1})do local c=cf*CFrame.new(side*18,.08,0);local p=A.Part(parent,'Sidewalk',{8,.18,len},c.Position,pavement,Enum.Material.Pavement);p.CFrame=c end
 for d=30,delta.Magnitude-30,24 do local at=a+delta.Unit*d;local p=A.Part(parent,'LaneDash',{.3,.02,8},at+Vector3.new(0,.105,0),A.Cream,Enum.Material.SmoothPlastic,false);p.CFrame=CFrame.lookAt(p.Position,p.Position+delta.Unit)end
 table.insert(W.Edges,{key(x1,z1),key(x2,z2)})
end
function W.Tree(parent,x,z,palm)
 if W.Root and W.Root:FindFirstChild('Roads')then for _,road in ipairs(W.Root.Roads:GetChildren())do if road.Material==Enum.Material.Asphalt then local v=road.CFrame:PointToObjectSpace(Vector3.new(x,road.Position.Y,z));if math.abs(v.X)<road.Size.X/2+4 and math.abs(v.Z)<road.Size.Z/2+4 then return end end end end
 local h=palm and 17 or 10
 W.Part(parent,'Trunk',{1,h,1},x,h/2,z,A.Wood,Enum.Material.Wood)
 if palm then for i=0,5 do local p=W.Part(parent,'PalmFrond',{3,.5,13},x,h,z,Color3.fromRGB(74,119,85),Enum.Material.Grass,false);p.CFrame=CFrame.new(x,h,z)*CFrame.Angles(0,i*math.pi/3,math.rad(12))*CFrame.new(0,0,4)end
 else local p=W.Part(parent,'TreeCrown',{9,11,9},x,h+3,z,grass,Enum.Material.Grass,false);p.Shape=Enum.PartType.Ball end
end
function W.Init(context)
 W.Context=context;W.Buildings={};W.Nodes={};W.Edges={}
 local w=workspace.Neighborhood;local root=folder(w,'CoastalWorld');W.Root=root
 local archive=folder(game.ServerStorage,'PreviousDistrictScenery')
 -- Keep gameplay objects and their paths; retire overlapping legacy scenery.
 for _,name in ipairs({'ArtDirection','GardenDetails','DetailCorrections','ValleyBackdrop','WalkNetwork','Wayfinding','UrbanGround','LivingStreet'})do local f=w:FindFirstChild(name);if f then for _,v in ipairs(f:GetChildren())do v.Parent=archive end end end
 for _,v in ipairs(w.Map:GetChildren())do if v.Name~='CommunityBoard'and v.Name~='CommunitySpawn'and v.Name~='MapleGreenSign'then v.Parent=archive end end
 for _,name in ipairs({'Paths','NeighborhoodPark','StreetEdges','StreetLife','Skyline','CoveBridge'})do local f=w.MapleHeights:FindFirstChild(name);if f then f.Parent=archive end end
 for _,v in ipairs(w.TownPolish:GetChildren())do v.Parent=archive end
 for _,v in ipairs(w.SideDestinations.Connections:GetChildren())do v.Parent=archive end
 for _,v in ipairs(w.Recreation:GetChildren())do if v.Name~='Green'and v.Name~='Meadow'then v.Parent=archive end end
 local land=folder(root,'Land');W.Part(land,'Mainland',{1280,8,1500},-80,-4,-50,grass,Enum.Material.Grass)
 workspace.Terrain:Clear()
 workspace.Terrain:FillBlock(CFrame.new(620,-8,-50),Vector3.new(120,16,1500),Enum.Material.Sand)
 workspace.Terrain:FillBlock(CFrame.new(1210,-35,-50),Vector3.new(1060,8,1700),Enum.Material.Sand)
 workspace.Terrain:FillBlock(CFrame.new(1210,-16,-50),Vector3.new(1060,30,1700),Enum.Material.Water)
 workspace.Terrain:FillBlock(CFrame.new(664,-4,-50),Vector3.new(32,6,1500),Enum.Material.Water)
 workspace.Terrain.WaterColor=Color3.fromRGB(41,144,165);workspace.Terrain.WaterTransparency=.3;workspace.Terrain.WaterWaveSize=.18
 local roads=folder(root,'Roads')
 -- Explicit street graph. Every road ends at a joined junction or turning square.
 for _,z in ipairs({-380,-300,-60,80,260,600})do local xs={-560,-440,-260,-80,80,300,520};for i=1,#xs-1 do W.Road(roads,xs[i],z,xs[i+1],z,'DistrictRoad')end end
 for _,x in ipairs({-560,80,520})do local zs={-600,-380,-300,-60,80,260,600};for i=1,#zs-1 do W.Road(roads,x,zs[i],x,zs[i+1],'Connector')end end
 for _,x in ipairs({-440,-260,-80})do W.Road(roads,x,-300,x,-60,'ResidentialLane')end
 for _,pair in ipairs({{-380,-300},{-300,-60},{-60,80},{80,260},{260,600}})do W.Road(roads,300,pair[1],300,pair[2],'SunsetBoulevard')end
 W.Road(roads,-560,-600,80,-600,'CountryRoad');W.Road(roads,80,-600,520,-600,'CoastApproach')
 local residential=folder(root,'Suburbs');W.Districts.Suburbs=Vector3.new(-260,0,-180)
 for _,h in ipairs(w.Houses:GetChildren())do
  local b=h.Foundation.CFrame;local id=tonumber(h.Name:match('%d+'))
  local f=h:FindFirstChild('Lawn');if f then f.Material=Enum.Material.Grass;f.Color=grass end
  local walk=W.Part(residential,'HomeWalk',{6,.2,17},0,0,0,pavement,Enum.Material.Pavement);walk.CFrame=b*CFrame.new(0,-.35,-26)
  local garage=h.BaseGarage;garage.Driveway.Size=Vector3.new(18,.2,21);garage.Driveway.CFrame=b*CFrame.new(-32,-.35,-24.5)
  h.Mailbox.Sign.SurfaceGui.TextLabel.Text=h:GetAttribute('Address')
  local lot=W.Part(residential,'GardenBed',{7,.8,4},0,0,0,A.Cream,Enum.Material.Concrete);lot.CFrame=b*CFrame.new(13,0,-23)
  local at=b*Vector3.new(13,0,-23);W.Tree(residential,at.X,at.Z,false)
 end
 local park=folder(root,'NeighborhoodPark');W.Part(park,'ParkLawn',{300,.14,90},-280,.05,5,grass,Enum.Material.Grass)
 for _,x in ipairs({-400,-340,-220,-160})do W.Tree(park,x,25,false)end
 w.Map.CommunitySpawn.CFrame=CFrame.new(-260,2,-40);w.Map.CommunityBoard.CFrame=CFrame.new(-280,5,-35);w.Map.MapleGreenSign.CFrame=CFrame.new(-240,5,-35)
 for _,guide in ipairs(w.GuideCharacters:GetChildren())do local p=guide:GetPivot();guide:PivotTo(CFrame.new(-265+(guide.Name=='Mabel'and 0 or guide.Name=='Dealer'and 15 or -15),p.Position.Y,-28)*p.Rotation)end
 local downtown=folder(root,'Downtown');W.Districts.Downtown=Vector3.new(300,0,-130)
 W.Part(downtown,'BoulevardBlocks',{370,.1,430},300,.02,-135,pavement,Enum.Material.Pavement)
 -- Existing shops and jobs become actual downtown destinations.
 W.Move(w.MapleHeights.MarketAvenue.MaplePizza,Vector3.new(220,0,-90),-math.pi/2)
 W.Move(w.MapleHeights.MarketAvenue.MapleLaundry,Vector3.new(220,0,-155),-math.pi/2)
 W.Move(w.MapleHeights.Uptown.MapleHotel,Vector3.new(380,0,-170),-math.pi/2)
 W.Move(w.MapleHeights.Uptown.ParkApartments,Vector3.new(380,0,-90),-math.pi/2)
 W.Move(w.MapleTower,Vector3.new(400,0,-265),math.pi/2)
 for _,n in ipairs({'MapleHotel','ParkApartments'})do table.insert(W.Buildings,w.MapleHeights.Uptown[n])end
 for _,n in ipairs({'MaplePizza','MapleLaundry'})do table.insert(W.Buildings,w.MapleHeights.MarketAvenue[n])end
 local b,p=W.Building(downtown,'SunburstHotel',200,-260,42,38,7,Color3.fromRGB(215,183,126),-math.pi/2,'store')
 -- Stepped crown and illuminated fins give the landmark a separate silhouette.
 W.Part(b,'Crown',{24,12,24},200,92,-260,A.Cream,Enum.Material.Concrete)
 for _,z in ipairs({-277,-243})do W.Part(b,'GoldenFin',{1,77,1},178,42,z,Color3.fromRGB(243,187,76),Enum.Material.Neon,false)end
 local c=W.Building(downtown,'CivicHall',160,0,44,32,2,A.Cream,math.pi,'store')
 W.Building(downtown,'CoastBank',225,25,32,28,2,Color3.fromRGB(166,179,176),math.pi,'store')
 W.Building(downtown,'SunsetHospital',395,15,44,32,3,Color3.fromRGB(213,222,213),math.pi,'clinic')
 local monument=W.Part(downtown,'SunburstMonument',{2,25,2},300,13,0,Color3.fromRGB(231,181,83),Enum.Material.Metal);monument.CFrame*=CFrame.Angles(0,0,.4)
 -- Plaza sits off the boulevard, never in a traffic lane.
 monument.Position=Vector3.new(470,13,-150)
 W.Part(downtown,'Plaza',{55,.2,90},462,.15,-150,pavement,Enum.Material.Marble)
 for _,z in ipairs({-175,-125})do W.Tree(downtown,465,z,true)end
 for _,z in ipairs({-210,40})do
  W.Part(downtown,'PedestrianBridge',{70,.7,10},300,15,z,A.Cream,Enum.Material.Concrete)
  for _,dz in ipairs({-5,5})do W.Part(downtown,'BridgeRail',{70,3,.25},300,16.8,z+dz,A.Ink,Enum.Material.Metal)end
  for _,x in ipairs({263,337})do for i=1,30 do W.Part(downtown,'BridgeStair',{8,i*.5,1.4},x,i*.25,z-42+i*1.4,A.Cream,Enum.Material.Concrete)end end
 end
 for z=-280,40,40 do for _,x in ipairs({274,326})do W.Tree(downtown,x,z,true)end end
 local commerce=folder(root,'CommercialStrip');W.Districts.Commercial=Vector3.new(-260,0,170)
 W.Part(commerce,'RetailPaving',{570,.1,140},-260,.02,170,pavement,Enum.Material.Pavement)
 W.Move(w.SideDestinations.CornerCafe,Vector3.new(-460,0,130),0)
 W.Move(w.SideDestinations.RepairWorkshop,Vector3.new(-140,0,130),0)
 W.Move(w.Shops.GeneralStore,Vector3.new(-375,0,145),0)
 W.Move(w.Shops.PawnShop,Vector3.new(-265,0,145),0)
 W.Building(commerce,'CoastalClothing',-460,210,36,26,1,Color3.fromRGB(185,159,179),math.pi,'store')
 W.Building(commerce,'SunsetCinema',-350,210,44,28,2,Color3.fromRGB(121,141,164),math.pi,'store')
 W.Building(commerce,'CarShowroom',-230,210,46,28,1,Color3.fromRGB(197,201,190),math.pi,'store')
 W.Building(commerce,'FuelAndSnacks',-120,210,32,24,1,Color3.fromRGB(195,114,94),math.pi,'store')
 for _,x in ipairs({-125,-115})do W.Part(commerce,'FuelPump',{3,5,2},x,2.5,238,A.Cream,Enum.Material.Metal)end
 local school=folder(root,'SchoolDistrict');W.Districts.School=Vector3.new(-440,0,400)
 W.Building(school,'CoastSchool',-460,330,56,32,2,Color3.fromRGB(204,172,125),0,'store')
 W.Move(w.MapleHeights.OldTown.Brownstone1,Vector3.new(-520,0,330),0)
 W.Move(w.MapleHeights.OldTown.Brownstone2,Vector3.new(-520,0,390),0)
 W.Part(school,'FootballField',{110,.14,145},-440,.1,475,Color3.fromRGB(73,128,90),Enum.Material.Grass)
 for z=415,535,20 do W.Part(school,'FieldLine',{100,.02,.2},-440,.185,z,A.Cream,Enum.Material.SmoothPlastic,false)end
 for _,z in ipairs({410,540})do for _,x in ipairs({-451,-429})do W.Part(school,'GoalPost',{.4,12,.4},x,6,z,A.Cream,Enum.Material.Metal)end;W.Part(school,'GoalBar',{22,.4,.4},-440,12,z,A.Cream,Enum.Material.Metal)end
 W.Part(school,'BasketballCourt',{50,.14,75},-335,.1,425,Color3.fromRGB(155,119,96),Enum.Material.Concrete)
 for _,z in ipairs({393,457})do W.Part(school,'HoopPole',{.4,11,.4},-335,5.5,z,A.Ink);W.Part(school,'Backboard',{8,5,.3},-335,10,z,A.Cream)end
 local industrial=folder(root,'Industrial');W.Districts.Industrial=Vector3.new(-120,0,430)
 W.Part(industrial,'Yard',{220,.14,245},-140,.02,435,Color3.fromRGB(145,151,149),Enum.Material.Concrete)
 W.Move(w.MapleHeights.Waterfront.WillowWarehouse,Vector3.new(-190,0,325),0)
 W.Building(industrial,'CoastalWorks',-100,330,55,35,1,Color3.fromRGB(153,167,168),0,'store')
 for i=1,7 do W.Part(industrial,'ShippingContainer',{30,12,12},-210+(i%3)*45,6,400+math.floor(i/3)*22,Color3.fromHSV(i*.12,.38,.67),Enum.Material.Metal)end
 W.Part(industrial,'CraneMast',{3,62,3},-90,31,465,A.Wood,Enum.Material.Metal);W.Part(industrial,'CraneJib',{80,3,3},-100,60,465,A.Wood,Enum.Material.Metal)
 for _,x in ipairs({-210,-165})do W.Part(industrial,'ConstructionSlab',{30,.7,30},x,.35,530,A.Cream,Enum.Material.Concrete);for _,dx in ipairs({-12,12})do W.Part(industrial,'SteelColumn',{1,20,1},x+dx,10,530,A.Ink,Enum.Material.Metal)end end
 local airport=folder(root,'Airport');W.Districts.Airport=Vector3.new(270,0,440)
 W.Part(airport,'Apron',{365,.15,265},300,.02,435,Color3.fromRGB(154,161,160),Enum.Material.Concrete)
 W.Part(airport,'Runway',{46,.12,260},415,.17,445,asphalt,Enum.Material.Asphalt)
 for z=335,555,22 do W.Part(airport,'RunwayDash',{1,.02,10},415,.24,z,A.Cream,Enum.Material.SmoothPlastic,false)end
 W.Building(airport,'CoastTerminal',205,330,66,34,2,Color3.fromRGB(173,197,195),0,'store')
 W.Building(airport,'ControlTower',130,385,26,26,4,A.Cream,0)
 W.Building(airport,'HangarOne',230,410,60,45,1,Color3.fromRGB(133,153,163),0)
 W.Part(airport,'Helipad',{45,.15,45},160,.17,525,Color3.fromRGB(110,127,135),Enum.Material.Concrete)
 local rural=folder(root,'Farmland');W.Districts.Farmland=Vector3.new(-330,0,-480)
 W.Building(rural,'CoastBarn',-370,-480,50,36,1,Color3.fromRGB(166,83,68),0,'store')
 W.Move(w.SideDestinations.OrchardStand,Vector3.new(-470,0,-450),0)
 for x=-270,-100,22 do W.Part(rural,'CropBed',{12,.7,95},x,.35,-480,Color3.fromRGB(116,92,63),Enum.Material.Ground);for z=-520,-440,12 do W.Part(rural,'Crops',{6,2,5},x,1.5,z,Color3.fromRGB(125,157,75),Enum.Material.Grass,false)end end
 local silo=W.Part(rural,'Silo',{24,50,24},-440,25,-520,Color3.fromRGB(167,177,174),Enum.Material.Metal);silo.Shape=Enum.PartType.Cylinder;silo.CFrame=CFrame.new(-440,25,-520)*CFrame.Angles(0,0,math.pi/2);silo.Size=Vector3.new(50,24,24)
 W.Part(rural,'WindmillTower',{8,38,8},-500,19,-520,A.Cream,Enum.Material.Concrete)
 for i=0,3 do local blade=W.Part(rural,'WindmillBlade',{3,25,.5},-500,39,-526,A.Wood);blade.CFrame=CFrame.new(-500,39,-526)*CFrame.Angles(0,0,i*math.pi/2)*CFrame.new(0,10,0)end
 local nature=folder(root,'Mountains');W.Districts.Mountains=Vector3.new(-200,0,-650)
 for i=-5,4 do workspace.Terrain:FillBall(Vector3.new(i*115,15,-730),85+(i%3)*13,Enum.Material.Rock)end
 W.Building(nature,'TrailCabin',40,-650,28,24,1,A.Wood,math.pi)
 local last=Vector3.new(20,.25,-615)
 for i=1,24 do local next=Vector3.new(20-i*18,i*2,-615-math.sin(i*.22)*35);local d=next-last;local p=W.Part(nature,'Trail',{7,.5,d.Magnitude+1},0,0,0,Color3.fromRGB(157,137,104),Enum.Material.Ground);p.CFrame=CFrame.lookAt((last+next)/2,next);workspace.Terrain:FillBall((last+next)/2-Vector3.new(0,8,0),10,Enum.Material.Ground);workspace.Terrain:FillBlock(p.CFrame+Vector3.new(0,7,0),Vector3.new(9,14,d.Magnitude+3),Enum.Material.Air);last=next end
 W.Part(nature,'LookoutDeck',{25,.5,20},last.X,last.Y,last.Z,A.Wood,Enum.Material.WoodPlanks)
 for _,x in ipairs({-140,-170,-200})do local tent=W.Part(nature,'Tent',{13,9,14},x,4.5,-640,Color3.fromRGB(168,128,82),Enum.Material.Fabric);tent.Shape=Enum.PartType.Block end
 -- Cave entrance is a constructed rock arch beside the accessible trail.
 for _,x in ipairs({-270,-248})do W.Part(nature,'CaveSide',{7,20,25},x,10,-654,Color3.fromRGB(113,120,117),Enum.Material.Rock)end
 workspace.Terrain:FillBlock(CFrame.new(-259,8,-654),Vector3.new(20,16,28),Enum.Material.Air)
 W.Part(nature,'CaveRoof',{30,8,25},-259,22,-654,Color3.fromRGB(113,120,117),Enum.Material.Rock)
 local fall=W.Part(nature,'Waterfall',{8,45,1},-330,25,-663,Color3.fromRGB(118,193,208),Enum.Material.Glass,false);fall.Transparency=.25
 local foam=Instance.new('ParticleEmitter');foam.Rate=30;foam.Lifetime=NumberRange.new(.5,1);foam.Speed=NumberRange.new(4,8);foam.Parent=fall
 local beach=folder(root,'Beach');W.Districts.Beach=Vector3.new(610,0,0)
 W.Part(beach,'Boardwalk',{12,.3,1200},560,.2,-20,A.Wood,Enum.Material.WoodPlanks)
 for z=-540,540,60 do W.Tree(beach,546,z,true)end
 W.Part(beach,'Pier',{125,1,45},657.5,3,0,A.Wood,Enum.Material.WoodPlanks)
 W.Part(beach,'CarnivalDeck',{180,1,180},810,3,25,A.Wood,Enum.Material.WoodPlanks)
 for x=610,880,30 do for _,z in ipairs({-20,70})do W.Part(beach,'PierPile',{2,40,2},x,-15,z,A.Wood,Enum.Material.Wood)end end
 for i=1,12 do W.Part(beach,'PierAccessStep',{12,i*.25,2},569+i*2,i*.125,0,A.Wood,Enum.Material.WoodPlanks)end
 for _,z in ipairs({-140,180,330})do
  W.Part(beach,'LifeguardPlatform',{10,1,10},620,5,z,A.Cream);W.Part(beach,'LifeguardRoof',{13,.5,13},620,12,z,A.Cream)
  for _,dx in ipairs({-4,4})do W.Part(beach,'LifeguardLeg',{.5,12,.5},620+dx,6,z,A.Wood)end
  for i=1,10 do W.Part(beach,'LifeguardStep',{5,i*.5,1.3},615-i*.9,i*.25,z,A.Cream)end
  for _,dz in ipairs({-25,25})do W.Part(beach,'UmbrellaPole',{.3,7,.3},612,3.5,z+dz,A.Wood);local p=W.Part(beach,'Umbrella',{12,.8,12},612,7,z+dz,Color3.fromRGB(204,153,112),Enum.Material.Fabric,false);p.Shape=Enum.PartType.Ball;W.Part(beach,'BeachSeat',{3,.5,7},612,.8,z+dz+4,A.Cream,nil,true,'Seat')end
 end
 -- Preserve the fishing interaction on a proper ocean pier.
 local fish=w.SideDestinations.FishingDeck;local transform=CFrame.new(975,3,75)
 for _,p in ipairs(fish:GetDescendants())do if p:IsA('BasePart')then p.CFrame=transform*p.CFrame end end
 W.Move(w.SideDestinations.LakesideTackle,Vector3.new(580,0,130),-math.pi/2)
 local ferry=require(script.Parent.LakeFerry);local offset=Vector3.new(970,0,230)
 w.LakeFerry:PivotTo(w.LakeFerry:GetPivot()+offset);ferry.Home+=offset;ferry.Offset=offset
 for _,v in ipairs(w.SunsetCove:GetChildren())do
  if v.Name=='BallRack'then v.Position=Vector3.new(610,1,110)
  elseif v.Name=='BallSign'then v.Position=Vector3.new(610,4,112)
  elseif v.Name=='SafetyBoard'then v.Position=Vector3.new(620,6,105)
  else v.Parent=archive end
 end
 W.Building(beach,'BeachChangingRooms',600,400,30,24,1,A.Cream,-math.pi/2)

 W.Part(beach,'MarinaDock',{140,1,9},665,1,240,A.Wood,Enum.Material.WoodPlanks)
 for _,z in ipairs({210,265})do W.Part(beach,'MarinaFinger',{7,1,50},733,1,z,A.Wood,Enum.Material.WoodPlanks)end
 require(script.Parent.CoastalAttractions).Build(W,context)
 require(script.Parent.CoastalFinish).Build(W,context)
 require(script.Parent.CoastalLandscape).Build(W)
 -- Public transit makes the large districts accessible before buying a car.
 context.Interactions:Register('CoastTravelBoard',function(player)context.Open(player,'CoastalTransit');return true end)
 local hubs={{'Suburbs',-260,-40},{'Downtown',340,65},{'Beach',552,30},{'School',-520,280},{'Commercial',-260,95},{'Airport',112,285},{'Farmland',-525,-565},{'Mountains',45,-565}}
 W.Stops={};W.Destinations={}
 for _,hub in ipairs(hubs)do
  local board=W.Sign(root,'TransitStop','TOWN SHUTTLE',hub[2],hub[3],0)
  board.Size=Vector3.new(12,2,.3);A.Prompt(board,'CoastTravelBoard','Town shuttle','Choose destination')
  table.insert(W.Stops,board);W.Destinations[hub[1]]=Vector3.new(hub[2],4,hub[3]+10)
 end
 w:SetAttribute('CoastalWorldVersion',1);root:SetAttribute('RoadEdges',#W.Edges)
 return root
end
function W.Travel(player,id)
 local destination=W.Destinations[id];if not destination then return false,'Choose a town district.'end
 if player:GetAttribute('Carrying')or player:GetAttribute('DeliveryAddress')or player:GetAttribute('CityWorkKind')then return false,'Finish your current delivery or shift before taking the shuttle.'end
 local c=player.Character;local h=c and c:FindFirstChildOfClass('Humanoid');local root=c and c:FindFirstChild('HumanoidRootPart')
 if not root or not h or h.Health<=0 or h.Sit then return false,'Stand beside a shuttle stop.'end
 local close=false;for _,stop in ipairs(W.Stops)do if(root.Position-stop.Position).Magnitude<18 then close=true;break end end
 if not close then return false,'Go to a TOWN SHUTTLE stop first.'end
 c:PivotTo(CFrame.new(destination));return true,'Welcome to '..id
end
return W
