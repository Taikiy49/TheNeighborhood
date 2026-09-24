local D=require(game.ReplicatedStorage.Neighborhood.Shared.LifeDefinitions)
local R=require(game.ReplicatedStorage.Neighborhood.Shared.LifeRules)
local Screen={}
local pages={{"Garden","Grow & gather","Four beds, six varieties and handmade arrangements."},{"Business","Your little business","Serve NPC customers at your side-yard counter."},{"Projects","Build together","Restore three communal places and use their activities."},{"Mystery","Neighborhood mysteries","Three cases, changing weekly clues and six endings."},{"Tours","Open-house afternoons","Opt-in tours and welcoming decorating challenges."},{"Mastery","Maker's notebook","Earn blueprints and new accent styles as you play."},{"Festival","Street festivals","Lantern hunts, a shared relay and returning decorations."}}
function Screen.Render(s,view,detail)
 local l=s.State.Life or R.Default();local now=l.Now or 0
 local function send(action,arg)s.Request("Life",action,arg or "")end
 local function nav(title,text,page)s:Row(title,text,"Open",function()s:Open("Life"..page)end)end
 if view=="Life"then
  s.Title.Text="Neighborhood Life"
  s:Row("Make yourself at home","Grow flowers, meet customers and leave a little mark on Maple Street. Your personal progress follows your saved profile.")
  for _,p in ipairs(pages)do nav(p[2],p[3],p[1])end
  return
 end
 s:Row("Neighborhood Life","Return to all seven activities.","All activities",function()s:Open("Life")end)
 if view=="LifeGarden"then
  s.Title.Text="Grow & gather"
  s:Row("Your side-yard garden","Walk to the four raised beds beside your home. Water once to shorten growth by 40 seconds. Water beside another species for a hybrid. Plants never wilt while you are away.")
  local varieties=0;for _ in pairs(l.Varieties)do varieties+=1 end;s:Row("Flower album",varieties.." / 6 varieties discovered. Hybrid flowers use the same arrangement recipes.")
  for i=1,4 do local id=tostring(i);local b=l.Beds[id]
   if b then
    local ready=R.Ready(b,now);s:Row("Bed "..i.." · "..b.Kind,(b.Hybrid and "Hybrid · "or "")..(ready and "Ready to harvest"or math.max(0,b.Planted+D.Flowers[b.Kind].Seconds-(b.Watered and 40 or 0)-now).." seconds remaining"),ready and "Harvest"or not b.Watered and "Water"or nil,function()send(ready and "Harvest"or "Water",id)end)
   else for _,kind in ipairs(D.FlowerOrder)do s:Row("Bed "..i.." · "..kind,"Seeds $"..D.Flowers[kind].Price.." · "..D.Flowers[kind].Seconds.." seconds","Plant",function()send("Plant",id..":"..kind)end)end end
  end
  for _,kind in ipairs(D.FlowerOrder)do s:Row(kind.." basket",tostring(l.Flowers[kind]or 0).." flowers")end
  for _,kind in ipairs({"Bouquet","Planter"})do local recipe=kind=="Bouquet"and "2 Daisy + 1 Lavender"or "2 Sunflower + 1 Daisy";s:Row(kind,recipe.." · Owned: "..(l.Goods[kind]or 0)..". Arrange at your side-yard counter.","Arrange",function()send("Arrange",kind)end)end
 elseif view=="LifeBusiness"then
  s.Title.Text="Your little business"
  s:Row("The counter beside your garden","NPC customers pay game cash. No player trading. Nursery orders use one arrangement; other orders use $25 supplies. Every completed three-step order pays $90 and 10 mastery XP.")
  if l.Business~=""then
   local d=D.Businesses[l.Business];s:Row(d.Name,l.OrderStep>0 and "Customer: "..D.Customers[(l.OrderSerial-1)%3+1]or "Next customer in "..math.max(0,l.NextOrder-now).." seconds")
   if l.OrderStep>0 then s:Row("Step "..l.OrderStep.." of 3",d.Steps[l.OrderStep].." · Ready in "..math.max(0,l.OrderReady-now).." seconds",d.Steps[l.OrderStep],function()send("Work",d.Steps[l.OrderStep])end)
   else s:Row("Take an order",l.Business=="Nursery"and "Next arrangement: "..(l.OrderSerial%2==0 and "Bouquet"or "Planter")or "Prepare a new commission using $25 supplies.","Accept order",function()send("Order")end)end
  end
  for _,id in ipairs({"Nursery","Furniture","Repair"})do local d=D.Businesses[id];s:Row(d.Name,"Requires "..d.Room..". Finish active orders before switching.","Run this business",function()send("Business",id)end)end
  s:Row("Need a room?","Buy expansions through Plan your home.","Plan your home",function()s:Open("Building")end)
 elseif view=="LifeProjects"then
  s.Title.Text="Build together"
  s:Row("Your shared neighborhood","Cafe and clubhouse: north of the cross street. Greenhouse: between the shops at the south end. Begin a repair at its counter, wait three seconds, then finish. Solo players can also complete every project.")
  for _,entry in ipairs(l.Projects or {})do local id=entry.Id;local d=D.Projects[id];local done=entry.Progress>=d.Goal
   s:Row(d.Name,entry.Progress.." / "..d.Goal.." repairs · Your saved contributions: "..(l.Contributions[id]or 0),done and "Use community activity"or l.Working==id and "Finish repair"or "Begin repair",function()send(done and "Social"or l.Working==id and "FinishRenovation"or "Renovate",id)end)
   if done then s:Row("Now open",id=="Cafe"and "Serve tea to earn 2 mastery XP."or id=="Clubhouse"and "Feature your decorating theme and receive its cosmetic banner."or "Collect three daisy cuttings for your arrangements.")end
  end
  s:Row("Saved legacy","Shared construction is per server. Your contributions and completion receipts are saved and help restore these places when you move. Community activities share a one-minute cooldown.")
 elseif view=="LifeMystery"then
  s.Title.Text="Neighborhood mysteries"
  local count=0;for _ in pairs(l.Endings)do count+=1 end;s:Row("Ending album",count.." / 6 endings. Each new ending earns $50 and 20 mastery XP. Weekly clue variants keep return visits different; there is no deadline.")
  if l.Mystery==""then for _,id in ipairs(D.CaseOrder)do s:Row(D.Cases[id].Name,"Follow the first three numbered park lanterns.","Open case",function()send("Case",id)end)end
  else
   local d=D.Cases[l.Mystery];s:Row(d.Name,"Clues found: "..l.Clue.." / 3"..(l.Clue>0 and " · "..d.Notes[l.Variant]or ". Begin at lantern 1 near the north park entrance."))
   if l.Clue<3 then s:Row("Next clue: lantern "..(l.Clue+1),"Walk there and inspect the note.","Inspect clue",function()send("Clue",tostring(l.Clue+1))end)
   elseif not l.Solved then for _,person in ipairs(d.People)do s:Row("Was it "..person.."?","Nora bakes, Leo runs the library, Willow grows lavender. Wrong guesses have no penalty.","Make deduction",function()send("Deduce",person)end)end
   else for i,ending in ipairs(d.Endings)do s:Row(ending,l.Endings[l.Mystery..":"..i]and "Already in your album; replay for the story."or "A new ending for your album.","Choose this ending",function()send("Ending",tostring(i))end)end end
   s:Row("Put away this case","Keeps all completed ending stamps.","Put away",function()send("PutAway")end)
  end
 elseif view=="LifeTours"then
  s.Title.Text="Open-house afternoons"
  s:Row("Your tour",l.TourOpen and "Open to visitors. Locking your house ends the tour."or "Closed. Opening a tour unlocks and opens your doors. Displayed possessions still follow the game's theft rules.",l.TourOpen and "Close tour"or "Open and unlock",function()send("Tour",l.TourOpen and "Close"or "Open")end)
  for _,theme in ipairs(D.Themes)do s:Row(theme,(l.Theme==theme and "Selected · "or "")..(l.Banners[theme]and "Banner earned"or "Cosmetic participation banner available"),"Select theme",function()send("Theme",theme)end)end
  s:Row("Welcoming homes challenge","At your home gallery sign, display any one possession and enter. Starter items count; no wealth rankings.","Enter showcase",function()send("Challenge")end)
  s:Row("Tour passport",l.Tours.." tours completed · "..l.Compliments.." compliments received")
  if l.Visit then
   if l.Visit.Step<=3 then local labels={"front porch","living room","side garden"};s:Row("Your next highlight",labels[l.Visit.Step],"Mark highlight",function()send("VisitStop",tostring(l.Visit.Step))end)
   else for _,text in ipairs({"Warm welcome","Inventive details","Lovely garden"})do s:Row(text,"Send a preset compliment to your host.","Send compliment",function()send("Compliment",text)end)end end
  end
  for _,host in ipairs(l.Listings or {})do s:Row(host.Name.." · "..host.Address,host.Theme.." · Walk to their home gallery sign.","Begin tour",function()send("Visit",tostring(host.UserId))end)end
  if #(l.Listings or {})==0 then s:Row("No open tours yet","Invite friends to join and open a home for visitors.")end
 elseif view=="LifeMastery"then
  s.Title.Text="Maker's notebook"
  s:Row("Mastery level "..math.floor(l.XP/100),l.XP.." lifetime XP. Grow, fulfill orders, renovate and solve stories. Expansion purchases earn 30 XP; crafted furniture earns 2. Your plot stays bounded for reliable multiplayer play.")
  for _,id in ipairs(D.BlueprintOrder)do local d=D.Blueprints[id];s:Row(id,d.XP.." XP to unlock · $"..d.Price.." to craft once at your side-yard counter. "..(l.Blueprints[id]and "Displayed in your garden."or ""),not l.Blueprints[id]and "Craft blueprint"or nil,function()send("Blueprint",id)end)end
  for _,id in ipairs({"Meadow","Coastal","Autumn"})do s:Row(id.." accents",D.Styles[id].XP.." XP · Restyles garden beds and business awnings. Your purchased home style stays intact.","Apply accents",function()send("Style",id)end)end
 elseif view=="LifeFestival"then
  s.Title.Text=(l.Season or "Seasonal").." street festival"
  s:Row("Lantern relay",(l.Relay or 0).." / 9 shared passes. Stations 1 → 2 → 3, three rounds. Everyone who contributes earns two current-season tokens, at most once per three minutes. Solo play works too.","Pass at next station",function()send("Relay",tostring((l.Relay or 0)%3+1))end)
  if l.Festival~=""then s:Row(l.Festival.." lantern hunt","Next: park lantern "..(l.Hunt+1)..". Four stops earn four tokens.","Collect at lantern",function()send("Token",tostring(l.Hunt+1))end)end
  for _,season in ipairs(D.Seasons)do
   s:Row(season.." collection",(l.Tokens[season]or 0).." tokens. Seasonal archive hunts are always available; decorations return, with no paid random rewards.",l.Festival==""and "Start lantern hunt"or nil,function()send("Hunt",season)end)
   for _,kind in ipairs({"Flag","Wreath","Lantern"})do local key=season..":"..kind;s:Row(season.." "..kind,l.Decor[key]and "Permanently unlocked."or D.Decor[kind].." "..season.." tokens",l.Decor[key]and "Display"or "Unlock",function()send(l.Decor[key]and "Equip"or "Decor",key)end)end
  end
 elseif view=="LifeStop"then
  s.Title.Text="Park lantern "..tostring(detail)
  s:Row("A little discovery stop","Use this station for your mystery, festival hunt or the shared relay.")
  if l.Mystery~=""then s:Row("Mystery clue","Your next clue is "..(l.Clue+1),"Inspect note",function()send("Clue",tostring(detail))end)end
  if l.Festival~=""then s:Row("Festival hunt","Your next lantern is "..(l.Hunt+1),"Collect lantern",function()send("Token",tostring(detail))end)end
  s:Row("Community relay","Next station: "..((l.Relay or 0)%3+1),"Pass lantern",function()send("Relay",tostring(detail))end)
  nav("Story album","Read clues and choose an ending.","Mystery");nav("Festival collections","Start a hunt or spend earned tokens.","Festival")
 end
end
return Screen
