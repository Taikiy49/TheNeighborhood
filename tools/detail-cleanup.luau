-- Deterministic edit-time corrections from the close-up visual audit.
assert(not game:GetService("RunService"):IsRunning(),"Edit only")
local w=workspace.Neighborhood
local old=w:FindFirstChild("DetailCorrections");if old then old:Destroy()end
local details=Instance.new("Folder");details.Name="DetailCorrections";details.Parent=w
local function part(name,size,cf,color)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color;p.Material=Enum.Material.SmoothPlastic
 p.Anchored=true;p.CanCollide=false;p.CanQuery=false;p.CanTouch=false;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=details;return p
end
local ink=Color3.fromRGB(48,68,65);local cream=Color3.fromRGB(236,233,215)
local meadow=w.ArtDirection.GardenDistrict.PicnicMeadow
local roofLength=17/math.cos(.23);local roofMiddle=11.35+8.5*math.tan(.23)
for _,v in meadow:GetChildren()do if v.Name=="PavilionRoof"then
 local side=v.Position.X<560 and -1 or 1
 v.Size=Vector3.new(roofLength,.35,29);v.CFrame=CFrame.new(560+side*8.5,roofMiddle,92)*CFrame.Angles(0,0,-side*.23)
end end
part("PavilionRidgeCap",Vector3.new(.45,.35,29.2),CFrame.new(560,11.35+17*math.tan(.23),92),ink)
for _,z in ipairs({81,103})do part("PavilionTieBeam",Vector3.new(31,.4,.65),CFrame.new(560,11.1,z),ink)end
local function sign(p)
 for _,g in p:GetChildren()do if g:IsA("SurfaceGui")then
  g.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud;g.PixelsPerStud=50;g.LightInfluence=.15
  for _,t in g:GetDescendants()do if t:IsA("TextLabel")then
   t.Size=UDim2.fromScale(.9,.84);t.Position=UDim2.fromScale(.05,.08);t.TextScaled=true;t.TextWrapped=true;t.Font=Enum.Font.GothamMedium;t.TextColor3=cream
  end end
 end end
end
local green=w.Map.MapleGreenSign;green.Size=Vector3.new(18,4,.5);green.Color=ink
green.SurfaceGui.TextLabel.Text="MAPLE GREEN\nThe neighborhood commons"
local post=w.Map.CommunityBoard;post.Size=Vector3.new(16,5,.5);post.Color=ink
post.SurfaceGui.TextLabel.Text="NEIGHBORHOOD POST\nParcel deliveries · $180"
local supports={};for _,v in w.Map:GetChildren()do if v.Name=="BoardPost"then table.insert(supports,v)end end
table.sort(supports,function(a,b)return a.Position.X<b.Position.X end)
for i,v in supports do v.Size=Vector3.new(.45,5,.45);v.CFrame=CFrame.new(39+(i==1 and -6 or 6),2.5,-308.45)end
for _,x in ipairs({-7,7})do part("GreenSignPost",Vector3.new(.45,5,.45),CFrame.new(x,2.5,-311.45),ink)end
for _,shop in w.Shops:GetChildren()do
 local p=shop.Sign;p.Size=Vector3.new(36,5,.4);p.CFrame=CFrame.new(shop.Floor.Position.X,14.8,416);p.Color=ink;p.CanCollide=false;p.CanQuery=false
 for _,dx in ipairs({-15,15})do part("ShopSignBracket",Vector3.new(.35,3,.35),CFrame.new(p.Position.X+dx,11.7,416.5),ink)end
end
for _,h in w.Houses:GetChildren()do
 local b=h.Foundation.CFrame
 -- Surface detailing stays attached to the moving door without extra collision parts.
 for _,v in h.Door:GetChildren()do if v.Name=="DoorJoinery"then v:Destroy()end end
 for _,face in ipairs({Enum.NormalId.Front,Enum.NormalId.Back})do
  local gui=Instance.new("SurfaceGui");gui.Name="DoorJoinery";gui.Face=face;gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud;gui.PixelsPerStud=50;gui.LightInfluence=.65;gui.Parent=h.Door
  local function panel(x,y,sx,sy,color)
   local v=Instance.new("Frame");v.Name="Inset";v.Position=UDim2.fromScale(x,y);v.Size=UDim2.fromScale(sx,sy);v.BorderSizePixel=0;v.BackgroundColor3=color;v.Parent=gui;return v
  end
  for i=0,2 do
   panel(.045+i*.315,.075,.28,.85,Color3.fromRGB(91,115,103))
   panel(.056+i*.315,.093,.258,.814,Color3.fromRGB(65,87,78))
  end
  panel(face==Enum.NormalId.Front and .92 or .065,.43,.012,.15,Color3.fromRGB(195,166,112))
 end

 local peak=-math.huge;local depth=0
 for _,roof in h:GetChildren()do if roof:IsA("BasePart")and roof.Name=="Roof"then
  depth=math.max(depth,roof.Size.Z)
  for _,x in ipairs({-1,1})do for _,y in ipairs({-1,1})do
   peak=math.max(peak,b:PointToObjectSpace(roof.CFrame:PointToWorldSpace(Vector3.new(x*roof.Size.X/2,y*roof.Size.Y/2,0))).Y)
  end end
 end end
 if depth>0 then part("CottageRidgeCap",Vector3.new(.6,.4,depth+.2),b*CFrame.new(0,peak-.1,0),ink)end
 -- Keep the address on the visible front of the porch instead of under its roof.
 h.AddressPlaque.CFrame=b*CFrame.new(0,11,-55.7);h.AddressPlaque.Size=Vector3.new(4,1.3,.25)
 local bottom=b:PointToObjectSpace(h.Ceiling.Position).Y-h.Ceiling.Size.Y/2
 for _,v in h.BuiltInInterior:GetChildren()do
  local y
  if v.Name=="CeilingMount"then y=bottom-.06
  elseif v.Name=="LinenShade"then y=bottom-.12-.325
  elseif v.Name=="Diffuser"then y=bottom-.12-.65-.04 end
  if y then local pos=b:PointToObjectSpace(v.Position);-- Preserve the vertical cylinder orientation.
   v.CFrame=b*CFrame.new(pos.X,y,pos.Z)*CFrame.Angles(0,0,math.pi/2)
  end
 end
end
for _,g in w:GetDescendants()do if g:IsA("SurfaceGui")and g.Parent:IsA("BasePart")then sign(g.Parent)end end
w:SetAttribute("DetailAuditVersion","detail-cleanup-1")
return {Houses=8,CeilingFixtures=40,ShopSigns=2,CommunityBoards=2}
