local A=require(script.Parent.CityArchitecture)
local M={Seats={},Cars={}}
function M.Build(W,context)
 local root=Instance.new('Folder');root.Name='CarnivalMidway';root.Parent=W.Root
 local lib=game.ServerStorage:WaitForChild('CarnivalArt')
 local function p(name,size,x,y,z,color,material,solid)
  return W.Part(root,name,size,x,y,z,color,material,solid)
 end
 local function place(name,x,z,scale,yaw)
  local m=lib[name]:Clone();m:ScaleTo(scale or 1);local box,size=m:GetBoundingBox()
  local target=CFrame.new(x,3.55+size.Y/2,z)*CFrame.Angles(0,yaw or 0,0)
  m:PivotTo(target*box:Inverse()*m:GetPivot());m.PrimaryPart=nil;m.WorldPivot=target;m.ModelStreamingMode=Enum.ModelStreamingMode.Atomic;m.Parent=root
  return m
 end
 -- Connected north extension: no attractions floating beyond the old pier.
 for _,v in ipairs(W.Root.Beach:GetChildren())do if v.Name=='PierRail'and math.abs(v.Position.Z+65)<1 then v:Destroy()end end
 p('MidwayDeck',{180,1,110},810,3,-120,A.Wood,Enum.Material.WoodPlanks,true)
 for _,x in ipairs({725,765,805,845,895})do for _,z in ipairs({-170,-115})do p('PierPile',{2,40,2},x,-16,z,A.Wood,Enum.Material.Wood,true)end end
 p('EastSafetyRail',{.3,3,290},900,5,-30,A.Cream,Enum.Material.Metal,true)
 p('WestSafetyRail',{.3,3,152},720,5,-99,A.Cream,Enum.Material.Metal,true)
 p('WestSafetyRail',{.3,3,92},720,5,69,A.Cream,Enum.Material.Metal,true)
 p('NorthSafetyRail',{180,3,.3},810,5,-175,A.Cream,Enum.Material.Metal,true)
 local ride=place('TiltWhirl',820,-130,.7,0);ride.Name='SeabreezeSpinner'
 local center=ride:GetPivot().Position
 for _,car in ipairs(ride:GetDescendants())do if car:IsA('Model')and car.Name=='spinning car'then
  local box=car:GetBoundingBox();car.PrimaryPart=nil;car.WorldPivot=box
  table.insert(M.Cars,{Model=car,Start=box})
  for _,seat in ipairs(car:GetDescendants())do if seat:IsA('Seat')or seat:IsA('VehicleSeat')then
   seat.Disabled=true;table.insert(M.Seats,seat)
   seat:GetPropertyChangedSignal('Occupant'):Connect(function()if not seat.Occupant then seat.Disabled=true end end)
  end end
 end end
 local board=p('SpinnerBoard',{8,3,.4},820,6,-88,A.Ink,Enum.Material.SmoothPlastic,false);A.Sign(board,'SEABREEZE SPINNER • FREE');A.Prompt(board,'CarnivalRide','Seabreeze Spinner','Board ride')
 context.Interactions:Register('CarnivalRide',function(player)
  local h=player.Character and player.Character:FindFirstChildOfClass('Humanoid')
  if not h or h.Health<=0 or h.Sit then return false,'Stand up before boarding.'end
  if player:GetAttribute('Carrying')or player:GetAttribute('DeliveryAddress')then return false,'Set down your item before boarding.'end
  for _,seat in ipairs(M.Seats)do if not seat.Occupant then seat.Disabled=false;player.Character:PivotTo(seat.CFrame*CFrame.new(0,2,0));seat:Sit(h);return true,'Enjoy the spin! Jump to get off.'end end
  return false,'The ride is full. Try again shortly.'
 end)
 -- Detailed imported booths replace the plain counters; keep established skill games.
 local attractions=W.Root.Attractions
 for _,v in ipairs(attractions:GetChildren())do if v.Name=='GameCounter'or v.Name=='GameRoof'or v.Name=='GamePost'then v:Destroy()end end
 for i,x in ipairs({745,790,835})do
  local booth=place('GameBooth',x,-48,.8,0);booth.Name='SkillBooth'..i
 end
 for _,target in ipairs(attractions:GetChildren())do if target.Name=='SkillTarget'then target.Position=Vector3.new(target.Position.X,7,-67)end end
 for i,d in ipairs({{742,-93},{879,-91}})do
  local stall=place('CandyStall',d[1],d[2],1.15,math.pi/2);stall.Name='CandyCart'..i
  local counter=p('CandyCounter',{4,2,.4},d[1],6,d[2]+8,Color3.fromRGB(223,132,169),Enum.Material.SmoothPlastic,false)
  A.Prompt(counter,'CarnivalTreat','Cotton candy','Take a free treat')
 end
 local last={}
 context.Interactions:Register('CarnivalTreat',function(player)
  if os.clock()-(last[player]or -10)<3 then return false,'Enjoy your treat first!'end;last[player]=os.clock()
  local bag=player:FindFirstChildOfClass('Backpack');if not bag then return false,'Your bag is not ready.'end
  if bag:FindFirstChild('Cotton candy')or player.Character:FindFirstChild('Cotton candy')then return false,'You already have cotton candy.'end
  local tool=Instance.new('Tool');tool.Name='Cotton candy';tool.CanBeDropped=false
  local stick=Instance.new('Part');stick.Name='Handle';stick.Size=Vector3.new(.15,1.8,.15);stick.Color=A.Cream;stick.CanCollide=false;stick.Massless=true;stick.Parent=tool
  local candy=Instance.new('Part');candy.Shape=Enum.PartType.Ball;candy.Size=Vector3.new(1.2,1.7,1.2);candy.Color=Color3.fromRGB(247,159,204);candy.Material=Enum.Material.Fabric;candy.CanCollide=false;candy.Massless=true;candy.CFrame=stick.CFrame*CFrame.new(0,1.1,0);candy.Parent=tool
  local weld=Instance.new('WeldConstraint');weld.Part0=stick;weld.Part1=candy;weld.Parent=stick
  tool.Activated:Connect(function()tool:Destroy()end);tool.Parent=bag;return true,'Free cotton candy! Equip it and tap to eat.'
 end)
 game.Players.PlayerRemoving:Connect(function(player)last[player]=nil end)
 -- Anchored balloon clusters, perimeter lights, and an entrance marquee.
 for _,d in ipairs({{714,-16},{714,16},{727,-75},{893,-75},{730,101},{887,101},{755,-162},{885,-160}})do
  local balloons=place('Balloons',d[1],d[2],1.4,0);balloons:PivotTo(balloons:GetPivot()+Vector3.new(0,5,0))
  p('BalloonTether',{.06,6,.06},d[1],6.5,d[2],A.Cream,Enum.Material.SmoothPlastic,false)
 end
 for _,z in ipairs({-18,18})do p('EntrancePost',{.6,17,.6},709,12,z,Color3.fromRGB(220,151,122),Enum.Material.Metal,true)end
 local sign=p('CarnivalMarquee',{.4,4,37},709,19,0,A.Ink,Enum.Material.SmoothPlastic,false);sign.CFrame*=CFrame.Angles(0,math.pi/2,0);sign.Size=Vector3.new(37,4,.4);A.Sign(sign,'PACIFIC PIER • RIDES & TREATS')
 for z=-160,100,20 do for _,x in ipairs({723,897})do
  local bulb=p('FestivalBulb',{.5,.5,.5},x,9,z,Color3.fromRGB(255,212,143),Enum.Material.Neon,false);bulb.Shape=Enum.PartType.Ball
  p('FestivalPost',{.12,5.5,.12},x,6.25,z,A.Ink,Enum.Material.Metal,false)
 end end
 local elapsed=0
 game:GetService('RunService').Heartbeat:Connect(function(dt)
  elapsed+=dt;local orbit=CFrame.new(center)*CFrame.Angles(0,elapsed*.2,0)*CFrame.new(-center)
  for i,c in ipairs(M.Cars)do local position=orbit*c.Start.Position
   c.Model:PivotTo(CFrame.new(position)*c.Start.Rotation*CFrame.Angles(0,elapsed*.55+i,0))
  end
 end)
 root:SetAttribute('NewRideSeats',#M.Seats);root:SetAttribute('ImportedModels',14)
end
return M
