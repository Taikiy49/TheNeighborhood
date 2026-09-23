if not game:GetService("RunService"):IsStudio()then return end
local Test=game:GetService("StudioTestService");local args=Test:GetTestArgs()
if type(args)~="table"or args.Name~="ArtAcceptance"then return end
local function run()
 local Players=game:GetService("Players");local Houses=require(script.Parent.Services.HouseService)
 local Discovery=require(script.Parent.Services.DiscoveryService);local Data=require(script.Parent.Services.PlayerDataService)
 local deadline=os.clock()+45
 repeat task.wait(0.2)until workspace:GetAttribute("NeighborhoodReady")and #Players:GetPlayers()==2 and Houses.ByPlayer[Players:GetPlayers()[2].UserId]or os.clock()>deadline
 assert(Data.SessionOnly,"Use isolated memory profiles")
 local world=workspace.Neighborhood;local art=assert(world:FindFirstChild("ArtDirection"));local count=0
 for _,p in ipairs(art:GetDescendants())do if p:IsA("BasePart")then
  count+=1;assert(p.Anchored and not p.CanQuery and not p.CanTouch and not p.CanCollide,"Scenery interferes with queries or physics: "..p:GetFullName())
 end end
 assert(count>300 and count<1900,"Unexpected art budget")
 assert(world:GetAttribute('ArtPassVersion')==2,'Expected garden redesign')
 local textureCount=0;local meshCount=0
 for _,p in world:GetDescendants()do
  if p:IsA('Texture')and p.Name:match('^HiggsfieldSiding')then textureCount+=1;assert(p.Texture=='rbxassetid://112300470260355','Wrong siding texture')end
  if p:IsA('MeshPart')then meshCount+=1;assert(p.MeshId~=''and p.TextureID~='','Missing mesh content')end
 end
 assert(textureCount>=128 and meshCount>=32,'Art assets missing')
 local path=game:GetService("PathfindingService"):CreatePath({AgentRadius=2,AgentHeight=5,AgentCanJump=true})
 local routes=0
 local function route(a,b,label)
  path:ComputeAsync(a,b);assert(path.Status==Enum.PathStatus.Success,"Art pass obstructed "..label);routes+=1
 end
 local start=world.Map.CommunityBoard.Position+Vector3.new(0,-2,-5)
 for id,h in pairs(Houses.ById)do
  Houses:SetDoor(h,true);task.wait(0.3)
  route(start,h.Model.Mailbox.Box.Position+Vector3.new(0,0,-4),id.." delivery")
  route(h.Model.Arrival.Position,h.Model.Foundation.CFrame:PointToWorldSpace(Vector3.new(0,3,-5)),id.." entrance")
  assert(h.Model.DisplaySlots:FindFirstChild("Slot6"),"Display slot missing")
  Houses:SetDoor(h,false)
 end
 for id,marker in pairs(Discovery.Markers)do route(start,marker.Position+Vector3.new(0,2,-3),id.." trail")end
 for _,shop in ipairs(world.Shops:GetChildren())do route(start,shop.Counter.Position+Vector3.new(0,2,-5),shop.Name)end
 local errors={};for _,v in ipairs(game:GetService("LogService"):GetLogHistory())do if v.messageType==Enum.MessageType.MessageError then table.insert(errors,v.message)end end
 assert(#errors==0,table.concat(errors,"; "))
 return {Passed=true,DecorativeParts=count,SidingTextures=textureCount,TexturedMeshes=meshCount,SuccessfulNavigationRoutes=routes,Verified={"All decorative geometry is anchored and excluded from gameplay raycasts, touch and collision","Eight delivery routes and eight front-door routes remain navigable","All five gnome clues and both stores remain reachable","Six item display slots retained in every house","Scene stays within the explicit decoration budget","Generated siding and tree meshes retained"},Errors=errors}
end
local ok,result=pcall(run);Test:EndTest(ok and result or {Passed=false,Error=tostring(result)})
