local TweenService = game:GetService("TweenService")
local Config = require(game.ReplicatedStorage.Neighborhood.Shared.Config)
local Service = {ByPlayer = {}, ById = {}}
function Service:Init(context)
    self.Context = context
    for _, model in ipairs(workspace.Neighborhood.Houses:GetChildren()) do
        self.ById[model.Name] = {Model=model, Owner=nil, Open=false, Locked=false, Door=model.Door, ClosedCFrame=model.Door.CFrame}
    end
end
function Service:Assign(player)
    if self.ByPlayer[player.UserId] then return self.ByPlayer[player.UserId] end
    local ids = {}; for id in pairs(self.ById) do table.insert(ids,id) end; table.sort(ids)
    for _, id in ipairs(ids) do
        local house = self.ById[id]
        if not house.Owner then
            house.Owner = player.UserId
            house.Model:SetAttribute("OwnerUserId", player.UserId)
            house.Model:SetAttribute("ProtectedUntil", os.time()+Config.NewPlayerProtection)
            house.Model.Mailbox.Sign.SurfaceGui.TextLabel.Text = house.Model:GetAttribute("Address") .. "\nOccupied"
            self.ByPlayer[player.UserId] = house
            player:SetAttribute("HouseId", id)
            return house
        end
    end
    return nil
end
function Service:SetDoor(house, open)
    house.Open = open
    house.Model:SetAttribute("DoorOpen",open)
    house.Door.CanCollide = not open
    local target = house.ClosedCFrame
    if open then target = target * CFrame.new(-2.5,0,0)*CFrame.Angles(0,math.rad(-100),0)*CFrame.new(2.5,0,0) end
    TweenService:Create(house.Door,TweenInfo.new(Config.DoorTween),{CFrame=target}):Play()
end
function Service:DoorAction(player, target, action)
    local house = self.ById[target:GetAttribute("HouseId")]
    if not house then return false,"This home is unavailable." end
    if not house.Owner then return false,"This home is waiting for a neighbor." end
    if action == "Lock" then
        if house.Owner ~= player.UserId then return false,"Only the homeowner can change this lock." end
        house.Locked = not house.Locked
        house.CompromisedUntil=nil
        if house.Locked then self:SetDoor(house,false) end
        house.Model:SetAttribute("Locked",house.Locked)
        return true, house.Locked and "Front door locked." or "Front door unlocked."
    end
    if house.Locked and house.Owner ~= player.UserId and (house.CompromisedUntil or 0)<os.clock() then self.Context.Open(player,"Breach",house.Model.Name);return true end
    self:SetDoor(house,not house.Open)
    return true, house.Open and "Door opened." or "Door closed."
end
function Service:Release(player)
    local house = self.ByPlayer[player.UserId]
    if not house then return end
    self:SetDoor(house,false); house.Owner=nil; house.Locked=false
    house.CompromisedUntil=nil;house.Model:SetAttribute("ProtectedUntil",0)
    house.Model:SetAttribute("OwnerUserId",0); house.Model:SetAttribute("Locked",false)
    house.Model.Mailbox.Sign.SurfaceGui.TextLabel.Text = house.Model:GetAttribute("Address") .. "\nAvailable"
    self.ByPlayer[player.UserId]=nil
end
return Service
