-- Geometry-only imports; see docs/STREET-ART.md for provenance and QA.
local Art=require(script.Parent.CuratedArchitecture)
local M={Signals={}}
function M.Phase(t,axis)
 local p=t%40
 if axis=='X'then return p<10 and 'Green'or p<13 and 'Yellow'or 'Red'end
 return p>=14 and p<24 and 'Green'or p>=24 and p<27 and 'Yellow'or 'Red'
end
-- A dedicated all-red pedestrian interval leaves time to cross the full street.
function M.CanCross(junction,t)
 for _,signal in ipairs(M.Signals)do
  if (signal.Position-junction).Magnitude<2 then local phase=((t or os.clock())+signal.Offset)%40;return phase>=28 and phase<=32 end
 end
 return false
end
function M.ShouldStop(position,direction)
 local axis=math.abs(direction.X)>math.abs(direction.Z)and 'X'or 'Z'
 for _,s in ipairs(M.Signals)do
  local delta=s.Position-position;local ahead=delta:Dot(direction)
  local lateral=math.abs(axis=='X'and delta.Z or delta.X)
  if ahead>17 and ahead<30 and lateral<12 and M.Phase(os.clock()+s.Offset,axis)~='Green'then return true end
 end
 return false
end
function M.Init()
 local W=require(script.Parent.CoastalWorld);local root=Instance.new('Folder');root.Name='StreetDressing';root.Parent=W.Root
 local function part(name,size,cf,color,material)
  local p=Instance.new('Part');p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color;p.Material=material or Enum.Material.Metal;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Parent=root;return p
 end
 local degree={};for _,edge in ipairs(W.Edges)do for _,key in ipairs(edge)do degree[key]=(degree[key]or 0)+1 end end
 for key,position in pairs(W.Nodes)do if degree[key]>=3 then
  local m=Art.Place('SuspendedSignal',root,CFrame.new(position.X,15,position.Z));m.Name='JunctionSignal_'..key
  local hook=m:FindFirstChild('Hook',true);hook.Transparency=1
  for _,p in ipairs(m:GetDescendants())do if p:IsA('BasePart')and p.Name=='Pole'then
   local a=p.Position+Vector3.new(0,p.Size.Y/2,0);local b=hook.Position;local cable=part('SuspensionCable',Vector3.new(.12,.12,(b-a).Magnitude),CFrame.lookAt((a+b)/2,b),Color3.fromRGB(48,54,59));cable.Parent=m
  end end
  table.insert(M.Signals,{Model=m,Position=position,Offset=(math.abs(position.X)+math.abs(position.Z))%9})
 end end
 local colors={Red=Color3.fromRGB(247,62,49),Yellow=Color3.fromRGB(255,192,55),Green=Color3.fromRGB(69,227,119)}
 local function update()
  for _,s in ipairs(M.Signals)do
   for _,v in ipairs(s.Model:GetDescendants())do if v:IsA('BasePart')and colors[v.Name]then
    local axis=(v.Parent.Name=='EFace'or v.Parent.Name=='WFace')and 'X'or 'Z'
    local on=M.Phase(os.clock()+s.Offset,axis)==v.Name
    v.Material=on and Enum.Material.Neon or Enum.Material.SmoothPlastic;v.Color=on and colors[v.Name]or colors[v.Name]:Lerp(Color3.new(),.82)
   end end
   s.Model:SetAttribute('Walk',M.CanCross(s.Position))
   s.Model:SetAttribute('EastWest',M.Phase(os.clock()+s.Offset,'X'));s.Model:SetAttribute('NorthSouth',M.Phase(os.clock()+s.Offset,'Z'))
  end
 end
 update();task.spawn(function()while root.Parent do task.wait(.25);update()end end)
 -- Swap the old ball crowns and flat palm blades for imported tree meshes.
 local positions={};local list=W.Root:GetDescendants()
 for _,v in ipairs(list)do if v:IsA('BasePart')and(v.Name=='Trunk'or v.Name=='TallTreeTrunk')then table.insert(positions,{v.Position.X,v.Position.Z,v.Size.Y>15});v:Destroy()
 elseif v:IsA('BasePart')and(v.Name=='TreeCrown'or v.Name=='PalmFrond'or v.Name=='LayeredCanopy')then v:Destroy()end end
 local trees=0;local used={}
 local function tree(x,z,palm,height)
  for _,at in ipairs(used)do if(Vector2.new(x,z)-at).Magnitude<15 then return end end
  local key=palm and 'CoastPalm'or 'StreetTree';local _,size=game.ServerStorage.CuratedArt[key]:GetBoundingBox();local h=height or(22+(trees%4)*3)
  Art.Place(key,root,CFrame.new(x,h/2,z)*CFrame.Angles(0,trees*.83,0),size*(h/size.Y));trees+=1;table.insert(used,Vector2.new(x,z))
 end
 for _,d in ipairs(positions)do tree(d[1],d[2],d[1]>80,d[3]and 30 or 22)end
 -- Keep extra trees outside roads, buildings, doors, and private plots.
 local shells={};for _,m in ipairs(workspace.Neighborhood:GetDescendants())do if m:IsA('Model')then local f=m:FindFirstChild('Floor')or m:FindFirstChild('Foundation');if f and f:IsA('BasePart')then table.insert(shells,f)end end end
 local function clear(x,z)
  local pos=Vector3.new(x,0,z)
  for _,f in ipairs(shells)do local q=f.CFrame:PointToObjectSpace(pos);if math.abs(q.X)<f.Size.X/2+14 and math.abs(q.Z)<f.Size.Z/2+14 then return false end end
  for _,r in ipairs(W.Root.Roads:GetChildren())do if r:IsA('BasePart')and r.Material==Enum.Material.Asphalt then local q=r.CFrame:PointToObjectSpace(pos);if math.abs(q.X)<r.Size.X/2+9 and math.abs(q.Z)<r.Size.Z/2+9 then return false end end end
  return true
 end
 for _,x in ipairs({50,110,270,330,490,550})do for z=-550,550,42 do if clear(x,z)then tree(x,z,x>80,25+(trees%3)*3)end end end
 for _,z in ipairs({-350,-30,110,230,570})do for x=-510,460,42 do if clear(x,z)then tree(x,z,x>100,23+(trees%3)*3)end end end
 -- Small, deliberate gathering pockets in the park and between downtown blocks.
 local tables=0
 for _,d in ipairs({{-390,4},{-330,4},{-210,4},{-150,4},{260,125},{340,125},{260,-225},{340,-225}})do
  if clear(d[1],d[2])then
   Art.Place('PicnicTable',root,CFrame.new(d[1],1.8,d[2]),Vector3.new(6.5,3.5,9));tables+=1
   for _,side in ipairs({-1,1})do Art.Place('Planter',root,CFrame.new(d[1]+side*8,1.8,d[2]),Vector3.new(3,3.6,3))end
  end
 end
 root:SetAttribute('Signals',#M.Signals);root:SetAttribute('ImportedTrees',trees);root:SetAttribute('PicnicTables',tables)
end
return M
