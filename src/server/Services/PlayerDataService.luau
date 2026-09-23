local Players=game:GetService("Players")
local Run=game:GetService("RunService")
local Http=game:GetService("HttpService")
local Schema=require(script.Parent.Parent.ProfileSchema)
local Repository=require(script.Parent.Parent.ProfileRepository)
local Service={Profiles={},Saving={},Flushing={},Closing=false,SessionOnly=false}
function Service:Init(context)
 self.Context=context
 local store
 local args=Run:IsStudio()and game:GetService("StudioTestService"):GetTestArgs()
 self.SessionOnly=Run:IsStudio()and (game.PlaceId==0 or (type(args)=="table"and args.Name~=nil)or workspace:GetAttribute("NeighborhoodVisualTest")==true)or false
 if self.SessionOnly then
  local memory={};store={GetAsync=function(_,k)return memory[k]end,UpdateAsync=function(_,k,fn)local value=fn(memory[k]);if value then memory[k]=value end;return value end}
 else
  store=game:GetService("DataStoreService"):GetDataStore(Run:IsStudio()and "TheNeighborhood_Development_v2"or "TheNeighborhood_Profiles_v2")
  local fixture=workspace:GetAttribute("PersistenceFixture")
  if Run:IsStudio()and type(fixture)=="string"then
   assert(#fixture==36 and fixture:match("^[%x%-]+$"),"Invalid persistence fixture namespace")
   store=game:GetService("DataStoreService"):GetDataStore("TheNeighborhood_RejoinFixtures_v1",fixture)
  end
  if Run:IsStudio()then
   local ok=pcall(function()store:GetAsync("access-probe")end)
   if not ok then self.SessionOnly=true;warn("[NEIGHBORHOOD] Studio API unavailable: session-only playtest. No persistent defaults will be written.")end
  end
 end
 self.Repository=Repository.new(store,game.JobId..":"..Http:GenerateGUID(false))
 task.spawn(function()
  while not self.Closing do task.wait(30);for _,player in ipairs(Players:GetPlayers())do if self.Profiles[player.UserId]then task.spawn(function()self:Save(player,false)end)end end end
 end)
 game:BindToClose(function()
  self.Closing=true;local pending=0
  for _,player in ipairs(Players:GetPlayers())do pending+=1;task.spawn(function()self.Context.Robbery:Release(player);self:Save(player,true);pending-=1 end)end
  local deadline=os.clock()+25;repeat task.wait(0.1)until pending==0 or os.clock()>deadline
 end)
end
function Service:Load(player)
 if self.Profiles[player.UserId]then return self.Profiles[player.UserId]end
 local profile,reason
 if self.SessionOnly then profile=Schema.Default()else profile,reason=self.Repository:Load(player.UserId)end
 -- The departing server retains its lease until PlayerRemoving finishes saving.
 -- Wait briefly for that handoff; never steal an active profile lease.
 local handoffDeadline=os.clock()+20
 while not profile and reason=="Profile is active on another server"and player.Parent==Players and os.clock()<handoffDeadline do
  task.wait(2);profile,reason=self.Repository:Load(player.UserId)
 end
 if not profile then player:Kick("Your saved neighborhood could not be opened safely. Please rejoin shortly.");warn("[PROFILE] Load rejected",player.UserId,reason);return nil end
 profile.JoinedAt=os.time();profile._SessionOnly=self.SessionOnly;profile._LastSaved=os.clock();profile._Restored=false
 profile._Recap=profile.LastSeen>0 and {LastSeen=profile.LastSeen,Message="Quiet while you were away. Your home was protected offline.",Incidents=Schema.Copy(profile.Incidents)} or nil
 self.Profiles[player.UserId]=profile
 player:SetAttribute("SaveStatus",self.SessionOnly and "Session only" or "Saved")
 return profile
end
function Service:Get(player)return self.Profiles[player.UserId]end
function Service:CanAct(player)
 local profile=self:Get(player)
 return player.Parent==Players and profile~=nil and not self.Closing and not profile._Closing and not profile._Released and not profile._Travel
end
function Service:BeginClose(player)local profile=self:Get(player);if profile then profile._Closing=true end end
function Service:Snapshot(player)
 local profile=self:Get(player);if not profile then return nil end
 local data={};for key in pairs(Schema.Default())do if profile[key]~=nil then data[key]=Schema.Copy(profile[key])end end
 data.LastSeen=os.time()
 if not profile._Restored then return data end
 data.Items={};data.Inventory={}
 for _,item in pairs(self.Context.Items.Items)do if item.OwnerUserId==player.UserId and item.State~="Sold"then
  local copy=Schema.Copy(item);copy.HolderUserId=nil;copy.HouseId=nil
  if copy.State=="Carried" or copy.State=="Escaped" or copy.State=="Dropped"then copy.State="Displayed"end
  table.insert(data.Items,copy);table.insert(data.Inventory,item.Id)
 end end
 local house=self.Context.Houses.ByPlayer[player.UserId];if house then data.House.Locked=house.Locked end
 return data
end
function Service:Save(player,release)
 if self.SessionOnly or not self:Get(player)then return true end
 local deadline=os.clock()+12
 while self.Saving[player.UserId] and os.clock()<deadline do task.wait(0.1)end
 if self.Saving[player.UserId]then return false end
 local profile=self:Get(player);if not profile or profile._Released then return true end
 self.Saving[player.UserId]=true;player:SetAttribute("SaveStatus","Saving")
 local snapshot=self:Snapshot(player)
 local ran,success,reason,durable=pcall(function()return self.Repository:Save(player.UserId,snapshot,release)end)
 if not ran then reason=tostring(success);success=false end
 self.Saving[player.UserId]=nil;player:SetAttribute("SaveStatus",success and "Saved" or "Save failed")
 if success then
  if durable then profile.Currency+=durable.Currency-snapshot.Currency;profile.CreditWatermarks=durable.CreditWatermarks;profile.CreditTotals=durable.CreditTotals end
  profile._LastSaved=os.clock();if release then profile._Released=true end
  self:FlushOutbox(player);self.Context.Sync(player)
 end
 if not success then
  warn("[PROFILE] Save failed",player.UserId,reason);self.Context.Notify(player,"Saving failed. Please stay connected while we retry.",false)
  if reason=="Profile session lock was lost" or os.clock()-profile._LastSaved>90 then player:Kick("Saving is unavailable. Rejoin shortly to protect your saved progress.")end
 end
 return success
end
function Service:FlushOutbox(player)
 local profile=self:Get(player);if not profile or self.SessionOnly or self.Flushing[player.UserId]then return end
 self.Flushing[player.UserId]=true
 -- Deliver in source sequence order. Recipient watermarks make replay harmless.
 while profile.Outbox[1]do
  local entry=profile.Outbox[1]
  if not self.Repository:EnqueueCredit(entry.Recipient,player.UserId,entry.Sequence,entry.Amount)then break end
  table.remove(profile.Outbox,1)
 end
 self.Flushing[player.UserId]=nil
end
function Service:Transfer(sourcePlayer,recipient,amount)
 local profile=self:Get(sourcePlayer);if not profile then return false end
 if self.SessionOnly then local target=self.Profiles[recipient];if target then target.Currency+=amount;return true end;return false end
 profile.NextTransfer+=1;table.insert(profile.Outbox,{Recipient=recipient,Sequence=profile.NextTransfer,Amount=amount})
 local saved=self:Save(sourcePlayer,false)
 local target=Players:GetPlayerByUserId(recipient)
 if saved and target then self:Save(target,false)end
 return saved
end
function Service:Release(player)self:BeginClose(player);self:Save(player,true);self.Profiles[player.UserId]=nil end
return Service
