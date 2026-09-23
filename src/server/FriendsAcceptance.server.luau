if not game:GetService('RunService'):IsStudio()then return end
local Test=game:GetService('StudioTestService');local args=Test:GetTestArgs()
if type(args)~='table'or args.Name~='FriendsAcceptance'then return end
local function run()
 local Players=game:GetService('Players');local Http=game:GetService('HttpService')
 local Friends=require(script.Parent.Services.FriendsService)
 local Data=require(script.Parent.Services.PlayerDataService)
 local Houses=require(script.Parent.Services.HouseService)
 local Repo=require(script.Parent.NeighborhoodRepository)
 local deadline=os.clock()+60
 repeat task.wait(.2)until #Players:GetPlayers()==3 and workspace:GetAttribute('NeighborhoodReady')and Houses.ByPlayer[Players:GetPlayers()[3].UserId]or os.clock()>deadline
 local players=Players:GetPlayers();table.sort(players,function(a,b)return a.Name<b.Name end)
 assert(#players==3 and Data.SessionOnly,'Expected three isolated clients')
 local a,b,c=players[1],players[2],players[3];local verified={}
 assert(not Friends:Action(b,'AcceptParty','fabricated'),'Forged invitation accepted')
 assert(Friends:Action(a,'Create'));local id=Friends.ByPlayer[a.UserId]
 assert(not Friends:Action(a,'Create'),'Duplicate party created')
 assert(Friends:Action(a,'Invite',b.UserId));assert(Friends:Action(b,'AcceptParty',id))
 assert(not Friends:Action(b,'Launch'),'Non-leader launched')
 assert(not Friends:Action(a,'Launch'),'Unready group launched')
 assert(Friends:Action(a,'Ready'));assert(Friends:Action(b,'Ready'))
 assert(Friends:Action(a,'Invite',c.UserId));assert(Friends:Action(c,'AcceptParty',id))
 assert(not Friends.Parties[id].Ready[a.UserId],'Membership change retained stale consent')
 assert(Friends:Action(c,'Leave'));assert(Friends.Parties[id].Leader==a.UserId)
 table.insert(verified,'Explicit invitations, party leadership, readiness, membership changes and leave checks')
 local reserves=0;local sent
 Friends.Reserve=function()reserves+=1;return 'SECRET-test-code','fixture-'..Http:GenerateGUID(false)end
 Friends.Send=function(group,code,token)sent={Players=group,Code=code,Token=token}end
 assert(Friends:Action(a,'Ready'));assert(Friends:Action(b,'Ready'))
 assert(Friends:Action(a,'Launch'))
 assert(reserves==1 and #sent.Players==2 and sent.Code=='SECRET-test-code','Group transport wrong')
 local saved=Friends.Parties[id].SavedId;local record=Friends.Repository:Get(saved)
 assert(record.Members[tostring(a.UserId)]==1 and record.Members[tostring(b.UserId)]==2,'Unstable house assignment')
 assert(not Data:CanAct(a)and not Data:CanAct(b),'Travel did not block mutations')
 assert(not Http:JSONEncode(Friends:View(a)):find('SECRET'),'Reserved access code leaked to client')
 Friends:Recover(a,'Test recovery');Friends:Recover(b,'Test recovery')
 assert(Data:CanAct(a)and Data:CanAct(b),'Travel failure did not restore actions')
 assert(Friends:Action(a,'Launch'));assert(reserves==1,'Retry allocated a second neighborhood')
 Friends:Recover(a,'Test recovery');Friends:Recover(b,'Test recovery')
 table.insert(verified,'Saved group, adjacent slots, transport roster, credential privacy, mutation freeze and idempotent retry')
 assert(not Friends:Action(c,'Return',saved),'Non-member travelled')
 Friends.Send=function()error('Injected teleport failure')end
 assert(not Friends:Action(a,'Return',saved));assert(Data:CanAct(a),'Synchronous teleport failure stranded profile')
 local oldSave=Data.Save;Data.Save=function()return false end
 local called=false;Friends.Send=function()called=true end
 assert(not Friends:Action(a,'Return',saved));assert(not called and Data:CanAct(a),'Failed save allowed departure')
 Data.Save=function()error('Injected save exception')end
 assert(not Friends:Action(a,'Return',saved));assert(not called and Data:CanAct(a),'Save exception stranded profile or allowed departure')
 Data.Save=oldSave
 table.insert(verified,'Save failures abort departure; teleport failures recover; nonmembers rejected')
 Friends.Travel[a.UserId]='departing';Friends:Removed(a)
 assert(Friends.Parties[id].Leader==b.UserId and Friends.Parties[id].SavedId==saved,'Partial departure lost shared destination')
 assert(Friends:Action(b,'Launch'));assert(reserves==1,'Remaining member could not retry the original neighborhood')
 Friends:Recover(b,'Test recovery')
 table.insert(verified,'Partial departure preserves destination and transfers party leadership for retry')
 -- Independent repositories stand in for separate servers against one atomic store.
 local memory={};local calls=0
 local store={GetAsync=function(_,key)return memory[key]end,UpdateAsync=function(_,key,fn)calls+=1;local v=fn(memory[key]);if v then memory[key]=v end;return v end}
 local now=1000;local one=Repo.new(store,function()return now end,function()end);local two=Repo.new(store,function()return now end,function()end)
 one:Create('shared','private-code',101,{101,102})
 assert(not pcall(function()two:Accept('shared',103)end),'Fabricated saved invite accepted')
 one:Invite('shared',101,103);assert(two:Index(103).shared)
 local joined=two:Accept('shared',103);assert(joined.Members['103']==3);assert(two:Accept('shared',103).Members['103']==3)
 assert(not pcall(function()two:Invite('shared',102,104)end),'Member invited without founder permission')
 for uid=104,108 do one:Invite('shared',101,uid);two:Accept('shared',uid)end
 assert(not pcall(function()one:Invite('shared',101,109)end),'Ninth member admitted')
 one:Create('expiry','code',201,{201});one:Invite('expiry',201,202);now+=86401
 assert(not pcall(function()two:Accept('expiry',202)end),'Expired invite accepted')
 one:Invite('expiry',201,203);two:Decline('expiry',203);assert(not two:Index(203).expiry)
 one:Create('lastslot','code',301,{301,302,303,304,305,306,307});one:Invite('lastslot',301,308);one:Invite('lastslot',301,309)
 two:Accept('lastslot',308);assert(not pcall(function()two:Accept('lastslot',309)end),'Concurrent last-slot acceptance overfilled circle')
 for n=1,32 do one:Bookmark(999,'bookmark'..n)end
 assert(not pcall(function()one:Bookmark(999,'overflow')end),'Directory cap ignored')
 assert(two:Index(999).bookmark1 and not two:Index(999).overflow,'Overflow discarded saved circles')
 table.insert(verified,'Cross-repository invitations, durable member slots, duplicate accept, eight-member cap, expiry and decline')
 -- Reassign in reverse arrival order: saved plots do not depend on arrival order.
 Houses:Release(a);Houses:Release(b);a:SetAttribute('NeighborhoodSlot',1);b:SetAttribute('NeighborhoodSlot',2)
 assert(Houses:Assign(b).Model.Name=='House02');assert(Houses:Assign(a).Model.Name=='House01')
 a:SetAttribute('NeighborhoodSlot',nil);b:SetAttribute('NeighborhoodSlot',nil)
 table.insert(verified,'Reverse-order arrivals retain adjacent saved plots')
 local errors={};for _,entry in game:GetService('LogService'):GetLogHistory()do if entry.messageType==Enum.MessageType.MessageError then table.insert(errors,entry.message)end end
 assert(#errors==0,table.concat(errors,'; '))
 local live=not args.SkipLiveDirectory and require(script.Parent.LiveNeighborhoodTests)()or {Skipped=true,Reason='Covered separately by live directory run'}
 return {Passed=true,Verified=verified,Errors=errors,DirectoryRequests=calls,LiveDirectory=live,Transport='Injected adapter; real Roblox teleports require published-client testing'}
end
local ok,result=pcall(run);Test:EndTest(ok and result or {Passed=false,Error=tostring(result)})
