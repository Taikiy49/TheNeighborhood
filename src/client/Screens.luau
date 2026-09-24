local UI=require(script.Parent.UI)
local Defs=require(game.ReplicatedStorage.Neighborhood.Shared.ItemDefinitions)
local Screens={State={Inventory={}}}
function Screens:Init(gui,request)
 self.Request=request
 self.Panel=UI.Panel(gui,UDim2.new(0.9,0,0.72,0),UDim2.fromScale(0.5,0.5));self.Panel.AnchorPoint=Vector2.new(0.5,0.5);self.Panel.Visible=false
 self.Panel.ZIndex=20
 self.Panel.Name="ScreensPanel"
 UI.New("UISizeConstraint",{MaxSize=Vector2.new(510,560)},self.Panel)
 self.Title=UI.Label(self.Panel,"",UDim2.new(1,-92,0,48),UDim2.fromOffset(16,8),UI.Theme.Title);self.Title.Font=UI.Theme.Display
 self.Title.TextScaled=true;UI.New("UITextSizeConstraint",{MinTextSize=14,MaxTextSize=24},self.Title)
 local close=UI.Button(self.Panel,"Close",UDim2.fromOffset(72,48),UDim2.new(1,-80,0,8),function()
  if self.CurrentView=="ChoosePlot"or self.CurrentView=="InviteFriends"then self:Open("Friends")else self:Close()end
 end);close.Name="CloseButton"
 game:GetService("UserInputService").InputBegan:Connect(function(input,processed)
  if not processed and self.Panel.Visible and (input.KeyCode==Enum.KeyCode.Escape or input.KeyCode==Enum.KeyCode.ButtonB) then self:Close() end
 end)
 self.Notice=UI.Panel(self.Panel,UDim2.new(1,-24,0,64),UDim2.fromOffset(12,64));self.Notice.Name="Notice";self.Notice.Visible=false
 self.NoticeText=UI.Label(self.Notice,"",UDim2.new(1,-16,1,-12),UDim2.fromOffset(8,6),14)
 self.List=UI.New("ScrollingFrame",{Size=UDim2.new(1,-24,1,-76),Position=UDim2.fromOffset(12,64),BackgroundTransparency=1,BorderSizePixel=0,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(),ScrollBarThickness=6,ScrollBarImageColor3=UI.Theme.Primary},self.Panel)
 UI.New("UIListLayout",{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder},self.List)
end
function Screens:ShowNotice(text,success)
 self.NoticeText.Text=text;self.NoticeText.TextColor3=success and UI.Theme.Text or UI.Theme.Danger
 self.Notice.Visible=true;self.List.Position=UDim2.fromOffset(12,136);self.List.Size=UDim2.new(1,-24,1,-148)
end
function Screens:ClearNotice()
 self.Notice.Visible=false;self.List.Position=UDim2.fromOffset(12,64);self.List.Size=UDim2.new(1,-24,1,-76)
end
function Screens:Close()
 self:ClearNotice()
 self:Resolve(false);self.Panel.Visible=false
 local navigation=game:GetService("GuiService")
 if navigation.SelectedObject and navigation.SelectedObject:IsDescendantOf(self.Panel) then navigation.SelectedObject=nil end
end
function Screens:Row(title,subtitle,action,callback)
 local row=UI.Panel(self.List,UDim2.new(1,-10,0,0),UDim2.new());row.AutomaticSize=Enum.AutomaticSize.Y
 self.RowIndex=(self.RowIndex or 0)+1;row.Name="Row"..self.RowIndex;row.LayoutOrder=self.RowIndex
 UI.New("UIPadding",{PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,8),PaddingTop=UDim.new(0,8),PaddingBottom=UDim.new(0,8)},row)
 UI.New("UIListLayout",{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder},row)
 local heading=UI.Label(row,title,UDim2.new(1,0,0,0),UDim2.new(),18);heading.AutomaticSize=Enum.AutomaticSize.Y;heading.LayoutOrder=1
 local body=UI.Label(row,subtitle,UDim2.new(1,0,0,0),UDim2.new(),14,UI.Theme.Muted);body.AutomaticSize=Enum.AutomaticSize.Y;body.LayoutOrder=2
 if action then
  local button
  button=UI.Button(row,action,UDim2.new(1,0,0,48),UDim2.new(),function()
   if self.Pending then return end
   self.Pending={Button=button,Text=action};button.Text="Working…";button.Active=false
   callback()
   task.delay(5,function()if self.Pending and self.Pending.Button==button then self:Resolve(false) end end)
  end)
  button.LayoutOrder=3
 end
end
function Screens:Resolve(success,requestId)
 if not self.Pending then return end
 if requestId and self.Pending.RequestId~=requestId then return end
 local pending=self.Pending;self.Pending=nil
 if pending.Button.Parent then pending.Button.Text=pending.Text;pending.Button.Active=true end
 if success and self.CurrentView=="BuildReview"then self:Open("Building");return end
 if success and self.CurrentView:sub(1,4)~="Life"and self.CurrentView~="Building"and self.CurrentView~="Crafting"and self.CurrentView~="Furnish"and self.CurrentView~="Layouts"and self.CurrentView~="Friends"and self.CurrentView~="InviteFriends"and self.CurrentView~="ChoosePlot"then self.Panel.Visible=false end
end
function Screens:Open(view,detail)
 self:Resolve(false)
 self.CurrentView=view;self.CurrentDetail=detail
 self.Panel.CloseButton.Text=(view=="ChoosePlot"or view=="InviteFriends")and "Back"or "Close"
 self.RowIndex=0
 for _,child in ipairs(self.List:GetChildren()) do if child:IsA("GuiObject") then child:Destroy() end end
 self.Title.Text=view=="Shop" and "Maple & Co." or view=="Pawn" and "Make a deal" or view=="Place" and "Make it yours" or view=="Item" and "A closer look" or view=="Cases" and "Your case files" or "Your inventory"
 local count=0
 if view:sub(1,4)=="Life"then require(script.Parent.LifeScreen).Render(self,view,detail)
 elseif view=="Building"or view=="BuildReview"or view=="Crafting"or view=="Furnish"or view=="Layouts"then require(script.Parent.BuildingScreen).Render(self,view,detail)
 elseif view=="Adventures" or view=="Projects"then require(script.Parent.AdventureScreen).Render(self,view)
 elseif view=="Boutique"then require(script.Parent.BoutiqueScreen).Render(self)
 elseif view=="Friends"or view=="InviteFriends"or view=="ChoosePlot"then
  require(script.Parent.FriendsScreen).Render(self,view,detail)
 elseif view=="Shop" then
  local ids={};for id,def in pairs(Defs) do if not def.DiscoverOnly then table.insert(ids,id)end end;table.sort(ids,function(a,b)return Defs[a].Value<Defs[b].Value end)
  for _,id in ipairs(ids) do local def=Defs[id];local price=math.floor(def.Value*(workspace.Neighborhood:GetAttribute("SaleMultiplier") or 1));self:Row(def.Name,def.Rarity.." • "..def.Description,"Buy · $"..price,function()self.Request("Buy",id)end) end
 elseif view=="Phone" then
  self.Title.Text="Your phone"
  self:Row("Room to grow","Expand your cottage, craft furniture and save favorite layouts.","Plan your home",function()self:Open("Building")end)
  self:Row("Neighborhood Life","Gardening, businesses, shared renovations, mysteries, tours, mastery and festivals.","Explore activities",function()self:Open("Life")end)
  self:Row("Maple Adventures","Six rumors, a story album, earned trophies and shared park projects.","Follow a rumor",function()self:Open("Adventures")end)
  self:Row("Style Boutique","Optional permanent home-style packs for Robux.","Browse styles",function()self:Open("Boutique")end)
  self:Row("Friends","Party up, move together and return to your saved neighborhood.","Open Friends",function()self:Open("Friends")end)
  for _,entry in ipairs({{"Progress","Settle in and earn achievements"},{"Home","Colors, flooring, security and permissions"},{"Garage","Your keys to Maple Street"},{"Pets","A companion with a nose for visitors"},{"Event","Community activities and rewards"},{"Journal","Five tiny notes. One very unusual gnome."},{"Weather","What's blowing through Maple Street"},{"Collection","Remember every possession you've acquired"},{"Neighbors","See who lives nearby"},{"Newspaper","Read real neighborhood stories"},{"Settings","Audio and motion preferences"},{"Cases","Review evidence and investigate"}})do self:Row(entry[1],entry[2],"Open",function()self:Open(entry[1])end)end
 elseif view=="Journal" then
  self.Title.Text="The gnome trail"
  local trail=self.State.Discoveries or {};local found=0
  for _,clue in ipairs(trail.Entries or {})do if clue.Found then found+=1 end;self:Row(clue.Title,(clue.Found and "Found · " or "Clue · ")..clue.Hint)end
  self:Row("Moonlight Gnome",trail.Claimed and "Reward claimed. Your collection remembers, even if you sell it." or found.." / 5 notes found. Your progress is saved.",not trail.Claimed and found==5 and "Claim collectible" or nil,function()self.Request("ClaimDiscovery","")end)
 elseif view=="Weather" then
  self.Title.Text="Maple forecast"
  local weather=self.State.Weather or {Title="Looking outside…",Description="Forecast loading."}
  self:Row(weather.Title,weather.Description)
  self:Row("A roof over your head","Raindrops disappear under shelter. Reduced motion hides falling rain while keeping the change in lighting.")
 elseif view=="Event" then
  self.Title.Text="Community notice"
  local event=self.State.CommunityEvent or {Title="Quiet on Maple Street",Description="Watch this space."}
  self:Row(event.Title,event.Description)
  if event.Kind=="BlockParty"then for _,neighbor in ipairs(self.State.Neighbors or {})do self:Row(neighbor.Name,"Meet within arm's reach in Maple Green. Both players must offer the high-five.","Offer / return high-five",function()self.Request("Event","HighFive",neighbor.UserId)end)end
  elseif event.Kind=="WatchNight"then for _,house in ipairs(self.State.Patrol or {})do self:Row(house.Address,"Stand beside this mailbox to check it.","Check mailbox",function()self.Request("Event","Watch",house.Id)end)end end
 elseif view=="Pets" then
  self.Title.Text="Your companion"
  local pet=self.State.Pets or {}
  if not pet.Dog then self:Row("Meet Biscuit","A dog who follows paths, stays in your yard and notices unexpected visitors. No stat multipliers.","Adopt · $600",function()self.Request("Pet","Adopt")end)
  else
   self:Row("Biscuit",pet.Mode=="Stay" and "Watching the yard" or "Following you","Follow me",function()self.Request("Pet","Follow")end)
   self:Row("A nose for neighbors","Visitors near your front door may catch Biscuit's attention. A bark is a lead, not proof of guilt.","Stay at home",function()self.Request("Pet","Stay")end)
  end
 elseif view=="Garage" then
  self.Title.Text="Your garage"
  local vehicle=self.State.Vehicles or {}
  if not vehicle.Compact then self:Row("Maple Compact","A cheerful little runabout. Native movement controls steer it; jump to get out.","Buy · $2400",function()self.Request("Vehicle","Buy")end)
  else
   self:Row("Maple Compact",vehicle.Plate or "Your car","Recall to driveway",function()self.Request("Vehicle","Recall")end)
   for _,color in ipairs({"Mint","Peach","Blue","Butter"})do self:Row(color,"Included paint finish","Apply paint",function()self.Request("Vehicle","Color",color)end)end
  end
 elseif view=="Newspaper" then
  self.Title.Text="Neighborhood Times"
  for _,story in ipairs(self.State.Feed or {})do count+=1;self:Row(story.Title,story.Text.." · "..os.date("!%H:%M UTC",story.Time))end
  if count==0 then self:Row("QUIET ON MAPLE STREET","No headlines yet. This newspaper reports actual neighborhood activity.")end
 elseif view=="Survey" then
  self.Title.Text=detail.Name
  for _,line in ipairs(detail.Lines)do self:Row(line[1],line[2])end
 elseif view=="Guide" then
  self.Title.Text=detail.Name
  for _,line in ipairs(detail.Lines)do self:Row(line[1],line[2])end
  self:Row("Your next steps","Your phone keeps a checklist, collection book and case files.","Open progress",function()self:Open("Progress")end)
 elseif view=="Home" then
  self.Title.Text="Your home"
  self:Row("Room to grow","Garden room, upstairs loft, garage and backyard workshop.","View expansion plans",function()self:Open("Building")end)
  local house=self.State.House or {}
  for _,color in ipairs({"Mint","Peach","Blue","Butter"})do local unlocked=house.UnlockedColors and house.UnlockedColors[color];self:Row(color.." exterior",house.Color==color and "Currently selected" or "A fresh look for your house",unlocked and "Apply paint" or "Unlock · $150",function()self.Request("Customize","Color",color)end)end
  for _,floor in ipairs({{"Wood",0},{"Tile",250},{"Carpet",200}})do local unlocked=house.UnlockedFloors and house.UnlockedFloors[floor[1]];self:Row(floor[1].." floor","Unlocked finishes can be reused.",unlocked and "Apply flooring" or "Unlock · $"..floor[2],function()self.Request("Customize","Floor",floor[1])end)end
  local level=house.SecurityLevel or 0
  self:Row("Front-door security","Level "..level.." · Each upgrade adds two seconds to lock tampering.",level<2 and "Upgrade · $"..((level+1)*350) or nil,function()self.Request("Customize","Security","")end)
  self:Row("House access","Friends may open the locked door. Roommates may also change the lock. Neither owns your possessions.","Manage permissions",function()self:Open("Permissions")end)
 elseif view=="Permissions" then
  self.Title.Text="House permissions"
  for _,neighbor in ipairs(self.State.Neighbors or {})do
   count+=1;local role=self.State.House and self.State.House.Permissions and self.State.House.Permissions[tostring(neighbor.UserId)] or "Visitor"
   for _,nextRole in ipairs({"Friend","Roommate","Visitor"})do self:Row(neighbor.Name,"Current access: "..role,"Set "..nextRole,function()self.Request("Permission",tostring(neighbor.UserId),nextRole)end)end
  end
  if count==0 then self:Row("No neighbors connected","Permissions can be granted when another player joins.")end
 elseif view=="Progress" then
  self.Title.Text="Make yourself at home"
  local delivery=game.Players.LocalPlayer:GetAttribute("DeliveryAddress")
  if delivery then self:Row("Parcel for "..delivery,"Carry the box to the matching mailbox. Cancelling returns it to the depot without a reward.","Cancel delivery",function()self.Request("CancelDelivery","")end)end
  local progress=self.State.Progress or {}
  self:Row("Level "..(progress.Level or 1),(progress.XP or 0).." XP · Reputation "..(progress.Reputation or 0))
  for _,step in ipairs(progress.Checklist or {})do self:Row(step.Done and "Complete" or "Next to try",step.Text)end
  for _,badge in ipairs(progress.Achievements or {})do self:Row(badge.Title,badge.Earned and "Achievement earned" or badge.Progress.." / "..badge.Target)end
 elseif view=="Collection" then
  self.Title.Text="Collection book"
  local owned={};for _,item in ipairs(self.State.Inventory or {})do owned[item.DefinitionId]=true end
  local ids={};for id in pairs(Defs)do table.insert(ids,id)end;table.sort(ids)
  for _,id in ipairs(ids)do local def=Defs[id];local collected=self.State.Collection and self.State.Collection[id]~=nil;self:Row(def.Name,def.Rarity.." · "..(owned[id] and "Owned" or collected and "Previously collected" or "Not discovered").." · "..def.Description)end
 elseif view=="Neighbors" or view=="Accuse" then
  self.Title.Text=view=="Accuse" and "Compare the evidence" or "Your neighbors"
  for _,neighbor in ipairs(self.State.Neighbors or {})do count+=1;self:Row(neighbor.Name,neighbor.Address.." · "..(neighbor.KnownFor or "Settling in").." · Display and security value $"..(neighbor.HouseValue or 0),view=="Accuse" and "Submit accusation" or nil,function()self.Request("Accuse",detail,neighbor.UserId)end)end
  if view=="Neighbors"then for _,neighbor in ipairs(self.State.Neighbors or {})do if neighbor.HouseId then self:Row("Visit "..neighbor.Name,"Stand at their front door to leave temporary flamingos. New neighbors and opted-out homes are protected.","Harmless prank · $50",function()self.Request("Prank",neighbor.HouseId)end)end end end
  if view=="Neighbors" then for _,neighbor in ipairs(self.State.Neighbors or {})do if neighbor.HouseId then self:Row("Look around "..neighbor.Address,"Observe from nearby. Only possessions and security in your line of sight are revealed.","Survey from here",function()self.Request("Survey",neighbor.HouseId)end)end end end
  if count==0 then self:Row("A quiet street","No other neighbors are connected right now.")end
 elseif view=="Settings" then
  self.Title.Text="Your preferences"
  for _,setting in ipairs({{"Sound","Feedback audio"},{"ReducedMotion","Reduced motion"},{"Pranks","Allow harmless yard pranks"}})do local enabled=self.State.Settings and self.State.Settings[setting[1]];self:Row(setting[2],enabled and "On" or "Off",enabled and "Turn off" or "Turn on",function()self.Request("Setting",setting[1],not enabled)end)end
 elseif view=="Recap" then
  self.Title.Text="Welcome back"
  self:Row("While you were away",detail.Message)
  for _,incident in ipairs(detail.Incidents or {})do if incident.Status~="Recovered" then self:Row("Existing case: "..incident.ItemName,incident.Status.." · Open Cases to continue investigating.")end end
 elseif view=="Breach" then
  self.Title.Text="A locked door"
  self:Row("The lock will take time","Stay beside the door for 4–8 seconds, depending on its security. The homeowner will be warned.","Tamper with lock",function()self.Request("Breach",detail)end)
  self:Row("Prefer a friendly visit?","Close this panel and ring the doorbell. Moving-in protection prevents break-ins.")
 elseif view=="Item" then
  local def=Defs[detail.DefinitionId]
  local recover=detail.State=="Carried" or detail.State=="Escaped" or detail.State=="Dropped"
  local resume=detail.HeldByYou and detail.State=="Dropped"
  local action=detail.Owned and (recover and "Recover your possession" or "Put in protected inventory") or "Steal · triggers display alarm"
  self:Row(def.Name,def.Rarity.." • "..def.Weight.." kg • $"..def.Value,resume and "Pick it back up" or action,function()self.Request(resume and "Resume" or detail.Owned and (recover and "Recover" or "Store") or "Steal",detail.Id)end)
  if not detail.Owned then self:Row("Know the risk","Stay beside it to lift. Cameras may see you. Heavy items slow you down.") end
 elseif view=="Cases" then
  for _,incident in ipairs(self.State.Incidents or {}) do
   count+=1
   self:Row(incident.ItemName,incident.Status.." • "..os.date("!%H:%M UTC",incident.Time),incident.Status=="Missing" and "Open case" or nil,function()self.Request("Case",incident.Id)end)
   for _,evidence in ipairs(incident.Evidence) do self:Row(evidence.Kind,evidence.Quality.." · "..evidence.Description) end
   for _,event in ipairs(incident.Timeline or {}) do self:Row(event.Status.." · "..os.date("!%H:%M UTC",event.Time),event.Description) end
   if incident.Status=="Missing" or incident.Status=="Investigating" or incident.Status=="Fenced"then self:Row("Compare your clues","Accusations are checked against recorded evidence. Unsupported accusations reduce reputation.","Choose a suspect",function()self:Open("Accuse",incident.Id)end)end
  end
  if count==0 then self:Row("Quiet on Maple Street","No incidents recorded. Your protected inventory is safe; displayed items may attract attention.") end
 elseif view=="Place" or view=="Pawn" or view=="Inventory" then
  if view=="Pawn" and self.State.Carrying then self:Row(self.State.Carrying,"Found it? Of course you did.","Fence carried item",function()self.Request("Fence","")end) end
  for _,item in ipairs(self.State.Inventory or {}) do
   if view=="Pawn" and item.State=="Fenced" then
    count+=1;self:Row(Defs[item.DefinitionId].Name,"Matches your missing-property record. Reclaim the original item.","Reclaim your property",function()self.Request("Reclaim",item.Id)end)
   elseif item.State=="Stored" or view=="Inventory" then
    count+=1;local def=Defs[item.DefinitionId]
    local action=view=="Place" and "Place here" or view=="Pawn" and "Sell · $"..math.floor(def.Value*0.4) or nil
    self:Row(def.Name,def.Rarity.." • "..item.State,action,function()self.Request(view=="Place" and "Place" or "Sell",item.Id,detail)end)
   end
  end
  if count==0 then self:Row("Nothing stored yet","Buy something at Maple & Co., or put a displayed item back in your inventory.") end
 end
 self.List.CanvasPosition=Vector2.zero;self.Panel.Visible=true
 if game:GetService("UserInputService"):GetLastInputType()==Enum.UserInputType.Gamepad1 then game:GetService("GuiService").SelectedObject=self.Panel.CloseButton end
end
return Screens
