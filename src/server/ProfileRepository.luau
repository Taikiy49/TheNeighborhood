local Schema=require(script.Parent.ProfileSchema)
local Http=game:GetService("HttpService")
local Repository={};Repository.__index=Repository
local function consumeInbox(data,inbox)
 for source,credit in pairs(inbox or {})do
  if credit.Sequence>(data.CreditWatermarks[source] or 0)then data.Currency+=credit.Amount;data.CreditWatermarks[source]=credit.Sequence;data.CreditTotals[source]=(data.CreditTotals[source] or 0)+credit.Amount end
 end
end
function Repository.new(store,token,clock,pause)return setmetatable({Store=store,Token=token,Clock=clock or os.time,Pause=pause or task.wait,Lease=120},Repository)end
function Repository:Retry(callback)
 local last
 for attempt=1,3 do local ok,result=pcall(callback);if ok then return true,result end;last=tostring(result);if attempt<3 then self.Pause(attempt)end end
 return false,last
end
function Repository:Load(userId)
 local reason
 local ok,record=self:Retry(function()return self.Store:UpdateAsync("player:"..userId,function(old)
  reason=nil
  if old and (type(old)~="table" or type(old.Data)~="table")then reason="Corrupt storage envelope";return nil end
  if old and old.Session and old.Session.Token~=self.Token and old.Session.Expires>self.Clock()then reason="Profile is active on another server";return nil end
  local valid,data=pcall(Schema.Migrate,old and old.Data,userId)
  if not valid then reason=tostring(data);return nil end
  consumeInbox(data,old and old.Inbox)
  return {Data=data,Inbox={},Revision=old and old.Revision or 0,Session={Token=self.Token,Expires=self.Clock()+self.Lease}}
 end)end)
 if not ok then return nil,record end
 if reason or not record or not record.Session or record.Session.Token~=self.Token then return nil,reason or "Profile lock not acquired"end
 return Schema.Copy(record.Data)
end
function Repository:Save(userId,snapshot,release)
 local valid,data=pcall(Schema.Migrate,snapshot,userId);if not valid then return false,tostring(data)end
 local writeId=Http:GenerateGUID(false);local reason
 local ok,record=self:Retry(function()return self.Store:UpdateAsync("player:"..userId,function(old)
  reason=nil
  if old and old.WriteId==writeId then return old end
  if not old or not old.Session or old.Session.Token~=self.Token or old.Session.Expires<=self.Clock()then reason="Profile session lock was lost";return nil end
  local outgoing=Schema.Copy(data)
  -- A previous save may have committed a credit even when every acknowledgement was lost.
  -- Preserve that income while retaining legitimate local spending since the caller's snapshot.
  for source,total in pairs(old.Data.CreditTotals or {})do
   local unseen=total-(outgoing.CreditTotals[source] or 0)
   if unseen>0 then outgoing.Currency+=unseen;outgoing.CreditTotals[source]=total;outgoing.CreditWatermarks[source]=math.max(outgoing.CreditWatermarks[source] or 0,old.Data.CreditWatermarks[source] or 0)end
  end
  consumeInbox(outgoing,old.Inbox)
  return {Data=outgoing,Inbox={},Revision=(old.Revision or 0)+1,WriteId=writeId,Session=not release and {Token=self.Token,Expires=self.Clock()+self.Lease} or nil}
 end)end)
 return ok and not reason and record~=nil and record.WriteId==writeId,reason or (not ok and tostring(record)) or nil,ok and record and record.Data or nil
end
function Repository:EnqueueCredit(recipient,source,sequence,amount)
 local accepted=false
 local ok,result=self:Retry(function()return self.Store:UpdateAsync("player:"..recipient,function(old)
  accepted=false
  local valid,data=pcall(Schema.Migrate,old and old.Data,recipient);if not valid then return nil end
  old=old or {Data=data,Revision=0};old.Inbox=old.Inbox or {}
  local key=tostring(source);local pending=old.Inbox[key]
  local latest=math.max(data.CreditWatermarks[key] or 0,pending and pending.Sequence or 0)
  if sequence>latest then old.Inbox[key]={Sequence=sequence,Amount=(pending and pending.Amount or 0)+amount}end
  accepted=true;return old
 end)end)
 return ok and accepted and result~=nil
end
return Repository
