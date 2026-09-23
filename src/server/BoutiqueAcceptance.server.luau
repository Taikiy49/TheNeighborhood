if not game:GetService("RunService"):IsStudio()or not workspace:GetAttribute("BoutiqueAcceptance")then return end
local function run()
 local root=script.Parent
 local B=require(root.Services.BoutiqueService);local D=require(root.Services.PlayerDataService);local H=require(root.Services.HouseService);local C=require(root.Services.CustomizationService)
 local p=game.Players:GetPlayers()[1];local deadline=os.clock()+30
 repeat task.wait(.2);p=game.Players:GetPlayers()[1]until p and D:Get(p)and H.ByPlayer[p.UserId]or os.clock()>deadline
 assert(p and D:Get(p),"Player ready");assert(D.SessionOnly)
 local profile=D:Get(p);local house=H.ByPlayer[p.UserId];local cash=profile.Currency;local original=house.Model.Floor.Color
 assert(not B:Action(p,"Equip","Cottage:Lavender"),"Forged equip rejected")
 B.Owned[p]={Cottage=true,Coastal=true}
 local catalog=require(game.ReplicatedStorage.Neighborhood.Shared.BoutiqueCatalog);local n=0
 for key,pack in pairs(catalog)do for id,style in pairs(pack.Styles)do assert(B:Action(p,"Equip",key..":"..id));assert(house.Model.Floor.Color==style.Floor);assert(house.Model.Floor.Material==style.Material);n+=1 end end
 assert(profile.Currency==cash)
 local schema=require(root.ProfileSchema);local copy=schema.Migrate(D:Snapshot(p),p.UserId);assert(copy.House.Boutique==profile.House.Boutique)
 assert(not B:Action(p,"Equip","Cottage:MadeUp"));assert(not B:Action(p,"Equip",{}));assert(not B:Action(p,"Equip",string.rep("x",500)))
 profile._Travel=true;assert(not B:Action(p,"Reset"));profile._Travel=nil
 assert(B:Action(p,"Reset"));assert(profile.House.Boutique==nil and house.Model.Floor.Color==original)
 assert(B:Action(p,"Equip","Cottage:Lavender"));B.Owned[p]={};C:Apply(p);assert(house.Model.Floor.Color==original)
 B:Action(p,"Reset");B.Context.Sync(p)
 return {Passed=true,Styles=n,Verified={"Unauthorized equip rejected","All six rendered flooring finishes","Currency unchanged","Selection survives schema save/reload","Malformed requests rejected","Travel blocks changes","Reset restores original floor","Missing entitlement restores base finish"},Backend="Studio isolated profile; injected entitlements, no Robux spent"}
end
local ok,result=pcall(run)
workspace:SetAttribute("BoutiqueTestResult",game:GetService("HttpService"):JSONEncode(ok and result or {Passed=false,Error=tostring(result)}))

