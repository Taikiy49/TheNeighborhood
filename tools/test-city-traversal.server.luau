assert(game:GetService('RunService'):IsStudio())
local ok,result=xpcall(function()
 local p=game.Players:GetPlayers()[1];local c=p.Character;local h=c.Humanoid;local r=c.HumanoidRootPart;r:SetNetworkOwner(nil)
 local function walk(at,seconds)
  h:MoveTo(at);local stop=os.clock()+seconds
  repeat h:MoveTo(at);task.wait(.1)until(r.Position-at).Magnitude<4 or os.clock()>stop
  assert((r.Position-at).Magnitude<4,'Walk blocked: '..tostring(at)..' reached '..tostring(r.Position))
 end
 local city=workspace.Neighborhood.MapleHeights
 c:PivotTo(CFrame.new(-273,3,-77));task.wait(.3)
 local stop=os.clock()+12
 repeat h:Move(Vector3.new(0,0,-1),false);task.wait(.1)until r.Position.Y>28 or os.clock()>stop
 assert(r.Position.Y>28,'Fire escape could not be climbed')
 h:Move(Vector3.zero,false);h.Jump=true;walk(Vector3.new(-281,28,-80),4)
 walk(Vector3.new(-281,28,-72),3);walk(Vector3.new(-247,28,-72),6)
 c:PivotTo(CFrame.new(108,3,-232));task.wait(.3)
 walk(Vector3.new(108,8,-274),8);walk(Vector3.new(-108,8,-274),20);walk(Vector3.new(-108,3,-232),8)
 -- A real position discontinuity must cancel the timed roof survey.
 local J=require(game.ServerScriptService.Neighborhood.CityJobs);local I=require(game.ServerScriptService.Neighborhood.Services.InteractionService)
 local start=city.OldTown.RouteStart;c:PivotTo(start.CFrame*CFrame.new(0,1,-3));task.wait(.4);J.Last[p.UserId]=nil;I.Last[p.UserId]=nil
 assert(I:Request(p,start,'CityWork'));c:PivotTo(CFrame.new(0,4,0));task.wait(.5);assert(not J.Active[p.UserId],'Teleport did not cancel roof route')
 return {'Actual humanoid climbed fire escape','Walked both roofs and connecting bridge','Walked up, across and down cove bridge','Roof teleport rejection'}
end,debug.traceback)
workspace:SetAttribute('CityTraversalResult',game.HttpService:JSONEncode({ok=ok,result=result}))
