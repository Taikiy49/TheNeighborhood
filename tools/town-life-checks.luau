-- Run as a normal server Script only in an isolated Studio session.
local R=game.ServerScriptService.Neighborhood
local D=require(R.Services.PlayerDataService)
local V=require(R.Services.VehicleService)
local Y=require(R.YardService)
local S=require(R.ProfileSchema)
local C=require(game.ReplicatedStorage.Neighborhood.Shared.VehicleCatalog)
local YC=require(game.ReplicatedStorage.Neighborhood.Shared.YardCatalog)
local p=game.Players:GetPlayers()[1]
local profile=D:Get(p);assert(D.SessionOnly)
local results={};local function test(name,f)local ok,e=pcall(f);table.insert(results,{name=name,pass=ok,error=not ok and tostring(e)or nil});print("TOWN CHECK",name,ok,e)end
test("Starter cash and empty ownership",function()assert(profile.Currency==250);assert(not next(profile.Vehicles.Owned));assert(not next(profile.Yard.Owned))end)
test("Remote showroom rejected",function()assert(not V:Action(p,"Buy","Bicycle"))end)
p.Character:PivotTo(workspace.Neighborhood.CoastalWorld.CommercialStrip.CarShowroom.Floor.CFrame*CFrame.new(0,5,0))
test("Catalog and funds restrictions",function()assert(not V:Action(p,"Buy","Unknown"));assert(not V:Action(p,"Buy","Bicycle"));profile.Currency=1000000;assert(not V:Action(p,"Buy","CoastGT"))end)
profile.XP=100000
for _,id in ipairs(C.Order)do
 test("Buy and duplicate "..id,function()local before=profile.Currency;assert(V:Action(p,"Buy",id));assert(profile.Currency==before-C.Items[id].Price);assert(not V:Action(p,"Buy",id))end)
 test("Spawn "..id,function()local ok,e=V:Spawn(p);assert(ok,e);assert(V.Cars[p.UserId].Model:GetAttribute("VehicleId")==id);V:Remove(p)end)
 test("Half resale and repeat rejected "..id,function()local before=profile.Currency;assert(V:Action(p,"Sell",id));assert(profile.Currency==before+math.floor(C.Items[id].Price*.5));assert(not V:Action(p,"Sell",id))end)
end
local house=Y.Context.Houses.ByPlayer[p.UserId].Model;p.Character:PivotTo(house.PersonalYard.YardLawn.CFrame*CFrame.new(0,5,0))
for _,id in ipairs(YC.Order)do test("Garden unlock/place "..id,function()assert(Y:Action(p,"Buy",id));assert(not Y:Action(p,"Buy",id));assert(Y:Action(p,"Place","1:"..id..":3"));assert(house.PersonalYard.Decor.Slot1)end)end
test("Garden slots and invalid inputs",function()for i=1,6 do assert(Y:Action(p,"Place",i..":Flowers:0"))end;assert(#house.PersonalYard.Decor:GetChildren()==6);assert(not Y:Action(p,"Place","7:Flowers:0"));assert(not Y:Action(p,"Place","1:Fake:0"));assert(not Y:Action(p,"Place","1:Flowers:4"));assert(Y:Action(p,"Clear","6"));assert(profile.Yard.Owned.Flowers)end)
test("Migration retains money yard and old car",function()local copy=S.Migrate(S.Copy(profile),p.UserId);assert(copy.Currency==profile.Currency and copy.Yard.Slots["1"].Id=="Flowers");local legacy=S.Default();legacy.Currency=9876;legacy.Vehicles={Compact=true};local migrated=S.Migrate(legacy,p.UserId);assert(migrated.Currency==9876 and migrated.Vehicles.Owned.Compact==2400)end)
test("Level boundaries",function()for level=1,100 do local xp=50*(level-1)^2;assert(C.Level(xp)==level);if level>1 then assert(C.Level(xp-1)==level-1)end end end)
workspace:SetAttribute("TownLifeCheckResults",game.HttpService:JSONEncode(results))
D.Context.Sync(p)

