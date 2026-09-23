-- Explicit local visual/input fixture. PlayerDataService uses memory only in this Studio mode.
if not game:GetService("RunService"):IsStudio() or workspace:GetAttribute("NeighborhoodVisualTest")~=true then return end
local Players=game:GetService("Players")
local Data=require(script.Parent.Services.PlayerDataService)
local Houses=require(script.Parent.Services.HouseService)
local Vehicles=require(script.Parent.Services.VehicleService)
local Pets=require(script.Parent.Services.PetService)
local deadline=os.clock()+40
repeat task.wait(0.2)until workspace:GetAttribute("NeighborhoodReady") and Players:GetPlayers()[1] and Houses.ByPlayer[Players:GetPlayers()[1].UserId] or os.clock()>deadline
local player=assert(Players:GetPlayers()[1],"Visual fixture player unavailable")
assert(Data.SessionOnly,"Visual fixture must never write persistent profiles")
if workspace:GetAttribute("VisualExploration")==true then
 repeat task.wait(0.2)until player.Character and player.Character:FindFirstChild("HumanoidRootPart") or os.clock()>deadline
 require(script.Parent.Services.WeatherService):Set("Rain")
 player.Character:PivotTo(workspace.Neighborhood.Map.CommunityBoard.CFrame*CFrame.new(0,-1,-5))
 local ok,why=require(script.Parent.Services.DeliveryService):Start(player);assert(ok,why)
 Data.Context.Sync(player)
 return
end
Data:Get(player).Currency=10000
assert(Vehicles:Action(player,"Buy"));assert(Pets:Action(player,"Adopt"))
local car=assert(Vehicles.Cars[player.UserId])
repeat task.wait(0.2)until player.Character and player.Character:FindFirstChild("HumanoidRootPart") or os.clock()>deadline
player.Character:PivotTo(car.Seat.CFrame*CFrame.new(0,2,0));car.Seat:Sit(player.Character.Humanoid)
car.Body:SetNetworkOwner(nil)
workspace:SetAttribute("VisualCarStart",car.Body.Position)
Data.Context.Sync(player)
