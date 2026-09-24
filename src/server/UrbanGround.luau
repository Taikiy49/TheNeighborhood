local A=require(script.Parent.CityArchitecture)
local M={}
function M.Apply(w)
 local old=w:FindFirstChild('UrbanGround');if old then old:Destroy()end
 local folder=Instance.new('Folder');folder.Name='UrbanGround';folder.Parent=w
 local converted=0
 for _,p in ipairs(w:GetDescendants())do
  if p:IsA('BasePart')and p.Position.Y<=0 and p.Size.X*p.Size.Z>300 and (p.Name:find('Ground')or p.Name=='ValleyFloor')then
   p.Material=Enum.Material.Asphalt;p.Color=Color3.fromRGB(76,79,80);p:SetAttribute('UrbanLand',true);converted+=1
  end
 end
 local function p(name,size,x,y,z,material,color)
  return A.Part(folder,name,size,Vector3.new(x,y,z),color,material)
 end
 -- Paved residential blocks replace broad front/back lawns; roads remain distinct.
 for _,side in ipairs({-1,1})do
  p('ResidentialBlock',{116,.12,356},side*136,.06,0,Enum.Material.Pavement,Color3.fromRGB(168,165,154))
  p('BackStreet',{18,.14,388},side*204,.11,0,Enum.Material.Asphalt,Color3.fromRGB(57,63,65))
  p('BackStreetFootway',{6,.18,388},side*192,.17,0,Enum.Material.Concrete,Color3.fromRGB(187,184,173))
 end
 -- The bounded neighborhood park remains the deliberate green exception.
 p('ParkLawn',{68,.1,140},0,.055,0,Enum.Material.Grass,Color3.fromRGB(103,132,82))
 -- Move existing street trees and their nearby lamp assemblies out of the carriageway.
 local trees=w.ArtDirection.GardenDistrict.StreetTrees
 for _,tree in ipairs(trees:GetChildren())do
  local trunk=tree:IsA('Model')and tree:FindFirstChild('Trunk')
  if trunk and math.abs(math.abs(trunk.Position.X)-207.6667)<1 then
   local target=trunk.Position.X<0 and -140 or 140
   tree:PivotTo(tree:GetPivot()+Vector3.new(target-trunk.Position.X,0,0))
  end
 end
 for _,lamp in ipairs(w.GardenDetails:GetChildren())do
  if lamp:IsA('BasePart')and lamp.Name:find('PathLamp')and math.abs(math.abs(lamp.Position.X)-207.6667)<2 then
   lamp.Position+=Vector3.new(lamp.Position.X<0 and 67.6667 or -67.6667,0,0)
  end
 end
 folder:SetAttribute('ConvertedGroundParts',converted)
 folder:SetAttribute('Design','Asphalt ground with paved blocks; contained central park')
 return converted
end
return M
