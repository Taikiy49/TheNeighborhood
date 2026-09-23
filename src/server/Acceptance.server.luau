-- Only runs in explicit Studio automation sessions. Never runs in a published server.
if not game:GetService("RunService"):IsStudio() then return end
local Test=game:GetService("StudioTestService")
local args=Test:GetTestArgs()
if type(args)~="table" or args.Name~="FoundationAcceptance" then return end
local function run()
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
    local Robbery=require(script.Parent.Services.RobberyService)
    local thief=players[2]
    local toilet=Items:Create(player,"GoldenToilet")
    player.Character:PivotTo(a.Model.DisplaySlots.Slot2.CFrame*CFrame.new(0,3,0))
    assert(Items:Place(player,toilet.Id,2),"Toilet placement failed")
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
    assert(not Robbery:Begin(player,toilet.Id),"Concurrent theft accepted")
    assert(not Robbery:Fence(thief),"Premature fence accepted")
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
    local errors={}
    for _,entry in ipairs(game:GetService("LogService"):GetLogHistory()) do if entry.messageType==Enum.MessageType.MessageError then table.insert(errors,entry.message) end end
    return {Passed=true,Verified=verified,Errors=errors,Players={{Name=players[1].Name,UserId=players[1].UserId,House=a.Model.Name},{Name=players[2].Name,UserId=players[2].UserId,House=b.Model.Name}}}
end
local ok,result=pcall(run)
if not ok then result={Passed=false,Error=tostring(result)} end
print("[ACCEPTANCE]",game:GetService("HttpService"):JSONEncode(result))
Test:EndTest(result)
