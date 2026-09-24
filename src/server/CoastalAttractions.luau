local A=require(script.Parent.CityArchitecture)
local M={Rides={},Games={},Cooldown={},Rewards={}}
function M.Build(W,context)
 local root=Instance.new('Folder');root.Name='Attractions';root.Parent=W.Root
 local function p(n,s,x,y,z,c,mat,solid,class)return W.Part(root,n,s,x,y,z,c,mat,solid,class)end
 local rides={};local games={}
 local function rideStation(name,x,y,z,seats)
  local station=p(name..'Boarding',{5,2,2},x,y,z,A.Ink)
  A.Prompt(station,'CoastRide',name,'Board ride');station:SetAttribute('Ride',name);rides[name]=seats;for _,seat in ipairs(seats)do seat:GetPropertyChangedSignal('Occupant'):Connect(function()if not seat.Occupant then seat.Disabled=true end end)end
 end
 local Art=require(script.Parent.CuratedArchitecture)
 local ferris,updateFerris=Art.Ferris(root,Vector3.new(790,36,10))
 rideStation('Pacific Wheel',790,5,-30,ferris)
 local carousel={};p('CarouselPlatform',{34,1,34},855,4,60,Color3.fromRGB(186,134,100),Enum.Material.WoodPlanks)
 local mast=p('CarouselMast',{12,3,3},855,10,60,A.Cream);mast.Shape=Enum.PartType.Cylinder;mast.CFrame*=CFrame.Angles(0,0,math.pi/2)
 local canopy=p('CarouselCanopy',{2,34,34},855,16,60,Color3.fromRGB(197,121,98));canopy.Shape=Enum.PartType.Cylinder;canopy.CFrame*=CFrame.Angles(0,0,math.pi/2)
 for i=1,24 do
  local a=i*math.pi/12
  local bulb=p('CarouselMarquee',{.45,.45,.45},855+math.sin(a)*17,16,60+math.cos(a)*17,Color3.fromRGB(255,227,166),Enum.Material.Neon,false);bulb.Shape=Enum.PartType.Ball
 end
 for _,y in ipairs({15,17})do local rim=p('CarouselGoldRim',{.2,34.4,34.4},855,y,60,Color3.fromRGB(193,156,81),Enum.Material.Metal,false);rim.Shape=Enum.PartType.Cylinder;rim.CFrame*=CFrame.Angles(0,0,math.pi/2)end
 for i=1,6 do
  local seat=p('CarouselSeat',{2,.3,2},855,7.8,60,A.Ink,nil,true,'Seat');seat.Disabled=true;seat.Transparency=1
  local key='Carousel'..({'Tiger','Elephant','Giraffe'})[(i-1)%3+1]
  local _,size=game.ServerStorage.CuratedArt[key]:GetBoundingBox();local scale=math.min(5/math.max(size.X,size.Z),3/size.Y)
  local rotation=CFrame.Angles(0,size.X>size.Z and math.pi/2 or 0,0)
  local animal=Art.Place(key,root,seat.CFrame*CFrame.new(0,-1.2,0)*rotation,size*scale)
  local pole=p('CarouselPole',{.15,10.5,.15},855,10.5,60,Color3.fromRGB(195,162,92),Enum.Material.Metal,false)
  table.insert(carousel,{Seat=seat,Animal=animal,Pole=pole,Rotation=rotation,Phase=i*math.pi/3})
 end
 local cs={};for _,c in ipairs(carousel)do table.insert(cs,c.Seat)end;rideStation('Seaside Carousel',835,5,80,cs)
 local swing={};p('SwingCanopy',{26,1,26},740,23,65,Color3.fromRGB(120,163,168));p('SwingMast',{2,20,2},740,13,65,A.Cream)
 for i=1,4 do local seat=p('SwingSeat',{3,.5,3},740,7,65,A.Wood,nil,true,'Seat');seat.Disabled=true;local chain=p('SwingChain',{.15,13,.15},740,14,65,A.Ink,Enum.Material.Metal,false);table.insert(swing,{Seat=seat,Chain=chain,Phase=i*math.pi/2})end
 local ss={};for _,c in ipairs(swing)do table.insert(ss,c.Seat)end;rideStation('Ocean Swings',722,5,88,ss)
 context.Interactions:Register('CoastRide',function(player,target)
  if player:GetAttribute('Carrying')or player:GetAttribute('DeliveryAddress')then return false,'Set down your item before boarding.'end
  local h=player.Character and player.Character:FindFirstChildOfClass('Humanoid');if not h or h.Health<=0 or h.Sit then return false,'Stand up before boarding.'end
  for _,seat in ipairs(rides[target:GetAttribute('Ride')]or{})do if not seat.Occupant then seat.Disabled=false;player.Character:PivotTo(seat.CFrame*CFrame.new(0,2,0));seat:Sit(h);return true,'Enjoy the ride! Jump to get off.'end end
  return false,'All seats are occupied. Try again shortly.'
 end)
 for i,title in ipairs({'Bottle timing','Ring challenge','Reaction bell'})do
  local x=745+(i-1)*45;local z=-55
  p('GameCounter',{28,3,6},x,5,z,A.Wood);p('GameRoof',{32,.5,12},x,14,z,Color3.fromHSV(i*.16,.35,.8))
  for _,dx in ipairs({-14,14})do p('GamePost',{.5,11,.5},x+dx,8.5,z+3,A.Cream)end
  local button=p('SkillTarget',{5,3,1},x,9,z-1,A.Ink,Enum.Material.Neon,false);A.Sign(button,'WAIT FOR GREEN')
  button:SetAttribute('Game',title);A.Prompt(button,'CoastSkill',title,'Hit when green');games[button]={Phase=i*.8,Window=.65}
 end
 context.Interactions:Register('CoastSkill',function(player,target)
  local d=games[target];if not d then return false,'Choose a carnival target.'end
  local now=os.clock();if now-(M.Cooldown[player]or -10)<2 then return false,'Let the target reset.'end;M.Cooldown[player]=now
  if(now+d.Phase)%3.5>d.Window then return false,'Too early or too late. Watch for green!'end
  if now-(M.Rewards[player]or -100)<20 then return true,'Nice timing! Practice freely; cash rewards reset after 20 seconds.'end
  local profile=context.Data:Get(player);if not profile then return false,'Your profile is still loading.'end
  M.Rewards[player]=now
  profile.Currency=math.min(1000000000,profile.Currency+8);context.Record(player,'Trial');context.Sync(player);return true,'Nice timing! Earned $8.'
 end)
 -- Airport aircraft: built silhouettes with cabins, seats, and a free sightseeing flight.
 local airplane=Instance.new('Model');airplane.Name='CoastPlane';airplane.Parent=root
 local function plane(n,s,dx,y,dz,c)local v=p(n,s,210+dx,y,485+dz,c,Enum.Material.Metal);v.Parent=airplane;return v end
 local fuselage=plane('Fuselage',{7,6,28},0,5,0,A.Cream);airplane.PrimaryPart=fuselage
 plane('Wings',{40,.7,8},0,5,-1,Color3.fromRGB(134,169,174));plane('TailWing',{15,.5,5},0,7,12,A.Cream);plane('TailFin',{.6,8,7},0,10,11,A.Ink)
 local seat=plane('PilotSeat',{3,.5,3},0,9,-7,A.Ink);local actual=Instance.new('Seat');actual.Name='FlightSeat';actual.Size=seat.Size;actual.CFrame=seat.CFrame;actual.Anchored=true;actual.Disabled=true;actual.Parent=airplane;seat:Destroy()
 local flight=p('FlightBoard',{7,3,1},195,5,470,A.Ink);A.Sign(flight,'COAST SIGHTSEEING - FREE FLIGHT');A.Prompt(flight,'CoastFlight','Coast sightseeing','Board plane')
 local helicopter=p('HelicopterCabin',{8,7,13},160,6,525,Color3.fromRGB(151,178,157));p('HelicopterTail',{2,2,15},160,7,537,A.Ink);p('Rotor',{28,.3,1},160,11,525,A.Ink)
 for _,v in ipairs(airplane:GetChildren())do if v:IsA('BasePart')and v~=actual then v.Transparency=1;v.CanCollide=false end end
 Art.Place('LightPlane',airplane,CFrame.new(210,6,485),Vector3.new(40,9,32))
 for _,name in ipairs({'HelicopterCabin','HelicopterTail','Rotor'})do local v=root:FindFirstChild(name);if v then v:Destroy()end end
 Art.Place('Helicopter',root,CFrame.new(160,7,525)*CFrame.Angles(0,math.pi/2,0),Vector3.new(30,9,9))
 local flying;local started;local home=airplane:GetPivot()
 context.Interactions:Register('CoastFlight',function(player)
  if flying then return false,'The plane is on a short sightseeing flight.'end
  if player:GetAttribute('Carrying')or player:GetAttribute('DeliveryAddress')then return false,'Finish carrying your item before flying.'end
  local h=player.Character and player.Character:FindFirstChildOfClass('Humanoid');if not h or h.Sit then return false,'Stand up before boarding.'end
  actual.Disabled=false;player.Character:PivotTo(actual.CFrame*CFrame.new(0,2,0));actual:Sit(h);flying=player;started=os.clock();return true,'Enjoy the coast! Jump to leave the plane.'
 end)
 local elapsed=0
 game:GetService('RunService').Heartbeat:Connect(function(dt)
  elapsed+=dt
  updateFerris(elapsed)
  for _,c in ipairs(carousel)do local a=elapsed*.28+c.Phase;c.Seat.CFrame=CFrame.new(855+math.sin(a)*11,7.8+math.sin(elapsed*1.2+c.Phase)*.4,60+math.cos(a)*11)*CFrame.Angles(0,a,0);c.Animal:PivotTo(c.Seat.CFrame*CFrame.new(0,-1.2,0)*c.Rotation);c.Pole.Position=Vector3.new(c.Seat.Position.X,10.5,c.Seat.Position.Z)end
  for _,c in ipairs(swing)do local a=elapsed*.3+c.Phase;local x,z=740+math.sin(a)*10,65+math.cos(a)*10;c.Seat.CFrame=CFrame.new(x,7,z)*CFrame.Angles(0,a,0);c.Chain.Position=Vector3.new(x,14,z)end
  for target,d in pairs(games)do local green=(os.clock()+d.Phase)%3.5<d.Window;target.Color=green and Color3.fromRGB(86,204,127)or Color3.fromRGB(184,107,96);target.SurfaceGui.TextLabel.Text=green and 'HIT NOW!'or 'WAIT' end
  if flying then
   local t=(os.clock()-started)/45
   if t>=1 or not flying.Parent or (t>.03 and not actual.Occupant)then
    local passenger=flying;actual.Disabled=true
    local character=passenger.Character;local passengerRoot=character and character:FindFirstChild('HumanoidRootPart')
    if passengerRoot then passengerRoot.Anchored=true end
    if actual.Occupant then actual.Occupant.Sit=false end
    local weld=actual:FindFirstChild('SeatWeld');if weld then weld:Destroy()end
    airplane:PivotTo(home);flying=nil
    if character then character:PivotTo(CFrame.new(195,4,462))end
    task.delay(.25,function()if passengerRoot and passengerRoot.Parent then
     if character.Parent then character:PivotTo(CFrame.new(195,4,462))end
     passengerRoot.AssemblyLinearVelocity=Vector3.zero;passengerRoot.AssemblyAngularVelocity=Vector3.zero;passengerRoot.Anchored=false
     passengerRoot:SetNetworkOwner(nil);character:PivotTo(CFrame.new(195,4,462))
     task.delay(1,function()if passengerRoot.Parent then passengerRoot:SetNetworkOwnershipAuto()end end)
    end end)
   else local a=t*math.pi*2;local pos=home.Position+Vector3.new(math.sin(a)*340,math.sin(t*math.pi)*130,(math.cos(a)-1)*220);airplane:PivotTo(CFrame.lookAt(pos,pos+Vector3.new(math.cos(a)*340,0,-math.sin(a)*220)))end
  end
 end)
 game.Players.PlayerRemoving:Connect(function(p)M.Cooldown[p]=nil;M.Rewards[p]=nil end)
 M.Rides=rides;M.Games=games;M.Ferris=ferris
 require(script.Parent.CarnivalExpansion).Build(W,context)
end
return M
