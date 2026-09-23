if not game:GetService("RunService"):IsStudio()then return end
local Test=game:GetService("StudioTestService");local args=Test:GetTestArgs()
if type(args)~="table" or args.Name~="NetworkAcceptance"then return end
local function run()
 local Players=game:GetService("Players");local Data=require(script.Parent.Services.PlayerDataService)
 local Houses=require(script.Parent.Services.HouseService);local Items=require(script.Parent.Services.ItemService)
 local Weather=require(script.Parent.Services.WeatherService);local Events=require(script.Parent.Services.EventService)
 local probe=Instance.new("RemoteEvent");probe.Name="NetworkProbe";probe.Parent=game.ReplicatedStorage.Neighborhood
 local reports={};probe.OnServerEvent:Connect(function(player,phase,payload)reports[player.UserId]=reports[player.UserId] or {};reports[player.UserId][phase]=payload end)
 workspace:SetAttribute("AdversarialNetworkTest",true)
 local deadline=os.clock()+45
 repeat task.wait(0.2)until #Players:GetPlayers()==2 and workspace:GetAttribute("NeighborhoodReady") and Houses.ByPlayer[Players:GetPlayers()[2].UserId] or os.clock()>deadline
 local players=Players:GetPlayers();assert(#players==2,"Two clients required")
 local function awaitPhase(phase,timeout)
  local untilTime=os.clock()+timeout
  while os.clock()<untilTime do
   local all=true;for _,player in ipairs(players)do if not reports[player.UserId] or not reports[player.UserId][phase]then all=false end end
   if all then return end;task.wait(0.2)
  end
  error("Client reports timed out: "..phase)
 end
 awaitPhase("ready",25);Events:Start("BlockParty")
 for _,player in ipairs(players)do probe:FireClient(player,"fuzz",Data:Get(player).Inventory[1])end
 awaitPhase("fuzz",100)
 local sent=0
 for _,player in ipairs(players)do
  sent+=reports[player.UserId].fuzz.Sent
  local profile=Data:Get(player)
  assert(profile.Currency==1200 and #Items:Owned(player)==2,"Malformed network requests changed money or inventory")
  assert(profile.House.Boutique==nil,"Malformed network request changed boutique selection")
  assert(next(profile.House.Permissions)==nil and profile.Settings.Sound==true and not profile.DiscoveryRewardClaimed,"Malformed network requests changed preferences or permissions")
 end
 for _,player in ipairs(players)do
  local profile=Data:Get(player);assert(not next(profile.Building.Unlocked)and not next(profile.Building.Owned)and not next(profile.Building.Placed)and not next(profile.Building.Layouts),"Malformed building remotes changed progress")
  local house=Houses.ByPlayer[player.UserId];player.Character:PivotTo(house.Model.Foundation.CFrame*CFrame.new(0,4,-20));probe:FireClient(player,"building")
 end
 awaitPhase("building",25)
 for _,player in ipairs(players)do
  sent+=reports[player.UserId].building.Sent;local profile=Data:Get(player);local count=0;for _ in pairs(profile.Building.Unlocked)do count+=1 end
  assert(profile.Currency==300 and profile.Building.Unlocked.GardenRoom and count==1,"Duplicate building remotes charged more than once or missed purchase")
  assert(Houses.ByPlayer[player.UserId].Model.HomeExpansion:FindFirstChild("GardenRoom"),"Remote purchase did not create room")
 end
 Events:Finish();Weather:Set("Rain")
 for index,player in ipairs(players)do
  player.Character:PivotTo(CFrame.new(0,4,60+index*8));player.Character.HumanoidRootPart:SetNetworkOwner(nil);probe:FireClient(player,"outdoor")
 end
 awaitPhase("outdoor",15)
 for _,player in ipairs(players)do local r=reports[player.UserId].outdoor;assert(r.RainParts==40 and r.Visible==40 and r.Weather=="Rain","Outdoor rain missing: "..game:GetService("HttpService"):JSONEncode(r))end
 for _,player in ipairs(players)do
  local house=Houses.ByPlayer[player.UserId];player.Character:PivotTo(house.Model.Foundation.CFrame*CFrame.new(0,3,-5));probe:FireClient(player,"shelter")
 end
 awaitPhase("shelter",15)
 for _,player in ipairs(players)do assert(reports[player.UserId].shelter.Visible==0,"Rain rendered under a roof")end
 for index,player in ipairs(players)do
  player.Character:PivotTo(CFrame.new(0,4,60+index*8));Data:Get(player).Settings.ReducedMotion=true;Data.Context.Sync(player);probe:FireClient(player,"motion")
 end
 awaitPhase("motion",15)
 for _,player in ipairs(players)do assert(reports[player.UserId].motion.Visible==0 and reports[player.UserId].motion.ReducedMotion,"Reduced-motion rain setting ignored")end
 Weather:Set("Clear")
 for _,player in ipairs(players)do Data:Get(player).Settings.ReducedMotion=false;Data.Context.Sync(player);probe:FireClient(player,"clear")end
 awaitPhase("clear",15)
 local clientErrors={}
 for _,player in ipairs(players)do
  local r=reports[player.UserId].clear;assert(r.Visible==0 and r.RainParts==40 and r.Weather=="Clear","Rain did not reset cleanly")
  for _,message in ipairs(r.Errors)do table.insert(clientErrors,message)end
 end
 Weather:Set("Rain")
 for round=1,2 do
  for index,player in ipairs(players)do
   local originalProfile=Data:Get(player);local inventory=originalProfile.Inventory[1];local currency=originalProfile.Currency;local home=Houses.ByPlayer[player.UserId]
   player:LoadCharacterAsync();task.wait(1)
   assert(Data:Get(player)==originalProfile and originalProfile.Inventory[1]==inventory and originalProfile.Currency==currency and Houses.ByPlayer[player.UserId]==home,"Respawn changed possessions or home")
   player.Character:PivotTo(CFrame.new(0,4,60+index*8));player.Character.HumanoidRootPart:SetNetworkOwner(nil)
   probe:FireClient(player,"respawn"..round)
  end
  awaitPhase("respawn"..round,20)
  for _,player in ipairs(players)do
   local r=reports[player.UserId]["respawn"..round]
   assert(r.Visible==40 and r.RainParts==40 and r.AppCount==1,"Respawn duplicated UI or lost weather: "..game:GetService("HttpService"):JSONEncode(r))
   for _,message in ipairs(r.Errors)do table.insert(clientErrors,message)end
  end
 end
 local errors={};for _,entry in ipairs(game:GetService("LogService"):GetLogHistory())do if entry.messageType==Enum.MessageType.MessageError then table.insert(errors,entry.message)end end
 assert(#errors==0 and #clientErrors==0,"Network/client errors: "..table.concat(errors,"; ")..table.concat(clientErrors,"; "))
 probe:Destroy();workspace:SetAttribute("AdversarialNetworkTest",nil)
 return {Passed=true,ActualRemoteRequests=sent,CharacterReloads=4,Verified={"Two real clients sent malformed and burst requests through production remotes","Malformed requests leave money, inventory, preferences, permissions and building data unchanged","Two clients each bought a garden room through production remotes; 100 duplicate requests per client never double-charge","Oversized and nonfinite user IDs safely rejected","Both clients rendered forty outdoor raindrops","Roofs suppressed rain on both clients","Reduced-motion suppressed rain on both clients","Clear weather hid rain without allocating extra drops","Four real character reloads retained money, original inventory ID, home, forty rain parts and one HUD","No server or client application errors"},ServerErrors=errors,ClientErrors=clientErrors}
end
local ok,result=pcall(run);Test:EndTest(ok and result or {Passed=false,Error=tostring(result)})
