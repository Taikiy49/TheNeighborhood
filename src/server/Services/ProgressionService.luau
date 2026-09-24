local Service={Last={}}
local steps={{Key="EnterHouse",Text="Open your front door"},{Key="Place",Text="Place one possession at home"},{Key="Visit",Text="Say hello to a neighbor"},{Key="Delivery",Text="Complete a parcel delivery from the community board"},{Key="Buy",Text="Buy something at Maple & Co."},{Key="Lock",Text="Lock your front door"}}
local achievements={
 {Id="WelcomeHome",Event="Place",Count=1,Title="This one's mine"},
 {Id="HonestWork",Event="Delivery",Count=5,Title="Honest work"},
 {Id="Collector",Event="Buy",Count=10,Title="Shelf space problem"},
 {Id="Detective",Event="Solved",Count=1,Title="Case closed"},
 {Id="Recovery",Event="Recovery",Count=1,Title="Back where it belongs"},
 {Id="GoldenGetaway",Event="GoldenEscape",Count=1,Title="Royal relocation"},
 {Id="GnomeTrail",Event="TrailComplete",Count=1,Title="Gnome where to look"},
 {Id="CommunitySpirit",Event="CommunityEvent",Count=3,Title="Part of the neighborhood"},
}
function Service:Init(context)self.Context=context;game.Players.PlayerRemoving:Connect(function(p)self.Last[p.UserId]=nil end)end
function Service:Record(player,event)
 local p=self.Context.Data:Get(player);if not p then return end
 self.Last[player.UserId]=self.Last[player.UserId] or {};local last=self.Last[player.UserId]
 if (event=="EnterHouse" or event=="Lock" or event=="Visit") and p.Statistics[event]then return end
 if os.clock()-(last[event] or -100)<2 then return end;last[event]=os.clock()
 p.Statistics[event]=(p.Statistics[event] or 0)+1;p.XP+=5
 for _,a in ipairs(achievements)do if a.Event==event and p.Statistics[event]>=a.Count and not p.Achievements[a.Id]then p.Achievements[a.Id]=os.time();p.XP+=25;self.Context.Notify(player,"Achievement: "..a.Title,true)end end
 for _,step in ipairs(steps)do if not p.Statistics[step.Key]then p.TutorialState=step.Key;return end end
 if p.TutorialState~="Done"then p.TutorialState="Done";p.XP+=50;self.Context.Notify(player,"You're settled in. Make the neighborhood your own.",true)end
end
function Service:View(player)
 local p=self.Context.Data:Get(player);if not p then return {}end
 local checklist={};for _,step in ipairs(steps)do table.insert(checklist,{Key=step.Key,Text=step.Text,Done=(p.Statistics[step.Key] or 0)>0})end
 local badges={};for _,a in ipairs(achievements)do table.insert(badges,{Title=a.Title,Earned=p.Achievements[a.Id]~=nil,Progress=math.min(p.Statistics[a.Event] or 0,a.Count),Target=a.Count})end
 return {XP=p.XP,Level=1+math.floor(p.XP/100),Reputation=p.Reputation,Checklist=checklist,Achievements=badges}
end
return Service
