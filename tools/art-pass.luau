-- Edit-time, deterministic art pass. Decorative additions never obstruct gameplay rays/routes.
assert(not game:GetService("RunService"):IsRunning(),"Edit mode required")
local world=workspace.Neighborhood
local old=world:FindFirstChild("ArtDirection");if old then old:Destroy()end
local art=Instance.new("Folder");art.Name="ArtDirection";art.Parent=world
local cream=Color3.fromRGB(243,230,204)
local teal=Color3.fromRGB(39,83,74)
local wood=Color3.fromRGB(135,96,67)
local random=Random.new(7331)
local function part(parent,name,size,cf,color,material,shape)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color;p.Material=material or Enum.Material.SmoothPlastic
 p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
 if shape then p.Shape=shape end;p.Parent=parent;return p
end
local function group(name)local f=Instance.new("Folder");f.Name=name;f.Parent=art;return f end
local function ball(parent,name,size,position,color,material)
 return part(parent,name,size,CFrame.new(position),color,material,Enum.PartType.Ball)
end
local function uprightCylinder(parent,name,radius,height,cf,color,material)
 return part(parent,name,Vector3.new(height,radius*2,radius*2),cf*CFrame.Angles(0,0,math.pi/2),color,material,Enum.PartType.Cylinder)
end
local function flowers(parent,basis,x,z,color)
 part(parent,"TerracottaPlanter",Vector3.new(3.8,0.8,1.5),basis*CFrame.new(x,2.9,z),wood,Enum.Material.Brick)
 for n=-1,1 do
  local pos=(basis*CFrame.new(x+n*1.05,3.6,z)).Position
  ball(parent,"LeafCushion",Vector3.new(1.8,1,1.6),pos,Color3.fromRGB(76,116,73))
  ball(parent,"FlowerCluster",Vector3.new(0.8,0.5,0.8),pos+Vector3.new(0,0.5,0),color)
 end
end
local palettes={Color3.fromRGB(233,154,130),Color3.fromRGB(239,198,110),Color3.fromRGB(163,188,213),Color3.fromRGB(207,174,196)}
local houses=world.Houses:GetChildren();table.sort(houses,function(a,b)return a.Name<b.Name end)
for index,house in ipairs(houses)do
 local f=group(house.Name.."Details");local base=house.Foundation.CFrame
 for _,p in house:GetChildren()do
  if p:IsA("BasePart")then
   if p.Name=="Roof" or p.Name=="PorchRoof"then p.Material=Enum.Material.RoofShingles;p.Color=index%2==0 and Color3.fromRGB(79,89,91)or Color3.fromRGB(58,79,79)
   elseif p.Name=="Shutter"then p.Material=Enum.Material.Wood
   elseif p.Name=="GardenFence"or p.Name=="RearFence"then p.Material=Enum.Material.Wood;p.Color=Color3.fromRGB(190,177,144)
   elseif p.Name=="Canopy"then p.Material=Enum.Material.SmoothPlastic;p.Color=index%3==0 and Color3.fromRGB(126,153,80)or Color3.fromRGB(83,126,84)
   elseif p.Name=="PorchShrub"then p.Material=Enum.Material.SmoothPlastic;p.Color=Color3.fromRGB(99,137,88)
   end
  end
 end
 -- Front windows stay clear; the sill planters sit below the glass.
 for _,x in ipairs({-9,9})do
  flowers(f,base,x,-13.4,palettes[(index-1)%4+1])
  part(f,"WindowLintel",Vector3.new(10.8,0.45,0.8),base*CFrame.new(x,9.35,-13.1),cream)
 end
 for _,x in ipairs({-14.9,14.9})do part(f,"CornerTrim",Vector3.new(0.55,10.8,0.65),base*CFrame.new(x,5.9,-12.85),cream)end
 for _,x in ipairs({-7,7})do
  part(f,"ColumnFoot",Vector3.new(1.2,0.5,1.2),base*CFrame.new(x,0.7,-17),cream)
  part(f,"ColumnCapital",Vector3.new(1.1,0.35,1.1),base*CFrame.new(x,9.1,-17),cream)
 end
 part(f,"WelcomeMat",Vector3.new(4.6,0.07,2.2),base*CFrame.new(0,0.34,-15.1),Color3.fromRGB(151,117,74),Enum.Material.Fabric)
 for _,side in ipairs({-1,1})do
  part(f,"RoofFascia",Vector3.new(0.35,0.55,29.4),base*CFrame.new(side*16,11.9,0),cream)
  for step=1,4 do
   local pos=(base*CFrame.new(side*(6+step*1.7),0.45,-21-step*0.45)).Position
   ball(f,"GardenStone",Vector3.new(1.8,0.55,1.4),pos,Color3.fromRGB(175,174,149),Enum.Material.Rock)
  end
 end
 -- Small rear patio detail, outside all six possession slots.
 part(f,"PatioRug",Vector3.new(8,0.05,4),base*CFrame.new(8,0.22,20),palettes[(index-1)%4+1],Enum.Material.Fabric)
 uprightCylinder(f,"PatioTable",1.7,0.24,base*CFrame.new(8,2.4,20),cream,Enum.Material.Wood)
 part(f,"TablePedestal",Vector3.new(0.4,2.1,0.4),base*CFrame.new(8,1.3,20),teal)
 local interior=house:FindFirstChild("BuiltInInterior")
 if interior then
  local side=index%2==0 and -1 or 1
  part(f,"KitchenBacksplash",Vector3.new(8.6,1.6,0.12),base*CFrame.new(side*9,4.4,12.19),Color3.fromRGB(208,224,205),Enum.Material.CeramicTiles)
  part(f,"BedroomWallArtFrame",Vector3.new(4.2,2.6,0.12),base*CFrame.new(-side*9,6.6,12.15),wood,Enum.Material.Wood)
  part(f,"BedroomWallArt",Vector3.new(3.8,2.2,0.14),base*CFrame.new(-side*9,6.6,12.05),palettes[index%4+1],Enum.Material.Fabric)
 end
end
local landscaping=group("Landscape")
local function organicCrown(p)
 if not p:GetAttribute("ArtOriginalSize")then p:SetAttribute("ArtOriginalSize",tostring(p.Size))end
 -- Keep original bounds stable on repeated authoring runs.
 local sx,sy,sz=p:GetAttribute("ArtOriginalSize"):match("([^,]+), ([^,]+), ([^,]+)")
 local size=Vector3.new(tonumber(sx),tonumber(sy),tonumber(sz))
 p.Size=size*0.8;p.Material=Enum.Material.Grass
 for n=1,3 do
  local a=n*2.1+p.Position.Z*0.1
  local offset=Vector3.new(math.cos(a)*size.X*0.25,n*0.5,math.sin(a)*size.Z*0.25)
  local leaf=ball(landscaping,"LeafLobe",size*Vector3.new(0.73,0.64,0.69),p.Position+offset,p.Color:Lerp(cream,n*0.025),Enum.Material.Grass)
  leaf.CFrame*=CFrame.Angles(0,a,0.18*n)
 end
end
for _,h in ipairs(houses)do for _,p in h:GetChildren()do if p.Name=="Canopy"and p:IsA("BasePart")then organicCrown(p)end end end
for _,p in world.Map:GetChildren()do
 if p:IsA("BasePart")and p.Name=="Canopy"then
  local shade=math.floor((p.Position.Z+100)/40)%3
  p.Color=({Color3.fromRGB(98,141,83),Color3.fromRGB(133,158,83),Color3.fromRGB(75,123,91)})[shade+1]
  organicCrown(p)
 elseif p:IsA("BasePart")and p.Name=="Lantern"then
  p.Size=Vector3.new(1.25,2,1.25);p.Material=Enum.Material.Glass;p.Transparency=0.25;p.Color=Color3.fromRGB(255,226,173)
  for _,dy in ipairs({-1.05,1.05})do part(landscaping,"LanternCap",Vector3.new(1.6,0.18,1.6),p.CFrame*CFrame.new(0,dy,0),teal,Enum.Material.Metal)end
  for _,dx in ipairs({-0.65,0.65})do for _,dz in ipairs({-0.65,0.65})do part(landscaping,"LanternFrame",Vector3.new(0.12,2.1,0.12),p.CFrame*CFrame.new(dx,0,dz),teal,Enum.Material.Metal)end end
 elseif p:IsA("BasePart")and (p.Name=="Sidewalk"or p.Name=="ParkWalk"or p.Name=="ParkCrosswalk")then p.Material=Enum.Material.Pavement;p.Color=Color3.fromRGB(219,208,184)
 elseif p:IsA("BasePart")and p.Name=="VillageGround"then p.Color=Color3.fromRGB(131,158,100)end
end
-- Curved landscaping masses frame the horizon instead of a floating flat rectangle.
for _,side in ipairs({-1,1})do
 for z=-175,175,70 do
  ball(landscaping,"RollingMeadow",Vector3.new(125,34,104),Vector3.new(side*194,-4,z),Color3.fromRGB(127,151,97),Enum.Material.Grass)
  for n=1,3 do
   local x=side*(151+n*11);local zz=z+n*8
   part(landscaping,"DistantTrunk",Vector3.new(1.4,11,1.4),CFrame.new(x,4,zz),wood,Enum.Material.Wood)
   local crown=ball(landscaping,"DistantCrown",Vector3.new(13,16,13),Vector3.new(x,14+n,zz),Color3.fromRGB(76+n*9,113+n*8,83),Enum.Material.Grass)
   ball(landscaping,"DistantLobe",Vector3.new(10,12,11),crown.Position+Vector3.new(3,1,2),crown.Color,Enum.Material.Grass)
  end
 end
end
for _,z in ipairs({-200,207})do ball(landscaping,"HorizonMeadow",Vector3.new(355,31,115),Vector3.new(0,-6,z),Color3.fromRGB(136,157,102),Enum.Material.Grass)end
-- Low planting ribbons leave the paths, discovery notes and street sightlines open.
for _,side in ipairs({-1,1})do
 for _,z in ipairs({-88,-64,-24,24,64,88})do
  local x=side*23
  ball(landscaping,"BorderPlanting",Vector3.new(2.8,1.4,5.4),Vector3.new(x,0.6,z),Color3.fromRGB(93,132,79))
  for n=-1,1 do ball(landscaping,"Wildflower",Vector3.new(0.55,0.4,0.55),Vector3.new(x,1.35,z+n*1.1),palettes[(n+4)%4+1])end
 end
end
local square=group("FountainCourt")
uprightCylinder(square,"StonePlinth",5.5,0.18,CFrame.new(14,0.25,12),Color3.fromRGB(215,207,177),Enum.Material.Limestone)
uprightCylinder(square,"FountainBasin",3.6,0.75,CFrame.new(14,0.72,12),cream,Enum.Material.Limestone)
uprightCylinder(square,"StillWater",3.15,0.07,CFrame.new(14,1.13,12),Color3.fromRGB(89,163,160),Enum.Material.Glass)
uprightCylinder(square,"FountainStem",0.6,2.6,CFrame.new(14,2.4,12),cream,Enum.Material.Limestone)
uprightCylinder(square,"UpperBowl",1.7,0.3,CFrame.new(14,3.7,12),cream,Enum.Material.Limestone)
ball(square,"WaterFinial",Vector3.new(0.6,0.9,0.6),Vector3.new(14,4.3,12),Color3.fromRGB(114,187,182),Enum.Material.Glass)
for n=1,12 do local a=n*math.pi/6;part(square,"CourtPaver",Vector3.new(1.9,0.1,1.1),CFrame.new(14+math.cos(a)*4.7,0.39,12+math.sin(a)*4.7)*CFrame.Angles(0,-a,0),Color3.fromRGB(168,158,134),Enum.Material.Pavement)end
local retail=group("Shopfronts")
for _,shop in world.Shops:GetChildren()do
 local center=shop.Floor.Position.X
 local accent=shop.Name=="GeneralStore" and teal or Color3.fromRGB(151,92,70)
 shop.Awning.Color=cream;shop.Awning.Material=Enum.Material.Fabric
 for n=-4,4 do
  part(retail,"CanvasStripe",Vector3.new(2.1,0.06,7.1),CFrame.new(center+n*4.2,9.23,142),accent,Enum.Material.Fabric)
  part(retail,"ScallopedValance",Vector3.new(2.1,0.7,0.18),CFrame.new(center+n*4.2,8.85,138.5),accent,Enum.Material.Fabric)
 end
 for _,side in ipairs({-1,1})do
  part(retail,"ShopPilaster",Vector3.new(1.2,13,1.3),CFrame.new(center+side*18.6,6.5,144.5),cream)
  uprightCylinder(retail,"ShopPot",1.2,1.6,CFrame.new(center+side*16,0.9,140),accent,Enum.Material.CeramicTiles)
  ball(retail,"ShopTopiary",Vector3.new(2.9,3.5,2.9),Vector3.new(center+side*16,2.8,140),Color3.fromRGB(79,126,84))
 end
 part(retail,"ShopCornice",Vector3.new(40.4,0.8,1.1),CFrame.new(center,14.6,143.3),cream)
end
local lighting=game:GetService("Lighting")
lighting.ClockTime=16.3;lighting.Brightness=2.1;lighting.Ambient=Color3.fromRGB(124,137,138);lighting.OutdoorAmbient=Color3.fromRGB(148,154,127)
local color=lighting:FindFirstChild("NeighborhoodGrade")or Instance.new("ColorCorrectionEffect");color.Name="NeighborhoodGrade";color.TintColor=Color3.fromRGB(255,244,222);color.Saturation=0.06;color.Contrast=0.07;color.Brightness=0.01;color.Parent=lighting
local bloom=lighting:FindFirstChildOfClass("BloomEffect")or Instance.new("BloomEffect");bloom.Name="Bloom";bloom.Intensity=0.13;bloom.Size=18;bloom.Threshold=1.4;bloom.Parent=lighting
local rays=lighting:FindFirstChildOfClass("SunRaysEffect")or Instance.new("SunRaysEffect");rays.Name="SunRays";rays.Intensity=0.045;rays.Spread=0.8;rays.Parent=lighting
world:SetAttribute("ArtPassVersion",1)
return {DecorativeParts=#art:GetDescendants(),Houses=#houses,TotalDescendants=#world:GetDescendants()}
