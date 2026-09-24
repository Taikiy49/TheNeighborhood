if not game:GetService('RunService'):IsStudio()then return end
local Test=game:GetService('StudioTestService');local args=Test:GetTestArgs();if type(args)~='table'or args.Name~='ResidenceAcceptance'then return end
local function run()
 local Players=game.Players;local Data=require(script.Parent.Services.PlayerDataService);local Houses=require(script.Parent.Services.HouseService);local R=require(script.Parent.ResidenceService);local Schema=require(script.Parent.ProfileSchema)
 local deadline=os.clock()+40
 repeat task.wait(.2)until #Players:GetPlayers()==2 and workspace:GetAttribute('NeighborhoodReady')and Data:Get(Players:GetPlayers()[2])and Data:Get(Players:GetPlayers()[2])._Restored or os.clock()>deadline
 assert(Data.SessionOnly);local player=Players:GetPlayers()[1];local other=Players:GetPlayers()[2];assert(player and other)
 repeat task.wait(.1)until (player.Character and player.Character:FindFirstChild("HumanoidRootPart")and other.Character and other.Character:FindFirstChild("HumanoidRootPart"))or os.clock()>deadline
 assert(player.Character and other.Character,"Characters did not spawn")
 local p=Data:Get(player);local h=Houses.ByPlayer[player.UserId];local originalHouse=h.Model;local items=#p.Inventory
 local old=Schema.Default();old.Residence=nil;assert(Schema.Migrate(old,player.UserId).Residence.Tier==1,'Old profile migration')
 local bad=Schema.Default();bad.Residence.Tier=99;assert(not pcall(Schema.Migrate,bad,player.UserId),'Corrupt tier accepted')
 p.Currency=100000
 local Building=require(script.Parent.Services.BuildingService)
 player.Character:PivotTo(h.Model.Arrival.CFrame)
 for _,id in ipairs({'GardenRoom','Loft','Garage','Workshop'})do local ok,why=Building:Action(player,'Buy',id);assert(ok,why)end
 local expansion=h.Model.HomeExpansion
 p.Currency=50000;p.Statistics.CityWork=100
 player.Character:PivotTo(h.Model.Foundation.CFrame*CFrame.new(0,4,0));assert(not R:Action(player,'Upgrade',2),'Remote upgrade accepted')
 local function visit()player.Character:PivotTo(CFrame.new(R.Agent.Position+Vector3.new(0,1,4)));task.wait(.2)end
 visit();local start=p.Currency
 for tier=2,4 do
  local ok,why=R:Action(player,'Upgrade',tier);assert(ok,why);assert(p.Residence.Tier==tier)
  local paid=p.Currency;assert(not R:Action(player,'Upgrade',tier),'Duplicate upgrade accepted');assert(p.Currency==paid,'Duplicate charge')
  assert(h.Model==originalHouse and #p.Inventory==items and h.Model:FindFirstChild('BaseGarage'),'Upgrade lost plot, possessions or garage')
  assert(#h.Model.ResidenceFloors:GetChildren()>20,'Empty residence')
  assert(h.Model.HomeExpansion==expansion and p.Building.Unlocked.Loft and expansion:FindFirstChild('LoftFloor',true),'Purchased expansion lost')
 end
 assert(p.Currency==start-2500-6500-16000,'Wrong upgrade prices')
 local lift=h.Model.ResidenceFloors:FindFirstChild('LiftUp');assert(lift)
 player.Character:PivotTo(lift.CFrame*CFrame.new(0,0,-3));task.wait(.2)
 local I=require(script.Parent.Services.InteractionService);I.Last[player.UserId]=nil
 local ok,why=I:Request(player,lift,'HomeLift');assert(ok,why)
 local pos=h.Model.Foundation.CFrame:PointToObjectSpace(player.Character:GetPivot().Position);assert(pos.Y>15,'Lift did not reach second floor')
 h.Locked=true;other.Character:PivotTo(lift.CFrame*CFrame.new(0,0,-3));I.Last[other.UserId]=nil;assert(not I:Request(other,lift,'HomeLift'),'Locked lift allows stranger');h.Locked=false
 visit();assert(not R:Action(player,'Renovate',0),'New work requirement bypassed')
 p.Statistics.CityWork+=8;local ok,why=R:Action(player,'Renovate',0);assert(ok,why);assert(p.Residence.Renovations==1 and p.Residence.Style=='Terracotta')
 assert(not R:Action(player,'Renovate',0),'Duplicate renovation accepted')
 local migrated=Schema.Migrate(Schema.Copy(p),player.UserId);assert(migrated.Residence.Tier==4 and migrated.Residence.Renovations==1,'Residence not serialized')
 local cash=p.Currency;p.Currency=0;p.Statistics.CityWork+=20;assert(not R:Action(player,'Renovate',1),'Insufficient funds accepted');p.Currency=cash
 R:Release(player);assert(not h.Model:FindFirstChild('ResidenceFloors'));R:Restore(player);assert(h.Model:FindFirstChild('ResidenceFloors'),'Restore failed')
 assert(h.Model.Lawn.Transparency==1 and h.Model.StoneApron.Material==Enum.Material.Pavement,'Grass still under house')
 Data.Context.Sync(player);Data.Context.Sync(other)
 local report={Passed=true,TiersTested=3,Verified={'old-profile defaults and corrupt tier rejection','agent distance and cash/work gates','three upgrades preserve plot, inventory and garage','duplicate requests do not charge twice','lift reaches upper floor; locked home rejects stranger','repeat renovation requires fresh work and changes palette','profile schema round trip and release/restore','stone apron replaces grass pad'},SurfaceAudit=workspace.Neighborhood:GetAttribute('SurfaceAudit')}
 return report
end
local ok,result=pcall(run);Test:EndTest(ok and result or {Passed=false,Error=tostring(result)})
