local w=workspace.Neighborhood
local I=require(game.ServerScriptService.Neighborhood.Services.InteractionService)
local Data=require(game.ServerScriptService.Neighborhood.Services.PlayerDataService)
local p=game.Players:GetPlayers()[1]
assert(Data.SessionOnly,'Tests require an isolated profile')
local cases={w.SideDestinations.CornerCafe,w.SideDestinations.RepairWorkshop,w.SideDestinations.OrchardStand,w.SideDestinations.LakesideTackle,w.Shops.GeneralStore,w.Shops.PawnShop,w.CoastalWorld.TownLife.PalmDiner,w.CoastalWorld.TownLife.NoodleKitchen,w.CoastalWorld.TownLife.BoardwalkBakery,w.CoastalWorld.TownLife.CornerConvenience,w.CoastalWorld.CommercialStrip.FuelAndSnacks}
local failed=0
for _,m in ipairs(cases)do
 local target
 for _,v in ipairs(m:GetChildren())do if v:IsA('BasePart')and v:GetAttribute('Action')and v.Name~='BaristaOrders'then target=v;break end end
 assert(target,'Missing service '..m.Name)
 for _,v in ipairs(p.Backpack:GetChildren())do if v:IsA('Tool')then v:Destroy()end end
 local art=m:FindFirstChild('ImportedCafe')or m:FindFirstChild('ImportedBakery')or m:FindFirstChild('ImportedMarket')or m:FindFirstChild('ImportedGreenhouse')
 p.Character.Humanoid.Sit=false;p.Character:PivotTo(CFrame.new(target.Position+art:GetPivot().LookVector*5));task.wait(.7)
 local ok,why=I:Request(p,target,target:GetAttribute('Action'))
 print('VENUE_CHECK',m.Name,ok,why)
 if not ok then
  failed+=1;local ray=RaycastParams.new();ray.FilterDescendantsInstances={p.Character};local at=p.Character.HumanoidRootPart.Position;local hit=workspace:Raycast(at,target.Position-at,ray);print('BLOCKER',hit and hit.Instance:GetFullName())
 end
end
local Life=require(game.ServerScriptService.Neighborhood.Services.LifeService)
for _,id in ipairs({'Cafe','Clubhouse','Greenhouse'})do
 Life:Project(id);local station=Life.Stations[id];assert(#station.Parent:GetDescendants()>50,'Project lost its finished art');p.Character.Humanoid.Sit=false;p.Character:PivotTo(CFrame.new(station.Position+Vector3.new(0,0,-3)));task.wait(.7)
 local ok,why=I:Request(p,station,'LifeStation');print('PROJECT_CHECK',id,ok,why);if not ok then failed+=1 end
end
local t=w.SideDestinations.CornerCafe.BaristaOrders;p.Character.Humanoid.Sit=false;p.Character:PivotTo(CFrame.new(t.Position+Vector3.new(0,0,-4)));task.wait(.7)
local initial=Data:Get(p).Currency
assert(I:Request(p,t,'CafeShift'));task.wait(.4);assert(not I:Request(p,t,'CafeShift'),'Early reward');task.wait(3.9);assert(I:Request(p,t,'CafeShift'));assert(Data:Get(p).Currency==initial+15,'Wrong reward');task.wait(.4);assert(not I:Request(p,t,'CafeShift'),'Duplicate reward');assert(Data:Get(p).Currency==initial+15)
print('BARISTA_CHECK passed: early denial, exact payout, cooldown')
local tea=w.SideDestinations.CornerCafe.ServiceBell
for _,v in ipairs(p.Backpack:GetChildren())do if v:IsA('Tool')then v:Destroy()end end
p.Character:PivotTo(CFrame.new(tea.Position+Vector3.new(0,0,-4)));task.wait(.7);assert(I:Request(p,tea,'CafeTea'));task.wait(.4);assert(not I:Request(p,tea,'CafeTea'),'Duplicate drink');assert(p.Backpack:FindFirstChild('Café tea'))
print('TEA_CHECK passed: imported cup, duplicate denial')
w:SetAttribute('VenueTestFailures',failed)
print('VENUE_ACCEPTANCE_COMPLETE',failed)
