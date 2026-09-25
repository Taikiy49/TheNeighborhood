local Service={Last={}}
local Levels=require(game.ReplicatedStorage.Neighborhood.Shared.VehicleCatalog)
local steps={{Key="EnterHouse",Text="Open your front door"},{Key="CityWork",Text="Finish your first paid shift"},{Key="Buy",Text="Buy furniture with your earnings"},{Key="Place",Text="Decorate your home"},{Key="Visit",Text="Say hello to a neighbor"}}
local achievements={
 {Id="WelcomeHome",Event="Place",Count=1,Title="This one's mine"},
 {Id="HonestWork",Event="Delivery",Count=5,Title="Honest work"},
 {Id="Collector",Event="Buy",Count=10,Title="Shelf space problem"},
 {Id="GnomeTrail",Event="TrailComplete",Count=1,Title="Gnome where to look"},
 {Id="CommunitySpirit",Event="CommunityEvent",Count=3,Title="Part of the neighborhood"},
}
function Service:Init(context)self.Context=context;game.Players.PlayerRemoving:Connect(function(p)self.Last[p.UserId]=nil end)end
function Service:Record(player,event)
 local p=self.Context.Data:Get(player);if not p then return end
 self.Last[player.UserId]=self.Last[player.UserId] or {};local last=self.Last[player.UserId]
 if (event=="EnterHouse" or event=="Lock" or event=="Visit") and p.Statistics[event]then return end
 if os.clock()-(last[event] or -100)<2 then return end;last[event]=os.clock()
 p.Statistics[event]=(p.Statistics[event] or 0)+1
 local repeatWork=event=='CityWork'or event=='Delivery'or event=='Trial'or event=='CommunityEvent'
 if repeatWork then if os.clock()-(last.RewardXP or -100)>20 then p.XP=math.min(1000000000,p.XP+15);last.RewardXP=os.clock()end
 elseif p.Statistics[event]==1 then p.XP=math.min(1000000000,p.XP+10)end
 for _,a in ipairs(achievements)do if a.Event==event and p.Statistics[event]>=a.Count and not p.Achievements[a.Id]then p.Achievements[a.Id]=os.time();p.XP+=25;self.Context.Notify(player,"Achievement: "..a.Title,true)end end
 for _,step in ipairs(steps)do if not p.Statistics[step.Key]then p.TutorialState=step.Key;return end end
 if p.TutorialState~="Done"then p.TutorialState="Done";p.XP+=50;self.Context.Notify(player,"You're settled in. Make the neighborhood your own.",true)end
end
function Service:View(player)
 local p=self.Context.Data:Get(player);if not p then return {}end
 local checklist={};for _,step in ipairs(steps)do table.insert(checklist,{Key=step.Key,Text=step.Text,Done=(p.Statistics[step.Key] or 0)>0})end
 local badges={};for _,a in ipairs(achievements)do table.insert(badges,{Title=a.Title,Earned=p.Achievements[a.Id]~=nil,Progress=math.min(p.Statistics[a.Event] or 0,a.Count),Target=a.Count})end
 local level=Levels.Level(p.XP);local base=50*(level-1)^2;local nextXP=50*level^2-base
 local title=level>=50 and 'Coast Icon'or level>=30 and 'Coast Legend'or level>=20 and 'Master Builder'or level>=10 and 'Town Regular'or level>=5 and 'Good Neighbor'or 'New Resident'
 player:SetAttribute('EarnedTitle',title);player:SetAttribute('EarnedLevel',level)
 return {XP=p.XP,Level=level,Title=title,LevelXP=p.XP-base,NextLevelXP=nextXP,Reputation=p.Reputation,Checklist=checklist,Achievements=badges}
end
return Service
