local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local root=RS:WaitForChild("Neighborhood")
for _,model in ipairs(workspace.Neighborhood:GetDescendants())do if model:IsA("Model") and model:GetAttribute("ExportPrimaryPart") then model.PrimaryPart=model:FindFirstChild(model:GetAttribute("ExportPrimaryPart"))end end
local remotes=root:WaitForChild("Remotes")
local Data=require(script.Parent.Services.PlayerDataService)
local Houses=require(script.Parent.Services.HouseService)
local Interactions=require(script.Parent.Services.InteractionService)
local Items=require(script.Parent.Services.ItemService)
local Economy=require(script.Parent.Services.EconomyService)
local Evidence=require(script.Parent.Services.EvidenceService)
local Robbery=require(script.Parent.Services.RobberyService)
local Delivery=require(script.Parent.Services.DeliveryService)
local Progression=require(script.Parent.Services.ProgressionService)
local Investigation=require(script.Parent.Services.InvestigationService)
local Community=require(script.Parent.Services.CommunityService)
local Customization=require(script.Parent.Services.CustomizationService)
local Pranks=require(script.Parent.Services.PrankService)
local Vehicles=require(script.Parent.Services.VehicleService)
local Pets=require(script.Parent.Services.PetService)
local Events=require(script.Parent.Services.EventService)
local Observation=require(script.Parent.Services.ObservationService)
local Discovery=require(script.Parent.Services.DiscoveryService)
local Weather=require(script.Parent.Services.WeatherService)
local Friends=require(script.Parent.Services.FriendsService)
local Boutique=require(script.Parent.Services.BoutiqueService)
local Adventures=require(script.Parent.Services.AdventureService)
local context={Data=Data,Houses=Houses,Interactions=Interactions,Items=Items,Economy=Economy,Evidence=Evidence,Robbery=Robbery}
context.Notify=function(player,message,ok)
    if player.Parent==Players and message then remotes.Notification:FireClient(player,{Text=message,Success=ok}) end
end
context.Snapshot=function(player)
    local profile=Data:Get(player); local house=Houses.ByPlayer[player.UserId]
    local neighbors={};for _,p in ipairs(Players:GetPlayers())do if p~=player then
        local h=Houses.ByPlayer[p.UserId];local neighborProfile=Data:Get(p);local stats=neighborProfile and neighborProfile.Statistics or {}
        table.insert(neighbors,{UserId=p.UserId,Name=p.DisplayName,HouseId=h and h.Model.Name,Address=h and h.Model:GetAttribute("Address") or "Moving in",HouseValue=Observation:HouseValue(p),KnownFor=(stats.Delivery or 0)>=5 and "Helpful neighbor" or (stats.Customize or 0)>0 and "Home decorator" or "Settling in"})
    end end
    local patrol={};for id,h in pairs(Houses.ById)do table.insert(patrol,{Id=id,Address=h.Model:GetAttribute("Address")})end;table.sort(patrol,function(a,b)return a.Id<b.Id end)
    return {Adventures=Adventures:View(player),Boutique=Boutique:View(player),Friends=Friends:View(player),Currency=profile and profile.Currency or 0,Address=house and house.Model:GetAttribute("Address") or "Finding your home",HouseId=house and house.Model.Name,SessionOnly=Data.SessionOnly,Inventory=Items:Owned(player),Collection=profile and profile.Collection or {},Discoveries=Discovery:View(player),Weather=Weather:View(),Incidents=profile and profile.Incidents or {},Recap=profile and profile._Recap,Carrying=player:GetAttribute("Carrying"),Progress=Progression:View(player),Settings=profile and profile.Settings,Neighbors=neighbors,House=profile and profile.House,Feed=Community.Feed,Vehicles=profile and profile.Vehicles,Pets=profile and profile.Pets,CommunityEvent=Events:View(),Patrol=patrol}
end
context.Sync=function(player) if player.Parent==Players then remotes.State:FireClient(player,context.Snapshot(player)) end end
context.Customization=Customization;context.Boutique=Boutique
Boutique:Init(context)
Progression:Init(context);Investigation:Init(context);Customization:Init(context)
context.Record=function(player,event)Progression:Record(player,event);Community:Record(event);if Adventures.Context then Adventures:Record(player,event)end end
Houses:Init(context); Interactions:Init(context)
Items:Init(context); Economy:Init(context)
Pranks:Init(context)
Vehicles:Init(context)
Pets:Init(context)
Evidence:Init(context);Robbery:Init(context)
Delivery:Init(context)
Data:Init(context)
Friends:Init(context)
context.Open=function(player,view,detail) remotes.View:FireClient(player,view,detail) end
require(script.Parent.GuideCharacters).Init(context)
Events:Init(context)
Observation:Init(context)
Discovery:Init(context)
Weather:Init(context)
Adventures:Init(context)
Interactions:Register("Shop",function(player) context.Open(player,"Shop");return true end)
Interactions:Register("Pawn",function(player) context.Open(player,"Pawn");return true end)
Interactions:Register("Place",function(player,target)
 if player:GetAttribute("HouseId")~=target:GetAttribute("HouseId") then return false,"Only the homeowner can decorate here." end
 context.Open(player,"Place",target:GetAttribute("Slot"));return true
end)
Interactions:Register("Item",function(player,target)
 local item=Items.Items[target:GetAttribute("ItemId")]
 if not item then return false,"This item has moved." end
 context.Open(player,"Item",{Id=item.Id,DefinitionId=item.DefinitionId,Owned=item.OwnerUserId==player.UserId,HeldByYou=item.HolderUserId==player.UserId,State=item.State});return true
end)
Interactions:Register("Door",function(...) return Houses:DoorAction(...) end)
Interactions:Register("Lock",function(...) return Houses:DoorAction(...) end)
Interactions:Register("Doorbell",function(player,target)
    local house=Houses.ById[target:GetAttribute("HouseId")]
    if house and house.Owner then
        local owner=Players:GetPlayerByUserId(house.Owner)
        if owner then context.Notify(owner,"Ding dong! A neighbor is at your door.",true) end
        if owner~=player then context.Record(player,"Visit")end
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
    if not Friends:AuthorizeArrival(player)then return end
    local profile=Data:Load(player);if not profile then return end
    if player.Parent~=Players then Data:Release(player);return end
    local house=Houses:Assign(player)
    if not house then player:Kick("This neighborhood is full. Please join another server."); return end
    Items:Restore(player,profile,house)
    Customization:Apply(player)
    if profile.Vehicles.Compact then Vehicles:Spawn(player)end
    if profile.Pets.Dog then Pets:Spawn(player)end
    player.CharacterAdded:Connect(function(c) characterAdded(player,c) end)
    if player.Character then task.spawn(characterAdded,player,player.Character) end
    context.Sync(player)
    task.spawn(function()Friends:Refresh(player,true);context.Sync(player)end)
    task.spawn(function()Boutique:Refresh(player);context.Sync(player)end)
end
Players.PlayerAdded:Connect(added)
Players.PlayerRemoving:Connect(function(player) Data:BeginClose(player);Robbery:Release(player);Data:Release(player);Items:Release(player);Houses:Release(player) end)
Players.PlayerRemoving:Connect(function(player)Friends:Removed(player)end)
for _,player in ipairs(Players:GetPlayers()) do task.spawn(added,player) end
local lastSync={}
remotes.Request.OnServerEvent:Connect(function(player,action,id,argument,requestId)
    local responseId=type(requestId)=="number" and requestId==requestId and requestId%1==0 and requestId>0 and requestId<1000000000 and requestId or nil
    local function respond(message,success)if player.Parent==Players then remotes.Notification:FireClient(player,{Text=message or "Action completed.",Success=success,RequestId=responseId})end end
    if type(action)~="string" or #action>24 then return end
    local now=os.clock(); if now-(lastSync[player] or 0)<0.3 then respond("Please wait a moment before another action.",false);return end
    lastSync[player]=now
    if action=="Sync" then context.Sync(player);return end
    if not Data:CanAct(player) then respond("Your profile is loading or closing. Please wait.",false);return end
    if type(id)~="string" or #id>80 then return end
    local ok,message=false,"Unavailable action."
    if action=="Adventure"then ok,message=Adventures:Action(player,id,argument)
    elseif action=="Boutique"then ok,message=Boutique:Action(player,id,argument)
    elseif action=="Friends"then ok,message=Friends:Action(player,id,argument)
    elseif action=="Buy" then ok,message=Economy:Buy(player,id)
    elseif action=="Sell" then ok,message=Economy:Sell(player,id)
    elseif action=="Place" then ok,message=Items:Place(player,id,argument)
    elseif action=="Steal" then ok,message=Robbery:Begin(player,id)
    elseif action=="Fence" then ok,message=Robbery:Fence(player)
    elseif action=="Reclaim" then ok,message=Robbery:Reclaim(player,id)
    elseif action=="Breach" then ok,message=Robbery:Breach(player,id)
    elseif action=="Drop" then ok,message=Robbery:Drop(player)
    elseif action=="Resume" then ok,message=Robbery:Resume(player,id)
    elseif action=="Accuse" then ok,message=Investigation:Accuse(player,id,argument)
    elseif action=="Customize" then ok,message=Customization:Change(player,id,argument)
    elseif action=="Permission" then ok,message=Customization:Permission(player,id,argument)
    elseif action=="Prank" then ok,message=Pranks:Place(player,id)
    elseif action=="Vehicle" then ok,message=Vehicles:Action(player,id,argument)
    elseif action=="Pet" then ok,message=Pets:Action(player,id)
    elseif action=="Event" then ok,message=Events:Action(player,id,argument)
    elseif action=="Survey" then ok,message=Observation:Survey(player,id)
    elseif action=="ClaimDiscovery" then ok,message=Discovery:Claim(player)
    elseif action=="CancelDelivery" then ok=Delivery:Cancel(player);message=ok and "Parcel returned to the depot." or "You have no active parcel."
    elseif action=="Setting" then
        if (id=="Sound" or id=="ReducedMotion" or id=="Pranks") and type(argument)=="boolean"then Data:Get(player).Settings[id]=argument;ok=true;message="Preference saved."end
    elseif action=="Recover" then
        local item=Items.Items[id];local model=Items.Models[id]
        if item and model then
            local valid,reason=Interactions:Validate(player,model.PrimaryPart)
            if valid then ok,message=Robbery:Recover(player,item) else message=reason end
        end
    elseif action=="Case" then
        for _,incident in ipairs(Data:Get(player).Incidents) do if incident.Id==id then if incident.Status=="Missing" then Evidence:Transition(incident,"Investigating","The homeowner opened an investigation.") end;ok=true;message="Case reviewed.";break end end
    elseif action=="Store" then
        local item=Items.Items[id];local model=Items.Models[id]
        if item and model then
            local valid,reason=Interactions:Validate(player,model.PrimaryPart)
            if valid then ok,message=Items:Store(player,item) else message=reason end
        end
    end
    respond(message,ok);context.Sync(player)
end)
Players.PlayerRemoving:Connect(function(player) lastSync[player]=nil end)
workspace:SetAttribute("NeighborhoodReady",true)
print("[NEIGHBORHOOD] Ready; "..(Data.SessionOnly and "session-only playtest" or "persistent profiles"))
