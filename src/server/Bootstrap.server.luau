local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local root=RS:WaitForChild("Neighborhood")
local remotes=root:WaitForChild("Remotes")
local Data=require(script.Parent.Services.PlayerDataService)
local Houses=require(script.Parent.Services.HouseService)
local Interactions=require(script.Parent.Services.InteractionService)
local Items=require(script.Parent.Services.ItemService)
local Economy=require(script.Parent.Services.EconomyService)
local Evidence=require(script.Parent.Services.EvidenceService)
local Robbery=require(script.Parent.Services.RobberyService)
local Delivery=require(script.Parent.Services.DeliveryService)
local context={Data=Data,Houses=Houses,Interactions=Interactions,Items=Items,Economy=Economy,Evidence=Evidence,Robbery=Robbery}
context.Notify=function(player,message,ok)
    if player.Parent==Players and message then remotes.Notification:FireClient(player,{Text=message,Success=ok}) end
end
context.Snapshot=function(player)
    local profile=Data:Get(player); local house=Houses.ByPlayer[player.UserId]
    return {Currency=profile and profile.Currency or 0,Address=house and house.Model:GetAttribute("Address") or "Finding your home",HouseId=house and house.Model.Name,SessionOnly=true,Inventory=Items:Owned(player),Incidents=profile and profile.Incidents or {},Carrying=player:GetAttribute("Carrying")}
end
context.Sync=function(player) if player.Parent==Players then remotes.State:FireClient(player,context.Snapshot(player)) end end
Houses:Init(context); Interactions:Init(context)
Items:Init(context); Economy:Init(context)
Evidence:Init(context);Robbery:Init(context)
Delivery:Init(context)
context.Open=function(player,view,detail) remotes.View:FireClient(player,view,detail) end
Interactions:Register("Shop",function(player) context.Open(player,"Shop");return true end)
Interactions:Register("Pawn",function(player) context.Open(player,"Pawn");return true end)
Interactions:Register("Place",function(player,target)
 if player:GetAttribute("HouseId")~=target:GetAttribute("HouseId") then return false,"Only the homeowner can decorate here." end
 context.Open(player,"Place",target:GetAttribute("Slot"));return true
end)
Interactions:Register("Item",function(player,target)
 local item=Items.Items[target:GetAttribute("ItemId")]
 if not item then return false,"This item has moved." end
 context.Open(player,"Item",{Id=item.Id,DefinitionId=item.DefinitionId,Owned=item.OwnerUserId==player.UserId,State=item.State});return true
end)
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
    Items:Create(player,"BasicChair");Items:Create(player,"Lamp")
    player.CharacterAdded:Connect(function(c) characterAdded(player,c) end)
    if player.Character then task.spawn(characterAdded,player,player.Character) end
    context.Sync(player)
end
Players.PlayerAdded:Connect(added)
Players.PlayerRemoving:Connect(function(player) Robbery:Release(player);Items:Release(player);Houses:Release(player); Data:Release(player) end)
for _,player in ipairs(Players:GetPlayers()) do task.spawn(added,player) end
local lastSync={}
remotes.Request.OnServerEvent:Connect(function(player,action,id,argument)
    if type(action)~="string" or #action>24 then return end
    local now=os.clock(); if now-(lastSync[player] or 0)<1 then return end
    lastSync[player]=now
    if action=="Sync" then context.Sync(player);return end
    if type(id)~="string" or #id>80 then return end
    local ok,message=false,"Unavailable action."
    if action=="Buy" then ok,message=Economy:Buy(player,id)
    elseif action=="Sell" then ok,message=Economy:Sell(player,id)
    elseif action=="Place" then ok,message=Items:Place(player,id,argument)
    elseif action=="Steal" then ok,message=Robbery:Begin(player,id)
    elseif action=="Fence" then ok,message=Robbery:Fence(player)
    elseif action=="Recover" then
        local item=Items.Items[id];local model=Items.Models[id]
        if item and model then
            local valid,reason=Interactions:Validate(player,model.PrimaryPart)
            if valid then ok,message=Robbery:Recover(player,item) else message=reason end
        end
    elseif action=="Case" then
        for _,incident in ipairs(Data:Get(player).Incidents) do if incident.Id==id then incident.Status=incident.Status=="Missing" and "Investigating" or incident.Status;ok=true;message="Case marked for investigation.";break end end
    elseif action=="Store" then
        local item=Items.Items[id];local model=Items.Models[id]
        if item and model then
            local valid,reason=Interactions:Validate(player,model.PrimaryPart)
            if valid then ok,message=Items:Store(player,item) else message=reason end
        end
    end
    context.Notify(player,message,ok);context.Sync(player)
end)
Players.PlayerRemoving:Connect(function(player) lastSync[player]=nil end)
workspace:SetAttribute("NeighborhoodReady",true)
print("[NEIGHBORHOOD] Foundation ready; session-only data.")
