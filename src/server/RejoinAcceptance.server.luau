if not game:GetService("RunService"):IsStudio()then return end
local phase=workspace:GetAttribute("PersistenceCycle")
if phase~=1 and phase~=2 then return end
local ok,result=pcall(function()
 local Players=game:GetService("Players")
 local Data=require(script.Parent.Services.PlayerDataService);local Items=require(script.Parent.Services.ItemService);local Houses=require(script.Parent.Services.HouseService)
 local deadline=os.clock()+45;local player
 repeat task.wait(0.2);player=Players:GetPlayers()[1]until player and Data:Get(player) and Data:Get(player)._Restored and player.Character and player.Character:FindFirstChild("HumanoidRootPart") or os.clock()>deadline
 assert(player and Data:Get(player),"Live player profile did not load");assert(not Data.SessionOnly,"Expected real persistent mode")
 local profile=Data:Get(player);local house=Houses.ByPlayer[player.UserId]
 if phase==1 then
  local item;for _,candidate in pairs(Items.Items)do if candidate.OwnerUserId==player.UserId and candidate.DefinitionId=="Lamp"then item=candidate;break end end
  assert(item,"Starter lamp missing")
  if item.State=="Displayed"then assert(Items:Store(player,item))end
  local slotNumber=1
  for slot=1,6 do local occupied=false;for _,candidate in pairs(Items.Items)do if candidate.HouseId==house.Model.Name and candidate.Slot==slot and candidate.State=="Displayed"then occupied=true end end;if not occupied then slotNumber=slot;break end end
  local slot=house.Model.DisplaySlots:FindFirstChild("Slot"..slotNumber);player.Character:PivotTo(slot.CFrame*CFrame.new(0,3,0));assert(Items:Place(player,item.Id,slotNumber))
  if not house.Locked then assert(Houses:DoorAction(player,house.Model.Lock,"Lock"))end
  profile.House.Boutique="Coastal:SeaGlass"
  assert(Data:Save(player,false),"Explicit live save failed")
  -- This change is intentionally after the explicit save: only shutdown saving can retain it.
  profile.Statistics.ShutdownProbe=(profile.Statistics.ShutdownProbe or 0)+1
  profile.Adventures={Completed={Teaspoon=true},Runs={Teaspoon=2},BestMs={Teaspoon=45000},Rewards={TrailCompass=true},Contributions=12,Active={Id="Moon",Next=2}}
  return {Passed=true,Phase=1,UserId=player.UserId,ItemId=item.Id,Slot=slotNumber,Currency=profile.Currency,ShutdownProbe=profile.Statistics.ShutdownProbe,Locked=house.Locked}
 end
 local expected=game:GetService("HttpService"):JSONDecode(assert(workspace:GetAttribute("PersistenceExpected"),"Missing expected profile"))
 assert(player.UserId==expected.UserId,"Rejoin account changed")
 assert(profile.Currency==expected.Currency,"Currency did not survive rejoin")
 assert(profile.House.Boutique=="Coastal:SeaGlass","Boutique preference did not survive actual server restart")
 local item=Items.Items[expected.ItemId];assert(item and item.State=="Displayed" and item.Slot==expected.Slot and Items.Models[item.Id],"Original displayed item did not restore")
 assert(house.Locked==expected.Locked,"Lock state did not restore")
 assert(profile.Statistics.ShutdownProbe==expected.ShutdownProbe,"Unsaved change was not flushed during shutdown")
 assert(profile.Adventures.Completed.Teaspoon and profile.Adventures.BestMs.Teaspoon==45000 and profile.Adventures.Rewards.TrailCompass and profile.Adventures.Contributions==12 and profile.Adventures.Active.Id=="Moon" and profile.Adventures.Active.Next==2,"Adventure progress did not survive shutdown/rejoin")
 assert(profile._Recap and profile._Recap.LastSeen>0,"Honest recap missing")
 return {Passed=true,Phase=2,Verified={"Normal Studio player rejoined same persistent profile","Currency retained","Original item GUID and display placement restored","House lock restored","Post-save change retained by shutdown save","Recap reflects real previous session","Boutique selection retained across actual server restart","Adventure album and unfinished chapter retained by shutdown save"}}
end)
workspace:SetAttribute("PersistenceCycleResult",game:GetService("HttpService"):JSONEncode(ok and result or {Passed=false,Error=tostring(result)}))
