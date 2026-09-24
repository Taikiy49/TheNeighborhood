local Players=game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Config = require(game.ReplicatedStorage.Neighborhood.Shared.Config)
local Service = {ByPlayer = {}, ById = {}}
function Service:Init(context)
    self.Context = context
    for _, model in ipairs(workspace.Neighborhood.Houses:GetChildren()) do
        local spawn=Instance.new("SpawnLocation");spawn.Name="HomeSpawn";spawn.Size=Vector3.new(4,.2,4);spawn.CFrame=model.Foundation.CFrame*CFrame.new(0,.65,-10);spawn.Transparency=1;spawn.CanCollide=false;spawn.CanTouch=false;spawn.CanQuery=false;spawn.Anchored=true;spawn.Neutral=true;spawn.Duration=0;spawn.Parent=model
        local tag=Instance.new("BillboardGui");tag.Name="HomeOwner";tag.Size=UDim2.fromOffset(190,42);tag.StudsOffset=Vector3.new(0,3,0);tag.MaxDistance=70;tag.Parent=model.AddressPlaque
        local label=Instance.new("TextLabel");label.Size=UDim2.fromScale(1,1);label.BackgroundTransparency=1;label.TextColor3=Color3.fromRGB(255,246,221);label.TextStrokeTransparency=.25;label.TextSize=14;label.Font=Enum.Font.GothamBold;label.Parent=tag
        local function refresh()
         local owner=model:GetAttribute("OwnerName");local npc=model:GetAttribute("NPCResident")
         label.Text=(owner and (owner.."'s House")or npc and (npc.."'s House · NPC")or "A neighbor's home").."\n"..model:GetAttribute("Address")
        end
        model:GetAttributeChangedSignal("OwnerName"):Connect(refresh);model:GetAttributeChangedSignal("NPCResident"):Connect(refresh);refresh()
        self.ById[model.Name] = {Model=model, Owner=nil, Open=false, Locked=false, Door=model.Door, ClosedCFrame=model.Door.CFrame}
    end
end
function Service:Assign(player)
    if self.ByPlayer[player.UserId] then return self.ByPlayer[player.UserId] end
    local ids = {}; for id in pairs(self.ById) do table.insert(ids,id) end; table.sort(ids)
    local slot=player:GetAttribute("NeighborhoodSlot")
    if slot then ids={string.format("House%02d",slot)}end
    for _, id in ipairs(ids) do
        local house = self.ById[id]
        if house and not house.Owner then
            house.Owner = player.UserId
            house.Model:SetAttribute("OwnerUserId", player.UserId)
            house.Model:SetAttribute("ProtectedUntil", os.time()+Config.NewPlayerProtection)
            house.Model.Mailbox.Sign.SurfaceGui.TextLabel.Text = player.DisplayName .. "'s House\n" .. house.Model:GetAttribute("Address")
            house.Model:SetAttribute("OwnerName",player.DisplayName)
            self.ByPlayer[player.UserId] = house
            player.RespawnLocation=house.Model.HomeSpawn
            player:SetAttribute("HouseId", id)
            return house
        end
    end
    return nil
end
function Service:SetDoor(house, open)
    house.Open = open
    house.Model:SetAttribute("DoorOpen",open)
    if self.Context.Building then self.Context.Building:SetDoor(house,open)end
    house.Door.CanCollide = not open
    house.Door.CanQuery = not open
    local target = house.ClosedCFrame
    if open then target = target * CFrame.new(-house.Door.Size.X/2,0,0)*CFrame.Angles(0,math.rad(-100),0)*CFrame.new(house.Door.Size.X/2,0,0) end
    TweenService:Create(house.Door,TweenInfo.new(Config.DoorTween),{CFrame=target}):Play()
end
function Service:DoorAction(player, target, action)
    local house = self.ById[target:GetAttribute("HouseId")]
    if not house then return false,"This home is unavailable." end
    if not house.Owner then
        if action=="Lock"then return false,"This is an NPC neighbor's home."end
        self:SetDoor(house,not house.Open);return true,"Welcome to the neighbor's cottage."
    end
    local permission=house.Permissions and house.Permissions[tostring(player.UserId)]
    if action == "Lock" then
        if house.Owner ~= player.UserId and permission~="Roommate" then return false,"Only the homeowner or a roommate can change this lock." end
        house.Locked = not house.Locked
        house.CompromisedUntil=nil
        if house.Locked then self:SetDoor(house,false);local owner=Players:GetPlayerByUserId(house.Owner);local profile=owner and self.Context.Data:Get(owner);if profile and profile.Life then profile.Life.TourOpen=false;if self.Context.Life then self.Context.Life:Home(owner)end end end
        house.Model:SetAttribute("Locked",house.Locked)
        if house.Locked then self.Context.Record(player,"Lock")end
        return true, house.Locked and "Front door locked." or "Front door unlocked."
    end
    if house.Locked and house.Owner ~= player.UserId and permission~="Friend" and permission~="Roommate" and (house.CompromisedUntil or 0)<os.clock() then self.Context.Open(player,"Breach",house.Model.Name);return true end
    self:SetDoor(house,not house.Open)
    if house.Owner==player.UserId and house.Open then self.Context.Record(player,"EnterHouse")end
    return true, house.Open and "Door opened." or "Door closed."
end
function Service:ContainsInterior(house,position)
 local v=house.Model.Foundation.CFrame:PointToObjectSpace(position);local size=house.Model.Foundation.Size
 local tier=house.Model:GetAttribute("ResidenceTier")or 1
 if tier>1 then local floors=require(game.ReplicatedStorage.Neighborhood.Shared.ResidenceDefinitions).Tiers[tier].Floors;if math.abs(v.X)<19 and v.Z> -17 and v.Z<15 and v.Y>=12 and v.Y<floors*12.4 then return true end end
 return math.abs(v.X)<=size.X/2 and math.abs(v.Z)<=size.Z/2 and v.Y>=-2 and v.Y<=house.Model.Ceiling.Position.Y-house.Model.Foundation.Position.Y+1
end
function Service:Release(player)
    local house = self.ByPlayer[player.UserId]
    if not house then return end
    self:SetDoor(house,false); house.Owner=nil; house.Locked=false
    house.CompromisedUntil=nil;house.Model:SetAttribute("ProtectedUntil",0)
    house.Permissions=nil
    house.Model:SetAttribute("OwnerName",nil);house.Model:SetAttribute("OwnerUserId",0); house.Model:SetAttribute("Locked",false)
    house.Model.Mailbox.Sign.SurfaceGui.TextLabel.Text = house.Model:GetAttribute("Address") .. "\nAvailable"
    self.ByPlayer[player.UserId]=nil
end
return Service
