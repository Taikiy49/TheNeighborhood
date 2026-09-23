-- Maple Street art direction v2. Run in Edit after art-pass.luau.
assert(not game:GetService('RunService'):IsRunning(),'Edit mode required')
local world=workspace.Neighborhood
local art=world.ArtDirection
local prior=art:FindFirstChild('GardenRedesign')
if prior and not game.ServerStorage:FindFirstChild('MapleTreeArtSource')then
 local trees=prior:FindFirstChild('Trees');local template=trees and trees:FindFirstChildWhichIsA('Model')
 if template then local copy=template:Clone();copy.Name='MapleTreeArtSource';copy.Parent=game.ServerStorage end
end
if prior then prior:Destroy()end
local root=Instance.new('Folder');root.Name='GardenRedesign';root.Parent=art
local C=Color3.fromRGB
local cream=C(235,224,201);local ink=C(48,64,63);local oak=C(136,105,74);local brick=C(149,99,76)
local siding='rbxassetid://112300470260355';local botanical='rbxassetid://96894167022767'
local function folder(name)local f=Instance.new('Folder');f.Name=name;f.Parent=root;return f end
local function part(parent,name,size,cf,color,material,shape)
 local p=Instance.new('Part');p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color;p.Material=material or Enum.Material.SmoothPlastic
 p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false
 p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;if shape then p.Shape=shape end;p.Parent=parent;return p
end
local function cylinder(parent,name,r,h,cf,color,mat)return part(parent,name,Vector3.new(h,r*2,r*2),cf*CFrame.Angles(0,0,math.pi/2),color,mat,Enum.PartType.Cylinder)end
local function beam(parent,name,a,b,width,color,mat)
 return part(parent,name,Vector3.new(width,width,(b-a).Magnitude),CFrame.lookAt((a+b)/2,b),color,mat)
end
local function texture(p,face)
 local name='HiggsfieldSiding'..face.Name;local t=p:FindFirstChild(name)or Instance.new('Texture');t.Name=name;t.Texture=siding;t.Face=face;t.StudsPerTileU=16;t.StudsPerTileV=10;t.Color3=p.Color;t.Parent=p
end
local function printOn(p)
 local d=p:FindFirstChild('HiggsfieldBotanical')or Instance.new('Decal');d.Name='HiggsfieldBotanical';d.Texture=botanical;d.Face=Enum.NormalId.Front;d.Parent=p
end
local function plant(parent,cf,scale,flower)
 if flower then part(parent,'PlantingCushion',Vector3.new(1.6,0.75,1.5)*scale,cf*CFrame.new(0,0.4*scale,0),C(81,103,65),Enum.Material.SmoothPlastic,Enum.PartType.Ball)
 else cylinder(parent,'ClayPot',0.55*scale,0.8*scale,cf*CFrame.new(0,0.4*scale,0),brick,Enum.Material.CeramicTiles)end
 for n=1,3 do local a=n*2.1
  local p=part(parent,'LeafSpray',Vector3.new(0.35,1.5,0.8)*scale,cf*CFrame.new(math.cos(a)*0.4*scale,1.35*scale,math.sin(a)*0.4*scale)*CFrame.Angles(0,a,0.4),C(86+n*5,112+n*6,75),Enum.Material.SmoothPlastic,Enum.PartType.Ball)
  if flower then part(parent,'FlowerHead',Vector3.new(0.65,0.45,0.65)*scale,p.CFrame*CFrame.new(0,0.65*scale,0),flower,Enum.Material.SmoothPlastic,Enum.PartType.Ball)end
 end
end
local palette={C(155,174,153),C(195,163,139),C(139,164,177),C(197,184,141),C(165,174,155),C(190,153,137),C(147,166,180),C(178,176,148)}
local houses=world.Houses:GetChildren();table.sort(houses,function(a,b)return a.Name<b.Name end)
for i,h in houses do
 local f=folder(h.Name);local base=h.Foundation.CFrame*CFrame.new(0,-0.5,0);local height=8+(i%3)
 for _,p in h:GetChildren()do if p:IsA('BasePart')then
  if p.Name:find('Wall')or p.Name=='FrontSill'or p.Name=='FrontHeader'or p.Name=='Gable'then
   p.Color=palette[i];p.Material=Enum.Material.WoodPlanks
   for _,face in {Enum.NormalId.Front,Enum.NormalId.Back,Enum.NormalId.Left,Enum.NormalId.Right}do texture(p,face)end
  elseif p.Name=='Foundation'then p.Material=Enum.Material.Brick;p.Color=C(156,148,129)
  elseif p.Name=='Shutter'then p.Color=ink
  elseif p.Name=='FrontPath'then p.Material=Enum.Material.Pavement;p.Color=C(192,184,165)
  elseif p.Name=='Porch'then p.Material=Enum.Material.WoodPlanks;p.Color=C(161,144,111)
  elseif p.Name=='Window'then p.Color=C(177,202,193);p.Transparency=0.62;p.Reflectance=0.06
  elseif p.Name=='Door'then p.Color=({ink,C(132,79,61),C(69,94,100)})[(i-1)%3+1]
  elseif p.Name=='AddressPlaque'then p.Color=ink
  elseif p.Name=='Chimney'then p.Material=Enum.Material.Brick;p.Color=brick;p.Size=Vector3.new(2.6,10,2.6);local pos=base:PointToObjectSpace(p.Position);p.CFrame=base*CFrame.new(pos.X,19,pos.Z)
  end
  if p.Name=='Roof'then
   local pos=base:PointToObjectSpace(p.Position);local side=pos.X<0 and -1 or 1;local angle=math.atan(height/16)
   p.Size=Vector3.new(math.sqrt(16^2+height^2),0.65,29.4);p.CFrame=base*CFrame.new(side*8,12.2+height/2,0)*CFrame.Angles(0,0,-side*angle);p.Color=C(56,69,77)
   for _,z in {-14.85,14.85}do part(f,'RakingFascia',Vector3.new(p.Size.X+0.3,0.55,0.35),p.CFrame*CFrame.new(0,0,z),cream,Enum.Material.Wood)end
  elseif p.Name=='Gable'then local pos=base:PointToObjectSpace(p.Position);p.Size=Vector3.new(0.65,height,15);p.CFrame=base*CFrame.new(pos.X,12+height/2,pos.Z)*(base:ToObjectSpace(p.CFrame).Rotation)end
 end end
 part(f,'RidgeCap',Vector3.new(0.6,0.45,30),base*CFrame.new(0,12.45+height,0),ink,Enum.Material.Metal)
 -- Attic windows provide a focal point in each tall gable.
 local pane=part(f,'AtticWindow',Vector3.new(3.2,3.6,0.25),base*CFrame.new(0,15.9,-13.15),C(106,144,149),Enum.Material.Glass);pane.Transparency=0.18
 for _,x in {-1.8,1.8}do part(f,'AtticJamb',Vector3.new(0.3,4.2,0.4),base*CFrame.new(x,15.9,-13.3),cream)end
 for _,y in {13.95,17.85}do part(f,'AtticLintel',Vector3.new(3.9,0.3,0.4),base*CFrame.new(0,y,-13.3),cream)end
 part(f,'AtticMullion',Vector3.new(0.15,3.6,0.4),base*CFrame.new(0,15.9,-13.35),cream)
 part(f,'AtticCrossbar',Vector3.new(3.2,0.15,0.4),base*CFrame.new(0,15.9,-13.35),cream)
 for _,side in {-1,1}do
  for _,y in {1.25,3.45}do part(f,'PorchRail',Vector3.new(4.2,0.25,0.35),base*CFrame.new(side*5.75,y,-18.6),cream,Enum.Material.Wood)end
  for n=0,4 do part(f,'PorchBaluster',Vector3.new(0.17,2.2,0.17),base*CFrame.new(side*(3.8+n*0.85),2.3,-18.6),cream,Enum.Material.Wood)end
  part(f,'PathBrickEdge',Vector3.new(0.35,0.22,17),base*CFrame.new(side*3.65,0.27,-24),brick,Enum.Material.Brick)
  part(f,'GardenBed',Vector3.new(7,0.15,4.6),base*CFrame.new(side*11,0.27,-19),C(133,117,83),Enum.Material.Ground)
  for n=1,3 do
   plant(f,base*CFrame.new(side*(8.5+n*1.3),0.2,-19.7+(n%2)),0.85,({C(221,211,172),C(169,154,184),C(211,157,142)})[(i+n)%3+1])
  end
  plant(f,base*CFrame.new(side*7.7,0.9,-16),0.9)
 end
 local oldArt=art:FindFirstChild(h.Name..'Details')
 if oldArt then for _,p in oldArt:GetChildren()do if p.Name=='BedroomWallArt'then p.Size=Vector3.new(3.4,3.4,0.14);printOn(p)elseif p.Name=='BedroomWallArtFrame'then p.Size=Vector3.new(3.8,3.8,0.12)end end end
 local interior=h:FindFirstChild('BuiltInInterior')
 if interior then for _,p in interior:GetChildren()do if p:IsA('BasePart')then
  if p.Name:find('Arch')or p.Name=='HallPartition'then p.Color=cream;p.Material=Enum.Material.Plaster
  elseif p.Name=='KitchenCabinets'then p.Color=palette[i];p.Material=Enum.Material.Wood
  elseif p.Name=='KitchenCounter'then p.Color=C(223,215,196);p.Material=Enum.Material.Limestone
  elseif p.Name=='Quilt'then p.Color=palette[(i+2)%8+1];p.Material=Enum.Material.Fabric
  elseif p.Name=='Headboard'or p.Name=='BedFrame'then p.Color=oak;p.Material=Enum.Material.Wood
  end
 end end end
 local side=i%2==0 and -1 or 1
 part(f,'KitchenShelf',Vector3.new(7.5,0.18,0.8),base*CFrame.new(side*9,7.5,11.7),oak,Enum.Material.Wood)
 for n=1,3 do cylinder(f,'CeramicJar',0.25+n*0.05,0.8,base*CFrame.new(side*(6.5+n),8,11.7),n==2 and palette[i]or cream,Enum.Material.CeramicTiles)end
 plant(f,base*CFrame.new(-side*5.6,1.2,9),0.9)
 local rug=part(f,'WovenBedroomRug',Vector3.new(8,0.045,5.5),base*CFrame.new(-side*9,1.24,6),C(180,164,134),Enum.Material.Fabric)
 for n=-3,3 do part(f,'RugStripe',Vector3.new(0.11,0.012,5.3),rug.CFrame*CFrame.new(n,0.03,0),cream,Enum.Material.Fabric)end
end
local civic=folder('VillageDetails')
for _,p in world.Map:GetChildren()do if p:IsA('BasePart')then
 if p.Name=='Sidewalk'or p.Name=='ParkWalk'or p.Name=='ParkCrosswalk'then p.Material=Enum.Material.Concrete;p.Color=C(196,188,168)
 elseif p.Name=='VillageGround'then p.Color=C(112,136,87)
 elseif p.Name=='MapleStreet'or p.Name=='CrossStreet'then p.Color=C(68,73,74);p.Material=Enum.Material.Asphalt
 elseif p.Name=='LaneMark'then p.Color=C(201,187,135)
 end
end end
for _,x in {-59.7,-24.3,24.3,59.7}do part(civic,'RaisedCurb',Vector3.new(0.4,0.35,267),CFrame.new(x,0.45,0),C(173,165,145),Enum.Material.Concrete)end
for _,x in {-56,-28,28,56}do for z=-128,128,8 do part(civic,'PavingJoint',Vector3.new(6.7,0.014,0.055),CFrame.new(x,0.506,z),C(165,157,141))end end
for _,s in world.Shops:GetChildren()do
 local x=s.Floor.Position.X;local accent=s.Name=='GeneralStore'and C(66,95,88)or C(154,102,78)
 for _,p in s:GetChildren()do if p:IsA('BasePart')then
  if p.Name=='Wall'or p.Name=='Back'then p.Color=C(198,185,154);p.Material=Enum.Material.Brick
  elseif p.Name=='Sign'then p.Color=cream;for _,t in p:GetDescendants()do if t:IsA('TextLabel')then t.TextColor3=ink;t.Font=Enum.Font.Garamond;t.Text=s.Name=='GeneralStore'and 'MAPLE & MAIN\nGENERAL STORE'or 'SECOND STORY\nPAWN & FINDS' end end
  elseif p.Name=='Counter'then p.Material=Enum.Material.Wood;p.Color=oak end
 end end
 for _,side in {-1,1}do
  part(civic,'ShopWindowFrame',Vector3.new(9,7.5,0.6),CFrame.new(x+side*13,4.7,144.1),accent,Enum.Material.Wood)
  local p=part(civic,'ShopWindow',Vector3.new(8.2,6.7,0.2),CFrame.new(x+side*13,4.7,143.7),C(155,183,174),Enum.Material.Glass);p.Transparency=0.48
  part(civic,'ShopMullion',Vector3.new(0.22,7,0.35),CFrame.new(x+side*13,4.7,143.5),cream)
  part(civic,'ShopCrossbar',Vector3.new(8.4,0.22,0.35),CFrame.new(x+side*13,4.7,143.5),cream)
  plant(civic,CFrame.new(x+side*17,0.3,136.8),1.3,C(218,203,161))
 end
 for _,y in {14.5,15.2}do part(civic,'ParapetCornice',Vector3.new(41,0.35,29),CFrame.new(x,y,157),cream,Enum.Material.Limestone)end
 for _,side in {-1,1}do
  local roof=part(civic,'ShopPitchedRoof',Vector3.new(41,0.5,math.sqrt(14^2+7^2)),CFrame.new(x,18.8,157+side*7)*CFrame.Angles(side*math.atan(7/14),0,0),C(56,69,77),Enum.Material.RoofShingles)
  roof.CastShadow=true
  for _,xx in {-20.6,20.6}do part(civic,'ShopRoofFascia',Vector3.new(0.35,0.55,roof.Size.Z+0.3),roof.CFrame*CFrame.new(xx,0,0),cream,Enum.Material.Wood)end
 end
 part(civic,'ShopRidge',Vector3.new(42,0.4,0.5),CFrame.new(x,22.5,157),ink,Enum.Material.Metal)
 for _,edge in {-20,20}do for _,side in {-1,1}do
  local g=Instance.new('WedgePart');g.Name='ShopGable';g.Size=Vector3.new(0.5,7,14);g.CFrame=CFrame.new(x+edge,18.8,157+side*7)*CFrame.Angles(0,side<0 and 0 or math.pi,0)
  g.Color=accent;g.Material=Enum.Material.WoodPlanks;g.Anchored=true;g.CanCollide=false;g.CanQuery=false;g.CanTouch=false;g.CastShadow=false;g.Parent=civic
 end end
 for n=-2,2 do
  part(civic,'DisplayShelf',Vector3.new(6,0.2,1),CFrame.new(x+n*6.8,5,167.8),oak,Enum.Material.Wood)
  for k=-1,1 do part(civic,'StoreParcel',Vector3.new(1.2,1.4,0.8),CFrame.new(x+n*6.8+k*1.6,5.8,167.8),k==0 and accent or C(180,152,111),Enum.Material.Cardboard)end
 end
end
-- Replace old canopy silhouettes with one reusable, textured, low-poly mesh asset.
local storage=game:GetService('ServerStorage')
local source=storage:FindFirstChild('MapleTreeArtSource')
if not source then source=game:GetService('CollectionService'):GetTagged('Assistant-44243f59-a3f1-43d3-99a2-f3765a3c3f3c')[1];assert(source,'Tree source missing');source.Name='MapleTreeArtSource';source.Parent=storage end
local trees=folder('Trees');local spots={}
for _,parent in {world.Map,table.unpack(houses)}do for _,p in parent:GetChildren()do
 if p:IsA('BasePart')and p.Name=='Trunk'then table.insert(spots,{p.Position.X,p.Position.Z,parent==world.Map and 20 or 22});p.Transparency=1
 elseif p:IsA('BasePart')and p.Name=='Canopy'then p.Transparency=1;p.CanCollide=false;p.CanQuery=false end
end end
local landscape=art.Landscape
for _,p in landscape:GetChildren()do
 if p.Name=='DistantTrunk'then table.insert(spots,{p.Position.X,p.Position.Z,22+(#spots%4)*2});p.Transparency=1
 elseif p.Name=='LeafLobe'or p.Name=='DistantCrown'or p.Name=='DistantLobe'then p.Transparency=1 end
end
for i,s in spots do
 local tree=source:Clone();tree.Name='MapleTree'..i;tree:ScaleTo(tree:GetScale()*s[3]/tree:GetExtentsSize().Y)
 local cf,size=tree:GetBoundingBox();tree:PivotTo(CFrame.new(s[1],s[3]/2,s[2])*CFrame.Angles(0,i*2.399,0)*(cf:ToObjectSpace(tree:GetPivot())))
 for _,p in tree:GetDescendants()do if p:IsA('BasePart')then p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=i<=16;p.Color=p.Name:find('leaves')and C(150+(i%3)*9,176+(i%2)*9,120)or C(215,204,184)end end
 tree.Parent=trees
end
local L=game:GetService('Lighting');L.ClockTime=15.8;L.Brightness=2.4;L.Ambient=C(114,123,132);L.OutdoorAmbient=C(139,149,148)
local grade=L.NeighborhoodGrade;grade.TintColor=C(255,249,236);grade.Saturation=-0.04;grade.Contrast=0.12;grade.Brightness=0.015
L.Bloom.Intensity=0.08;L.SunRays.Intensity=0.025
local a=L:FindFirstChildOfClass('Atmosphere');if a then a.Density=0.25;a.Haze=1.2;a.Color=C(218,229,231);a.Decay=C(164,183,188)end
world:SetAttribute('ArtPassVersion',2)
local count=0;for _,p in art:GetDescendants()do if p:IsA('BasePart')then count+=1 end end
return {ArtParts=count,Trees=#spots,WorldDescendants=#world:GetDescendants(),Siding=siding,Botanical=botanical}
