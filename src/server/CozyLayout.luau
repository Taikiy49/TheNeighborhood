-- Idempotent migration from the authored enlarged district to compact, avatar-scale homes.
local M={}
local ratio=1.4/3
local function scaled(v)return Vector3.new(v.X*ratio,v.Y,v.Z*ratio)end
local function part(parent,name,size,cf,color,solid,class)
 local p=Instance.new(class or "Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color;p.Material=Enum.Material.SmoothPlastic;p.Anchored=true;p.CanCollide=solid~=false;p.CanTouch=false;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent;return p
end
function M.Apply(w)
 if w:GetAttribute("CozyLayout")=="cozy-1"then return end
 assert(w:GetAttribute("HorizontalScale")==3,"Expected expanded district input")
 for _,name in ipairs({"Recreation","Wayfinding"})do local old=w:FindFirstChild(name);if old then old:Destroy()end end
 for _,h in ipairs(w.Houses:GetChildren())do
  for _,name in ipairs({"BuiltInInterior","FurnishedRooms","EntranceJoinery"})do local old=h:FindFirstChild(name);if old then old:Destroy()end end
 end
 local preserved={}
 for _,m in ipairs(w:GetDescendants())do if m:IsA("Model")and(m.Name=="Mailbox"or m.Name=="ParkBench"or m.Parent==w.GuideCharacters)then
  local center=m:GetPivot().Position
  for _,p in ipairs(m:GetDescendants())do if p:IsA("BasePart")then preserved[p]={Size=p.Size,CFrame=p.CFrame+(scaled(center)-center)}end end
 end end
 for _,p in ipairs(w:GetDescendants())do if p:IsA("BasePart")then
  local cf=p.CFrame;local x,y,z=scaled(cf.RightVector),scaled(cf.UpVector),scaled(cf.ZVector);local right=x.Unit;local up=z:Cross(x).Unit;local back=right:Cross(up)
  p.Size=Vector3.new(p.Size.X*x.Magnitude,p.Size.Y*math.abs(y:Dot(up)),p.Size.Z*math.abs(z:Dot(back)))
  p.CFrame=CFrame.fromMatrix(scaled(cf.Position),right,up,back)
 end end
 for p,v in pairs(preserved)do p.Size=v.Size;p.CFrame=v.CFrame end
 local cream=Color3.fromRGB(244,245,236);local sage=Color3.fromRGB(119,147,135);local oak=Color3.fromRGB(177,145,107);local ink=Color3.fromRGB(54,70,66)
 for index,h in ipairs(w.Houses:GetChildren())do
  local b=h.Foundation.CFrame
  -- Bring the shell down to cottage height; furniture below is rebuilt at human scale.
  for _,p in ipairs(h:GetDescendants())do if p:IsA("BasePart")and not p:IsDescendantOf(h.Mailbox)and p.Name~="Foundation"and p.Name~="Floor"then
   local cf=b:ToObjectSpace(p.CFrame);local pos=cf.Position;local r,u,z=cf.RightVector,cf.UpVector,cf.ZVector
   local function short(v)return Vector3.new(v.X,v.Y/1.3,v.Z)end
   local x,y,zz=short(r),short(u),short(z);local right=x.Unit;local up=zz:Cross(x).Unit;local back=right:Cross(up)
   p.Size=Vector3.new(p.Size.X*x.Magnitude,p.Size.Y*math.abs(y:Dot(up)),p.Size.Z*math.abs(zz:Dot(back)))
   p.CFrame=b*CFrame.fromMatrix(Vector3.new(pos.X,.7+(pos.Y-.7)/1.3,pos.Z),right,up,back)
  end end
  h:SetAttribute("InteriorHeightScale",1)
  h.Arrival.Size=Vector3.one;h.Arrival.CFrame=b*CFrame.new(0,3.5,-31)*CFrame.Angles(0,math.pi,0)
  h.Lock.Size=Vector3.new(.45,.8,.5);h.Doorbell.Size=Vector3.new(.6,.9,.5);h.AddressPlaque.Size=Vector3.new(3,1,.2)
  h.AddressPlaque.CFrame=b*CFrame.new(0,9.5,-26.1)
  h.SecurityCamera.Size=Vector3.new(.8,.7,1.4);h.CameraLens.Size=Vector3.new(.45,.4,.1)
  h.SecurityCamera.CFrame=CFrame.lookAt(b:PointToWorldSpace(Vector3.new(17,8,-13)),b:PointToWorldSpace(Vector3.new(0,3,-2)));h.CameraLens.CFrame=h.SecurityCamera.CFrame*CFrame.new(0,0,-.75)
  local interior=Instance.new("Folder");interior.Name="BuiltInInterior";interior.Parent=h
  local function p(n,s,x,y,z,c,solid,class)return part(interior,n,Vector3.new(table.unpack(s)),b*CFrame.new(x,y,z),c,solid,class)end
  h.Floor.Color=oak;h.Floor.Material=Enum.Material.SmoothPlastic;h.Ceiling.Color=cream
  -- A broad center aisle joins the front door, six display slots and future rear expansion.
  for _,s in ipairs({-1,1})do p("HallPartition",{.25,8,13},s*4.8,4.7,10,cream)end
  p("BedroomRug",{11,.04,11},-12,.73,10,sage,false)
  p("BedFrame",{6.2,.6,7.5},-12,1.1,11,oak)
  p("Mattress",{6,.7,7.1},-12,1.75,11,cream)
  p("Quilt",{6,.18,4.8},-12,2.19,9.9,sage,false)
  p("Headboard",{6.4,3,.25},-12,2.2,14.8,oak)
  for _,x in ipairs({-13.6,-10.4})do p("Pillow",{2.4,.3,1.5},x,2.3,13.5,cream,false)end
  p("KitchenCabinets",{11.7,2.7,2.8},12,2.05,14.5,sage)
  p("KitchenCounter",{12,.2,3},12,3.5,14.5,cream)
  p("SinkBasin",{2.4,.08,1.7},10,3.65,14.5,ink,false)
  p("Tap",{.15,.8,.15},10,4,15.3,oak,false)
  p("Cooktop",{2.7,.06,2},15,3.65,14.5,ink,false)
  for i=1,5 do p("CabinetPull",{.6,.08,.1},6.7+i*1.8,2.9,13.05,ink,false)end
  p("Fridge",{2.8,6,2.8},17.5,3.7,10,cream)
  p("LivingRug",{10,.03,8},-11,.74,-8,sage,false)
  p("Sofa",{7,1.4,2.6},-11,1.6,-12.5,sage)
  p("SofaBack",{7,2,.45},-11,2.6,-13.7,sage)
  for _,x in ipairs({-14.3,-7.7})do p("SofaArm",{.5,1.6,2.8},x,2,-12.5,sage)end
  p("CoffeeTable",{4,.25,2},-11,1.8,-8.8,oak)
  for _,x in ipairs({-12.6,-9.4})do p("TableLeg",{.2,1.1,1.5},x,1.2,-8.8,ink)end
  p("DiningTable",{4.5,.25,3},11,3,-10,oak)
  p("DiningBase",{.5,2.2,.5},11,1.9,-10,ink)
  for _,z in ipairs({-12.6,-7.4})do
   p("DiningChair",{2,.35,2},11,1.8,z,cream,true,"Seat")
   p("ChairBack",{2,1.6,.2},11,2.55,z+(z< -10 and -1 or 1),oak)
   for _,x in ipairs({10.3,11.7})do p("ChairLeg",{.2,1.4,1.4},x,1.1,z,oak)end
  end
  for _,x in ipairs({-12,12})do for _,z in ipairs({-8,10})do
   local lamp=p("CeilingLight",{2,.25,2},x,10.5,z,cream,false);local light=Instance.new("PointLight");light.Brightness=.45;light.Range=20;light:SetAttribute("LightingRole","Interior");light.Color=Color3.fromRGB(255,238,211);light.Parent=lamp
  end end
  for i,v in ipairs(h.DisplaySlots:GetChildren())do if v:IsA("BasePart")then
   -- Preserve identity but give each display a clear, wall-side location.
   local slot=tonumber(v.Name:match('%d+'))or i;local places={{-17,-3},{-8,-3},{8,-3},{17,-3},{-17,4},{17,4}}
   local a=places[slot];if a then v.CFrame=b*CFrame.new(a[1],.74,a[2]);v.Size=Vector3.new(2.5,.08,2.5);v.Transparency=.92 end
  end end
 end
 -- Original central loop remains the only road: paths lead out to the destinations.
 for _,p in ipairs(w.Map:GetChildren())do if p:IsA("BasePart")and p.Name=="MapleStreet"then p.Size=Vector3.new(18,p.Size.Y,p.Size.Z)elseif p:IsA("BasePart")and p.Name=="CrossStreet"then p.Size=Vector3.new(p.Size.X,p.Size.Y,18)end end
 w:SetAttribute("HorizontalScale",1.4);w:SetAttribute("CozyLayout","cozy-1")
end
return M
