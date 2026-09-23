return function()
 local player=game.Players.LocalPlayer;local remote=game.ReplicatedStorage.Neighborhood.Remotes:WaitForChild("Drive")
 task.spawn(function()while true do
  task.wait(0.12)
  local humanoid=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
  local seat=humanoid and humanoid.SeatPart
  if seat and seat:IsA("VehicleSeat") and seat:GetAttribute("VehicleOwner")==player.UserId then remote:FireServer(seat.ThrottleFloat,seat.SteerFloat)end
 end end)
end
