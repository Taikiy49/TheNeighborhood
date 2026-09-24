local Space=require(game.ReplicatedStorage.Neighborhood.Shared.WorldSpace)
local D=require(game.ReplicatedStorage.Neighborhood.Shared.LifeDefinitions)
local R=require(game.ReplicatedStorage.Neighborhood.Shared.LifeRules)
local F={}
local cream=Color3.fromRGB(236,233,215);local timber=Color3.fromRGB(160,128,89);local green=Color3.fromRGB(119,147,135)
function F.Part(parent,name,size,cf,color,material)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color or cream;p.Material=material or Enum.Material.SmoothPlastic;p.Anchored=true;p.CanTouch=false;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent;return p
end
function F.Sign(part,text)
 local gui=Instance.new("SurfaceGui");gui.Face=Enum.NormalId.Front;gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud;gui.PixelsPerStud=50;gui.LightInfluence=.15;gui.Parent=part
 local label=Instance.new("TextLabel");label.Size=UDim2.fromScale(.9,.84);label.Position=UDim2.fromScale(.05,.08);label.BackgroundTransparency=1;label.TextColor3=cream;label.Font=Enum.Font.GothamMedium;label.TextScaled=true;label.TextWrapped=true;label.Text=text;label.Parent=gui
end
function F.Prompt(part,view,arg)
 part:SetAttribute("Action","LifeStation");part:SetAttribute("LifeView",view);part:SetAttribute("LifeArg",arg or "")
 local p=Instance.new("ProximityPrompt");p.Style=Enum.ProximityPromptStyle.Custom;p.ActionText="Explore";p.ObjectText=part.Name;p.MaxActivationDistance=10;p.RequiresLineOfSight=false;p:SetAttribute("Action","LifeStation");p.Parent=part
end
function F.Flower(parent,cf,color,hybrid)
 F.Part(parent,"Stem",Vector3.new(.13,1.3,.13),cf*CFrame.new(0,.65,0),green)
 for i=1,5 do local a=i*math.pi*2/5;local p=F.Part(parent,"Petal",Vector3.new(.6,.2,.6),cf*CFrame.new(math.cos(a)*.32,1.35,math.sin(a)*.32),color);p.Shape=Enum.PartType.Ball;p.CanCollide=false end
 local p=F.Part(parent,"Pollen",Vector3.new(.32,.28,.32),cf*CFrame.new(0,1.45,0),hybrid and Color3.fromRGB(229,136,155)or Color3.fromRGB(233,175,57));p.Shape=Enum.PartType.Ball;p.CanCollide=false
end
function F.Home(house,life,now)
 local old=house:FindFirstChild("NeighborhoodLife");if old then old:Destroy()end
 local m=Instance.new("Model");m.Name="NeighborhoodLife";m.ModelStreamingMode=Enum.ModelStreamingMode.Atomic;m.Parent=house
 local basis=house.Foundation.CFrame;local accent=D.Styles[life.Style].Color
 local anchor
 local function part(name,size,x,y,z,color,mat)local pos=Vector3.new(x,y,z);pos=anchor and Space.Point(anchor)+(pos-anchor)or Space.Point(pos);return F.Part(m,name,size,basis*CFrame.new(pos),color,mat)end
 for i=1,4 do
  local x,z=table.unpack(D.Beds[i]);anchor=Vector3.new(x,0,z);local bed=part("GardenBed"..i,Vector3.new(2.4,.8,3),x,1,z,accent);F.Prompt(bed,"LifeGarden",tostring(i))
  part("Soil",Vector3.new(2.1,.15,2.7),x,1.47,z,Color3.fromRGB(72,55,41),Enum.Material.Ground)
  local b=life.Beds[tostring(i)];if b then
   if R.Ready(b,now)then for j=1,3 do F.Flower(m,basis*CFrame.new(Space.Point(Vector3.new(x,1.6,z))+Vector3.new((j-2)*.6,0,0)),D.Flowers[b.Kind].Color,b.Hybrid)end
   else local sprout=part("Sprout",Vector3.new(.4,.5,.4),x,1.8,z,green);sprout.Shape=Enum.PartType.Ball;sprout.CanCollide=false end
  end
 end
 anchor=nil
 for z=14,25,3 do part("GardenSteppingStone",Vector3.new(2.2,.12,2),20,.15,z,Color3.fromRGB(183,173,153),Enum.Material.SmoothPlastic)end
 anchor=Vector3.new(21,0,11)
 local counter=part("LifeCounter",Vector3.new(5,2.5,2),21,1.5,11,timber);F.Prompt(counter,"LifeBusiness")
 for _,x in ipairs({18.5,23.5})do part("AwningPost",Vector3.new(.2,6,.2),x,3.2,11,cream)end
 for i=1,6 do part("Awning",Vector3.new(.9,.18,3.5),18.3+i*.85,6.3,11,i%2==0 and cream or accent)end
 local sign=part("BusinessSign",Vector3.new(5,1.4,.2),21,4.8,10.6,green);F.Sign(sign,D.Businesses[life.Business]and D.Businesses[life.Business].Name or "Garden workshop")
 if life.OrderStep>0 then
  local torso=part("Customer",Vector3.new(1.6,2,1),21,2.5,7.8,accent);torso.CanCollide=false
  local head=part("CustomerHead",Vector3.new(1.2,1.2,1.2),21,4.1,7.8,Color3.fromRGB(190,144,109));head.Shape=Enum.PartType.Ball;head.CanCollide=false
  for _,x in ipairs({20.5,21.5})do local leg=part("CustomerLeg",Vector3.new(.5,1.4,.6),x,1,7.8,green);leg.CanCollide=false end
 end
 anchor=nil
 local tour=part("TourSign",Vector3.new(4,2,.2),8,3,-21,green);F.Sign(tour,life.TourOpen and "WELCOME\nHome tour"or "Home gallery");F.Prompt(tour,"LifeTours");anchor=Vector3.new(8,0,-21);local post=part("TourSignPost",Vector3.new(.3,3,.3),8,1,-20.7,green);post.CanCollide=false;post.CanQuery=false;anchor=nil
 if life.Banners[life.Theme]then local banner=part("ChallengeBanner",Vector3.new(2,3,.12),11,4,-14,accent);F.Sign(banner,life.Theme)end
 for i,id in ipairs(D.BlueprintOrder)do if life.Blueprints[id]then
  local x=14;local z=18+i*6;anchor=Vector3.new(x,0,z)
  if id=="WindChime"then
   part(id,Vector3.new(2,.2,.5),x,4,z,timber);for j=1,4 do part("Chime",Vector3.new(.15,1+j*.25,.15),x-1+j*.4,3,z,cream,Enum.Material.Metal)end
  elseif id=="Birdhouse"then
   part("BirdPost",Vector3.new(.3,3,.3),x,2,z,timber);part(id,Vector3.new(1.6,1.8,1.3),x,4,z,accent);part("BirdRoof",Vector3.new(2,.25,1.7),x,5,z,cream)
   local hole=part("BirdOpening",Vector3.new(.5,.5,.1),x,4,z-.7,Color3.fromRGB(40,42,34));hole.Shape=Enum.PartType.Ball
  elseif id=="TeaTable"then
   part(id,Vector3.new(2.5,.3,2.5),x,2.5,z,timber);part("TableFoot",Vector3.new(.4,2,.4),x,1.3,z,cream)
   part("Teacup",Vector3.new(.5,.45,.5),x,2.9,z,accent,Enum.Material.CeramicTiles)
  else part("LanternPost",Vector3.new(.25,4,.25),x,2.5,z,timber);part(id,Vector3.new(1,1.2,1),x,4.7,z,Color3.fromRGB(242,203,119),Enum.Material.Neon)end
 end end
 if life.Equipped~=""then
  anchor=Vector3.new(6,0,-14)
  local season,kind=life.Equipped:match("^(%a+):(%a+)$");local color=D.SeasonColors[season]
  if kind=="Wreath"then for i=1,10 do local a=i*math.pi/5;local leaf=part("FestivalWreath",Vector3.new(.6,.6,.25),6+math.cos(a),5+math.sin(a),-14,color);leaf.Shape=Enum.PartType.Ball;leaf.CanCollide=false end
  elseif kind=="Flag"then local flag=part("FestivalFlag",Vector3.new(2.5,2,.12),6,5,-14,color);F.Sign(flag,season)
  else part("FestivalLantern",Vector3.new(1,1.5,1),6,5,-14,color,Enum.Material.Neon)end
 end
 return m
end
function F.Project(parent,id,amount)
 local d=D.Projects[id];local old=parent:FindFirstChild(id);if old then old:Destroy()end
 local m=Instance.new("Model");m.Name=id;m.Parent=parent;local cf=CFrame.new(Space.Point(d.Position))*CFrame.Angles(0,id=="Greenhouse"and 0 or math.pi,0);local width=id=="Greenhouse"and 12 or 18
 local function p(n,s,x,y,z,c,mat)return F.Part(m,n,s,cf*CFrame.new(x,y,z),c,mat)end
 p("Deck",Vector3.new(width,.4,14),0,-.6,0,timber)
 for _,x in ipairs({-width/2,width/2})do for _,z in ipairs({-6.5,6.5})do p("Pillar",Vector3.new(.5,8,.5),x,3,z,cream)end end
 local stage=math.floor(amount/d.Goal*3)
 if stage>=1 then p("Back",Vector3.new(width,7,.3),0,3,6.5,green)end
 if stage>=2 then
  for _,side in ipairs({-1,1})do local r=p("PitchedRoof",Vector3.new(width/2+1,.35,16),side*width/4,7.2,0,Color3.fromRGB(68,89,90),Enum.Material.SmoothPlastic);r.CFrame*=CFrame.Angles(0,0,side*math.rad(-18))end
 end
 local station=p("Renovation_"..id,Vector3.new(5,2.5,2),0,1,-4,green);F.Prompt(station,"LifeProjects",id)
 local sign=p("Sign",Vector3.new(width-2,1.4,.2),0,5.8,-8.2,green);F.Sign(sign,d.Name.." · "..amount.."/"..d.Goal)
 if amount>=d.Goal then
  for _,x in ipairs({-3,3})do p("Bench",Vector3.new(3,.5,2),x,.9,2,timber);for _,z in ipairs({1.3,2.7})do p("BenchLeg",Vector3.new(.25,1,.25),x,.3,z,cream)end end
  for i=1,3 do F.Flower(m,cf*CFrame.new(-3+i*1.5,2.3,-4),D.Flowers.Daisy.Color,false)end
 end
 Space.Stretch(m,cf)
 return station
end
function F.World(parent,season)
 local old=parent:FindFirstChild("NeighborhoodLife");if old then old:Destroy()end
 local m=Instance.new("Folder");m.Name="NeighborhoodLife";m.Parent=parent
 local stops={};for i,authoredPos in ipairs(D.Stops)do local pos=Space.Point(authoredPos)
  F.Part(m,"LanternPost",Vector3.new(.3,5,.3),CFrame.new(pos+Vector3.new(0,.5,0)),timber)
  local stop=F.Part(m,"ParkLantern"..i,Vector3.new(2.4,1.8,.4),CFrame.new(pos+Vector3.new(0,2,0)),D.SeasonColors[season]);F.Sign(stop,tostring(i).." · "..season);F.Prompt(stop,"LifeStop",tostring(i));stops[tostring(i)]=stop
 end
 -- Open plaza paths keep the new north pavilions connected to the cross street.
 for _,x in ipairs({-22,22})do F.Part(m,"PlazaPath",Space.Point(Vector3.new(6,.15,26)),Space.Frame(x,.12,-146),Color3.fromRGB(183,173,153),Enum.Material.SmoothPlastic)end
 return m,stops
end
return F
