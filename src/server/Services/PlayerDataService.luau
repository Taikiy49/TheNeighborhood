-- Session adapter only. Persistent backend is a separate milestone; never overwrite failed loads with defaults.
local Config = require(game.ReplicatedStorage.Neighborhood.Shared.Config)
local Service = {Profiles = {}}
function Service:Load(player)
    if self.Profiles[player.UserId] then return self.Profiles[player.UserId] end
    local profile = {Version=Config.SchemaVersion, Currency=Config.StartingCurrency, Inventory={}, Incidents={}, TutorialState="EnterHouse", JoinedAt=os.time()}
    self.Profiles[player.UserId] = profile
    return profile
end
function Service:Get(player) return self.Profiles[player.UserId] end
function Service:Release(player) self.Profiles[player.UserId] = nil end
return Service
