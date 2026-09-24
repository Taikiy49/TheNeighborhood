-- Ordered physical jobs. Rewards and timing live exclusively on the server.
local J={Active={},Last={}}
local rewards={Pizza=45,Laundry=45,Hotel=65,Rooftops=65}
function J:Publish(player)
 local run=self.Active[player.UserId]
 player:SetAttribute('CityWorkKind',run and run.Kind)
 player:SetAttribute('CityWorkStep',run and run.Step)
 player:SetAttribute('CityWorkReadyAt',run and(workspace:GetServerTimeNow()+math.max(0,run.Ready-os.clock())))
 local position
 local city=workspace.Neighborhood:FindFirstChild('MapleHeights')
 if run and city then for _,v in ipairs(city:GetDescendants())do if v:IsA('BasePart')and v:GetAttribute('CityJob')==run.Kind and v:GetAttribute('Step')==run.Step then position=v.Position;break end end end
 player:SetAttribute('CityWorkPosition',position)
end
function J:Cue(player,run)
 local step=run.Step
 task.delay(4,function()if self.Active[player.UserId]==run and run.Step==step then self.Context.Notify(player,'Ready for station '..step..'. Follow your shift route.',true)end end)
end
function J:Work(player,target)
 local kind,step=target:GetAttribute('CityJob'),target:GetAttribute('Step')
 if not rewards[kind]or type(step)~='number'then return false,'Unknown work station.'end
 local now=os.clock();local id=player.UserId;local run=self.Active[id]
 if step==1 then
  if now-(self.Last[id]or -90)<90 then return false,'Next paid shift is available in a minute and a half.'end
  if player:GetAttribute('Carrying')or player:GetAttribute('DeliveryAddress')then return false,'Finish carrying your current item first.'end
  self.Active[id]={Kind=kind,Step=2,Ready=now+4,Expires=now+240,Position=player.Character:GetPivot().Position,At=now}
  self:Cue(player,self.Active[id])
  local directions={Pizza='Prepare at the middle board, then box at the right station.',Laundry='Use the washer, then fold at the table.',Hotel='Take the lift: tidy room 201, then room 301.',Rooftops='Climb the west brownstone fire escape, check its roof, then cross to the east roof.'}
  return true,directions[kind]..' Each step needs four seconds.'
 end
 if not run or run.Kind~=kind then return false,'Start this shift at its first station.'end
 if run.Step~=step then return false,'Complete the previous station first.'end
 if now>run.Expires then self.Active[id]=nil;return false,'Shift expired. Start again.'end
 if now<run.Ready then return false,'Still preparing. Give this step four seconds.'end
 if step==2 then run.Step=3;run.Ready=now+4;self:Cue(player,run);return true,'Good work. Move to the final station; ready in four seconds.'end
 local p=self.Context.Data:Get(player);if not p then return false,'Profile unavailable.'end
 self.Active[id]=nil;self.Last[id]=now
 p.Currency=math.min(1000000000,p.Currency+rewards[kind]);self.Context.Record(player,'CityWork')
 return true,'Shift complete! Earned $'..rewards[kind]..'. Counts toward your daily work goal.'
end
function J:Init(context)
 self.Context=context;require(script.Parent.MapleHeights).Build(workspace.Neighborhood)
 context.Interactions:Register('CityWork',function(player,target)local ok,message=self:Work(player,target);self:Publish(player);return ok,message end)
 context.Interactions:Register('WarehouseDelivery',function(player,target)return require(script.Parent.Services.DeliveryService):Start(player,target)end)
 context.Interactions:Register('CityLift',function(player,target)
  if player:GetAttribute('Carrying')or player:GetAttribute('DeliveryAddress')then return false,'Finish carrying your item before using the lift.'end
  local c=player.Character;local human=c and c:FindFirstChildOfClass('Humanoid');local destination=target:GetAttribute('Destination')
  if not human or human.Health<=0 or human.Sit or typeof(destination)~='Vector3' then return false,'Stand up before using the lift.'end
  c:PivotTo(CFrame.new(destination));return true,'You have arrived.'
 end)
 local function added(player)player.CharacterRemoving:Connect(function()self.Active[player.UserId]=nil;self:Publish(player)end)end
 game.Players.PlayerAdded:Connect(added);for _,p in ipairs(game.Players:GetPlayers())do added(p)end
 game.Players.PlayerRemoving:Connect(function(p)self.Active[p.UserId]=nil;self.Last[p.UserId]=nil end)
 local elapsed=0
 game:GetService('RunService').Heartbeat:Connect(function(dt)
  elapsed+=dt;if elapsed<.2 then return end;elapsed=0
  for id,run in pairs(self.Active)do
   if os.clock()>run.Expires then
    self.Active[id]=nil;local p=game.Players:GetPlayerByUserId(id);if p then self:Publish(p);context.Notify(p,'Shift ended. Start again whenever you like.',false)end
    continue
   end
   if run.Kind=='Rooftops'then
    local p=game.Players:GetPlayerByUserId(id);local c=p and p.Character;local root=c and c:FindFirstChild('HumanoidRootPart');local now=os.clock()
    if not root or(root.Position-run.Position).Magnitude>40*(now-run.At)+12 then
     self.Active[id]=nil;if p then self:Publish(p);context.Notify(p,'Roof route interrupted. Start again at the courtyard.',false)end
    else run.Position=root.Position;run.At=now end
   end
  end
 end)
end
return J
