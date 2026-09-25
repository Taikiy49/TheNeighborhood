local UI=require(script.Parent.UI)
local Guide=require(script.Parent.TaskGuide)
local M={}
local symbols={'● Circle','★ Star','◆ Diamond','▲ Triangle'}
local shapes={'●','★','◆','▲'}
function M.Render(s,tab)
 tab=tab or 'Tasks';s.CurrentDetail=tab;s.Title.Text='Your goals'
 s.RowIndex+=1
 local tabs=UI.New('Frame',{Name='GoalTabs',Size=UDim2.new(1,-10,0,48),BackgroundTransparency=1,LayoutOrder=s.RowIndex},s.List)
 for i,name in ipairs({'Tasks','Play','Jobs'})do
  local b=UI.Button(tabs,name,UDim2.new(1/3,-6,0,48),UDim2.new((i-1)/3,0,0,0),function()s:Open('Activities',name)end)
  if tab==name then b.BackgroundColor3=UI.Theme.Accent;b.TextColor3=UI.Theme.Text end
 end
 local a=s.State.Activities;if not a then s:Row('Getting ready…','Your goals will appear when your home is ready.');return end
 if tab=='Tasks'then
  s:Row('Build a life here','Do jobs → earn cash → upgrade your home, yard and rides. Games and friends are always optional.','Find a paid job',function()s:Open('Activities','Jobs')end)
  local target=Guide:Savings(s.State)
  s:ProgressRow(target.Title,target.ProgressLabel..' saved. '..target.Hint,target.Count,target.Total,target.Button,function()s:Open(target.View,target.Detail)end)

  local xp=a.XP or 0;local maximum=xp>=800
  local steps=s.State.Progress and s.State.Progress.Checklist or {};local done=0
  for _,step in ipairs(steps)do if step.Done then done+=1 end end
  s:ProgressRow('Make yourself at home',done==#steps and 'All first steps finished!'or 'One small step at a time.',done,math.max(1,#steps))
  for _,step in ipairs(steps)do
   if step.Done then continue end
   local entry=Guide.Steps[step.Key];local title=entry and entry[1]or step.Text
   s:Row((step.Done and 'Done • 'or '')..title,step.Done and 'Nice work!'or(entry and entry[2]or step.Text),not step.Done and 'Show me'or nil,function()
    Guide:Track(nil);Guide:Show({Key=entry and entry[3],Title=title},s.State,game.Players.LocalPlayer);s:Close()
   end)
   break
  end
  local residence=s.State.Residence;if residence then local defs=require(game.ReplicatedStorage.Neighborhood.Shared.ResidenceDefinitions);local nextHome=defs.Tiers[residence.Tier+1];s:Row(nextHome and 'Dream home: '..nextHome.Name or 'Your next renovation',nextHome and 'Work, save and grow your home upward.'or 'Refresh your home and keep building your renovation record.','See home plans',function()s:Open('Residence')end)end
  s:Row('Today’s tasks','Optional goals. New tasks arrive each day.')
  local names={Circuit='Finish a checkpoint run',Memory='Win the memory game',Work='Finish 3 jobs or trials'}
  for _,g in ipairs(a.Goals or {})do
   local ready=g.Count>=g.Target;local action=not g.Claimed and(ready and 'Collect $100 + 50 XP'or 'Try this task')or nil
   s:ProgressRow(names[g.Id]or g.Name,g.Claimed and 'Reward collected!'or 'Reward: $100 + 50 XP',math.min(g.Count,g.Target),g.Target,action,function()
    if ready then s.Request('Activities','Claim',g.Id)else s:Open('Activities',g.Id=='Work'and 'Jobs'or 'Play')end
   end)
  end
  s:ProgressRow(a.Rank,maximum and 'Top rank reached!'or 'XP to your next rank',maximum and 200 or xp%200,200)
  s:Row('Your achievements','See every first step and achievement.','See all progress',function()s:Open('Progress')end)
 elseif tab=='Jobs'then
  s:Row('Earn cash around town','Pick a job. Follow the HERE marker, then tap its station.')
  for _,job in ipairs(Guide.Jobs)do s:Row(job.Title..' • '..job.Reward,job.Hint,'Show me',function()
   Guide:Track(job.Id);Guide:Show({Key='Job:'..job.Id,Title=job.Title,Position=job.Position},s.State,game.Players.LocalPlayer);s:Close()
  end)end
  s:Row('Take your time','Each shop step needs 4 seconds. Paid shifts have a 90-second break.')
 else
  if a.Memory then
   local m=a.Memory
   s:ProgressRow('Memory • round '..m.Round..' of 5',m.Showing and 'Watch! Remember this order.'or 'Your turn! Tap the same order.',m.Showing and 0 or m.Entered,m.Length)
   if m.Showing then
    local sequence={};for i,n in ipairs(m.Sequence or {})do table.insert(sequence,i..'. '..shapes[n])end
    s:Row(table.concat(sequence,'  →  '),'The sequence will hide before your turn.')
   else
    s.RowIndex+=1;local grid=UI.New('Frame',{Name='MemoryButtons',Size=UDim2.new(1,-10,0,112),BackgroundTransparency=1,LayoutOrder=s.RowIndex},s.List)
    for i,name in ipairs(symbols)do UI.Button(grid,name,UDim2.new(.5,-4,0,48),UDim2.new((i-1)%2*.5,0,0,math.floor((i-1)/2)*56),function()s.Request('Activities','Answer',i)end)end
   end
  else s:Row('Memory game • $80','Watch a pattern. Tap it back. Beat 5 rounds!','Play memory',function()s.Request('Activities','Memory')end)end
  if a.Run then s:ProgressRow('Checkpoint run','Next stop: '..a.Run.Name,a.Run.Step-1,a.Run.Total,'Keep running',function()s:Close()end)
  else s:Row('Checkpoint run • $120','Follow 6 markers on foot. Beat your best time!','Start running',function()s.Request('Activities','Circuit');s:Close()end)end
  if a.Run or a.Memory then s:Row('Want a break?','You can try again anytime.','Stop challenge',function()s.Request('Activities','Cancel')end)end
  s:Row('Neighborhood playground','Swings, a slide and climbing steps in the park.','Show me',function()Guide:Show({Key='Playground',Title='Neighborhood playground',Position=Vector3.new(-90,3,10)},s.State,game.Players.LocalPlayer);s:Close()end)
  s:Row('More adventures','Grow flowers, solve a mystery or explore town.','Explore more',function()s:Open('MenuExplore')end)
 end
end
function M.Update(state)
 if M.Marker then M.Marker:Destroy();M.Marker=nil end
 local run=state.Activities and state.Activities.Run;if not run then return end
 local p=UI.New('Part',{Name='MyCircuitCheckpoint',Anchored=true,CanCollide=false,CanQuery=false,CanTouch=false,Transparency=1,Size=Vector3.one,Position=Vector3.new(table.unpack(run.Position))},workspace);M.Marker=p
 local b=UI.New('BillboardGui',{Size=UDim2.fromOffset(200,60),StudsOffset=Vector3.new(0,6,0),AlwaysOnTop=true},p)
 local panel=UI.Panel(b,UDim2.fromScale(1,1),UDim2.new());panel.BackgroundColor3=UI.Theme.Primary
 local t=UI.Label(panel,'CHECKPOINT '..run.Step..'/6\n'..run.Name,UDim2.new(1,-12,1,-8),UDim2.fromOffset(6,4),16,UI.Theme.Surface);t.TextXAlignment=Enum.TextXAlignment.Center
end
return M
