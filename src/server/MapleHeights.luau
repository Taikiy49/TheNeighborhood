-- City pass preserves authoritative house/item paths and all saved coordinates.
local A=require(script.Parent.CityArchitecture)
local M={}
local function folder(p,name)local f=Instance.new('Folder');f.Name=name;f.Parent=p;return f end
function M.Build(w)
 local prior=w:FindFirstChild('MapleHeights');if prior then prior:Destroy()end
 local root=folder(w,'MapleHeights');root:SetAttribute('Version',2)
 local function part(parent,name,s,x,y,z,c,mat,solid)return A.Part(parent,name,s,Vector3.new(x,y,z),c,mat,solid)end
 local paths=folder(root,'Paths');local paving=Color3.fromRGB(190,183,165)
 local function path(name,x,z,sx,sz)return part(paths,name,{sx,.18,sz},x,.22,z,paving,Enum.Material.Pavement)end
 -- The inherited mountain enclosure is replaced, not layered beneath the skyline.
 local valley=w:FindFirstChild('ValleyBackdrop');if valley then for _,v in ipairs(valley:GetChildren())do if v.Name~='ValleyFloor'then v:Destroy()end end end
 -- Remove only obsolete park dressings where the new active frontages stand.
 for _,v in ipairs(w.ArtDirection.GardenDistrict.MapleGreen:GetChildren())do
  local pos=v:IsA('Model')and v:GetPivot().Position or v:IsA('BasePart')and v.Position
  if pos and math.abs(pos.Z)>82 then v:Destroy()end
 end
 for _,v in ipairs(w.TownPolish:GetChildren())do
  if v.Name:match('^Clock')or v.Name:match('^Pergola')or v.Name:match('^Picnic')or v.Name=='TableLeg'or v.Name=='NoticePost'then v:Destroy()end
 end
 local park=folder(root,'NeighborhoodPark')
 -- A 76 x 140 green bounded by frontages; entrances align with existing crossings.
 for _,z in ipairs({-80,80})do path('ParkEdge',0,z,80,6)end
 for _,x in ipairs({-35,35})do
  for _,z in ipairs({-51,-19,19,51})do
   part(park,'LowGardenWall',{.6,1.5,23},x,.9,z,A.Cream,Enum.Material.Brick)
   local shrub=part(park,'Hedge',{2,2,22},x,2,z,Color3.fromRGB(87,121,76));shrub.CanCollide=false
  end
 end
 -- Move the existing functional community board into the park, never duplicate it.
 local board=w.Map.CommunityBoard;board.Position=Vector3.new(18,5,-73);board.Size=Vector3.new(12,4,.3)
 local label=board:FindFirstChildWhichIsA('TextLabel',true);if label then label.Text='MAPLE HEIGHTS\nDeliver parcels • Earn cash\nActivities • Daily goals'end
 local sign=w.Map.MapleGreenSign;sign.Position=Vector3.new(-18,5,-73);sign.Size=Vector3.new(12,4,.3)
 local text=sign:FindFirstChildWhichIsA('TextLabel',true);if text then text.Text='NEIGHBORHOOD PARK\nYour home is across the street\nMarket shops: south • Beach: north'end
 for _,x in ipairs({-18,18})do for _,dx in ipairs({-4,4})do part(park,'BoardPost',{.35,4,.35},x+dx,2,-72.8,A.Ink)end end
 path('NoticeApproach',0,-78,40,4)
 for _,v in ipairs(w.Map:GetChildren())do if v.Name=='ParkBench'and v:IsA('Model')and v:GetPivot().Position.Z<0 then local pos=v:GetPivot().Position;v:PivotTo(v:GetPivot()+Vector3.new(0,0,-64-pos.Z))end end
 local civic=folder(root,'MarketAvenue')
 local function job(p,n,x,y,z,kind,step,label)
  local t=p(n,{1.5,.6,1.5},x,y,z,A.Cream);t:SetAttribute('CityJob',kind);t:SetAttribute('Step',step)
  A.Prompt(t,'CityWork',label,step==1 and 'Start shift' or 'Complete step '..step);return t
 end
 local deli,d=A.Building(civic,'MaplePizza',Vector3.new(-21,0,111),30,28,1,A.Brick,'MAPLE PIZZA')
 d('Counter',{19,3,3},0,1.9,7,A.Ink);d('CounterTop',{20,.3,3.3},0,3.6,7,A.Wood)
 d('Oven',{6,6,3},-9,3.4,11,A.Ink);d('OvenMouth',{4,2,.2},-9,3.6,9.4,Color3.fromRGB(46,39,32))
 A.Table(d,-6,0,-5);A.Table(d,7,0,-5)
 job(d,'OrderTicket',-7,4.1,5,'Pizza',1,'Pizza: read order');job(d,'PrepBoard',0,4.1,5,'Pizza',2,'Pizza: prepare');job(d,'ServeBox',7,4.1,5,'Pizza',3,'Pizza: box order')
 local pizza=d('Pizza',{.25,2.4,2.4},0,3.9,8,Color3.fromRGB(231,183,83));pizza.Shape=Enum.PartType.Cylinder;pizza.CFrame*=CFrame.Angles(0,0,math.pi/2)
 for i=1,6 do local angle=i*math.pi/3;local topping=d('Pepperoni',{.1,.5,.5},math.cos(angle)*.7,4.08,8+math.sin(angle)*.7,A.Brick);topping.Shape=Enum.PartType.Cylinder;topping.CFrame*=CFrame.Angles(0,0,math.pi/2)end
 d('BoxPrepTable',{4,3.8,4},9,1.9,10,A.Wood)
 for i=1,4 do d('PizzaBox',{3,.4,3},9,3.6+i*.4,10,A.Cream)end
 local menu=d('Menu',{18,3,.2},0,8,13.5,A.Ink,nil,false);A.Sign(menu,'PIZZA SHIFT • $45\nOrder → Prep → Box\nWait for each preparation cue')
 local laundry,l=A.Building(civic,'MapleLaundry',Vector3.new(21,0,111),30,28,1,Color3.fromRGB(158,176,166),'MAPLE LAUNDRY')
 for _,x in ipairs({-10,-5,0})do l('Washer',{4,5,4},x,2.9,10,A.Cream);local door=l('WasherDoor',{2.8,2.8,.2},x,2.7,7.9,A.Ink);door.Shape=Enum.PartType.Ball end
 l('FoldingTable',{10,3,4},7,1.9,2,A.Wood);l('FoldedLinen',{3,.6,2},7,3.8,2,A.Cream)
 l('LaundryBasket',{3,2.5,3},-10,1.65,-4,A.Wood)
 job(l,'SortBasket',-10,2.8,-4,'Laundry',1,'Laundry: sort linens');job(l,'WashControl',-5,4.2,7.6,'Laundry',2,'Laundry: wash');job(l,'FoldBasket',3,3.7,1,'Laundry',3,'Laundry: fold')
 A.Table(l,-6,0,-9)
 local rules=l('ShiftRules',{19,3,.2},0,9,13.5,A.Ink,nil,false);A.Sign(rules,'LAUNDRY SHIFT • $45\nSort → Wash → Fold\nWait for the next station cue')
 path('MarketPlaza',0,88,78,10);path('MarketLane',0,141,78,6)
 for _,x in ipairs({-39,39})do path('ShopSidewalk',x,116,6,50)end
 -- Continuous commercial paving fills gaps between entrances and the street.
 part(paths,'MarketBlockPaving',{84,.16,61},0,.17,113.5,Color3.fromRGB(172,169,158),Enum.Material.Pavement)
 -- Northern frontages frame the park; all three apartment floors are usable.
 local uptown=folder(root,'Uptown')
 local apartment,a=A.Building(uptown,'ParkApartments',Vector3.new(-21,0,-120),30,28,3,Color3.fromRGB(181,155,129),'PARK APARTMENTS • SOCIAL LOUNGE')
 for _,y in ipairs({0,12,24})do A.Lounge(a,y);A.Table(a,-5,y,-7)end
 A.Lifts(a,{0,12,24},'Park Apartments')
 local hotel,h=A.Building(uptown,'MapleHotel',Vector3.new(21,0,-120),30,28,3,Color3.fromRGB(205,194,170),'MAPLE HOTEL')
 h('Reception',{16,3,3},-3,1.9,4,A.Ink);A.Table(h,-6,0,-7)
 for _,y in ipairs({12,24})do
  h('BedFrame',{8,1,10},-6,y+1.2,4,A.Wood);h('Mattress',{7.5,.8,9},-6,y+2.1,4,A.Cream);h('Pillow',{6,.5,2},-6,y+2.7,7,A.Cream)
  h('BedPlinth',{7,.6,9},-6,y+.7,4,A.Wood);h('ServiceTable',{3,2.5,2},-6,y+1.65,-2,A.Wood)
  h('Wardrobe',{4,7,3},-10,y+3.9,-8,A.Wood);A.Table(h,4,y,-6)
 end
 A.Lifts(h,{0,12,24},'Maple Hotel')
 job(h,'ReceptionTicket',-5,3.9,2,'Hotel',1,'Hotel: housekeeping shift');job(h,'RoomOne',-6,15,-2,'Hotel',2,'Hotel: tidy room 201');job(h,'RoomTwo',-6,27,-2,'Hotel',3,'Hotel: tidy room 301')
 -- Face the park. Vector attributes must follow the same transform as geometry.
 for _,building in ipairs({apartment,hotel})do
  local center=building==apartment and Vector3.new(-21,0,-120)or Vector3.new(21,0,-120)
  local rotation=CFrame.new(center)*CFrame.Angles(0,math.pi,0)*CFrame.new(-center)
  building:PivotTo(rotation*building:GetPivot());building:SetAttribute('Entry',rotation*building:GetAttribute('Entry'))
  for _,v in ipairs(building:GetDescendants())do local destination=v:GetAttribute('Destination');if destination then v:SetAttribute('Destination',rotation*destination)end end
 end
 path('UptownFront',0,-141,78,6);path('UptownCourt',0,-94,78,10)
 for _,x in ipairs({-39,39})do path('UptownWalk',x,-119,6,50)end
 part(paths,'UptownBlockPaving',{84,.16,55},0,.17,-116.5,Color3.fromRGB(172,169,158),Enum.Material.Pavement)
 -- A small older block links the cafe to the lake promenade without swallowing the waterfront.
 local old=folder(root,'OldTown')
 for i=1,2 do
  local cx=-289+(i-1)*36
  local brown,b=A.Building(old,'Brownstone'..i,Vector3.new(cx,0,-80),28,28,2,i==1 and A.Brick or Color3.fromRGB(139,108,83),'OLD TOWN • READING ROOM')
  A.Lounge(b,0);A.Table(b,-5,0,-7);A.Lounge(b,12);A.Table(b,-5,12,-7)
  A.Lifts(b,{0,12},'Old Town reading room')
  b('Stoop',{10,.3,6},0,.25,-17,A.Cream)
  -- Climbable fire escape outside, with a roof opening and real rooftop walkway.
  local truss=b('FireEscape',{2,30,2},16,15,0,A.Ink,Enum.Material.Metal,true,'TrussPart')
  b('EscapeLanding',{4,.4,6},12,24.7,0,A.Ink,Enum.Material.Metal)
  for _,v in ipairs(brown:GetChildren())do if v.Name=='RoofRail'and(math.abs(v.Position.X-(cx+14))<.1 or i==2 and math.abs(v.Position.X-(cx-14))<.1)then v:Destroy()end end
  local t=b('RoofSurvey',{1.5,1,1.5},7,26,2,A.Cream);t:SetAttribute('CityJob','Rooftops');t:SetAttribute('Step',i+1);A.Prompt(t,'CityWork','Old Town rooftop route','Check rooftop '..i)
  brown:SetAttribute('FireEscape',truss.Position)
 end
 part(paths,'OldTownBlockPaving',{80,.16,56},-270,.17,-83,Color3.fromRGB(172,169,158),Enum.Material.Pavement)
 path('OldTownCourt',-270,-105,80,12);path('OldTownLink',-225,-105,10,12)
 part(old,'RooftopBridge',{10,.4,5},-271,24.8,-72,A.Ink,Enum.Material.Metal)
 local route=part(old,'RouteStart',{2,3,1},-232,2,-96,A.Ink);route:SetAttribute('CityJob','Rooftops');route:SetAttribute('Step',1);A.Prompt(route,'CityWork','Old Town roof route','Start survey • $65')
 -- Warehouse is a real delivery depot using the existing parcel system.
 local water=folder(root,'Waterfront')
 local warehouse,s=A.Building(water,'WillowWarehouse',Vector3.new(-270,0,145),38,26,1,Color3.fromRGB(153,127,100),'WILLOW PARCEL DEPOT')
 for _,x in ipairs({-12,12})do s('Rack',{7,7,3},x,3.9,9,A.Ink);for j=1,3 do s('Parcel',{3,1.7,2},x,j*2,7,A.Wood,Enum.Material.Cardboard)end end
 s('DispatchDesk',{13,3,3},0,1.9,5,A.Wood)
 local depot=s('Dispatch',{2,.6,2},0,3.9,3,A.Cream);A.Prompt(depot,'WarehouseDelivery','Willow Parcel Depot','Collect a neighborhood delivery')
 path('WarehouseApron',-270,122,46,14);path('DepotLink',-233,122,29,6)
 -- Narrow waterfront footbridge: swimming remains unobstructed underneath.
 local bridge=folder(root,'CoveBridge')
 part(bridge,'Deck',{220,.6,7},0,5,-274,A.Wood,Enum.Material.WoodPlanks)
 for _,z in ipairs({-277.5,-270.5})do part(bridge,'Rail',{196,2,.3},0,6.3,z,A.Ink,Enum.Material.Metal)end
 for _,x in ipairs({-108,108})do
  for n=1,10 do part(bridge,'Step',{7,n*.5,4},x,n*.25,-234-n*4,A.Cream)end
  path('BridgeShore',x,-224,7,22)
 end
 for _,x in ipairs({-76,-38,0,38,76})do part(bridge,'Pier',{1.2,14,1.2},x,-2,-274,A.Wood,Enum.Material.Wood)end
 -- A perimeter of compact city silhouettes, visibly separate from playable destinations.
 local skyline=folder(root,'Skyline');skyline:SetAttribute('Decorative',true)
 local function silhouette(x,z,width,height,color)
  local m=Instance.new('Model');m.Name='DistantCityBuilding';m.Parent=skyline;m:SetAttribute('Enterable',false)
  part(m,'Facade',{width,height,28},x,height/2,z,color,Enum.Material.Brick)
  part(m,'Cornice',{width+2,1,30},x,height,z,A.Cream)
  for y=8,height-5,10 do for dx=-width/2+5,width/2-4,8 do
   part(m,'Window',{3.8,5,.2},x+dx,y,z-14.15,Color3.fromRGB(134,169,173),Enum.Material.Glass,false)
   part(m,'Window',{3.8,5,.2},x+dx,y,z+14.15,Color3.fromRGB(134,169,173),Enum.Material.Glass,false)
  end end
 end
 for i=-4,4 do silhouette(i*70,334,44,38+(i%3)*17,i%2==0 and A.Brick or Color3.fromRGB(174,163,143))end
 for _,side in ipairs({-1,1})do for i=-3,3 do silhouette(side*382,i*75,42,42+(i%3)*20,Color3.fromRGB(135+i*4,147,139))end end
 for _,x in ipairs({-250,-170,170,250})do silhouette(x,-333,46,45+math.abs(x)%37,Color3.fromRGB(164,153,134))end
 -- Street continuations terminate at a deliberate bus turning court, not a grass stub.
 local streets=folder(root,'StreetEdges')
 for _,side in ipairs({-1,1})do
  part(streets,'CityVerge',{54,4,590},side*363,-2,0,Color3.fromRGB(157,159,153),Enum.Material.Concrete)
  part(streets,'ServiceStreet',{18,.18,569},side*339,.08,9.5,Color3.fromRGB(68,76,76),Enum.Material.Asphalt)
  for _,z in ipairs({-266})do
   part(streets,'TurningCourt',{32,.18,24},side*339,.08,z,Color3.fromRGB(68,76,76),Enum.Material.Asphalt)
   part(streets,'EndKerb',{32,.7,.5},side*339,.3,z+side*0+(z>0 and 12 or -12),A.Cream)
  end
  path('OuterFootway',side*324,0,6,550)
  path('OuterNorthLink',side*297,-194,48,6);path('OuterSouthLink',side*314,194,20,6)
  local frontZ=side<0 and 168 or 143
  path('ShopOuterApproach',side*301,(194+frontZ)/2,6,194-frontZ+6);path('ShopFrontApproach',side*286,frontZ,30,6)
  local shelter=part(streets,'BusShelterRoof',{5,.4,13},side*326,8,-202,A.Ink)
  for _,z in ipairs({-207,-197})do part(streets,'ShelterPost',{.4,8,.4},side*327,4,z,A.Ink)end
  part(streets,'BusStopSeat',{2,.4,8},side*329,1.6,-202,A.Wood)
  for _,z in ipairs({-205,-199})do part(streets,'BusSeatLeg',{1.5,1.4,.4},side*329,.7,z,A.Ink)end
  local stop=part(streets,'TransitMap',{.3,4,5},side*328,5,-202,A.Ink,nil,false);stop.CFrame*=CFrame.Angles(0,side*math.pi/2,0);A.Sign(stop,'MAPLE HEIGHTS\nBus turning court\nCity backdrop')
 end
 part(streets,'SouthCityGround',{730,4,55},0,-2,292,Color3.fromRGB(157,159,153),Enum.Material.Concrete)
 part(streets,'ConnectedBoulevard',{696,.18,18},0,.08,294,Color3.fromRGB(68,76,76),Enum.Material.Asphalt)
 part(streets,'MarketAccessLane',{12,.18,107},0,.08,240.5,Color3.fromRGB(68,76,76),Enum.Material.Asphalt)
 for _,x in ipairs({-8,8})do path('MarketAlleyFootway',x,243,3,96)end
 path('SouthCitySidewalk',0,308,696,6)
 path('GreenhouseApproach',95,214,6,40)
 -- Clear authored landscaping only inside new footprint bounds; never remove house objects.
 local footprints={{0,-120,78,34},{0,111,78,34},{-271,-80,78,34},{-270,145,44,32},{95,230,24,56},{301,170,10,62}}
 for _,f in ipairs({w.GardenDetails,w.ArtDirection.GardenDistrict.StreetTrees,w.ArtDirection.GardenDistrict.BoundaryGroves,w.ArtDirection.GardenDistrict.Orchard})do
  for _,v in ipairs(f:GetChildren())do local pos=v:IsA('Model')and v:GetPivot().Position or v:IsA('BasePart')and v.Position
   if pos then for _,box in ipairs(footprints)do if math.abs(pos.X-box[1])<box[3]/2 and math.abs(pos.Z-box[2])<box[4]/2 then v:Destroy();break end end end
  end
 end
 require(script.Parent.CityDensity).Skyline(root)
 require(script.Parent.TownStreets).Build(root)
 w:SetAttribute('CityBorough','Maple Heights');return root
end
return M
