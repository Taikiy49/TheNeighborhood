-- Compact, furnished destinations. Server-authoritative, free interactions.
local F=require(script.Parent.RecreationFactory)
local M={Active={},Cooldown={}}
local cream=Color3.fromRGB(230,221,199)
local ink=Color3.fromRGB(48,77,68)
local wood=Color3.fromRGB(154,112,77)
local function part(parent,n,s,p,c,solid,class)
 return F.Part(parent,n,s,CFrame.new(p),c,solid,class)
end
local function prompt(p,action,title,label)
 p:SetAttribute("Action",action)
 local q=Instance.new("ProximityPrompt");q.Name="Use";q.Style=Enum.ProximityPromptStyle.Custom;q.ObjectText=title;q.ActionText=label;q.MaxActivationDistance=10;q.RequiresLineOfSight=true;q:SetAttribute("Action",action);q.Parent=p
end
function M.Build(w)
 local old=w:FindFirstChild("SideDestinations");if old then old:Destroy()end
 local root=Instance.new("Folder");root.Name="SideDestinations";root.Parent=w
 local function building(name,center,title,color)
  local m=Instance.new("Model");m.Name=name;m.ModelStreamingMode=Enum.ModelStreamingMode.Atomic;m.Parent=root
  local function p(n,s,x,y,z,c,solid,class)return part(m,n,Vector3.new(table.unpack(s)),center+Vector3.new(x,y,z),c,solid,class)end
  p("Floor",{36,.4,30},0,.2,0,wood).Material=Enum.Material.WoodPlanks
  p("RearWall",{36,13,.7},0,6.9,15,color)
  for _,x in ipairs({-18,18})do
   p("SideSill",{.7,3,30},x,1.9,0,color)
   p("SideHeader",{.7,3,30},x,11.9,0,color)
   for _,z in ipairs({-14,0,14})do p("WindowPier",{.7,9,1},x,6.5,z,color)end
   for _,z in ipairs({-7,7})do local g=p("SideWindow",{.25,7,12},x,6.9,z,Color3.fromRGB(170,205,207));g.Material=Enum.Material.Glass;g.Transparency=.7 end
  end
  -- One generous open entrance, with glazing on both sides.
  for _,x in ipairs({-11,11})do
   p("FrontSill",{14,2,.7},x,1.4,-15,color)
   local g=p("DisplayWindow",{13,7,.25},x,5.9,-15,Color3.fromRGB(170,205,207));g.Material=Enum.Material.Glass;g.Transparency=.7
  end
  p("Header",{36,3,.8},0,11.9,-15,color)
  p("Roof",{39,.8,33},0,13.8,0,ink).Material=Enum.Material.Slate
  p("Ceiling",{35,.15,29},0,13.25,0,cream)
  p("Cornice",{39,.4,1},0,13.1,-16.3,cream)
  local sign=p("ShopName",{27,2,.35},0,11.7,-15.6,ink,false);F.Sign(sign,title)
  p("Awning",{37,.3,4},0,9.7,-17,ink)
  p("EntryPath",{8,.18,12},0,.1,-21,cream).Material=Enum.Material.Pavement
  local light=p("CeilingLamp",{2,.2,2},0,12.8,0,cream,false);light.Material=Enum.Material.Neon
  local l=Instance.new("PointLight");l.Brightness=.7;l.Range=25;l.Color=Color3.fromRGB(255,224,175);l.Parent=light
  local counter=p("Counter",{14,3,3},0,1.9,7,ink)
  p("CounterTop",{15,.3,3.5},0,3.55,7,wood)
  local interact=p("ServiceBell",{1,.5,1},0,3.95,5.9,Color3.fromRGB(207,171,83));interact:SetAttribute("Destination",name)
  for _,x in ipairs({-13,13})do
   p("Planter",{3,1.4,3},x,.8,-18.5,ink)
   local plant=p("Shrub",{3,2,3},x,2.3,-18.5,Color3.fromRGB(98,137,86),false);plant.Shape=Enum.PartType.Ball
  end
  m:SetAttribute("Entry",center+Vector3.new(0,3,-22))
  return m,p,interact
 end
 local function tableSet(p,x,z)
  p("CafeTable",{5,.35,4},x,2.7,z,wood);p("TablePedestal",{.7,2.5,.7},x,1.3,z,ink)
  for _,dx in ipairs({-3.5,3.5})do p("Chair",{2,.4,2},x+dx,1.5,z,ink,true,"Seat");p("ChairLeg",{.4,1.3,.4},x+dx,.7,z,wood);p("ChairBack",{2,2,.25},x+dx,2.5,z+1,ink)end
 end
 local cafe,p,bell=building("CornerCafe",Vector3.new(-270,0,-165),"CORNER CAFE",Color3.fromRGB(213,169,131))
 tableSet(p,-10,-5);tableSet(p,10,-5)
 p("EspressoMachine",{5,3,2},-4,5.2,8,ink);p("PastryCase",{5,2,2},5,4.7,8,cream)
 p("MachineFace",{4.6,1.7,.15},-4,5.3,6.95,Color3.fromRGB(180,186,180),false)
 p("DripTray",{4.6,.15,1},-4,3.9,6.3,ink,false)
 for _,x in ipairs({-5,-3})do p("Spout",{.25,.65,.5},x,4.4,6.7,cream,false);p("Cup",{.6,.65,.6},x,4.25,6.15,cream,false)end
 for i=1,4 do local bun=p("Pastry",{.7,.5,.7},3+i*.8,5.9,8,Color3.fromRGB(205,142,78),false);bun.Shape=Enum.PartType.Ball end
 local menu=p("Menu",{12,4,.2},0,9.2,14.4,ink,false);F.Sign(menu,"ON THE HOUSE\nTea & pastries\nTake a seat, meet a neighbor")
 prompt(bell,"CafeTea","Corner Cafe","Take a free tea")
 local boat,b,fish=building("LakesideTackle",Vector3.new(-270,0,195),"WILLOW BAIT & TACKLE",Color3.fromRGB(155,181,176))
 for i=1,4 do b("FishingRod",{.15,7,.15},-14+i,4,12,wood,false)end
 b("TackleShelf",{10,5,2},10,3,12,wood)
 for i=1,5 do b("TackleBox",{1.5,1,1.5},5+i*1.7,6,12,ink,false)end
 tableSet(b,-10,-4)
 prompt(fish,"DestinationInfo","Willow Tackle","Read fishing tips")
 fish:SetAttribute("Message","The fishing deck is beside Willow Lake. Cast, wait for BITE, then reel within two seconds. The ferry is at the east bank.")
 local deck=Instance.new("Model");deck.Name="FishingDeck";deck.Parent=root
 part(deck,"Deck",Vector3.new(16,.5,12),Vector3.new(-264,.4,109),wood).Material=Enum.Material.WoodPlanks
 for _,x in ipairs({-272,-256})do part(deck,"SideRail",Vector3.new(.3,3,12),Vector3.new(x,2,109),ink)end
 local cast=part(deck,"RodStand",Vector3.new(1,3,1),Vector3.new(-264,2,105),ink);prompt(cast,"LakeFishing","Willow Lake","Cast / reel")
 local tips=part(deck,"FishingRules",Vector3.new(8,3,.3),Vector3.new(-264,5,114.5),ink,false);F.Sign(tips,"CAST. WAIT FOR BITE. REEL!\nCatch & release - $25\nOne reward per minute")
 local shop,s,bench=building("RepairWorkshop",Vector3.new(270,0,170),"MAPLE REPAIR WORKSHOP",Color3.fromRGB(189,178,154))
 for _,x in ipairs({-12,12})do
  s("ToolShelf",{7,1,2},x,5,13,wood)
  for i=1,4 do s("Tool",{.4,2,.4},x-3+i*1.3,6.5,13,ink,false)end
 end
 s("RepairRadio",{4,2,2},-4,4.7,7,Color3.fromRGB(145,85,59))
 for _,x in ipairs({-11,11})do s("WorkStool",{2,.5,2},x,1.8,3,wood,true,"Seat")end
 local instructions=s("RepairRules",{14,4,.3},0,8,14.4,ink,false);F.Sign(instructions,"RESTORE A VINTAGE RADIO\nStart, wait for READY, then finish\n$30 - one reward per minute")
 prompt(bench,"WorkshopRepair","Repair bench","Start / finish repair")
 local farm,f,crate=building("OrchardStand",Vector3.new(175,0,245),"ORCHARD FARM STAND",Color3.fromRGB(179,190,143))
 for _,x in ipairs({-11,11})do
  f("ProduceCrate",{6,2,4},x,1.4,9,wood)
  for i=1,6 do local apple=f("Apple",{.8,.8,.8},x-2+(i%3)*1.4,2.8,8+math.floor((i-1)/3)*1.3,Color3.fromRGB(181,66,47),false);apple.Shape=Enum.PartType.Ball end
 end
 tableSet(f,0,-5);prompt(crate,"OrchardSnack","Orchard stand","Take a free apple")
 local paths=Instance.new("Folder");paths.Name="Connections";paths.Parent=root
 local function path(x,z,sx,sz)part(paths,"Path",Vector3.new(sx,.18,sz),Vector3.new(x,.1,z),cream).Material=Enum.Material.Pavement end
 path(-244,-191,60,8);path(-244,169,60,8);path(-264,142,8,54)
 path(244,144,60,8);path(216,170,8,48);path(175,204,8,30);path(196,194,42,6)
 -- Clear only landscaping within the new building footprints and connecting walks.
 local regions={{-270,-165,23,31},{-270,195,23,31},{270,170,23,31},{175,245,23,31},{-244,-191,34,5},{-244,169,34,5},{-264,142,5,25},{244,144,34,5},{175,204,5,18}}
 local remove={}
 for _,v in ipairs(w.ArtDirection.GardenDistrict:GetDescendants())do
  if v:IsA("Model")and (v:FindFirstChild("Trunk")or v.Name=="ParkTree")then
   local at=v:GetPivot().Position
   for _,r in ipairs(regions)do if math.abs(at.X-r[1])<r[3]and math.abs(at.Z-r[2])<r[4]then remove[v]=true end end
  end
 end
 for v in pairs(remove)do v:Destroy()end
 return root
end
function M.BeginOrFinish(player,target,kind)
 local now=os.clock();local key=player.UserId;local active=M.Active[key]
 if active then
  M.Active[key]=nil
  if active.Target~=target or active.Kind~=kind then return false,"Finish one activity at a time."end
  if now<active.Ready then return false,"Too early! Wait for the cue before trying again."end
  if now>active.Ready+2 then return false,"Missed the timing window. Try again."end
  local profile=M.Context.Data:Get(player);if not profile then return false,"Profile unavailable."end
  local amount=kind=="fish"and 25 or 30;profile.Currency+=amount;M.Cooldown[key]=now;M.Context.Record(player,kind=="fish"and "Fishing"or "Repair")
  return true,kind=="fish"and "Nice catch! Released safely. Earned $25."or "Radio restored! Earned $30."
 end
 if now-(M.Cooldown[key]or -60)<60 then return false,"Next paid activity is available in a minute. Enjoy the neighborhood meanwhile."end
 local job={Target=target,Kind=kind,Ready=now+math.random(30,60)/10};M.Active[key]=job
 task.delay(job.Ready-now,function()
  if M.Active[key]~=job then return end
  local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
  if not root or (root.Position-target.Position).Magnitude>12 or not M.Context.Data:CanAct(player)then M.Active[key]=nil;return end
  M.Context.Notify(player,kind=="fish"and "BITE! Reel now - two seconds!"or "READY! Finish the repair now - two seconds!",true)
  task.delay(2.2,function()if M.Active[key]==job then M.Active[key]=nil;M.Context.Notify(player,"Timing window missed. Start again when ready.",false)end end)
 end)
 return true,kind=="fish"and "Line cast. Wait for BITE before reeling."or "Repair started. Wait for READY before finishing."
end
function M.Snack(player,apple)
 local bag=player:FindFirstChildOfClass("Backpack");if not bag then return false,"Your backpack is not ready."end
 for _,container in ipairs({bag,player.Character})do if container then for _,v in ipairs(container:GetChildren())do if v:IsA("Tool")and v:GetAttribute("CafeSnack")then return false,"Enjoy your current snack first."end end end end
 local tool=Instance.new("Tool");tool.Name=apple and "Orchard apple"or "Corner Cafe tea";tool.CanBeDropped=false;tool:SetAttribute("CafeSnack",true)
 local handle=Instance.new("Part");handle.Name="Handle";handle.Size=apple and Vector3.new(.7,.7,.7)or Vector3.new(.65,.8,.65);handle.Color=apple and Color3.fromRGB(185,61,42)or cream;handle.Shape=apple and Enum.PartType.Ball or Enum.PartType.Cylinder;handle.CanCollide=false;handle.Massless=true;handle.Parent=tool
 local used=false;tool.Activated:Connect(function()if used then return end;used=true;M.Context.Notify(player,apple and "A crisp apple, fresh from the orchard."or "A warm cup of tea. Welcome to the Corner Cafe.",true);tool:Destroy()end)
 tool.Parent=bag;game:GetService("Debris"):AddItem(tool,180)
 return true,"Added to your backpack. Equip and tap to enjoy."
end
function M.Init(context)
 M.Context=context;M.Build(workspace.Neighborhood)
 context.Interactions:Register("CafeTea",function(p)return M.Snack(p,false)end)
 context.Interactions:Register("OrchardSnack",function(p)return M.Snack(p,true)end)
 context.Interactions:Register("DestinationInfo",function(_,t)return true,t:GetAttribute("Message")end)
 context.Interactions:Register("LakeFishing",function(p,t)return M.BeginOrFinish(p,t,"fish")end)
 context.Interactions:Register("WorkshopRepair",function(p,t)return M.BeginOrFinish(p,t,"repair")end)
 game.Players.PlayerRemoving:Connect(function(p)M.Active[p.UserId]=nil;M.Cooldown[p.UserId]=nil end)
end
return M
