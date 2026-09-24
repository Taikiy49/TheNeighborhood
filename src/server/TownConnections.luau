-- Door-to-sidewalk routes are authored against the final imported venue positions.
local A=require(script.Parent.CityArchitecture)
local M={Routes={}}
local routes={
 GeneralStore={{-364.8,98}},PawnShop={{-258,98}},CornerCafe={{-465,98}},RepairWorkshop={{-147.4,98}},
 LakesideTackle={{560,123}},OrchardStand={{-470,-550},{-542,-550}},
 MaplePizza={{282,-90}},MapleLaundry={{282,-155}},ParkApartments={{318,-90}},MapleHotel={{318,-170}},
 SunburstHotel={{282,-260}},CivicHall={{160,62}},CoastBank={{225,62}},SunsetHospital={{395,62}},
 SunsetTheatre={{175,-398}},OceanGallery={{400,-398}},PalmResort={{175,-450},{240,-450},{240,-398}},
 CoastalClothing={{-460,242}},SunsetCinema={{-350,242}},CarShowroom={{-230,242}},FuelAndSnacks={{-135,231.6},{-135,242}},
 CoastSchool={{-460,282}},Brownstone1={{-510,358},{-542,358}},Brownstone2={{-474,358},{-542,358}},
 WillowWarehouse={{-190,282}},CoastalWorks={{-100,282}},CoastTerminal={{205,282}},
 ControlTower={{130,363},{98,363}},HangarOne={{230,378},{270,378},{270,282}},
 CoastBarn={{-370,-550},{-542,-550}},TrailCabin={{40,-618}},
 BeachChangingRooms={{636,400},{636,430},{560,430}},PacificLighthouse={{615,-558},{538,-558}},
 PalmDiner={{98,-185}},NoodleKitchen={{450,-362}},BoardwalkBakery={{447,195},{480,195},{480,242}},CornerConvenience={{199.6,98}},
 Cafe={{-390,-42}},Clubhouse={{-473,-42}},Greenhouse={{-60,-550},{62,-550}},
}
function M.Init()
 local w=workspace.Neighborhood
 local root=Instance.new('Folder');root.Name='PedestrianConnections';root.Parent=w.CoastalWorld;M.Root=root;M.Routes={}
 local color=Color3.fromRGB(201,192,174)
 local function point(x,z)return Vector3.new(x,.32,z)end
 local paved={}
 local function segment(parent,a,b,width)
  local delta=b-a;if delta.Magnitude<.1 then return end
  assert(math.abs(delta.X)<.15 or math.abs(delta.Z)<.15,'Routes must follow the street grid')
  local horizontal=math.abs(delta.X)>math.abs(delta.Z)
  local padX=horizontal and .75 or width/2;local padZ=horizontal and width/2 or .75
  local rect={math.min(a.X,b.X)-padX,math.min(a.Z,b.Z)-padZ,math.max(a.X,b.X)+padX,math.max(a.Z,b.Z)+padZ}
  local pieces={rect}
  -- Subtract previously paved rectangles: junctions meet without coplanar faces.
  for _,old in ipairs(paved)do
   local nextPieces={}
   for _,r in ipairs(pieces)do
    local x1,z1,x2,z2=math.max(r[1],old[1]),math.max(r[2],old[2]),math.min(r[3],old[3]),math.min(r[4],old[4])
    if x1>=x2 or z1>=z2 then table.insert(nextPieces,r)else
     for _,v in ipairs({{r[1],r[2],x1,r[4]},{x2,r[2],r[3],r[4]},{x1,r[2],x2,z1},{x1,z2,x2,r[4]}})do
      if v[3]-v[1]>.02 and v[4]-v[2]>.02 then table.insert(nextPieces,v)end
     end
    end
   end
   pieces=nextPieces
  end
  for _,r in ipairs(pieces)do
   local p=A.Part(parent,'Walkway',{r[3]-r[1],.16,r[4]-r[2]},point((r[1]+r[3])/2,(r[2]+r[4])/2),color,Enum.Material.Pavement)
   p:SetAttribute('PedestrianPath',true);table.insert(paved,r)
  end
 end
 local projectEntries={Cafe=point(-390,-14.3),Clubhouse=point(-473,-5),Greenhouse=point(-60,-499.7)}
 for _,m in ipairs(w:GetDescendants())do
  if m:IsA('Model')then
   local entry=m:GetAttribute('Entry')
   if m.Parent.Name=='NeighborhoodLife'and projectEntries[m.Name]then entry=projectEntries[m.Name]end
   if typeof(entry)=='Vector3'and routes[m.Name]then
    local f=Instance.new('Folder');f.Name=m.Name;f.Parent=root
    local nodes={point(entry.X,entry.Z)}
    local floor=m:FindFirstChild('Floor')
    if floor then
     local toward=floor.Position-entry
     local dir=math.abs(toward.X)>math.abs(toward.Z)and Vector3.new(math.sign(toward.X),0,0)or Vector3.new(0,0,math.sign(toward.Z))
     local query=RaycastParams.new();query.FilterType=Enum.RaycastFilterType.Include;query.FilterDescendantsInstances={m};query.RespectCanCollide=true
     for distance=1,22 do
      local at=entry+dir*distance
      local hit=workspace:Raycast(Vector3.new(at.X,7,at.Z),Vector3.new(0,-9,0),query)
      if hit and hit.Position.Y<2.5 and hit.Normal.Y>.8 then
       local threshold=point(at.X,at.Z);segment(f,nodes[1],threshold,4)
       table.insert(nodes,1,threshold);break
      end
     end
    end
    for _,v in ipairs(routes[m.Name])do table.insert(nodes,point(v[1],v[2]))end
    for i=1,#nodes-1 do segment(f,nodes[i],nodes[i+1],i==1 and #nodes>#routes[m.Name]+1 and 4 or 8)end
    m:SetAttribute('ConnectedEntrance',true)
    table.insert(M.Routes,{Model=m,Points=nodes,Folder=f})
   end
  end
 end
 -- Continuous school promenade, entrance spurs and a walking loop around the pitches.
 local f=Instance.new('Folder');f.Name='SportsPromenade';f.Parent=root
 local lines={
  {-542,358,-410,358},{-410,358,-410,378},{-410,378,-310,378},{-310,282,-310,560},{-542,282,-542,580},
  {-542,560,-310,560},{-505,400,-310,400},{-505,400,-505,560},
  {-375,400,-375,560},{-310,425,-303,425},{-310,330,-385,330},
  {-600,382,-542,382},{-600,382,-600,398},{-600,485,-600,580},{-600,580,-542,580},
 }
 for _,v in ipairs(lines)do segment(f,point(v[1],v[2]),point(v[3],v[4]),7)end
 -- Tower has its own raised lobby approach, joined to the boulevard frontage.
 local tower=w.MapleTower;local old=tower:FindFirstChild('StreetConnection');if old then old:Destroy()end
 local walk=tower:FindFirstChild('EntranceWalk')
 if walk then local p=walk.Position;local t=Instance.new('Folder');t.Name='MapleTower';t.Parent=root
  segment(t,point(p.X,p.Z),point(318,p.Z),8)
 end
 local routeStart=w.MapleHeights.OldTown:FindFirstChild('RouteStart')
 if routeStart then routeStart.Transparency=1;routeStart.CanCollide=false
  for _,gui in ipairs(routeStart:GetChildren())do if gui:IsA('SurfaceGui')then gui:Destroy()end end
 end
 for _,p in ipairs(w.CoastalWorld.Landscape:GetChildren())do
  if p:IsA('BasePart')and (p.Name=='Streetlamp'or p.Name=='Lantern')and math.abs(p.Position.X-325)<.1 and math.abs(p.Position.Z+265)<.1 then p.Position+=Vector3.new(0,0,11)end
 end
 -- Keep the single community activity board and useful transit/safety signs.
 -- These two duplicate advertisements have no interaction of their own.
 for _,p in ipairs({w.Map:FindFirstChild('MapleGreenSign'),w.SunsetCove:FindFirstChild('BallSign')})do
  if p then p.Transparency=1;p.CanCollide=false;p.CanQuery=false
   for _,v in ipairs(p:GetChildren())do if v:IsA('SurfaceGui')then v:Destroy()end end
  end
 end
 -- No placards advertising obvious sports equipment; prompts are on the equipment.
 for _,v in ipairs(w.Recreation:GetDescendants())do
  if v.Name=='ActivitySign'or v.Name=='SignSupport'or v.Name=='Welcome'or v.Name=='SignPost'then v:Destroy()
  elseif v.Name=='Interact'and v:IsA('BasePart')then v.Transparency=1;v.CanCollide=false end
 end
 root:SetAttribute('ConnectedBuildings',#M.Routes)
end
return M
