local root=game.ServerScriptService.Neighborhood
local D=require(root.Services.PlayerDataService)
assert(D.SessionOnly,'Isolated Studio session required')
local V=require(root.Services.VehicleService)
local C=require(game.ReplicatedStorage.Neighborhood.Shared.VehicleCatalog)
local p=game.Players:GetPlayers()[1];local profile=D:Get(p)
local hum=p.Character.Humanoid;local hrp=p.Character.HumanoidRootPart
local report={Vehicles={},Security=0,Economy=0,ImportedTemplates=0}
local function save()workspace:SetAttribute('VehicleArtQA',game:GetService('HttpService'):JSONEncode(report))end
for _,m in ipairs(game.ServerStorage.VehicleArt:GetChildren())do
 assert(m:GetAttribute('SourceAssetId'),'No attribution')
 for _,v in ipairs(m:GetDescendants())do assert(not v:IsA('LuaSourceContainer')and not v:IsA('RemoteEvent')and not v:IsA('RemoteFunction')and not v:IsA('Constraint'),'Unsafe imported component')end
 report.ImportedTemplates+=1
end
local store=workspace.Neighborhood.CoastalWorld.CommercialStrip.CarShowroom
profile.Vehicles.Owned={};profile.Vehicles.Compact=false;profile.Vehicles.Selected='';profile.Currency=200000;profile.XP=100000
p.Character:PivotTo(CFrame.new(0,5,0));assert(not V:Action(p,'Buy','Compact'));report.Security+=1
p.Character:PivotTo(CFrame.new(store.Floor.Position+Vector3.new(0,4,0)))
local before=profile.Currency;assert(V:Action(p,'Buy','Compact'));assert(profile.Currency==before-C.Items.Compact.Price)
assert(not V:Action(p,'Buy','Compact'));assert(V:Action(p,'Sell','Compact'));assert(profile.Currency==before-C.Items.Compact.Price/2);report.Economy=3
local garage=V.Context.Houses.ByPlayer[p.UserId].Model.BaseGarage
local savedSpawn=garage.CarSpawn.CFrame
local track=Instance.new('Part');track.Name='VehicleQATrack';track.Size=Vector3.new(180,1,180);track.Anchored=true;track.Position=Vector3.new(0,1000,0);track.Parent=workspace
for _,id in ipairs(C.Order)do
 profile.Vehicles.Owned[id]=C.Items[id].Price;profile.Vehicles.Selected=id
 p.Character:PivotTo(CFrame.new(garage.CarSpawn.Position+Vector3.new(20,4,0)))
 local ok,why=V:Spawn(p);assert(ok,id..' spawn: '..tostring(why))
 local car=V.Cars[p.UserId];assert(car.Model:FindFirstChild('Imported'..id))
 assert(car.Body.Transparency==1 and car.Body:GetNetworkOwner()==nil)
 for _,part in ipairs(car.Model:GetDescendants())do if part:IsA('BasePart')then assert(not part.Anchored,'Anchored vehicle art')end end
 assert(not V:Input(p,1,0));report.Security+=1
 -- Real physics on an empty stretch of the road, using the normal input path.
 car.Model:PivotTo(CFrame.new(0,1003,30));car.Yaw=0;car.Body.AssemblyLinearVelocity=Vector3.zero
 p.Character:PivotTo(car.Seat.CFrame+Vector3.new(0,3,0));task.wait(.15);car.Seat:Sit(hum);task.wait(.3)
 assert(car.Seat.Occupant==hum,'Cannot sit '..id)
 assert(not V:Input(p,0/0,0));report.Security+=1
 assert(not V:Spawn(p),'Occupied recall accepted');report.Security+=1
 local origin=car.Body.Position
 for i=1,20 do V.InputTimes[p.UserId]=nil;assert(V:Input(p,1,0));task.wait(.1)end
 local distance=(car.Body.Position-origin).Magnitude;assert(distance>8,'No drive motion '..id)
 local yaw=car.Yaw
 for i=1,8 do V.InputTimes[p.UserId]=nil;assert(V:Input(p,.7,.7));task.wait(.1)end
 assert(math.abs(car.Yaw-yaw)>.1,'No steering '..id)
 assert(car.Body.Position.Y>1001 and car.Body.Position.Y<1005,'Unstable suspension '..id)
 assert(V:Action(p,'Color','Peach'))
 local paint=0
 for _,part in ipairs(car.Model:GetDescendants())do if part:IsA('BasePart')and part:GetAttribute('VehiclePaint')then assert(part.Color==Color3.fromRGB(220,149,109));paint+=1 end end
 assert(paint>0,'No paint panels '..id)
 local samples={Distance=distance,PaintPanels=paint,Height=car.Body.Position.Y}
 hum.Sit=false;task.wait(.2);V:Remove(p);report.Vehicles[id]=samples;save()
end
assert(garage.CarSpawn.CFrame==savedSpawn)
for _,traffic in ipairs(require(root.TownLifeExpansion).Traffic)do assert(traffic.Model:FindFirstChildWhichIsA('Model'));assert(traffic.Model.Body.Transparency==1)end
assert(store.ImportedAutoShop and workspace.Neighborhood.SideDestinations.RepairWorkshop.ImportedAutoShop)
track:Destroy()
report.Passed=true;save();print('IMPORTED VEHICLES PASS')
