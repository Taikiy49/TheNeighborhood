-- Edit-only, reproducible district landscape. No imported meshes/textures required.
assert(not game:GetService("RunService"):IsRunning(),"Edit mode required")
local w=workspace.Neighborhood;assert(w:GetAttribute("HorizontalScale")==3,"Expand the world first")
local art=w.ArtDirection
for _,v in ipairs(art:GetChildren())do
 if v.Name:match("^House%d+Details$")or table.find({"Landscape","FountainCourt","Shopfronts","GardenRedesign","GardenDistrict"},v.Name)then v:Destroy()end
end
local root=Instance.new("Folder");root.Name="GardenDistrict";root.Parent=art
local C={Grass=Color3.fromRGB(139,166,110),Leaf=Color3.fromRGB(77,119,85),LeafLight=Color3.fromRGB(113,150,93),Cream=Color3.fromRGB(236,233,215),Path=Color3.fromRGB(207,203,184),Ink=Color3.fromRGB(48,68,65),Wood=Color3.fromRGB(160,128,89),Water=Color3.fromRGB(96,172,170),Stone=Color3.fromRGB(171,179,161)}
local count=0
local function folder(name)local f=Instance.new("Folder");f.Name=name;f.Parent=root;return f end
local function p(parent,name,size,cf,color,solid,material,class)
 local v=Instance.new(class or "Part");v.Name=name;v.Size=size;v.CFrame=cf;v.Color=color;v.Material=material or Enum.Material.SmoothPlastic
 v.Anchored=true;v.CanCollide=solid==true;v.CanTouch=false;v.CanQuery=solid==true;v.TopSurface=Enum.SurfaceType.Smooth;v.BottomSurface=Enum.SurfaceType.Smooth;v.Parent=parent;count+=1;return v
end
local function box(parent,name,size,pos,color,solid,mat)return p(parent,name,Vector3.new(table.unpack(size)),CFrame.new(table.unpack(pos)),color,solid,mat)end
local function ball(parent,name,r,pos,color,solid)local v=p(parent,name,Vector3.one*r*2,CFrame.new(pos),color,solid);v.Shape=Enum.PartType.Ball;if name=="Crown"or name=="MeadowHill"or name=="HerbBush"then v.Material=Enum.Material.Grass end;return v end
local function disc(parent,name,r,y,x,z,color,solid)
 local v=p(parent,name,Vector3.new(.16,r*2,r*2),CFrame.new(x,y,z)*CFrame.Angles(0,0,math.pi/2),color,solid);v.Shape=Enum.PartType.Cylinder;return v
end
local function path(parent,a,b,width)
 local delta=b-a;return p(parent,"Walkway",Vector3.new(width,.12,delta.Magnitude+.15),CFrame.lookAt((a+b)/2,b),C.Path,true)
end
local function tree(parent,x,z,scale,seed)
 local m=Instance.new("Model");m.Name="ParkTree";m.Parent=parent
 local h=9*scale
 local trunk=p(m,"Trunk",Vector3.new(1.15*scale,h,1.15*scale),CFrame.new(x,h/2,z),C.Wood,true)
 local tint=seed%3==0 and C.LeafLight or C.Leaf
 ball(m,"Crown",5.4*scale,Vector3.new(x,h+3.8*scale,z),tint,false)
 ball(m,"Crown",4.4*scale,Vector3.new(x-3.5*scale,h+1.3*scale,z+1.5*scale),tint:Lerp(C.LeafLight,.24),false)
 ball(m,"Crown",4.2*scale,Vector3.new(x+3.8*scale,h+2*scale,z-1.8*scale),tint:Lerp(C.Leaf,.18),false)
 ball(m,"Crown",3.7*scale,Vector3.new(x+.7*scale,h+6.4*scale,z+.5*scale),tint:Lerp(C.LeafLight,.16),false)
 m.PrimaryPart=trunk
 return m
end
local function bench(parent,cf)
 local m=Instance.new("Model");m.Name="ParkBench";m.Parent=parent
 p(m,"Seat",Vector3.new(6,.35,2),cf*CFrame.new(0,1.6,0),C.Wood,true,nil,"Seat")
 p(m,"Back",Vector3.new(6,1.5,.22),cf*CFrame.new(0,2.45,.95),C.Wood,true)
 for _,x in ipairs({-2.4,2.4})do p(m,"Leg",Vector3.new(.25,1.5,1.8),cf*CFrame.new(x,.8,0),C.Ink,true)end
end
local function sign(parent,title,x,z,angle)
 local cf=CFrame.new(x,0,z)*CFrame.Angles(0,angle or 0,0)
 p(parent,"SignPost",Vector3.new(.35,4.8,.35),cf*CFrame.new(0,2.4,0),C.Ink,false)
 local plate=p(parent,"DistrictSign",Vector3.new(12,2.5,.3),cf*CFrame.new(0,4.6,0),C.Ink,false)
 for _,face in ipairs({Enum.NormalId.Front,Enum.NormalId.Back})do
  local gui=Instance.new("SurfaceGui");gui.Face=face;gui.CanvasSize=Vector2.new(720,150);gui.LightInfluence=.25;gui.Parent=plate
  local text=Instance.new("TextLabel");text.Size=UDim2.fromScale(1,1);text.BackgroundTransparency=1;text.TextColor3=C.Cream;text.Font=Enum.Font.GothamMedium;text.TextSize=38;text.Text=title;text.Parent=gui
 end
end
local streets=folder("Streets")
w.Map.VillageGround.Color=C.Grass;w.Map.VillageGround.Material=Enum.Material.Grass
-- Keep the arterial roads navigable at vehicle scale, with generous planted verges.
for _,v in ipairs(w.Map:GetChildren())do if v:IsA("BasePart")then
 if v.Name=="MapleStreet"then v.Size=Vector3.new(36,v.Size.Y,v.Size.Z);v.Material=Enum.Material.Asphalt;v.Color=Color3.fromRGB(76,86,84)
 elseif v.Name=="CrossStreet"then v.Size=Vector3.new(v.Size.X,v.Size.Y,36);v.Material=Enum.Material.Asphalt;v.Color=Color3.fromRGB(76,86,84)
 elseif v.Name=="Sidewalk"or v.Name=="ParkWalk"or v.Name=="ParkCrosswalk"or v.Name=="BackyardShortcut"then v.Material=Enum.Material.SmoothPlastic;v.Color=C.Path
 elseif v.Name=="LaneMark"then v.Size=Vector3.new(.35,.025,9);v.Color=C.Cream
 elseif v.Name=="Trunk"or v.Name=="Canopy"then v:Destroy()
 elseif v.Name=="LampPost"or v.Name=="Lantern"then v:Destroy()
 end
end end
for _,x in ipairs({-144.4,-107.6,107.6,144.4})do box(streets,"RoadCurb",{.65,.35,762},{x,.22,0},C.Cream,false)end
for _,z in ipairs({-381,0,381})do
 for _,x in ipairs({-126,126})do
  for n=-3,3 do box(streets,"CrossingStripe",{30,.03,1.5},{x,.19,z+n*3},C.Cream,false)end
 end
end
for _,x in ipairs({-168,168})do for z=-297,297,99 do
 box(streets,"StreetlampPost",{.22,8.6,.22},{x,4.3,z},C.Ink,false)
 local lamp=box(streets,"StreetlampGlass",{.85,1.2,.85},{x,9,z},C.Cream,false,Enum.Material.Glass);lamp.Transparency=.15
 for _,y in ipairs({8.33,9.67})do box(streets,"StreetlampCap",{1.1,.12,1.1},{x,y,z},C.Ink,false)end
 local light=Instance.new("PointLight");light.Color=Color3.fromRGB(255,234,195);light.Brightness=.6;light.Range=25;light.Shadows=false;light.Parent=lamp
end end
-- Block edges become connected promenades, not empty leftover ground.
local walks=folder("Promenades")
local corners={Vector3.new(-462,.17,-510),Vector3.new(462,.17,-510),Vector3.new(462,.17,510),Vector3.new(-462,.17,510)}
for i=1,4 do path(walks,corners[i],corners[i%4+1],12)end
for _,z in ipairs({-372,0,372})do
 path(walks,Vector3.new(-462,.17,z),Vector3.new(-168,.17,z),10)
 path(walks,Vector3.new(168,.17,z),Vector3.new(462,.17,z),10)
end
for _,x in ipairs({-210,210})do path(walks,Vector3.new(x,.17,-510),Vector3.new(x,.17,510),8)end
path(walks,Vector3.new(0,.17,-510),Vector3.new(0,.17,-330),14)
path(walks,Vector3.new(0,.17,330),Vector3.new(0,.17,510),14)
local planting=folder("StreetTrees")
for _,x in ipairs({-151,151})do for z=-324,324,54 do if math.abs(z)>18 then tree(planting,x,z,1.15,math.floor(z))end end end
for _,x in ipairs({-445,445})do for z=-468,468,78 do if math.abs(z)>20 then tree(planting,x,z,1.35,math.floor(z/78))end end end
for _,z in ipairs({-493,493})do for x=-390,390,65 do if math.abs(x)>155 then tree(planting,x,z,1.3,math.floor(x/65))end end end
-- Cottage shell cleanup, clear porch approaches and planted corners.
local exteriors=folder("Cottages")
for index,h in ipairs(w.Houses:GetChildren())do
 local b=h.Foundation.CFrame
 for _,v in ipairs(h:GetDescendants())do if v:IsA("Decal")and v.Name:match("^Higgsfield")then v:Destroy()end end
 for _,v in ipairs(h:GetChildren())do if v:IsA("BasePart")then
  if v.Name:find("Wall")or v.Name=="FrontSill"or v.Name=="FrontHeader"or v.Name=="Gable"then v.Material=Enum.Material.SmoothPlastic
  elseif v.Name=="Roof"or v.Name=="PorchRoof"then v.Material=Enum.Material.SmoothPlastic;v.Color=Color3.fromRGB(60,79,82)
  elseif v.Name=="Foundation"then v.Material=Enum.Material.SmoothPlastic;v.Color=C.Stone
  elseif v.Name=="Porch"or v.Name=="FrontPath"then v.Material=Enum.Material.SmoothPlastic;v.Color=C.Path
  elseif v.Name=="FrontPost"or v.Name=="WindowMullion"or v.Name=="WindowCrossbar"or v.Name=="PorchColumn"then v.Color=C.Cream
  elseif v.Name=="Trunk"or v.Name=="Canopy"or v.Name=="PorchShrub"then v:Destroy()
  elseif v.Name=="GardenFence"or v.Name=="RearFence"then v.Color=C.Wood;v.Material=Enum.Material.SmoothPlastic
  end
 end end
 local function localBox(name,size,x,y,z,c)
  if name~="PorchPlanter"then local V=h:GetAttribute("InteriorHeightScale")or 1;y=.7+(y-.7)*V;size={size[1],size[2]*V,size[3]}end
  return p(exteriors,name,Vector3.new(table.unpack(size)),b*CFrame.new(x,y,z),c,false)end
 for _,side in ipairs({-1,1})do
  localBox("EaveTrim",{.4,.55,80},side*44.4,11.15,0,C.Cream)
  localBox("FrontCorner",{.5,10.5,.5},side*44.3,5.8,-38.4,C.Cream)
  localBox("WindowHeader",{27.5,.4,.5},side*27,9.2,-38.7,C.Cream)
  -- Three panes make the wider front windows deliberate.
  for _,xx in ipairs({21.5,32.5})do localBox("WindowDivider",{.22,5.1,.45},side*xx,6.2,-38.65,C.Cream)end
  localBox("PorchPlanter",{5,1.4,2.4},side*23,.7,-49,C.Wood)
  for j=-1,1 do
   local pos=(b*CFrame.new(side*23+j*1.4,1.9,-49)).Position
   ball(exteriors,"HerbBush",1.15,pos,C.Leaf,false)
  end
  local pos=(b*CFrame.new(side*61,0,54)).Position;tree(exteriors,pos.X,pos.Z,1.15,index)
 end
 local a=b:PointToWorldSpace(Vector3.new(0,-.32,-59));local to=Vector3.new(h.Foundation.Position.X<0 and -168 or 168,.18,a.Z);path(exteriors,Vector3.new(a.X,.18,a.Z),to,16)
end
-- Garden courts frame the central walk without blocking the clue stops.
local courts=folder("MapleGreen")
for _,side in ipairs({-1,1})do
 for _,z in ipairs({-150,150})do
  box(courts,"GardenBorder",{18,.25,38},{side*59,.15,z},C.Stone,false)
  box(courts,"PlantingBed",{16,.22,36},{side*59,.3,z},Color3.fromRGB(100,119,79),false)
  for j=-2,2 do
   ball(courts,"LowLavender",1.65,Vector3.new(side*59,1.5,z+j*6),j%2==0 and Color3.fromRGB(157,160,178)or C.LeafLight,false)
  end
 end
 for _,z in ipairs({-240,-25,245})do tree(courts,side*60,z,1.15,z)end
end
disc(courts,"FountainPlaza",21,.17,49,90,C.Path,true)
disc(courts,"FountainBasin",12,.45,49,90,C.Stone,true)
disc(courts,"FountainWater",10.6,.56,49,90,C.Water,false)
local column=box(courts,"FountainColumn",{1.7,3.8,1.7},{49,2.4,90},C.Cream,true)
disc(courts,"FountainBowl",4.3,4.35,49,90,C.Stone,false)
disc(courts,"FountainUpperWater",3.6,4.46,49,90,C.Water,false)
ball(courts,"FountainFinial",.65,Vector3.new(49,5.15,90),C.Cream,false)
bench(courts,CFrame.new(49,0,109))
bench(courts,CFrame.new(68,0,90)*CFrame.Angles(0,math.pi/2,0))
-- Willow Lake: shallow ornamental water with an accessible shoreline path.
local lake=folder("WillowLake")
local function triangle(parent,name,a,b,c,color)
 local ab,ac,bc=b-a,c-a,c-b
 if ab:Dot(ab)>ac:Dot(ac)and ab:Dot(ab)>bc:Dot(bc)then c,a=a,c
 elseif ac:Dot(ac)>bc:Dot(bc)then a,b=b,a end
 ab,ac,bc=b-a,c-a,c-b
 local right=ac:Cross(ab).Unit;local back=bc.Unit;local up=bc:Cross(right).Unit
 local height=math.abs(ab:Dot(up))
 local first=p(parent,name,Vector3.new(.12,height,math.abs(ab:Dot(back))),CFrame.fromMatrix((a+b)/2,right,up,back),color,false,nil,"WedgePart")
 local second=p(parent,name,Vector3.new(.12,height,math.abs(ac:Dot(back))),CFrame.fromMatrix((a+c)/2,-right,up,-back),color,false,nil,"WedgePart")
 first.CastShadow=false;second.CastShadow=false
end
local function capsule(name,r,y,color)
 local center=box(lake,name,{r*2,.12,140},{-565,y,90},color,false);center.CastShadow=false
 for _,endcap in ipairs({{20,math.pi},{160,0}})do
  local center=Vector3.new(-565,y,endcap[1])
  for i=0,23 do
   local a=endcap[2]+i*math.pi/24;local b=endcap[2]+(i+1)*math.pi/24
   triangle(lake,name,center,center+Vector3.new(math.cos(a)*r,0,math.sin(a)*r),center+Vector3.new(math.cos(b)*r,0,math.sin(b)*r),color)
  end
 end
end
capsule("Shore",76,.06,C.Stone)
capsule("Water",72,.2,C.Water)
path(lake,Vector3.new(-474,.17,-72),Vector3.new(-654,.17,-72),10)
path(lake,Vector3.new(-654,.17,-72),Vector3.new(-654,.17,250),10)
path(lake,Vector3.new(-654,.17,250),Vector3.new(-474,.17,250),10)
path(lake,Vector3.new(-474,.17,250),Vector3.new(-474,.17,-72),10)
path(lake,Vector3.new(-462,.17,0),Vector3.new(-474,.17,0),12)
box(lake,"ViewingDeck",{25,.3,20},{-493,.25,90},C.Wood,true)
for _,z in ipairs({-35,15,190,230})do tree(lake,-665,z,1.3,z);bench(lake,CFrame.new(-640,0,z)*CFrame.Angles(0,-math.pi/2,0))end
sign(lake,"WILLOW LAKE",-470,-90,math.pi/2)
-- Picnic meadow, framed by trees and a small open-sided timber pavilion.
local meadow=folder("PicnicMeadow")
path(meadow,Vector3.new(462,.17,0),Vector3.new(570,.17,0),12)
path(meadow,Vector3.new(570,.17,-140),Vector3.new(570,.17,180),10)
box(meadow,"PavilionDeck",{34,.4,26},{560,.2,92},C.Path,true)
for _,x in ipairs({545,575})do for _,z in ipairs({81,103})do box(meadow,"PavilionPost",{.7,11,.7},{x,5.5,z},C.Ink,true)end end
for _,side in ipairs({-1,1})do
 p(meadow,"PavilionRoof",Vector3.new(19,.35,29),CFrame.new(560+side*8.5,12.3,92)*CFrame.Angles(0,0,-side*.23),C.Ink,false)
end
for _,z in ipairs({-85,-25,90,150})do
 local x=z==90 and 560 or 606
 box(meadow,"PicnicTable",{7,.3,3.5},{x,2.7,z},C.Wood,true)
 for _,dx in ipairs({-2.5,2.5})do box(meadow,"TableLeg",{.3,2.5,2.8},{x+dx,1.3,z},C.Ink,true)end
 bench(meadow,CFrame.new(x,0,z-3.2)*CFrame.Angles(0,math.pi,0));bench(meadow,CFrame.new(x,0,z+3.2))
end
for i=1,12 do local a=i*math.pi/6;tree(meadow,570+math.cos(a)*84,40+math.sin(a)*175,1.3,i)end
sign(meadow,"PICNIC MEADOW",468,-22,-math.pi/2)
-- Orchard clearings at the southern edge; walking alleys remain open.
local orchard=folder("Orchard")
for _,side in ipairs({-1,1})do
 for x=260,380,40 do for z=418,458,40 do tree(orchard,side*x,z,.9,x+z)end end
 path(orchard,Vector3.new(side*250,.17,480),Vector3.new(side*408,.17,480),10)
 bench(orchard,CFrame.new(side*315,0,465));sign(orchard,"MAPLE ORCHARD",side*250,470)
end
-- Shops receive coherent storefronts and sidewalks; interaction counters stay intact.
local market=folder("Market")
box(market,"MarketPlaza",{248,.12,64},{0,.16,414},C.Path,true)
for _,shop in ipairs(w.Shops:GetChildren())do
 for _,v in ipairs(shop:GetChildren())do if v:IsA("BasePart")then
  if v.Name=="Back"or v.Name=="Wall"then v.Color=Color3.fromRGB(219,223,211);v.Material=Enum.Material.SmoothPlastic
  elseif v.Name=="Floor"then v.Color=C.Path;v.Material=Enum.Material.SmoothPlastic
  elseif v.Name=="Roof"then v.Color=C.Ink;v.Material=Enum.Material.SmoothPlastic
  elseif v.Name=="Awning"then v.Color=C.Ink;v.Material=Enum.Material.SmoothPlastic;v.Size=Vector3.new(120,.25,18);v.CFrame=CFrame.new(v.Position.X,12,426)*CFrame.Angles(math.rad(-10),0,0)
  elseif v.Name=="Sign"then v.CanCollide=false;v.CanQuery=false
  elseif v.Name=="Counter"then v.Color=C.Wood;v.Material=Enum.Material.SmoothPlastic
  end
 end end
 local center=shop.Floor.Position;local width=shop.Floor.Size.X
 box(market,"MarketApron",{width+8,.12,18},{center.X,.2,421},C.Path,true)
 for _,dx in ipairs({-width/2,width/2})do
  box(market,"ShopColumn",{.6,14,.6},{center.X+dx,7,434},C.Cream,false)
 end
end
-- Low hills and distant groves close the horizon with a consistent palette.
local edge=folder("BoundaryGroves")
for _,side in ipairs({-1,1})do
 for z=-510,510,85 do
  ball(edge,"MeadowHill",42,Vector3.new(side*693,-34,z),C.Grass,false)
  if z< -110 or z>280 then tree(edge,side*648,z,1.8,z)end
 end
end
for _,z in ipairs({-560,560})do for x=-600,600,100 do
 ball(edge,"MeadowHill",48,Vector3.new(x,-36,z),C.Grass,false);tree(edge,x,z-10*(z>0 and 1 or -1),1.8,x)
end end
sign(walks,"MAPLE GREEN",0,-350)
sign(walks,"MARKET STREET",0,365)
w:SetAttribute("DistrictDesign","garden-district-3")
return {AuthoredParts=count,Map=w.Map.VillageGround.Size,Areas={"Willow Lake","Picnic Meadow","Maple Orchard","Market Street"}}
