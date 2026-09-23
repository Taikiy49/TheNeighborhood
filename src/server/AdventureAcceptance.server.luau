-- Integration tests run only in an explicit memory-isolated Studio session.
if not game:GetService("RunService"):IsStudio()then return end
local Test=game:GetService("StudioTestService");local args=Test:GetTestArgs()
if type(args)~="table"or args.Name~="AdventureAcceptance"then return end
local function run()
 local Players=game:GetService("Players")
 local Data=require(script.Parent.Services.PlayerDataService)
 local A=require(script.Parent.Services.AdventureService)
 local Items=require(script.Parent.Services.ItemService)
 local Economy=require(script.Parent.Services.EconomyService)
 local Schema=require(script.Parent.ProfileSchema)
 local Defs=require(game.ReplicatedStorage.Neighborhood.Shared.AdventureDefinitions)
 local verified={};local deadline=os.clock()+60
 repeat task.wait(.2)until #Players:GetPlayers()==2 and Data:Get(Players:GetPlayers()[2])and A.Context and workspace:GetAttribute("NeighborhoodReady")or os.clock()>deadline
 assert(#Players:GetPlayers()==2 and Data.SessionOnly,"Expected two memory-isolated clients")
 local p,q=table.unpack(Players:GetPlayers())
 for _,player in ipairs({p,q})do
  repeat task.wait(.1)until player.Character and player.Character:FindFirstChild("HumanoidRootPart")or os.clock()>deadline
  player.Character.HumanoidRootPart:SetNetworkOwner(nil)
 end
 local profile=Data:Get(p);local other=Data:Get(q)
 local original=profile.Currency
 local old=Schema.Default();old.Adventures=nil
 assert(Schema.Migrate(old,p.UserId).Adventures.Contributions==0,"Old profiles did not gain adventure defaults")
 for _,mutate in ipairs({
  function(v)v.Adventures.Active={Id="Teaspoon",Next=4}end,
  function(v)v.Adventures.Active={Id="fake",Next=1}end,
  function(v)v.Adventures.Completed.fake=true end,
  function(v)v.Adventures.BestMs.Teaspoon=0/0 end,
  function(v)v.Adventures.Contributions=-1 end,
  function(v)v.Adventures.Rewards.fake=true end,
 })do local bad=Schema.Default();mutate(bad);assert(not pcall(Schema.Migrate,bad,p.UserId),"Corrupt album accepted")end
 table.insert(verified,"Existing profiles migrate; six corrupt album shapes rejected")
 assert(not A:Claim(p,"StoryOwl"),"Unearned trophy granted")
 local malformed=0
 for n=1,100 do for _,value in ipairs({false,{},0/0,math.huge,-1,"",string.rep("x",1000)})do
  for _,action in ipairs({"Start","Claim","bad-action"})do local ok,accepted=pcall(function()return A:Action(p,action,value)end);assert(ok and not accepted,"Malformed request threw or succeeded");malformed+=1 end
 end end
 assert(profile.Currency==original and next(profile.Adventures.Completed)==nil,"Malformed input changed progress")
 local forged=Instance.new("Part");forged:SetAttribute("Landmark","North");forged.Parent=workspace.Neighborhood.Runtime
 assert(not A:Visit(p,forged));forged:Destroy();assert(not A:Visit(p,nil)and not A:Visit(p,{}))
 table.insert(verified,"2,100 malformed actions plus forged/malformed posts rejected without rewards")
 assert(A:Start(p,"Teaspoon"));assert(not A:Start(p,"Bandit"),"Concurrent story accepted")
 assert(not A:Visit(p,A.Markers.North),"Distant chapter accepted")
 p.Character:PivotTo(A.Markers.North.CFrame*CFrame.new(0,1,-3))
 assert(not A:Visit(p,A.Markers.North)and not A.Jobs[p.UserId],"Teleport awarded chapter")
 assert(profile.Adventures.Active.Next==1,"Interrupted travel advanced story")
 assert(A:Action(p,"Abandon"));assert(not profile.Adventures.Active)
 table.insert(verified,"Duplicate starts, remote visits and teleport advancement rejected; abandon clears only active run")
 -- These walks use actual server-owned Humanoids and the production travel guard.
 local walked=0
 local function walk(player,target)
  local root=player.Character.HumanoidRootPart;local human=player.Character.Humanoid
  local path=game:GetService("PathfindingService"):CreatePath({AgentRadius=2,AgentHeight=5,AgentCanJump=true,WaypointSpacing=7})
  path:ComputeAsync(root.Position,target.Position+Vector3.new(0,-1,-3));assert(path.Status==Enum.PathStatus.Success,"No walking path to "..target.Name)
  local untilTime=os.clock()+90
  for _,point in ipairs(path:GetWaypoints())do
   if point.Action==Enum.PathWaypointAction.Jump then human.Jump=true end
   human:MoveTo(point.Position)
   repeat task.wait(.1);local delta=root.Position-point.Position
   until Vector3.new(delta.X,0,delta.Z).Magnitude<2.5 or os.clock()>untilTime
   assert(os.clock()<untilTime,"Walking route timed out: "..target.Name)
  end
  walked+=1
 end
 for _,pair in ipairs({{p,"Teaspoon"},{q,"Bandit"}})do
  local player,id=table.unpack(pair)
  local first=A.Markers[Defs.Routes[id].Stops[1]];player.Character:PivotTo(first.CFrame*CFrame.new(0,1,-3));task.wait(.3)
  assert(A:Start(player,id))
  for index,stop in ipairs(Defs.Routes[id].Stops)do
   if index>1 then walk(player,A.Markers[stop])end
   local ok,why=A:Visit(player,A.Markers[stop]);assert(ok,why)
   if index<3 then assert(not A:Visit(player,A.Markers[stop]),"Duplicate chapter accepted")end
  end
  local album=Data:Get(player).Adventures;assert(album.Completed[id]and album.BestMs[id]>1000 and not album.Active)
 end
 assert(profile.Currency==original+90 and other.Currency==1290,"First story reward incorrect")
 table.insert(verified,"Two real clients complete different three-chapter stories on foot; four full walking legs and saved personal bests")
 q.Character:PivotTo(workspace.Neighborhood.Houses.House02.Arrival.CFrame)
 -- Checkpoint simulations deliberately resume after relocation; these are NOT timed walking evidence.
 local function checkpointRun(player,id)
  assert(A:Start(player,id))
  for _,stop in ipairs(Defs.Routes[id].Stops)do
   assert(A:Action(player,"Pause"));local snapshot=Schema.Migrate(Data:Snapshot(player),player.UserId)
   assert(snapshot.Adventures.Active and snapshot.Adventures.Active.Id==id,"Checkpoint was not serializable")
   player.Character:PivotTo(A.Markers[stop].CFrame*CFrame.new(0,1,-3))
   assert(A:Action(player,"Resume"));local ok,why=A:Visit(player,A.Markers[stop]);assert(ok,id.."/"..stop..": "..tostring(why))
  end
 end
 for _,id in ipairs(Defs.Order)do
  if not profile.Adventures.Completed[id]then A.LastContribution[p.UserId]=nil;checkpointRun(p,id)end
 end
 assert(profile.Currency==original+540,"Six unique stories paid the wrong total")
 assert(profile.Adventures.BestMs.Radio==nil,"Paused run set a personal best")
 local record=profile.Adventures.BestMs.Teaspoon;local money=profile.Currency
 for n=1,40 do A.LastContribution[p.UserId]=nil;checkpointRun(p,Defs.Order[n%6+1])end
 assert(profile.Currency==money and profile.Adventures.BestMs.Teaspoon==record,"Replays farmed first-completion cash or replaced timed record")
 assert(A.Project==4 and A.ProjectProgress==0,"Shared projects did not finish")
 for i=1,3 do assert(A.World:FindFirstChild("Project"..i),"Completed park improvement missing")end
 assert(other.Adventures.Contributions>0,"Second player's contribution was lost")
 assert(A:View(q).Project.Completed==3,"Shared completion is not visible to both clients")
 table.insert(verified,"All six stories, 40 checkpoint replays, no duplicate first rewards; paused runs cannot overwrite personal bests; three shared park improvements rendered")
 while #profile.Inventory<40 do Items:Create(p,"BasicChair")end
 assert(not A:Claim(p,"StoryOwl")and not profile.Adventures.Rewards.StoryOwl,"Full inventory consumed trophy")
 p.Character:PivotTo(workspace.Neighborhood.Shops.PawnShop.Counter.CFrame*CFrame.new(0,3,-5))
 for _,id in ipairs({"TrailCompass","StoryOwl","NeighborLantern"})do
  assert(Economy:Sell(p,profile.Inventory[1]));assert(A:Claim(p,id));assert(not A:Claim(p,id),"Duplicate trophy issued")
  local model=require(script.Parent.ItemFactory).Create(id);local visible=0;for _,piece in ipairs(model:GetDescendants())do if piece:IsA("BasePart")and piece.Transparency<1 then visible+=1 end end;assert(visible>=3,"Trophy has no visible geometry: "..id);model:Destroy()
  p.Character:PivotTo(workspace.Neighborhood.Shops.GeneralStore.Counter.CFrame*CFrame.new(0,3,-5));assert(not Economy:Buy(p,id),"Earned-only trophy sold in store")
  p.Character:PivotTo(workspace.Neighborhood.Shops.PawnShop.Counter.CFrame*CFrame.new(0,3,-5))
 end
 local owl;for _,item in ipairs(Items:Owned(p))do if item.DefinitionId=="StoryOwl"then owl=item end end
 assert(Economy:Sell(p,owl.Id));assert(profile.Collection.StoryOwl and not A:Claim(p,"StoryOwl"),"Selling trophy reset claim or collection")
 table.insert(verified,"Full inventory defers rewards; three exclusive trophies render and claim once; selling retains collection and receipt")
 assert(A:Start(q,"Moon"));A:Pause(q)
 local snap=Schema.Migrate(Data:Snapshot(q),q.UserId);assert(snap.Adventures.Active.Id=="Moon")
 other._Closing=true;assert(not A:Action(q,"Resume")and not A:Claim(q,"TrailCompass"));other._Closing=nil
 assert(A:Action(q,"Resume"));q.Character.Humanoid.Health=0;A:Step()
 assert(not A.Jobs[q.UserId]and other.Adventures.Active.Id=="Moon","Death did not preserve paused chapter")
 table.insert(verified,"Closing profiles reject actions; death pauses without losing the saved chapter")
 local live=require(script.Parent.LiveStorageTests)()
 local errors={};for _,entry in ipairs(game:GetService("LogService"):GetLogHistory())do if entry.messageType==Enum.MessageType.MessageError then table.insert(errors,entry.message)end end
 assert(#errors==0,table.concat(errors,"; "))
 return {Passed=true,Verified=verified,MalformedRequests=malformed,ActualWalkingLegs=walked,CheckpointReplaySimulations=40,LiveStorage=live,Errors=errors}
end
local ok,result=pcall(run);Test:EndTest(ok and result or {Passed=false,Error=tostring(result)})
