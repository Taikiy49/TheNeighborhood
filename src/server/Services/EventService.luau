local Players=game:GetService("Players")
local Service={Current=nil,Participation={},Offers={}}
local definitions={
 GarageSale={Title="Garage Sale Day",Description="Maple & Co. has 20% off every household item for the next two minutes."},
 BlockParty={Title="Block Party",Description="Meet in Maple Green. Offer a high-five to a nearby neighbor; they must return it. Each pair earns $20 once."},
 WatchNight={Title="Neighborhood Watch",Description="Check three different mailboxes on foot. Finish a patrol to earn $90."},
 PowerOutage={Title="Lights Out",Description="Streetlights are out. Cameras need a level-two backup system; mechanical display alarms still work."},
}
function Service:Init(context)
 self.Context=context
 Players.PlayerRemoving:Connect(function(p)self.Offers[p.UserId]=nil end)
 local board=workspace.Neighborhood.Map.CommunityBoard;board:SetAttribute("SecondaryAction","CommunityEvent")
 local prompt=Instance.new("ProximityPrompt");prompt.Name="CommunityEvent";prompt.Style=Enum.ProximityPromptStyle.Custom;prompt.ActionText="Community notice";prompt.ObjectText="What's happening";prompt.KeyboardKeyCode=Enum.KeyCode.F;prompt.GamepadKeyCode=Enum.KeyCode.ButtonY;prompt.MaxActivationDistance=10;prompt:SetAttribute("Action","CommunityEvent");prompt.Parent=board
 context.Interactions:Register("CommunityEvent",function(player)context.Open(player,"Event");return true end)
 local testing=false
 if game:GetService("RunService"):IsStudio() then local args=game:GetService("StudioTestService"):GetTestArgs();testing=type(args)=="table" and args.Name~=nil end
 if testing then return end
 task.spawn(function()
  task.wait(45)
  local order={"BlockParty","GarageSale","WatchNight","PowerOutage"};local index=math.floor(os.time()/86400)%#order+1
  while true do self:Start(order[index]);task.wait(120);self:Finish();task.wait(180);index=index%#order+1 end
 end)
end
function Service:View()
 if not self.Current then return {Title="A quiet moment",Description="The next community event will appear on this board and your phone."}end
 return {Id=self.Current.Id,Kind=self.Current.Kind,Title=definitions[self.Current.Kind].Title,Description=definitions[self.Current.Kind].Description,EndsAt=self.Current.EndsAt}
end
function Service:Start(kind)
 assert(definitions[kind],"Unknown community event")
 self:Finish();self.Current={Id=game:GetService("HttpService"):GenerateGUID(false),Kind=kind,EndsAt=os.time()+120};self.Participation={};self.Offers={}
 workspace.Neighborhood:SetAttribute("SaleMultiplier",kind=="GarageSale" and 0.8 or 1)
 workspace.Neighborhood:SetAttribute("PowerOutage",kind=="PowerOutage")
 for _,p in ipairs(Players:GetPlayers())do self.Context.Notify(p,definitions[kind].Title.." has started. Open Phone → Community.",true);self.Context.Sync(p)end
end
function Service:Finish()
 self.Current=nil;self.Offers={}
 workspace.Neighborhood:SetAttribute("SaleMultiplier",1);workspace.Neighborhood:SetAttribute("PowerOutage",false)
 if self.Context then for _,p in ipairs(Players:GetPlayers())do self.Context.Sync(p)end end
end
function Service:Reward(player,key,amount)
 local p=self.Context.Data:Get(player);if not p then return false end
 local receipt=self.Current.Id..":"..key
 if table.find(p.EventClaims,receipt)then return false end
 table.insert(p.EventClaims,receipt);while #p.EventClaims>32 do table.remove(p.EventClaims,1)end
 p.Currency+=amount;self.Context.Record(player,"CommunityEvent");return true
end
function Service:Action(player,action,argument)
 if not self.Current or self.Current.EndsAt<os.time()then return false,"That event has finished."end
 local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
 local humanoid=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
 if not root or not humanoid or humanoid.Health<=0 then return false,"Your character is not ready."end
 if action=="Watch" and self.Current.Kind=="WatchNight"then
  local house=type(argument)=="string" and self.Context.Houses.ById[argument]
  if not house then return false,"Choose a house from the patrol list."end
  local valid,why=self.Context.Interactions:Validate(player,house.Model.Mailbox.Box);if not valid then return false,why end
  local visits=self.Participation[player.UserId] or {};self.Participation[player.UserId]=visits
  if visits[argument]then return false,"You already checked this home."end
  visits[argument]=true;local count=0;for _ in pairs(visits)do count+=1 end
  if count>=3 and self:Reward(player,"patrol",90)then return true,"Patrol complete. You earned $90."end
  return true,"Mailbox checked. "..math.min(count,3).." / 3 homes visited."
 elseif action=="HighFive" and self.Current.Kind=="BlockParty"then
  local target=type(argument)=="number" and Players:GetPlayerByUserId(argument)
  local targetRoot=target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
  if not target or target==player or not targetRoot or (root.Position-targetRoot.Position).Magnitude>10 or Vector3.new(root.Position.X,0,root.Position.Z).Magnitude>30 then return false,"Meet that neighbor in Maple Green first."end
  local offered=self.Offers[target.UserId]
  if offered and offered.Target==player.UserId and os.clock()-offered.Time<15 then
   self.Offers[target.UserId]=nil;self.Offers[player.UserId]=nil
   local key="highfive:"..math.min(player.UserId,target.UserId)..":"..math.max(player.UserId,target.UserId)
   local paid=self:Reward(player,key,20);local otherPaid=self:Reward(target,key,20)
   if paid or otherPaid then self.Context.Notify(target,"High-five! You each earned $20.",true);self.Context.Sync(target);return true,"High-five! You earned $20."end
   return false,"You already celebrated with this neighbor during this party."
  end
  self.Offers[player.UserId]={Target=target.UserId,Time=os.clock()};self.Context.Notify(target,"A nearby neighbor offered a high-five. Open Phone → Community to return it.",true)
  return true,"High-five offered. They have 15 seconds to return it."
 end
 return false,"That activity is not part of the current event."
end
return Service
