local Definitions=require(game.ReplicatedStorage.Neighborhood.Shared.ItemDefinitions)
local Factory={}
function Factory.Create(id)
 local def=assert(Definitions[id],"Unknown item definition")
 local model=Instance.new("Model");model.Name=id
 local root=Instance.new("Part");root.Name="Root";root.Size=Vector3.new(1,1,1);root.Transparency=1;root.CanCollide=false;root.Anchored=true;root.Parent=model;model.PrimaryPart=root
 local gold=id=="GoldenToilet" or id=="GoldenTrashCan"
 local function piece(name,size,pos,color,shape)
  local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=CFrame.new(pos);p.Color=color or def.Color;p.Material=gold and Enum.Material.Metal or Enum.Material.SmoothPlastic;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
  if shape then p.Shape=shape end;p.Parent=model;return p
 end
 local dark=Color3.fromRGB(36,53,54);local cream=Color3.fromRGB(244,233,204)
 if id=="TrailCompass"then
  piece("Base",Vector3.new(2.6,.4,2.6),Vector3.new(0,.2,0),dark)
  local face=piece("BrassDial",Vector3.new(.4,2.4,2.4),Vector3.new(0,.6,0),nil,Enum.PartType.Cylinder);face.CFrame*=CFrame.Angles(0,0,math.pi/2);face.Material=Enum.Material.Metal
  local needle=piece("Needle",Vector3.new(.18,.12,1.6),Vector3.new(0,.9,0),Color3.fromRGB(172,72,58));needle.CFrame*=CFrame.Angles(0,.5,0)
 elseif id=="StoryOwl"then
  piece("Perch",Vector3.new(2.6,.35,2),Vector3.new(0,.2,0),dark)
  piece("Body",Vector3.new(1.8,2.5,1.6),Vector3.new(0,1.6,0),nil,Enum.PartType.Ball)
  for _,x in ipairs({-.45,.45})do
   piece("EyeRing",Vector3.new(.8,.8,.3),Vector3.new(x,2.3,-.65),cream,Enum.PartType.Ball)
   piece("Eye",Vector3.new(.28,.28,.2),Vector3.new(x,2.3,-.85),dark,Enum.PartType.Ball)
  end
  piece("Beak",Vector3.new(.22,.4,.3),Vector3.new(0,1.9,-.9),Color3.fromRGB(214,169,75))
 elseif id=="NeighborLantern"then
  piece("Base",Vector3.new(2.2,.3,2.2),Vector3.new(0,.2,0))
  for _,x in ipairs({-.8,.8})do for _,z in ipairs({-.8,.8})do piece("Frame",Vector3.new(.15,2.5,.15),Vector3.new(x,1.6,z))end end
  local glow=piece("WarmGlow",Vector3.new(1,1.8,1),Vector3.new(0,1.5,0),cream);glow.Material=Enum.Material.Neon
  local light=Instance.new("PointLight");light.Color=cream;light.Brightness=.6;light.Range=9;light.Parent=glow
  piece("Top",Vector3.new(2.2,.35,2.2),Vector3.new(0,3,0))
  piece("Handle",Vector3.new(1,.45,.2),Vector3.new(0,3.35,0))
 elseif id=="GoldenToilet" then
  piece("Pedestal",Vector3.new(3.2,0.7,4),Vector3.new(0,0.35,0))
  piece("Stem",Vector3.new(2,2.1,2.5),Vector3.new(0,1.4,0))
  piece("Bowl",Vector3.new(4.8,2,5.6),Vector3.new(0,2.6,-0.4),nil,Enum.PartType.Ball)
  piece("Seat",Vector3.new(4.3,0.3,4.5),Vector3.new(0,3.35,-0.8),cream,Enum.PartType.Ball)
  piece("SeatOpening",Vector3.new(2.7,0.32,3),Vector3.new(0,3.4,-0.8),dark,Enum.PartType.Ball)
  piece("Tank",Vector3.new(4,4,1.7),Vector3.new(0,3.4,2.1))
  piece("TankLid",Vector3.new(4.3,0.35,2),Vector3.new(0,5.6,2.1))
  piece("Handle",Vector3.new(0.7,0.25,0.4),Vector3.new(1.2,4.8,1.1),cream)
  piece("CrownBase",Vector3.new(2,0.3,1),Vector3.new(0,6,2.1))
  for x=-1,1 do piece("CrownPoint",Vector3.new(0.35,0.7+0.3*(1-math.abs(x)),0.7),Vector3.new(x*0.75,6.35,2.1)) end
 elseif id=="BasicChair" then
  piece("Seat",Vector3.new(3,0.5,3),Vector3.new(0,2,0));piece("Back",Vector3.new(3,3,0.45),Vector3.new(0,3.5,1.25))
  for _,x in ipairs({-1.1,1.1}) do for _,z in ipairs({-1.1,1.1}) do piece("Leg",Vector3.new(0.4,2,0.4),Vector3.new(x,1,z)) end end
 elseif id=="Lamp" then
  piece("Base",Vector3.new(2.2,0.3,2.2),Vector3.new(0,0.15,0),dark);piece("Stem",Vector3.new(0.3,3.3,0.3),Vector3.new(0,1.9,0),dark);piece("Shade",Vector3.new(2.8,1.5,2.8),Vector3.new(0,3.9,0),cream)
 elseif id=="Television" or id=="Microwave" then
  local tv=id=="Television";piece("Body",Vector3.new(tv and 5 or 3.8,tv and 3.3 or 2.3,tv and 0.6 or 2.5),Vector3.new(0,tv and 2.5 or 1.2,0))
  piece("Screen",Vector3.new(tv and 4.5 or 2.5,tv and 2.8 or 1.6,0.1),Vector3.new(tv and 0 or -0.4,tv and 2.5 or 1.2,tv and -0.36 or -1.3),dark)
  if tv then piece("Stand",Vector3.new(2,0.2,1.8),Vector3.new(0,0.1,0));piece("Stem",Vector3.new(0.5,1,0.5),Vector3.new(0,0.5,0)) end
 elseif id=="GardenGnome" or id=="MoonGnome" then
  piece("Body",Vector3.new(1.8,2,1.6),Vector3.new(0,1.2,0),Color3.fromRGB(69,117,158),Enum.PartType.Ball)
  piece("Head",Vector3.new(1.5,1.5,1.5),Vector3.new(0,2.6,0),cream,Enum.PartType.Ball)
  piece("Nose",Vector3.new(0.45,0.45,0.5),Vector3.new(0,2.5,-0.8),cream,Enum.PartType.Ball)
  piece("Hat",Vector3.new(1.4,1.8,1.4),Vector3.new(0,3.7,0),nil,Enum.PartType.Ball)
 elseif id=="LawnFlamingo" then
  for _,x in ipairs({-0.4,0.4}) do piece("Leg",Vector3.new(0.15,2.5,0.15),Vector3.new(x,1.25,0),dark) end
  piece("Body",Vector3.new(2,1.6,2.7),Vector3.new(0,3,0),nil,Enum.PartType.Ball);piece("Neck",Vector3.new(0.5,2,0.5),Vector3.new(0,4,-0.9));piece("Head",Vector3.new(1,0.8,1.2),Vector3.new(0,5,-1.1),nil,Enum.PartType.Ball);piece("Beak",Vector3.new(0.45,0.45,0.8),Vector3.new(0,4.85,-1.9),dark)
 elseif id=="FancyVase" then
  piece("Body",Vector3.new(2.5,3.2,2.5),Vector3.new(0,1.6,0),nil,Enum.PartType.Ball);piece("Neck",Vector3.new(1.2,1,1.2),Vector3.new(0,3.5,0));piece("Rim",Vector3.new(1.6,0.3,1.6),Vector3.new(0,4,0),cream)
 elseif id=="SuspiciousPainting" then
  piece("Frame",Vector3.new(4,5,0.4),Vector3.new(0,2.5,0),Color3.fromRGB(151,105,65));piece("Canvas",Vector3.new(3.5,4.5,0.1),Vector3.new(0,2.5,-0.25))
  for _,x in ipairs({-0.7,0.7}) do piece("Eye",Vector3.new(0.8,0.4,0.15),Vector3.new(x,3.2,-0.4),cream,Enum.PartType.Ball);piece("Pupil",Vector3.new(0.22,0.3,0.17),Vector3.new(x,3.2,-0.5),dark) end
 elseif id=="GoldenTrashCan" then
  piece("Bin",Vector3.new(3,4,3),Vector3.new(0,2,0));piece("Lid",Vector3.new(3.3,0.4,3.3),Vector3.new(0,4.2,0));piece("Handle",Vector3.new(1.2,0.35,0.4),Vector3.new(0,4.55,0))
 end
 return model
end
return Factory
