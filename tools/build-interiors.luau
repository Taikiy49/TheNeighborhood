-- Idempotent Edit-mode authoring: preserves houses, possessions and front escape paths.
assert(not game:GetService("RunService"):IsRunning(),"Run this authoring tool only in Edit mode")
local cream=Color3.fromRGB(234,224,204)
local wood=Color3.fromRGB(126,91,62)
local function build(house,index)
 local previous=house:FindFirstChild("BuiltInInterior");if previous then previous:Destroy()end
 local folder=Instance.new("Folder");folder.Name="BuiltInInterior";folder.Parent=house
 local basis=house.Foundation.CFrame
 local camera=house:FindFirstChild("SecurityCamera")
 if camera then
  camera.CFrame=CFrame.lookAt(basis:PointToWorldSpace(Vector3.new(12,8.5,-10)),basis:PointToWorldSpace(Vector3.new(0,3,-2)))
  local lens=house:FindFirstChild("CameraLens");if lens then lens.CFrame=camera.CFrame*CFrame.new(0,0,-0.75)end
 end
 local function part(name,size,position,color,material)
  local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=basis*CFrame.new(position);p.Color=color or cream;p.Material=material or Enum.Material.SmoothPlastic;p.Anchored=true;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=folder;return p
 end
 local kitchenSide=index%2==0 and -1 or 1
 house:SetAttribute("InteriorLayout",kitchenSide==1 and "Garden Kitchen" or "Corner Kitchen")
 for _,side in ipairs({-1,1})do
  part("HallPartition",Vector3.new(0.35,10.5,11),Vector3.new(side*4,5.75,7),cream)
  part("RoomArchOuter",Vector3.new(2.5,10.5,0.35),Vector3.new(side*13,5.75,1.5),cream)
  part("RoomArchInner",Vector3.new(1.8,10.5,0.35),Vector3.new(side*4.85,5.75,1.5),cream)
  part("RoomArchHeader",Vector3.new(10.3,2,0.35),Vector3.new(side*9.25,10,1.5),cream)
  part("RoomSkirting",Vector3.new(0.45,0.5,10.5),Vector3.new(side*4,0.95,7),Color3.fromRGB(250,242,223))
 end
 local side=kitchenSide
 part("KitchenCabinets",Vector3.new(8.3,2.6,2.2),Vector3.new(side*9,2,10.5),Color3.fromRGB(112,150,133))
 part("KitchenCounter",Vector3.new(8.6,0.25,2.5),Vector3.new(side*9,3.45,10.5),Color3.fromRGB(240,231,211))
 part("SinkBasin",Vector3.new(2,0.15,1.5),Vector3.new(side*7,3.63,10.5),Color3.fromRGB(108,131,133),Enum.Material.Metal)
 part("TapStem",Vector3.new(0.2,0.8,0.2),Vector3.new(side*7,4.05,11.3),Color3.fromRGB(163,173,169),Enum.Material.Metal)
 part("TapSpout",Vector3.new(0.2,0.2,0.65),Vector3.new(side*7,4.35,11),Color3.fromRGB(163,173,169),Enum.Material.Metal)
 for _,dx in ipairs({-0.5,0.5})do for _,dz in ipairs({-0.5,0.5})do
  local burner=part("Cooktop",Vector3.new(0.7,0.07,0.7),Vector3.new(side*11+dx,3.62,10.5+dz),Color3.fromRGB(52,64,60));burner.Shape=Enum.PartType.Cylinder;burner.CFrame*=CFrame.Angles(0,0,math.pi/2);burner.Size=Vector3.new(0.07,0.7,0.7)
 end end
 for _,x in ipairs({6,8,10,12})do part("CabinetPull",Vector3.new(1.2,0.12,0.15),Vector3.new(side*x,2.4,9.3),Color3.fromRGB(213,186,111),Enum.Material.Metal)end
 side=-kitchenSide
 part("BedFrame",Vector3.new(7,0.8,4),Vector3.new(side*9,1.2,9.4),wood,Enum.Material.Wood)
 part("Mattress",Vector3.new(6.7,0.6,3.8),Vector3.new(side*9,1.9,9.4),Color3.fromRGB(240,230,208),Enum.Material.Fabric)
 part("Quilt",Vector3.new(6.75,0.15,2.1),Vector3.new(side*9,2.3,8.7),index%3==0 and Color3.fromRGB(205,156,108) or Color3.fromRGB(107,149,165),Enum.Material.Fabric)
 part("Headboard",Vector3.new(7,3,0.35),Vector3.new(side*9,2.1,11.5),wood,Enum.Material.Wood)
 for _,x in ipairs({-1.6,1.6})do part("Pillow",Vector3.new(2.6,0.45,1),Vector3.new(side*9+x,2.45,10.6),Color3.fromRGB(250,242,222),Enum.Material.Fabric)end
 local pendant=part("HallPendant",Vector3.new(1.5,0.35,1.5),Vector3.new(0,10.7,5),Color3.fromRGB(236,202,132))
 local light=Instance.new("PointLight");light.Color=Color3.fromRGB(255,226,185);light.Brightness=0.65;light.Range=20;light.Shadows=true;light.Parent=pendant
 for _,entry in ipairs({{4,-9},{6,9}})do house.DisplaySlots["Slot"..entry[1]].CFrame=basis*CFrame.new(entry[2],0.8,4)end
end
local houses=workspace.Neighborhood.Houses:GetChildren();table.sort(houses,function(a,b)return a.Name<b.Name end)
for index,house in ipairs(houses)do build(house,index)end
return "Authored eight furnished interiors with two mirrored layouts; preserved the front room and six display slots."
