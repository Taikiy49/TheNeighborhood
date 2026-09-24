local D=require(script.Parent.LifeDefinitions)
local R={}
function R.Int(v,a,b)return type(v)=="number"and v==v and v%1==0 and v>=a and v<=b end
function R.Default()return {Beds={},Flowers={},Goods={},Varieties={},XP=0,Blueprints={},Style="Meadow",Business="",OrderSerial=0,OrderStep=0,OrderReady=0,NextOrder=0,Contributions={},Renovations={},WorkReady=0,Endings={},Mystery="",Clue=0,Variant=1,Solved=false,TourOpen=false,Theme="CozyCorners",Banners={},Tours=0,Compliments=0,Festival="",Hunt=0,NextHunt=0,Tokens={},Decor={},Equipped="",NextRelay=0}end
local function map(t,allow,check)if type(t)~="table"then return false end;for k,v in pairs(t)do if not allow(k)or not check(v)then return false end end;return true end
local function yes(v)return v==true end
local function count(v)return R.Int(v,0,999)end
local function stamp(k)if type(k)~="string"then return false end;local id,n=k:match("^(%a+):([12])$");return id and D.Cases[id]and n end
local function decor(k)if type(k)~="string"then return false end;local s,x=k:match("^(%a+):(%a+)$");return s and table.find(D.Seasons,s)and D.Decor[x]end
function R.Valid(p)
 if type(p)~="table"then return false end
 local defaults=R.Default();for k in pairs(p)do if defaults[k]==nil then return false end end
 for _,k in ipairs({"XP","OrderSerial","OrderReady","NextOrder","WorkReady","Tours","Compliments","NextHunt","NextRelay"})do if not R.Int(p[k],0,10000000000)then return false end end
 if not R.Int(p.OrderStep,0,3)or not R.Int(p.Clue,0,3)or not R.Int(p.Variant,1,3)or not R.Int(p.Hunt,0,4)then return false end
 if type(p.Solved)~="boolean"or type(p.TourOpen)~="boolean"or not D.Styles[p.Style]or not table.find(D.Themes,p.Theme)then return false end
 if p.Business~=""and not D.Businesses[p.Business]or p.Mystery~=""and not D.Cases[p.Mystery]or p.Festival~=""and not table.find(D.Seasons,p.Festival)then return false end
 if p.Equipped~=""and not decor(p.Equipped)then return false end
 if not map(p.Beds,function(k)return k=="1"or k=="2"or k=="3"or k=="4"end,function(v)return type(v)=="table"and D.Flowers[v.Kind]~=nil and R.Int(v.Planted,0,10000000000)and type(v.Watered)=="boolean"and type(v.Hybrid)=="boolean"end)then return false end
 if not map(p.Flowers,function(k)return D.Flowers[k]~=nil end,count)or not map(p.Goods,function(k)return D.Goods[k]~=nil end,count)then return false end
 if not map(p.Varieties,function(k)return D.Flowers[k]or (type(k)=="string"and D.Flowers[k:match("^(%a+)Hybrid$")])end,yes)then return false end
 if not map(p.Blueprints,function(k)return D.Blueprints[k]end,yes)or not map(p.Banners,function(k)return table.find(D.Themes,k)end,yes)then return false end
 if not map(p.Contributions,function(k)return D.Projects[k]end,function(v)return R.Int(v,0,18)end)or not map(p.Renovations,function(k)return D.Projects[k]end,yes)then return false end
 if not map(p.Endings,stamp,yes)or not map(p.Tokens,function(k)return table.find(D.Seasons,k)end,count)or not map(p.Decor,decor,yes)then return false end
 if p.Equipped~=""and not p.Decor[p.Equipped]then return false end
 if p.XP<D.Styles[p.Style].XP then return false end
 for k in pairs(p.Blueprints)do if p.XP<D.Blueprints[k].XP then return false end end
 return true
end
function R.Earn(p,n)p.XP=math.min(1000000000,p.XP+n)end
function R.Ready(b,now)return now>=b.Planted+D.Flowers[b.Kind].Seconds-(b.Watered and 40 or 0)end
-- Pure, synchronous mutation engine. Callers authorize proximity and ownership first.
-- Failure branches do not debit resources; rewards clear their receipt in the same call.
function R.Action(p,cash,action,arg,now,building)
 if type(arg)~="string"or #arg>80 then return false,"Choose an available activity.",0 end
 local function ok(msg,delta)return true,msg,delta or 0 end
 local function no(msg)return false,msg,0 end
 if action=="Plant"then
  local bed,kind=arg:match("^([1-4]):(%a+)$");local d=kind and D.Flowers[kind]
  if not d or p.Beds[bed]then return no("Choose an empty bed and a seed.")end
  if cash<d.Price then return no("Seeds cost $"..d.Price.." in game cash.")end
  p.Beds[bed]={Kind=kind,Planted=now,Watered=false,Hybrid=false};return ok("Seed planted. It stays safe while you are away.",-d.Price)
 elseif action=="Water"then
  local b=p.Beds[arg];if not b or b.Watered then return no("Choose a bed that needs watering.")end
  b.Watered=true;for key,other in pairs(p.Beds)do if key~=arg and other.Kind~=b.Kind then b.Hybrid=true;break end end
  return ok("Watered! Nearby different flowers can create a new variety.")
 elseif action=="Harvest"then
  local b=p.Beds[arg];if not b or not R.Ready(b,now)then return no("This flower is still growing.")end
  if (p.Flowers[b.Kind]or 0)>=999 then return no("Use some flowers before harvesting more.")end
  p.Flowers[b.Kind]=(p.Flowers[b.Kind]or 0)+1;p.Varieties[b.Kind..(b.Hybrid and "Hybrid"or "")]=true;p.Beds[arg]=nil;R.Earn(p,5);return ok("Flower collected and variety recorded.")
 elseif action=="Arrange"then
  local recipe=D.Goods[arg];if not recipe or (p.Goods[arg]or 0)>=999 then return no("Choose an arrangement with room in storage.")end
  for kind,n in pairs(recipe)do if (p.Flowers[kind]or 0)<n then return no("Grow the flowers listed in this recipe first.")end end
  for kind,n in pairs(recipe)do p.Flowers[kind]-=n end;p.Goods[arg]=(p.Goods[arg]or 0)+1;R.Earn(p,3);return ok(arg.." arranged.")
 elseif action=="Business"then
  local d=D.Businesses[arg];if not d or not building.Unlocked[d.Room]then return no("Build the business's required room first.")end
  if p.OrderStep>0 then return no("Finish the current order before changing businesses.")end
  p.Business=arg;return ok(d.Name.." is open for NPC orders.")
 elseif action=="Order"then
  if not D.Businesses[p.Business]or p.OrderStep>0 or now<p.NextOrder then return no("Finish your order or wait for the next customer.")end
  if p.Business=="Nursery"then
   local good=p.OrderSerial%2==0 and "Bouquet"or "Planter";if (p.Goods[good]or 0)<1 then return no("This customer needs a "..good..". Arrange one first.")end;p.Goods[good]-=1
  elseif cash<25 then return no("Order supplies cost $25 in game cash.")end
  p.OrderSerial=math.min(1000000000,p.OrderSerial+1);p.OrderStep=1;p.OrderReady=now+3
  return ok("Order accepted. Complete the three work steps.",p.Business=="Nursery"and 0 or -25)
 elseif action=="Work"then
  local d=D.Businesses[p.Business];if not d or p.OrderStep<1 or arg~=d.Steps[p.OrderStep]or now<p.OrderReady then return no("Follow the current work step after its short preparation time.")end
  if p.OrderStep==3 then
   if cash>999999910 then return no("Spend some cash before completing this order.")end
   p.OrderStep=0;p.NextOrder=now+60;R.Earn(p,10);return ok("Happy customer! Earned $90 and 10 mastery XP.",90)
  end
  p.OrderStep+=1;p.OrderReady=now+3;return ok("Work step finished.")
 elseif action=="Blueprint"then
  local d=D.Blueprints[arg];if not d or p.Blueprints[arg]or p.XP<d.XP then return no("Earn the mastery shown on this blueprint first.")end
  if cash<d.Price then return no("You need $"..d.Price.." in game cash.")end
  p.Blueprints[arg]=true;return ok("Handcrafted decoration installed at your home.",-d.Price)
 elseif action=="Style"then
  local d=D.Styles[arg];if not d or p.XP<d.XP then return no("Earn more mastery to unlock this accent style.")end;p.Style=arg;return ok("Garden and business accents restyled.")
 elseif action=="Case"then
  if not D.Cases[arg]or p.Mystery~=""then return no("Finish or put away your current mystery first.")end
  p.Mystery=arg;p.Clue=0;p.Variant=math.floor(now/604800)%3+1;p.Solved=false;return ok("Mystery opened. Follow the numbered park clues.")
 elseif action=="PutAway"then p.Mystery="";p.Clue=0;p.Solved=false;return ok("Unfinished mystery put away. Your ending stamps remain.")
 elseif action=="Clue"then
  if p.Mystery==""or p.Clue>=3 or arg~=tostring(p.Clue+1)then return no("Follow your next numbered clue.")end
  p.Clue+=1;return ok(p.Clue==1 and D.Cases[p.Mystery].Notes[p.Variant]or p.Clue==2 and "Ask who uses the object mentioned in your first note."or "All three neighbors meant well. Decide whose clue fits, then choose an ending.")
 elseif action=="Deduce"then
  if p.Mystery==""or p.Clue~=3 or arg~=D.Cases[p.Mystery].People[p.Variant]then return no("That does not fit the clues. Re-read the first note; there is no penalty.")end
  p.Solved=true;return ok("You worked it out! Choose how the story ends.")
 elseif action=="Ending"then
  if not p.Solved or p.Mystery==""or (arg~="1"and arg~="2")then return no("Solve the mystery before choosing its ending.")end
  local key=p.Mystery..":"..arg;local first=not p.Endings[key];if first and cash>999999950 then return no("Spend some cash before claiming this ending.")end
  p.Endings[key]=true;p.Mystery="";p.Clue=0;p.Solved=false;if first then R.Earn(p,20)end;return ok(first and "New ending stamp! $50 and 20 mastery XP."or "Story revisited. Your ending is already in the album.",first and 50 or 0)
 elseif action=="Theme"then if not table.find(D.Themes,arg)then return no("Choose a decorating theme.")end;p.Theme=arg;return ok("Tour theme selected.")
 elseif action=="Tour"then if arg~="Open"and arg~="Close"then return no("Choose open or close.")end;p.TourOpen=arg=="Open";return ok(p.TourOpen and "Tour opened. Your doors are unlocked for visitors."or "Tour closed. You can lock your home again.")
 elseif action=="Hunt"then
  if not table.find(D.Seasons,arg)or p.Festival~=""or now<p.NextHunt then return no("Finish your hunt or wait for the next one.")end
  p.Festival=arg;p.Hunt=0;return ok("Festival hunt started. Visit all four numbered park lanterns.")
 elseif action=="Token"then
  if p.Festival==""or p.Hunt>=4 or arg~=tostring(p.Hunt+1)then return no("Find the next numbered lantern.")end
  if p.Hunt==3 and (p.Tokens[p.Festival]or 0)>995 then return no("Spend festival tokens before finishing.")end
  p.Hunt+=1;if p.Hunt==4 then local season=p.Festival;p.Tokens[season]=(p.Tokens[season]or 0)+4;p.Festival="";p.Hunt=0;p.NextHunt=now+180;R.Earn(p,8);return ok("Hunt complete! Four seasonal tokens earned.")end
  return ok("Lantern found. Look for the next numbered stop.")
 elseif action=="Decor"then
  local season,kind=arg:match("^(%a+):(%a+)$");local price=season and table.find(D.Seasons,season)and D.Decor[kind]
  if not price or p.Decor[arg]then return no("Choose a decoration you do not own yet.")end
  if (p.Tokens[season]or 0)<price then return no("Earn more "..season.." festival tokens first.")end
  p.Tokens[season]-=price;p.Decor[arg]=true;p.Equipped=arg;return ok("Seasonal decoration unlocked and displayed.")
 elseif action=="Equip"then if not p.Decor[arg]then return no("Unlock this decoration first.")end;p.Equipped=arg;return ok("Seasonal decoration displayed.")end
 return no("Choose an available neighborhood activity.")
end
return R
