local root=game.ServerScriptService.Neighborhood
local S=require(root.ProfileSchema)
local G=require(root.OwnerHome)
local D=require(root.Services.PlayerDataService)
assert(D.SessionOnly,'Use an isolated Studio profile')
local p=game.Players:GetPlayers()[1]
assert(p.UserId==G.UserId,'Run the integration check as the owner')
local h=require(root.Services.HouseService).ByPlayer[p.UserId].Model
local fresh=S.Default()
assert(not G.Apply(123,fresh,h))
assert(#fresh.Items==0 and next(fresh.Vehicles)==nil)
assert(G.Apply(G.UserId,fresh,h) and #fresh.Items==6)
assert(not G.Apply(G.UserId,fresh,h) and #fresh.Items==6)
local migrated=S.Migrate(S.Copy(fresh),G.UserId)
assert(migrated.Statistics.OwnerHomeV1==1 and #migrated.Items==6)
local existing=S.Default()
existing.Vehicles={Owned={Compact=2400},Selected='Compact',Plate='CUSTOM'}
existing.Yard.Slots['1']={Id='Flowers',Rotation=2}
local cash=existing.Currency
G.Apply(G.UserId,existing,h)
assert(existing.Vehicles.Selected=='Compact' and existing.Vehicles.Plate=='CUSTOM')
assert(existing.Yard.Slots['1'].Rotation==2 and existing.Currency==cash)
S.Migrate(S.Copy(existing),G.UserId)
local snapshot=D:Snapshot(p)
assert(snapshot.Statistics.OwnerHomeV1==1 and #snapshot.Items>=6)
S.Migrate(S.Copy(snapshot),p.UserId)
local car=require(root.Services.VehicleService).Cars[p.UserId]
assert(car and car.Speed==36 and car.Seat:GetAttribute('VehicleOwner')==p.UserId)
assert(#h.PersonalYard.Decor:GetChildren()==6)
local boards=0
for _,v in ipairs(workspace.Neighborhood:GetDescendants())do
 if v.Name=='YardBoard'then
  assert(v.Transparency==1 and not v.CanCollide and v:FindFirstChildOfClass('ProximityPrompt'))
  boards+=1
 end
 assert(v.Name~='GardenSign')
end
assert(boards==12)
print('OWNER HOME CHECKS PASS')
