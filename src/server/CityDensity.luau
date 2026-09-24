local A=require(script.Parent.CityArchitecture)
local M={}
function M.Houses(w)
 local plots=require(game.ReplicatedStorage.Neighborhood.Shared.PlotLayout)
 for _,h in ipairs(w.Houses:GetChildren())do
  local id=tonumber(h.Name:match('%d+'));local target=plots.Position(id)
  local delta=Vector3.new(target.X-h.Foundation.Position.X,0,0)
  if delta.Magnitude>.01 then
   local box=h.Mailbox;local mailbox=box:GetPivot()
   h:PivotTo(h:GetPivot()+delta);box:PivotTo(mailbox)
   -- Shorten the front path toward the house while retaining its street endpoint.
   local path=h:FindFirstChild('FrontPath')
   if path then local axis=math.abs(path.CFrame.RightVector.X)>.9 and 'X'or 'Z';local s=path.Size
    path.Size=Vector3.new(axis=='X'and math.max(1,s.X-delta.Magnitude)or s.X,s.Y,axis=='Z'and math.max(1,s.Z-delta.Magnitude)or s.Z)
    path.Position-=delta/2
   end
  end
 end
 w:SetAttribute('HouseRowSpacing',218)
end
function M.Skyline(root)
 local old=root:FindFirstChild('Skyline');if old then old:Destroy()end
 local f=Instance.new('Folder');f.Name='Skyline';f.Parent=root
 local palette={A.Brick,Color3.fromRGB(178,159,131),Color3.fromRGB(132,146,144),Color3.fromRGB(184,174,157)}
 local n=0;local rejected=0
 local function block(x,z)
  local decor={}
  -- A conservative square includes rotated cornices, stoops and entrance paving.
  local params=OverlapParams.new();params.FilterType=Enum.RaycastFilterType.Exclude;params.FilterDescendantsInstances={f}
  for _,v in ipairs(workspace:GetPartBoundsInBox(CFrame.new(x,7,z),Vector3.new(48,12,48),params))do
   if v.CanCollide and v.Position.Y>1 then
    local tree=v:FindFirstAncestor('ParkTree')
    if tree and tree:IsDescendantOf(root.Parent.ArtDirection)then decor[tree]=true
    elseif v:IsDescendantOf(root.Parent.GardenDetails)and v.Name:find('PathLamp')then
     for _,lamp in ipairs(root.Parent.GardenDetails:GetChildren())do if lamp:IsA('BasePart')and lamp.Name:find('PathLamp')and(Vector3.new(lamp.Position.X,0,lamp.Position.Z)-Vector3.new(v.Position.X,0,v.Position.Z)).Magnitude<3 then decor[lamp]=true end end
    else rejected+=1;return end
   end
  end
  -- Do not build on either body of terrain water.
  local region=Region3.new(Vector3.new(x-24,-4,z-24),Vector3.new(x+24,4,z+24)):ExpandToGrid(4)
  local materials=workspace.Terrain:ReadVoxels(region,4)
  for _,ys in ipairs(materials)do for _,zs in ipairs(ys)do for _,mat in ipairs(zs)do if mat==Enum.Material.Water then rejected+=1;return end end end end
  for item in pairs(decor)do item:Destroy()end
  n+=1
  local floors=({2,3,2,4,3,5})[(n-1)%6+1];local width=({28,32,30})[(n-1)%3+1]
  local center=Vector3.new(x,0,z)
  local building,p=A.Building(f,'NeighborhoodBlock'..n,center,width,24,floors,palette[(n-1)%#palette+1],'NEIGHBORHOOD LOUNGE')
  local levels={};for level=0,floors-1 do local y=level*12;table.insert(levels,y);A.Lounge(p,y);A.Table(p,5,y,-6)end
  A.Lifts(p,levels,'Neighborhood lounge')
  local toward=Vector3.new(-x,0,-z).Unit
  local rotation=CFrame.lookAt(center,center+toward)*CFrame.new(-center)
  building:PivotTo(rotation*building:GetPivot())
  building:SetAttribute('Entry',rotation*building:GetAttribute('Entry'))
  for _,v in ipairs(building:GetDescendants())do local destination=v:GetAttribute('Destination');if typeof(destination)=='Vector3'then v:SetAttribute('Destination',rotation*destination)end end
  building:SetAttribute('Floors',floors);building:SetAttribute('FacingCenter',true);building:SetAttribute('BlockCenter',center)
  building:SetAttribute('Role','Furnished neighborhood lounge')
 end
 -- Inner infill is considered first; occupied sites remain open for existing activities.
 for _,side in ipairs({-1,1})do for _,z in ipairs({-180,-120,-60,0,60,120,180})do block(side*172,z)end end
 for _,side in ipairs({-1,1})do for _,z in ipairs({-210,-126,-42,42,126,210})do block(side*238,z)end end
 for _,side in ipairs({-1,1})do for _,z in ipairs({-240,-180,-120,-60,0,60,120,180,240})do block(side*306,z)end end
 for _,z in ipairs({-310,258})do for _,x in ipairs({-240,-180,-120,-60,0,60,120,180,240})do block(x,z)end end
 f:SetAttribute('TowerCount',n);f:SetAttribute('RejectedOccupiedLots',rejected)
 f:SetAttribute('Design','Closer two-to-five-storey blocks facing the town center')
end
return M
