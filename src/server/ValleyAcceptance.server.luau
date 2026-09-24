if not game:GetService("RunService"):IsStudio()then return end
local Test=game:GetService("StudioTestService");local args=Test:GetTestArgs()
if type(args)~="table"or args.Name~="ValleyAcceptance"then return end
local function run()
 local deadline=os.clock()+45
 repeat task.wait(.2)until workspace:GetAttribute("NeighborhoodReady")or os.clock()>deadline
 local w=workspace.Neighborhood;local valley=assert(w:FindFirstChild("ValleyBackdrop"))
 assert(valley.ModelStreamingMode==Enum.ModelStreamingMode.Persistent,"Skyline may stream away")
 local count=0;for _,p in valley:GetDescendants()do if p:IsA("BasePart")then count+=1;assert(p.Anchored and not p.CanTouch)end end
 assert(count==292,"Unexpected scenery count")
 local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Include;params.FilterDescendantsInstances={valley};params.RespectCanCollide=true
 local rays=0
 for _,height in ipairs({5,40})do for i=0,359 do
  local a=math.rad(i);local hit=workspace:Raycast(Vector3.new(0,height,0),Vector3.new(math.cos(a),0,math.sin(a))*1900,params)
  assert(hit and hit.Instance.Name=="GraniteRidge"or hit and hit.Instance.Name=="WoodedFoothill"or hit and hit.Instance.Name=="PineTrunk","Open boundary at "..i)
  assert(math.abs(hit.Position.X)<1700 and math.abs(hit.Position.Z)<1600,"Barrier beyond ground")
  rays+=1
 end end
 local footing=0
 for _,x in ipairs({-760,0,760})do for _,z in ipairs({-640,0,640})do if x~=0 or z~=0 then
  local hit=workspace:Raycast(Vector3.new(x,60,z),Vector3.new(0,-100,0),params)
  assert(hit,"Missing footing beyond old edge");footing+=1
 end end end
 local path=game:GetService("PathfindingService"):CreatePath({AgentRadius=2,AgentHeight=5,AgentCanJump=true})
 local routes=0
 for _,pair in ipairs({{{-680,3,0},{-760,3,0}},{{680,3,0},{760,3,0}},{{0,3,-570},{0,3,-640}},{{0,3,570},{0,3,640}}})do
  path:ComputeAsync(Vector3.new(table.unpack(pair[1])),Vector3.new(table.unpack(pair[2])))
  assert(path.Status==Enum.PathStatus.Success,"Old edge is obstructed");routes+=1
 end
 return {Passed=true,SceneryParts=count,BoundaryRays=rays,FootingChecks=footing,SuccessfulNavigationRoutes=routes,PersistentSkyline=true,Footprint={3600,3400},Scope="Local two-client Studio test; radial collision and navigation checks, not exhaustive climbing or device performance certification"}
end
local ok,result=pcall(run);Test:EndTest(ok and result or {Passed=false,Error=tostring(result)})
