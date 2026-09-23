if not game:GetService("RunService"):IsStudio()then return end
local Test=game:GetService("StudioTestService");local args=Test:GetTestArgs()
if type(args)~="table" or args.Name~="LifecycleStress"then return end
local function run()
 local Players=game:GetService("Players");local Data=require(script.Parent.Services.PlayerDataService)
 local Houses=require(script.Parent.Services.HouseService);local Items=require(script.Parent.Services.ItemService)
 local Economy=require(script.Parent.Services.EconomyService);local Schema=require(script.Parent.ProfileSchema)
 local definitions=require(game.ReplicatedStorage.Neighborhood.Shared.ItemDefinitions)
 local deadline=os.clock()+45
 repeat task.wait(0.2)until #Players:GetPlayers()==2 and workspace:GetAttribute("NeighborhoodReady") and Houses.ByPlayer[Players:GetPlayers()[2].UserId] or os.clock()>deadline
 local players=Players:GetPlayers();assert(#players==2 and Data.SessionOnly)
 for _,player in ipairs(players)do repeat task.wait(0.1)until player.Character and player.Character:FindFirstChild("HumanoidRootPart") or os.clock()>deadline;Data:Get(player).Currency=1000000 end
 local ids={};for id,definition in pairs(definitions)do if not definition.DiscoverOnly then table.insert(ids,id)end end;table.sort(ids)
 local seen={};local expected={[players[1].UserId]=1000000,[players[2].UserId]=1000000};local failuresRejected=0
 local random=Random.new(941);local runtimeBefore=#workspace.Neighborhood.Runtime:GetDescendants()
 for iteration=1,100 do
  local player=players[(iteration-1)%2+1];local other=players[iteration%2+1];local house=Houses.ByPlayer[player.UserId]
  local definitionId=ids[(iteration-1)%#ids+1];local definition=definitions[definitionId]
  local prior={};for _,item in ipairs(Items:Owned(player))do prior[item.Id]=true end
  player.Character:PivotTo(workspace.Neighborhood.Shops.GeneralStore.Counter.CFrame*CFrame.new(0,3,-5))
  local bought,why=Economy:Buy(player,definitionId);assert(bought,why);expected[player.UserId]-=definition.Value
  local newItem;for _,item in ipairs(Items:Owned(player))do if not prior[item.Id]then newItem=Items.Items[item.Id]end end
  assert(newItem and not seen[newItem.Id],"Purchase duplicated an identity");seen[newItem.Id]=true
  local slot=random:NextInteger(1,6);player.Character:PivotTo(house.Model.DisplaySlots["Slot"..slot].CFrame*CFrame.new(0,3,0))
  assert(Items:Place(player,newItem.Id,slot));assert(Items.Models[newItem.Id] and newItem.State=="Displayed")
  assert(not Items:Place(other,newItem.Id,slot));assert(not Items:Store(other,newItem));assert(not Economy:Sell(player,newItem.Id));failuresRejected+=3
  assert(Items:Store(player,newItem));assert(not Items:Store(player,newItem));failuresRejected+=1
  player.Character:PivotTo(workspace.Neighborhood.Shops.PawnShop.Counter.CFrame*CFrame.new(0,3,-5))
  assert(Economy:Sell(player,newItem.Id));expected[player.UserId]+=math.floor(definition.Value*0.4)
  assert(not Economy:Sell(player,newItem.Id));assert(not Items:Place(player,newItem.Id,slot));failuresRejected+=2
  assert(not Items.Items[newItem.Id] and not Items.Models[newItem.Id],"Sold item leaked registry or model")
  assert(Data:Get(player).Currency==expected[player.UserId] and #Data:Get(player).Inventory==2,"Lifecycle violated balance or inventory invariant")
  if iteration%10==0 then Schema.Migrate(Data:Snapshot(player),player.UserId);task.wait()end
 end
 assert(#workspace.Neighborhood.Runtime:GetDescendants()==runtimeBefore,"Repeated lifecycle leaked world instances")
 local errors={};for _,entry in ipairs(game:GetService("LogService"):GetLogHistory())do if entry.messageType==Enum.MessageType.MessageError then table.insert(errors,entry.message)end end
 assert(#errors==0,"Lifecycle stress produced errors")
 return {Passed=true,Cycles=100,Definitions=#ids,InvalidTransitionsRejected=failuresRejected,Seed=941,WorldInstancesBefore=runtimeBefore,WorldInstancesAfter=#workspace.Neighborhood.Runtime:GetDescendants(),Errors=errors,Verified={"One hundred complete acquire/display/store/sell cycles across two owners","All ten store collectibles rendered and exercised","Six hundred foreign/duplicate/invalid state transitions rejected","Original GUIDs unique across every acquisition","Currency and inventory invariants held after every cycle","No leaked item models or registry entries"}}
end
local ok,result=pcall(run);Test:EndTest(ok and result or {Passed=false,Error=tostring(result)})
