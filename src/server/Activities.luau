local Players=game:GetService('Players')
local S={Runs={},Memory={},Paid={}}
local places={{'West cottages',-75,-90},{'Lakeside junction',-75,60},{'Market crossing',0,194},{'Meadow junction',75,60},{'East cottages',75,-90},{'Beach boardwalk',0,-194}}
local goals={{Id='Circuit',Name='Finish a neighborhood circuit',Target=1},{Id='Memory',Name='Complete the five-round memory challenge',Target=1},{Id='Work',Name='Finish three jobs or meadow trials',Target=3}}
function S:Progress(player)
 local p=self.Context.Data:Get(player);if not p then return end
 local a=p.Activities;local day=math.floor(os.time()/86400)
 if a.Day~=day then a.Day=day;a.Counts={};a.Claimed={}end
 return a,p
end
function S:Record(player,event)
 local a=self:Progress(player);if not a then return end
 local key=event=='Delivery'or event=='Trial'or event=='Fishing'or event=='Repair'
 key=key and 'Work'or event
 if key=='Circuit'or key=='Memory'or key=='Work'then a.Counts[key]=math.min(100,(a.Counts[key]or 0)+1)end
end
function S:View(player)
 local a=self:Progress(player);if not a then return end
 local ranks={'New Neighbor','Street Explorer','Local Favorite','Town Champion','Maple Legend'}
 local v={XP=a.XP,Rank=ranks[math.min(5,1+math.floor(a.XP/200))],NextRank=math.min(800,(math.floor(a.XP/200)+1)*200),Goals={},BestMs=a.BestMs,Finishes=a.Finishes}
 for _,g in ipairs(goals)do table.insert(v.Goals,{Id=g.Id,Name=g.Name,Target=g.Target,Count=a.Counts[g.Id]or 0,Claimed=a.Claimed[g.Id]==true})end
 local run=self.Runs[player];if run then local q=places[run.Order[run.Next]];v.Run={Name=q[1],Position={q[2],3,q[3]},Step=run.Next,Total=6,Elapsed=math.floor(os.clock()-run.Started)}end
 local m=self.Memory[player];if m then v.Memory={Round=m.Round,Entered=m.At-1,Length=#m.Sequence,Showing=os.clock()<m.ShowUntil};if v.Memory.Showing then v.Memory.Sequence=table.clone(m.Sequence)end end
 return v
end
function S:Reward(player,kind,amount,xp)
 local a,p=self:Progress(player);if not a then return false end
 local key=player.UserId..kind;local now=os.clock()
 if now-(self.Paid[key]or -90)<90 then return false end
 self.Paid[key]=now;p.Currency=math.min(1000000000,p.Currency+amount);a.XP=math.min(1000000000,a.XP+xp);return true
end
function S:Round(player,m)
 m.Sequence={};m.At=1
 for i=1,m.Round+2 do table.insert(m.Sequence,math.random(1,4))end
 m.ShowUntil=os.clock()+3+m.Round*.5;m.Expires=m.ShowUntil+35
 task.delay(3+m.Round*.5,function()if self.Memory[player]==m then self.Context.Sync(player)end end)
end
function S:Action(player,action,value)
 local a,p=self:Progress(player);if not a then return false,'Profile unavailable.'end
 if action=='Claim'then
  local goal;for _,g in ipairs(goals)do if g.Id==value then goal=g end end
  if not goal then return false,'Unknown objective.'end
  if a.Claimed[value]then return false,'Already collected today.'end
  if (a.Counts[value]or 0)<goal.Target then return false,'Finish the objective first.'end
  a.Claimed[value]=true;p.Currency=math.min(1000000000,p.Currency+100);a.XP=math.min(1000000000,a.XP+50);return true,'Objective complete: $100 and 50 mastery XP!'
 elseif action=='Circuit'then
  if self.Runs[player]then return false,'Finish or cancel your current circuit.'end
  local hrp=player.Character and player.Character:FindFirstChild('HumanoidRootPart');if not hrp then return false,'Your character is not ready.'end
  local order={};local offset=math.floor(os.time()/600)%6;local reverse=math.floor(os.time()/600)%2==1
  for i=1,6 do order[i]=(offset+(reverse and -i or i))%6+1 end
  self.Runs[player]={Order=order,Next=1,Started=os.clock(),Last=hrp.Position,LastAt=os.clock(),Distance=0};return true,'Circuit started! Follow the checkpoint marker on foot. Six stops; beat your best time.'
 elseif action=='Memory'then
  if self.Memory[player]then return false,'Finish or cancel the current memory game.'end
  local m={Round=1};self.Memory[player]=m;self:Round(player,m);return true,'Remember the sequence, then repeat it when it disappears.'
 elseif action=='Answer'then
  local m=self.Memory[player];if not m then return false,'Start a memory challenge first.'end
  if type(value)~='number'or value%1~=0 or value<1 or value>4 then return false,'Choose one of the four symbols.'end
  if os.clock()<m.ShowUntil then return false,'Watch first; answer after the sequence disappears.'end
  if os.clock()>m.Expires or value~=m.Sequence[m.At]then self.Memory[player]=nil;return false,'Sequence missed. Start again and try to reach round five.'end
  m.At+=1
  if m.At>#m.Sequence then
   if m.Round==5 then
    self.Memory[player]=nil;self:Record(player,'Memory');a.Finishes=math.min(1000000000,a.Finishes+1)
    local paid=self:Reward(player,'Memory',80,25);return true,paid and 'Perfect memory! $80 and 25 mastery XP.'or 'Perfect memory! Practice complete; cash rewards refresh every 90 seconds.'
   end
   m.Round+=1;self:Round(player,m);return true,'Correct! Remember the next sequence.'
  end
  return true,'Correct symbol.'
 elseif action=='Cancel'then self.Runs[player]=nil;self.Memory[player]=nil;return true,'Challenge cancelled. You can start again anytime.'end
 return false,'Unknown activity.'
end
function S:Step()
 for player,run in pairs(self.Runs)do
  local c=player.Character;local hrp=c and c:FindFirstChild('HumanoidRootPart');local h=c and c:FindFirstChildOfClass('Humanoid');local now=os.clock()
  if not hrp or not h or h.Health<=0 or h.Sit or now-run.Started>600 or not self.Context.Data:CanAct(player)then self.Runs[player]=nil;self.Context.Notify(player,'Circuit ended. Start another whenever you like.',false);self.Context.Sync(player)
  else
   local delta=(hrp.Position-run.Last).Magnitude;local dt=now-run.LastAt
   if delta>math.max(12,dt*32)then self.Runs[player]=nil;self.Context.Notify(player,'Circuit interrupted by a jump in position. Restart on foot.',false);self.Context.Sync(player)
   else
    run.Distance+=delta;run.Last=hrp.Position;run.LastAt=now
    local q=places[run.Order[run.Next]];local target=Vector3.new(q[2],hrp.Position.Y,q[3])
    if (hrp.Position-target).Magnitude<7 and math.abs(hrp.Position.Y)<12 then
     run.Next+=1
     if run.Next>6 then
      self.Runs[player]=nil;local elapsed=math.floor((now-run.Started)*1000);local a=self:Progress(player)
      if a and elapsed>20000 and run.Distance>250 then
       a.BestMs=a.BestMs==0 and elapsed or math.min(a.BestMs,elapsed);a.Finishes=math.min(1000000000,a.Finishes+1);self:Record(player,'Circuit')
       local paid=self:Reward(player,'Circuit',120,30);self.Context.Notify(player,paid and 'Circuit complete! $120 and 30 mastery XP.'or 'Circuit complete! Personal best and daily progress updated.',true)
      end
     else self.Context.Notify(player,'Checkpoint '..(run.Next-1)..'/6! Follow the next marker.',true)end
     self.Context.Sync(player)
    end
   end
  end
 end
 for player,m in pairs(self.Memory)do if os.clock()>m.Expires then self.Memory[player]=nil;self.Context.Notify(player,'Memory challenge timed out. Try again anytime.',false);self.Context.Sync(player)end end
end
function S:Init(context)
 self.Context=context
 Players.PlayerRemoving:Connect(function(p)self.Runs[p]=nil;self.Memory[p]=nil;self.Paid[p.UserId..'Memory']=nil;self.Paid[p.UserId..'Circuit']=nil end)
 task.spawn(function()while true do task.wait(.2);self:Step()end end)
end
return S
