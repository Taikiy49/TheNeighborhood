if not game:GetService("RunService"):IsStudio()then return end
local Test=game:GetService("StudioTestService");local args=Test:GetTestArgs()
if type(args)~="table"or args.Name~="BoutiqueRegression"then return end
local function run()
 local Players=game:GetService("Players");local root=script.Parent
 local B=require(root.Services.BoutiqueService);local D=require(root.Services.PlayerDataService)
 local H=require(root.Services.HouseService);local C=require(root.Services.CustomizationService)
 local Schema=require(root.ProfileSchema);local Catalog=require(game.ReplicatedStorage.Neighborhood.Shared.BoutiqueCatalog)
 local deadline=os.clock()+50
 repeat task.wait(.2)until #Players:GetPlayers()==2 and H.ByPlayer[Players:GetPlayers()[2].UserId]or os.clock()>deadline
 local players=Players:GetPlayers();assert(#players==2 and D.SessionOnly,"Two isolated profiles required")
 local p,q=players[1],players[2]
 repeat task.wait(.1)until not B.Busy[p]and not B.Busy[q]or os.clock()>deadline
 assert(not B.Busy[p]and not B.Busy[q],"Initial ownership check timeout")
 local actual=B.OwnsPass;local calls=0;local owned=false;local outage=false
 B.OwnsPass=function(_,_,_)calls+=1;if outage then error("Injected ownership outage")end;return owned end
 B.Owned[p]={};B.Owned[q]={};assert(B:Refresh(p))
 local profile=D:Get(p);local house=H.ByPlayer[p.UserId];local neighbor=H.ByPlayer[q.UserId]
 local cash=profile.Currency;local neighborFloor=neighbor.Model.Floor.Color
 local originalFloor=house.Model.Floor.Color;local originalMaterial=house.Model.Floor.Material
 local originals={};for _,part in ipairs(house.Model:GetChildren())do if part:IsA("BasePart")then originals[part]=part.Color end end
 local verified={}
 assert(not B:Action(p,"Equip","Cottage:Lavender"))
 local before=calls;assert(not B:PurchaseFinished(p,Catalog.Cottage.PassId,false));assert(not B:PurchaseFinished(p,-123,true));assert(calls==before)
 assert(B:PurchaseFinished(p,Catalog.Cottage.PassId,true));assert(not B.Owned[p].Cottage,"Callback alone granted entitlement")
 table.insert(verified,"Cancellation, unrelated IDs and false ownership never grant purchases")
 owned=true;assert(B:PurchaseFinished(p,Catalog.Cottage.PassId,true));assert(B.Owned[p].Cottage and B.Owned[p].Coastal)
 assert(not B:Action(q,"Equip","Cottage:Lavender"),"Entitlement leaked between players")
 outage=true;assert(not B:Refresh(p));assert(B.Owned[p].Cottage,"Verified ownership lost on transient outage")
 assert(not B:Refresh(q));assert(not B:Action(q,"Equip","Cottage:Lavender"),"Outage granted unverified ownership")
 outage=false;owned=false;assert(B:Refresh(p));assert(not B.Owned[p].Cottage)
 table.insert(verified,"Ownership verification, API outage behavior, revocation and player isolation")
 -- Reproduce a purchase completion arriving during a slow, stale ownership request.
 local entered=false;local release=false;local finished=false;local first=true
 B.OwnsPass=function()
  calls+=1
  if first then first=false;entered=true;repeat task.wait()until release;return false end
  return true
 end
 local raceCalls=calls
 task.spawn(function()assert(B:Refresh(p));finished=true end)
 repeat task.wait()until entered
 assert(not B:PurchaseFinished(p,Catalog.Cottage.PassId,true));release=true
 local untilTime=os.clock()+10;repeat task.wait()until finished or os.clock()>untilTime
 assert(finished and B.Owned[p].Cottage and B.Owned[p].Coastal and calls-raceCalls>=4,"Busy refresh lost purchase recheck")
 table.insert(verified,"Purchase completion during a blocked ownership lookup queues a fresh check")
 B.OwnsPass=function()calls+=1;return true end
 B.LastRefresh[p]=nil;assert(B:Action(p,"Refresh"));before=calls;assert(not B:Action(p,"Refresh"));assert(calls==before,"Throttled refresh called API")
 local styles=0;local textureChecks=0
 for round=1,100 do
  for key,pack in pairs(Catalog)do for id,style in pairs(pack.Styles)do
   assert(B:Action(p,"Equip",key..":"..id));styles+=1
   assert(house.Model.Floor.Color==style.Floor and house.Model.Floor.Material==style.Material)
   for _,part in ipairs(house.Model:GetChildren())do
    if part:IsA("BasePart")and (part.Name:find("Wall")or part.Name=="FrontSill"or part.Name=="FrontHeader"or part.Name=="Gable")then
     assert(part.Color==style.Wall)
     for _,texture in ipairs(part:GetChildren())do if texture:IsA("Texture")and texture.Name:match("^HiggsfieldSiding")then assert(texture.Color3==style.Wall);textureChecks+=1 end end
    end
   end
  end end
  if round%10==0 then task.wait()end
 end
 assert(profile.Currency==cash and neighbor.Model.Floor.Color==neighborFloor,"Cosmetic affected economy or neighbor")
 local copy=Schema.Migrate(D:Snapshot(p),p.UserId);assert(copy.House.Boutique==profile.House.Boutique)
 local corrupt=Schema.Copy(copy);corrupt.House.Boutique={};assert(not pcall(Schema.Migrate,corrupt,p.UserId))
 table.insert(verified,"600 style equips preserve balances, neighbor appearance, walls, textures and floor materials")
 local invalid=0;local bad={false,{},0/0,math.huge,12,"Unknown:Bad","Cottage:Bad",string.rep("x",1000)}
 for _=1,100 do for _,value in ipairs(bad)do assert(not B:Action(p,"Equip",value));invalid+=1 end end
 profile._Travel=true;assert(not B:Action(p,"Reset"));profile._Travel=nil
 assert(B:Action(p,"Reset"));assert(not profile.House.Boutique and house.Model.Floor.Color==originalFloor and house.Model.Floor.Material==originalMaterial)
 for part,color in pairs(originals)do assert(part.Color==color,"Original exterior not restored")end
 assert(B:Action(p,"Equip","Cottage:Lavender"));assert(C:Change(p,"Color","Mint"));assert(not profile.House.Boutique)
 assert(B:Action(p,"Equip","Coastal:BlueHour"));assert(C:Change(p,"Floor","Tile"));assert(not profile.House.Boutique)
 table.insert(verified,"800 malformed requests rejected; travel blocked; ordinary customization and reset remove cosmetic overlay")
 table.insert(verified,"Saved selection round-trip and corrupt preference rejection")
 B:Action(p,"Reset");B.OwnsPass=actual;B.Owned[p]={};B.Owned[q]={}
 local errors={};for _,entry in ipairs(game:GetService("LogService"):GetLogHistory())do if entry.messageType==Enum.MessageType.MessageError then table.insert(errors,entry.message)end end
 assert(#errors==0,table.concat(errors,";"))
 return {Passed=true,StyleEquips=styles,TextureChecks=textureChecks,MalformedRequests=invalid,OwnershipAdapterCalls=calls,Verified=verified,Errors=errors,Scope="Two actual Studio clients; injected ownership adapter, no purchase or Robux charge"}
end
local ok,result=pcall(run);Test:EndTest(ok and result or {Passed=false,Error=tostring(result)})

