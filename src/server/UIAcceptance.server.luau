local Space=require(game.ReplicatedStorage.Neighborhood.Shared.WorldSpace)
if not game:GetService("RunService"):IsStudio()then return end
local Test=game:GetService("StudioTestService");local args=Test:GetTestArgs()
if type(args)~="table"or args.Name~="UIAcceptance"then return end
local function run()
 local Players=game:GetService("Players");local Data=require(script.Parent.Services.PlayerDataService)
 local deadline=os.clock()+60
 repeat task.wait(.2)until #Players:GetPlayers()==2 and Data:Get(Players:GetPlayers()[2])or os.clock()>deadline
 assert(#Players:GetPlayers()==2 and Data.SessionOnly)
 local Building=require(script.Parent.Services.BuildingService);local Houses=require(script.Parent.Services.HouseService)
 for _,player in ipairs(Players:GetPlayers())do
  repeat task.wait(.1)until Data:Get(player)and Data:Get(player)._Restored and player.Character and player.Character:FindFirstChild("HumanoidRootPart")or os.clock()>deadline
  Data:Get(player).Currency=20000;local home=Houses.ByPlayer[player.UserId].Model;player.Character:PivotTo(home.Arrival.CFrame)
  for _,id in ipairs({"GardenRoom","Loft","Garage","Workshop"})do assert(Building:Action(player,"Buy",id))end
  player.Character:PivotTo(home.Foundation.CFrame*Space.Frame(0,4,42))
  for _,id in ipairs({"Bench","Bookcase","Planter","Desk"})do assert(Building:Action(player,"Craft",id))end
  assert(Building:Action(player,"Place",{Zone="Loft",Cell=1,Kind="Bench",Rotation=2}));assert(Building:Action(player,"SaveLayout","1"));Data.Context.Sync(player)
 end
 local guidance=require(script.Parent.GoalServerTests)(Players:GetPlayers()[1])
 deadline=os.clock()+60
 local probe=Instance.new("RemoteEvent");probe.Name="UIProbe";probe.Parent=game.ReplicatedStorage.Neighborhood
 local reports={};probe.OnServerEvent:Connect(function(player,result)reports[tostring(player.UserId)]=result end)
 workspace:SetAttribute("UIAcceptance",true)
 local received=0
 repeat task.wait(.2);received=0;for _ in pairs(reports)do received+=1 end until received==2 or os.clock()>deadline
 assert(received==2,"UI client reports timed out")
 assert(not workspace:FindFirstChild("MyHomeMarkerAnchor"),"Private marker leaked to server");local seenHomes={};for _,r in pairs(reports)do assert(r.HomeMarker and r.HomeMarker.Passed,r.Error or "Missing marker report");assert(not seenHomes[r.HomeMarker.HouseId],"Clients point to same home");seenHomes[r.HomeMarker.HouseId]=true end;local count=0;for _,report in pairs(reports)do assert(report.Passed,report.Error);count+=#report.Checks end
 workspace:SetAttribute("UIAcceptance",nil);probe:Destroy()
 return {Passed=true,ScreenChecks=count,Clients=reports,Guidance=guidance,Scope="Actual client rendering at 510px and 360px panel widths; not physical mobile/controller input"}
end
local ok,result=pcall(run);Test:EndTest(ok and result or {Passed=false,Error=tostring(result)})
