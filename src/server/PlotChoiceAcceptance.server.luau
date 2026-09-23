if not game:GetService('RunService'):IsStudio()then return end
local Test=game:GetService('StudioTestService');local args=Test:GetTestArgs()
if type(args)~='table'or args.Name~='PlotChoiceAcceptance'then return end
local function run()
 local Players=game:GetService('Players');local Http=game:GetService('HttpService')
 local Friends=require(script.Parent.Services.FriendsService)
 local Houses=require(script.Parent.Services.HouseService)
 local Data=require(script.Parent.Services.PlayerDataService)
 local Layout=require(game.ReplicatedStorage.Neighborhood.Shared.PlotLayout)
 local Repo=require(script.Parent.NeighborhoodRepository)
 local deadline=os.clock()+60
 repeat task.wait(.2)until #Players:GetPlayers()==3 and workspace:GetAttribute('NeighborhoodReady')and Houses.ByPlayer[Players:GetPlayers()[3].UserId]or os.clock()>deadline
 local p=Players:GetPlayers();table.sort(p,function(a,b)return a.Name<b.Name end)
 assert(#p==3 and Data.SessionOnly,'Three isolated clients required')
 local a,b,c=p[1],p[2],p[3];local verified={}
 assert(Friends:Action(a,'Create'));assert(Friends:Action(a,'ChoosePlot',5))
 local id=Friends.ByPlayer[a.UserId];local party=Friends.Parties[id]
 for _,player in {b,c}do assert(Friends:Action(a,'Invite',player.UserId));assert(Friends:Action(player,'AcceptParty',id))end
 assert(party.Plots[tostring(b.UserId)]==6 and party.Plots[tostring(c.UserId)]==7,'Friends did not receive nearby east-side plots')
 for _,player in p do assert(Friends:Action(player,'Ready'))end
 assert(Friends:Action(b,'ChoosePlot',4));assert(next(party.Ready)==nil,'Changing plot retained stale readiness')
 assert(not Friends:Action(c,'ChoosePlot',4),'Another party member displaced')
 for _,invalid in {false,{},0,9,-1,1.5,0/0,math.huge,'5'}do assert(not Friends:Action(a,'ChoosePlot',invalid),'Invalid plot accepted')end
 assert(party.Plots[tostring(a.UserId)]==5 and party.Plots[tostring(b.UserId)]==4 and party.Plots[tostring(c.UserId)]==7)
 table.insert(verified,'Nearby defaults follow the founder; own free-plot choice; occupied and malformed choices rejected; readiness reset')
 Friends.Reserve=function()return 'test-code','plot-'..Http:GenerateGUID(false)end
 Friends.Send=function()end
 for _,player in p do assert(Friends:Action(player,'Ready'))end
 assert(Friends:Action(a,'Launch'))
 local saved=Friends.Repository:Get(party.SavedId)
 assert(saved.Members[tostring(a.UserId)]==5 and saved.Members[tostring(b.UserId)]==4 and saved.Members[tostring(c.UserId)]==7,'Chosen plots not saved')
 for _,player in p do Friends:Recover(player,'Test recovery')end
 assert(not Friends:Action(b,'ChoosePlot',2),'Saved neighborhood layout changed through a party')
 table.insert(verified,'Chosen plots committed with the circle; retries and saved circles cannot silently relocate members')
 for _,player in p do Houses:Release(player)end
 for _,player in {c,b,a}do
  local slot=saved.Members[tostring(player.UserId)];player:SetAttribute('NeighborhoodSlot',slot)
  assert(Houses:Assign(player).Model.Name==string.format('House%02d',slot));player:SetAttribute('NeighborhoodSlot',nil)
 end
 table.insert(verified,'Reverse-order arrivals use selected plot numbers')
 local memory={};local store={GetAsync=function(_,k)return memory[k]end,UpdateAsync=function(_,k,fn)local v=fn(memory[k]);if v then memory[k]=v end;return v end}
 local one=Repo.new(store,nil,function()end);local two=Repo.new(store,nil,function()end)
 one:Create('choice','code',101,{101,102},{['101']=5,['102']=7})
 one:Invite('choice',101,103);one:Invite('choice',101,104)
 assert(not pcall(function()two:Accept('choice',103,7)end),'Offline member lost their plot')
 assert(two:Accept('choice',103,6).Members['103']==6)
 assert(not pcall(function()two:Accept('choice',104,6)end),'Stale last-plot selection displaced member')
 assert(two:Accept('choice',103,2).Members['103']==6,'Duplicate acceptance relocated an existing member')
 assert(two:Accept('choice',104).Members['104']==8,'Automatic invitation plot was not nearest')
 assert(not pcall(function()one:Create('bad','code',201,{201,202},{['201']=3,['202']=3})end),'Duplicate creation plots accepted')
 assert(not memory['group:bad'],'Invalid creation partially committed')
 table.insert(verified,'Saved invitations support chosen or nearest plots, atomic conflict rejection, offline reservations and idempotent acceptance')
 local combinations=0
 for anchor=1,8 do
  local used={[anchor]=true}
  for _=1,7 do
   local slot=assert(Layout.Nearest(used,anchor));assert(not used[slot])
   local distance=(Layout.Position(slot)-Layout.Position(anchor)).Magnitude
   for candidate=1,8 do if not used[candidate]then assert(distance<=(Layout.Position(candidate)-Layout.Position(anchor)).Magnitude,'Not the nearest available plot')end end
   used[slot]=true;combinations+=1
  end
  assert(Layout.Nearest(used,anchor)==nil)
 end
 for slot=1,8 do
  local position=Houses.ById[string.format('House%02d',slot)].Model.Foundation.Position
  assert((Layout.Position(slot)-Vector2.new(position.X,position.Z)).Magnitude<.01,'Plot layout drifted from real map')
 end
 table.insert(verified,'All eight starting plots and 56 nearest-choice steps match actual map geometry')
 local live=require(script.Parent.LiveNeighborhoodTests)()
 local errors={};for _,entry in game:GetService('LogService'):GetLogHistory()do if entry.messageType==Enum.MessageType.MessageError then table.insert(errors,entry.message)end end
 assert(#errors==0,table.concat(errors,'; '))
 return {Passed=true,Verified=verified,NearestChoices=combinations,LiveDirectory=live,Errors=errors,Transport='Injected adapter; no live cross-server teleport claim'}
end
local ok,result=pcall(run);Test:EndTest(ok and result or {Passed=false,Error=tostring(result)})
