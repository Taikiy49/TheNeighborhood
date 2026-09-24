local player=game:GetService("Players").LocalPlayer
local remote=game.ReplicatedStorage:WaitForChild("Neighborhood"):WaitForChild("Remotes"):WaitForChild("Request")
local function character(char)
 local function tool(v)
  if not v:IsA("Tool")or not v:GetAttribute("RecreationToy")or v:GetAttribute("ToyClientBound")then return end
  v:SetAttribute("ToyClientBound",true)
  v.Activated:Connect(function()remote:FireServer("Playground","Throw")end)
 end
 char.ChildAdded:Connect(tool);for _,v in ipairs(char:GetChildren())do tool(v)end
end
player.CharacterAdded:Connect(character);if player.Character then character(player.Character)end
