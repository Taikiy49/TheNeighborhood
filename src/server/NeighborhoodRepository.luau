-- Server-only directory. Access codes never enter player profiles or remote payloads.
local Repo={};Repo.__index=Repo
local Plots=require(game.ReplicatedStorage.Neighborhood.Shared.PlotLayout)
local function copy(v)if type(v)~='table'then return v end;local t={};for k,x in pairs(v)do t[k]=copy(x)end;return t end
function Repo.new(store,clock,pause)return setmetatable({Store=store,Clock=clock or os.time,Pause=pause or task.wait},Repo)end
function Repo:Call(fn)
 for n=1,3 do local ok,r=pcall(fn);if ok then return r end;if n<3 then self.Pause(n)end end
 error('Neighborhood directory unavailable. Try again shortly.',0)
end
local fresh=Instance.new('DataStoreGetOptions');fresh.UseCache=false
function Repo:Get(id)return self:Call(function()return self.Store:GetAsync('group:'..id,fresh)end)end
function Repo:Index(uid)return self:Call(function()return self.Store:GetAsync('user:'..uid,fresh)end)or {}end
function Repo:Bookmark(uid,id)
 self:Call(function()return self.Store:UpdateAsync('user:'..uid,function(old)
  local t=copy(old or {});local count=0;for _ in pairs(t)do count+=1 end
  assert(t[id]or count<32,'Your neighborhood list is full. Decline old invitations first.')
  t[id]=self.Clock();return t
 end)end)
end
function Repo:Create(id,code,owner,members,choices)
 assert(#members>=1 and #members<=8,'A neighborhood holds eight members.')
 local result=self:Call(function()return self.Store:UpdateAsync('group:'..id,function(old)
  if old then assert(old.Owner==owner,'Neighborhood collision');return old end
  local r={Id=id,Code=code,Owner=owner,Created=self.Clock(),Members={},Pending={}}
  local used={}
  for _,uid in ipairs(members)do
   local slot=choices and choices[tostring(uid)]
   if slot~=nil then assert(Plots.Valid(slot)and not used[slot],'Invalid or duplicate plot');r.Members[tostring(uid)]=slot;used[slot]=true end
  end
  local seen={}
  for _,uid in ipairs(members)do
   local key=tostring(uid);assert(not seen[key],'Duplicate member');seen[key]=true
   if not r.Members[key]then local slot=assert(Plots.Nearest(used,r.Members[tostring(owner)]));r.Members[key]=slot;used[slot]=true end
  end
  return r
 end)end)
 for _,uid in ipairs(members)do self:Bookmark(uid,id)end
 return result
end
function Repo:Invite(id,owner,target)
 local result=self:Call(function()return self.Store:UpdateAsync('group:'..id,function(old)
  assert(old and old.Owner==owner,'Only the founder can invite members.')
  local r=copy(old);assert(not r.Members[tostring(target)],'Already a member.')
  local count=0;for _ in pairs(r.Members)do count+=1 end;assert(count<8,'This neighborhood has eight members.')
  local pending=0;for uid,expires in pairs(r.Pending)do if expires<=self.Clock()then r.Pending[uid]=nil else pending+=1 end end
  assert(pending<16 or r.Pending[tostring(target)],'Too many pending invitations.')
  r.Pending[tostring(target)]=self.Clock()+86400;return r
 end)end)
 self:Bookmark(target,id);return result
end
function Repo:Accept(id,uid,preferred)
 assert(preferred==nil or Plots.Valid(preferred),'Invalid plot choice.')
 local r=self:Call(function()return self.Store:UpdateAsync('group:'..id,function(old)
  assert(old,'Neighborhood missing.');local nextRecord=copy(old);local key=tostring(uid)
  if nextRecord.Members[key]then return nextRecord end
  assert((nextRecord.Pending[key]or 0)>self.Clock(),'Invitation expired or unavailable.')
  local used={};for _,slot in pairs(nextRecord.Members)do used[slot]=true end
  local slot=preferred or Plots.Nearest(used,nextRecord.Members[tostring(nextRecord.Owner)])
  assert(slot and not used[slot],'That plot is reserved or the neighborhood is full.')
  nextRecord.Members[key]=slot;nextRecord.Pending[key]=nil;return nextRecord
 end)end)
 self:Bookmark(uid,id);return r
end
function Repo:Decline(id,uid)
 self:Call(function()return self.Store:UpdateAsync('group:'..id,function(old)
  if not old then return nil end;local r=copy(old);r.Pending[tostring(uid)]=nil;return r
 end)end)
 self:Call(function()return self.Store:UpdateAsync('user:'..uid,function(old)local r=copy(old or {});r[id]=nil;return r end)end)
end
return Repo
