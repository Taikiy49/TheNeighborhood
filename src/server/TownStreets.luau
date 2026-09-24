local A=require(script.Parent.CityArchitecture)
local T={}
function T.Build(root)
 local old=root:FindFirstChild('StreetLife');if old then old:Destroy()end
 local m=Instance.new('Folder');m.Name='StreetLife';m.Parent=root
 local function p(n,s,x,y,z,c,mat,solid,class)return A.Part(m,n,s,Vector3.new(x,y,z),c,mat,solid,class)end
 local lights={}
 -- Keep furnishings outside the six-stud shop sidewalks and eight-stud doors.
 for _,x in ipairs({-45,45})do for _,z in ipairs({-130,-106,-66,66,106,130})do
  p('LampFoot',{1.2,.35,1.2},x,.45,z,A.Ink,Enum.Material.Metal)
  p('LampPost',{.35,10,.35},x,5.5,z,A.Ink,Enum.Material.Metal)
  p('LanternCap',{1.8,.3,1.8},x,11.3,z,A.Ink,Enum.Material.Metal)
  local glass=p('Lantern',{1.1,1.4,1.1},x,10.45,z,Color3.fromRGB(255,226,172),Enum.Material.Glass,false)
  local light=Instance.new('PointLight');light.Color=glass.Color;light.Range=20;light.Brightness=.65;light.Shadows=false;light.Parent=glass;table.insert(lights,light)
 end end
 local function lighting()
  local hour=game.Lighting.ClockTime;local night=hour<6 or hour>=18
  for _,l in ipairs(lights)do l.Enabled=night;l.Parent.Material=night and Enum.Material.Neon or Enum.Material.Glass end
 end
 lighting();local connection=game.Lighting:GetPropertyChangedSignal('ClockTime'):Connect(lighting)
 m.Destroying:Connect(function()connection:Disconnect()end)
 local walks=root.Parent:FindFirstChild('WalkNetwork')
 if walks then for _,v in ipairs(walks:GetChildren())do if v:IsA('BasePart')and v.Name=='Zebra'and math.abs(math.abs(v.Position.Z)-90)<1 and math.abs(math.abs(v.Position.X)-58.8)<10 then v:Destroy()end end end
 for _,z in ipairs({90,-90})do for _,side in ipairs({-1,1})do
  p('CrossingApproach',{8,.18,8},side*46,.22,z,A.Cream,Enum.Material.Pavement)
  for stripe=-2,2 do p('MarketCrossing',{1.6,.025,6},side*58.8+stripe*3.4,.19,z,A.Cream,Enum.Material.SmoothPlastic,false)end
 end end
 -- Confine greenery to raised beds, leaving a continuous paved walking surface.
 for _,z in ipairs({86,-92})do for _,x in ipairs({-31,31})do
  p('TreePlanter',{6,1,3},x,.75,z,Color3.fromRGB(169,163,145),Enum.Material.Concrete)
  p('PlanterSoil',{5.6,.12,2.6},x,1.32,z,Color3.fromRGB(77,65,48),Enum.Material.Ground,false)
  p('TreeTrunk',{.6,6,.6},x,4.3,z,A.Wood,Enum.Material.Wood)
  local crown=p('TreeCrown',{5,6,4},x,8.2,z,Color3.fromRGB(91,126,78),Enum.Material.Grass,false);crown.Shape=Enum.PartType.Ball
 end end
 for _,z in ipairs({86,-92})do for _,x in ipairs({-11,11})do
  p('PublicBench',{6,.4,1.7},x,1.9,z,A.Wood,Enum.Material.WoodPlanks,true,'Seat')
  p('BenchBack',{6,1.5,.25},x,2.65,z+1,A.Wood,Enum.Material.WoodPlanks)
  for _,dx in ipairs({-2,2})do p('BenchLeg',{.35,1.4,1.5},x+dx,1,z,A.Ink,Enum.Material.Metal)end
 end end
 for _,x in ipairs({-43,43})do
  p('LitterBin',{1.5,2.4,1.5},x,1.5,139,A.Ink,Enum.Material.Metal)
  p('BinRim',{1.7,.2,1.7},x,2.85,139,A.Cream,Enum.Material.Metal)
 end
 for _,building in ipairs(root.MarketAvenue:GetChildren())do
  local floor=building:FindFirstChild('Floor');if floor then
   local oldCanopy=building:FindFirstChild('DoorCanopy');if oldCanopy then oldCanopy:Destroy()end
   local x=floor.Position.X;local z=floor.Position.Z-15.5
   local color=building.Name=='MaplePizza'and Color3.fromRGB(165,94,72)or Color3.fromRGB(92,130,122)
   p('ShopAwning',{28,.25,3},x,8.8,z,color,Enum.Material.Fabric)
   p('AwningValance',{28,.65,.18},x,8.4,z-1.6,color,Enum.Material.Fabric)
   for _,dx in ipairs({-12,12})do p('AwningBracket',{.2,2,.2},x+dx,7.5,z+1,A.Ink,Enum.Material.Metal)end
  end
 end
 -- Street names identify actual crossings instead of adding scattered task boards.
 for _,data in ipairs({{45,88,'MARKET STREET'},{45,-94,'PARK SQUARE'}})do
  local x,z,label=table.unpack(data);p('StreetNamePost',{.25,8,.25},x,4.3,z,A.Ink,Enum.Material.Metal)
  local sign=p('StreetName',{7,1.2,.18},x,8.5,z,A.Ink,Enum.Material.Metal,false);A.Sign(sign,label)
  local back=sign:FindFirstChildWhichIsA('SurfaceGui'):Clone();back.Face=Enum.NormalId.Back;back.Parent=sign
 end
 -- A compact outdoor seating terrace behind the shops, clear of the service lane.
 for _,x in ipairs({-21,21})do
  local function patio(n,s,dx,y,dz,c,mat,solid,class)return p('Patio'..n,s,x+dx,y,134+dz,c,mat,solid,class)end
  A.Table(patio,0,0,0)
 end
 m:SetAttribute('Design','Coordinated market and park streets; clear shop entrances')
 return m
end
return T
