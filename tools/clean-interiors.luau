-- Deterministic Edit-only refresh; stable gameplay slots and structural footprint.
assert(not game:GetService("RunService"):IsRunning(),"Edit mode required")
local world=workspace.Neighborhood
local R=(world:GetAttribute("HorizontalScale")or 2)/2
local C={Wall=Color3.fromRGB(229,233,227),Trim=Color3.fromRGB(247,247,238),Oak=Color3.fromRGB(177,145,107),Sage=Color3.fromRGB(119,147,135),Ink=Color3.fromRGB(54,70,66),Linen=Color3.fromRGB(213,214,197),Brass=Color3.fromRGB(155,130,84)}
local count=0
local houses=world.Houses:GetChildren();table.sort(houses,function(a,b)return a.Name<b.Name end)
for index,h in ipairs(houses)do
 local b=h.Foundation.CFrame
 local old=h:FindFirstChild("BuiltInInterior");if old then old:Destroy()end
 local rear=h:FindFirstChild("InteriorBackFinish");if rear then rear:Destroy()end
 local folder=Instance.new("Folder");folder.Name="BuiltInInterior";folder.Parent=h
 -- Remove only former interior decoration. Exterior landscaping stays untouched.
 for _,v in ipairs(world.ArtDirection:GetDescendants())do
  if v:IsA("BasePart")then local p=b:PointToObjectSpace(v.Position)
   if math.abs(p.X)<28.5*R and math.abs(p.Z)<24.6*R and p.Y>.5 and p.Y<11 then v:Destroy()end
  end
 end
 local V=h:GetAttribute("InteriorHeightScale")or 1
 local anchor=nil
 local function p(name,size,x,y,z,color,material,solid)
  if anchor then x=x+anchor.X*(R-1);z=z+anchor.Z*(R-1) else x*=R;z*=R;y=.7+(y-.7)*V;size=Vector3.new(size.X*R,size.Y*V,size.Z*R)end
  if name=="CeilingMount"or name=="LinenShade"or name=="Diffuser"then y=.7+(y-.7)*V end
  local v=Instance.new("Part");v.Name=name;v.Size=size;v.CFrame=b*CFrame.new(x,y,z);v.Color=color or C.Wall;v.Material=material or Enum.Material.SmoothPlastic
  v.Anchored=true;v.CanCollide=solid==true;v.CanQuery=solid==true;v.CanTouch=false;v.TopSurface=Enum.SurfaceType.Smooth;v.BottomSurface=Enum.SurfaceType.Smooth;v.Parent=folder;count+=1;return v
 end
 local function box(name,s,x,y,z,c,solid)return p(name,Vector3.new(table.unpack(s)),x,y,z,c,nil,solid)end
 local function cylinder(name,r,height,x,y,z,c,mat)
  local v=p(name,Vector3.new(height,r*2,r*2),x,y,z,c,mat);v.CFrame*=CFrame.Angles(0,0,math.pi/2);v.Shape=Enum.PartType.Cylinder;return v
 end
 local function light(x,z)
  local savedAnchor=anchor;anchor=Vector3.new(x,0,z)
  cylinder("CeilingMount",.65,.12,x,10.85,z,C.Ink)
  cylinder("LinenShade",1.35,.65,x,10.35,z,C.Trim,Enum.Material.SmoothPlastic)
  local lens=cylinder("Diffuser",1.16,.08,x,9.98,z,C.Trim,Enum.Material.Neon)
  local l=Instance.new("PointLight");l.Color=Color3.fromRGB(255,245,224);l.Brightness=.4;l.Range=28;l.Shadows=false;l.Parent=lens;anchor=savedAnchor
 end
 local function rug(name,x,z,w,d)
  box(name,{w,.035,d},x,.728,z,C.Linen)
  box(name.."Inset",{w-.35,.012,d-.35},x,.753,z,Color3.fromRGB(200,207,193))
 end
 -- Thin independent liners keep exterior paint/siding out of the home.
 box("SideLining",{.12,10.55,48.8},-28.43,5.925,0,C.Wall)
 box("SideLining",{.12,10.55,48.8},28.43,5.925,0,C.Wall)
 local rear=box("InteriorBackFinish",{56.8,10.55,.12},0,5.925,24.43,C.Wall);rear.Parent=h
 for _,side in ipairs({-1,1})do
  box("FrontLining",{22,2.8,.12},side*18,2,-24.43,C.Wall)
  box("FrontLintelLining",{28,2.2,.12},side*15,10.05,-24.43,C.Wall)
  box("SideSkirting",{.2,.45,48.6},side*28.32,.94,0,C.Trim)
  box("SideCornice",{.22,.22,48.6},side*28.3,10.85,0,C.Trim)
  box("FrontSkirting",{21,.45,.22},side*18,.94,-24.32,C.Trim)
  box("HallPartition",{.5,10.65,22},side*8,5.825,14,C.Wall,true)
  box("HallSkirting",{.64,.45,21.2},side*8,.94,13.7,C.Trim)
  -- Single generous opening; continuous paired jambs and level lintels.
  box("RoomArchOuter",{5,10.5,.5},side*26,5.75,3,C.Wall,true)
  box("RoomArchInner",{3.6,10.5,.5},side*9.7,5.75,3,C.Wall,true)
  box("RoomArchHeader",{20.6,2.3,.5},side*18.5,10.05,3,C.Wall,true)
  for _,x in ipairs({11.65,23.35})do box("DoorCasing",{.22,8.35,.7},side*x,4.9,3,C.Trim)end
  box("DoorCasingHeader",{12,.25,.7},side*17.5,9,3,C.Trim)
  for _,xx in ipairs({8,28})do box("WindowPostLining",{2.6,7,.12},side*xx,6,-24.26,C.Trim)end
  -- Slim window returns hide siding edges, without covering the glass.
  for _,x in ipairs({9.6,26.4})do box("WindowReturn",{.25,5.6,.38},side*x,6.2,-24.38,C.Trim)end
  for _,y in ipairs({3.4,9})do box("WindowReturn",{17,.25,.38},side*18,y,-24.38,C.Trim)end
 end
 h.Floor.Material=Enum.Material.SmoothPlastic;h.Floor.Color=C.Oak;h.Ceiling.Color=C.Trim;h.Ceiling.Material=Enum.Material.SmoothPlastic
 -- Quiet drawn joinery avoids the noisy, oversized default wood texture.
 for i=0,27 do
  local x=-28+i*2
  if i>0 then local line=box("FloorJoint",{.025,.01,48},x,.707,0,Color3.fromRGB(158,132,102));line:SetAttribute("FloorSeam",true)end
  for j=0,3 do
   local z=-18+j*12+(i%2)*6
   if z<24 then local line=box("BoardJoint",{2,.01,.025},x+1,.707,z,Color3.fromRGB(158,132,102));line:SetAttribute("FloorSeam",true)end
  end
 end
 -- Preserve every slot's identity and position; replace blank raised tiles with quiet markers.
 for _,slot in ipairs(h.DisplaySlots:GetChildren())do if slot:IsA("BasePart")then slot.Transparency=.88;slot.Color=C.Sage;slot.Material=Enum.Material.SmoothPlastic;slot.CanCollide=false end end
 local side=index%2==0 and -1 or 1
 anchor=Vector3.new(side*18.5,0,24.3)
 -- A coherent fitted kitchen: seven repeated modules, recessed sink and dark cooktop.
 box("KitchenToeKick",{14.6,.3,2.8},side*18.5,.9,22.6,C.Ink,true)
 box("KitchenCabinets",{14.6,2.5,3.2},side*18.5,2.3,22.6,C.Sage,true)
 for i=0,6 do
  local x=side*(12.2+i*2.1)
  box("CabinetDoor",{2.02,2.2,.1},x,2.35,20.94,C.Sage)
  box("CabinetPull",{.7,.07,.09},x,3.1,20.83,C.Brass)
 end
 -- Counter splits around the basin rather than a solid slab painted as a sink.
 box("KitchenCounter",{4.8,.18,3.45},side*13.3,3.65,22.6,C.Trim,true)
 box("KitchenCounter",{6.35,.18,3.45},side*22.15,3.65,22.6,C.Trim,true)
 box("SinkRimBack",{3.9,.18,.45},side*17.7,3.65,24.1,C.Trim)
 box("SinkRimFront",{3.9,.18,.5},side*17.7,3.65,21.13,C.Trim)
 box("SinkBasin",{3.15,.12,2.3},side*17.7,3.32,22.6,Color3.fromRGB(125,139,135))
 for _,dx in ipairs({-1.65,1.65})do box("SinkEdge",{.12,.38,2.4},side*17.7+dx,3.5,22.6,C.Trim)end
 cylinder("TapStem",.09,.7,side*17.7,4.04,23.7,C.Brass,Enum.Material.Metal)
 box("TapSpout",{.18,.16,.9},side*17.7,4.4,23.3,C.Brass)
 box("Cooktop",{2.65,.08,2.4},side*23.7,3.8,22.6,C.Ink)
 for _,dx in ipairs({-.68,.68})do for _,dz in ipairs({-.55,.55})do cylinder("Burner",.4,.025,side*23.7+dx,3.85,22.6+dz,Color3.fromRGB(91,107,101),Enum.Material.Metal)end end
 box("Backsplash",{15.1,2.4,.12},side*18.5,4.95,24.25,Color3.fromRGB(215,224,214))
 for i=1,3 do box("TileJoint",{15,.025,.03},side*18.5,3.9+i*.55,24.17,C.Trim)end
 box("FloatingShelf",{12,.18,1},side*18.5,7.1,23.75,C.Oak)
 for i=1,2 do cylinder("Stoneware",.28,.65,side*(14+i),7.51,23.6,C.Trim,Enum.Material.SmoothPlastic)end
 box("Fridge",{3.2,6.7,3.3},side*26.5,4.1,17.3,C.Trim,true)
 box("FridgeSeam",{3.12,.04,.04},side*26.5,5.3,15.62,C.Ink)
 box("FridgeHandle",{.1,1.2,.16},side*25.4,3.9,15.5,C.Ink)
 -- Bedroom: correctly proportioned double bed, a matched pair of nightstands and low rug.
 local bx=-side*18
 anchor=nil
 rug("BedroomRug",bx,17.5,12.5,11.8)
 anchor=Vector3.new(bx,0,24.3)
 box("BedFrame",{7.2,.55,8},bx,1.12,19.8,C.Oak,true)
 box("Mattress",{6.9,.65,7.8},bx,1.72,19.8,C.Trim,true)
 box("Headboard",{7.4,3.4,.32},bx,2.45,23.9,C.Oak,true)
 box("Quilt",{6.95,.22,5.3},bx,2.12,18.55,C.Sage)
 box("QuiltFold",{6.98,.15,.55},bx,2.28,20.7,Color3.fromRGB(160,180,165))
 for _,dx in ipairs({-1.75,1.75})do
  box("Pillow",{2.8,.42,1.6},bx+dx,2.18,22.6,C.Trim)
 end
 for _,dx in ipairs({-5.1,5.1})do
  box("Nightstand",{2,1.55,2},bx+dx,1.48,22.7,C.Oak,true)
  box("DrawerFace",{1.82,.6,.08},bx+dx,1.77,21.65,Color3.fromRGB(188,160,123))
  cylinder("LampBase",.32,.1,bx+dx,2.31,22.7,C.Ink)
  cylinder("LampStem",.07,.6,bx+dx,2.65,22.7,C.Brass)
  cylinder("LampShade",.55,.7,bx+dx,3.24,22.7,C.Trim,Enum.Material.SmoothPlastic)
 end
 -- Two framed, geometric botanical studies: real flat geometry, no blurry generated image.
 for _,dx in ipairs({-2.3,2.3})do
  box("PrintFrame",{3.1,3.6,.12},bx+dx,6.35,24.22,C.Oak)
  box("PrintPaper",{2.8,3.3,.08},bx+dx,6.35,24.1,C.Trim)
  box("BotanicalStem",{.035,2.4,.04},bx+dx,6.2,24.03,C.Sage)
  for j=1,3 do
   local leaf=box("BotanicalLeaf",{.8,.3,.04},bx+dx+(j%2==0 and .32 or -.32),5.4+j*.45,24,C.Sage);leaf.CFrame*=CFrame.Angles(0,0,j%2==0 and .4 or -.4)
  end
 end
 -- Front sitting area lives against the window; possession spaces and central entrance remain clear.
 local sx=-side*18
 anchor=nil
 rug("LivingRug",sx,-17,13,8)
 anchor=Vector3.new(sx,0,-24.3)
 box("SofaPlinth",{8.4,.25,3.1},sx,1,-20.4,C.Ink)
 box("SofaSeat",{8.3,.7,3.3},sx,1.55,-20.4,C.Linen,true)
 box("SofaBack",{8.4,1.7,.55},sx,2.5,-21.75,C.Linen,true)
 for _,dx in ipairs({-4.25,4.25})do box("SofaArm",{.6,1.2,3.3},sx+dx,1.95,-20.4,C.Linen,true)end
 for _,dx in ipairs({-2.65,0,2.65})do box("SeatCushion",{2.57,.25,2.6},sx+dx,2.02,-20.1,C.Trim)end
 box("SofaPillow",{1.4,1.15,.4},sx+3,2.55,-21.1,C.Sage)
 box("CoffeeTable",{5,.18,2},sx,1.65,-16,C.Oak,true)
 for _,dx in ipairs({-1.8,1.8})do box("CoffeeLeg",{.22,.85,1.3},sx+dx,1.17,-16,C.Ink)end
 box("ClosedBook",{1.2,.13,.85},sx+.9,1.81,-16,C.Sage)
 -- An entry console on the other side balances the room without filling player display areas.
 local cx=side*18
 anchor=Vector3.new(cx,0,-24.3)
 box("EntryConsole",{8,.2,1.7},cx,3,-22.8,C.Oak,true)
 for _,dx in ipairs({-3.6,3.6})do box("ConsoleLeg",{.2,2.2,1.3},cx+dx,1.8,-22.8,C.Ink,true)end
 cylinder("EntryBowl",.55,.2,cx,3.22,-22.8,C.Trim)
 anchor=nil
 light(-18,-10);light(18,-10);light(0,12);light(-18,15);light(18,15)
 h:SetAttribute("InteriorDesignVersion","clean-cottage-2")
 h:SetAttribute("InteriorLayout",side==1 and "Garden Kitchen"or"Corner Kitchen")
end
return {Houses=#houses,AuthoredParts=count,Design="clean-cottage-2"}
