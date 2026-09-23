if not game:GetService("RunService"):IsStudio()then return end
local Test=game:GetService("StudioTestService");local args=Test:GetTestArgs()
if type(args)~="table" or args.Name~="ExplorationAcceptance"then return end
local function run()
 local Players=game:GetService("Players");local Data=require(script.Parent.Services.PlayerDataService)
 local Houses=require(script.Parent.Services.HouseService);local Items=require(script.Parent.Services.ItemService)
 local Discovery=require(script.Parent.Services.DiscoveryService);local Delivery=require(script.Parent.Services.DeliveryService)
 local Economy=require(script.Parent.Services.EconomyService);local Weather=require(script.Parent.Services.WeatherService)
 local Schema=require(script.Parent.ProfileSchema);local verified={};local deadline=os.clock()+45
 repeat task.wait(0.2)until #Players:GetPlayers()==2 and workspace:GetAttribute("NeighborhoodReady") and Houses.ByPlayer[Players:GetPlayers()[2].UserId] or os.clock()>deadline
 local players=Players:GetPlayers();assert(#players==2,"Expected two clients")
 local player=players[1];local other=players[2]
 repeat task.wait(0.1)until player.Character and player.Character:FindFirstChild("HumanoidRootPart") and other.Character and other.Character:FindFirstChild("HumanoidRootPart") or os.clock()>deadline
 player.Character.HumanoidRootPart:SetNetworkOwner(nil);other.Character.HumanoidRootPart:SetNetworkOwner(nil)
 assert(Data.SessionOnly,"Exploration tests require memory profiles")
 local profile=Data:Get(player);local before=profile.Currency
 assert(not Discovery:Claim(player),"Premature trail claim accepted")
 assert(not Discovery:Find(player,nil) and not Discovery:Find(player,{}),"Malformed discovery accepted")
 assert(not Discovery:Find(player,Discovery.Markers.Gnome2),"Remote discovery accepted")
 local forged=Instance.new("Part");forged:SetAttribute("DiscoveryId","Gnome1");forged.Parent=workspace.Neighborhood.Runtime
 assert(not Discovery:Find(player,forged),"Forged trail tag accepted");forged:Destroy()
 table.insert(verified,"Discovery rejects remote, malformed, forged and premature claims")
 local ownedBefore=#Items:Owned(player)
 for index=1,5 do
  local marker=Discovery.Markers["Gnome"..index];player.Character:PivotTo(marker.CFrame*CFrame.new(0,2,-3))
  local found,why=Discovery:Find(player,marker);assert(found,why)
  assert(not Discovery:Find(player,marker),"Repeated clue granted credit")
  if index<5 then assert(#Items:Owned(player)==ownedBefore,"Early collectible granted")end
 end
 assert(profile.DiscoveryRewardClaimed and #Items:Owned(player)==ownedBefore+1,"Trail reward missing")
 assert(not Discovery:Claim(player) and not Discovery:Claim(other),"Duplicate or foreign-progress claim accepted")
 local moon;for _,item in ipairs(Items:Owned(player))do if item.DefinitionId=="MoonGnome"then moon=item end end;assert(moon)
 local reloaded=Schema.Migrate(Data:Snapshot(player),player.UserId)
 assert(reloaded.DiscoveryRewardClaimed and reloaded.Discoveries.Gnome5 and reloaded.Collection.MoonGnome,"Discovery persistence snapshot incomplete")
 table.insert(verified,"Five physical markers yield exactly one original collectible; progress and receipt serialize")
 player.Character:PivotTo(workspace.Neighborhood.Shops.GeneralStore.Counter.CFrame*CFrame.new(0,3,-5))
 assert(not Economy:Buy(player,"MoonGnome"),"Discovery-only collectible sold in store")
 player.Character:PivotTo(workspace.Neighborhood.Shops.PawnShop.Counter.CFrame*CFrame.new(0,3,-5))
 assert(Economy:Sell(player,moon.Id));assert(profile.Collection.MoonGnome and not Items.Items[moon.Id],"Historical collection vanished on sale")
 assert(not Economy:Sell(player,moon.Id),"Collectible sold twice")
 table.insert(verified,"Exclusive collectible cannot be bought; historical collection survives sale")
 local otherProfile=Data:Get(other)
 while #otherProfile.Inventory<40 do Items:Create(other,"BasicChair")end
 for index=1,5 do local marker=Discovery.Markers["Gnome"..index];other.Character:PivotTo(marker.CFrame*CFrame.new(0,2,-3));local ok,why=Discovery:Find(other,marker);assert(ok,why)end
 assert(not otherProfile.DiscoveryRewardClaimed and #otherProfile.Inventory==40,"Full inventory lost or overflowed reward")
 assert(not Discovery:Claim(other),"Full inventory claim accepted")
 other.Character:PivotTo(workspace.Neighborhood.Shops.PawnShop.Counter.CFrame*CFrame.new(0,3,-5));assert(Economy:Sell(other,otherProfile.Inventory[1]));assert(Discovery:Claim(other));assert(#otherProfile.Inventory==40)
 table.insert(verified,"Full inventory defers trail reward without losing progress; claim succeeds once after freeing space")
 for _,kind in ipairs({"Rain","Overcast","Clear"})do assert(Weather:Set(kind));assert(workspace.Neighborhood:GetAttribute("Weather")==kind and Weather:View().Kind==kind)end
 assert(not Weather:Set("invalid") and Weather.Current=="Clear","Invalid weather changed state")
 table.insert(verified,"Weather lifecycle and replicated forecast agree; invalid weather rejected")
 local fuzzCases=0;local balance=profile.Currency
 for _,value in ipairs({false,{},0/0,math.huge,-math.huge,"",string.rep("x",1000),-1,99999})do
  local ok,bought=pcall(function()return Economy:Buy(player,value)end);assert(ok and not bought,"Malformed buy threw or succeeded");fuzzCases+=1
  local ok2,placed=pcall(function()return Items:Place(player,value,value)end);assert(ok2 and not placed,"Malformed placement threw or succeeded");fuzzCases+=1
 end
 assert(profile.Currency==balance,"Malformed requests changed currency")
 table.insert(verified,"Eighteen malformed service requests rejected without mutation or errors")
 assert(not Delivery:Start(player),"Remote parcel pickup accepted")
 local board=workspace.Neighborhood.Map.CommunityBoard
 player.Character:PivotTo(board.CFrame*CFrame.new(0,-1,-5));task.wait(0.3)
 local started,why=Delivery:Start(player);assert(started,why)
 local job=assert(Delivery.Jobs[player.UserId]);assert(job.Parcel.Parent==player.Character and player.Character:GetAttribute("CarryPose"),"Physical parcel or pose absent")
 assert(not Delivery:Start(player),"Duplicate parcel pickup accepted")
 assert(not Delivery:Complete(player,nil),"Invalid delivery accepted")
 local destination=Houses.ById[job.HouseId].Model.Mailbox.Box
 assert(not Delivery:Complete(player,destination),"Remote delivery accepted")
 local path=game:GetService("PathfindingService"):CreatePath({AgentRadius=2,AgentHeight=5,AgentCanJump=true,WaypointSpacing=7})
 path:ComputeAsync(player.Character.HumanoidRootPart.Position,destination.Position+Vector3.new(0,-1,-4));assert(path.Status==Enum.PathStatus.Success,"No path to delivery mailbox")
 local routeDeadline=os.clock()+45
 for _,waypoint in ipairs(path:GetWaypoints())do
  if waypoint.Action==Enum.PathWaypointAction.Jump then player.Character.Humanoid.Jump=true end
  player.Character.Humanoid:MoveTo(waypoint.Position)
  repeat task.wait(0.1);local delta=player.Character.HumanoidRootPart.Position-waypoint.Position
  until Vector3.new(delta.X,0,delta.Z).Magnitude<2.5 or os.clock()>routeDeadline
  assert(os.clock()<routeDeadline,"Physical parcel route timed out")
 end
 while os.clock()-job.Started<8.2 do task.wait(0.1)end
 assert(Delivery.Jobs[player.UserId],"Legitimate walking route was cancelled")
 local cash=profile.Currency;local delivered,reason=Delivery:Complete(player,destination);assert(delivered,reason)
 assert(profile.Currency==cash+180 and not job.Parcel.Parent and not player.Character:GetAttribute("CarryPose"),"Delivery reward or cleanup incorrect")
 assert(not Delivery:Complete(player,destination),"Duplicate delivery reward accepted")
 table.insert(verified,"Physical parcel carried over an actual path; exact reward, pose cleanup and duplicate rejection")
 player.Character:PivotTo(board.CFrame*CFrame.new(0,-1,-5));Delivery.Last[player.UserId]=nil
 assert(Delivery:Start(player));cash=profile.Currency;assert(Delivery:Cancel(player));assert(not Delivery:Cancel(player));assert(profile.Currency==cash)
 table.insert(verified,"Voluntary parcel cancellation removes prop without paying")
 Delivery.Last[player.UserId]=nil;assert(Delivery:Start(player));local interrupted=Delivery.Jobs[player.UserId];interrupted.Started-=9
 local mailbox=Houses.ById[interrupted.HouseId].Model.Mailbox.Box;player.Character:PivotTo(mailbox.CFrame*CFrame.new(0,1,-4))
 assert(not Delivery:Complete(player,mailbox) and not Delivery.Jobs[player.UserId],"Teleport delivery paid before periodic guard")
 assert(profile.Currency==cash,"Teleport route changed balance")
 table.insert(verified,"Immediate teleport-to-mailbox request cancels parcel without paying")
 player.Character:PivotTo(board.CFrame*CFrame.new(0,-1,-5));Delivery.Last[player.UserId]=nil;assert(Delivery:Start(player))
 player.Character.Humanoid.Health=0;Delivery:Step();assert(not Delivery.Jobs[player.UserId] and not player:GetAttribute("DeliveryAddress"),"Death retained parcel job")
 table.insert(verified,"Character death cancels parcel and clears its address")
 local live=require(script.Parent.LiveStorageTests)()
 local errors={};for _,entry in ipairs(game:GetService("LogService"):GetLogHistory())do if entry.messageType==Enum.MessageType.MessageError then table.insert(errors,entry.message)end end
 assert(#errors==0,"Application errors: "..table.concat(errors,"; "))
 return {Passed=true,Verified=verified,MalformedRequests=fuzzCases,LiveStorageTests=live,Errors=errors}
end
local ok,result=pcall(run);Test:EndTest(ok and result or {Passed=false,Error=tostring(result)})
