assert(not game:GetService("RunService"):IsRunning(),"Edit mode required")
local w=workspace.Neighborhood
if w:GetAttribute("HorizontalScale")==3 then return "Already expanded"end
assert(w:GetAttribute("HorizontalScale")==2,"Expected previous spacious world")
local ratio=1.5
local function point(v)return Vector3.new(v.X*ratio,v.Y,v.Z*ratio)end
local preserved={}
local function keep(parts,anchor)
 for _,p in ipairs(parts)do if p:IsA("BasePart")then preserved[p]={Size=p.Size,CFrame=p.CFrame+(point(anchor)-anchor)}end end
end
for _,m in ipairs(w:GetDescendants())do if m:IsA("Model")and(m.Name=="Mailbox"or m.Name=="ParkBench"or m.Parent==w.GuideCharacters or m.Parent.Name=="CatalogDisplay")then keep(m:GetDescendants(),m:GetPivot().Position)end end
for _,h in ipairs(w.Houses:GetChildren())do
 for _,name in ipairs({"Lock","Doorbell","AddressPlaque","PorchLamp","Arrival"})do local p=h:FindFirstChild(name);if p then keep({p},p.Position)end end
 keep({h.SecurityCamera,h.CameraLens},h.SecurityCamera.Position)
 for _,p in ipairs(h.DisplaySlots:GetChildren())do keep({p},p.Position)end
end
for _,p in ipairs(w:GetDescendants())do if p:IsA("BasePart")then
 local cf=p.CFrame;local x,y,z=point(cf.RightVector),point(cf.UpVector),point(cf.ZVector)
 local right=x.Unit;local back=x:Cross(y).Unit;local up=back:Cross(right);local size=p.Size
 p.Size=Vector3.new(size.X*x.Magnitude,size.Y*math.abs(y:Dot(up)),size.Z*math.abs(z:Dot(back)))
 p.CFrame=CFrame.fromMatrix(point(cf.Position),right,up,back)
end end
for p,old in pairs(preserved)do p.Size=old.Size;p.CFrame=old.CFrame end
w.Map.VillageGround.Size=Vector3.new(1440,4,1200)
for _,h in ipairs(w.Houses:GetChildren())do
 local camera=h.SecurityCamera;camera.CFrame=CFrame.lookAt(camera.Position,h.Foundation.CFrame:PointToWorldSpace(Vector3.new(0,3,-6)));h.CameraLens.CFrame=camera.CFrame*CFrame.new(0,0,-.75)
end
w:SetAttribute("HorizontalScale",3);w:SetAttribute("BuildVersion","garden-district-3")
return {Map=w.Map.VillageGround.Size,House=w.Houses.House01.Foundation.Size}
