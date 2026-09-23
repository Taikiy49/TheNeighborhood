local Pose={}
function Pose.Init()
 local Players=game:GetService("Players");local Run=game:GetService("RunService")
 local joints=setmetatable({},{__mode="k"});local bases=setmetatable({},{__mode="k"})
 local function characterAdded(character)
  local function register(joint)
   if (joint:IsA("Motor6D") or joint:IsA("AnimationConstraint")) and joint.Name:lower():find("shoulder")then joints[joint]=character end
  end
  character.DescendantAdded:Connect(register);for _,joint in ipairs(character:GetDescendants())do register(joint)end
 end
 local function playerAdded(player)player.CharacterAdded:Connect(characterAdded);if player.Character then characterAdded(player.Character)end end
 Players.PlayerAdded:Connect(playerAdded);for _,player in ipairs(Players:GetPlayers())do playerAdded(player)end
 -- Remove our previous offset before Animator evaluation, then layer after it.
 Run.PreAnimation:Connect(function()for joint,base in pairs(bases)do if joint.Parent then joint.Transform=base end;bases[joint]=nil end end)
 Run.PreSimulation:Connect(function()
  for joint,character in pairs(joints)do
   if not joint.Parent or not character.Parent then joints[joint]=nil
   elseif character:GetAttribute("CarryPose")then bases[joint]=joint.Transform;joint.Transform=joint.Transform*CFrame.Angles(math.rad(65),0,0)end
  end
 end)
end
return Pose
