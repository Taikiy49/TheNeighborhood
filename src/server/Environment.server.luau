local Lighting=game:GetService("Lighting")
local Policy=require(script.Parent.LightingPolicy)
local world=workspace:WaitForChild("Neighborhood")
local lamps={}
local hours=15.5
local function update(lamp)lamp.Enabled=Policy.Enabled(lamp,hours,world:GetAttribute("PowerOutage")==true)end
local function register(v)if v:IsA("PointLight")then lamps[v]=true;update(v)end end
for _,v in ipairs(world:GetDescendants())do register(v)end
world.DescendantAdded:Connect(register)
world.DescendantRemoving:Connect(function(v)lamps[v]=nil end)
world:GetAttributeChangedSignal("PowerOutage"):Connect(function()for lamp in pairs(lamps)do if lamp.Parent then update(lamp)end end end)
local start=os.clock()
while true do
 hours=(15.5+(os.clock()-start)/75)%24
 Lighting.ClockTime=hours
 for lamp in pairs(lamps)do if lamp.Parent then update(lamp)else lamps[lamp]=nil end end
 task.wait(2)
end
