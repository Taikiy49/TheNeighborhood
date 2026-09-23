local Schema=require(script.Parent.ProfileSchema)
local Repository=require(script.Parent.ProfileRepository)
return function(options)
 options=options or {};local cycles=options.Cycles or 50;local seed=options.Seed or 88217
 local records={};local failures=0;local afterCommit=false;local lostResponses=0;local now=1000;local calls=0
 local store={}
 function store:UpdateAsync(key,callback)
  calls+=1;if failures>0 then failures-=1;error("Injected request failure")end
  local old=records[key] and Schema.Copy(records[key]);local nextValue=callback(old)
  if nextValue then records[key]=Schema.Copy(nextValue)end
  if lostResponses>0 then lostResponses-=1;error("Injected repeated lost responses after durable commit")end
  if afterCommit then afterCommit=false;error("Injected lost response after commit")end
  return nextValue and Schema.Copy(nextValue) or nil
 end
 local a=Repository.new(store,"server-a",function()return now end,function()end)
 local b=Repository.new(store,"server-b",function()return now end,function()end)
 local passed={}
 local profile=assert(a:Load(42));assert(profile.Currency==1200)
 assert(not b:Load(42));table.insert(passed,"Concurrent profile session rejected")
 profile.Currency=913;failures=2;assert(a:Save(42,profile,false));assert(records["player:42"].Data.Currency==913)
 table.insert(passed,"Transient save failures retry without resetting data")
 local revision=records["player:42"].Revision;afterCommit=true;assert(a:Save(42,profile,false));assert(records["player:42"].Revision==revision+1)
 table.insert(passed,"Lost commit response produces one revision")
 failures=3;profile.Currency=800;assert(not a:Save(42,profile,false));assert(records["player:42"].Data.Currency==913)
 table.insert(passed,"Exhausted retries preserve previous durable snapshot")
 profile.Items={{Id="original-item",DefinitionId="GoldenToilet",OwnerUserId=42,OriginalOwnerUserId=42,State="Displayed",Slot=2,Provenance={{Kind="Acquired",Time=1000}}}}
 profile.House.Locked=true;profile.TutorialState="Done";profile.XP=50
 profile.Adventures={Completed={Teaspoon=true},Runs={Teaspoon=4},BestMs={Teaspoon=43000},Rewards={TrailCompass=true},Contributions=12,Active={Id="Moon",Next=2}}
 assert(a:Save(42,profile,true));local rejoined=assert(b:Load(42))
 assert(rejoined.Currency==800 and rejoined.Items[1].Id=="original-item" and rejoined.Items[1].Slot==2 and rejoined.House.Locked and rejoined.XP==50)
 assert(rejoined.Adventures.Active.Next==2 and rejoined.Adventures.Completed.Teaspoon and rejoined.Adventures.Rewards.TrailCompass and rejoined.Adventures.Contributions==12 and rejoined.Adventures.BestMs.Teaspoon==43000,"Adventure state lost on repository reload")
 table.insert(passed,"Release and rejoin retain money, original item identity, placement, lock, progression and adventure album")
 assert(not a:Save(42,profile,false));now+=121;assert(a:Load(42));assert(not b:Save(42,profile,false))
 table.insert(passed,"Expired lease recovery rejects stale server writes")
 records["player:77"]={Data={Version=999,Currency=1200},Revision=0};assert(not a:Load(77));assert(records["player:77"].Data.Version==999)
 records["player:78"]={Data={Version=1,Currency=-1},Revision=0};assert(not a:Load(78));assert(records["player:78"].Data.Currency==-1)
 table.insert(passed,"Future schema and corrupt money rejected without overwriting storage")
 records["player:79"]={Data={Version=1,Currency=333},Revision=0};local migrated=assert(a:Load(79));assert(migrated.Version==2 and migrated.Currency==333 and migrated.XP==0)
 table.insert(passed,"Version-one migration adds defaults while preserving currency")
 local duplicate=Schema.Copy(profile);table.insert(duplicate.Items,Schema.Copy(duplicate.Items[1]));assert(not a:Save(42,duplicate,false))
 local wrongOwner=Schema.Copy(profile);wrongOwner.Items[1].OwnerUserId=99;assert(not a:Save(42,wrongOwner,false))
 table.insert(passed,"Duplicate item IDs and foreign ownership rejected")
 assert(a:EnqueueCredit(55,42,1,2900));assert(a:EnqueueCredit(55,42,1,2900));assert(a:EnqueueCredit(55,42,2,200))
 local recipient=assert(a:Load(55));assert(recipient.Currency==4300,"Credit queue duplicated or lost payment")
 assert(a:EnqueueCredit(55,42,1,2900));assert(a:EnqueueCredit(55,42,2,200));assert(a:EnqueueCredit(55,42,3,100))
 local saved,_,durable=a:Save(55,recipient,false);assert(saved and durable.Currency==4400,"Active profile did not consume new credit once")
 afterCommit=true;assert(a:EnqueueCredit(55,42,4,75));local savedAgain,_,after=a:Save(55,durable,true);assert(savedAgain and after.Currency==4475,"Lost queue response duplicated payment")
 table.insert(passed,"Durable credit inbox rejects duplicate/replayed settlements across active and offline profiles")
 local uncertain=assert(a:Load(55));assert(a:EnqueueCredit(55,42,5,125))
 lostResponses=3;assert(not a:Save(55,uncertain,false),"Expected exhausted lost responses")
 uncertain.Currency-=25 -- Legitimate local spending after the unacknowledged commit.
 local retried,_,reconciled=a:Save(55,uncertain,true)
 assert(retried and reconciled.Currency==4575,"Unacknowledged committed credit or later spending was overwritten")
 table.insert(passed,"Committed credit survives all retry responses being lost and a later stale-memory save")
 local random=Random.new(seed);local simulation=assert(a:Load(55));local expected=simulation.Currency
 for sequence=6,5+cycles do
  local source=sequence%2==0 and 42 or 99;local amount=random:NextInteger(1,200)
  assert(a:EnqueueCredit(55,source,sequence,amount));assert(a:EnqueueCredit(55,source,sequence,amount));expected+=amount
  local spent=random:NextInteger(0,25);simulation.Currency-=spent;expected-=spent
  if sequence%3==0 then lostResponses=3;assert(not a:Save(55,simulation,false))end
  local saved,_,nextProfile=a:Save(55,simulation,false);assert(saved and nextProfile.Currency==expected,"Seeded settlement simulation lost money at "..sequence)
  simulation=nextProfile
 end
 assert(a:Save(55,simulation,true));assert(b:Load(55).Currency==expected)
 table.insert(passed,tostring(cycles).." seeded settlement/spending cycles across two sources survive duplicate delivery and repeated lost acknowledgements")
 return {Passed=true,Verified=passed,Requests=calls,Seed=seed,Cycles=cycles,Backend="Injected storage; not proof of Roblox API access"}
end
