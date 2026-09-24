if not game:GetService("RunService"):IsStudio()then return end
local Test=game:GetService("StudioTestService");local args=Test:GetTestArgs()
if type(args)~="table"or args.Name~="RenewalAcceptance"then return end
local ok,result=xpcall(function()
 local deadline=os.clock()+40;local P=game.Players;local root=script.Parent
 local H=require(root.Services.HouseService);local D=require(root.Services.PlayerDataService);local I=require(root.Services.InteractionService);local R=require(root.Services.RecreationService)
 repeat task.wait(.2)until #P:GetPlayers()==8 and workspace:GetAttribute("NeighborhoodReady")or os.clock()>deadline
 local players=P:GetPlayers();assert(#players==8,"Eight clients required")
 local seen={};local houses={}
 for _,p in ipairs(players)do
  repeat task.wait(.1)until D:CanAct(p)and H.ByPlayer[p.UserId]and p.Character and p.Character:FindFirstChild("HumanoidRootPart")or os.clock()>deadline
  assert(D:CanAct(p),"Profile blocked");local h=assert(H.ByPlayer[p.UserId]);assert(not seen[h.Model.Name]);seen[h.Model.Name]=true;table.insert(houses,h.Model.Name)
  repeat task.wait(.1)until H:ContainsInterior(h,p.Character:GetPivot().Position)or os.clock()>deadline
  assert(H:ContainsInterior(h,p.Character:GetPivot().Position),"Spawn is outside home: "..p.Name.." "..tostring(p.Character:GetPivot().Position).." expected "..tostring(h.Model.Foundation.Position))
  assert(h.Model.Mailbox.Sign.SurfaceGui.TextLabel.Text:find(p.DisplayName,1,true),"Owner missing from sign")
 end
 task.wait(2);assert(#workspace.Neighborhood.Runtime.ResidentNeighbors:GetChildren()==4,"NPC vacancy count")
 local p=players[1];local h=H.ByPlayer[p.UserId]
 -- Real slots beyond eight; no fabricated Player instances.
 for slot=9,12 do
  H:Release(p);p:SetAttribute("NeighborhoodSlot",slot);local nextHome=assert(H:Assign(p));assert(nextHome.Model.Name==string.format("House%02d",slot));assert(H:DoorAction(p,nextHome.Door,"Door"))
 end
 H:Release(p);p:SetAttribute("NeighborhoodSlot",nil);H:Assign(p)
 local profile=D:Get(p);local Schema=require(root.ProfileSchema)
 local migrated=Schema.Migrate(Schema.Default(),p.UserId);assert(migrated.Settings.Music and migrated.Trials.XP==0)
 local store={};local Repo=require(root.ProfileRepository).new({UpdateAsync=function(_,key,fn)local v=fn(store[key]);if v then store[key]=v end;return v end},"renewal-fixture")
 assert(Repo:Load(p.UserId));local cash=profile.Currency
 R:TrialReward(p,"Activity006",2.9);assert(profile.Currency==cash+75 and profile.Trials.Best.Activity006==2900)
 R:TrialReward(p,"Activity006",4);assert(profile.Currency==cash+75,"Reward cooldown bypass")
 assert(Repo:Save(p.UserId,D:Snapshot(p),true));local reload=assert(Repo:Load(p.UserId));assert(reload.Trials.Best.Activity006==2900 and reload.Settings.Music,"New progress did not survive rejoin")
 local tower=workspace.Neighborhood.MapleTower
 p.Character:PivotTo(tower.GroundLift.CFrame*CFrame.new(0,0,-4));task.wait(.4)
 local lifted,why=I:Request(p,tower.GroundLift,"TowerLift");assert(lifted,why);assert(p.Character:GetPivot().Position.Y>55)
 p.Character:PivotTo(tower.RoofLift.CFrame*CFrame.new(0,0,-4));task.wait(.4);assert(I:Request(p,tower.RoofLift,"TowerLift"));assert(p.Character:GetPivot().Position.Y<10)
 local human=p.Character:FindFirstChildOfClass("Humanoid")
 p.Character:PivotTo(CFrame.new(-264,-2,42));task.wait(3);assert(human:GetState()==Enum.HumanoidStateType.Swimming,"Lake does not support swimming")
 local originalNotify=R.Context.Notify;local trialMessages={};R.Context.Notify=function(who,message,success)if who==p then table.insert(trialMessages,tostring(message))end;originalNotify(who,message,success)end
 local course=R:Model("Activity006");p.Character:PivotTo(CFrame.new(course.Start.Position+Vector3.new(0,3,0)));task.wait(.5)
 assert(R:Use(p,course.Interact));task.wait(.3)
 local function walk(pos)
  human:MoveTo(pos);local stop=os.clock()+7
  repeat task.wait(.1)until (Vector3.new(p.Character:GetPivot().Position.X,0,p.Character:GetPivot().Position.Z)-Vector3.new(pos.X,0,pos.Z)).Magnitude<2 or os.clock()>stop
  assert(os.clock()<stop,"Course walking stalled")
 end
 walk(course.Finish.Position);task.wait(.3);walk(course.Start.Position);task.wait(.4);assert(R.Courses[p]==nil,"Sprint did not finish")
 assert(profile.Trials.Wins.Activity006>=3,"Walking course did not record completion: "..table.concat(trialMessages," | "))
 p.Character:PivotTo(CFrame.new(course.Start.Position+Vector3.new(0,3,0)));task.wait(.3);assert(R:Use(p,course.Interact));task.wait(.2)
 local wins=profile.Trials.Wins.Activity006;p.Character:PivotTo(CFrame.new(0,4,0));task.wait(.4);assert(R.Courses[p]==nil and profile.Trials.Wins.Activity006==wins,"Teleport rewarded")
 local errors={};for _,v in ipairs(game:GetService("LogService"):GetLogHistory())do if v.messageType==Enum.MessageType.MessageError then table.insert(errors,v.message)end end
 return {Passed=#errors==0,Errors=errors,Houses=houses,Verified={"8 real clients with ready profiles and distinct named homes","All 12 housing slots assignable","Four vacancy NPCs at eight players","Interior arrival","Swimming in terrain water","Library lift both directions","Gold reward and cooldown","Trial records and music preference survive repository rejoin","Real humanoid sprint completion","Teleport shortcut rejected"}}
end,debug.traceback)
Test:EndTest(ok and result or {Passed=false,Error=result})
