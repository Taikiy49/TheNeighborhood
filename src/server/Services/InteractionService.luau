local Players = game:GetService("Players")
local Prompts = game:GetService("ProximityPromptService")
local Config = require(game.ReplicatedStorage.Neighborhood.Shared.Config)
local Service = {Last = {}, Handlers = {}}
function Service:Register(action, handler) self.Handlers[action] = handler end
function Service:Validate(player, target)
    if typeof(target) ~= "Instance" or not target:IsA("BasePart") or not target:IsDescendantOf(workspace.Neighborhood) then return false,"Unavailable interaction." end
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid or humanoid.Health<=0 then return false,"Your character is not ready." end
    local distance = (root.Position-target.Position).Magnitude
    if distance ~= distance or distance > Config.InteractionRange then return false,"Move closer." end
    local ray = RaycastParams.new(); ray.FilterType=Enum.RaycastFilterType.Exclude
    ray.FilterDescendantsInstances=(target:GetAttribute("ItemId") or target:GetAttribute("VehicleOwner")) and {char,target.Parent} or {char}
    local hit = workspace:Raycast(root.Position,target.Position-root.Position,ray)
    if hit and hit.Instance ~= target and not hit.Instance:IsDescendantOf(target) then return false,"There is something in the way." end
    return true
end
function Service:Request(player, target, action)
    if not self.Context.Data:CanAct(player) then return false,"Your profile is loading or closing."end
    local now = os.clock()
    if now-(self.Last[player.UserId] or 0)<Config.ActionInterval then return false,"Slow down a moment." end
    self.Last[player.UserId] = now
    if type(action)~="string" or #action>32 then return false,"Invalid action." end
    local valid,message = self:Validate(player,target)
    if not valid then return false,message end
    if target:GetAttribute("Action")~=action and target:GetAttribute("SecondaryAction")~=action then return false,"Unavailable action." end
    local handler=self.Handlers[action]; if not handler then return false,"Unavailable action." end
    return handler(player,target,action)
end
function Service:Init(context)
    self.Context=context
    Prompts.PromptTriggered:Connect(function(prompt,player)
        local target=prompt.Parent
        if not target or not target:IsDescendantOf(workspace.Neighborhood) then return end
        local ok,message=self:Request(player,target,prompt:GetAttribute("Action"))
        context.Notify(player,message,ok)
        context.Sync(player)
    end)
    Players.PlayerRemoving:Connect(function(p) self.Last[p.UserId]=nil end)
end
return Service
