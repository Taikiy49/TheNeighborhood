-- Presentation only: counts, rewards and completed steps remain server-owned.
local UI=require(script.Parent.UI)
local G={Selected=nil}
G.Steps={
 CityWork={'Earn your first paycheck','Follow the marker. Order, prepare, then box a pizza.','Job:Pizza'},
 EnterHouse={'Open your front door','Your home is your starting point. Jobs earn cash for upgrades.','Door'},
 Place={'Decorate your home','Walk to a display spot. Choose an item.','Place'},
 Visit={'Say hello to a neighbor','Greet an NPC or ring a player’s doorbell.','Visit'},
 Delivery={'Deliver a parcel','Get a box from the park board.','Delivery'},
 Buy={'Visit the furniture shop','Walk to Maple & Co. Choose something you can afford.','Shop'},
 Lock={'Lock your home','Use the lock beside your front door.','Lock'},
}
G.Jobs={
 {Id='Pizza',Title='Make a pizza',Hint='Order → prepare → box',Reward='$45',Position=Vector3.new(-28,4,116)},
 {Id='Laundry',Title='Wash and fold',Hint='Sort → wash → fold',Reward='$45',Position=Vector3.new(11,3,107)},
 {Id='Hotel',Title='Help at the hotel',Hint='Reception → room 201 → room 301',Reward='$65',Position=Vector3.new(26,4,-122)},
 {Id='Rooftops',Title='Explore the rooftops',Hint='Courtyard → climb → check both roofs',Reward='$65',Position=Vector3.new(-232,2,-96)},
 {Id='Delivery',Title='Deliver a parcel',Hint='Park board → matching mailbox',Reward='Earn cash',Position=Vector3.new(18,5,-73)},
}
local stationNames={Pizza={'Read the order','Prepare the pizza','Box the pizza'},Laundry={'Sort the clothes','Use the washer','Fold the clothes'},Hotel={'Visit reception','Tidy room 201','Tidy room 301'},Rooftops={'Start in the courtyard','Check the first roof','Check the second roof'}}
function G:Track(id)self.Selected=id;self.MarkerKey=nil end
-- Targets use the same price definitions as server purchases; no new currency or rewards.
function G:Savings(state)
 local shared=game.ReplicatedStorage.Neighborhood.Shared
 local catalog=require(shared.VehicleCatalog);local homes=require(shared.ResidenceDefinitions)
 local cash=math.max(0,state.Currency or 0)
 if not catalog.Owned(state.Vehicles or {},'Bicycle')then
  local price=catalog.Items.Bicycle.Price
  return {Title='Your first bicycle',Hint=cash>=price and 'You have enough! Visit Coast Motors.'or 'Finish paid jobs to buy your own ride.',Count=math.min(cash,price),Total=price,ProgressLabel='$'..cash..' / $'..price,View=cash>=price and 'Garage'or 'Activities',Detail='Jobs',Button=cash>=price and 'See bicycle'or 'Find a paid job'}
 end
 local residence=state.Residence or {Tier=1,Renovations=0,Work=0,ProjectWork=0}
 local nextHome=homes.Tiers[residence.Tier+1];local project=nextHome or homes.Project(residence)
 local work=nextHome and (residence.Work or 0)or (residence.ProjectWork or 0)
 return {Title=nextHome and nextHome.Name or 'Your next renovation',Hint=math.min(work,project.Work)..' / '..project.Work..' jobs finished. Earn, save, then upgrade.',Count=math.min(cash,project.Price),Total=project.Price,ProgressLabel='$'..cash..' / $'..project.Price,View='Residence',Button='See home plans'}
end
function G:Pick(state,attributes)
 local a=state.Activities or {};local p=state.Progress
 if self.PreviousJob and not attributes.CityWorkKind then self.Selected=nil end
 self.PreviousJob=attributes.CityWorkKind

 if attributes.DeliveryAddress then return {Title='Deliver this box',Hint=attributes.DeliveryAddress..' • use the mailbox',Key='Mailbox',Button='Show me'}end
 if attributes.CityWorkKind then
  local names=stationNames[attributes.CityWorkKind];local step=attributes.CityWorkStep or 2
  local seconds=math.max(0,math.ceil((attributes.CityWorkReadyAt or 0)-workspace:GetServerTimeNow()))
  return {Title=names and names[step]or 'Finish your shift',Hint=seconds>0 and 'Getting ready… '..seconds..' seconds' or 'Ready! Walk to the marked station.',Key='CityWork',Position=attributes.CityWorkPosition,Count=step-1,Total=3,Button='Show me'}
 end
 if a.Memory then return {Title='Memory game • round '..a.Memory.Round,Hint=a.Memory.Showing and 'Watch the shapes. Remember their order.'or 'Tap the shapes in the same order.',Count=a.Memory.Round-1,Total=5,View='Activities',Detail='Play',Button='Play'}end
 if a.Run then return {Title='Reach the next checkpoint',Hint=a.Run.Name,Count=a.Run.Step-1,Total=a.Run.Total,Position=Vector3.new(table.unpack(a.Run.Position)),Key='Circuit',Button='Show me'}end
 if not p then return {Title='Getting your home ready…',Hint='Your goals will appear here.',Count=0,Total=1,Button='Please wait',Loading=true}end
 if self.Selected=='Housing'then return {Title='Visit Avery',Hint='Home upgrades in the hotel lobby.',Position=Vector3.new(12,3,-112),Key='HousingDesk',Button='Show me'}end
 if self.Selected then for _,job in ipairs(self.Jobs)do if job.Id==self.Selected then return {Title=job.Title,Hint=job.Hint,Position=job.Position,Key='Job:'..job.Id,Button='Show me'}end end end
 local complete=0;local nextStep
 for _,step in ipairs(p.Checklist or {})do if step.Done then complete+=1 elseif not nextStep then nextStep=step end end
 if nextStep then local guide=self.Steps[nextStep.Key];return {Title=guide and guide[1]or nextStep.Text,Hint=guide and guide[2]or 'Open Goals for help.',Key=guide and guide[3],Count=complete,Total=#p.Checklist,Button='Show me'}end
 for _,goal in ipairs(a.Goals or {})do if not goal.Claimed and goal.Count>=goal.Target then return {Title='Your reward is ready!',Hint='Open Goals to collect it.',Count=goal.Target,Total=goal.Target,View='Activities',Detail='Tasks',Button='Collect reward'}end end
 if state.Residence then return self:Savings(state)end
 return {Title='Pick something fun',Hint='Try a game, a job or a daily task.',View='Activities',Detail='Play',Button='Choose a game'}
end
function G:Attributes(player)
 local a={};for _,k in ipairs({'Carrying','DeliveryAddress','CityWorkKind','CityWorkStep','CityWorkReadyAt','CityWorkPosition'})do a[k]=player:GetAttribute(k)end;return a
end
function G:Position(task,state,player)
 local district=workspace:FindFirstChild('Neighborhood')
 if district and task.Key then local attribute=task.Key=='HousingDesk'and 'HousingDesk'or task.Key:match('^Job:(.+)$');if attribute then local pos=district:GetAttribute(attribute=='HousingDesk'and attribute or 'Job'..attribute);if pos then return pos end end end
 if task.Position then return task.Position end
 local w=workspace:FindFirstChild('Neighborhood');if not w then return end
 local h=w.Houses:FindFirstChild(state.HouseId or '')
 local key=task.Key;local target
 if key=='Door'or key=='Lock'then target=h and h:FindFirstChild(key)
 elseif key=='Place'then
  local used={};for _,item in ipairs(state.Inventory or {})do if item.State=='Displayed'and item.Slot then used[item.Slot]=true end end
  if h and h:FindFirstChild('DisplaySlots')then for i=1,12 do if not used[i]then target=h.DisplaySlots:FindFirstChild('Slot'..i);if target then break end end end end
 elseif key=='Visit'then
  for _,neighbor in ipairs(state.Neighbors or {})do local house=w.Houses:FindFirstChild(neighbor.HouseId or '');if house then target=house:FindFirstChild('Doorbell');if target then break end end end
  if not target then local residents=w.Runtime:FindFirstChild('ResidentNeighbors');if residents then for _,npc in ipairs(residents:GetChildren())do target=npc:FindFirstChild('Torso');if target then break end end end end
 elseif key=='Mailbox'then for _,house in ipairs(w.Houses:GetChildren())do if house:GetAttribute('Address')==player:GetAttribute('DeliveryAddress')then target=house:FindFirstChild('Mailbox')and house.Mailbox:FindFirstChild('Box');break end end
 elseif key=='Delivery'then target=w.Map:FindFirstChild('CommunityBoard')
 elseif key=='Shop'then target=w.Shops:FindFirstChild('GeneralStore');target=target and target:FindFirstChild('Counter')
 elseif key=='Pawn'then target=w.Shops:FindFirstChild('PawnShop');target=target and target:FindFirstChild('Counter')end
 if target and target:IsA('BasePart')then return target.Position end
 if key=='Shop'then return Vector3.new(-39.2,1.5,222.6)elseif key=='Pawn'then return Vector3.new(39.2,1.5,222.6)end
end
function G:ClearMarker()if self.Marker then self.Marker:Destroy();self.Marker=nil end end
function G:Show(task,state,player)
 local position=self:Position(task,state,player);self:ClearMarker();if not position then return false end
 if task.Key=='Circuit'then return true end -- The circuit already has its own checkpoint marker.
 local part=UI.New('Part',{Name='MyTaskDestination',Anchored=true,CanCollide=false,CanTouch=false,CanQuery=false,Transparency=1,Size=Vector3.one,Position=position},workspace)
 self.Marker=part;self.MarkerKey=task.Key;self.MarkerTitle=task.Title
 local b=UI.New('BillboardGui',{Size=UDim2.fromOffset(204,64),StudsOffset=Vector3.new(0,5,0),AlwaysOnTop=true},part)
 local panel=UI.Panel(b,UDim2.fromScale(1,1),UDim2.new());panel.BackgroundColor3=UI.Theme.Primary
 local text=UI.Label(panel,'HERE\n'..task.Title,UDim2.new(1,-16,1,-8),UDim2.fromOffset(8,4),16,UI.Theme.Surface);text.TextXAlignment=Enum.TextXAlignment.Center
 return true
end
return G
