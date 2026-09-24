local F=require(script.Parent.RecreationFactory)
local M={}
function M.Build(w)
 local old=w:FindFirstChild("LakeFerry");if old then old:Destroy()end
 local root=Instance.new("Model");root.Name="LakeFerry";root.ModelStreamingMode=Enum.ModelStreamingMode.Atomic;root.Parent=w
 local home=CFrame.new(-247,1,42)*CFrame.Angles(0,math.pi/2,0)
 local function p(n,s,cf,c,solid,class)return F.Part(root,n,s,cf,c,solid,class)end
 local wood=Color3.fromRGB(170,125,85);local cream=Color3.fromRGB(240,229,203);local green=Color3.fromRGB(60,110,99)
 p("BoardingPier",Vector3.new(13,.4,6),CFrame.new(-237,.3,42),wood,true)
 for _,z in ipairs({38.5,45.5})do for _,x in ipairs({-232,-242})do p("MooringPost",Vector3.new(.6,3,.6),CFrame.new(x,1,z),wood,true)end end
 local boat=Instance.new("Model");boat.Name="WillowLaunch";boat.Parent=root
 local function b(n,size,offset,color,solid,class)local v=p(n,size,home*CFrame.new(offset),color,solid,class);v.Parent=boat;return v end
 local hull=b("Hull",Vector3.new(7,.7,12),Vector3.zero,green,true);boat.PrimaryPart=hull
 for _,x in ipairs({-3.3,3.3})do b("Gunwale",Vector3.new(.4,1.2,12),Vector3.new(x,.8,0),cream,true)end
 for _,z in ipairs({-5.7,5.7})do b("Bow",Vector3.new(6.7,1.2,.4),Vector3.new(0,.8,z),green,true)end
 local seat=b("PassengerSeat",Vector3.new(3,.5,2),Vector3.new(0,1,1.5),wood,true,"Seat");seat.Disabled=true
 b("SeatBack",Vector3.new(3,1.6,.25),Vector3.new(0,1.8,2.5),wood,false)
 for _,x in ipairs({-2.8,2.8})do for _,z in ipairs({-2,3})do b("CanopyPost",Vector3.new(.18,5,.18),Vector3.new(x,2.5,z),cream,false)end end
 b("Canopy",Vector3.new(6.4,.25,6),Vector3.new(0,5.1,.5),green,false)
 local board=p("FerryBoard",Vector3.new(6,2,.3),CFrame.new(-230,4,36),green,false);F.Sign(board,"WILLOW LAUNCH\nFree ocean cruise")
 p("BoardPost",Vector3.new(.3,3,.3),CFrame.new(-230,1.5,36.2),wood,false)
 board:SetAttribute("Action","LakeCruise")
 local prompt=Instance.new("ProximityPrompt");prompt.ActionText="Take a cruise";prompt.ObjectText="Willow Launch · free";prompt.RequiresLineOfSight=true;prompt.MaxActivationDistance=12;prompt.Style=Enum.ProximityPromptStyle.Custom;prompt:SetAttribute("Action","LakeCruise");prompt.Parent=board
 M.Boat=boat;M.Seat=seat;M.Home=home;M.Rider=nil;M.Started=nil
 return root
end
function M.Reset()
 local character=M.Rider and M.Rider.Character
 local root=character and character:FindFirstChild('HumanoidRootPart')
 if root then root.Anchored=true end
 if M.Seat.Occupant then M.Seat.Occupant.Sit=false end
 local weld=M.Seat:FindFirstChild('SeatWeld');if weld then weld:Destroy()end
 M.Seat.Disabled=true;M.Boat:PivotTo(M.Home);M.Rider=nil;M.Started=nil
 local pier=workspace.Neighborhood.LakeFerry.BoardingPier
 if character then character:PivotTo(pier.CFrame+Vector3.new(0,4,0))end
 task.delay(.25,function()if root and root.Parent then
  if character.Parent then character:PivotTo(pier.CFrame+Vector3.new(0,4,0))end
  root.AssemblyLinearVelocity=Vector3.zero;root.AssemblyAngularVelocity=Vector3.zero;root.Anchored=false
  root:SetNetworkOwner(nil);character:PivotTo(pier.CFrame+Vector3.new(0,4,0))
  task.delay(1,function()if root.Parent then root:SetNetworkOwnershipAuto()end end)
 end end)
end
function M.Init(context)
 M.Build(workspace.Neighborhood)
 context.Interactions:Register("LakeCruise",function(player)
  if M.Rider then return false,"The launch is on a short cruise. It will be back soon."end
  local char=player.Character;local hum=char and char:FindFirstChildOfClass("Humanoid")
  if not hum or hum.Health<=0 or hum.Sit or player:GetAttribute("Carrying")then return false,"Stand up and set down any carried item first."end
  M.Rider=player;M.Started=os.clock();M.Seat.Disabled=false;char:PivotTo(M.Seat.CFrame*CFrame.new(0,2,0));M.Seat:Sit(hum)
  return true,"Enjoy the 35-second ocean cruise. Jump to leave the boat."
 end)
 game:GetService("RunService").Heartbeat:Connect(function()
  if not M.Rider then return end
  local t=os.clock()-M.Started
  if not M.Rider.Parent or t>=35 or (t>1 and(not M.Seat.Occupant or M.Seat.Occupant.Health<=0))then M.Reset();return end
  -- A closed coastal excursion returns to the same boarding pier.
  local a=math.clamp(t/35,0,1)*math.pi*2
  local pos=Vector3.new(-266+19*math.cos(a),1,42+20*math.sin(a))+(M.Offset or Vector3.zero)
  local tangent=Vector3.new(-19*math.sin(a),0,20*math.cos(a))
  M.Boat:PivotTo(CFrame.lookAt(pos,pos+tangent))
 end)
 game.Players.PlayerRemoving:Connect(function(player)if M.Rider==player then M.Reset()end end)
end
return M
