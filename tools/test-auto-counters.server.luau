assert(require(game.ServerScriptService.Neighborhood.Services.PlayerDataService).SessionOnly,'Studio isolated session required')
local p=game.Players:GetPlayers()[1];local hum=p.Character.Humanoid;local hrp=p.Character.HumanoidRootPart
local I=require(game.ServerScriptService.Neighborhood.Services.InteractionService);local report={}
for _,m in ipairs({workspace.Neighborhood.SideDestinations.RepairWorkshop,workspace.Neighborhood.CoastalWorld.CommercialStrip.CarShowroom})do
local t=m:FindFirstChild('ServiceBell')or m.CarSalesDesk
p.Character:PivotTo(CFrame.new(m:GetAttribute('Entry')));hrp:SetNetworkOwner(nil);task.wait(.3)
local endAt=os.clock()+12;repeat hum:MoveTo(t.Position);task.wait(.1)until (Vector3.new(hrp.Position.X,0,hrp.Position.Z)-Vector3.new(t.Position.X,0,t.Position.Z)).Magnitude<3 or os.clock()>endAt
assert((hrp.Position-t.Position).Magnitude<5,'Cannot reach '..m.Name..' counter')
I.Last[p.UserId]=nil;local ok,why=I:Request(p,t,t:GetAttribute('Action'));table.insert(report,{Venue=m.Name,Reached=true,Action=ok,Message=why})
workspace:SetAttribute('AutoDeskQA',game:GetService('HttpService'):JSONEncode(report));if m.Name=='CarShowroom'then assert(ok,tostring(why))end
end
workspace:SetAttribute('AutoDeskQA',game:GetService('HttpService'):JSONEncode(report));print('AUTO COUNTER WALK PASS')
