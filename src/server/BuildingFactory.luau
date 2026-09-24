local Space=require(game.ReplicatedStorage.Neighborhood.Shared.WorldSpace)
local D=require(game.ReplicatedStorage.Neighborhood.Shared.BuildingDefinitions)
local F={}
local cream=Color3.fromRGB(236,233,215);local green=Color3.fromRGB(80,119,100);local wood=Color3.fromRGB(177,145,107)
local roof=Color3.fromRGB(69,86,88)
local function part(parent,name,size,cf,color,material)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Anchored=true;p.CanTouch=false;p.Color=color or cream;p.Material=material or Enum.Material.SmoothPlastic;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent;return p
end
local function prompt(p,action,text)
 p:SetAttribute("Action",action);local q=Instance.new("ProximityPrompt");q.Style=Enum.ProximityPromptStyle.Custom;q.ActionText=text;q.ObjectText="Your home";q.MaxActivationDistance=10;q.RequiresLineOfSight=false;q:SetAttribute("Action",action);q.Parent=p
end
function F.Furniture(parent,cf,kind)
 local m=Instance.new("Model");m.Name=kind;m.Parent=parent
 local function p(name,size,x,y,z,color,mat)return part(m,name,size,cf*CFrame.new(x,y,z),color,mat)end
 if kind=="Planter"then
  p("Terracotta",Vector3.new(2,1.5,2),0,.75,0,Color3.fromRGB(168,110,84),Enum.Material.SmoothPlastic)
  for i=1,5 do local leaf=p("Fern",Vector3.new(1.3,1.7,1.3),math.sin(i*2)*.65,2.1,math.cos(i*2)*.65,green,Enum.Material.Grass);leaf.Shape=Enum.PartType.Ball;leaf.CanCollide=false end
 elseif kind=="Bookcase"then
  p("Back",Vector3.new(3.2,4,.25),0,2,.6,wood)
  for _,x in ipairs({-1.5,1.5})do p("Side",Vector3.new(.2,4,1.4),x,2,0,cream)end
  for y=0,4,2 do p("Shelf",Vector3.new(3.2,.18,1.4),0,y+.1,0,cream)end
  for i=1,6 do p("Book",Vector3.new(.3,1.3,.8),-1.2+(i-1)*.45,2.85,0,i%2==0 and green or Color3.fromRGB(168,115,87))end
 else
  local height=kind=="Desk"and 2.6 or 1.5
  p("Top",Vector3.new(3.3,.3,1.8),0,height,0,wood)
  for _,x in ipairs({-1.35,1.35})do for _,z in ipairs({-.6,.6})do p("Leg",Vector3.new(.25,height,.25),x,height/2,z,cream)end end
  if kind=="Bench"then p("Cushion",Vector3.new(3,.35,1.6),0,1.8,0,green,Enum.Material.Fabric);p("Backrest",Vector3.new(3.3,1.3,.2),0,2.5,.8,cream)
  else p("Notebook",Vector3.new(.9,.12,1),.7,2.83,0,green)end
 end
 return m
end
function F.Create(house,b)
 local model=Instance.new("Model");model.Name="HomeExpansion";model.ModelStreamingMode=Enum.ModelStreamingMode.Atomic
 local basis=house.Foundation.CFrame
 local function p(name,size,x,y,z,color,mat)return part(model,name,size,basis*CFrame.new(x,y,z),color,mat)end
 local function shell(id,x,z,w,d,h,glazed)
  local r=Instance.new("Folder");r.Name=id;r.Parent=model
  local function q(name,size,xx,yy,zz,c,mat)local v=p(name,size,xx,yy,zz,c,mat);v.Parent=r;return v end
  q("Floor",Vector3.new(w,.4,d),x,.5,z,wood)
  for _,side in ipairs({-1,1})do
   local wall=q("Wall",Vector3.new(.4,h,d),x+side*w/2,.7+h/2,z,glazed and Color3.fromRGB(185,219,211)or green,glazed and Enum.Material.Glass or Enum.Material.SmoothPlastic)
   if glazed then wall.Transparency=.65 end
   for _,endZ in ipairs({-1,1})do q("Corner",Vector3.new(.65,h,.65),x+side*w/2,.7+h/2,z+endZ*d/2,cream)end
   q("Sill",Vector3.new(.6,.6,d),x+side*w/2,1.1,z,cream)
   q("Cornice",Vector3.new(.7,.6,d),x+side*w/2,h+.5,z,cream)
  end
  if glazed then
   for _,side in ipairs({-1,1})do
    local back=q("Back",Vector3.new((w-7)/2,h,.4),x+side*(w+7)/4,.7+h/2,z+d/2,Color3.fromRGB(185,219,211),Enum.Material.Glass);back.Transparency=.65
    for zz=z-d/2+4,z+d/2-1,4 do q("WindowMullion",Vector3.new(.5,h,.3),x+side*w/2,.7+h/2,zz,cream)end
    q("DoorJamb",Vector3.new(.45,8.5,.65),x+side*3.65,4.95,z+d/2,cream)
   end
   local transom=q("Transom",Vector3.new(7,h-8,.4),x,8.7+(h-8)/2,z+d/2,Color3.fromRGB(185,219,211),Enum.Material.Glass);transom.Transparency=.65
   q("DoorHeader",Vector3.new(7.7,.5,.65),x,8.95,z+d/2,cream)
   local door=q("GardenDoor",Vector3.new(7,8,.4),x,4.7,z+d/2,Color3.fromRGB(166,195,177),Enum.Material.Glass);door.Transparency=.35
   door:SetAttribute("HouseId",house.Name);prompt(door,"Door","Open garden door")
   local handle=q("GardenHandle",Vector3.new(.18,.65,.18),x-2.7,4.7,z+d/2+.3,Color3.fromRGB(183,148,83),Enum.Material.Metal);handle.CanCollide=false
   for _,yy in ipairs(h>15 and {5.2,11.5,16.8}or {5.2})do
    if yy<8.7 then for _,side in ipairs({-1,1})do q("BackWindowRail",Vector3.new((w-7)/2,.3,.6),x+side*(w+7)/4,yy,z+d/2,cream)end else q("BackWindowRail",Vector3.new(w,.3,.6),x,yy,z+d/2,cream)end
    for _,side in ipairs({-1,1})do q("SideWindowRail",Vector3.new(.6,.3,d),x+side*w/2,yy,z,cream)end
   end
  else q("Back",Vector3.new(w,h,.4),x,.7+h/2,z+d/2,green)end
  -- A central open arch preserves a six-stud walking route.
  for _,side in ipairs({-1,1})do q("Front",Vector3.new((w-7)/2,h,.4),x+side*(w+7)/4,.7+h/2,z-d/2,green)end
  q("Lintel",Vector3.new(7,math.max(.5,h-8),.5),x,8.7+math.max(.5,h-8)/2,z-d/2,cream)
  local rise=w*.18;local half=w/2+.7;local length=math.sqrt(half*half+rise*rise)
  for _,side in ipairs({-1,1})do
   local v=q("PitchedRoof",Vector3.new(length,.45,d+1.6),x+side*half/2,h+.9+rise/2,z,roof,Enum.Material.SmoothPlastic)
   v.CFrame*=CFrame.Angles(0,0,-side*math.atan(rise/half))
  end
  q("Ridge",Vector3.new(.5,.5,d+1.7),x,h+.9+rise,z,roof,Enum.Material.SmoothPlastic)
  local light=q("Pendant",Vector3.new(1,.3,1),x,h-.2,z,cream,Enum.Material.Neon);light.CanCollide=false
  local stem=q("PendantStem",Vector3.new(.12,rise+.65,.12),x,h+.275+rise/2,z,roof);stem.CanCollide=false;stem.CanQuery=false
  local glow=Instance.new("PointLight");glow.Color=Color3.fromRGB(255,231,191);glow.Brightness=.7;glow.Range=18;glow.Parent=light
  return r
 end
 if b.Unlocked.GardenRoom then
  shell("GardenRoom",0,22,24,16,b.Unlocked.Loft and 21 or 10.5,true)
  p("HallThreshold",Vector3.new(7,.4,2),0,.5,13,wood)
  for _,side in ipairs({-1,1})do p("CottageBack",Vector3.new(11.5,14.3,.7),side*9.25,7.59,12.6,Color3.fromRGB(229,233,227),Enum.Material.SmoothPlastic)end
  p("CottageHeader",Vector3.new(7,6.3,.7),0,11.65,12.6,Color3.fromRGB(229,233,227),Enum.Material.SmoothPlastic)
 end
 if b.Unlocked.Loft then
  p("LoftFloor",Vector3.new(12,.4,16),-6,11.45,22,wood)
  -- Two ten-step flights, 0.5475-stud rises and a full-width landing.
  for i=1,10 do local top=.7+i*.5475;p("StairUp"..i,Vector3.new(4,top-.7,1.15),8,(top+.7)/2,15+(i-1)*1.1,wood)end
  p("StairLanding",Vector3.new(10,.4,3),6,5.975,27,wood)
  for i=1,10 do local top=6.175+i*.5475;p("StairReturn"..i,Vector3.new(4,.3,1.15),3,top-.15,25.5-(i-1)*1.1,wood)end
  p("TopLanding",Vector3.new(6,.4,1.9),3,11.45,14.95,wood)
  for _,x in ipairs({1.2,4.8})do local a=Vector3.new(x,5.8,26.1);local z=Vector3.new(x,11.15,14.7);local beam=p("StairStringer",Vector3.new(.25,.45,(z-a).Magnitude),0,0,0,roof);beam.CFrame=basis*CFrame.lookAt((a+z)/2,z);beam.CanCollide=false;beam.CanQuery=false end
  -- Rail posts and continuous caps define the stairwell edge without closing the entry.
  for z=19,29,2 do p("LoftBaluster",Vector3.new(.2,2.6,.2),0,12.95,z,cream)end
  p("LoftRail",Vector3.new(.3,.25,11),0,14.25,24,cream)
  for z=16,25,3 do p("StairSpindle",Vector3.new(.2,2.3,.2),10,2+(z-15)*.5,z,cream)end
 end
 -- Every cottage has a BaseGarage; this upgrade unlocks its furnishing spaces.
 if b.Unlocked.Workshop then
  p("BackyardLawn",Vector3.new(53,.2,23),0,-.4,39,Color3.fromRGB(126,155,99),Enum.Material.Grass)
  shell("Workshop",0,40,24,18,10,false)
  p("WorkshopStep",Vector3.new(7,.4,3),0,.5,30.5,wood)
  local bench=p("CraftBench",Vector3.new(5,2.4,2),0,1.9,45.5,wood);prompt(bench,"CraftHome","Craft furniture");bench:SetAttribute("HouseId",house.Name)
  p("BenchTop",Vector3.new(5.3,.25,2.3),0,3.2,45.5,cream)
 end
 for _,zone in ipairs(D.Order)do if b.Unlocked[zone]then
  for i,xyz in ipairs(D.Rooms[zone].Cells)do
   local pad=p("Cell_"..zone.."_"..i,Vector3.new(3.5,.06,3.5),xyz[1],xyz[2]+.04,xyz[3],Color3.fromRGB(166,145,112),Enum.Material.Fabric)
   pad.CanCollide=false;pad:SetAttribute("HouseId",house.Name);pad:SetAttribute("Zone",zone);pad:SetAttribute("Cell",i);prompt(pad,"FurnishHome","Arrange furniture")
  end
 end end
 local furnishings=Instance.new("Folder");furnishings.Name="Furnishings";furnishings.Parent=model
 Space.Stretch(model,basis)
 return model
end
function F.Arrange(model,house,b)
 local folder=model.Furnishings;folder:ClearAllChildren()
 for key,v in pairs(b.Placed)do local xyz=D.Rooms[v.Zone].Cells[v.Cell];local m=F.Furniture(folder,house.Foundation.CFrame*Space.Frame(table.unpack(xyz))*CFrame.Angles(0,math.rad(v.Rotation*90),0),v.Kind);m.Name=key end
end
function F.AddDisplays(house,b)
 for index,zone in ipairs(D.Order)do if b.Unlocked[zone]then for i,xyz in ipairs(D.Rooms[zone].Displays)do
  local n=6+(index-1)*2+i
  if not house.DisplaySlots:FindFirstChild("Slot"..n)then
   local pad=part(house.DisplaySlots,"Slot"..n,Vector3.new(3,.1,3),house.Foundation.CFrame*Space.Frame(table.unpack(xyz)),cream,Enum.Material.Concrete)
   pad.CanCollide=false;pad:SetAttribute("HouseId",house.Name);pad:SetAttribute("Slot",n);pad:SetAttribute("Expansion",true);prompt(pad,"Place","Display a possession")
  end
 end end end
end
return F
