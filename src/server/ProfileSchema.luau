local Config=require(game.ReplicatedStorage.Neighborhood.Shared.Config)
local Definitions=require(game.ReplicatedStorage.Neighborhood.Shared.ItemDefinitions)
local Schema={Version=2}
local function integer(v,min,max)return type(v)=="number" and v==v and v%1==0 and v>=min and v<=max end
function Schema.Default()
 return {Version=2,Currency=Config.StartingCurrency,Inventory={},Items={},Collection={},Discoveries={},DiscoveryRewardClaimed=false,Incidents={},CaseTruth={},Vehicles={},Pets={},EventClaims={},Outbox={},CreditWatermarks={},CreditTotals={},NextTransfer=0,TutorialState="EnterHouse",XP=0,Reputation=0,Statistics={},Achievements={},Settings={Sound=true,ReducedMotion=false,Pranks=true},House={Locked=false,Color="Original"},LastSeen=0,FirstVisit=true}
end
function Schema.Copy(value,depth)
 depth=depth or 0;assert(depth<16,"Profile nesting exceeds limit")
 if type(value)~="table"then assert(type(value)=="string" or type(value)=="boolean" or (type(value)=="number" and value==value and math.abs(value)<1e15),"Unsupported profile value");return value end
 local result={};local count=0
 for k,v in pairs(value)do count+=1;assert(count<=5000,"Profile table exceeds limit");assert(type(k)=="string" or type(k)=="number","Invalid profile key");result[k]=Schema.Copy(v,depth+1)end
 return result
end
function Schema.Migrate(raw,userId)
 if raw==nil then return Schema.Default()end
 assert(type(raw)=="table","Corrupt profile root")
 assert(integer(raw.Version or 1,1,Schema.Version),"Unsupported profile version")
 assert(integer(raw.Currency,0,1000000000),"Corrupt currency")
 local p=Schema.Default();for key in pairs(p)do if raw[key]~=nil then p[key]=Schema.Copy(raw[key])end end
 assert(type(p.Items)=="table" and #p.Items<=Config.MaxInventory,"Corrupt inventory")
 assert(type(p.Incidents)=="table" and #p.Incidents<=Config.MaxIncidents,"Corrupt incidents")
 assert(type(p.House)=="table" and type(p.Settings)=="table","Corrupt preferences")
 assert(p.House.Boutique==nil or (type(p.House.Boutique)=="string" and #p.House.Boutique<=60),"Corrupt home style")
 assert(type(p.Vehicles)=="table" and type(p.Pets)=="table","Corrupt garage or pets")
 assert(p.Vehicles.Compact==nil or type(p.Vehicles.Compact)=="boolean","Corrupt vehicle ownership")
 assert(p.Pets.Dog==nil or type(p.Pets.Dog)=="boolean","Corrupt pet ownership")
 assert(p.Pets.Mode==nil or p.Pets.Mode=="Follow" or p.Pets.Mode=="Stay","Corrupt pet mode")
 assert(type(p.EventClaims)=="table" and #p.EventClaims<=32,"Corrupt event receipts")
 assert(type(p.Collection)=="table" and type(p.Discoveries)=="table" and type(p.DiscoveryRewardClaimed)=="boolean","Corrupt collection progress")
 for id,firstSeen in pairs(p.Collection)do assert(Definitions[id] and integer(firstSeen,0,100000000000),"Corrupt collected item")end
 for id,found in pairs(p.Discoveries)do assert(type(id)=="string" and id:match("^Gnome[1-5]$") and found==true,"Corrupt discovery progress")end
 for _,receipt in ipairs(p.EventClaims)do assert(type(receipt)=="string" and #receipt<160,"Corrupt event receipt")end
 assert(integer(p.XP,0,1000000000) and integer(p.Reputation,-10000,10000),"Corrupt progression")
 assert(type(p.TutorialState)=="string" and #p.TutorialState<64,"Corrupt tutorial")
 assert(type(p.Statistics)=="table" and type(p.Achievements)=="table","Corrupt statistics")
 for key,value in pairs(p.Statistics)do assert(type(key)=="string" and integer(value,0,1000000000),"Corrupt statistic counter")end
 assert(type(p.CaseTruth)=="table","Corrupt case ledger")
 assert(type(p.Outbox)=="table" and type(p.CreditWatermarks)=="table" and type(p.CreditTotals)=="table" and integer(p.NextTransfer,0,1000000000),"Corrupt settlement ledger")
 for source,total in pairs(p.CreditTotals)do assert(type(source)=="string" and integer(total,0,100000000000000),"Corrupt credit total")end
 for _,entry in ipairs(p.Outbox)do assert(type(entry)=="table" and integer(entry.Recipient,-100000000000,100000000000) and integer(entry.Sequence,1,p.NextTransfer) and integer(entry.Amount,1,1000000000),"Corrupt outgoing settlement")end
 for source,sequence in pairs(p.CreditWatermarks)do assert(type(source)=="string" and integer(sequence,1,1000000000),"Corrupt settlement receipt")end
 for key,value in pairs(p.CaseTruth)do assert(type(key)=="string" and integer(value,-100000000000,100000000000),"Corrupt case identity")end
 for _,key in ipairs({"Sound","ReducedMotion","Pranks"})do if p.Settings[key]==nil then p.Settings[key]=Schema.Default().Settings[key]end;assert(type(p.Settings[key])=="boolean","Corrupt preference")end
 assert(integer(p.LastSeen,0,100000000000),"Corrupt timestamp")
 local seen={};local slots={};p.Inventory={}
 for _,item in ipairs(p.Items)do
  assert(type(item)=="table" and type(item.Id)=="string" and #item.Id<=80 and not seen[item.Id],"Duplicate or corrupt item ID")
  assert(Definitions[item.DefinitionId] and item.OwnerUserId==userId,"Corrupt item ownership")
  assert(item.State=="Stored" or item.State=="Displayed" or item.State=="Fenced","Corrupt item state")
  if item.State=="Displayed"then assert(integer(item.Slot,1,6) and not slots[item.Slot],"Corrupt display placement");slots[item.Slot]=true end
  seen[item.Id]=true;table.insert(p.Inventory,item.Id)
  p.Collection[item.DefinitionId]=p.Collection[item.DefinitionId] or 0
 end
 for _,incident in ipairs(p.Incidents)do assert(type(incident)=="table" and type(incident.Id)=="string" and type(incident.Evidence)=="table" and type(incident.Status)=="string","Corrupt incident")end
 p.Version=Schema.Version;return p
end
return Schema
