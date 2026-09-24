-- Called only by the opt-in Studio UI acceptance suite.
return function(s)
 assert(game:GetService('RunService'):IsStudio())
 local G=require(script.Parent.TaskGuide);local H=require(script.Parent.GoalHUD)
 local UI=require(script.Parent.UI);local reports={};local original=s.State;local size=s.Panel.Size
 local fixtures={
  {Name='Loading',State={}},
  {Name='First visit',State={Progress={Checklist={{Key='EnterHouse',Text='Open your door',Done=false}}},Activities={Rank='New Neighbor',XP=0,Goals={{Id='Work',Name='Work',Count=0,Target=3}}}}},
  {Name='Reward ready',State={Progress={Checklist={{Key='EnterHouse',Done=true}}},Activities={Rank='Street Explorer',XP=250,Goals={{Id='Work',Name='Work',Count=3,Target=3}}}}},
  {Name='All done',State={Progress={Checklist={{Key='EnterHouse',Done=true}}},Activities={Rank='Maple Legend',XP=900,Goals={{Id='Work',Name='Work',Count=3,Target=3,Claimed=true}}}}},
  {Name='Memory watch',State={Activities={Memory={Round=5,Entered=0,Length=7,Showing=true,Sequence={1,2,3,4,1,2,3}}}}},
  {Name='Memory answer',State={Activities={Memory={Round=5,Entered=6,Length=7,Showing=false}}}},
  {Name='Running',State={Activities={Run={Name='Lakeside junction',Position={-75,3,60},Step=4,Total=6}}}},
 }
 G.Selected=nil
 assert(G:Pick({},{}).Loading,'Unknown progress displayed as complete')
 assert(G:Pick(fixtures[3].State,{}).Button=='Collect reward','Earned reward not surfaced')
 assert(G:Pick(fixtures[4].State,{}).Title=='Pick something fun','Completed goals still demanded')
 assert(G:Pick(fixtures[2].State,{DeliveryAddress='101 Maple Street'}).Key=='Mailbox','Active delivery lost priority')
 assert(G:Pick(fixtures[2].State,{CityWorkKind='Pizza',CityWorkStep=2,CityWorkReadyAt=workspace:GetServerTimeNow()+3}).Count==1,'Job step bar is inaccurate')
 for _,width in ipairs({510,360})do
  s.Panel.Size=UDim2.fromOffset(width,480)
  for _,fixture in ipairs(fixtures)do for _,tab in ipairs({'Tasks','Play','Jobs'})do
   s.State=fixture.State;s:Open('Activities',tab);task.wait(.08)
   for _,v in ipairs(s.List:GetDescendants())do
    if v:IsA('TextLabel')then assert(v.TextFits,'Goal text clips: '..fixture.Name..' '..tab..' '..v.Text)end
    if v:IsA('TextButton')then assert(v.AbsoluteSize.Y>=48,'Small goal action')end
    if v.Name=='Fill'and v:IsA('Frame')then assert(v.Size.X.Scale>=0 and v.Size.X.Scale<=1,'Progress bar overflow')end
   end
   table.insert(reports,fixture.Name..'/'..tab..'/'..width)
  end end
 end
 s.State=original;s:Close()
 for _,v in ipairs({Vector2.new(390,844),Vector2.new(854,393),Vector2.new(640,360),Vector2.new(1280,720)})do
  H:Layout(v.X,v.Y);local card=H.Card
  assert(card.Position.X.Offset>=0 and card.Position.Y.Offset>=0,'Task card origin offscreen')
  assert(card.Position.X.Offset+card.Size.X.Offset<=v.X and card.Position.Y.Offset+card.Size.Y.Offset<=v.Y,'Task card offscreen')
  H:Update();task.wait(.05);assert(H.Title.TextFits and H.Hint.TextFits,'HUD text clips')
  assert(H.Action.AbsoluteSize.Y>=48,'Task action too small')
  table.insert(reports,'HUD '..v.X..'x'..v.Y)
 end
 H:Layout(workspace.CurrentCamera.ViewportSize.X,workspace.CurrentCamera.ViewportSize.Y)
 s.Panel.Size=size;s.State=original
 return reports
end
