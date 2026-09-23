-- Only runs in explicit Studio automation sessions. Never runs in a published server.
if not game:GetService("RunService"):IsStudio() then return end
local Test=game:GetService("StudioTestService")
local args=Test:GetTestArgs()
if type(args)~="table" or args.Name~="FoundationAcceptance" then return end
local function run()
    local persistenceTests=require(script.Parent.ProfileTests)()
    assert(persistenceTests.Passed,"Persistence fault tests failed")
    local Players=game:GetService("Players")
    local deadline=os.clock()+40
    repeat task.wait(0.2) until (#Players:GetPlayers()>=2 and workspace:GetAttribute("NeighborhoodReady")) or os.clock()>deadline
    local players=Players:GetPlayers();assert(#players==2,"Expected two connected clients")
    local Houses=require(script.Parent.Services.HouseService)
    local Interactions=require(script.Parent.Services.InteractionService)
    repeat task.wait(0.2) until (Houses.ByPlayer[players[1].UserId] and Houses.ByPlayer[players[2].UserId] and players[1].Character and players[2].Character and players[1].Character:FindFirstChild("HumanoidRootPart") and players[2].Character:FindFirstChild("HumanoidRootPart")) or os.clock()>deadline
    local a=Houses.ByPlayer[players[1].UserId];local b=Houses.ByPlayer[players[2].UserId]
    assert(a and b,"Player house state missing");assert(a~=b,"Players received the same house")
    local verified={"Two real clients connected","Distinct houses assigned"}
    for _,player in ipairs(players) do
        local house=Houses.ByPlayer[player.UserId]
        player.Character:PivotTo(house.Door.CFrame*CFrame.new(0,0,-5))
        task.wait(0.3)
        local ok,message=Interactions:Request(player,house.Door,"Door")
        assert(ok,message);assert(house.Open,"Door did not open")
        table.insert(verified,player.Name.." opened their own door")
    end
    local allowed=Houses:DoorAction(players[2],a.Model.Lock,"Lock")
    assert(not allowed,"Visitor changed another player's lock")
    table.insert(verified,"Visitor lock mutation rejected")
    task.wait(0.3)
    assert(not Interactions:Request(players[1],nil,"Door"),"Invalid target accepted")
    table.insert(verified,"Malformed interaction rejected")
    local Items=require(script.Parent.Services.ItemService)
    local Economy=require(script.Parent.Services.EconomyService)
    local Data=require(script.Parent.Services.PlayerDataService)
    local player=players[1];local before=Data:Get(player).Currency
    player.Character:PivotTo(workspace.Neighborhood.Shops.GeneralStore.Counter.CFrame*CFrame.new(0,2,-5))
    local bought,reason=Economy:Buy(player,"GardenGnome");assert(bought,reason)
    assert(Data:Get(player).Currency==before-160,"Purchase debit wrong")
    local owned=Items:Owned(player);local gnome
    for _,item in ipairs(owned) do if item.DefinitionId=="GardenGnome" then gnome=item end end
    assert(gnome,"Purchased item missing")
    assert(not Economy:Buy(player,"NotAnItem"),"Invalid purchase accepted")
    assert(not Economy:Buy(player,"GoldenToilet"),"Insufficient funds accepted")
    player.Character:PivotTo(a.Model.DisplaySlots.Slot1.CFrame*CFrame.new(0,3,0))
    assert(Items:Place(player,gnome.Id,1),"Placement failed")
    assert(not Items:Place(players[2],gnome.Id,1),"Foreign placement accepted")
    assert(Items:Store(player,Items.Items[gnome.Id]),"Store failed")
    player.Character:PivotTo(workspace.Neighborhood.Shops.PawnShop.Counter.CFrame*CFrame.new(0,2,-5))
    assert(Economy:Sell(player,gnome.Id),"Pawn sale failed")
    assert(not Economy:Sell(player,gnome.Id),"Duplicate sale accepted")
    assert(Data:Get(player).Currency==before-160+64,"Sale payout wrong")
    table.insert(verified,"Purchase, placement, storage and sale lifecycle")
    table.insert(verified,"Invalid item, insufficient funds, foreign ownership and duplicate sale rejected")
    local Customization=require(script.Parent.Services.CustomizationService)
    local paintBalance=Data:Get(player).Currency
    assert(Customization:Change(player,"Color","Blue"));assert(Data:Get(player).Currency==paintBalance-150)
    local paintedTextures=0
    for _,finish in a.Model:GetDescendants()do
        if finish:IsA("Texture")and finish.Name:match("^HiggsfieldSiding")then
            assert(finish.Color3==Color3.fromRGB(154,187,205),"Siding did not follow purchased paint")
            paintedTextures+=1
        end
    end
    assert(paintedTextures>0,"House siding missing")
    table.insert(verified,"Higgsfield siding follows purchased house paint")
    assert(Customization:Change(player,"Color","Blue"));assert(Data:Get(player).Currency==paintBalance-150,"Unlocked paint charged again")
    assert(not Customization:Change(player,"Color","invalid"),"Invalid paint accepted")
    assert(Customization:Permission(player,tostring(players[2].UserId),"Friend"))
    assert(Houses:DoorAction(player,a.Model.Lock,"Lock"))
    assert(Houses:DoorAction(players[2],a.Door,"Door"));assert(a.Open,"Invited friend could not enter")
    assert(not Houses:DoorAction(players[2],a.Model.Lock,"Lock"),"Friend changed lock")
    assert(Customization:Permission(player,tostring(players[2].UserId),"Roommate"))
    assert(Houses:DoorAction(players[2],a.Model.Lock,"Lock"));assert(not a.Locked,"Roommate lock permission missing")
    assert(Customization:Permission(player,tostring(players[2].UserId),"Visitor"))
    table.insert(verified,"Paint purchase is charged once; invalid options rejected; entry, roommate locks and item ownership remain separate")
    local Vehicles=require(script.Parent.Services.VehicleService)
    local garageBalance=Data:Get(player).Currency;Data:Get(player).Currency=5000
    assert(Vehicles:Action(player,"Buy"));assert(Data:Get(player).Currency==2600,"Vehicle purchase price wrong")
    assert(not Vehicles:Action(player,"Buy"),"Duplicate vehicle purchase accepted")
    local car=assert(Vehicles.Cars[player.UserId],"Purchased car did not spawn")
    assert(not Vehicles:Input(players[2],1,0),"Foreign driver input accepted")
    player.Character:PivotTo(car.Seat.CFrame*CFrame.new(0,2,0));car.Seat:Sit(player.Character.Humanoid);task.wait(0.5);car.Body:SetNetworkOwner(nil)
    assert(not Vehicles:Input(player,0/0,0),"NaN vehicle input accepted")
    assert(not Vehicles:Input(player,2,0),"Out-of-range throttle accepted")
    assert(car.Seat.Occupant==player.Character.Humanoid,"Driver did not settle into seat")
    local carStart=car.Body.Position
    -- Keep the idle client's zero-throttle packets from racing this server physics fixture.
    local driveFixture=game:GetService("RunService").PreSimulation:Connect(function()car.Throttle=1;car.Steer=0;car.LastInput=os.clock()end)
    task.wait(2);driveFixture:Disconnect()
    assert((car.Body.Position-carStart).Magnitude>3,"Vehicle did not drive under server physics: "..tostring(car.Body.Position-carStart))
    assert(car.Body.AssemblyLinearVelocity.Magnitude<45,"Vehicle exceeded bounded speed")
    player.Character.Humanoid.Sit=false;player.Character.Humanoid.Jump=true;task.wait(0.5);Vehicles:Remove(player)
    Data:Get(player).Currency=garageBalance
    table.insert(verified,"Car purchase, owner-only input, physical driving and bounded speed; duplicate/NaN/out-of-range requests rejected")
    local Pets=require(script.Parent.Services.PetService)
    local petBalance=Data:Get(player).Currency;Data:Get(player).Currency=1000
    assert(Pets:Action(player,"Adopt"));assert(Data:Get(player).Currency==400,"Pet adoption debit wrong")
    assert(not Pets:Action(player,"Adopt"),"Duplicate pet adoption accepted")
    assert(not Pets:Action(players[2],"Stay"),"Unowned pet command accepted")
    local pet=assert(Pets.Pets[player.UserId],"Adopted pet missing")
    local petStart=pet.Root.Position
    player.Character:PivotTo(a.Model.Arrival.CFrame*CFrame.new(0,0,10))
    local petDeadline=os.clock()+8
    repeat task.wait(0.25)until (pet.Root.Position-petStart).Magnitude>1 or os.clock()>petDeadline
    assert((pet.Root.Position-petStart).Magnitude>1,"Companion did not follow a navigation path")
    assert(Pets:Action(player,"Stay"));assert(Data:Get(player).Pets.Mode=="Stay")
    Data:Get(player).Currency=petBalance
    table.insert(verified,"Pet adoption charged once; path following and stay command work; unowned commands rejected")
    local Events=require(script.Parent.Services.EventService)
    Events:Start("GarageSale")
    player.Character:PivotTo(workspace.Neighborhood.Shops.GeneralStore.Counter.CFrame*CFrame.new(0,2,-5))
    local saleBalance=Data:Get(player).Currency
    assert(Economy:Buy(player,"GardenGnome"));assert(Data:Get(player).Currency==saleBalance-128,"Garage sale discount incorrect")
    Events:Finish();assert(workspace.Neighborhood:GetAttribute("SaleMultiplier")==1)
    Events:Start("BlockParty")
    player.Character:PivotTo(CFrame.new(0,4,0));players[2].Character:PivotTo(CFrame.new(4,4,0))
    local firstCash=Data:Get(player).Currency;local secondCash=Data:Get(players[2]).Currency
    assert(not Events:Action(player,"HighFive",player.UserId),"Self high-five accepted")
    assert(Events:Action(player,"HighFive",players[2].UserId));assert(Data:Get(player).Currency==firstCash,"Unconsented high-five paid")
    assert(Events:Action(players[2],"HighFive",player.UserId))
    assert(Data:Get(player).Currency==firstCash+20 and Data:Get(players[2]).Currency==secondCash+20,"Mutual high-five payout incorrect")
    assert(Events:Action(player,"HighFive",players[2].UserId));assert(not Events:Action(players[2],"HighFive",player.UserId),"Repeated pair paid twice")
    Events:Start("PowerOutage");assert(workspace.Neighborhood:GetAttribute("PowerOutage"));Events:Finish();assert(not workspace.Neighborhood:GetAttribute("PowerOutage"))
    assert(not Events:Action(player,"HighFive",players[2].UserId),"Inactive event accepted")
    table.insert(verified,"Event discount, mutual consent, unique pair reward, outage lifecycle and inactive-event rejection")
    Events:Start("WatchNight")
    assert(not Events:Action(player,"Watch",a.Model.Name),"Remote patrol check accepted")
    local patrolBalance=Data:Get(player).Currency
    for index=1,3 do
        local patrolHouse=Houses.ById[string.format("House%02d",index)]
        player.Character:PivotTo(patrolHouse.Model.Mailbox.Box.CFrame*CFrame.new(0,1,-4))
        local checked,why=Events:Action(player,"Watch",patrolHouse.Model.Name);assert(checked,why)
        assert(not Events:Action(player,"Watch",patrolHouse.Model.Name),"Duplicate patrol accepted")
    end
    assert(Data:Get(player).Currency==patrolBalance+90,"Patrol reward incorrect");Events:Finish()
    table.insert(verified,"Three distinct physical mailbox visits pay once; remote and repeat checks rejected")
    local Pranks=require(script.Parent.Services.PrankService)
    local prankBalance=Data:Get(player).Currency
    player.Character:PivotTo(b.ClosedCFrame*CFrame.new(0,0,-5))
    assert(not Pranks:Place(player,a.Model.Name),"Self prank accepted")
    assert(not Pranks:Place(player,b.Model.Name),"Protected home pranked")
    b.Model:SetAttribute("ProtectedUntil",0);Data:Get(players[2]).Settings.Pranks=false
    assert(not Pranks:Place(player,b.Model.Name),"Opt-out ignored")
    Data:Get(players[2]).Settings.Pranks=true
    local pranked,prankReason=Pranks:Place(player,b.Model.Name);assert(pranked,prankReason)
    assert(Data:Get(player).Currency==prankBalance-50 and Pranks.Active[b.Model.Name],"Prank debit or physical flock missing")
    assert(not Pranks:Place(player,b.Model.Name),"Prank cooldown ignored")
    local tidy=Pranks.Active[b.Model.Name].TidySign
    assert(not Interactions.Handlers.CleanPrank(player,tidy),"Visitor cleaned another yard")
    assert(Interactions.Handlers.CleanPrank(players[2],tidy));assert(not Pranks.Active[b.Model.Name])
    table.insert(verified,"Physical flamingo prank, owner cleanup, price, opt-out, beginner protection and cooldown")
    local Observation=require(script.Parent.Services.ObservationService)
    player.Character:PivotTo(CFrame.new(0,4,0));assert(not Observation:Survey(player,a.Model.Name),"Remote house survey accepted")
    player.Character:PivotTo(a.ClosedCFrame*CFrame.new(0,0,-5));assert(Observation:Survey(player,a.Model.Name))
    assert(not Observation:Survey(player,a.Model.Name),"Survey cooldown ignored")
    local occlusionTarget=Instance.new("Part");occlusionTarget.Anchored=true;occlusionTarget.Size=Vector3.one;occlusionTarget.CFrame=player.Character.Head.CFrame*CFrame.new(0,0,-8);occlusionTarget.Parent=workspace.Neighborhood.Runtime
    local wall=Instance.new("Part");wall.Anchored=true;wall.Size=Vector3.new(8,8,1);wall.CFrame=player.Character.Head.CFrame*CFrame.new(0,0,-4);wall.Parent=workspace.Neighborhood.Runtime
    assert(not Observation:Visible(player,occlusionTarget,20),"Observation saw through wall");wall:Destroy()
    assert(Observation:Visible(player,occlusionTarget,20),"Unobstructed observation failed");occlusionTarget:Destroy()
    table.insert(verified,"Nearby house survey respects walls, distance and request cooldown")
    local Robbery=require(script.Parent.Services.RobberyService)
    local thief=players[2]
    assert(Houses:DoorAction(player,a.Model.Lock,"Lock"))
    player.Character:PivotTo(a.Model.DisplaySlots.Slot3.CFrame*CFrame.new(0,3,0))
    thief.Character:PivotTo(a.ClosedCFrame*CFrame.new(0,0,-5));thief.Character.HumanoidRootPart:SetNetworkOwner(nil)
    assert(not Robbery:Breach(thief,a.Model.Name),"Protected door breach allowed")
    a.Model:SetAttribute("ProtectedUntil",0)
    local beganBreach,breachReason=Robbery:Breach(thief,a.Model.Name);assert(beganBreach,"Breach start rejected: "..tostring(breachReason))
    thief.Character:PivotTo(a.ClosedCFrame*CFrame.new(0,0,-15));task.wait(4.5)
    assert(not a.Open and not Robbery.Breaching[thief.UserId],"Cancelled breach opened door")
    thief.Character:PivotTo(a.ClosedCFrame*CFrame.new(0,0,-5))
    assert(Robbery:Breach(thief,a.Model.Name));task.wait(4.5)
    assert(a.Open and a.CompromisedUntil>os.clock(),"Completed breach did not open door")
    assert(Houses:DoorAction(player,a.Model.Lock,"Lock"))
    assert(not a.CompromisedUntil,"Owner lock control failed to reset breach")
    a.Model:SetAttribute("ProtectedUntil",os.time()+300)
    table.insert(verified,"Timed lock breach; protection and movement cancellation; owner reset")
    local toilet=Items:Create(player,"GoldenToilet")
    player.Character:PivotTo(a.Model.DisplaySlots.Slot2.CFrame*CFrame.new(0,3,0))
    assert(Items:Place(player,toilet.Id,2),"Toilet placement failed")
    player.Character:PivotTo(a.Model.DisplaySlots.Slot3.CFrame*CFrame.new(0,3,0))
    thief.Character:PivotTo(a.Model.DisplaySlots.Slot2.CFrame*CFrame.new(0,3,-4))
    thief.Character.HumanoidRootPart:SetNetworkOwner(nil)
    assert(not Robbery:Begin(thief,toilet.Id),"Beginner protection failed")
    -- Test-only removal of moving-in immunity; production retains the full duration.
    a.Model:SetAttribute("ProtectedUntil",0)
    local began,why=Robbery:Begin(thief,toilet.Id);assert(began,why)
    task.wait(3)
    local session=Robbery.Sessions[thief.UserId];assert(session,"Carry session missing")
    assert(toilet.State=="Carried","Item not carried")
    assert(thief.Character.Humanoid.WalkSpeed<=6,"Heavy item movement penalty missing")
    assert(Items.Models[toilet.Id].PrimaryPart:FindFirstChild("CarryWeld"),"Carry weld missing")
    local joints={};for _,joint in ipairs(thief.Character:GetDescendants())do if joint.Name:lower():find("shoulder")then table.insert(joints,joint.Name..":"..joint.ClassName)end end
    assert(#session.Pose>=2,"Carry arm pose missing: "..table.concat(joints,","))
    assert(Robbery:Drop(thief),"Voluntary drop failed")
    assert(toilet.State=="Dropped" and thief.Character.Humanoid.WalkSpeed==16,"Drop did not free movement")
    assert(not Robbery:Resume(player,toilet.Id),"Foreign carry resumed")
    local resumed,resumeReason=Robbery:Resume(thief,toilet.Id);assert(resumed,"Carry resume failed: "..tostring(resumeReason))
    session=Robbery.Sessions[thief.UserId]
    assert(toilet.State=="Carried" and thief.Character.Humanoid.WalkSpeed<=6,"Resumed weight penalty missing")
    table.insert(verified,"Drop and resume preserve original possession, physical carry pose and movement restoration")
    assert(not Robbery:Begin(player,toilet.Id),"Concurrent theft accepted")
    assert(not Robbery:Fence(thief),"Premature fence accepted")
    local spare=Items:Create(player,"Lamp")
    player.Character:PivotTo(a.Model.DisplaySlots.Slot2.CFrame*CFrame.new(0,3,3))
    assert(not Items:Place(player,spare.Id,2),"Missing possession's slot was reused")
    assert(Robbery:Recover(player,toilet),"Owner recovery failed")
    assert(toilet.State=="Displayed" and not toilet.HolderUserId,"Recovery state wrong")
    assert(thief.Character.Humanoid.WalkSpeed==16,"Movement not restored")
    table.insert(verified,"Golden Toilet theft, physical weld, weight penalty and owner recovery")
    table.insert(verified,"Beginner protection, concurrent theft and premature fence rejection")
    local profile=Data:Get(player)
    assert(#profile.Incidents>=1 and #profile.Incidents[1].Evidence>=1,"Incident evidence missing")
    local encoded=game:GetService("HttpService"):JSONEncode(profile.Incidents)
    assert(not encoded:find("UserId"),"Evidence leaks user identity")
    table.insert(verified,"Structured incident evidence without culprit user ID")
    -- Exercise an actual walking escape using server-controlled test character physics.
    player.Character:PivotTo(a.Model.DisplaySlots.Slot3.CFrame*CFrame.new(0,3,0))
    thief.Character:PivotTo(a.Model.DisplaySlots.Slot2.CFrame*CFrame.new(0,3,-4))
    local again,againReason=Robbery:Begin(thief,toilet.Id);assert(again,againReason);task.wait(3)
    local escaped=Robbery.Sessions[thief.UserId];assert(escaped,"Second carry failed")
    local humanoid=thief.Character.Humanoid
    local destination=(a.ClosedCFrame*CFrame.new(0,0,-52)).Position
    local walkingDeadline=os.clock()+25
    repeat
        humanoid:MoveTo(destination)
        task.wait(2)
    until escaped.State=="Escaped" or not Robbery.Sessions[thief.UserId] or os.clock()>walkingDeadline
    assert(Robbery.Sessions[thief.UserId] and escaped.State=="Escaped","Walking escape failed")
    table.insert(verified,"Heavy-item character walked through the door and escaped")
    -- Travel to the pawn counter is bypassed only after the real escape was established.
    thief.Character:PivotTo(workspace.Neighborhood.Shops.PawnShop.Counter.CFrame*CFrame.new(0,3,-5))
    escaped.LastPosition=thief.Character.HumanoidRootPart.Position;escaped.LastTime=os.clock()
    local thiefCash=Data:Get(thief).Currency
    assert(Robbery:Fence(thief),"Fencing failed")
    assert(Data:Get(thief).Currency==thiefCash+2900,"Fence value incorrect")
    assert(not Robbery:Fence(thief),"Duplicate fence payout accepted")
    assert(Items.Items[toilet.Id]==toilet and toilet.State=="Fenced","Fenced ownership record lost")
    table.insert(verified,"Fence payout exactly $2900; duplicate fence rejected")
    local Investigation=require(script.Parent.Services.InvestigationService)
    local incident=profile.Incidents[1]
    assert(not Investigation:Accuse(thief,incident.Id,player.UserId),"Foreign case accusation accepted")
    assert(not Investigation:Accuse(player,incident.Id,player.UserId),"Self accusation accepted")
    assert(Investigation:Accuse(player,incident.Id,thief.UserId),"Evidence-backed accusation failed")
    assert(incident.Status=="Solved" and profile.Statistics.Solved==1,"Investigation reward missing")
    assert(not Investigation:Accuse(player,incident.Id,thief.UserId),"Duplicate solution rewarded")
    table.insert(verified,"Evidence-backed accusation solves case once; foreign case and self accusations rejected")
    assert(not Robbery:Reclaim(thief,toilet.Id),"Thief reclaimed victim property")
    assert(not Robbery:Reclaim(player,toilet.Id),"Remote reclaim accepted")
    player.Character:PivotTo(workspace.Neighborhood.Shops.PawnShop.Counter.CFrame*CFrame.new(0,3,-5))
    assert(Robbery:Reclaim(player,toilet.Id),"Owner reclaim failed")
    assert(toilet.State=="Stored" and toilet.RecoveryProtected,"Reclaim protection missing")
    assert(not Robbery:Reclaim(player,toilet.Id),"Duplicate reclaim accepted")
    assert(#profile.Incidents[1].Timeline==4,"Incident timeline lost a transition")
    player.Character:PivotTo(a.Model.DisplaySlots.Slot2.CFrame*CFrame.new(0,3,0));assert(Items:Place(player,toilet.Id,2))
    assert(not Robbery:Begin(thief,toilet.Id),"Recovered item farming allowed")
    assert(Items:Store(player,toilet),"Reclaimed item storage failed")
    table.insert(verified,"Original item reclaimed; foreign, remote, duplicate and repeat-farming requests rejected; four incident transitions retained")
    local testItem=Items:Create(player,"Television")
    player.Character:PivotTo(a.Model.DisplaySlots.Slot2.CFrame*CFrame.new(0,3,0));assert(Items:Place(player,testItem.Id,2))
    player.Character:PivotTo(a.Model.DisplaySlots.Slot3.CFrame*CFrame.new(0,3,0))
    thief.Character:PivotTo(a.Model.DisplaySlots.Slot2.CFrame*CFrame.new(0,3,-4))
    Robbery.Cooldowns[player.UserId]=nil
    assert(Robbery:Begin(thief,testItem.Id));task.wait(3)
    assert(Robbery.Sessions[thief.UserId],"Disconnect fixture carry missing")
    Robbery:Release(thief)
    assert(testItem.State=="Displayed" and not Robbery.Sessions[thief.UserId],"Disconnect resolution failed")
    table.insert(verified,"Disconnect cleanup returns carried property and restores movement")
    assert(Robbery:Begin(thief,testItem.Id));task.wait(3)
    assert(Robbery.Sessions[thief.UserId],"Teleport fixture missing")
    thief.Character:PivotTo(CFrame.new(0,12,0));task.wait(0.5)
    assert(testItem.State=="Displayed" and not Robbery.Sessions[thief.UserId],"Teleport escape accepted")
    table.insert(verified,"Teleport during carry returns property with no payout")
    thief.Character:PivotTo(a.Model.DisplaySlots.Slot2.CFrame*CFrame.new(0,3,-4))
    assert(Robbery:Begin(thief,testItem.Id));task.wait(3)
    assert(Robbery.Sessions[thief.UserId],"Actual departure fixture missing")
    thief:Kick("Studio acceptance: verify player departure cleanup")
    local departureDeadline=os.clock()+15
    repeat task.wait(0.2) until not Houses.ByPlayer[thief.UserId] or os.clock()>departureDeadline
    assert(testItem.State=="Displayed" and not Robbery.Sessions[thief.UserId] and not Houses.ByPlayer[thief.UserId],"Real departure failed cleanup: "..game:GetService("HttpService"):JSONEncode({ItemState=testItem.State,Session=Robbery.Sessions[thief.UserId]~=nil,House=Houses.ByPlayer[thief.UserId]~=nil,Connected=thief.Parent==Players}))
    assert(not b.Owner,"Departed player's plot remained claimed")
    table.insert(verified,"Actual client disconnect releases plot and returns carried possession")
    local storageOk,storageResult=pcall(function()return game:GetService("DataStoreService"):GetDataStore("TheNeighborhood_DevelopmentProbe_v1"):GetAsync("read-access-check")end)
    local liveStorage=storageOk and require(script.Parent.LiveStorageTests)() or nil
    local errors={}
    for _,entry in ipairs(game:GetService("LogService"):GetLogHistory()) do if entry.messageType==Enum.MessageType.MessageError then table.insert(errors,entry.message) end end
    return {Passed=true,Verified=verified,PersistenceTests=persistenceTests,LiveStorageTests=liveStorage,Errors=errors,DataStoreAccess={Allowed=storageOk,Result=tostring(storageResult)},Players={{Name=players[1].Name,UserId=players[1].UserId,House=a.Model.Name},{Name=players[2].Name,UserId=players[2].UserId,House=b.Model.Name}}}
end
local ok,result=pcall(run)
if not ok then result={Passed=false,Error=tostring(result)} end
print("[ACCEPTANCE]",game:GetService("HttpService"):JSONEncode(result))
Test:EndTest(result)
