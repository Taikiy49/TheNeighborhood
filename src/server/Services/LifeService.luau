local Space=require(game.ReplicatedStorage.Neighborhood.Shared.WorldSpace)
local Players=game:GetService("Players")
local D=require(game.ReplicatedStorage.Neighborhood.Shared.LifeDefinitions)
local R=require(game.ReplicatedStorage.Neighborhood.Shared.LifeRules)
local Schema=require(script.Parent.Parent.ProfileSchema)
local F=require(script.Parent.Parent.LifeFactory)
local S={Now=os.time,Totals={},Seen={},Stations={},Visits={},Tasks={},Travel={},LastAction={},Growth={}}
function S:Earn(player,n)local p=self.Context.Data:Get(player);if p then R.Earn(p.Life,n)end end
function S:Home(player)
 local p=self.Context.Data:Get(player);local h=self.Context.Houses.ByPlayer[player.UserId]
 if p and h then F.Home(h.Model,p.Life,self.Now())end
end
function S:Project(id)
 self.Stations[id]=F.Project(self.World,id,self.Totals[id]or 0)
end
function S:Merge(player)
 local l=self.Context.Data:Get(player).Life;local key=player.UserId;self.Seen[key]=self.Seen[key]or {}
 for id,d in pairs(D.Projects)do
  local old=self.Seen[key][id]or 0;local n=l.Contributions[id]or 0
  self.Totals[id]=math.min(d.Goal,(self.Totals[id]or 0)+math.max(0,n-old));self.Seen[key][id]=math.max(n,old)
  if l.Renovations[id]then self.Totals[id]=d.Goal end
  self:Project(id)
 end
 self:Receipts()
end
function S:Receipts()
 for _,player in ipairs(Players:GetPlayers())do local p=self.Context.Data:Get(player)
  if p and self.Context.Data:CanAct(player)then for id,d in pairs(D.Projects)do
   if (self.Totals[id]or 0)>=d.Goal and (p.Life.Contributions[id]or 0)>0 and not p.Life.Renovations[id]then p.Life.Renovations[id]=true;R.Earn(p.Life,20)end
  end end
 end
end
function S:Restore(player)self:Merge(player);self:Home(player);local l=self.Context.Data:Get(player).Life;if l.TourOpen then self:Doors(player)end end
function S:Doors(player)
 local p=self.Context.Data:Get(player);local h=self.Context.Houses.ByPlayer[player.UserId]
 if p and h and p.Life.TourOpen then h.Locked=false;p.House.Locked=false;h.Model:SetAttribute("Locked",false);self.Context.Houses:SetDoor(h,true)end
end
function S:Release(player)
 local h=self.Context.Houses.ByPlayer[player.UserId];local m=h and h.Model:FindFirstChild("NeighborhoodLife");if m then m:Destroy()end
 self.Visits[player.UserId]=nil;self.Tasks[player.UserId]=nil;self.Travel[player.UserId]=nil;self.LastAction[player.UserId]=nil;self.Growth[player.UserId]=nil
 -- Keep contribution watermarks for this server's lifetime: reconnects cannot count twice.
end
function S:Near(player,part)
 if not part or not part.Parent then return false end
 local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
 return root and (root.Position-part.Position).Magnitude<=12 and self.Context.Interactions:Validate(player,part)==true
end
function S:Ready(player)
 if not self.Context.Data:CanAct(player)then return false end
 local h=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
 return h and h.Health>0 and not h.Sit and not player:GetAttribute("Carrying")and not player:GetAttribute("Departed")
end
function S:Walked(player,part)
 local old=self.Travel[player.UserId];local now=os.clock()
 if old and (part.Position-old.Position).Magnitude>16 and now-old.Time<(part.Position-old.Position).Magnitude/28 then return false end
 self.Travel[player.UserId]={Position=part.Position,Time=now};return true
end
function S:View(player)
 local p=self.Context.Data:Get(player);local v=p and Schema.Copy(p.Life)or R.Default()
 v.Now=self.Now();v.Season=self.Season;v.Projects={};v.Listings={};v.Relay=self.Relay;v.Working=self.Tasks[player.UserId]and self.Tasks[player.UserId].Id
 for _,id in ipairs(D.ProjectOrder)do table.insert(v.Projects,{Id=id,Progress=self.Totals[id]or 0})end
 for _,other in ipairs(Players:GetPlayers())do local pr=self.Context.Data:Get(other);local h=self.Context.Houses.ByPlayer[other.UserId]
  if pr and h and pr.Life.TourOpen then table.insert(v.Listings,{UserId=other.UserId,Name=other.DisplayName,Address=h.Model:GetAttribute("Address"),Theme=pr.Life.Theme})end
 end
 local visit=self.Visits[player.UserId];if visit then v.Visit={Host=visit.Host,Step=visit.Step}end
 return v
end
function S:Action(player,action,arg)
 if type(action)~="string"or type(arg)~="string"or #arg>80 or not self:Ready(player)then return false,"Stand on foot with empty hands and wait for your profile."end
 local now=self.Now();local p=self.Context.Data:Get(player);local l=p.Life;local h=self.Context.Houses.ByPlayer[player.UserId]
 local home=h and h.Model:FindFirstChild("NeighborhoodLife");if not home then return false,"Your home is loading."end
 local last=self.LastAction[player.UserId]or 0;if os.clock()-last<.15 then return false,"Give that action a moment."end;self.LastAction[player.UserId]=os.clock()
 local function no()return false,"Walk to the activity's marked station first."end
 if action=="Renovate"or action=="FinishRenovation"or action=="Social"then
  local d=D.Projects[arg];if not d or not self:Near(player,self.Stations[arg])then return no()end
  if action=="Social"then
   if (self.Totals[arg]or 0)<d.Goal or now<l.WorkReady then return false,"Restore this place first, or wait a minute before its next activity."end
   if arg=="Greenhouse"and (l.Flowers.Daisy or 0)>996 then return false,"Your flower storage is full."end
   l.WorkReady=now+60;R.Earn(l,2)
   if arg=="Greenhouse"then l.Flowers.Daisy=(l.Flowers.Daisy or 0)+3;return true,"Community cuttings collected: three daisies."
   elseif arg=="Clubhouse"then l.Banners[l.Theme]=true;self:Home(player);return true,"Your decorating theme is featured at the clubhouse. Banner earned."
   else return true,"You served tea at the restored cafe. Two mastery XP earned."end
  end
  if (self.Totals[arg]or 0)>=d.Goal then return false,"Already restored! Try the community activity."end
  if action=="Renovate"then
   if now<l.WorkReady then return false,"Take a short breather before the next repair."end
   self.Tasks[player.UserId]={Id=arg,Ready=os.clock()+3};return true,d.Task..". Stay nearby for three seconds, then finish."
  end
  local job=self.Tasks[player.UserId];if not job or job.Id~=arg or os.clock()<job.Ready then return false,"Begin this work task and let its preparation finish."end
  self.Tasks[player.UserId]=nil;l.WorkReady=now+5;l.Contributions[arg]=math.min(d.Goal,(l.Contributions[arg]or 0)+1);R.Earn(l,2);self:Merge(player)
  return true,"One repair completed together. Your contribution is saved."
 elseif action=="Challenge"then
  if not self:Near(player,home.TourSign)then return no()end
  if l.Banners[l.Theme]then return false,"You already earned this theme's banner."end
  local displayed=false;for _,item in ipairs(self.Context.Items:Owned(player))do if item.State=="Displayed"then displayed=true;break end end
  if not displayed then return false,"Display any one possession at home, then enter. Starter items count."end
  l.Banners[l.Theme]=true;R.Earn(l,5);self:Home(player);return true,"Your home joins the showcase! Cosmetic theme banner earned."
 elseif action=="Visit"then
  local id=tonumber(arg);if not R.Int(id,-100000000000,100000000000)then return false,"Choose an available tour."end;local host=Players:GetPlayerByUserId(id);local pr=host and self.Context.Data:Get(host);local house=id and self.Context.Houses.ByPlayer[id]
  if not host or host==player or not pr or not pr.Life.TourOpen or not house then return false,"Choose another neighbor's open tour."end
  if not self:Near(player,house.Model.NeighborhoodLife.TourSign)then return no()end
  self.Visits[player.UserId]={Host=id,Step=1};return true,"Tour begun. See the porch, living room and side garden."
 elseif action=="VisitStop"or action=="Compliment"then
  local visit=self.Visits[player.UserId];local host=visit and Players:GetPlayerByUserId(visit.Host);local pr=host and self.Context.Data:Get(host);local house=host and self.Context.Houses.ByPlayer[host.UserId]
  if not visit or not pr or not pr.Life.TourOpen or not house then self.Visits[player.UserId]=nil;return false,"This tour has closed."end
  local root=player.Character.HumanoidRootPart;local v=house.Model.Foundation.CFrame:PointToObjectSpace(root.Position)
  local positions={Vector3.new(0,3,-19),Vector3.new(0,3,0),Vector3.new(18,3,22)}
  if action=="VisitStop"then
   if visit.Step>3 or arg~=tostring(visit.Step)or (v-Space.Point(positions[visit.Step])).Magnitude>9 then return false,"Walk to your next tour stop: porch, living room, then side garden."end
   local target=visit.Step==1 and house.Model.NeighborhoodLife.TourSign or visit.Step==2 and house.Model.Foundation or house.Model.NeighborhoodLife.GardenBed1
   if not self:Walked(player,target)then return false,"Enjoy the walk between tour stops."end
   visit.Step+=1;if visit.Step==4 then l.Tours=math.min(1000000000,l.Tours+1)end;return true,visit.Step==4 and "Home tour complete! Leave a preset compliment."or "Tour highlight visited."
  end
  if visit.Step~=4 or not table.find({"Warm welcome","Inventive details","Lovely garden"},arg)then return false,"Finish the tour before leaving a compliment."end
  pr.Life.Compliments=math.min(1000000000,pr.Life.Compliments+1);self.Visits[player.UserId]=nil;self.Context.Notify(host,player.DisplayName.." enjoyed your tour: "..arg,true);return true,"Compliment delivered. Thank you for visiting."
 elseif action=="Relay"then
  local index=tostring((self.Relay%3)+1);local stop=self.Stops[index]
  if arg~=index or not self:Near(player,stop)then return false,"The relay needs park lantern "..index.." next."end
  if not self:Walked(player,stop)then return false,"Walk between the relay stations."end
  if now<l.NextRelay then return false,"Your next rewarded relay is available in "..(l.NextRelay-now).." seconds."end
  self.Relay+=1;self.RelayPeople[player.UserId]=true
  if self.Relay>=9 then
   for id in pairs(self.RelayPeople)do local other=Players:GetPlayerByUserId(id);local pr=other and self.Context.Data:Get(other)
    if pr and self.Context.Data:CanAct(other)and now>=pr.Life.NextRelay then pr.Life.NextRelay=now+180;pr.Life.Tokens[self.Season]=math.min(999,(pr.Life.Tokens[self.Season]or 0)+2);R.Earn(pr.Life,5);self.Context.Sync(other)end
   end
   self.Relay=0;self.RelayPeople={};return true,"Relay complete! Contributors earned two "..self.Season.." tokens."
  end
  return true,"Lantern passed! Next station: "..tostring(self.Relay%3+1).."."
 end
 local part
 if action=="Plant"then part=home:FindFirstChild("GardenBed"..(arg:match("^([1-4]):")or ""))
 elseif action=="Water"or action=="Harvest"then part=home:FindFirstChild("GardenBed"..arg)
 elseif action=="Clue"or action=="Token"then part=self.Stops[arg]
 elseif action=="Tour"or action=="Theme"then part=home.TourSign
 elseif table.find({"Arrange","Business","Order","Work","Blueprint","Style"},action)then part=home.LifeCounter
 elseif not table.find({"Case","PutAway","Deduce","Ending","Hunt","Decor","Equip"},action)then return false,"Unknown life activity."end
 if part and not self:Near(player,part)then return no()end
 if (action=="Plant"or action=="Water"or action=="Harvest"or action=="Clue"or action=="Token")and not part then return no()end
 -- Reject premature route claims before consuming a movement receipt.
 if action=="Clue"and (l.Mystery==""or arg~=tostring(l.Clue+1)or l.Clue>=3)then return false,"Follow the next clue in your mystery."end
 if action=="Token"and (l.Festival==""or arg~=tostring(l.Hunt+1))then return false,"Follow the next lantern in your hunt."end
 if (action=="Clue"or action=="Token")and not self:Walked(player,part)then return false,"Walk along the park trail between clues."end
 local ok,message,delta=R.Action(l,p.Currency,action,arg,now,p.Building)
 if ok then p.Currency+=delta;if action=="Tour"then self:Doors(player)end
  if table.find({"Plant","Water","Harvest","Business","Order","Work","Blueprint","Style","Tour","Theme","Decor","Equip"},action)then self:Home(player)end
 end
 return ok,message
end
function S:Init(context)
 self.Context=context;self.Season=D.Season(self.Now());self.Relay=0;self.RelayPeople={}
 self.World,self.Stops=F.World(workspace.Neighborhood.Runtime,self.Season)
 for id in pairs(D.Projects)do self.Totals[id]=0;self:Project(id)end
 context.Interactions:Register("LifeStation",function(player,target)
  if not self:Ready(player)then return false,"Stand on foot with empty hands."end
  local valid=target:IsDescendantOf(self.World)
  if not valid then for _,h in pairs(context.Houses.ById)do local m=h.Model:FindFirstChild("NeighborhoodLife");if m and target:IsDescendantOf(m)then valid=true;break end end end
  if not valid then return false,"This station is unavailable."end
  context.Sync(player);context.Open(player,target:GetAttribute("LifeView"),target:GetAttribute("LifeArg"));return true
 end)
 task.spawn(function()while task.wait(5)do
  for _,player in ipairs(Players:GetPlayers())do local p=context.Data:Get(player)
   if p and context.Data:CanAct(player)then
    local key="";for i=1,4 do local b=p.Life.Beds[tostring(i)];key..=b and (R.Ready(b,self.Now())and "R"or "G")or "E"end
    if key~=self.Growth[player.UserId]then self.Growth[player.UserId]=key;self:Home(player)end
    -- Locking a home explicitly ends its tour; do not silently undo the owner's lock.
    local h=context.Houses.ByPlayer[player.UserId];if p.Life.TourOpen and h and h.Locked then p.Life.TourOpen=false;self:Home(player)end
    context.Sync(player)
   end
  end
 end end)
end
return S
