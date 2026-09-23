local Repository=require(script.Parent.ProfileRepository)
return function()
 local api=game:GetService("DataStoreService"):GetDataStore("TheNeighborhood_AutomatedTests_v2")
 local prefix=game:GetService("HttpService"):GenerateGUID(false)..":"
 local store={}
 function store:UpdateAsync(key,callback)return api:UpdateAsync(prefix..key,callback)end
 local first=Repository.new(store,"test-server-one")
 local second=Repository.new(store,"test-server-two")
 local ok,result=pcall(function()
  local profile=assert(first:Load(42));profile.Currency=731;profile.XP=25
  profile.Items={{Id="test-original-item",DefinitionId="GoldenToilet",OwnerUserId=42,OriginalOwnerUserId=42,State="Displayed",Slot=2,Provenance={{Kind="Acquired",Time=os.time()}}}}
  profile.House.Locked=true;profile.House.Boutique="Cottage:Lavender"
  profile.Discoveries={Gnome1=true,Gnome2=true,Gnome3=true,Gnome4=true,Gnome5=true};profile.DiscoveryRewardClaimed=true;profile.Collection.MoonGnome=os.time()
  assert(not second:Load(42),"Live concurrent session was accepted")
  assert(first:Save(42,profile,true),"Live save failed")
  local loaded=assert(second:Load(42));assert(loaded.Currency==731 and loaded.XP==25 and loaded.Items[1].Id=="test-original-item" and loaded.Items[1].Slot==2 and loaded.House.Locked,"Live reload changed data")
  assert(loaded.House.Boutique=="Cottage:Lavender","Live boutique selection lost")
  assert(loaded.DiscoveryRewardClaimed and loaded.Discoveries.Gnome5 and loaded.Collection.MoonGnome,"Live discovery/collection persistence lost")
  assert(first:EnqueueCredit(42,99,1,50));assert(first:EnqueueCredit(42,99,1,50))
  local saved,_,credited=second:Save(42,loaded,true);assert(saved and credited.Currency==781,"Live queued settlement duplicated or lost")
  return {Passed=true,Backend="Roblox DataStore: isolated GUID-prefixed fixtures",Verified={"Actual UpdateAsync profile creation","Cross-session lock rejection","Save/reload of currency, XP, original item ID, display slot and lock","Discovery progress, reward receipt and historical collection survive reload","Duplicate queued settlement pays once","Session release","Boutique selection survives live DataStore release/reload"}}
 end)
 local cleaned,cleanupError=pcall(function()api:RemoveAsync(prefix.."player:42")end)
 if not ok then error(result)end
 result.FixtureRemoved=cleaned;result.CleanupError=not cleaned and tostring(cleanupError) or nil
 return result
end
