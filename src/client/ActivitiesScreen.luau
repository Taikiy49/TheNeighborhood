local M={}
local symbols={'LEAF','STAR','MOON','SUN'}
function M.Render(s)
 s.Title.Text='Always something to do'
 local a=s.State.Activities;if not a then s:Row('Getting ready','Your activity progress is loading.');return end
 s:Row(a.Rank,a.XP..' mastery XP | '..(a.NextRank<=a.XP and 'Highest rank reached' or 'Next rank: '..a.NextRank..' XP'))
 if a.Memory then
  local m=a.Memory;s:Row('Memory challenge - round '..m.Round..'/5',m.Showing and table.concat((function()local t={}for _,n in ipairs(m.Sequence or {})do table.insert(t,symbols[n])end return t end)(),'  >  ')or ('Repeat the sequence: '..m.Entered..' / '..m.Length..' symbols'))
  if not m.Showing then
   local UI=require(script.Parent.UI);s.RowIndex+=1
   local grid=UI.New('Frame',{Size=UDim2.new(1,-10,0,112),BackgroundTransparency=1,LayoutOrder=s.RowIndex},s.List)
   for i,name in ipairs(symbols)do UI.Button(grid,name,UDim2.new(.5,-4,0,48),UDim2.new((i-1)%2*.5,0,0,math.floor((i-1)/2)*56),function()s.Request('Activities','Answer',i)end)end
  end
 else s:Row('Memory challenge','Five rounds, from 3 to 7 symbols. Finish for $80 and mastery XP. Rewards every 90 seconds.','Play memory challenge',function()s.Request('Activities','Memory')end)end
 if a.Run then s:Row('Circuit: '..a.Run.Step..' / '..a.Run.Total,'Next: '..a.Run.Name..'. Close this panel and follow the floating marker on foot.')
 else s:Row('Neighborhood circuit','Six checkpoints; route changes every 10 minutes. Finish for $120 and mastery XP. Best: '..(a.BestMs>0 and string.format('%.1fs',a.BestMs/1000)or 'none yet'),'Start checkpoint run',function()s.Request('Activities','Circuit')end)end
 if a.Run or a.Memory then s:Row('Take a break','No penalty for cancelling.','Cancel challenge',function()s.Request('Activities','Cancel')end)end
 for _,g in ipairs(a.Goals)do s:Row(g.Name,math.min(g.Count,g.Target)..' / '..g.Target..' | $100 + 50 mastery XP | resets daily (UTC)',not g.Claimed and g.Count>=g.Target and 'Collect reward'or nil,function()s.Request('Activities','Claim',g.Id)end)end
 s:Row('Jobs and skill games','Deliver parcels from the community board; fish at Willow Lake; repair radios at the workshop; run the meadow trials. These count toward the work objective.')
 s:Row('Explore more','Gardening, crafting, home upgrades, mysteries, community events and story routes are on your phone.','Open neighborhood life',function()s:Open('Life')end)
end
function M.Update(state)
 if M.Marker then M.Marker:Destroy();M.Marker=nil end
 local run=state.Activities and state.Activities.Run;if not run then return end
 local p=Instance.new('Part');p.Name='MyCircuitCheckpoint';p.Anchored=true;p.CanCollide=false;p.CanQuery=false;p.CanTouch=false;p.Transparency=1;p.Size=Vector3.one;p.Position=Vector3.new(table.unpack(run.Position));p.Parent=workspace;M.Marker=p
 local b=Instance.new('BillboardGui');b.Size=UDim2.fromOffset(220,60);b.StudsOffset=Vector3.new(0,6,0);b.AlwaysOnTop=true;b.Parent=p
 local t=Instance.new('TextLabel');t.Size=UDim2.fromScale(1,1);t.BackgroundColor3=Color3.fromRGB(37,81,70);t.BackgroundTransparency=.15;t.TextColor3=Color3.fromRGB(250,237,199);t.Font=Enum.Font.GothamBold;t.TextSize=16;t.TextWrapped=true;t.Text='CHECKPOINT '..run.Step..'/6\n'..run.Name;t.Parent=b
end
return M
