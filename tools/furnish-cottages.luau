-- Higgsfield-inspired furnishing pass. Run after clean-interiors; preserves all slots.
assert(not game:GetService("RunService"):IsRunning(),"Edit only")
local w=workspace.Neighborhood
local C={Oak=Color3.fromRGB(177,145,107),Cream=Color3.fromRGB(234,232,216),Sage=Color3.fromRGB(119,147,135),Ink=Color3.fromRGB(54,70,66),Leaf=Color3.fromRGB(88,117,78),Stone=Color3.fromRGB(157,160,145),Rose=Color3.fromRGB(184,139,131),Lavender=Color3.fromRGB(152,146,170)}
local count=0
local function part(parent,name,size,cf,color,solid,class)
 local p=Instance.new(class or "Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color;p.Material=Enum.Material.SmoothPlastic
 p.Anchored=true;p.CanCollide=solid==true;p.CanQuery=solid==true;p.CanTouch=false;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent;count+=1;return p
end
local function plant(parent,cf,scale)
 local pot=part(parent,"CeramicPlanter",Vector3.new(scale,scale,scale),cf*CFrame.new(0,scale/2,0),C.Cream,true)
 for i=1,3 do
  local leaf=part(parent,"LeafSpray",Vector3.new(scale*.8,scale*1.7,scale*.65),cf*CFrame.new((i-2)*scale*.38,scale*1.7,0)*CFrame.Angles(0,0,(i-2)*.45),C.Leaf,false);leaf.Shape=Enum.PartType.Ball
 end
 return pot
end
local function chair(parent,cf,name)
 part(parent,name,Vector3.new(2.4,.45,2.4),cf*CFrame.new(0,1.85,0),C.Cream,true,"Seat")
 part(parent,"ChairBack",Vector3.new(2.4,1.8,.28),cf*CFrame.new(0,2.8,1.1),name=="ReadingSeat"and C.Sage or C.Oak,true)
 for _,x in ipairs({-.85,.85})do for _,z in ipairs({-.85,.85})do part(parent,"ChairLeg",Vector3.new(.2,1.55,.2),cf*CFrame.new(x,.85,z),C.Oak,true)end end
 if name=="ReadingSeat"then for _,x in ipairs({-1.2,1.2})do part(parent,"PaddedArm",Vector3.new(.35,.8,2.5),cf*CFrame.new(x,2.3,0),C.Sage,true)end end
end
local houses=w.Houses:GetChildren();table.sort(houses,function(a,b)return a.Name<b.Name end)
for index,h in ipairs(houses)do
 local old=h:FindFirstChild("FurnishedRooms");if old then old:Destroy()end
 local f=Instance.new("Folder");f.Name="FurnishedRooms";f.Parent=h
 local b=h.Foundation.CFrame;local side=index%2==0 and -1 or 1
 local function box(name,size,x,y,z,col,solid)return part(f,name,Vector3.new(table.unpack(size)),b*CFrame.new(x,y,z),col,solid)end
 -- Place the dining group away from the entrance, front display slots and kitchen route.
 local x=side*27
 box("DiningRug",{16,.035,13},x,.75,-26,C.Cream,false)
 box("DiningTable",{8,.25,4.4},x,3,-26,C.Oak,true)
 for _,dx in ipairs({-3.3,3.3})do for _,dz in ipairs({-1.5,1.5})do box("TableLeg",{.3,2.1,.3},x+dx,1.85,-26+dz,C.Ink,true)end end
 chair(f,b*CFrame.new(x-5.5,.7,-26)*CFrame.Angles(0,-math.pi/2,0),"DiningSeat")
 chair(f,b*CFrame.new(x+5.5,.7,-26)*CFrame.Angles(0,math.pi/2,0),"DiningSeat")
 chair(f,b*CFrame.new(x,.7,-29.9)*CFrame.Angles(0,math.pi,0),"DiningSeat")
 chair(f,b*CFrame.new(x,.7,-22.1),"DiningSeat")
 plant(f,b*CFrame.new(x,3.15,-26),.7)
 box("DiningSideboard",{2.4,2.6,8},side*39.6,2.15,-25,C.Sage,true)
 box("SideboardTop",{2.7,.18,8.3},side*39.6,3.54,-25,C.Oak,true)
 plant(f,b*CFrame.new(side*39.6,3.65,-22.5),.9)
 for _,dz in ipairs({-2.2,2.2})do
  box("DiningArtFrame",{.18,4.5,3.7},side*42.25,7.5,-25+dz,C.Oak,false)
  box("DiningArtPaper",{.12,4.15,3.35},side*42.1,7.5,-25+dz,C.Cream,false)
  box("DiningArtShape",{.08,2.3,1.6},side*42,7.3,-25+dz,C.Sage,false)
 end
 -- Compact island with a wide aisle behind it and room to approach the saved display slot.
 box("IslandPlinth",{7.6,.25,3},side*23,.95,26,C.Ink,true)
 box("IslandCabinet",{8,2.45,3.4},side*23,2.3,26,C.Sage,true)
 box("IslandWorktop",{8.5,.2,3.9},side*23,3.65,26,C.Cream,true)
 for _,dx in ipairs({-2,2})do box("IslandDoor",{3.75,2.1,.1},side*23+dx,2.35,24.25,C.Sage,false);box("IslandHandle",{.7,.07,.09},side*23+dx,3.1,24.15,C.Ink,false)end
 -- Reading seats face the existing sofa without intruding on the mid-room display spaces.
 local lx=-side*27
 chair(f,b*CFrame.new(lx-7,.7,-26)*CFrame.Angles(0,-math.pi/2,0),"ReadingSeat")
 chair(f,b*CFrame.new(lx+7,.7,-26)*CFrame.Angles(0,math.pi/2,0),"ReadingSeat")
 plant(f,b*CFrame.new(-side*39,.7,-32),1.7)
 -- Low bookcase along the outside wall. Open shelves and grouped books add purpose.
 local shelf=b*CFrame.new(-side*39.5,0,-7)*CFrame.Angles(0,-side*math.pi/2,0)
 for _,dx in ipairs({-3.2,3.2})do part(f,"BookcaseSide",Vector3.new(.2,6,1.6),shelf*CFrame.new(dx,3.7,0),C.Oak,true)end
 for _,y in ipairs({.8,2.6,4.4,6.6})do part(f,"BookcaseShelf",Vector3.new(6.6,.18,1.6),shelf*CFrame.new(0,y,0),C.Oak,true)end
 for row=1,3 do for j=1,4 do part(f,"GroupedBooks",Vector3.new(.45,1.2+(j%2)*.18,1.1),shelf*CFrame.new(-2.5+j*.65,1.5+(row-1)*1.8,0),j%2==0 and C.Sage or C.Cream,false)end end
 -- Bedroom storage sits on the outer wall, clear of the bed and doorway.
 box("Wardrobe",{3.5,7,8},-side*39,4.25,23,C.Oak,true)
 for _,dz in ipairs({-2,2})do box("WardrobeDoor",{.12,6.6,3.8},-side*37.2,4.3,23+dz,C.Cream,false)end
 box("BedroomBench",{6,.35,2},-side*27,1.8,22,C.Sage,true)
 for _,dx in ipairs({-2.4,2.4})do box("BenchSupport",{.22,.9,1.5},-side*27+dx,1.2,22,C.Ink,true)end
 h:SetAttribute("FurnishingVersion","furnished-cottage-1")
end
-- Repeated stone-edged beds give each house an intentional frontage.
local old=w:FindFirstChild("GardenDetails");if old then old:Destroy()end
local garden=Instance.new("Folder");garden.Name="GardenDetails";garden.Parent=w
for _,h in houses do
 for _,x in ipairs({-34,34})do
  local cf=h.Foundation.CFrame*CFrame.new(x,0,-43)
  part(garden,"StonePlanter",Vector3.new(12,1.1,3.6),cf*CFrame.new(0,.35,0),C.Stone,true)
  part(garden,"PlantingSoil",Vector3.new(11.4,.12,3),cf*CFrame.new(0,.96,0),Color3.fromRGB(84,83,65),false)
  for j=-2,2 do
   local shrub=part(garden,"Shrub",Vector3.new(2.5,1.7,2.4),cf*CFrame.new(j*2.1,1.6,0),C.Leaf,false);shrub.Shape=Enum.PartType.Ball
   for _,dz in ipairs({-.55,.55})do local flower=part(garden,"FlowerCluster",Vector3.new(.65,.7,.65),cf*CFrame.new(j*2.1,2.35,dz),j%2==0 and C.Cream or C.Lavender,false);flower.Shape=Enum.PartType.Ball end
  end
 end
end
-- Matching planting and small path lamps carry the palette into public destinations.
for _,pos in ipairs({{-675,-90},{-675,270},{-452,-90},{-452,270},{600,-150},{600,190},{-140,448},{140,448}})do
 local cf=CFrame.new(pos[1],0,pos[2])
 part(garden,"PublicStoneBed",Vector3.new(10,.8,4),cf*CFrame.new(0,.4,0),C.Stone,true)
 for j=-1,1 do
  local shrub=part(garden,"PublicShrub",Vector3.new(3,2.1,3),cf*CFrame.new(j*3,1.5,0),C.Leaf,false);shrub.Shape=Enum.PartType.Ball
  local flowers=part(garden,"PublicFlowers",Vector3.new(1.8,.65,1.3),cf*CFrame.new(j*3,2.5,0),j==0 and C.Cream or C.Lavender,false);flowers.Shape=Enum.PartType.Ball
 end
 part(garden,"PathLampPost",Vector3.new(.6,3.8,.6),cf*CFrame.new(7,1.9,0),C.Ink,true)
 local lantern=part(garden,"PathLantern",Vector3.new(.9,.7,.9),cf*CFrame.new(7,3.8,0),C.Cream,false)
 lantern.Material=Enum.Material.Neon
 local light=Instance.new("PointLight");light.Color=Color3.fromRGB(255,231,190);light.Range=18;light.Brightness=.5;light.Enabled=false;light.Parent=lantern
end
w:SetAttribute("FurnishingDesign","maple-valley-1")
return {Houses=#houses,NewParts=count,Design="maple-valley-1"}
