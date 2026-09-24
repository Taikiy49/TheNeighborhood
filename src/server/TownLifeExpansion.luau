local A=require(script.Parent.CityArchitecture)
local M={Traffic={},Passengers={}}
function M.Init(context)
 local W=require(script.Parent.CoastalWorld);local root=Instance.new('Folder');root.Name='TownLife';root.Parent=W.Root;M.Root=root
 local function p(parent,n,s,x,y,z,c,mat,solid,class)return W.Part(parent,n,s,x,y,z,c,mat,solid,class)end
 -- Restaurants have furnished interiors and use the established free snack interaction.
 for _,d in ipairs({{'PalmDiner',150,-185,Color3.fromRGB(193,152,124)},{'NoodleKitchen',450,-330,Color3.fromRGB(171,133,119)},{'CornerConvenience',180,125,Color3.fromRGB(150,176,158)},{'BoardwalkBakery',440,215,Color3.fromRGB(214,186,156)}})do
  for _,v in ipairs(W.Root.Landscape:GetChildren())do
   if v:IsA('BasePart')and math.abs(v.Position.X-d[2])<23 and math.abs(v.Position.Z-d[3])<20 then v:Destroy()end
  end
  local b=W.Building(root,d[1],d[2],d[3],32,24,1,d[4],0,'store')
  local snack=p(b,'SnackCounter',{5,3,3},d[2]-7,2,d[3]-4,A.Wood);A.Prompt(snack,'CoastSnack',d[1]=='NoodleKitchen'and 'Takeaway counter'or 'Snack counter','Take a free snack')
 end
 -- Mixed canopy heights mark streets and the park without putting trees in traffic lanes.
 for i,d in ipairs({{-540,-180},{-535,10},{-20,-180},{40,180},{40,380},{40,540},{470,-540},{485,360},{-530,-530},{-300,-350},{-100,-350},{-620,325},{-625,590},{-360,35}})do
  local h=22+(i%4)*4;p(root,'TallTreeTrunk',{1.8,h,1.8},d[1],h/2,d[2],A.Wood,Enum.Material.Wood)
  for level=0,2 do local crown=p(root,'LayeredCanopy',{15-level*3,12,15-level*3},d[1],h-3+level*5,d[2],Color3.fromRGB(81+i%3*8,119+i%3*6,82),Enum.Material.Grass,false);crown.Shape=Enum.PartType.Ball end
 end
 -- Additional clearly identified pedestrians stay in downtown pedestrian pockets.
 local template=workspace.Neighborhood.GuideCharacters.Mabel;local walkers={}
 for i=1,24 do
  local m=template:Clone();m.Name='Town visitor '..i
  for _,v in ipairs(m:GetDescendants())do if v:IsA('ProximityPrompt')or v:IsA('BillboardGui')then v:Destroy()elseif v:IsA('BasePart')then v.CanCollide=false;v.CanTouch=false;v.CanQuery=false end end
  m.Parent=root;m:ScaleTo(.85+(i%4)*.08)
  local centers={Vector3.new(140,3,-110),Vector3.new(460,3,-90),Vector3.new(240,3,170),Vector3.new(370,3,180)}
  local center=centers[(i-1)%4+1];table.insert(walkers,{Model=m,Center=center,Phase=i*.9})
 end
 -- Low-speed traffic uses physical car collision groups and stops before obstacles.
 local route={Vector3.new(87,2,-373),Vector3.new(513,2,-373),Vector3.new(513,2,593),Vector3.new(87,2,593)}
 for i=1,6 do
  local model=Instance.new('Model');model.Name='NeighborhoodTraffic'..i;model.ModelStreamingMode=Enum.ModelStreamingMode.Atomic;model.Parent=root
  local body=p(model,'Body',{6,2,10},0,2,0,Color3.fromHSV(i/7,.25,.7));model.PrimaryPart=body
  p(model,'Cabin',{5,2,5},0,4,1,A.Cream);for _,x in ipairs({-3,3})do for _,z in ipairs({-3,3})do local wheel=p(model,'Wheel',{.7,2,2},x,1,z,A.Ink);wheel.Shape=Enum.PartType.Cylinder end end
  for _,v in ipairs(model:GetChildren())do if v:IsA('BasePart')then v.CollisionGroup='NeighborhoodCars'end end
  local start=(i-1)%4+1;local nextIndex=start%4+1;local position=route[start]:Lerp(route[nextIndex],i>4 and .55 or .15)
  model:PivotTo(CFrame.lookAt(position,route[nextIndex]));table.insert(M.Traffic,{Model=model,Next=nextIndex,Position=position})
 end
 local query=OverlapParams.new();query.RespectCanCollide=true;query.CollisionGroup='NeighborhoodCars';query.FilterType=Enum.RaycastFilterType.Exclude
 -- Elevated coastal rail: three stations, free one-stop trips, eight-second boarding windows.
 local rail=Instance.new('Folder');rail.Name='CoastalRail';rail.Parent=root
 for _,x in ipairs({546,550})do p(rail,'Rail',{.35,.4,820},x,19,0,A.Ink,Enum.Material.Metal)end
 for z=-410,410,10 do p(rail,'Sleeper',{8,.5,1},548,18.5,z,A.Wood)end
 for z=-400,400,80 do p(rail,'RailColumn',{2,18,2},548,9,z,A.Cream,Enum.Material.Concrete)end
 local stations={-400,0,400};local stationBoards={}
 for i,z in ipairs(stations)do
  p(rail,'StationPlatform',{16,1,28},561,18,z,A.Cream,Enum.Material.Concrete);p(rail,'ShelterRoof',{18,.5,30},561,29,z,A.Ink)
  for _,dz in ipairs({-12,12})do p(rail,'ShelterPost',{.5,11,.5},567,23.5,z+dz,A.Wood)end
  local board=p(rail,'StationBoard',{8,3,.4},568,5,z,A.Ink);board:SetAttribute('Station',i);A.Sign(board,({'SUNSET STATION','PIER STATION','AIRPORT STATION'})[i]);A.Prompt(board,'CoastRail','Coastal rail','Board next train');stationBoards[i]=board
  local lift=p(rail,'PlatformLift',{2,3,.3},571,3,z+8,A.Cream);lift:SetAttribute('Destination',Vector3.new(561,22,z+8));A.Prompt(lift,'CityLift','Station platform','Visit platform')
  local down=p(rail,'PlatformReturn',{2,3,.3},565,21,z+8,A.Cream);down:SetAttribute('Destination',Vector3.new(573,4,z+8));A.Prompt(down,'CityLift','Street level','Return to street')
 end
 local train=Instance.new('Model');train.Name='CoastTram';train.ModelStreamingMode=Enum.ModelStreamingMode.Atomic;train.Parent=rail
 local body=p(train,'TramBody',{7,2,20},548,20,-400,Color3.fromRGB(95,151,149));train.PrimaryPart=body
 p(train,'TramRoof',{8,.5,21},548,27,-400,A.Cream)
 for _,x in ipairs({545,551})do for _,z in ipairs({-408,-392})do p(train,'TramPillar',{.4,5,.4},x,24,z,A.Cream)end end
 local seats={};for i=1,4 do local seat=p(train,'PassengerSeat',{2,.5,3},548,22,-411+i*4,A.Wood,nil,true,'Seat');seat.Disabled=true;seats[i]=seat end
 local station,direction,dwell,z=1,1,8,-400
 local function release(player,seat,destination)
  local c=player.Character;local r=c and c:FindFirstChild('HumanoidRootPart');seat.Disabled=true
  if r then r.Anchored=true end;if seat.Occupant then seat.Occupant.Sit=false end
  local weld=seat:FindFirstChild('SeatWeld');if weld then weld:Destroy()end
  if c then c:PivotTo(CFrame.new(destination))end
  task.delay(.25,function()if r and r.Parent then r.Anchored=false;r:SetNetworkOwner(nil);c:PivotTo(CFrame.new(destination));r.AssemblyLinearVelocity=Vector3.zero;task.delay(1,function()if r.Parent then r:SetNetworkOwnershipAuto()end end)end end)
 end
 context.Interactions:Register('CoastRail',function(player,target)
  if target:GetAttribute('Station')~=station or dwell<=0 then return false,'The train is on its way. It stops here every minute.'end
  local h=player.Character and player.Character:FindFirstChildOfClass('Humanoid');if not h or h.Sit or player:GetAttribute('Carrying')or player:GetAttribute('DeliveryAddress')then return false,'Stand up and finish your delivery first.'end
  for _,seat in ipairs(seats)do if not seat.Occupant then seat.Disabled=false;player.Character:PivotTo(seat.CFrame*CFrame.new(0,2,0));seat:Sit(h);M.Passengers[player]=seat;return true,'Next stop! Jump to leave early.'end end
  return false,'This tram is full. Catch the next one.'
 end)
 local elapsed=0;game:GetService('RunService').Heartbeat:Connect(function(dt)
  elapsed+=dt
  for player,seat in pairs(M.Passengers)do if not seat.Occupant or seat.Occupant.Parent~=player.Character then
   M.Passengers[player]=nil;release(player,seat,Vector3.new(573,4,stations[station]+8))
  end end
  for _,v in ipairs(walkers)do local t=elapsed*.22+v.Phase;local pos=v.Center+Vector3.new(math.sin(t)*9,0,math.cos(t)*14);v.Model:PivotTo(CFrame.lookAt(pos,pos+Vector3.new(math.cos(t),0,-math.sin(t))))end
  for _,v in ipairs(M.Traffic)do local d=route[v.Next]-v.Position;if d.Magnitude<2 then v.Next=v.Next%4+1;d=route[v.Next]-v.Position end
   query.FilterDescendantsInstances={v.Model};local look=CFrame.lookAt(v.Position+d.Unit*9,route[v.Next]);local blocked=false
   for _,hit in ipairs(workspace:GetPartBoundsInBox(look,Vector3.new(6,3,9),query))do if hit.Position.Y>1 and not hit:IsDescendantOf(rail)then blocked=true;break end end
   if not blocked and not require(script.Parent.StreetDressing).ShouldStop(v.Position,d.Unit)then v.Position+=d.Unit*math.min(d.Magnitude,dt*18);v.Model:PivotTo(CFrame.lookAt(v.Position,route[v.Next]))end
  end
  if dwell>0 then dwell-=dt else
   local target=stations[station+direction];z+=math.sign(target-z)*math.min(math.abs(target-z),dt*40)
   train:PivotTo(CFrame.new(548,20,z)*CFrame.Angles(0,direction==1 and math.pi or 0,0))
   if math.abs(target-z)<.1 then station+=direction;if station==1 or station==3 then direction=-direction end;dwell=8
    for player,seat in pairs(M.Passengers)do release(player,seat,Vector3.new(573,4,stations[station]+8));M.Passengers[player]=nil end
   end
  end
  rail:SetAttribute('Station',station);rail:SetAttribute('Boarding',dwell>0)
 end)
 game.Players.PlayerRemoving:Connect(function(p)M.Passengers[p]=nil end)
 -- Earned, read-only public titles; no personal text or age-sensitive matchmaking.
 local function title(player)
  local function character(c)
   local head=c:WaitForChild('Head',10);if not head then return end
   local gui=Instance.new('BillboardGui');gui.Name='EarnedRank';gui.Size=UDim2.fromOffset(180,25);gui.StudsOffset=Vector3.new(0,3,0);gui.MaxDistance=45;gui.Parent=head
   local text=Instance.new('TextLabel');text.Size=UDim2.fromScale(1,1);text.BackgroundTransparency=1;text.TextColor3=A.Cream;text.TextStrokeTransparency=.4;text.Font=Enum.Font.GothamBold;text.TextSize=13;text.Parent=gui
   local function update()text.Text=(player:GetAttribute('EarnedTitle')or 'New Resident')..' • Lv '..(player:GetAttribute('EarnedLevel')or 1)end
   local conn=player:GetAttributeChangedSignal('EarnedLevel'):Connect(update);gui.Destroying:Connect(function()conn:Disconnect()end);update()
  end
  player.CharacterAdded:Connect(character);if player.Character then task.spawn(character,player.Character)end
 end
 game.Players.PlayerAdded:Connect(title);for _,p in ipairs(game.Players:GetPlayers())do title(p)end
end
return M
