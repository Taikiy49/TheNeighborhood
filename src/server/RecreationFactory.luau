local D=require(game.ReplicatedStorage.Neighborhood.Shared.RecreationDefinitions)
local F={}
local ink=Color3.fromRGB(47,70,63);local cream=Color3.fromRGB(233,226,204);local wood=Color3.fromRGB(163,125,86)
function F.Part(parent,name,size,cf,color,solid,class)
 local p=Instance.new(class or "Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color or cream;p.Anchored=true;p.CanCollide=solid~=false;p.CanTouch=false;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Material=Enum.Material.SmoothPlastic;p.Parent=parent;return p
end
function F.Sign(p,text)
 local gui=Instance.new("SurfaceGui");gui.Face=Enum.NormalId.Front;gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud;gui.PixelsPerStud=32;gui.LightInfluence=.25;gui.Parent=p
 local label=Instance.new("TextLabel");label.Size=UDim2.fromScale(.92,.84);label.Position=UDim2.fromScale(.04,.08);label.BackgroundTransparency=1;label.TextColor3=cream;label.TextScaled=true;label.TextWrapped=true;label.Font=Enum.Font.GothamMedium;label.Text=text;label.Parent=gui
end
function F.Build(w)
 local prior=w:FindFirstChild("Recreation");if prior and prior:GetAttribute("Version")==D.Version then return prior end
 if prior then prior:Destroy()end
 local root=Instance.new("Folder");root.Name="Recreation";root.Parent=w
 local roads=Instance.new("Folder");roads.Name="RoadNetwork";roads.Parent=root
 local asphalt=Color3.fromRGB(76,86,84)
 local function road(name,a,b)
  local delta=b-a;local p=F.Part(roads,name,Vector3.new(36,.18,delta.Magnitude+36),CFrame.lookAt((a+b)/2,b),asphalt);p.Material=Enum.Material.Asphalt
  for t=27,delta.Magnitude-27,24 do local c=a+delta.Unit*t
   F.Part(roads,"CenterDash",Vector3.new(.4,.025,9),CFrame.lookAt(c+Vector3.new(0,.11,0),c+delta.Unit+Vector3.new(0,.11,0)),cream,false)
  end
 end
 local corners={Vector3.new(-770,.08,-640),Vector3.new(770,.08,-640),Vector3.new(770,.08,640),Vector3.new(-770,.08,640)}
 if not w:GetAttribute("CozyLayout")then
 for i=1,4 do road("ValleyCircuit"..i,corners[i],corners[i%4+1])end
 -- Southbound Maple Street joins Cross Street before the shops. Do not extend through them.
 for _,x in ipairs({-126,126})do road("MapleLink",Vector3.new(x,.08,-399),Vector3.new(x,.08,-640))end
 for _,s in ipairs({-1,1})do for _,z in ipairs({-381,381})do road("CrossLink",Vector3.new(s*138,.08,z),Vector3.new(s*770,.08,z))end end
 local streetTrees=w.ArtDirection.GardenDistrict.StreetTrees
 for _,tree in ipairs(streetTrees:GetChildren())do local trunk=tree:FindFirstChild("Trunk");if trunk and math.abs(math.abs(trunk.Position.Z)-381)<16 and math.abs(trunk.Position.X)>160 then tree:PivotTo(tree:GetPivot()+Vector3.new(0,0,trunk.Position.Z>0 and 36 or -36))end end
 for i=1,4 do
  local a,b=corners[i],corners[i%4+1];local delta=b-a;local outward=Vector3.new((a+b).X,0,(a+b).Z).Unit
  local sidewalk=F.Part(roads,"CircuitFootpath",Vector3.new(8,.14,delta.Magnitude+44),CFrame.lookAt((a+b)/2+outward*24+Vector3.new(0,.08,0),b+outward*24+Vector3.new(0,.08,0)),cream)
  sidewalk:SetAttribute("Accessible",true)
 end
 -- Move only the enclosing landscape outward; keep homes, saved coordinates and district paths intact.
 local valley=w:FindFirstChild("ValleyBackdrop")
 if valley and not valley:GetAttribute("RecreationClearance")then
  for _,p in ipairs(valley:GetChildren())do if p:IsA("BasePart")and p.Name~="ValleyFloor"then
   local factor=p.Name=="GraniteRidge"and 1.25 or p.Name=="DistantPeak"and 1.12 or 1.35
   p.CFrame+=Vector3.new(p.Position.X*(factor-1),0,p.Position.Z*(factor-1))
  end end
  valley:SetAttribute("RecreationClearance",true)
 end
 -- Trees/lamps occupy verges, with clear intersections and vehicle turning room.
 for _,z in ipairs({-640,640})do for x=-690,690,60 do if math.abs(math.abs(x)-126)>40 then
  local post=F.Part(roads,"CircuitLamp",Vector3.new(.4,10,.4),CFrame.new(x,5,z+(z>0 and 25 or -25)),ink,false)
  local glass=F.Part(roads,"Lantern",Vector3.new(1.1,1.3,1.1),post.CFrame*CFrame.new(0,5,0),cream,false)
  local light=Instance.new("PointLight");light.Range=24;light.Brightness=.5;light.Color=Color3.fromRGB(255,228,185);light.Parent=glass
 end end end
 end
 local function walk(a,b,width)local delta=b-a;if delta.Magnitude>.1 then F.Part(root,"ConnectingPath",Vector3.new(width,.12,delta.Magnitude),CFrame.lookAt((a+b)/2,b),cream)end end
 for zi,zone in ipairs(D.Zones)do
  local z=Instance.new("Model");z.Name=zone.Id;z.ModelStreamingMode=Enum.ModelStreamingMode.Atomic;z.Parent=root
  local center=zone.Position
  if zone.Id=="Meadow"then
   walk(Vector3.new(219,.2,0),Vector3.new(294,.2,0),6)
   local board=F.Part(z,"Welcome",Vector3.new(10,3,.3),CFrame.new(231,6,-9),ink,false);F.Sign(board,"MEADOW TRIALS\nBalance · Sprint · Ride")
   F.Part(z,"SignPost",Vector3.new(.4,5,.4),CFrame.new(231,2.5,-8.8),wood,false)
  end
 end
 for id,d in pairs(D.Activities)do
  local m=Instance.new("Model");m.Name=id;m:SetAttribute("Kind",d.Kind);m.Parent=root[d.Zone]
  local cf=CFrame.new(d.Position)
  local function p(name,size,x,y,z,color,solid,class)return F.Part(m,name,size,cf*CFrame.new(x,y,z),color,solid,class)end
  if d.Kind=="Bowl" or d.Kind=="Sprint" or d.Kind=="Domino" then p("ActivityPad",Vector3.new(13,.12,23),0,.2,0,Color3.fromRGB(185,179,151)) end
  local button=p("Interact",Vector3.new(2,1.4,1.5),-10,1.5,-8,ink)
  button:SetAttribute("Action","Recreation");button:SetAttribute("ActivityId",id)
  local prompt=Instance.new("ProximityPrompt");prompt.Style=Enum.ProximityPromptStyle.Custom;prompt.ObjectText=d.Name;prompt.ActionText=({Toss="Grab toy",Bowl="Roll ball",Ride="Ride",Bounce="Bounce",Balance="Start trail",Sprint="Start sprint",Lantern="Change colors",Water="Water flowers",Dig="Dig",Domino="Topple / reset"})[d.Kind];prompt.RequiresLineOfSight=false;prompt.MaxActivationDistance=10;prompt:SetAttribute("Action","Recreation");prompt.Parent=button
  local title=p("ActivitySign",Vector3.new(6,1.4,.2),-8,3.4,-8,ink,false);F.Sign(title,d.Kind=="Toss"and "Free toys"or d.Name:gsub('^%w+ ',''))
  p("SignSupport",Vector3.new(.22,3,.22),-8,1.7,-7.7,wood,false)
  if d.Kind=="Toss"then
   p("ToyShelf",Vector3.new(8,.4,3),0,2,0,wood)
   for n=-1,1 do local toy=p("DisplayToy",Vector3.new(1.6,1.6,1.6),n*2.3,3,0,d.Color,false);toy.Shape=d.Variant%3==0 and Enum.PartType.Block or Enum.PartType.Ball end
   local target=p("Target",Vector3.new(5,.4,5),6,.6,5,cream);target.Shape=Enum.PartType.Cylinder;target.CFrame*=CFrame.Angles(0,0,math.pi/2)
  elseif d.Kind=="Bowl"then
   p("Lane",Vector3.new(7,.18,18),0,.4,0,wood)
   for i=1,6 do local pin=p("Pin"..i,Vector3.new(.65,2,.65),(i%3-1)*1.5,1.55,4+math.floor((i-1)/3)*1.6,cream);pin.Shape=Enum.PartType.Cylinder;pin.CFrame*=CFrame.Angles(0,0,math.pi/2);pin.Size=Vector3.new(2,.65,.65) end
  elseif d.Kind=="Ride"then
   local disc=p("RideBase",Vector3.new(.5,15,15),0,.7,0,wood);disc.Shape=Enum.PartType.Cylinder;disc.CFrame*=CFrame.Angles(0,0,math.pi/2)
   p("Mast",Vector3.new(.5,4,.5),0,2,0,ink)
   local seat=p("RideSeat",Vector3.new(3,.5,3),5,2.6,0,d.Color,true,"Seat");seat.Disabled=true
   p("RideBack",Vector3.new(3,2,.3),5,3.7,1.3,d.Color,false)
  elseif d.Kind=="Bounce"then
   local pad=p("Spring",Vector3.new(.7,10,10),0,.8,0,ink);pad.Shape=Enum.PartType.Cylinder;pad.CFrame*=CFrame.Angles(0,0,math.pi/2)
   for _,x in ipairs({-4,4})do for _,z in ipairs({-4,4})do p("SpringFoot",Vector3.new(.4,1,.4),x,.5,z,d.Color)end end
  elseif d.Kind=="Balance"or d.Kind=="Sprint"then
   p("Start",Vector3.new(4,.2,3),0,.45,-8,cream)
   p("Finish",Vector3.new(5,.2,3),0,.45,8,ink)
   if d.Kind=="Balance"then for i=1,5 do p("BalanceStep",Vector3.new(2.8,1+i%2*.6,3),math.sin(i+d.Variant)*2,1,-7+i*2.4,wood)end
   else for _,x in ipairs({-3,3})do p("LaneEdge",Vector3.new(.2,.1,16),x,.4,0,cream,false)end end
  elseif d.Kind=="Lantern"then
   for i=1,3 do p("LampPost",Vector3.new(.3,5,.3),(i-2)*4,2.5,0,ink);local lamp=p("Glow"..i,Vector3.new(1.6,2,1.6),(i-2)*4,5,0,d.Color,false);local light=Instance.new("PointLight");light.Range=12;light.Brightness=.6;light.Parent=lamp end
  elseif d.Kind=="Water"then
   p("Planter",Vector3.new(10,1,6),0,.6,0,wood);p("Soil",Vector3.new(9,.2,5),0,1.2,0,Color3.fromRGB(83,71,56))
   for i=1,5 do p("Stem"..i,Vector3.new(.2,1,.2),(i-3)*1.5,1.8,0,ink,false);local b=p("Bloom"..i,Vector3.new(.8,.8,.8),(i-3)*1.5,2.4,0,d.Color,false);b.Shape=Enum.PartType.Ball end
  elseif d.Kind=="Dig"then
   p("SandPatch",Vector3.new(10,.3,8),0,.5,0,Color3.fromRGB(217,196,151))
   local gem=p("Treasure",Vector3.new(1.4,1.4,1.4),0,1.5,0,d.Color,false);gem.Shape=Enum.PartType.Ball;gem.Transparency=1
  elseif d.Kind=="Domino"then
   for i=1,8 do p("Domino"..i,Vector3.new(2.5,3,.45),0,1.85,-7+i*1.6,i%2==0 and cream or d.Color)end
  end
 end
 root:SetAttribute("Version",D.Version);root:SetAttribute("ActivityCount",D.Count)
 return root
end
return F
