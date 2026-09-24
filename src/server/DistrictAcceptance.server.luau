if not game:GetService("RunService"):IsStudio()then return end
local Test=game:GetService("StudioTestService");local args=Test:GetTestArgs();if type(args)~="table"or args.Name~="DistrictAcceptance"then return end
local function run()
 local Players=game:GetService("Players");local Data=require(script.Parent.Services.PlayerDataService)
 local deadline=os.clock()+65
 repeat task.wait(.2)until #Players:GetPlayers()==2 and workspace:GetAttribute("NeighborhoodReady")or os.clock()>deadline
 local players=Players:GetPlayers();assert(#players==2 and Data.SessionOnly)
 for _,p in ipairs(players)do repeat task.wait(.1)until Data:Get(p)and Data:Get(p)._Restored and p.Character and p.Character:FindFirstChild("HumanoidRootPart")or os.clock()>deadline;assert(p.Character);p.Character.HumanoidRootPart:SetNetworkOwner(nil)end
 local world=workspace.Neighborhood;assert(world:GetAttribute("HorizontalScale")==3 and world:GetAttribute("DistrictDesign")=="garden-district-3")
 assert(world.Map.VillageGround.Size==Vector3.new(1440,4,1200))
 local root=world.ArtDirection.GardenDistrict
 for _,name in ipairs({"WillowLake","PicnicMeadow","Orchard","Market","MapleGreen","Promenades"})do assert(root:FindFirstChild(name),"Missing district "..name)end
 for _,v in ipairs(root:GetDescendants())do if v:IsA("BasePart")then assert(v.Anchored and math.abs(v.Position.X)<720 and math.abs(v.Position.Z)<600,"Unbounded landscape")end;assert(not v:IsA("MeshPart")and not v:IsA("Decal"),"District requires an external art asset")end
 local Policy=require(script.Parent.LightingPolicy)
 local indoor=world.Houses.House01.BuiltInInterior:FindFirstChildWhichIsA("PointLight",true)
 local street=root.Streets:FindFirstChildWhichIsA("PointLight",true)
 assert(indoor and street and Policy.Enabled(indoor,12,false)and not Policy.Enabled(street,12,false)and Policy.Enabled(street,20,false))
 local holder=Instance.new("Part");holder.Anchored=true;holder.Transparency=1;holder.CanCollide=false;holder.Parent=world.Runtime
 local added=Instance.new("PointLight");added:SetAttribute("LightingRole","Interior");added.Parent=holder;task.wait(.2)
 assert(added.Enabled and indoor.Enabled,"Daytime indoor lighting is off")
 world:SetAttribute("PowerOutage",true);task.wait(.2);assert(not added.Enabled and not indoor.Enabled,"Outage ignored newly created lights")
 world:SetAttribute("PowerOutage",false);task.wait(.2);assert(added.Enabled and indoor.Enabled,"Indoor light failed to restore");holder:Destroy()
 local legs=0
 local function route(player,start,points)
  player.Character:PivotTo(CFrame.new(start[1],4,start[2]));task.wait(.4)
  local human=player.Character.Humanoid;local body=player.Character.HumanoidRootPart
  for _,point in ipairs(points)do
   local goal=Vector3.new(point[1],.7,point[2]);local timeout=os.clock()+(Vector3.new(body.Position.X,.7,body.Position.Z)-goal).Magnitude/12+6
   repeat human:MoveTo(goal);task.wait(.1)until(Vector3.new(body.Position.X,.7,body.Position.Z)-goal).Magnitude<2 or os.clock()>timeout
   assert((Vector3.new(body.Position.X,.7,body.Position.Z)-goal).Magnitude<2.5,"Blocked district path at "..tostring(goal).." actual "..tostring(body.Position));legs+=1
  end
 end
 route(players[1],{-462,0},{{-474,0},{-474,80},{-489,80},{-489,90},{-474,90},{-474,160}})
 route(players[2],{462,0},{{510,0},{570,0},{570,50},{560,77},{548,77},{548,90}})
 route(players[1],{-462,372},{{-462,480},{-408,480},{-315,480},{-250,480}})
 return {Passed=true,Clients=2,PhysicalWalkingLegs=legs,SetupTeleports=3,MapStuds={1440,1200},FoundationStuds={90,78},Verified={"Lake promenade and viewing deck reached on foot","Meadow paths and open pavilion reached on foot","Southern promenade connects to orchard alleys","All six district groups exist; scenery centers stay within map bounds","District art uses built-in geometry with no downloaded meshes or decals"},LightingVerified=true,OnlineSaveRejoinTested=false}
end
local ok,result=pcall(run);Test:EndTest(ok and result or{Passed=false,Error=tostring(result)})
