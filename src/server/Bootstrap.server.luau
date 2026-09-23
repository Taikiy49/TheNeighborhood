local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local root=RS:WaitForChild("Neighborhood")
local remotes=root:WaitForChild("Remotes")
local Data=require(script.Parent.Services.PlayerDataService)
local Houses=require(script.Parent.Services.HouseService)
local Interactions=require(script.Parent.Services.InteractionService)
local context={Data=Data,Houses=Houses,Interactions=Interactions}
context.Notify=function(player,message,ok)
    if player.Parent==Players and message then remotes.Notification:FireClient(player,{Text=message,Success=ok}) end
end
context.Snapshot=function(player)
    local profile=Data:Get(player); local house=Houses.ByPlayer[player.UserId]
    return {Currency=profile and profile.Currency or 0,Address=house and house.Model:GetAttribute("Address") or "Finding your home",HouseId=house and house.Model.Name,SessionOnly=true}
end
context.Sync=function(player) if player.Parent==Players then remotes.State:FireClient(player,context.Snapshot(player)) end end
Houses:Init(context); Interactions:Init(context)
Interactions:Register("Door",function(...) return Houses:DoorAction(...) end)
Interactions:Register("Lock",function(...) return Houses:DoorAction(...) end)
Interactions:Register("Doorbell",function(player,target)
    local house=Houses.ById[target:GetAttribute("HouseId")]
    if house and house.Owner then
        local owner=Players:GetPlayerByUserId(house.Owner)
        if owner then context.Notify(owner,"Ding dong! A neighbor is at your door.",true) end
        return true,"Doorbell rung. Try looking innocent."
    end
    return false,"Nobody has moved in yet."
end)
local function characterAdded(player,character)
    local rootPart=character:WaitForChild("HumanoidRootPart",10)
    local house=Houses.ByPlayer[player.UserId]
    if rootPart and house then character:PivotTo(house.Model.Arrival.CFrame) end
end
local function added(player)
    Data:Load(player)
    local house=Houses:Assign(player)
    if not house then player:Kick("This neighborhood is full. Please join another server."); return end
    player.CharacterAdded:Connect(function(c) characterAdded(player,c) end)
    if player.Character then task.spawn(characterAdded,player,player.Character) end
    context.Sync(player)
end
Players.PlayerAdded:Connect(added)
Players.PlayerRemoving:Connect(function(player) Houses:Release(player); Data:Release(player) end)
for _,player in ipairs(Players:GetPlayers()) do task.spawn(added,player) end
local lastSync={}
remotes.Request.OnServerEvent:Connect(function(player,action)
    if action~="Sync" then return end
    local now=os.clock(); if now-(lastSync[player] or 0)<1 then return end
    lastSync[player]=now; context.Sync(player)
end)
Players.PlayerRemoving:Connect(function(player) lastSync[player]=nil end)
workspace:SetAttribute("NeighborhoodReady",true)
print("[NEIGHBORHOOD] Foundation ready; session-only data.")
