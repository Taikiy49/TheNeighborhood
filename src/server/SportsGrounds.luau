-- Imported sports art; server-controlled shared balls and local match scores.
local A=require(script.Parent.CityArchitecture)
local Run=game:GetService('RunService')
local S={Balls={},Scores={Soccer={0,0},Basketball={0,0}}}
function S:Reset(state)
 local ball=state.Part
 ball.CFrame=CFrame.new(state.Home);ball.AssemblyLinearVelocity=Vector3.zero;ball.AssemblyAngularVelocity=Vector3.zero
 state.Previous=state.Home;state.LastShot=0;state.LastTouch=nil;state.ResetAt=nil
end
function S:Play(player,ball)
 local state=self.Balls[ball];if not state then return false,'Use the court ball.'end
 local c=player.Character;local r=c and c:FindFirstChild('HumanoidRootPart');local h=c and c:FindFirstChildOfClass('Humanoid')
 if not r or not h or h.Health<=0 or h.Sit or player:GetAttribute('Carrying')then return false,'Stand beside the ball with your hands free.'end
 if (r.Position-ball.Position).Magnitude>8 then return false,'Move closer to the ball.'end
 local now=os.clock();if state.ResetAt or now-state.LastShot<.65 then return false,'Wait for the ball to settle.'end
 local d=Vector3.new(r.CFrame.LookVector.X,0,r.CFrame.LookVector.Z)
 if d.Magnitude<.1 then return false,'Face the goal or basket.'end
 d=d.Unit;state.LastShot=now;state.LastTouch=player.UserId
 ball:SetNetworkOwner(nil)
 local speed=state.Kind=='Soccer'and 58 or 38
 local lift=state.Kind=='Soccer'and 13 or 57
 ball.AssemblyLinearVelocity=d*speed+Vector3.new(0,lift,0)
 ball.AssemblyAngularVelocity=Vector3.new(d.Z,0,-d.X)*12
 return true,state.Kind=='Soccer'and 'Kick! Aim with the direction you face.'or 'Shot! Face the basket and try from the painted key.'
end
function S:Score(state,side)
 if state.ResetAt then return end
 self.Scores[state.Kind][side]+=1
 state.ResetAt=os.clock()+2
 local score=self.Scores[state.Kind]
 self.Labels[state.Kind].Text=state.Kind:upper()..'   '..score[1]..' : '..score[2]
 local player=state.LastTouch and game.Players:GetPlayerByUserId(state.LastTouch)
 if player then self.Context.Notify(player,state.Kind=='Soccer'and 'Goal!'or 'Basket!',true)end
end
function S:Step()
 local now=os.clock()
 for ball,state in pairs(self.Balls)do
  local pos=ball.Position;local localPos=pos-state.Center
  if state.ResetAt then if now>=state.ResetAt then self:Reset(state)end
  elseif math.abs(localPos.X)>state.Bounds.X or math.abs(localPos.Z)>state.Bounds.Z or pos.Y< -5 or pos.Y>90 then self:Reset(state)
  else
   if state.Kind=='Soccer'then
    for i,g in ipairs(state.Goals)do
     local prev=state.Previous-g.Position;local cur=pos-g.Position
     if prev.Z*g.Side<0 and cur.Z*g.Side>=0 and math.abs(cur.X)<g.Width and cur.Y> -1 and cur.Y<g.Height then self:Score(state,i);break end
    end
   else
    for i,hoop in ipairs(state.Goals)do
     if state.Previous.Y>hoop.Y and pos.Y<=hoop.Y and Vector3.new(pos.X-hoop.X,0,pos.Z-hoop.Z).Magnitude<1.45 then self:Score(state,i);break end
    end
   end
   state.Previous=pos
  end
 end
end
function S.Init(context)
 S.Context=context;S.Balls={};S.Labels={};S.Scores={Soccer={0,0},Basketball={0,0}}
 local w=workspace.Neighborhood;local school=w.CoastalWorld.SchoolDistrict
 local retired={FootballField=true,FieldLine=true,GoalPost=true,GoalBar=true,BasketballCourt=true,HoopPole=true,Backboard=true,SportsBallRack=true}
 for _,v in ipairs(school:GetChildren())do if retired[v.Name]then v:Destroy()end end
 for _,v in ipairs(w.CoastalWorld.Landscape:GetChildren())do if v.Name=='CourtLine'or v.Name=='BasketballRim'then v:Destroy()end end
 local root=Instance.new('Folder');root.Name='SportsGrounds';root.Parent=school;S.Root=root
 local library=game.ServerStorage.SportsArt
 local settings={
  {Kind='Soccer',Center=Vector3.new(-440,.22,475),Scale=.86,Bounds=Vector3.new(55,0,83)},
  {Kind='Basketball',Center=Vector3.new(-335,.22,444),Scale=.72,Bounds=Vector3.new(29,0,47)},
 }
 for _,d in ipairs(settings)do
  local model=library[d.Kind]:Clone();model.Name=d.Kind;model:ScaleTo(d.Scale);model:PivotTo(CFrame.new(d.Center));model.ModelStreamingMode=Enum.ModelStreamingMode.Atomic;model.Parent=root
  local goals={}
  for _,p in ipairs(model:GetDescendants())do if p:IsA('BasePart')then
   p.Anchored=true;p.CanQuery=true;p.CanTouch=false
   if p.Name=='Rim'then table.insert(goals,p.Position);p.CanCollide=false end
   if p.Size.Y<.4 and p.Name~='Court'and p.Name~='grass'then p.CanCollide=false;p.CanQuery=false end
  end end
  if d.Kind=='Soccer'then
   for _,goal in ipairs(model:GetChildren())do if goal.Name=='Goal'and goal:IsA('Model')then
    local cf,size=goal:GetBoundingBox();local side=cf.Position.Z>d.Center.Z and 1 or -1
    table.insert(goals,{Position=Vector3.new(cf.Position.X,d.Center.Y,cf.Position.Z-side*size.Z/2),Side=side,Width=size.X/2-1,Height=size.Y})
   end end
  end
  table.sort(goals,function(a,b)return (typeof(a)=='Vector3'and a.Z or a.Position.Z)<(typeof(b)=='Vector3'and b.Z or b.Position.Z)end)
  assert(#goals==2,d.Kind..' must have two goals')
  local ball=library[d.Kind..'Ball']:Clone();ball.Name=d.Kind..'Ball';ball.Size=Vector3.one*(d.Kind=='Soccer'and 1.8 or 1.35)
  ball.Anchored=false;ball.CanCollide=true;ball.CanTouch=false;ball.CanQuery=true
  ball.CustomPhysicalProperties=PhysicalProperties.new(.5,.35,d.Kind=='Soccer'and .35 or .65)
  ball.CFrame=CFrame.new(d.Center+Vector3.new(0,2,0));ball.Parent=root;ball:SetNetworkOwner(nil)
  A.Prompt(ball,'PlaySport',d.Kind,d.Kind=='Soccer'and 'Kick ball'or 'Shoot ball')
  local state={Part=ball,Kind=d.Kind,Home=ball.Position,Previous=ball.Position,Center=d.Center,Bounds=d.Bounds,Goals=goals,LastShot=0}
  S.Balls[ball]=state
  -- One small score display at the grounds, not a row of activity advertisements.
  local x=d.Center.X+(d.Kind=='Soccer'and -51 or 32);local z=d.Center.Z-25
  local post=A.Part(root,'ScorePost',{.35,7,.35},Vector3.new(x,3.5,z),A.Ink,Enum.Material.Metal)
  local board=A.Part(root,d.Kind..'Score',{7,2,.25},Vector3.new(x,7,z),A.Ink,Enum.Material.Metal,false)
  A.Sign(board,d.Kind:upper()..'   0 : 0');S.Labels[d.Kind]=board.SurfaceGui.TextLabel
 end
 context.Interactions:Register('PlaySport',function(player,target)return S:Play(player,target)end)
 local accumulated=0;Run.Heartbeat:Connect(function(dt)accumulated+=dt;if accumulated>=.03 then accumulated=0;S:Step()end end)
end
return S
