-- Authored street hierarchy: a continuous driving loop, pedestrian crossings and visible destinations.
local F=require(script.Parent.RecreationFactory)
local M={}
local cream=Color3.fromRGB(241,231,205)
local ink=Color3.fromRGB(48,72,65)
function M.Build(w)
 local old=w:FindFirstChild("TownPolish");if old then old:Destroy()end
 local root=Instance.new("Folder");root.Name="TownPolish";root.Parent=w
 if not w:GetAttribute("CozyLandscapeFixed")then
  for _,v in ipairs(w.ArtDirection.GardenDistrict:GetDescendants())do
   if v:IsA("BasePart")and(v.Name=="Crown"or v.Name=="HerbBush"or v.Name=="LowLavender")then v.Size=Vector3.new(v.Size.X*1.8,v.Size.Y*.85,v.Size.Z*1.8)end
  end
  for _,v in ipairs(w.ValleyBackdrop:GetChildren())do if v:IsA("BasePart")and v.Name~="ValleyFloor"then
   v.Size=Vector3.new(v.Size.X,v.Size.Y*.46,v.Size.Z);v.Position=Vector3.new(v.Position.X,v.Position.Y*.46,v.Position.Z)
  end end
  w:SetAttribute("CozyLandscapeFixed",true)
 end
 local function p(n,s,x,y,z,c,solid,class)return F.Part(root,n,Vector3.new(table.unpack(s)),CFrame.new(x,y,z),c,solid,class)end
 -- External cottage joinery must share the shell's vertical transformation.
 if not w:GetAttribute("CozyJoineryFixed")then
  for _,v in ipairs(w.ArtDirection.GardenDistrict.Cottages:GetDescendants())do
   if v:IsA("BasePart")and table.find({"EaveTrim","WindowHeader","WindowDivider","FrontCorner"},v.Name)then
    v.Size=Vector3.new(v.Size.X,v.Size.Y/1.3,v.Size.Z);v.Position=Vector3.new(v.Position.X,.7+(v.Position.Y-.7)/1.3,v.Position.Z)
   end
  end
  for _,cap in ipairs(w.DetailCorrections:GetChildren())do if cap.Name=="CottageRidgeCap"then
   cap.Position=Vector3.new(cap.Position.X,.7+(cap.Position.Y-.7)/1.3,cap.Position.Z)
  end end
  w:SetAttribute("CozyJoineryFixed",true)
 end
 -- Cross streets end exactly at the outer edge of the loop, with no asphalt stubs.
 for _,v in ipairs(w.Map:GetChildren())do
  if v.Name=="CrossStreet"then v.Size=Vector3.new(135.6,v.Size.Y,18)
  elseif v.Name=="LaneMark"and math.abs(v.Position.Z)<9 then v:Destroy()end
 end
 -- End sidewalk segments at the crossing, rather than projecting beyond the town.
 for _,v in ipairs(w.Map:GetChildren())do if v.Name=="Sidewalk"then v.Size=Vector3.new(v.Size.X,v.Size.Y,355.6)end end
 local lights={}
 for _,x in ipairs({-58.8,58.8})do
  for _,side in ipairs({-1,1})do
   local z=side*10;local sx=x+side*11.2
   p("SignalPole",{.45,10,.45},sx,5,z,ink,true)
   local head=p("SignalHousing",{1.4,3.6,1},sx,9.2,z,ink,false)
   local row={}
   for i,color in ipairs({Color3.fromRGB(238,83,70),Color3.fromRGB(255,201,79),Color3.fromRGB(95,213,144)})do
    local bulb=p("SignalLens",{.8,.8,.15},sx,10.4-(i-1)*1.1,z+side*.56,color,false)
    bulb.Shape=Enum.PartType.Ball;bulb:SetAttribute("LitColor",color);row[i]=bulb
   end
   table.insert(lights,row)
   local stop=p("StopLine",{8,.025,.55},x+side*4.5,.21,side*9.5,cream,false)
  end
 end
 M.Lights=lights
 -- A slim civic clock is a recognizable meeting point, with readable faces on both approaches.
 p("ClockBase",{6,1,6},-22,.5,-105,cream)
 p("ClockTower",{3.8,22,3.8},-22,12,-105,ink)
 p("ClockCornice",{5,1,5},-22,23.5,-105,cream)
 p("ClockLantern",{2.8,3,2.8},-22,25.5,-105,Color3.fromRGB(223,173,96))
 local roof=p("ClockRoof",{.5,6,6},-22,27.5,-105,ink);roof.Shape=Enum.PartType.Cylinder;roof.CFrame*=CFrame.Angles(0,0,math.pi/2)
 for _,side in ipairs({-1,1})do
  local face=p("ClockFace",{3.5,3.5,.1},-22,21,-105+side*1.96,cream,false)
  if side==1 then face.CFrame*=CFrame.Angles(0,math.pi,0)end
  F.Sign(face,"12\n9   ·   3\n6")
  local gui=face:FindFirstChildWhichIsA("SurfaceGui");gui.TextLabel.TextColor3=ink
  local minute=Instance.new("Frame");minute.Name="MinuteHand";minute.AnchorPoint=Vector2.new(.5,1);minute.Position=UDim2.fromScale(.5,.5);minute.Size=UDim2.fromScale(.035,.26);minute.BorderSizePixel=0;minute.BackgroundColor3=ink;minute.Parent=gui
  local hour=minute:Clone();hour.Name="HourHand";hour.Size=UDim2.fromScale(.05,.18);hour.Parent=gui
 end
 -- A small covered picnic court gives the green height and an actual place to sit.
 for _,x in ipairs({15,33})do for _,z in ipairs({-114,-96})do p("PergolaPost",{.55,9,.55},x,4.5,z,ink)end end
 for x=15,33,3 do p("PergolaRafter",{.4,.45,20},x,9,-105,cream)end
 for _,z in ipairs({-114,-96})do p("PergolaBeam",{20,.5,.5},24,8.8,z,cream)end
 p("PicnicTable",{7,.35,3},24,2.8,-105,Color3.fromRGB(174,136,95))
 for _,z in ipairs({-108,-102})do
  p("PicnicSeat",{7,.4,1.5},24,1.7,z,Color3.fromRGB(174,136,95),true,"Seat")
  for _,x in ipairs({21.5,26.5})do p("PicnicLeg",{.35,1.5,1.4},x,.75,z,ink)end
 end
 for _,x in ipairs({21.5,26.5})do p("TableLeg",{.4,2.6,2.5},x,1.3,-105,ink)end
 -- Signs face the approach and stand beside the route. No competing boards at its center.
 for _,v in ipairs(w.ArtDirection.GardenDistrict.Promenades:GetChildren())do if v.Name=="DistrictSign"or v.Name=="SignPost"then v:Destroy()end end
 for _,name in ipairs({"MapleGreenSign","CommunityBoard"})do local v=w.Map:FindFirstChild(name);if v then
  local pos=name=="MapleGreenSign"and Vector3.new(-22,5,-135)or Vector3.new(22,5,-135)
  v.Position=pos;v.Size=Vector3.new(9,3,.3)
 end end
 for _,v in ipairs(w.Map:GetChildren())do if v.Name=="BoardPost"then v:Destroy()end end
 for _,v in ipairs(w.DetailCorrections:GetChildren())do if v.Name=="GreenSignPost"then v:Destroy()end end
 for _,x in ipairs({-22,22})do for _,dx in ipairs({-3.5,3.5})do p("NoticePost",{.3,4,.3},x+dx,2,-134.8,ink)end end
 w:SetAttribute("TownDesign","cozy-civic-1")
 return root
end
function M.Step(w,time)
 local phase=time%30;local active=phase<18 and 3 or phase<21 and 2 or 1
 for _,row in ipairs(M.Lights or {})do for i,bulb in ipairs(row)do
  bulb.Material=i==active and Enum.Material.Neon or Enum.Material.SmoothPlastic
  bulb.Color=i==active and bulb:GetAttribute("LitColor")or Color3.fromRGB(42,48,43)
 end end
 w.TownPolish:SetAttribute("SignalPhase",({"Red","Amber","Green"})[active])
 local clock=game.Lighting.ClockTime
 for _,v in ipairs(w.TownPolish:GetDescendants())do if v.Name=="MinuteHand"then v.Rotation=(clock%1)*360 elseif v.Name=="HourHand"then v.Rotation=(clock%12)*30 end end
end
function M.Init(w)
 M.Build(w);M.Step(w,0)
 local timer=0;game:GetService("RunService").Heartbeat:Connect(function(dt)timer+=dt;if timer>=.25 then timer=0;M.Step(w,workspace:GetServerTimeNow())end end)
end
return M
