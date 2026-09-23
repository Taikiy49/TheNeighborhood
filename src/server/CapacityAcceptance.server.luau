if not game:GetService("RunService"):IsStudio()then return end
local Test=game:GetService("StudioTestService");local args=Test:GetTestArgs()
if type(args)~="table" or args.Name~="CapacityAcceptance"then return end
local ok,result=pcall(function()
 local Players=game:GetService("Players");local Houses=require(script.Parent.Services.HouseService)
 local Data=require(script.Parent.Services.PlayerDataService);local Items=require(script.Parent.Services.ItemService)
 local deadline=os.clock()+90
 repeat task.wait(0.25)until #Players:GetPlayers()==8 and workspace:GetAttribute("NeighborhoodReady") or os.clock()>deadline
 assert(#Players:GetPlayers()==8,"Expected eight actual clients")
 local seen={};local summary={}
 for _,player in ipairs(Players:GetPlayers())do
  repeat task.wait(0.1)until Houses.ByPlayer[player.UserId] and player.Character and player.Character:FindFirstChild("HumanoidRootPart") or os.clock()>deadline
  local house=assert(Houses.ByPlayer[player.UserId],"Missing house at capacity")
  assert(not seen[house.Model.Name],"Duplicate plot at capacity");seen[house.Model.Name]=true
  assert(#Items:Owned(player)==2,"Starter kit duplicated or missing")
  assert(Data:Get(player).Currency==1200,"Starting balance differs at capacity")
  table.insert(summary,{Player=player.Name,House=house.Model.Name})
 end
 local function sample(duration)
  local frames={};local connection=game:GetService("RunService").Heartbeat:Connect(function(dt)table.insert(frames,dt)end)
  task.wait(duration);connection:Disconnect();table.sort(frames)
  local total=0;for _,dt in ipairs(frames)do total+=dt end
  return {Samples=#frames,MeanServerFrameMs=total/math.max(#frames,1)*1000,P95ServerFrameMs=(frames[math.max(1,math.ceil(#frames*0.95))] or 0)*1000,ServerMemoryMb=game:GetService("Stats"):GetTotalMemoryUsageMb(),WorldInstances=#workspace.Neighborhood:GetDescendants()}
 end
 task.wait(10)
 local baseline=sample(4)
 local Vehicles=require(script.Parent.Services.VehicleService);local Pets=require(script.Parent.Services.PetService)
 for _,player in ipairs(Players:GetPlayers())do
  Data:Get(player).Currency=3000
  local purchased,why=Vehicles:Action(player,"Buy");assert(purchased,why)
  assert(Vehicles.Cars[player.UserId],"Car could not spawn at capacity")
  assert(Pets:Action(player,"Adopt"));assert(Data:Get(player).Currency==0,"Expansion purchase debit incorrect")
  local house=Houses.ByPlayer[player.UserId]
  player.Character:PivotTo(house.Model.Foundation.CFrame*CFrame.new(-12,3,-25))
 end
 local probe=Instance.new("RemoteEvent");probe.Name="NetworkProbe";probe.Parent=game.ReplicatedStorage.Neighborhood
 local reports={};probe.OnServerEvent:Connect(function(player,phase,payload)if phase=="capacity"then reports[player.UserId]=payload end end)
 workspace:SetAttribute("AdversarialNetworkTest",true)
 require(script.Parent.Services.WeatherService):Set("Rain")
 task.wait(6)
 for _,player in ipairs(Players:GetPlayers())do probe:FireClient(player,"capacity")end
 local performance=sample(8)
 for _,player in ipairs(Players:GetPlayers())do
  local car=Vehicles.Cars[player.UserId];assert(car and car.Body.Position.Y>-2 and car.Body.Position.Y<10,"Parked car suspension unstable")
  assert(Pets.Pets[player.UserId] and Pets.Pets[player.UserId].Model.Parent,"Pet missing at capacity")
  local report=reports[player.UserId];assert(report and report.RainParts==40 and report.Visible==40,"Client rain missing at capacity")
  assert(#report.Errors==0,"Client errors at capacity: "..table.concat(report.Errors,"; "))
 end
 performance.Baseline=baseline;performance.Note="Warm local Studio server alongside eight client processes; not a mobile-device benchmark or a production performance pass."
 local errors={};for _,entry in ipairs(game:GetService("LogService"):GetLogHistory())do if entry.messageType==Enum.MessageType.MessageError then table.insert(errors,entry.message)end end
 assert(#errors==0,"Application errors at capacity: "..table.concat(errors,"; "))
 probe:Destroy();workspace:SetAttribute("AdversarialNetworkTest",nil)
 return {Passed=true,Players=summary,Performance=performance,Verified={"Eight actual clients connected","Eight distinct owned houses","One starter kit per player","Correct independent currency balances","Eight purchased cars with stable parked suspension","Eight companion pets active","Eight clients each rendered forty rain streaks","No server or client application errors"}}
end)
Test:EndTest(ok and result or {Passed=false,Error=tostring(result)})
