-- Avatar-scale entrances and intentional public wayfinding, applied before house ownership initializes.
local M={}
function M.Apply(w)
 for _,h in ipairs(w.Houses:GetChildren())do
  local old=h:FindFirstChild("EntranceJoinery");if old then old:Destroy()end
  local folder=Instance.new("Folder");folder.Name="EntranceJoinery";folder.Parent=h
  local b=h.Foundation.CFrame;local door=h.Door;local wall=h:FindFirstChild("FrontPost")
  local r=h.Foundation.Size.X/90;local cozy=r<.75;local width=cozy and 5.8 or 6.4;local height=cozy and 8 or 9.5
  local wallZ=-37.8*r;local faceZ=wallZ-1.05*r-.11;local edge=10.05*r;local gap=width/2+.05
  local headerBottom=b:PointToObjectSpace(h.FrontHeader.Position).Y-h.FrontHeader.Size.Y/2
  local function part(name,size,x,y,z,color)
   local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=b*CFrame.new(x,y,z);p.Color=color;p.Material=wall.Material;p.Anchored=true;p.CanTouch=false;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=folder;return p
  end
  door.Size=Vector3.new(width,height,.55);door.CFrame=b*CFrame.new(0,.44+height/2,wallZ)
  for _,s in ipairs({-1,1})do
   part("FrontWallInfill",Vector3.new(edge-gap,headerBottom-.44,2.1*r),s*(edge+gap)/2,(headerBottom+.44)/2,wallZ,wall.Color)
   part("DoorFrame",Vector3.new(.22,height+.2,.25),s*(gap+.09),.44+height/2,faceZ,Color3.fromRGB(244,245,236))
  end
  local top=.44+height
  part("DoorLintel",Vector3.new(gap*2,math.max(.1,headerBottom-top),2.1*r),0,(headerBottom+top)/2,wallZ,wall.Color)
  part("DoorFrameTop",Vector3.new(width+.5,.22,.25),0,top+.08,faceZ,Color3.fromRGB(244,245,236))
  h.Doorbell.CFrame=b*CFrame.new(-gap-.6,4.1,faceZ-.18);h.Lock.CFrame=b*CFrame.new(gap+.6,4.1,faceZ-.18)
  for _,v in ipairs(door:GetChildren())do if v.Name=="DoorJoinery"then v:Destroy()end end
  for _,face in ipairs({Enum.NormalId.Front,Enum.NormalId.Back})do
   local g=Instance.new("SurfaceGui");g.Name="DoorJoinery";g.Face=face;g.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud;g.PixelsPerStud=40;g.LightInfluence=.65;g.Parent=door
   for _,spec in ipairs({{.12,.09,.76,.48},{.12,.63,.76,.27}})do local f=Instance.new("Frame");f.Name="Panel";f.Position=UDim2.fromScale(spec[1],spec[2]);f.Size=UDim2.fromScale(spec[3],spec[4]);f.BackgroundColor3=Color3.fromRGB(65,87,78);f.BorderSizePixel=1;f.BorderColor3=Color3.fromRGB(112,135,119);f.Parent=g end
   local handle=Instance.new("Frame");handle.Name="Handle";handle.Position=UDim2.fromScale(face==Enum.NormalId.Front and .9 or .065,.53);handle.Size=UDim2.fromScale(.035,.08);handle.BackgroundColor3=Color3.fromRGB(195,166,112);handle.BorderSizePixel=0;handle.Parent=g
  end
 end
 local previous=w:FindFirstChild("Wayfinding");if previous then previous:Destroy()end
 local f=Instance.new("Folder");f.Name="Wayfinding";f.Parent=w
 local function post(name,pos,title,body)
  local p=Instance.new("Part");p.Name=name;p.Size=Vector3.new(.6,9,.6);p.Position=pos+Vector3.new(0,4.5,0);p.Anchored=true;p.CanCollide=false;p.Color=Color3.fromRGB(72,91,79);p.Parent=f
  local board=p:Clone();board.Name=name.."Board";board.Size=Vector3.new(17,5,.4);board.Position=pos+Vector3.new(0,8,-.6);board.Parent=f
  for _,face in ipairs({Enum.NormalId.Front,Enum.NormalId.Back})do
   local g=Instance.new("SurfaceGui");g.Face=face;g.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud;g.PixelsPerStud=32;g.Parent=board
   local t=Instance.new("TextLabel");t.Size=UDim2.fromScale(.9,.88);t.Position=UDim2.fromScale(.05,.06);t.BackgroundTransparency=1;t.Text=title.."\n"..body;t.TextScaled=true;t.TextWrapped=true;t.Font=Enum.Font.GothamMedium;t.TextColor3=Color3.fromRGB(244,245,236);t.Parent=g
  end
 end
 local ratio=(w:GetAttribute("HorizontalScale")or 3)/3
 post("NorthDirectory",Vector3.new(65*ratio,0,-345*ratio),"MAPLE GREEN","Park & stories: ahead\nShops: south end of Maple Street")
 post("SouthDirectory",Vector3.new(-65*ratio,0,345*ratio),"MARKET STREET","Shops: across the crossing\nLake: west · Meadow: east")
 for _,v in ipairs(w.ArtDirection.GardenDistrict:GetDescendants())do
  if v:IsA("BasePart")and v.Name=="DistrictSign"and not v:GetAttribute("RaisedWayfinding")then
   v.Position+=Vector3.new(0,3,0);v:SetAttribute("RaisedWayfinding",true)
   local nearest,dist=nil,math.huge
   for _,p in ipairs(v.Parent:GetChildren())do if p:IsA("BasePart")and p.Name=="SignPost"then local d=(Vector3.new(p.Position.X,0,p.Position.Z)-Vector3.new(v.Position.X,0,v.Position.Z)).Magnitude;if d<dist then nearest,dist=p,d end end end
   if nearest and dist<2 then nearest.Size+=Vector3.new(0,3,0);nearest.Position+=Vector3.new(0,1.5,0)end
  end
 end
 w:SetAttribute("ArrivalDesign","single-door-1")
end
return M
