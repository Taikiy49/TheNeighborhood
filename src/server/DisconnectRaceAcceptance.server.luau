if not game:GetService("RunService"):IsStudio()then return end
local Test=game:GetService("StudioTestService");local args=Test:GetTestArgs()
if type(args)~="table" or args.Name~="DisconnectRaceAcceptance"then return end
local function run()
 local Players=game:GetService("Players");local Data=require(script.Parent.Services.PlayerDataService)
 local Houses=require(script.Parent.Services.HouseService);local Items=require(script.Parent.Services.ItemService)
 local Robbery=require(script.Parent.Services.RobberyService);local Interactions=require(script.Parent.Services.InteractionService)
 local deadline=os.clock()+45
 repeat task.wait(0.2)until #Players:GetPlayers()==2 and workspace:GetAttribute("NeighborhoodReady") and Houses.ByPlayer[Players:GetPlayers()[2].UserId] or os.clock()>deadline
 local players=Players:GetPlayers();assert(#players==2);local owner=players[1];local thief=players[2]
 for _,player in ipairs(players)do repeat task.wait(0.1)until player.Character and player.Character:FindFirstChild("HumanoidRootPart") or os.clock()>deadline;player.Character.HumanoidRootPart:SetNetworkOwner(nil)end
 local house=Houses.ByPlayer[owner.UserId];house.Model:SetAttribute("ProtectedUntil",0);Houses:SetDoor(house,true)
 local item=Items:Create(owner,"Television");owner.Character:PivotTo(house.Model.DisplaySlots.Slot2.CFrame*CFrame.new(0,3,0));assert(Items:Place(owner,item.Id,2))
 owner.Character:PivotTo(house.Model.DisplaySlots.Slot3.CFrame*CFrame.new(0,3,0))
 thief.Character:PivotTo(house.Model.DisplaySlots.Slot2.CFrame*CFrame.new(0,3,-4));assert(Robbery:Begin(thief,item.Id));task.wait(3)
 assert(Robbery.Sessions[thief.UserId],"Carry fixture missing")
 local originalSave=Data.Save
 Data.Save=function(self,player,release)if player==owner and release then task.wait(4)end;return originalSave(self,player,release)end
 owner:Kick("Studio test: delayed save while leaving")
 local closingDeadline=os.clock()+15
 repeat task.wait(0.05)until Data:Get(owner) and Data:Get(owner)._Closing or os.clock()>closingDeadline
 assert(Data:Get(owner) and Data:Get(owner)._Closing,"No closing window observed")
 assert(not Robbery.Sessions[thief.UserId] and thief.Character.Humanoid.WalkSpeed==16,"Owner departure did not return active carry")
 assert(not Data:CanAct(owner),"Closing profile still accepts actions")
 assert(not Interactions:Request(owner,house.Door,"Door"),"Closing owner interacted during save")
 local accepted,reason=Robbery:Begin(thief,item.Id)
 assert(not accepted and reason:find("leaving"),"New theft began during delayed owner save: "..tostring(reason))
 house.Locked=true;assert(not Robbery:Breach(thief,house.Model.Name),"Breach began during delayed owner save")
 local cleanupDeadline=os.clock()+12
 repeat task.wait(0.1)until not Houses.ByPlayer[owner.UserId] or os.clock()>cleanupDeadline
 Data.Save=originalSave
 assert(not Data:Get(owner) and not house.Owner and not Items.Items[item.Id] and not Items.Models[item.Id],"Departure left profile, plot or item behind")
 task.wait(3);assert(not Robbery.Sessions[thief.UserId] and not Robbery.Preparing[thief.UserId],"Delayed callback resurrected an abandoned theft")
 for _,entry in ipairs(game:GetService("LogService"):GetLogHistory())do assert(entry.messageType~=Enum.MessageType.MessageError,"Disconnect race produced an application error: "..entry.message)end
 return {Passed=true,InjectedSaveDelaySeconds=4,Verified={"Actual owner disconnected while another player carried their item","Carry returned and movement restored before delayed saving","Closing profile rejected interactions","New theft and breach rejected during the save window","Profile, plot and possession cleaned after save","Delayed callbacks did not resurrect the theft"}}
end
local ok,result=pcall(run);Test:EndTest(ok and result or {Passed=false,Error=tostring(result)})
