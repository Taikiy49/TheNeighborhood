local Repository=require(script.Parent.NeighborhoodRepository)
return function()
 if game:GetService("RunService"):IsStudio() and game.PlaceId==0 then
  return {Skipped=true,Passed=false,Reason="Unpublished local place: real Roblox DataStore verification requires an authenticated published place."}
 end
 local api=game:GetService('DataStoreService'):GetDataStore('NeighborhoodGroups_AutomatedTests_v1')
 local prefix=game:GetService('HttpService'):GenerateGUID(false)..':'
 local keys={};local store={}
 function store:GetAsync(key,options)return api:GetAsync(prefix..key,options)end
 function store:UpdateAsync(key,fn)keys[key]=true;return api:UpdateAsync(prefix..key,fn)end
 local a=Repository.new(store);local b=Repository.new(store)
 local ok,result=pcall(function()
  a:Create('circle','fixture-code',101,{101})
  a:Invite('circle',101,102)
  assert(b:Index(102).circle,'Cross-server invitation index missing')
  assert(b:Accept('circle',102).Members['102']==2,'Live acceptance failed')
  local reloaded=Repository.new(store):Get('circle')
  assert(reloaded.Code=='fixture-code'and reloaded.Members['101']==1 and reloaded.Members['102']==2,'Directory reload changed membership')
  assert(b:Accept('circle',102).Members['102']==2,'Repeated acceptance reassigned plot')
  a:Invite('circle',101,103);b:Decline('circle',103);assert(not b:Index(103).circle)
  a:Create('chosen','fixture-code',201,{201,202},{['201']=5,['202']=7})
  a:Invite('chosen',201,203);assert(b:Accept('chosen',203,6).Members['203']==6)
  local chosen=Repository.new(store):Get('chosen')
  assert(chosen.Members['201']==5 and chosen.Members['202']==7 and chosen.Members['203']==6,'Chosen plot persistence failed')
  return {Passed=true,Verified={'Live directory creation','Invitation visible through independent repository','Accepted membership and stable plots reload','Duplicate acceptance is idempotent','Decline clears invitation index','Chosen party and invitation plots persist across repository reload'},Backend='Roblox DataStore; isolated GUID-prefixed fixtures'}
 end)
 local removed=true;for key in pairs(keys)do local cleaned=pcall(function()api:RemoveAsync(prefix..key)end);removed=removed and cleaned end
 if not ok then error(result)end;result.FixturesRemoved=removed;return result
end
