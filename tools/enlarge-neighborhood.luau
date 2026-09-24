-- One-time authoring migration. The exported asset stores the result; runtime must not repeat it.
assert(not game:GetService("RunService"):IsRunning(),"Stop Play before authoring")
local world=workspace.Neighborhood
if world:GetAttribute("HorizontalScale")==2 then return "Already enlarged"end
assert(not world:GetAttribute("HorizontalScale"),"Unexpected map scale")
local S=require(game.ReplicatedStorage.Neighborhood.Shared.WorldSpace)
local preserved={}
local function preserve(parts,anchor)
 for _,part in ipairs(parts)do if part:IsA("BasePart")then
  preserved[part]={Size=part.Size,CFrame=part.CFrame+(S.Point(anchor)-anchor)}
 end end
end
-- Small assemblies retain human proportions. Trees and architecture become larger.
for _,model in ipairs(world:GetDescendants())do if model:IsA("Model")and (model.Name=="Mailbox"or model.Name=="ParkBench"or model.Parent==world.GuideCharacters or model.Parent.Name=="CatalogDisplay")then
 preserve(model:GetDescendants(),model:GetPivot().Position)
end end
for _,house in ipairs(world.Houses:GetChildren())do
 local basis=house.Foundation.CFrame;local interior=house.BuiltInInterior
 local bed,kitchen={},{}
 for _,part in ipairs(interior:GetChildren())do
  if table.find({"BedFrame","Mattress","Quilt","Headboard","Pillow"},part.Name)then table.insert(bed,part)
  elseif part.Name:match("^Kitchen")or part.Name:match("^Tap")or part.Name=="SinkBasin"or part.Name=="Cooktop"or part.Name=="CabinetPull"then table.insert(kitchen,part)end
 end
 preserve(bed,interior.BedFrame.Position);preserve(kitchen,interior.KitchenCabinets.Position)
 for _,name in ipairs({"Lock","Doorbell","AddressPlaque","PorchLamp","Arrival"})do local p=house:FindFirstChild(name);if p then preserve({p},p.Position)end end
 if house:FindFirstChild("SecurityCamera")then preserve({house.SecurityCamera,house.CameraLens},house.SecurityCamera.Position)end
 for _,pad in ipairs(house.DisplaySlots:GetChildren())do preserve({pad},pad.Position)end
end
S.Stretch(world,CFrame.identity)
for part,old in pairs(preserved)do part.Size=old.Size;part.CFrame=old.CFrame end
for _,house in ipairs(world.Houses:GetChildren())do local camera=house.SecurityCamera;camera.CFrame=CFrame.lookAt(camera.Position,house.Foundation.CFrame:PointToWorldSpace(S.Point(Vector3.new(0,3,-2))));house.CameraLens.CFrame=camera.CFrame*CFrame.new(0,0,-.75)end
world:SetAttribute("BuildVersion","spacious-neighborhood-2")
return {Scale=2,Ground=world.Map.VillageGround.Size,Foundation=world.Houses.House01.Foundation.Size,PreservedHumanScaleParts=(function()local n=0;for _ in pairs(preserved)do n+=1 end;return n end)()}
