-- Creator Store geometry only; no imported scripts or vehicle controllers.
local M={}
local library=game.ServerStorage:WaitForChild('VehicleArt')
function M.Place(id,parent,cf,moving,color)
 local m=assert(library:FindFirstChild(id),'Missing sourced vehicle '..id):Clone()
 m.Name='Imported'..id;m.ModelStreamingMode=Enum.ModelStreamingMode.Atomic;m:PivotTo(cf);m.Parent=parent
 for _,p in ipairs(m:GetDescendants())do
  if p:IsA('BasePart')then
   p.Anchored=not moving;p.CanTouch=false;p.CanQuery=false;p.CanCollide=false;p.Massless=true;p.CollisionGroup='NeighborhoodCars'
   if color and p:GetAttribute('VehiclePaint')then p.Color=color end
  end
 end
 return m
end
local function replace(model,kind,cf,entry,service)
 local keep={}
 for _,p in ipairs(model:GetDescendants())do
  if p:IsA('BasePart')and p:GetAttribute('Action')~='CityLift'and(p:GetAttribute('Action')or p.Name=='Floor'or p.Name=='Counter')then table.insert(keep,p)end
 end
 local saved=Instance.new('Folder');saved.Parent=model
 for _,p in ipairs(keep)do p.Parent=saved end
 for _,v in ipairs(model:GetChildren())do if v~=saved then v:Destroy()end end
 for _,p in ipairs(keep)do
  p.Parent=model;p.Size=Vector3.one;p.Transparency=1;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=p:GetAttribute('Action')~=nil
  p.CFrame=p.Name=='Floor'and cf or CFrame.new(cf*service)
  for _,g in ipairs(p:GetChildren())do if g:IsA('SurfaceGui')then g:Destroy()end end
 end
 saved:Destroy()
 local art=library[kind]:Clone();art.Name='ImportedAutoShop';art:PivotTo(cf);art.Parent=model
 for _,p in ipairs(art:GetDescendants())do if p:IsA('BasePart')then p.Anchored=true;p.CanQuery=p.CanCollide;p.CanTouch=false end end
 model:SetAttribute('Entry',cf*entry);model:SetAttribute('ImportedVenue',kind)
 return art
end
function M.Init()
 local w=workspace.Neighborhood;local root=w.CoastalWorld
 local showroom=root.CommercialStrip.CarShowroom
 local cf=CFrame.new(-230,.15,210)*CFrame.Angles(0,-math.pi/2,0)
 replace(showroom,'Showroom',cf,Vector3.new(17.2,3,0),Vector3.new(-5,3,0))
 for i,id in ipairs({'Roadster','CoastGT'})do M.Place(id,showroom,cf*CFrame.new(3.85,.55,i==1 and -17.5 or 17.5)*CFrame.Angles(0,-math.pi/2,0))end
 local workshop=w.SideDestinations.RepairWorkshop
 local repairCF=CFrame.new(-140,.15,140)
 replace(workshop,'AutoShop',repairCF,Vector3.new(-7.4,3,-27),Vector3.new(-7.4,3,-12))
 require(script.Parent.VenueRenewal).Place('Workbench',workshop,repairCF*CFrame.new(-30,.4,14),.9)
 M.Place('Compact',workshop,repairCF*CFrame.new(-16,.4,4))
 local A=require(script.Parent.CityArchitecture)
 for _,d in ipairs({{showroom,'COAST MOTORS',CFrame.new(-230,14.8,226.5)*CFrame.Angles(0,math.pi,0)},{workshop,'MAPLE AUTO REPAIRS',CFrame.new(-147.4,14.8,113.8)}})do
  local sign=game.ServerStorage.VenueArt.VenueSign:Clone();sign.Name='VenueName';sign.Size=Vector3.new(22,2,.2);sign.CFrame=d[3];sign.CanCollide=false;sign.CanQuery=false
  for _,v in ipairs(sign:GetChildren())do v:Destroy()end;A.Sign(sign,d[2]);sign.Parent=d[1]
 end
 -- Existing depot trucks use the same sourced art library as the player fleet.
 for _,p in ipairs(root.Industrial:GetChildren())do if p:IsA('BasePart')and p.Name:match('^Truck')then p:Destroy()end end
 for _,x in ipairs({-200,-140})do M.Place('DeliveryTruck',root.Industrial,CFrame.new(x,.2,565))end
 -- Remove only street trees intersecting these enlarged finished premises.
 for _,venue in ipairs({showroom,workshop})do
  local b,s=venue.ImportedAutoShop:GetBoundingBox()
  for _,tree in ipairs(root.StreetDressing:GetChildren())do
   if tree:IsA('Model')and(tree.Name=='Art_StreetTree'or tree.Name=='Art_CoastPalm')then
    local q=b:PointToObjectSpace(tree:GetPivot().Position)
    if math.abs(q.X)<s.X/2+12 and math.abs(q.Z)<s.Z/2+12 then tree:Destroy()end
   end
  end
 end
end
return M
