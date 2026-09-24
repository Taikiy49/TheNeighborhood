-- Shared, intentionally small architectural vocabulary for Maple Heights.
local F=require(script.Parent.RecreationFactory)
local A={Ink=Color3.fromRGB(45,66,62),Cream=Color3.fromRGB(230,219,195),Brick=Color3.fromRGB(157,91,69),Wood=Color3.fromRGB(151,111,76)}
function A.Part(parent,name,size,position,color,material,solid,class)
 local p=F.Part(parent,name,Vector3.new(table.unpack(size)),CFrame.new(position),color or A.Cream,solid,class)
 p.Material=material or Enum.Material.SmoothPlastic;return p
end
function A.Sign(p,text)F.Sign(p,text)end
function A.Prompt(p,action,title,label)
 p:SetAttribute('Action',action)
 local q=Instance.new('ProximityPrompt');q.Style=Enum.ProximityPromptStyle.Custom;q.ObjectText=title;q.ActionText=label;q.MaxActivationDistance=10;q.RequiresLineOfSight=true;q:SetAttribute('Action',action);q.Parent=p
end
function A.Building(parent,name,center,width,depth,floors,color,title)
 local m=Instance.new('Model');m.Name=name;m.ModelStreamingMode=Enum.ModelStreamingMode.Atomic;m.Parent=parent;m:SetAttribute('Enterable',true)
 local function p(n,s,x,y,z,c,mat,solid,class)return A.Part(m,n,s,center+Vector3.new(x,y,z),c,mat,solid,class)end
 local h=floors*12;local w=width/2;local d=depth/2
 if not table.find({'MarketAvenue','Uptown','OldTown'},parent.Name)then p('BuildingApron',{width+6,.16,depth+6},0,.17,0,Color3.fromRGB(172,169,158),Enum.Material.Pavement)end
 p('Floor',{width,.4,depth},0,.2,0,A.Wood,Enum.Material.WoodPlanks)
 p('RearWall',{width,h,.6},0,h/2+.4,d,color,Enum.Material.Brick)
 for _,x in ipairs({-w,w})do p('SideWall',{.6,h,depth},x,h/2+.4,0,color,Enum.Material.Brick)end
 -- A single eight-stud entrance and storefront glazing; upper floors have real slabs.
 for _,side in ipairs({-1,1})do
  local span=w-4;local x=side*(4+span/2)
  p('StoreSill',{span,2,.6},x,1.4,-d,color,Enum.Material.Brick)
  local glass=p('StoreGlass',{span-.5,6,.18},x,5.4,-d,Color3.fromRGB(142,184,190),Enum.Material.Glass);glass.Transparency=.55
 end
 p('Fascia',{width,3.5,.7},0,10.6,-d,color,Enum.Material.Brick)
 local sign=p('Nameplate',{width-3,2,.2},0,10.6,-d-.5,A.Ink,nil,false);A.Sign(sign,title)
 for floor=1,floors-1 do
  p('UpperFloor',{width,.45,depth},0,floor*12+.4,0,A.Wood,Enum.Material.WoodPlanks)
  p('UpperFront',{width,12,.6},0,floor*12+6.4,-d,color,Enum.Material.Brick)
  p('StringCourse',{width+.7,.4,depth+.7},0,floor*12+.5,0,A.Cream)
  for x=-w+5,w-4,8 do
   p('WindowFrame',{4.6,6.6,.45},x,floor*12+6,-d-.5,A.Cream)
   p('WindowGlass',{3.9,5.8,.15},x,floor*12+6,-d-.8,Color3.fromRGB(90,132,141),Enum.Material.Glass,false)
   p('WindowMullion',{.2,5.8,.2},x,floor*12+6,-d-.95,A.Cream,nil,false)
  end
  for _,x in ipairs({-w-.4,w+.4})do for _,z in ipairs({-6,5})do
   p('SideWindowFrame',{.4,6.5,4.5},x,floor*12+6,z,A.Cream)
   p('SideWindowGlass',{.1,5.7,3.8},x+(x>0 and .25 or -.25),floor*12+6,z,Color3.fromRGB(90,132,141),Enum.Material.Glass,false)
  end end
 end
 p('Roof',{width+1,.65,depth+1},0,h+.5,0,A.Ink,Enum.Material.Slate)
 for _,z in ipairs({-d,d})do p('RoofRail',{width+1,3,.35},0,h+2,z,A.Ink,Enum.Material.Metal)end
 for _,x in ipairs({-w,w})do p('RoofRail',{.35,3,depth},x,h+2,0,A.Ink,Enum.Material.Metal)end
 p('Cornice',{width+2,.6,depth+2},0,h+.1,0,A.Cream)
 local entry=center+Vector3.new(0,3,-d-4);m:SetAttribute('Entry',entry)
 p('EntrancePaving',{8,.18,8},0,.22,-d-4,A.Cream,Enum.Material.Pavement)
 p('DoorCanopy',{10,.3,3},0,8.5,-d-1.5,A.Ink,Enum.Material.Metal)
 for floor=0,floors-1 do
  local lamp=p('CeilingLight',{2,.2,2},0,floor*12+11.6,0,A.Cream,Enum.Material.Neon,false)
  local light=Instance.new('PointLight');light.Range=22;light.Brightness=.65;light.Color=Color3.fromRGB(255,231,194);light.Parent=lamp
 end
 p('DoorLight',{1,1,.7},-5,8,-d-.5,A.Cream,Enum.Material.Neon,false)
 local l=Instance.new('PointLight');l.Range=18;l.Brightness=.5;l.Color=Color3.fromRGB(255,222,177);l.Parent=m.DoorLight
 return m,p
end
function A.Table(p,x,y,z)
 if y>0 then y+=.225 end
 p('TableTop',{5,.3,3},x,y+2.5,z,A.Wood);p('TableLeg',{.6,2.4,.6},x,y+1.2,z,A.Ink)
 for _,dx in ipairs({-3.5,3.5})do
  p('Seat',{2,.4,2},x+dx,y+1.5,z,A.Ink,nil,true,'Seat');p('ChairBack',{2,1.8,.3},x+dx,y+2.4,z+1,A.Ink)
  for _,lx in ipairs({-.75,.75})do for _,lz in ipairs({-.75,.75})do p('ChairLeg',{.25,1.3,.25},x+dx+lx,y+.65,z+lz,A.Wood)end end
 end
end
function A.Lounge(p,y)
 if y>0 then y+=.225 end
 p('Sofa',{8,1,3},-6,y+1.5,5,A.Ink);p('SofaBack',{8,2,.5},-6,y+2.6,6.5,A.Ink)
 for _,x in ipairs({-9,-3})do for _,z in ipairs({4,6})do p('SofaFoot',{.5,.6,.5},x,y+.7,z,A.Wood)end end
 p('CoffeeTable',{5,.4,3},-6,y+1.6,0,A.Wood);p('CoffeeLeg',{.6,1.5,.6},-6,y+.8,0,A.Ink)
 p('Bookcase',{7,7,1.5},-7,y+3.9,10,A.Wood)
 for row=1,3 do for i=1,7 do p('Book',{.5,1.6,.4},-10+i*.75,y+row*2,9,A.Cream,nil,false)end end
end
function A.Lifts(p,levels,title)
 for i,y in ipairs(levels)do
  local nextY=levels[i%#levels+1]
  p('LiftAlcove',{6,8,.3},8,y+4,10,A.Ink)
  local panel=p('LiftPanel',{2,3,.3},8,y+3,9.5,A.Cream,nil,false)
  panel:SetAttribute('Destination',panel.Position+Vector3.new(0,nextY-y,-4))
  A.Prompt(panel,'CityLift',title,nextY==0 and 'Return to lobby' or 'Visit floor '..tostring(nextY/12+1))
  A.Sign(panel,nextY==0 and 'LOBBY' or 'UPSTAIRS')
  panel.SurfaceGui.TextLabel.TextColor3=A.Ink
 end
end
return A
