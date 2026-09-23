local Feedback={}
function Feedback.Init()
 local audio=game:GetService("SoundService")
 local Debris=game:GetService("Debris")
 local function tone(pitch)
  local sound=Instance.new("Sound")
  sound.Name="NeighborhoodFeedback";sound.SoundId="rbxasset://sounds/volume_slider.ogg"
  sound.Volume=0.12;sound.PlaybackSpeed=pitch;sound.Parent=audio;sound:Play();Debris:AddItem(sound,3)
 end
 game.ReplicatedStorage.Neighborhood.Remotes.Notification.OnClientEvent:Connect(function(data)tone(data.Success and 1.25 or 0.75)end)
 local houses=workspace.Neighborhood:WaitForChild("Houses")
 local watched=setmetatable({},{__mode="k"})
 local function attach(door)
  if door.Name~="Door" or not door:IsA("BasePart") or not door.Parent or door.Parent.Parent~=houses or watched[door] then return end
  watched[door]=true;local house=door.Parent
  local lamp=Instance.new("PointLight");lamp.Name="AlarmLight";lamp.Color=Color3.fromRGB(255,104,72);lamp.Range=18;lamp.Brightness=0;lamp.Parent=door
  local generation=0
  local function changed()
   generation+=1;local current=generation
   if not house:GetAttribute("Alarm") then lamp.Brightness=0;return end
   task.spawn(function()
    while current==generation and door.Parent do
     lamp.Brightness=2
     local player=game.Players.LocalPlayer;local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
     if root and (root.Position-door.Position).Magnitude<65 then tone(0.65) end
     task.wait(0.35);if current~=generation then return end;lamp.Brightness=0;task.wait(0.65)
    end
   end)
  end
  local connection=house:GetAttributeChangedSignal("Alarm"):Connect(changed)
  door.Destroying:Connect(function()generation+=1;connection:Disconnect();watched[door]=nil end)
  changed()
 end
 houses.DescendantAdded:Connect(attach)
 for _,part in ipairs(houses:GetDescendants())do attach(part)end
end
return Feedback
