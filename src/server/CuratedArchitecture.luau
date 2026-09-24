-- Geometry-only Creator Store assets; provenance in docs/CURATED-ART.md.
local M={}
local library=game.ServerStorage:WaitForChild('CuratedArt')
function M.Place(name,parent,target,size)
 local m=library[name]:Clone();m.Name='Art_'..name
 local box,original=m:GetBoundingBox();local scale=size and size/original or Vector3.one
 for _,p in ipairs(m:GetDescendants())do if p:IsA('BasePart')then
  local relative=box:ToObjectSpace(p.CFrame)
  p.Size*=scale;p.CFrame=target*CFrame.new(relative.Position*scale)*relative.Rotation
  local mesh=p:FindFirstChildOfClass('SpecialMesh');if mesh then mesh.Scale*=scale;mesh.Offset*=scale end
  p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false
  if p:IsA('Seat')or p:IsA('VehicleSeat')then p.Disabled=true end
 end end
 -- Imported model pivots can retain their original off-map position after
 -- individual parts move. Reset the pivot before any ride animates the model.
 m.PrimaryPart=nil;m.WorldPivot=target;m.Parent=parent;return m
end
function M.Building(model)
 local floor=model:FindFirstChild('Floor');local roof=model:FindFirstChild('Roof')
 if not floor or not roof or not model:FindFirstChild('Fascia')or model:FindFirstChild('CuratedFacade')then return false end
 local f=Instance.new('Folder');f.Name='CuratedFacade';f.Parent=model
 local basis=floor.CFrame;local width,depth=floor.Size.X,floor.Size.Z
 local h=basis:PointToObjectSpace(roof.Position).Y
 local hash=0;for i=1,#model.Name do hash+=model.Name:byte(i)end
 local style=({'A','B','C','D'})[hash%4+1]
 -- The original collision shell, entrances and interior gameplay stay authoritative.
 for _,p in ipairs(model:GetChildren())do
  if p:IsA('BasePart')and(p.Name:find('Window')or p.Name=='StoreGlass'or p.Name=='StringCourse'or p.Name=='DoorCanopy')then p.Transparency=1 end
 end
 local function panel(kind,x,y,z,w,height,yaw)
  return M.Place(style..kind,f,basis*CFrame.new(x,y,z)*CFrame.Angles(0,yaw or math.pi/2,0),Vector3.new(1.3,height,w))
 end
 local sideSpan=(width-9)/2
 for _,sign in ipairs({-1,1})do panel('Store',sign*(4.5+sideSpan/2),4.3,-depth/2-.65,sideSpan,8.4)end
 for _,side in ipairs({-1,1})do
  local count=math.max(2,math.floor(depth/12));local step=depth/count
  for i=1,count do panel('Store',side*(width/2+.65),4.3,-depth/2+(i-.5)*step,step,8.4,side==1 and 0 or math.pi)end
 end
 panel('Store',0,4.3,depth/2+.65,width,8.4,-math.pi/2)
 if h>17 then
  -- Repeat at the actual twelve-stud floor spacing; never stretch one window
  -- over several storeys. The Upper module contains three window rows.
  local function upper(x,z,w,yaw)
   local y=12
   while y<h-1 do
    local span=math.min(h-y,36)
    if span<35 then span=math.min(h-y,12)end
    panel(span>=35 and 'Upper'or 'Store',x,y+span/2,z,w,span,yaw)
    y+=span
   end
  end
  local columns=math.max(2,math.floor(width/7.5));local step=width/columns
  for i=1,columns do upper(-width/2+(i-.5)*step,-depth/2-.65,step)end
  for _,side in ipairs({-1,1})do
   local columns=math.max(2,math.floor(depth/9));local step=depth/columns
   for i=1,columns do upper(side*(width/2+.65),-depth/2+(i-.5)*step,step,side==1 and 0 or math.pi)end
  end
  -- Back façades matter on a driveable town, too.
  for i=1,columns do upper(-width/2+(i-.5)*step,depth/2+.65,step,-math.pi/2)end
 end
 M.Place('Awning',f,basis*CFrame.new(0,8.3,-depth/2-1.5)*CFrame.Angles(0,math.pi/2,0),Vector3.new(3,1.8,10))
 for _,side in ipairs({-1,1})do M.Place('Planter',f,basis*CFrame.new(side*6,1.3,-depth/2-3),Vector3.new(2.3,2.8,2.3))end
 M.Place('RoofUnit',f,basis*CFrame.new(width*.22,h+2,depth*.15),Vector3.new(5,3.4,7))
 if h>=35 and depth>=24 then
  for y=12,h-10,12 do M.Place('FireEscape',f,basis*CFrame.new(width/2+1.8,y+5.5,0),Vector3.new(3,11.8,9))end
 end
 -- Natural materials and separated trim replace uniformly flat tinted brick.
 for _,p in ipairs(model:GetChildren())do if p:IsA('BasePart')then
  if p.Name=='SideWall'or p.Name=='RearWall'or p.Name=='UpperFront'then p.Material=hash%2==0 and Enum.Material.Plaster or Enum.Material.Brick end
 end end
 return true
end
function M.Init()
 local w=workspace.Neighborhood;local n=0;local list=w:GetDescendants()
 for _,m in ipairs(list)do if m:IsA('Model')and M.Building(m)then n+=1 end end
 for _,h in ipairs(w.Houses:GetChildren())do
  local f=Instance.new('Folder');f.Name='CottageArt';f.Parent=h;local b=h.Foundation.CFrame
  for _,side in ipairs({-1,1})do
   M.Place('Planter',f,b*CFrame.new(side*9,1.4,-22),Vector3.new(2.5,3,2.5))
   M.Place('Flowers',f,b*CFrame.new(side*12,5.3,-18.9),Vector3.new(1,2.6,4))
  end
  for _,z in ipairs({-7,7})do M.Place('AStore',f,b*CFrame.new(21.6,5.5,z),Vector3.new(.8,7.6,7))end
  local garage=h:FindFirstChild('BaseGarage')
  if garage then M.SmallShell(garage,true)end
 end
 for _,m in ipairs(w.SideDestinations:GetChildren())do if m:IsA('Model')and m:FindFirstChild('Floor')then
  local b=m.Floor.CFrame;local size=m.Floor.Size;local f=Instance.new('Folder');f.Name='CuratedShopDetails';f.Parent=m
  for _,side in ipairs({-1,1})do M.Place('Planter',f,b*CFrame.new(side*(size.X/2-3),1.5,-size.Z/2-3),Vector3.new(2.8,3,2.8))end
  n+=1
  M.SmallShell(m,false)
 end end
 for _,m in ipairs(w.Shops:GetChildren())do if m:IsA('Model')and m:FindFirstChild('Floor')then M.SmallShell(m,false);n+=1 end end
 w:SetAttribute('CuratedBuildings',n)
end
function M.SmallShell(model,garage)
 local floor,roof=model:FindFirstChild('Floor'),model:FindFirstChild('Roof');if not floor or not roof then return end
 local f=Instance.new('Folder');f.Name='CuratedSideDetails';f.Parent=model
 local b=floor.CFrame;local width,depth=floor.Size.X,floor.Size.Z;local height=math.clamp(b:PointToObjectSpace(roof.Position).Y-1,6,12)
 for _,side in ipairs({-1,1})do
  local count=math.max(1,math.floor(depth/12));local step=depth/count
  for i=1,count do M.Place('CStore',f,b*CFrame.new(side*(width/2+.5),height/2,-depth/2+(i-.5)*step)*CFrame.Angles(0,side==1 and 0 or math.pi,0),Vector3.new(.8,height,step))end
 end
 if not garage then
  M.Place('Awning',f,b*CFrame.new(0,height-1,-depth/2-1.6)*CFrame.Angles(0,math.pi/2,0),Vector3.new(3,2,math.min(16,width-3)))
  M.Place('RoofUnit',f,b*CFrame.new(0,height+2,depth*.2),Vector3.new(4,3,5))
 end
end
function M.Ferris(parent,center)
 local m=library.FerrisWheel:Clone();m.Name='PacificWheel';m:ScaleTo(.8)
 m:PivotTo(CFrame.new(center)*m.Pin.CFrame:Inverse()*m:GetPivot());m.Parent=parent
 local cabins,seats={},{}
 for _,basket in ipairs(m.Baskets:GetChildren())do
  if basket:IsA('Model')then local seat=basket:FindFirstChildWhichIsA('Seat',true)
   if seat then table.insert(seats,seat);table.insert(cabins,{Model=basket,Start=basket:GetPivot()})end
  end
 end
 local wheel=m.Wheel;local wheelStart=wheel:GetPivot()
 local function update(t)
  local rotation=CFrame.new(center)*CFrame.Angles(0,0,-t*.1)*CFrame.new(-center)
  wheel:PivotTo(rotation*wheelStart)
  for _,c in ipairs(cabins)do c.Model:PivotTo(CFrame.new(rotation*c.Start.Position)*c.Start.Rotation)end
 end
 return seats,update
end
return M
