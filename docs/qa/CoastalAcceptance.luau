-- Run as a normal server Script in a Studio session-only fixture after finishing ArrivalIntro.
-- Keep this script out of the published Edit datamodel. Do not run concurrently with ride tests.
local W=require(game.ServerScriptService.Neighborhood.CoastalWorld)
local c=W.Context
assert(c.Data.SessionOnly,'Use a session-only Studio fixture')
local p=game.Players:GetPlayers()[1]
while not c.Data:Get(p)or not p.Character do task.wait(.1)end
require(game.ServerScriptService.Neighborhood.Services.VehicleService):Remove(p)
p.Character.Humanoid.Sit=false
task.wait(2)
local report={}
local first=next(W.Nodes);local q={first};local seen={}
while #q>0 do local id=table.remove(q);if not seen[id]then seen[id]=true;for _,e in ipairs(W.Edges)do if e[1]==id then table.insert(q,e[2])elseif e[2]==id then table.insert(q,e[1])end end end end
local n,reached=0,0;for _ in pairs(W.Nodes)do n+=1 end;for _ in pairs(seen)do reached+=1 end
assert(n==reached,'Disconnected roads');report.RoadNodes=n;report.RoadEdges=#W.Edges
local L=require(game.ReplicatedStorage.Neighborhood.Shared.PlotLayout);local streets={}
for _,h in ipairs(workspace.Neighborhood.Houses:GetChildren())do local id=tonumber(h.Name:match('%d+'));streets[L.Street(id)]=(streets[L.Street(id)]or 0)+1 end
for _,count in pairs(streets)do assert(count==4)end;report.Houses=12;report.Streets=3
local count=0
for id,dest in pairs(W.Destinations)do p.Character:PivotTo(W.Stops[1].CFrame*CFrame.new(0,0,-5));task.wait(.1);local ok,msg=W.Travel(p,id);assert(ok,msg);assert((p.Character:GetPivot().Position-dest).Magnitude<1);count+=1 end
report.Transit=count
local Vehicles=require(game.ServerScriptService.Neighborhood.Services.VehicleService)
local profile=c.Data:Get(p);profile.Vehicles.Compact=true;local original=c.Houses.ByPlayer[p.UserId];local garages=0
for _,h in pairs(c.Houses.ById)do c.Houses.ByPlayer[p.UserId]=h;local ok,msg=Vehicles:Spawn(p);assert(ok,h.Model.Name..': '..tostring(msg));Vehicles:Remove(p);garages+=1 end
c.Houses.ByPlayer[p.UserId]=original;report.CarSpawns=garages
local params=OverlapParams.new();params.FilterType=Enum.RaycastFilterType.Exclude;params.FilterDescendantsInstances={workspace.Neighborhood.CoastalWorld.Roads,workspace.Neighborhood.Runtime,p.Character}
local obstacles={}
for _,road in ipairs(W.Root.Roads:GetChildren())do if road.Material==Enum.Material.Asphalt then for _,part in ipairs(workspace:GetPartBoundsInBox(road.CFrame+Vector3.new(0,3,0),Vector3.new(road.Size.X-1,4,road.Size.Z-1),params))do if part.CanCollide and part.Position.Y>1 then table.insert(obstacles,part:GetFullName())end end end end
report.RoadObstacles=#obstacles;assert(#obstacles==0,table.concat(obstacles,','))
workspace:SetAttribute('CoastalAcceptanceFinal',game:GetService('HttpService'):JSONEncode(report))
p.Character:PivotTo(original.Model.HomeSpawn.CFrame+Vector3.new(0,3,0))
