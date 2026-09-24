return function(player)
 assert(game:GetService('RunService'):IsStudio())
 local root=script.Parent;local D=require(root.Services.PlayerDataService);assert(D.SessionOnly,'UI tests require isolated session profiles')
 local I=require(root.Services.InteractionService);local J=require(root.CityJobs);local profile=D:Get(player)
 local function go(target)
  player.Character:PivotTo(target.CFrame*CFrame.new(0,1,-3));task.wait(.4);I.Last[player.UserId]=nil
 end
 local resident=workspace.Neighborhood.Runtime.ResidentNeighbors:GetChildren()[1].Torso
 go(resident);local ok,why=I:Request(player,resident,'Resident');assert(ok,why);assert(profile.Statistics.Visit==1,'NPC greeting did not complete introduction')
 local xp=profile.XP;go(resident);assert(I:Request(player,resident,'Resident'));assert(profile.XP==xp,'NPC hello farms tutorial XP')
 local pizza=workspace.Neighborhood.MapleHeights.MarketAvenue.MaplePizza;local cash=profile.Currency
 go(pizza.OrderTicket);assert(I:Request(player,pizza.OrderTicket,'CityWork'));assert(player:GetAttribute('CityWorkKind')=='Pizza'and player:GetAttribute('CityWorkStep')==2,'Missing active job guidance')
 assert(player:GetAttribute('CityWorkPosition')==pizza.PrepBoard.Position,'Wrong next station')
 assert(player:GetAttribute('CityWorkReadyAt')>workspace:GetServerTimeNow(),'Missing preparation timer')
 go(pizza.PrepBoard);assert(not I:Request(player,pizza.PrepBoard,'CityWork'));task.wait(4);I.Last[player.UserId]=nil;assert(I:Request(player,pizza.PrepBoard,'CityWork'));assert(player:GetAttribute('CityWorkStep')==3,'Step did not advance')
 task.wait(4);go(pizza.ServeBox);assert(I:Request(player,pizza.ServeBox,'CityWork'));assert(not player:GetAttribute('CityWorkKind')and not player:GetAttribute('CityWorkPosition'),'Completed shift guidance stayed visible');assert(profile.Currency==cash+45,'Reward changed')
 J.Last[player.UserId]=nil;go(pizza.OrderTicket);assert(I:Request(player,pizza.OrderTicket,'CityWork'));J.Active[player.UserId].Expires=0;task.wait(.5);assert(not player:GetAttribute('CityWorkKind'),'Expired shift guidance stayed visible')
 D.Context.Sync(player)
 return {Passed=true,Verified={'NPC greeting completes first-step goal without repeat XP','Real station interactions publish correct job, step, position and server timer','Early action rejected; steps advance; reward remains $45','Completion and expiry clear tracked job'}}
end
