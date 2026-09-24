-- Finished Creator Store buildings and furniture; sources in docs/VENUE-RENEWAL.md.
local A=require(script.Parent.CityArchitecture)
local M={}
local library=game.ServerStorage:WaitForChild('VenueArt')
function M.Place(name,parent,cf,scale)
 scale=scale or 1
 local shell=parent:FindFirstChild('ImportedBakery')
 if shell and name~='Bakery'then
  local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Include;ray.FilterDescendantsInstances={shell};ray.RespectCanCollide=true
  local hit=workspace:Raycast(cf.Position+Vector3.new(0,5,0),Vector3.new(0,-10,0),ray)
  if hit then cf+=Vector3.new(0,hit.Position.Y+.02-cf.Position.Y,0)end
 end
 local m=library[name]:Clone();m.Name='Imported'..name;m:ScaleTo(scale or 1);m:PivotTo(cf);m.ModelStreamingMode=Enum.ModelStreamingMode.Atomic;m.Parent=parent
 for _,p in ipairs(m:GetDescendants())do if p:IsA('BasePart')then p.Anchored=true;p.CanQuery=p.CanCollide and p.Size.X*p.Size.Y*p.Size.Z>25;p.CanTouch=p:IsA('Seat') end end
 if name=='Cafe'or name=='Bakery'then
  local ceiling=m:FindFirstChildWhichIsA('BasePart',true)
  for _,x in ipairs({-8,8})do local at=Instance.new('Attachment');at.Position=ceiling.CFrame:PointToObjectSpace(cf*Vector3.new(x,9*scale,0));at.Parent=ceiling;local l=Instance.new('PointLight');l.Color=Color3.fromRGB(255,225,185);l.Range=30;l.Brightness=.8;l.Parent=at end
 end
 return m
end
local function anchor(parent,name,position)
 local p=Instance.new('Part');p.Name=name;p.Size=Vector3.new(1,1,1);p.Position=position;p.Transparency=1;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=true;p.Parent=parent;return p
end
local function identify(m,title,cf,width)
 -- Adapt a sign from the existing town art library; no replacement shell geometry.
 local template=library:FindFirstChild('VenueSign')
 if not template then return end
 local sign=template:Clone();sign.Name='VenueName';sign.Size=Vector3.new(width or 20,2,.2);sign.CFrame=cf;sign.CanCollide=false;sign.CanQuery=false
 for _,g in ipairs(sign:GetChildren())do g:Destroy()end
 A.Sign(sign,title);sign.Parent=m
end
function M.Project(parent,id,amount)
 local d=require(game.ReplicatedStorage.Neighborhood.Shared.LifeDefinitions).Projects[id]
 local old=parent:FindFirstChild(id);if old then old:Destroy()end
 local m=Instance.new('Model');m.Name=id;m.Parent=parent;m.ModelStreamingMode=Enum.ModelStreamingMode.Atomic
 local locations={Cafe=Vector3.new(-390,.2,10),Clubhouse=Vector3.new(-480,.2,10),Greenhouse=Vector3.new(-60,.2,-470)}
 local cf=CFrame.new(locations[id]);local kind=id=='Greenhouse'and 'Greenhouse'or id=='Clubhouse'and 'Bakery'or 'Cafe'
 local scale=id=='Greenhouse'and 1.1 or id=='Clubhouse'and 1 or .9
 M.Place(kind,m,cf,scale)
 anchor(m,'Floor',cf.Position)
 local pos=id=='Greenhouse'and Vector3.new(0,3,-10)or id=='Clubhouse'and Vector3.new(0,3,-4)or Vector3.new(10,4,8)
 local station=anchor(m,'Renovation_'..id,cf*pos)
 A.Prompt(station,'LifeStation',d.Name,'Community upgrades');station:SetAttribute('LifeView','LifeProjects');station:SetAttribute('LifeArg',id)
 m:SetAttribute('RenovationProgress',amount);m:SetAttribute('RenovationGoal',d.Goal)
 if id=='Cafe'then
  local tea=anchor(m,'TeaService',cf*Vector3.new(10,4,5));A.Prompt(tea,'CafeTea','Park Café','Take free tea')
  identify(m,'PARK CAFÉ',cf*CFrame.new(0,14,-21.8),20)
 elseif id=='Clubhouse'then
  for _,level in ipairs({.5,15,30})do M.Place('Booth',m,cf*CFrame.new(2,level,0),.7)end
  identify(m,'MAPLE CLUBHOUSE',cf*CFrame.new(0,12,-11.5),17)
 else
  local art=require(script.Parent.CuratedArchitecture)
  for _,x in ipairs({-7,7})do for _,z in ipairs({-8,0,8})do art.Place('Planter',m,cf*CFrame.new(x,1.6,z),Vector3.new(3,3,3))end end
 end
 return station
end
local function replace(m,kind,cf,scale)
 -- Keep service objects by identity, so references and economy checks remain valid.
 local keep={};for _,p in ipairs(m:GetDescendants())do if p:IsA('BasePart')and p:GetAttribute('Action')~='CityLift'and(p:GetAttribute('Action')or p.Name=='Counter' or p.Name=='Floor')then table.insert(keep,p)end end
 local saved=Instance.new('Folder');saved.Name='ServiceTargets';saved.Parent=m
 for _,p in ipairs(keep)do p.Parent=saved;p.Transparency=1;p.CanCollide=false;p.CanTouch=false;p.CanQuery=p:GetAttribute('Action')~=nil;for _,v in ipairs(p:GetChildren())do if v:IsA('SurfaceGui')then v:Destroy()end end end
 for _,v in ipairs(m:GetChildren())do if v~=saved then v:Destroy()end end
 for _,p in ipairs(keep)do p.Parent=m end;saved:Destroy()
 local art=M.Place(kind,m,cf,scale)
 local service=kind=='Market'and Vector3.new(26,4,13)or kind=='Bakery'and Vector3.new(3,4,-4)or kind=='Greenhouse'and Vector3.new(0,3,-8)or Vector3.new(11,4,6)
 for _,p in ipairs(keep)do
  if p.Name=='Floor'then p.Size=Vector3.new(1,1,1);p.CFrame=cf
  else p.Size=Vector3.new(1,1,1);p.CFrame=cf*CFrame.new(service*scale)end
 end
 local entry=kind=='Market'and Vector3.new(12,3,-28)*scale or kind=='Bakery'and Vector3.new(7,3,-15)*scale or Vector3.new(0,3,-27)*scale
 m:SetAttribute('Entry',cf*entry);m:SetAttribute('ImportedVenue',kind)
 return art
end
function M.Init(context)
 local w=workspace.Neighborhood;local root=w.CoastalWorld;local side=w.SideDestinations
 context.Interactions:Register('CafeTea',function(player)
  local bag=player:FindFirstChildOfClass('Backpack');if not bag or not player.Character then return false,'Your character is not ready.'end
  for _,container in ipairs({bag,player.Character})do for _,v in ipairs(container:GetChildren())do if v:GetAttribute('CafeSnack')then return false,'Enjoy your current drink first.'end end end
  local cup=library.TeaCup:Clone();cup:ScaleTo(.55)
  local tool=Instance.new('Tool');tool.Name='Café tea';tool.CanBeDropped=false;tool:SetAttribute('CafeSnack',true)
  local handle=cup:FindFirstChildWhichIsA('BasePart',true);handle.Name='Handle'
  for _,p in ipairs(cup:GetDescendants())do if p:IsA('BasePart')then p.Anchored=false;p.CanCollide=false;p.CanQuery=false;p.CanTouch=false;p.Massless=true;p.Parent=tool;if p~=handle then local weld=Instance.new('WeldConstraint');weld.Part0=handle;weld.Part1=p;weld.Parent=p end end end
  cup:Destroy();tool.Parent=bag;game:GetService('Debris'):AddItem(tool,180)
  tool.Activated:Once(function()context.Notify(player,'Enjoy your tea!',true);tool:Destroy()end)
  return true,'Tea ready! Equip it from your bag and tap to drink.'
 end)
 replace(side.CornerCafe,'Cafe',CFrame.new(-465,.15,130),.95)
 identify(side.CornerCafe,'CORNER CAFÉ',CFrame.new(-465,14,107.2),22)
 replace(w.Shops.GeneralStore,'Market',CFrame.new(-375,.15,147),.85)
 M.Place('Workbench',root.Industrial.CoastalWorks,root.Industrial.CoastalWorks.Floor.CFrame*CFrame.new(14,.2,8),.8)
 replace(side.OrchardStand,'Greenhouse',CFrame.new(-470,.15,-450),1.1)
 for _,x in ipairs({-478,-462})do M.Place('FruitStand',side.OrchardStand,CFrame.new(x,.4,-447),.8)end
 identify(side.OrchardStand,'ORCHARD FARM MARKET',CFrame.new(-470,10,-470),20)
 replace(side.LakesideTackle,'Bakery',CFrame.new(585,.15,130)*CFrame.Angles(0,math.pi/2,0),1)
 M.Place('StockedShelf',side.LakesideTackle,CFrame.new(592,.4,133)*CFrame.Angles(0,math.pi/2,0),.65)
 identify(side.LakesideTackle,'COAST BAIT & TACKLE',CFrame.new(573.5,12,130)*CFrame.Angles(0,math.pi/2,0),17)
 replace(w.Shops.PawnShop,'Bakery',CFrame.new(-265,.15,145),1)
 M.Place('ServiceCounter',w.Shops.PawnShop,CFrame.new(-265,.4,147),.8)
 M.Place('StockedShelf',w.Shops.PawnShop,CFrame.new(-270,.4,152),.7)
 identify(w.Shops.PawnShop,'SECOND CHANCE • PAWN',CFrame.new(-265,12,133.5),17)
 -- Café-sized restaurants retain distinct existing locations and service targets.
 local town=root.TownLife
 replace(town.PalmDiner,'Cafe',CFrame.new(150,.15,-185)*CFrame.Angles(0,math.pi/2,0),.9)
 replace(town.NoodleKitchen,'Cafe',CFrame.new(450,.15,-330),.9)
 replace(town.BoardwalkBakery,'Bakery',CFrame.new(440,.15,215),1)
 replace(town.CornerConvenience,'Market',CFrame.new(190,.15,145),.8)
 replace(root.CommercialStrip.FuelAndSnacks,'Market',CFrame.new(-120,.15,212)*CFrame.Angles(0,math.pi,0),.7)
 for _,m in ipairs({town.PalmDiner,town.NoodleKitchen,town.BoardwalkBakery,town.CornerConvenience})do local target=m:FindFirstChild('SnackCounter');if target then target:SetAttribute('Action','CafeTea');for _,p in ipairs(target:GetChildren())do if p:IsA('ProximityPrompt')then p:SetAttribute('Action','CafeTea');p.ActionText='Take free tea';p.ObjectText=m.Name=='NoodleKitchen'and 'Sunset Café'or m.Name:gsub('(%l)(%u)','%1 %2')end end end end
 local snack=anchor(root.CommercialStrip.FuelAndSnacks,'MarketSnacks',Vector3.new(-138.2,3,202.9));A.Prompt(snack,'CafeTea','Coast Market','Take free tea')
 identify(town.BoardwalkBakery,'BOARDWALK BAKERY',CFrame.new(440,12,203.5),17)
 identify(town.NoodleKitchen,'SUNSET CAFÉ',CFrame.new(450,14,-351.6),20)
 identify(town.PalmDiner,'PALM DINER',CFrame.new(128.4,14,-185)*CFrame.Angles(0,math.pi/2,0),20)
 for _,m in ipairs({town.BoardwalkBakery})do
  M.Place('ServiceCounter',m,CFrame.new(440,1,215),.7)
  M.Place('PastryDisplay',m,CFrame.new(447,1,215),.75)
  for _,y in ipairs({.4,15,30})do M.Place('Booth',m,CFrame.new(438,y,223),.7)end
 end
 local shift=anchor(side.CornerCafe,'BaristaOrders',Vector3.new(-456,4,133));A.Prompt(shift,'CafeShift','Barista shift','Prepare / serve an order')
 local jobs,last={},{}
 context.Interactions:Register('CafeShift',function(player)
  local now=os.clock();local job=jobs[player]
  if job then
   if now<job then return false,'Still brewing. Wait for READY.'end
   jobs[player]=nil
   if now>job+3 then return false,'Order cooled down. Try another.'end
   local profile=context.Data:Get(player);if not profile then return false,'Profile unavailable.'end
   last[player]=now;profile.Currency=math.min(1000000000,profile.Currency+15);context.Record(player,'CityWork');context.Sync(player);return true,'Order served! Earned $15.'
  end
  if now-(last[player]or -60)<60 then return false,'Next paid order arrives in a minute.'end
  local ready=now+4;jobs[player]=ready
  task.delay(4,function()if jobs[player]==ready and player.Parent then context.Notify(player,'READY! Serve the café order within three seconds.',true)end end)
  return true,'Brewing. Wait for READY, then use this counter again.'
 end)
 game.Players.PlayerRemoving:Connect(function(p)jobs[p]=nil;last[p]=nil end)
 -- Replace repeated block furniture across public rooms, preserving every job target.
 local removed={Sofa=true,SofaBack=true,SofaFoot=true,CoffeeTable=true,CoffeeLeg=true,TableTop=true,TableLeg=true,ChairBack=true,ChairLeg=true}
 local rooms=0
 for _,m in ipairs(w:GetDescendants())do
  if m:IsA('Model')and m:FindFirstChild('Floor')and not m:GetAttribute('ImportedVenue')and not m:IsDescendantOf(w.Houses)then
   local bases={};local floor=m.Floor
   for _,p in ipairs(m:GetChildren())do if p:IsA('BasePart')and p.Name=='Sofa'then local v=floor.CFrame:PointToObjectSpace(p.Position);table.insert(bases,Vector3.new(v.X,math.max(0,v.Y-1),v.Z))end end
   if #bases>0 then
    for _,p in ipairs(m:GetChildren())do if removed[p.Name]or(p.Name=='Seat'and p:IsA('Seat'))then p:Destroy()end end
    for _,at in ipairs(bases)do M.Place('Booth',m,floor.CFrame*CFrame.new(at),.65)end
    rooms+=1
   end
  end
 end
 -- Menus always refer to the current coast, not the removed lake.
 local tackle=side.LakesideTackle.ServiceBell;tackle:SetAttribute('Message','Fish at the beach pier. Cast, wait for BITE, then reel within two seconds. The marina is on the coast.')
 -- Clear the two kinds of imported street trees against the enlarged real footprints.
 local trees=root.StreetDressing;local removedTrees=0
 for _,venue in ipairs(w:GetDescendants())do
  if venue:IsA('Model')and(venue.Name=='ImportedCafe'or venue.Name=='ImportedMarket'or venue.Name=='ImportedBakery'or venue.Name=='ImportedGreenhouse')then
   local b,size=venue:GetBoundingBox()
   for _,tree in ipairs(trees:GetChildren())do if tree:IsA('Model')and(tree.Name=='Art_StreetTree'or tree.Name=='Art_CoastPalm')then
    local q=b:PointToObjectSpace(tree:GetPivot().Position)
    if math.abs(q.X)<size.X/2+3 and math.abs(q.Z)<size.Z/2+3 then tree:Destroy();removedTrees+=1 end
   end end
  end
 end
 w:SetAttribute('VenueTreesCleared',removedTrees)
 w:SetAttribute('RenewedPublicInteriors',rooms);w:SetAttribute('ImportedVenueCount',14)
end
return M
