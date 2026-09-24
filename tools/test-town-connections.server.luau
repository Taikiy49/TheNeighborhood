local root=game.ServerScriptService.Neighborhood
local D=require(root.Services.PlayerDataService)
assert(D.SessionOnly,'Run only in an isolated Studio profile')
local C=require(root.TownConnections)
local Sports=require(root.SportsGrounds)
local I=require(root.Services.InteractionService)
local p=game.Players:GetPlayers()[1]
local hum=p.Character.Humanoid;local hrp=p.Character.HumanoidRootPart
hrp:SetNetworkOwner(nil)
local report={Routes=#C.Routes,Samples=0,Blocked={},GrassGaps={},Walked={},Sports=0}
local q=OverlapParams.new();q.RespectCanCollide=true;q.FilterType=Enum.RaycastFilterType.Exclude
local exclusions={}
for _,player in ipairs(game.Players:GetPlayers())do table.insert(exclusions,player.Character)end
q.FilterDescendantsInstances=exclusions
local ray=RaycastParams.new();ray.RespectCanCollide=true;ray.FilterType=Enum.RaycastFilterType.Exclude;ray.FilterDescendantsInstances=exclusions
local probe=Instance.new("Part");probe.Name="PathCollisionProbe";probe.Anchored=true;probe.Transparency=1;probe.CanCollide=false;probe.CanTouch=false;probe.CanQuery=false;probe.Parent=workspace
local function preciseBox(cf,size)probe.Size=size;probe.CFrame=cf;return workspace:GetPartsInPart(probe,q)end
local seen={}
for _,route in ipairs(C.Routes)do
 for i=1,#route.Points-1 do
  local a,b=route.Points[i],route.Points[i+1];local length=(b-a).Magnitude
  if length>.01 then for t=0,length,3 do
   local pos=a:Lerp(b,t/length);report.Samples+=1
   for _,part in ipairs(preciseBox(CFrame.new(pos+Vector3.new(0,3.4,0)),Vector3.new(3,4.2,3)))do
    local key=route.Model.Name..part:GetFullName()
    if not seen[key]then seen[key]=true;table.insert(report.Blocked,{Route=route.Model.Name,Part=part:GetFullName()})end
   end
   local hit=workspace:Raycast(pos+Vector3.new(0,1.5,0),Vector3.new(0,-4,0),ray)
   if not hit or hit.Material==Enum.Material.Grass then table.insert(report.GrassGaps,{Route=route.Model.Name,Position=tostring(pos)})end
  end end
 end
end
workspace:SetAttribute('TownConnectionQA',game:GetService('HttpService'):JSONEncode(report))
assert(#report.Blocked==0,'Blocked paths: '..game:GetService('HttpService'):JSONEncode(report.Blocked))
assert(#report.GrassGaps==0,'Grass gaps')
local paving={}
for _,v in ipairs(C.Root:GetDescendants())do if v:IsA('BasePart')then table.insert(paving,v)end end
for i,a in ipairs(paving)do for j=i+1,#paving do local b=paving[j]
 local dx=(a.Size.X+b.Size.X)/2-math.abs(a.Position.X-b.Position.X)
 local dz=(a.Size.Z+b.Size.Z)/2-math.abs(a.Position.Z-b.Position.Z)
 assert(dx<.03 or dz<.03,'Coplanar path overlap')
end end
for _,v in ipairs(C.Root.SportsPromenade:GetChildren())do
 local hits=workspace:GetPartBoundsInBox(v.CFrame+Vector3.new(0,3.4,0),Vector3.new(math.max(.1,v.Size.X-.5),4.4,math.max(.1,v.Size.Z-.5)),q)
 assert(#hits==0,'Sports promenade blocked: '..(hits[1]and hits[1]:GetFullName()or ''))
end
for _,v in ipairs(game.ServerStorage.SportsArt:GetDescendants())do
 assert(not v:IsA('LuaSourceContainer')and not v:IsA('RemoteEvent')and not v:IsA('RemoteFunction'),'External executable code')
end
report.NonoverlappingPaving=#paving
local walks={CarShowroom=true,RepairWorkshop=true,CornerCafe=true,GeneralStore=true,OrchardStand=true,CoastSchool=true,PalmResort=true,HangarOne=true,BeachChangingRooms=true,FuelAndSnacks=true}
for _,route in ipairs(C.Routes)do if walks[route.Model.Name]then
 p.Character:PivotTo(CFrame.new(route.Points[#route.Points]+Vector3.new(0,3,0)));hrp.AssemblyLinearVelocity=Vector3.zero;task.wait(.2)
 for i=#route.Points-1,1,-1 do
  local goal=route.Points[i];local deadline=os.clock()+15
  repeat hum:MoveTo(goal);task.wait(.1)until Vector3.new(hrp.Position.X-goal.X,0,hrp.Position.Z-goal.Z).Magnitude<2 or os.clock()>deadline
  assert(Vector3.new(hrp.Position.X-goal.X,0,hrp.Position.Z-goal.Z).Magnitude<2.5,'Cannot walk '..route.Model.Name)
 end
 table.insert(report.Walked,route.Model.Name)
 workspace:SetAttribute('TownConnectionQA',game:GetService('HttpService'):JSONEncode(report))
end end
for ball,state in pairs(Sports.Balls)do
 assert(#state.Goals==2 and ball:GetNetworkOwner()==nil)
 p.Character:PivotTo(CFrame.new(state.Home+Vector3.new(30,3,0)));I.Last[p.UserId]=nil
 assert(not I:Request(p,ball,'PlaySport'),'distant action')
 Sports:Reset(state);p.Character:PivotTo(CFrame.lookAt(state.Home+Vector3.new(0,3,4),state.Home));task.wait(.2);I.Last[p.UserId]=nil
 local origin=ball.Position;local ok,why=I:Request(p,ball,'PlaySport');assert(ok,why)
 assert(not Sports:Play(p,ball),'duplicate shot');task.wait(.2)
 assert((ball.Position-origin).Magnitude>1,'ball motion')
 Sports:Reset(state)
 local before=Sports.Scores[state.Kind][1]
 if state.Kind=='Soccer'then local g=state.Goals[1];state.Previous=g.Position+Vector3.new(0,2,-g.Side*2);ball.CFrame=CFrame.new(g.Position+Vector3.new(0,2,g.Side*2))
 else local g=state.Goals[1];state.Previous=g+Vector3.new(0,2,0);ball.CFrame=CFrame.new(g-Vector3.new(0,.2,0))end
 Sports:Step();assert(Sports.Scores[state.Kind][1]==before+1,'score detection')
 Sports:Step();assert(Sports.Scores[state.Kind][1]==before+1,'duplicate score')
 state.ResetAt=0;Sports:Step();assert((ball.Position-state.Home).Magnitude<.1,'score reset')
 ball.CFrame=CFrame.new(state.Center+Vector3.new(400,2,0));Sports:Step();assert((ball.Position-state.Home).Magnitude<.1,'out of bounds reset')
 report.Sports+=1
end
for _,id in ipairs({'Activity001','Activity002','Activity003','Activity008'})do assert(not workspace.Neighborhood.Recreation:FindFirstChild(id,true))end
for _,v in ipairs(workspace.Neighborhood.Recreation:GetDescendants())do assert(v.Name~='ActivitySign'and v.Name~='SignSupport')end
probe:Destroy()
report.Passed=true
workspace:SetAttribute('TownConnectionQA',game:GetService('HttpService'):JSONEncode(report))
print('TOWN CONNECTIONS AND SPORTS PASS',report.Routes,report.Samples,#report.Walked,report.Sports)
