if not game:GetService("RunService"):IsStudio()then return end
local Test=game:GetService("StudioTestService");local args=Test:GetTestArgs()
if type(args)~="table"or args.Name~="FurnishingAcceptance"then return end
local function run()
 local Players=game:GetService("Players");local H=require(script.Parent.Services.HouseService)
 local Data=require(script.Parent.Services.PlayerDataService)
 local untilTime=os.clock()+45
 repeat task.wait(.2)until #Players:GetPlayers()==2 and workspace:GetAttribute("NeighborhoodReady")or os.clock()>untilTime
 assert(Data.SessionOnly)
 local path=game:GetService("PathfindingService"):CreatePath({AgentRadius=2,AgentHeight=5,AgentCanJump=false})
 local routes,seats=0,0
 for _,h in workspace.Neighborhood.Houses:GetChildren()do
  local f=assert(h:FindFirstChild("FurnishedRooms"));assert(h:GetAttribute("FurnishingVersion")=="furnished-cottage-1")
  assert(f:FindFirstChild("DiningTable")and f:FindFirstChild("IslandWorktop")and f:FindFirstChild("Wardrobe")and f:FindFirstChild("BookcaseShelf"))
  for _,v in f:GetChildren()do if v:IsA("Seat")then seats+=1 end;assert(v:IsA("BasePart")and v.Anchored and not v.CanTouch)end
  for _,slot in h.DisplaySlots:GetChildren()do if slot:IsA("BasePart")then
   path:ComputeAsync(h.Foundation.CFrame:PointToWorldSpace(Vector3.new(0,3,-6)),slot.Position+Vector3.new(0,3,0))
   assert(path.Status==Enum.PathStatus.Success,"Furniture obstructs "..h.Name.." "..slot.Name);routes+=1
  end end
 end
 assert(seats==48,"Expected six usable seats in every home")
 local seated=0
 for _,p in Players:GetPlayers()do
  repeat task.wait(.1)until H.ByPlayer[p.UserId]and p.Character and p.Character:FindFirstChildOfClass("Humanoid")or os.clock()>untilTime
  local h=H.ByPlayer[p.UserId].Model;local seat=h.FurnishedRooms.DiningSeat;local hum=p.Character:FindFirstChildOfClass("Humanoid")
  p.Character:PivotTo(seat.CFrame*CFrame.new(0,3,0));seat:Sit(hum);task.wait(.4)
  assert(seat.Occupant==hum,"Dining chair cannot be used");seated+=1;hum.Sit=false;hum.Jump=true
 end
 return {Passed=true,Houses=8,UsableSeats=seats,ActualPlayersSeated=seated,DisplaySlotRoutes=routes,Scope="Local two-client fixture; no production profile mutation"}
end
local ok,result=pcall(run);Test:EndTest(ok and result or {Passed=false,Error=tostring(result)})
