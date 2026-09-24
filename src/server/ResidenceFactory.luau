local D=require(game.ReplicatedStorage.Neighborhood.Shared.ResidenceDefinitions)
local A=require(script.Parent.CityArchitecture)
local F={}
function F.Create(h,r)
 local m=Instance.new('Model');m.Name='ResidenceFloors';m.ModelStreamingMode=Enum.ModelStreamingMode.Atomic
 local basis=h.Foundation.CFrame;local colors={Sage=Color3.fromRGB(121,151,135),Terracotta=Color3.fromRGB(177,111,87),Blue=Color3.fromRGB(100,133,155)}
 local accent=colors[r.Style];local cream=A.Cream;local ink=A.Ink
 local function p(n,size,x,y,z,c,mat,solid,class)
  local v=A.Part(m,n,size,Vector3.zero,c or cream,mat,solid,class);v.CFrame=basis*CFrame.new(x,y,z);return v
 end
 local function lift(level)
  local y=level==1 and .75 or 12.4*(level-1)+.45
  local function button(name,x,destination,label)
   local t=p(name,{.65,1.2,.4},x,y+3,-9.4,ink,nil,false)
   t:SetAttribute('HouseId',h.Name);t:SetAttribute('Floor',destination);A.Prompt(t,'HomeLift','Home lift',label)
  end
  p('LiftMat',{5,.08,5},0,y+.1,-11,ink,Enum.Material.Metal)
  if level<D.Tiers[r.Tier].Floors then button('LiftUp',2.6,level+1,'Up to floor '..(level+1))end
  if level>1 then button('LiftDown',-2.6,level-1,'Down to floor '..(level-1))end
  local plaque=p('FloorLabel',{4,1,.15},0,y+6,-8.3,ink,nil,false);A.Sign(plaque,'FLOOR '..level)
 end
 if r.Tier>1 then lift(1);local plaque=p('ResidencePlaque',{10,1.5,.16},0,13.65,-17.4,ink,nil,false);A.Sign(plaque,D.Tiers[r.Tier].Name..' • Renovation '..r.Renovations)end
 for level=2,D.Tiers[r.Tier].Floors do
  local y=12.4*(level-1)
  p('ResidenceSlab',{39,.5,32},0,y,-1,A.Wood,Enum.Material.WoodPlanks)
  -- Separate wall bands and inset glazing leave real, transparent window openings.
  for _,z in ipairs({-17,15})do
   p('Sill',{39,2,.5},0,y+1.25,z,accent,Enum.Material.Brick)
   p('Lintel',{39,1,.5},0,y+11.65,z,cream)
   for _,x in ipairs({-16,-8,0,8,16})do
    local pane=p('Glass',{7.5,8.5,.16},x,y+6.6,z,Color3.fromRGB(158,195,198),Enum.Material.Glass);pane.Transparency=.55
   end
   for _,x in ipairs({-19.25,-12,-4,4,12,19.25})do p('Mullion',{.28,9,.65},x,y+6.7,z,ink)end
  end
  for _,x in ipairs({-19.25,19.25})do p('SideWall',{.5,11.9,31},x,y+6.2,-1,accent,Enum.Material.Brick)end
  p('Ceiling',{38,.3,31},0,y+12.05,-1,cream)
  local light=p('CeilingLight',{2,.15,2},0,y+11.7,0,cream,Enum.Material.Neon,false)
  local lamp=Instance.new('PointLight');lamp.Range=28;lamp.Brightness=.7;lamp.Color=Color3.fromRGB(255,234,206);lamp.Parent=light
  local style=level==3 and 'Bedroom' or level==5 and 'Garden' or 'Lounge'
  p('Rug',{16,.06,13},-7,y+.3,3,accent,nil,false)
  if style=='Bedroom'then
   p('BedBase',{8,1,10},-9,y+.9,4,ink);p('Mattress',{7.8,.7,9.8},-9,y+1.75,4,cream);p('Cover',{7.8,.12,6},-9,y+2.17,2,accent)
   for _,x in ipairs({-11,-7})do p('Pillow',{3,.45,2},x,y+2.3,7.5,cream)end
   p('Wardrobe',{5,8,3},12,y+4.3,6,A.Wood)
  else
   p('SofaBack',{10,3,.6},-8,y+2.3,10,accent)
   for _,x in ipairs({-11,-5})do p('FamilySeat',{4.5,.7,3.5},x,y+1.9,8,accent,nil,true,'Seat')end
   p('CoffeeTable',{8,.35,4},-8,y+1.8,2,A.Wood);for _,x in ipairs({-11,-5})do p('TableLeg',{.4,1.5,3},x,y+.9,2,ink)end
   if style=='Garden'then for _,x in ipairs({-15,13})do
    p('Planter',{4,1.5,8},x,y+1,5,cream,Enum.Material.Concrete)
    for _,z in ipairs({2,5,8})do local bush=p('Plant',{2.4,3,2.4},x,y+3,z,Color3.fromRGB(78,116,72),Enum.Material.Grass,false);bush.Shape=Enum.PartType.Ball end
   end end
  end
  p('Desk',{7,.35,3},10,y+3,0,A.Wood);for _,x in ipairs({7,13})do p('DeskLeg',{.5,2.6,2.5},x,y+1.5,0,ink)end
  p('DeskSeat',{2.5,.5,2.5},10,y+1.8,-3,accent,nil,true,'Seat')
  p('Bookcase',{5,7,1.5},12,y+3.8,12,A.Wood);for n=1,4 do p('Books',{4.4,.8,1.6},12,y+n*1.4,11.8,n%2==0 and accent or ink,nil,false)end
  lift(level)
 end
 if r.Tier>1 then local top=12.4*D.Tiers[r.Tier].Floors
  p('ResidenceRoof',{40,.6,33},0,top+.3,-1,ink,Enum.Material.Slate)
  for _,z in ipairs({-17,15})do p('Crown',{39.7,1,.55},0,top+.85,z,cream)end
 end
 return m
end
return F
