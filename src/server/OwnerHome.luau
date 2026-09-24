-- Explicit personal grant requested by taikiyama49. No client-accessible grant API.
local M={UserId=2868186764,Receipt='OwnerHomeV1'}
function M.Apply(userId,profile,house)
 if userId~=M.UserId or profile.Statistics[M.Receipt]==1 then return false end
 local Catalog=require(game.ReplicatedStorage.Neighborhood.Shared.VehicleCatalog)
 local vehicles=Catalog.Normalize(profile.Vehicles)
 for _,id in ipairs({'Roadster','Bicycle'})do vehicles.Owned[id]=vehicles.Owned[id]or Catalog.Items[id].Price end
 if vehicles.Selected==''then vehicles.Selected='Roadster'end
 vehicles.Color=vehicles.Color or 'Blue';vehicles.Plate=vehicles.Plate or 'TAIKI'
 profile.Pets.Dog=true;profile.Pets.Mode=profile.Pets.Mode or 'Stay'
 local occupied={};local owned={}
 for _,item in ipairs(profile.Items)do owned[item.DefinitionId]=true;if item.Slot then occupied[item.Slot]=true end end
 local desired={'Television','Lamp','BasicChair','Microwave','FancyVase','SuspiciousPainting'}
 local cap=require(game.ReplicatedStorage.Neighborhood.Shared.Config).MaxInventory
 for _,id in ipairs(desired)do
  local item
  for _,v in ipairs(profile.Items)do if v.DefinitionId==id and v.State=='Stored'then item=v;break end end
  if not owned[id]and #profile.Items<cap then
   item={Id=game:GetService('HttpService'):GenerateGUID(false),DefinitionId=id,OwnerUserId=userId,OriginalOwnerUserId=userId,State='Stored',Provenance={{Kind='Acquired',Time=os.time()}}}
   table.insert(profile.Items,item);table.insert(profile.Inventory,item.Id);profile.Collection[id]=profile.Collection[id]or os.time()
  end
  if item then for i=1,14 do if not occupied[i]and house.DisplaySlots:FindFirstChild('Slot'..i)then item.Slot=i;item.State='Displayed';item.PlacedBefore=true;occupied[i]=true;break end end end
 end
 for i,id in ipairs({'Flowers','Bench','Picnic','Lantern','Trampoline','Pergola'})do
  profile.Yard.Owned[id]=true
  local slot=tostring(i);if not profile.Yard.Slots[slot]then profile.Yard.Slots[slot]={Id=id,Rotation=0}end
 end
 profile.FirstVisit=false;profile.Statistics[M.Receipt]=1
 return true
end
return M
