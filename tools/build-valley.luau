-- Rebuild the surrounding valley in Edit mode without rescaling player plots.
assert(not game:GetService("RunService"):IsRunning(),"Edit mode required")
local w=workspace.Neighborhood
local old=w:FindFirstChild("ValleyBackdrop");if old then old:Destroy()end
local root=Instance.new("Model");root.Name="ValleyBackdrop"
-- The skyline must remain visible from every streaming cell in the neighborhood.
root.ModelStreamingMode=Enum.ModelStreamingMode.Persistent;root.Parent=w
local ground=w.Map.VillageGround
local count=0
local function part(name,size,cf,color,material,solid,ball)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color;p.Material=material
 p.Anchored=true;p.CanCollide=solid;p.CanQuery=solid;p.CanTouch=false
 p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
 if ball then p.Shape=Enum.PartType.Ball end
 p.Parent=root;count+=1;return p
end
local grass=ground.Color
-- Four adjoining slabs extend the ground to 3,600 x 3,400 without coplanar overlap.
local top=ground.Position.Y+ground.Size.Y/2
for _,s in ipairs({{-1260,0,1080,3400},{1260,0,1080,3400},{0,-1150,1440,1100},{0,1150,1440,1100}})do
 part("ValleyFloor",Vector3.new(s[3],24,s[4]),CFrame.new(s[1],top-12,s[2]),grass,Enum.Material.Grass,true)
end
-- Overlapping rounded granite ridges create a continuous, irregular skyline.
-- All peaks begin outside the existing 720 x 600 half-extents of the district.
for i=0,31 do
 local a=i*math.pi/16
 local variation=math.sin(i*2.17)*.5+.5
 local x,z=math.cos(a)*1120,math.sin(a)*1030
 local height=410+variation*210
 part("GraniteRidge",Vector3.new(540,height,540),CFrame.new(x,height*.15,z)*CFrame.Angles(0,-a,0),Color3.fromRGB(108+variation*15,124+variation*13,117+variation*12),Enum.Material.Slate,true,true)
 part("WoodedFoothill",Vector3.new(400,220+variation*80,380),CFrame.new(math.cos(a)*960,-72,math.sin(a)*865),grass:Lerp(Color3.fromRGB(91,122,81),.3),Enum.Material.Grass,true,true)
 local farHeight=570+math.sin(i*1.71)^2*280
 part("DistantPeak",Vector3.new(580,farHeight*2,540),CFrame.new(math.cos(a)*1430,-farHeight*.32,math.sin(a)*1340)*CFrame.Angles(0,a*.7,0),Color3.fromRGB(116,137,137),Enum.Material.Slate,false,true)
end
-- A sparse forest softens the transition; no trees occupy existing activity paths.
for i=0,63 do
 local a=i*math.pi/32
 local x,z=math.cos(a)*(810+25*math.sin(i*2.2)),math.sin(a)*(710+20*math.sin(i*1.8))
 local h=20+(i%5)*2
 part("PineTrunk",Vector3.new(2,h,2),CFrame.new(x,h/2,z),Color3.fromRGB(105,89,69),Enum.Material.Wood,true)
 for tier=0,1 do
  part("PineCrown",Vector3.new(20-tier*5,28-tier*5,20-tier*5),CFrame.new(x,h+5+tier*12,z),Color3.fromRGB(63+tier*9,94+tier*9,76+tier*5),Enum.Material.Grass,false,true)
 end
end
root:SetAttribute("FootprintX",3600);root:SetAttribute("FootprintZ",3400)
root:SetAttribute("DesignVersion","valley-1")
return {Parts=count,Footprint={3600,3400},DistrictUnchanged={ground.Size.X,ground.Size.Z}}
