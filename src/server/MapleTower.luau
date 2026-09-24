local F=require(script.Parent.RecreationFactory)
local M={}
function M.Build(w)
 local old=w:FindFirstChild("MapleTower");if old then old:Destroy()end
 local m=Instance.new("Model");m.Name="MapleTower";m.ModelStreamingMode=Enum.ModelStreamingMode.Atomic;m.Parent=w
 local base=Vector3.new(270,0,-165);local cream=Color3.fromRGB(221,216,197);local green=Color3.fromRGB(56,85,78);local wood=Color3.fromRGB(165,132,96)
 local function p(n,size,x,y,z,c,solid,class)return F.Part(m,n,Vector3.new(table.unpack(size)),CFrame.new(base+Vector3.new(x,y,z)),c,solid,class)end
 p("Foundation",{38,1,34},0,.5,0,cream)
 for _,x in ipairs({-18,18})do p("SideWall",{1,58,32},x,30,0,cream)end
 p("RearWall",{36,58,1},0,30,16,cream)
 for _,x in ipairs({-12,12})do p("FrontPiers",{12,58,1},x,30,-16,cream)end
 for floor=1,5 do
  local y=floor*11;p("FloorBand",{38,.7,34},0,y,0,green)
  if floor<5 then local glass=p("AtriumWindow",{12,10.3,.3},0,y+5.5,-16,Color3.fromRGB(160,192,192),true);glass.Material=Enum.Material.Glass;glass.Transparency=.2 end
  for _,x in ipairs({-12,12})do local glass=p("Window",{8,7,.3},x,y-4,-16.6,Color3.fromRGB(141,180,180),false);glass.Material=Enum.Material.Glass;glass.Transparency=.18 end
 end
 p("RoofDeck",{36,1,32},0,56,0,wood)
 for _,x in ipairs({-18,18})do p("RoofRail",{.3,4,32},x,58.5,0,green)end
 for _,z in ipairs({-16,16})do p("RoofRail",{36,4,.3},0,58.5,z,green)end
 for _,x in ipairs({-11,11})do
  p("RoofPlanter",{7,1.5,4},x,57.5,10,green)
  local crown=p("RoofShrub",{6,3,3},x,59.5,10,Color3.fromRGB(111,149,100),false);crown.Shape=Enum.PartType.Ball
  p("LookoutSeat",{6,.4,2},x,58,-9,wood,true,"Seat")
  for _,dx in ipairs({-2,2})do p("LookoutSeatLeg",{.4,1.3,1.5},x+dx,57.25,-9,green)end
 end
 p("LibraryDesk",{9,.5,4},-10,3,7,wood);p("DeskBase",{1,3,1},-10,1.5,7,green)
 for _,x in ipairs({-12,-8})do p("ReadingSeat",{2,.4,2},x,1.8,3,green,true,"Seat");for _,dx in ipairs({-.7,.7})do p("ReadingSeatLeg",{.3,.6,1.5},x+dx,1.3,3,wood)end end
 for _,x in ipairs({-15,-8})do
  p("Bookshelf",{5,7,2},x,4,13.8,wood)
  for row=1,3 do for book=1,6 do p("Book",{.55,1.5,.7},x-2+book*.6,row*2,12.6,book%2==0 and cream or green,false)end end
 end
 local fascia=p("TowerName",{26,3,.3},0,9,-16.8,green,false);F.Sign(fascia,"MAPLE HOUSE - LIBRARY & LOOKOUT")
 p("EntranceWalk",{6,.2,22},0,.15,-27,cream);p("StreetConnection",{57,.2,6},-28.5,.15,-38,cream)
 local function lift(name,y,label)
  local panel=p(name,{2,3,.4},10,y+2,8,green,false);panel:SetAttribute("Action","TowerLift");panel:SetAttribute("Roof",y<10);F.Sign(panel,label)
  local q=Instance.new("ProximityPrompt");q.Style=Enum.ProximityPromptStyle.Custom;q.ObjectText="Maple House lift";q.ActionText=label;q.MaxActivationDistance=10;q:SetAttribute("Action","TowerLift");q.Parent=panel
 end
 lift("GroundLift",1,"Rooftop lookout");lift("RoofLift",56,"Library lobby")
 return m
end
function M.Init(context)
 M.Build(workspace.Neighborhood)
 context.Interactions:Register("TowerLift",function(player,target)
  if player:GetAttribute("Carrying")then return false,"Set down the carried item before using the lift."end
  local c=player.Character;local h=c and c:FindFirstChildOfClass("Humanoid");if not h or h.Sit then return false,"Stand up before using the lift."end
  c:PivotTo(CFrame.new(278,target:GetAttribute("Roof")and 60 or 5,-160));return true,target:GetAttribute("Roof")and "Maple House rooftop lookout."or "Maple House library."
 end)
end
return M
