local Polish={}
local function part(parent,name,size,cf,color)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color;p.Anchored=true;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent;return p
end
function Polish.Install()
 local world=workspace.Neighborhood
 if world:GetAttribute("Polish1") then return "Already installed" end
 for _,house in ipairs(world.Houses:GetChildren())do
  local floor=house.Foundation;local base=floor.CFrame*CFrame.new(0,-0.5,0)
  local n=tonumber(house.Name:match("%d+"));local height=5+(n%3)
  for _,z in ipairs({-12.6,12.6})do for _,side in ipairs({-1,1})do
   local wedge=Instance.new("WedgePart");wedge.Name="Gable";wedge.Size=Vector3.new(0.65,height,15);wedge.CFrame=base*CFrame.new(side*7.5,12+height/2,z)*CFrame.Angles(0,side*math.pi/2,0);wedge.Color=house.BackWall.Color;wedge.Anchored=true;wedge.Parent=house
  end end
  local camera=part(house,"SecurityCamera",Vector3.new(0.8,0.7,1.4),base*CFrame.new(10,9,10)*CFrame.Angles(0,0,0),Color3.fromRGB(53,64,64))
  camera.CFrame=CFrame.lookAt(camera.Position,(base*CFrame.new(0,2,-4)).Position)
  camera.CanCollide=false
  local lens=part(house,"CameraLens",Vector3.new(0.45,0.4,0.1),camera.CFrame*CFrame.new(0,0,-0.75),Color3.fromRGB(177,223,203));lens.CanCollide=false; lens.CanQuery=false
  local mailbox=house.Mailbox.Box;mailbox:SetAttribute("Action","Deliver");mailbox:SetAttribute("HouseId",house.Name)
  local pp=Instance.new("ProximityPrompt");pp.ActionText="Deliver parcel";pp.ObjectText=house:GetAttribute("Address");pp.MaxActivationDistance=10;pp:SetAttribute("Action","Deliver");pp.Parent=mailbox
 end
 local board=part(world.Map,"CommunityBoard",Vector3.new(9,5,0.6),CFrame.new(13,5,-103),Color3.fromRGB(35,79,70))
 local gui=Instance.new("SurfaceGui");gui.Face=Enum.NormalId.Front;gui.CanvasSize=Vector2.new(600,340);gui.Parent=board
 local text=Instance.new("TextLabel");text.Size=UDim2.fromScale(1,1);text.BackgroundTransparency=1;text.Font=Enum.Font.GothamBold;text.TextScaled=true;text.TextColor3=Color3.fromRGB(244,245,236);text.Text="NEIGHBORHOOD POST\nDeliver a parcel · Earn $180\nMeet your neighbors on the way.";text.Parent=gui
 board:SetAttribute("Action","Delivery");local pp=Instance.new("ProximityPrompt");pp.ActionText="Take a delivery";pp.ObjectText="Neighborhood Post";pp.MaxActivationDistance=10;pp:SetAttribute("Action","Delivery");pp.Parent=board
 for _,x in ipairs({9,17})do part(world.Map,"BoardPost",Vector3.new(0.6,5,0.6),CFrame.new(x,2.5,-103),Color3.fromRGB(127,88,59)) end
 world:SetAttribute("Polish1",true)
 return "Gables, security cameras, community deliveries installed."
end
return Polish
