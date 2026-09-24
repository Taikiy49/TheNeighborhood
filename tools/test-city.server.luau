assert(game:GetService('RunService'):IsStudio())
local base=game.ServerScriptService.Neighborhood
local J=require(base.CityJobs);local I=require(base.Services.InteractionService)
local D=require(base.Services.DeliveryService);local original=J.Context
local p=game.Players:GetPlayers()[1];local reports={}
local fixture=require(base.ProfileSchema).Default();local records=0
local ctx=table.clone(original);ctx.Data={Get=function()return fixture end};ctx.Record=function(_,event)assert(event=='CityWork');records+=1 end;J.Context=ctx
local ok,err=xpcall(function()
 local c=p.Character;local human=c:FindFirstChildOfClass('Humanoid');local hrp=c.HumanoidRootPart;hrp:SetNetworkOwner(nil)
 local city=workspace.Neighborhood.MapleHeights
 local function go(target)
  local direction=target.CFrame.LookVector
  -- Station tests isolate timing/rewards from traversal. Roof movement is checked separately.
  local run=J.Active[p.UserId];if run then run.Position=target.Position+direction*3+Vector3.new(0,1,0);run.At=os.clock()end
  c:PivotTo(CFrame.new(target.Position+direction*3+Vector3.new(0,1,0)));task.wait(.4);I.Last[p.UserId]=nil
 end
 -- Actual humanoid walks through each single entry; teleport only positions the test at its start.
 for _,district in ipairs({city.MarketAvenue,city.Uptown,city.OldTown,city.Waterfront})do
  for _,m in ipairs(district:GetChildren())do if m:IsA('Model')and m:GetAttribute('Entry')then
   local e=m:GetAttribute('Entry');local floor=m.Floor;local inside=Vector3.new(floor.Position.X,3,floor.Position.Z)
   c:PivotTo(CFrame.new(e));task.wait(.2);human:MoveTo(inside)
   local untilTime=os.clock()+5;repeat task.wait(.1)until(hrp.Position-inside).Magnitude<4 or os.clock()>untilTime
   assert((hrp.Position-inside).Magnitude<4,'Entrance blocked: '..m.Name..' '..tostring(hrp.Position));table.insert(reports,'walked '..m.Name)
  end end
 end
 for _,kind in ipairs({'Pizza','Laundry','Hotel','Rooftops'})do
  local stations={};for _,t in ipairs(city:GetDescendants())do if t:GetAttribute('CityJob')==kind then stations[t:GetAttribute('Step')]=t end end
  local before=fixture.Currency;J.Last[p.UserId]=nil;J.Active[p.UserId]=nil
  go(stations[3]);assert(not I:Request(p,stations[3],'CityWork'),'Out-of-order paid')
  go(stations[1]);assert(I:Request(p,stations[1],'CityWork'))
  go(stations[2]);assert(not I:Request(p,stations[2],'CityWork'),'Early action accepted');task.wait(4)
  go(stations[2]);local a,b=I:Request(p,stations[2],'CityWork');assert(a,b);task.wait(4)
  go(stations[3]);local a,b=I:Request(p,stations[3],'CityWork');assert(a,b)
  local expected=(kind=='Pizza'or kind=='Laundry')and 45 or 65
  assert(fixture.Currency==before+expected,'Incorrect reward')
  go(stations[3]);assert(not I:Request(p,stations[3],'CityWork'),'Duplicate reward')
  go(stations[1]);assert(not I:Request(p,stations[1],'CityWork'),'Cooldown bypass')
  c:PivotTo(CFrame.new(0,4,0));I.Last[p.UserId]=nil;assert(not I:Request(p,stations[1],'CityWork'),'Distance bypass')
  table.insert(reports,kind..': order, timing, reward, duplicate, cooldown, distance passed')
 end
 assert(records==4)
 for _,v in ipairs(city:GetDescendants())do if v:IsA('BasePart')and v:GetAttribute('Action')=='CityLift'then
  go(v);local a,b=I:Request(p,v,'CityLift');assert(a,b);assert((c:GetPivot().Position-v:GetAttribute('Destination')).Magnitude<1)
 end end;table.insert(reports,'all city lift destinations passed')
 local dispatch=city.Waterfront.WillowWarehouse.Dispatch;go(dispatch);D.Last[p.UserId]=nil
 local a,b=I:Request(p,dispatch,'WarehouseDelivery');assert(a,b);assert(D.Jobs[p.UserId]and p:GetAttribute('DeliveryAddress'));D:Cancel(p)
 table.insert(reports,'warehouse creates and cancels physical existing delivery')
end,debug.traceback)
J.Context=original;J.Active[p.UserId]=nil;J.Last[p.UserId]=nil
workspace:SetAttribute('CityTestResult',game.HttpService:JSONEncode({ok=ok,error=not ok and err or nil,checks=reports}))
print('[CITY TEST]',ok,err)
