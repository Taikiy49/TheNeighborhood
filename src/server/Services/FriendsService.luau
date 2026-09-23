local Players=game:GetService('Players')
local Run=game:GetService('RunService')
local Teleport=game:GetService('TeleportService')
local Http=game:GetService('HttpService')
local Repository=require(script.Parent.Parent.NeighborhoodRepository)
local Plots=require(game.ReplicatedStorage.Neighborhood.Shared.PlotLayout)
local Service={Parties={},ByPlayer={},Invites={},Views={},Busy={},Travel={},LastRefresh={},FriendPages={}}
local function validId(id)return type(id)=='string'and #id>0 and #id<=64 and id:match('^[%w%-]+$')end
local function memberIndex(party,uid)return table.find(party.Members,uid)end
local function usedPlots(slots)local used={};for _,slot in pairs(slots)do used[slot]=true end;return used end
function Service:PlotOptions(slots,uid)
 local result={};local owners={};for owner,slot in pairs(slots)do owners[slot]=tonumber(owner)end
 for slot=1,8 do
  local house=self.Context.Houses.ById[string.format('House%02d',slot)]
  table.insert(result,{Slot=slot,Address=house and house.Model:GetAttribute('Address')or 'Home '..slot,Side=Plots.Side(slot),Available=owners[slot]==nil,Yours=owners[slot]==uid})
 end
 return result
end
function Service:Init(context)
 self.Context=context
 local store=game:GetService('DataStoreService'):GetDataStore(Run:IsStudio()and 'NeighborhoodGroups_Development_v1'or 'NeighborhoodGroups_v1')
 if context.Data.SessionOnly then
  local memory={};store={GetAsync=function(_,k)return memory[k]end,UpdateAsync=function(_,k,fn)local v=fn(memory[k]);if v then memory[k]=v end;return v end}
 end
 self.Repository=Repository.new(store)
 self.Reserve=function()assert(not Run:IsStudio(),'Travel is available in the published Roblox game.');return Teleport:ReserveServerAsync(game.PlaceId)end
 self.Send=function(players,code,token)
  assert(not Run:IsStudio(),'Travel is available in the published Roblox game.')
  local options=Instance.new('TeleportOptions');if code then options.ReservedServerAccessCode=code end
  options:SetTeleportData({NeighborhoodTravelToken=token})
  Teleport:TeleportAsync(game.PlaceId,players,options)
 end
 Teleport.TeleportInitFailed:Connect(function(player,_,_,_,options)
  local data=options and options:GetTeleportData()
  if data and data.NeighborhoodTravelToken==self.Travel[player.UserId]then self:Recover(player,'Travel failed. Your progress is safe here. Open Friends to retry.')end
 end)
end
function Service:Recover(player,message)
 self.Travel[player.UserId]=nil;local profile=self.Context.Data:Get(player);if profile then profile._Travel=nil end
 self.Context.Notify(player,message,false);self:Broadcast()
end
function Service:Broadcast()
 for _,p in Players:GetPlayers()do if self.Context.Data:Get(p)then self.Context.Sync(p)end end
end
function Service:View(player)
 local view=self.Views[player.UserId]or {Saved={},Incoming={},Friends={}}
 local result={Saved=view.Saved,Incoming=view.Incoming,Friends=view.Friends,Error=view.Error,Travel=self.Travel[player.UserId]~=nil,Studio=Run:IsStudio(),Current=player:GetAttribute('SavedNeighborhood')}
 local pages=self.FriendPages[player.UserId];if pages then result.FriendsPage=pages.Index;result.MoreFriends=pages.Index<#pages.Pages or not pages.Cursor.IsFinished;result.PreviousFriends=pages.Index>1 end
 local party=self.Parties[self.ByPlayer[player.UserId]]
 if party then
  result.Party={Leader=party.Leader,Members={},Busy=party.Busy==true,Plots=self:PlotOptions(party.Plots,player.UserId),PlotsLocked=party.SavedId~=nil}
  for _,uid in ipairs(party.Members)do local p=Players:GetPlayerByUserId(uid);local slot=party.Plots[tostring(uid)];local house=self.Context.Houses.ById[string.format('House%02d',slot)];table.insert(result.Party.Members,{UserId=uid,Name=p and p.DisplayName or 'Neighbor',Ready=party.Ready[uid]==true,Slot=slot,Address=house.Model:GetAttribute('Address')})end
 end
 result.Invites={}
 for id,expires in pairs(self.Invites[player.UserId]or {})do local p=self.Parties[id];if p and expires>os.time()then local leader=Players:GetPlayerByUserId(p.Leader);table.insert(result.Invites,{Id=id,Name=leader and leader.DisplayName or 'Neighbor'})end end
 return result
end
function Service:Refresh(player,force)
 if not force and os.clock()-(self.LastRefresh[player.UserId]or -100)<10 then return false,'Please wait a few seconds before refreshing.'end
 self.LastRefresh[player.UserId]=os.clock()
 local prior=self.Views[player.UserId]or {Friends={}}
 local ok,result=pcall(function()
  local saved,incoming={},{}
  for id in pairs(self.Repository:Index(player.UserId))do
   local r=self.Repository:Get(id)
   if r then local count=0;for _ in pairs(r.Members)do count+=1 end
    local entry={Id=id,Title='Maple Circle '..id:sub(1,6),Count=count,Owner=r.Owner,Slot=r.Members[tostring(player.UserId)],Plots=self:PlotOptions(r.Members,player.UserId)}
    if entry.Slot then entry.Address=entry.Plots[entry.Slot].Address end
    if entry.Slot then table.insert(saved,entry)elseif r.Pending[tostring(player.UserId)]then entry.Expired=r.Pending[tostring(player.UserId)]<=os.time();table.insert(incoming,entry)end
   end
  end
  table.sort(saved,function(a,b)return a.Id<b.Id end);table.sort(incoming,function(a,b)return a.Id<b.Id end)
  return {Saved=saved,Incoming=incoming,Friends=prior.Friends or {}}
 end)
 if ok then self.Views[player.UserId]=result else prior.Error='Could not load saved neighborhoods. Refresh to try again.';self.Views[player.UserId]=prior end
 return ok,ok and 'Friends list updated.'or self.Views[player.UserId].Error
end
function Service:LoadFriends(player,direction)
 if Run:IsStudio()then return false,'Roblox friend invitations are available in the published game.'end
 local ok,list=pcall(function()
  local state=self.FriendPages[player.UserId]
  if not state or direction=='LoadFriends'then state={Cursor=Players:GetFriendsAsync(player.UserId),Pages={},Index=1};self.FriendPages[player.UserId]=state
  elseif direction=='PreviousFriends'then state.Index=math.max(1,state.Index-1)
  elseif state.Index<#state.Pages then state.Index+=1
  elseif not state.Cursor.IsFinished then state.Cursor:AdvanceToNextPageAsync();state.Index+=1 end
  if not state.Pages[state.Index]then local out={};for _,friend in state.Cursor:GetCurrentPage()do table.insert(out,{UserId=friend.Id,Name=friend.DisplayName or friend.Username})end;state.Pages[state.Index]=out end
  return state.Pages[state.Index]
 end)
 if not ok then return false,'Could not load Roblox friends. Try again.'end
 self.Views[player.UserId]=self.Views[player.UserId]or {Saved={},Incoming={}};self.Views[player.UserId].Friends=list
 return true,'Roblox friends loaded.'
end
function Service:AuthorizeArrival(player)
 if game.PrivateServerId~=''and game.PrivateServerOwnerId==0 then
  local ok,r=pcall(function()return self.Repository:Get(game.PrivateServerId)end)
  if not ok or not r or not r.Members[tostring(player.UserId)]then player:Kick('This saved neighborhood is invite-only. Join the game normally and accept your invitation first.');return false end
  player:SetAttribute('SavedNeighborhood',r.Id);player:SetAttribute('NeighborhoodSlot',r.Members[tostring(player.UserId)])
 end
 return true
end
function Service:TravelTo(players,record)
 for _,p in ipairs(players)do
  if p.Parent~=Players or not self.Context.Data:CanAct(p)or self.Travel[p.UserId]then return false,'Everyone must finish loading before travelling.'end
  if record and not record.Members[tostring(p.UserId)]then return false,'Everyone must accept this neighborhood invitation first.'end
 end
 local token=Http:GenerateGUID(false)
 for _,p in ipairs(players)do self.Travel[p.UserId]=token;self.Context.Data:Get(p)._Travel=true end
 local function restore(message)for _,p in ipairs(players)do if self.Travel[p.UserId]==token then self:Recover(p,message)end end end
 for _,p in ipairs(players)do
  local ran,saved=pcall(function()self.Context.Robbery:Release(p);return self.Context.Data:Save(p,false)end)
  if not ran or not saved then restore('Travel cancelled because saving failed. Please try again.');return false,'Your group stayed here because a save failed.'end
 end
 for _,p in ipairs(players)do if p.Parent~=Players then restore('Travel cancelled because a party member disconnected.');return false,'A member disconnected. Ready up again.'end end
 local ok=pcall(self.Send,players,record and record.Code,token)
 if not ok then restore('Travel unavailable. Your progress is safe here. Try again in the published game.');return false,'Travel could not start. Open Friends to retry.'end
 task.delay(45,function()restore('Travel timed out. Open Friends to retry.')end)
 return true,'Moving together… Your progress has been saved.'
end
function Service:Leave(player,preserveDestination)
 local id=self.ByPlayer[player.UserId];local party=self.Parties[id]
 if not party then return true,'You are not in a party.'end
 if party.Busy then return false,'Your party is preparing to travel.'end
 table.remove(party.Members,memberIndex(party,player.UserId));party.Ready[player.UserId]=nil;self.ByPlayer[player.UserId]=nil
 party.Plots[tostring(player.UserId)]=nil
 if #party.Members==0 then self.Parties[id]=nil else
  party.Leader=party.Members[1]
  if not preserveDestination then party.Ready={};party.SavedId=nil;party.ReservedCode=nil end
 end
 return true,'You left the party. Your saved neighborhoods remain available.'
end
function Service:Action(player,action,arg)
 if self.Busy[player.UserId]then return false,'Please wait for your previous request.'end
 self.Busy[player.UserId]=true
 local ok,a,b=pcall(function()return self:Handle(player,action,arg)end)
 self.Busy[player.UserId]=nil
 if not ok then a=false;b='Could not complete that request. Refresh Friends and try again.'end
 self:Broadcast();return a,b
end
function Service:Handle(player,action,arg)
 local uid=player.UserId;local id=self.ByPlayer[uid];local party=self.Parties[id]
 if action=='Refresh'then return self:Refresh(player)
 elseif action=='LoadFriends'or action=='NextFriends'or action=='PreviousFriends'then return self:LoadFriends(player,action)
 elseif action=='Create'then
  if party then return false,'You already have a party.'end
  id=Http:GenerateGUID(false);self.Parties[id]={Leader=uid,Members={uid},Ready={},Plots={[tostring(uid)]=1}};self.ByPlayer[uid]=id;return true,'Party created. Invite neighbors below.'
 elseif action=='Invite'then
  local target=type(arg)=='number'and Players:GetPlayerByUserId(arg)
  if not party or party.Leader~=uid or party.Busy or not target or target==player or self.ByPlayer[arg]or #party.Members>=8 then return false,'That neighbor cannot be invited right now.'end
  self.Invites[arg]=self.Invites[arg]or {};self.Invites[arg][id]=os.time()+120
  self.Context.Notify(target,player.DisplayName..' invited you to a party. Open Phone → Friends.',true);return true,'Party invite sent.'
 elseif action=='AcceptParty'then
  if party or not validId(arg)then return false,'Leave your current party first.'end
  local target=self.Parties[arg]
  if not target or target.Busy or #target.Members>=8 or ((self.Invites[uid]or {})[arg]or 0)<=os.time()then return false,'That party invite is no longer available.'end
  target.Plots[tostring(uid)]=assert(Plots.Nearest(usedPlots(target.Plots),target.Plots[tostring(target.Leader)]))
  table.insert(target.Members,uid);target.Ready={};target.SavedId=nil;self.ByPlayer[uid]=arg;self.Invites[uid]={};return true,'You joined the party. A nearby home is picked; you can choose another before readying up.'
 elseif action=='DeclineParty'then if type(arg)=='string'and self.Invites[uid]then self.Invites[uid][arg]=nil end;return true,'Invitation dismissed.'
 elseif action=='Leave'then return self:Leave(player)
 elseif action=='ChoosePlot'then
  if not party or party.Busy or party.SavedId then return false,'Choose a plot before your neighborhood is created.'end
  if not Plots.Valid(arg)then return false,'Choose one of the eight plots.'end
  if party.Plots[tostring(uid)]==arg then return true,'That is already your chosen plot.'end
  if usedPlots(party.Plots)[arg]then return false,'That plot belongs to another party member. Choose an available plot.'end
  party.Plots[tostring(uid)]=arg;party.Ready={};return true,'Plot selected. Everyone must ready up again for the new arrangement.'
 elseif action=='Ready'then
  if not party or party.Busy then return false,'Join a party first.'end;party.Ready[uid]=not party.Ready[uid];return true,party.Ready[uid]and 'Ready to travel.'or 'You are no longer ready.'
 elseif action=='Launch'then
  if not party or party.Leader~=uid or party.Busy then return false,'Only the party leader can move the group.'end
  local travelers={};for _,member in ipairs(party.Members)do local p=Players:GetPlayerByUserId(member);if not p or not party.Ready[member]then return false,'Every party member must be ready.'end;table.insert(travelers,p)end
  party.Busy=true;self:Broadcast()
  local success,done,message=pcall(function()
   if not party.SavedId then local code,privateId=self.Reserve();party.SavedId=privateId;party.ReservedCode=code end
   local record=self.Repository:Get(party.SavedId)or self.Repository:Create(party.SavedId,party.ReservedCode,uid,party.Members,party.Plots)
   for _,member in ipairs(party.Members)do self.Repository:Bookmark(member,record.Id)end
   for _,p in ipairs(travelers)do self:Refresh(p,true)end
   return self:TravelTo(travelers,record)
  end)
  party.Busy=false
  if not success then return false,Run:IsStudio()and 'Group travel must be tested in the published Roblox game.'or 'Could not prepare your neighborhood. Retry when ready.'end
  return done,message
 elseif action=='AcceptSaved'or action=='DeclineSaved'or action=='Return'or action=='InviteSaved'then
  local groupId=type(arg)=='table'and arg.Id or arg;if not validId(groupId)then return false,'Choose a saved neighborhood.'end
  if action=='AcceptSaved'then
   local preferred;if type(arg)=='table'then preferred=arg.Slot end
   local accepted=pcall(function()self.Repository:Accept(groupId,uid,preferred)end)
   self:Refresh(player,true)
   return accepted,accepted and 'Your home plot is saved. You can visit whenever you like.'or 'That invitation or plot is no longer available. Refresh and choose again.'
  end
  if action=='DeclineSaved'then local record=self.Repository:Get(groupId);if record and record.Members[tostring(uid)]then return false,'You already belong to this neighborhood.'end;self.Repository:Decline(groupId,uid);self:Refresh(player,true);return true,'Invitation declined.'end
  local record=self.Repository:Get(groupId);if not record or not record.Members[tostring(uid)]then return false,'You are not a member of that neighborhood.'end
  if action=='InviteSaved'then
   local target=type(arg)=='table'and arg.UserId
   if record.Owner~=uid or type(target)~='number'or target%1~=0 or target<=0 or target==uid then return false,'Choose a Roblox friend to invite.'end
   local friends=player:IsFriendsWithAsync(target);if not friends then return false,'Only your Roblox friends can receive this invitation.'end
   self.Repository:Invite(groupId,uid,target);return true,'Invite saved for 24 hours. Ask your friend to open Friends and refresh.'
  end
  if player:GetAttribute('SavedNeighborhood')==groupId then return false,'You are already in this neighborhood.'end
  return self:TravelTo({player},record)
 elseif action=='Public'then return self:TravelTo({player},nil)
 end
 return false,'Unknown friends action.'
end
function Service:Removed(player)
 local party=self.Parties[self.ByPlayer[player.UserId]];if party then party.Busy=false end
 self:Leave(player,self.Travel[player.UserId]~=nil);self.Invites[player.UserId]=nil;self.Views[player.UserId]=nil;self.Travel[player.UserId]=nil;self.LastRefresh[player.UserId]=nil;self.Busy[player.UserId]=nil;self.FriendPages[player.UserId]=nil;self:Broadcast()
end
return Service
