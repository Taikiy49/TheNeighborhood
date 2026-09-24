-- Reproducible, idempotent district migration. Does not touch player data.
local M={}
local function p(parent,name,size,pos,color)
 local v=Instance.new("Part");v.Name=name;v.Size=size;v.Position=pos;v.Anchored=true;v.Material=Enum.Material.SmoothPlastic;v.Color=color;v.TopSurface=Enum.SurfaceType.Smooth;v.BottomSurface=Enum.SurfaceType.Smooth;v.Parent=parent;return v
end
function M.Water()
 local terrain=workspace.Terrain
 local region=Region3.new(Vector3.new(-304,-16,-28),Vector3.new(-224,0,112)):ExpandToGrid(4)
 local size=region.Size/4;local corner=region.CFrame.Position-region.Size/2
 local mats,occ={},{}
 for x=1,size.X do mats[x]={};occ[x]={};for y=1,size.Y do mats[x][y]={};occ[x][y]={};for z=1,size.Z do
  local at=corner+Vector3.new(x-.5,y-.5,z-.5)*4
  local dz=math.max(0,math.abs(at.Z-42)-30)
  local radius=math.sqrt((at.X+264)^2+dz^2)
  local depth=radius<22 and 12 or radius<29 and 8 or radius<33 and 4 or 0
  mats[x][y][z]=at.Y>=-depth and depth>0 and Enum.Material.Water or Enum.Material.Sand;occ[x][y][z]=1
 end end end
 terrain:WriteVoxels(region,4,mats,occ);terrain.WaterColor=Color3.fromRGB(60,132,143);terrain.WaterTransparency=.35;terrain.WaterWaveSize=.12;terrain.WaterWaveSpeed=5
end
function M.ClearPaths(w)
 for _,path in ipairs(w.WalkNetwork:GetChildren())do if path.Name=="StreetSidewalk"then path.Size=Vector3.new(6,.2,math.abs(path.Position.X)>70 and 388 or 338)end end
 if w:GetAttribute("RenewalPathsClear")then return end
 for _,h in ipairs(w.Houses:GetChildren())do
  local box=h.Mailbox;local at=box:GetPivot().Position;local sign=h.Foundation.Position.X<0 and -1 or 1
  box:PivotTo(box:GetPivot()+Vector3.new(sign*82-at.X,0,0))
 end
 for _,tree in ipairs(w.ArtDirection.GardenDistrict.Orchard:GetChildren())do
  if tree:IsA("Model")and tree:FindFirstChild("Trunk")and math.abs(tree.Trunk.Position.Z-194)<6 then tree:PivotTo(tree:GetPivot()+Vector3.new(0,0,10))end
 end
 local centers={}
 for _,v in ipairs(w.GardenDetails:GetChildren())do if v.Name=="StonePlanter"and math.abs(v.Position.Z-60)<4 then table.insert(centers,v.Position)end end
 for _,v in ipairs(w.GardenDetails:GetChildren())do if v:IsA("BasePart")then for _,c in ipairs(centers)do if(Vector3.new(v.Position.X,0,v.Position.Z)-Vector3.new(c.X,0,c.Z)).Magnitude<4 then v.Position+=Vector3.new(0,0,7);break end end end end
 w:SetAttribute("RenewalPathsClear",true)
end
function M.Apply(w)
 M.Water()
 if w:GetAttribute("DistrictRenewal")=="v1"then M.ClearPaths(w);return end
 local Plots=require(game.ReplicatedStorage.Neighborhood.Shared.PlotLayout)
 -- Attach authored cottage trim to its house before moving plots.
 local cottages=w.ArtDirection.GardenDistrict.Cottages
 for _,v in ipairs(cottages:GetChildren())do
  local pos=v:IsA("Model")and v:GetPivot().Position or v:IsA("BasePart")and v.Position
  if pos then
   local best,dist
   for _,h in ipairs(w.Houses:GetChildren())do local d=(h.Foundation.Position-pos).Magnitude;if not dist or d<dist then best,dist=h,d end end
   if best then local f=best:FindFirstChild("ExteriorTrim")or Instance.new("Folder");f.Name="ExteriorTrim";f.Parent=best;v.Parent=f end
  end
 end
 for _,v in ipairs(w.DetailCorrections:GetChildren())do if v.Name=="CottageRidgeCap"then
  local best,dist;for _,h in ipairs(w.Houses:GetChildren())do local d=(h.Foundation.Position-v.Position).Magnitude;if not dist or d<dist then best,dist=h,d end end;v.Parent=best.ExteriorTrim
 end end
 for id=9,12 do
  local h=w.Houses[id<=10 and "House01"or "House05"]:Clone();h.Name=string.format("House%02d",id);h.Parent=w.Houses
  h:SetAttribute("Address",tostring(100+id).." Maple Street")
  for _,v in ipairs(h:GetDescendants())do if v:GetAttribute("HouseId")then v:SetAttribute("HouseId",h.Name)end end
 end
 for _,h in ipairs(w.Houses:GetChildren())do
  local id=tonumber(h.Name:match("%d+"));local pos=Plots.Position(id);local delta=Vector3.new(pos.X,h.Foundation.Position.Y,pos.Y)-h.Foundation.Position
  h:PivotTo(h:GetPivot()+delta)
  h:SetAttribute("OwnerUserId",0);h:SetAttribute("OwnerName",nil)
  for _,v in ipairs(h:GetChildren())do
   if v.Name=="GardenFence"or v.Name=="RearFence"then v:Destroy()
   elseif v.Name=="Lawn"then v.Size=Vector3.new(56,v.Size.Y,80)
   elseif v.Name=="FrontPath"then v.Transparency=1;v.CanCollide=false end
  end
  local trim=h:FindFirstChild("ExteriorTrim");if trim then for _,v in ipairs(trim:GetChildren())do if v.Name=="Walkway"or v.Name=="ParkTree"then v:Destroy()end end end
  h.Mailbox.Sign.SurfaceGui.TextLabel.Text=h:GetAttribute("Address").."\nNeighbor's home"
  if h:FindFirstChild("AddressPlaque")then for _,v in ipairs(h.AddressPlaque:GetDescendants())do if v:IsA("TextLabel")then v.Text=tostring(100+id)end end end
 end
 -- Replace the layered sidewalk grid with one road loop and clean, joined footpaths.
 for _,v in ipairs(w.Map:GetChildren())do if table.find({"Sidewalk","ParkCrosswalk","BackyardShortcut","LaneMark"},v.Name)then v:Destroy()end end
 local promenades=w.ArtDirection.GardenDistrict.Promenades
 for _,v in ipairs(promenades:GetChildren())do if v.Name=="Walkway"then v:Destroy()end end
 local f=Instance.new("Folder");f.Name="WalkNetwork";f.Parent=w
 local stone=Color3.fromRGB(189,183,164)
 local function path(name,x,z,sx,sz)local a=p(f,name,Vector3.new(sx,.2,sz),Vector3.new(x,.1,z),stone);a.Material=Enum.Material.Pavement;return a end
 for _,x in ipairs({-75,75,-43,43})do path("StreetSidewalk",x,0,6,332)end
 for _,z in ipairs({-194,194})do path("MarketCrosswalk",0,z,156,6)end
 -- Connections avoid drawing pavement over the asphalt. Zebra paint marks crossings.
 for _,x in ipairs({-58.8,58.8})do for _,z in ipairs({-150,-90,-30,30,90,150})do
  for dx=-7,7,3.5 do local v=path("Zebra",x+dx,z,1.6,5);v.Position=Vector3.new(v.Position.X,.19,z);v.Size=Vector3.new(1.6,.025,5);v.CanCollide=false end
 end end
 for _,h in ipairs(w.Houses:GetChildren())do
  local b=h.Foundation;local front=b.CFrame:PointToWorldSpace(Vector3.new(0,0,-28));local sx=front.X>0 and 75 or -75
  path("HomeApproach",(front.X+sx)/2,front.Z,math.abs(front.X-sx),6)
 end
 path("GreenCrossing",0,0,80,6)
 for _,sgn in ipairs({-1,1})do
  path("DistrictPromenade",sgn*215.6,0,6,382)
  path("DistrictNorth",sgn*145,-194,134,6);path("DistrictSouth",sgn*145,194,134,6)
  -- Cross behind the gap between homes, not through living rooms.
  path("DistrictLink",sgn*147,60,132,6)
 end
 path("LakeApproach",-224,42,17,6)
 -- Remove the solid ground under the lake, not merely its colored surface.
 local lake=w.ArtDirection.GardenDistrict.WillowLake
 for _,v in ipairs(lake:GetChildren())do if (v.Name=="Water"or v.Name=="Shore")then v:Destroy()end end
 local g=w.Map:FindFirstChild("VillageGround")
 if g then
  local c=g.Color;g:Destroy()
  p(w.Map,"VillageGroundWest",Vector3.new(34,4,560),Vector3.new(-319,-2,0),c)
  p(w.Map,"VillageGroundEast",Vector3.new(562,4,560),Vector3.new(55,-2,0),c)
  p(w.Map,"VillageGroundNorth",Vector3.new(76,4,254),Vector3.new(-264,-2,-153),c)
  p(w.Map,"VillageGroundSouth",Vector3.new(76,4,170),Vector3.new(-264,-2,195),c)
 end
 w:SetAttribute("DistrictRenewal","v1");M.ClearPaths(w)
end
return M
