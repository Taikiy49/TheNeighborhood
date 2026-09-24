local Space=require(game.ReplicatedStorage.Neighborhood.Shared.WorldSpace)
local Players=game:GetService("Players")
local Shared=game.ReplicatedStorage.Neighborhood.Shared
local Defs=require(Shared.AdventureDefinitions)
local Config=require(Shared.Config)
local Service={Jobs={},Markers={},Project=1,ProjectProgress=0,Contributors={},LastContribution={}}

local function part(parent,name,size,position,color)
 local p=Instance.new("Part");p.Name=name;p.Size=Space.Point(size);p.Position=Space.Point(position);p.Color=color
 p.Material=Enum.Material.Wood;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.Parent=parent;return p
end
local function sign(p,text)
 local gui=Instance.new("SurfaceGui");gui.Face=Enum.NormalId.Front;gui.CanvasSize=Vector2.new(360,180);gui.Parent=p
 local label=Instance.new("TextLabel");label.Size=UDim2.fromScale(1,1);label.BackgroundTransparency=1;label.Text=text;label.TextColor3=Color3.fromRGB(248,239,213);label.TextScaled=true;label.TextWrapped=true;label.Font=Enum.Font.GothamBold;label.Parent=gui
end
local function prompt(p,action,label)
 p:SetAttribute("Action",action)
 local q=Instance.new("ProximityPrompt");q.Style=Enum.ProximityPromptStyle.Custom;q.ActionText=label;q.ObjectText=p.Name;q.MaxActivationDistance=10;q:SetAttribute("Action",action);q.Parent=p
end
function Service:Build()
 local folder=Instance.new("Folder");folder.Name="MapleAdventures";folder.Parent=workspace.Neighborhood.Runtime;self.World=folder
 for id,landmark in pairs(Defs.Landmarks)do
  local post=part(folder,landmark.Name,Vector3.new(2.8,1.8,.35),landmark.Position+Vector3.new(0,1,0),Color3.fromRGB(45,83,72))
  post:SetAttribute("Landmark",id);sign(post,"MAPLE STORIES\n"..landmark.Name);prompt(post,"ReadRumor","Read rumor")
  local stem=part(folder,id.."Post",Vector3.new(.3,2,.3),landmark.Position-Vector3.new(0,.6,0),Color3.fromRGB(135,103,68));stem.CanQuery=false
  self.Markers[id]=post
 end
 self.Board=part(folder,"Maple Adventures",Vector3.new(5,3,.5),Vector3.new(18,3,-110),Color3.fromRGB(45,83,72))
 sign(self.Board,"MAPLE ADVENTURES\nStories • Shared projects");prompt(self.Board,"AdventureBoard","Choose an adventure")
 part(folder,"BoardPost",Vector3.new(.5,3,.5),Vector3.new(18,1,-110),Color3.fromRGB(135,103,68)).CanQuery=false
end
function Service:BuildProject(index)
 if self.World:FindFirstChild("Project"..index)then return end
 local model=Instance.new("Model");model.Name="Project"..index;model.Parent=self.World
 local wood=Color3.fromRGB(133,99,70);local cream=Color3.fromRGB(241,222,170)
 if index==1 then
  for _,x in ipairs({-12,12})do
   part(model,"RaisedBed",Vector3.new(6,.5,3),Vector3.new(x,.55,65),wood)
   for n=1,5 do
    local at=Vector3.new(x-3+n,1.4,65)
    part(model,"Stem",Vector3.new(.12,1,.12),at,Color3.fromRGB(76,119,67))
    local flower=part(model,"Flower",Vector3.new(.7,.4,.7),at+Vector3.new(0,.6,0),n%2==0 and Color3.fromRGB(225,170,147)or cream);flower.Shape=Enum.PartType.Ball
   end
  end
 elseif index==2 then
  part(model,"LibraryPost",Vector3.new(.5,3,.5),Vector3.new(-18,1.5,62),wood)
  part(model,"Bookcase",Vector3.new(3,2.2,1.4),Vector3.new(-18,3.5,62),wood)
  part(model,"DarkShelf",Vector3.new(2.6,1.6,.1),Vector3.new(-18,3.5,61.25),Color3.fromRGB(42,64,57))
  for n=1,7 do part(model,"Book",Vector3.new(.22,1+n%3*.15,.35),Vector3.new(-19.2+n*.3,3.4,61.1),n%2==0 and cream or Color3.fromRGB(151,174,137))end
  part(model,"LibraryRoof",Vector3.new(3.6,.35,2),Vector3.new(-18,4.8,62),Color3.fromRGB(48,83,72))
  local fascia=part(model,"LibrarySign",Vector3.new(3,.55,.15),Vector3.new(-18,4.45,61.12),Color3.fromRGB(48,83,72));sign(fascia,"MAPLE READS")
 else
  for _,x in ipairs({-18,18})do for _,z in ipairs({50,70})do
   part(model,"LanternPost",Vector3.new(.22,5,.22),Vector3.new(x,2.5,z),wood)
   local globe=part(model,"LanternGlass",Vector3.new(1,1.4,1),Vector3.new(x,5.3,z),cream);globe.Material=Enum.Material.Glass;globe.Transparency=.55
   local flame=part(model,"WarmCandle",Vector3.new(.25,.7,.25),Vector3.new(x,5.2,z),Color3.fromRGB(237,183,102));flame.Material=Enum.Material.Neon
   for _,height in ipairs({4.55,6.05})do part(model,"LanternCap",Vector3.new(1.25,.16,1.25),Vector3.new(x,height,z),Color3.fromRGB(45,71,61))end
   for _,dx in ipairs({-.48,.48})do for _,dz in ipairs({-.48,.48})do part(model,"LanternFrame",Vector3.new(.08,1.4,.08),Vector3.new(x+dx,5.3,z+dz),Color3.fromRGB(45,71,61))end end
   local light=Instance.new("PointLight");light.Color=Color3.fromRGB(255,214,152);light.Brightness=.8;light.Range=14;light.Parent=flame
  end end
 end
 -- Decorative details do not obstruct traversal or interaction raycasts.
 for _,p in ipairs(model:GetDescendants())do if p:IsA("BasePart")then p.CanQuery=false end end
end
function Service:Init(context)
 self.Context=context;self:Build()
 context.Interactions:Register("AdventureBoard",function(player)context.Open(player,"Adventures");return true end)
 context.Interactions:Register("ReadRumor",function(player,target)return self:Visit(player,target)end)
 local function added(player)player.CharacterRemoving:Connect(function()self:Pause(player)end)end
 Players.PlayerAdded:Connect(added);for _,p in ipairs(Players:GetPlayers())do added(p)end
 Players.PlayerRemoving:Connect(function(p)self.Jobs[p.UserId]=nil;self.LastContribution[p.UserId]=nil;self.Contributors[p.UserId]=nil end)
 task.spawn(function()while true do task.wait(.25);self:Step()end end)
end
function Service:Ready(player)
 if not self.Context.Data:CanAct(player)then return nil,"Your profile is loading or closing."end
 local char=player.Character;local root=char and char:FindFirstChild("HumanoidRootPart");local human=char and char:FindFirstChildOfClass("Humanoid")
 if not root or not human or human.Health<=0 then return nil,"Your character is not ready."end
 if human.SeatPart or player:GetAttribute("Carrying")or player:GetAttribute("DeliveryAddress")then return nil,"Explore on foot with your hands free."end
 return root
end
function Service:Pause(player)
 self.Jobs[player.UserId]=nil;player:SetAttribute("AdventureHint",nil)
end
function Service:Start(player,id,resume)
 local root,why=self:Ready(player);if not root then return false,why end
 local p=self.Context.Data:Get(player);local a=p.Adventures
 if self.Jobs[player.UserId]then return false,"Finish or pause your current story first."end
 if resume then id=a.Active and a.Active.Id end
 local route=type(id)=="string" and Defs.Routes[id]
 if not route then return false,"Choose a story from Maple Adventures."end
 if a.Active and not resume then return false,"Resume or abandon your saved story first."end
 a.Active=a.Active or {Id=id,Next=1}
 self.Jobs[player.UserId]={Started=os.clock(),LastTime=os.clock(),LastPosition=root.Position,Timed=not resume,Next=a.Active.Next}
 player:SetAttribute("AdventureHint",Defs.Landmarks[route.Stops[a.Active.Next]].Hint)
 return true,"Follow the clue in Phone → Adventures. Take as long as you like."
end
function Service:CheckTravel(player,job)
 local root,why=self:Ready(player);if not root then self:Pause(player);return false,why end
 local now=os.clock();local distance=(root.Position-job.LastPosition).Magnitude
 if distance~=distance or distance>26*math.min(now-job.LastTime,2)+10 then self:Pause(player);return false,"Story paused after an interrupted route. Resume from your phone."end
 job.LastPosition=root.Position;job.LastTime=now;return true
end
function Service:Step()
 for id,job in pairs(self.Jobs)do
  local p=Players:GetPlayerByUserId(id)
  if not p then self.Jobs[id]=nil else
   local ok,why=self:CheckTravel(p,job)
   if not ok then self.Context.Notify(p,why,false);self.Context.Sync(p)end
  end
 end
end
function Service:Visit(player,target)
 if typeof(target)~="Instance" or not target:IsA("BasePart")then return false,"Find a Maple Stories post."end
 local landmark=target:GetAttribute("Landmark")
 if not landmark or self.Markers[landmark]~=target then return false,"That is not a story post."end
 local job=self.Jobs[player.UserId];if not job then self.Context.Open(player,"Adventures");return false,"Choose or resume a rumor trail first."end
 local travelled,reason=self:CheckTravel(player,job);if not travelled then return false,reason end
 local valid,why=self.Context.Interactions:Validate(player,target);if not valid then return false,why end
 local p=self.Context.Data:Get(player);local a=p.Adventures;local active=a.Active;local route=active and Defs.Routes[active.Id]
 if not route or route.Stops[active.Next]~=landmark then return false,"This post belongs to another chapter. Follow your current clue."end
 local note=route.Notes[active.Next];active.Next+=1;job.Next=active.Next
 if active.Next<=#route.Stops then
  player:SetAttribute("AdventureHint",Defs.Landmarks[route.Stops[active.Next]].Hint)
  self.Context.Open(player,"Adventures");return true,note
 end
 local id=active.Id;local elapsed=math.max(1,math.floor((os.clock()-job.Started)*1000))
 local first=not a.Completed[id]
 a.Completed[id]=true;a.Runs[id]=math.min((a.Runs[id]or 0)+1,1000000)
 if job.Timed then a.BestMs[id]=math.min(a.BestMs[id]or elapsed,elapsed)end
 a.Active=nil;self:Pause(player)
 if first then p.Currency=math.min(p.Currency+90,1000000000);p.XP=math.min(p.XP+30,1000000000)end
 self.Context.Record(player,"Adventure")
 self.Context.Open(player,"Adventures")
 return true,note..(first and " Story stamp earned · $90 and 30 XP."or " Story revisited. Your album keeps the ending.")
end
function Service:Record(player,event)
 if event~="Adventure" and event~="Delivery" and event~="Discovery" and event~="CommunityEvent"then return end
 if not self.Context.Data:CanAct(player)then return end
 local now=os.clock();if now-(self.LastContribution[player.UserId]or -100)<2 then return end
 self.LastContribution[player.UserId]=now
 local a=self.Context.Data:Get(player).Adventures;a.Contributions=math.min(a.Contributions+1,1000000)
 if self.Project>#Defs.Projects then return end
 self.ProjectProgress+=1;self.Contributors[player.UserId]=true
 if self.ProjectProgress>=Defs.Projects[self.Project].Goal then
  local finished=self.Project;self:BuildProject(finished);self.Project+=1;self.ProjectProgress=0
  self.Context.Record(player,"ParkProject")
  for _,p in ipairs(Players:GetPlayers())do self.Context.Notify(p,Defs.Projects[finished].Title.." is complete! Visit the south end of Maple Green.",true)end
  self.Contributors={}
 end
 for _,p in ipairs(Players:GetPlayers())do self.Context.Sync(p)end
end
function Service:Claim(player,id)
 if not self.Context.Data:CanAct(player)then return false,"Your profile is unavailable."end
 local p=self.Context.Data:Get(player);local a=p.Adventures;local reward
 for _,r in ipairs(Defs.Rewards)do if r.Id==id then reward=r;break end end
 if not reward then return false,"Choose a trophy from your album."end
 if a.Rewards[id]then return false,"This trophy has already been claimed."end
 local count=a.Contributions;if reward.Kind=="Trails"then count=0;for _ in pairs(a.Completed)do count+=1 end end
 if count<reward.Target then return false,"Keep exploring and helping the neighborhood."end
 if #p.Inventory>=Config.MaxInventory then return false,"Free one inventory slot. Your earned trophy will wait."end
 if not self.Context.Items:Create(player,id)then return false,"Your trophy could not be created."end
 a.Rewards[id]=true;return true,"Your "..reward.Title.." is ready to display at home."
end
function Service:Action(player,action,id)
 if action=="Start"then return self:Start(player,id,false)
 elseif action=="Resume"then return self:Start(player,nil,true)
 elseif action=="Claim"then return self:Claim(player,id)
 elseif action=="Pause"or action=="Abandon"then
  if not self.Context.Data:CanAct(player)then return false,"Profile unavailable."end
  self:Pause(player);if action=="Abandon"then self.Context.Data:Get(player).Adventures.Active=nil end
  return true,action=="Pause"and "Chapter saved. Resume whenever you like."or "Story put away. Earned stamps are safe."
 end
 return false,"Unavailable adventure action."
end
function Service:View(player)
 local p=self.Context and self.Context.Data:Get(player);if not p then return {}end
 local a=p.Adventures;local routes={};local completed=0
 for _,id in ipairs(Defs.Order)do
  local d=Defs.Routes[id];if a.Completed[id]then completed+=1 end
  table.insert(routes,{Id=id,Title=d.Title,Completed=a.Completed[id]==true,BestMs=a.BestMs[id],Runs=a.Runs[id]or 0,Ending=a.Completed[id]and d.Notes[#d.Notes]or nil})
 end
 local active
 if a.Active then
  local d=Defs.Routes[a.Active.Id];active={Id=a.Active.Id,Title=d.Title,Next=a.Active.Next,Hint=Defs.Landmarks[d.Stops[a.Active.Next]].Hint,Note=a.Active.Next>1 and d.Notes[a.Active.Next-1]or nil,Paused=self.Jobs[player.UserId]==nil}
 end
 local rewards={};for _,r in ipairs(Defs.Rewards)do table.insert(rewards,{Id=r.Id,Title=r.Title,Count=r.Kind=="Trails"and completed or a.Contributions,Target=r.Target,Claimed=a.Rewards[r.Id]==true})end
 local project=Defs.Projects[self.Project]
 return {Routes=routes,Active=active,Completed=completed,Contributions=a.Contributions,Rewards=rewards,Project={Title=project and project.Title or "Maple Green is blooming",Description=project and project.Description or "All three shared projects are finished in this server. Your personal contributions and trophies stay saved.",Progress=self.ProjectProgress,Goal=project and project.Goal or 0,Completed=self.Project-1}}
end
return Service
