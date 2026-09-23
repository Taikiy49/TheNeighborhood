local Lighting=game:GetService("Lighting")
local world=workspace:WaitForChild("Neighborhood")
local lamps={}
for _,v in ipairs(world:GetDescendants())do if v:IsA("PointLight")then table.insert(lamps,v)end end
local start=os.clock()
while true do
 local hours=(15.5+(os.clock()-start)/75)%24
 Lighting.ClockTime=hours
 local night=hours>18 or hours<6
 for _,lamp in ipairs(lamps)do if lamp.Parent then lamp.Enabled=night end end
 task.wait(2)
end
