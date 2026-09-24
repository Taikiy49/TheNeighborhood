-- Read-only broad-phase screen for sign occlusion. Confirm findings in screenshots.
local w=workspace.Neighborhood;local parts={};local signs={}
for _,v in w:GetDescendants()do
 if v:IsA("BasePart")and v.Transparency<.5 and v.Material~=Enum.Material.Glass then table.insert(parts,v)end
 if v:IsA("SurfaceGui")and v.Parent:IsA("BasePart")and v.Enabled and (v.Face==Enum.NormalId.Front or v.Face==Enum.NormalId.Back)then table.insert(signs,v)end
end
local function intersect(p,a,b)
 local o=p.CFrame:PointToObjectSpace(a);local d=p.CFrame:VectorToObjectSpace(b-a);local half=p.Size*.5
 local near,far=0,1
 for _,axis in ipairs({"X","Y","Z"})do
  if math.abs(d[axis])<1e-6 then if math.abs(o[axis])>half[axis]then return false end
  else local x=(-half[axis]-o[axis])/d[axis];local y=(half[axis]-o[axis])/d[axis];if x>y then x,y=y,x end;near=math.max(near,x);far=math.min(far,y);if near>far then return false end end
 end
 return far>.001 and near<.999
end
local findings={};local rays=0
for _,g in signs do
 local p=g.Parent;local sign=g.Face==Enum.NormalId.Front and -1 or 1
 local normal=p.CFrame:VectorToWorldSpace(Vector3.new(0,0,sign))
 local eye=p.Position+normal*20;eye=Vector3.new(eye.X,math.min(p.Position.Y,6),eye.Z)
 local blocked={}
 for _,sample in ipairs({{0,0},{-.35,0},{.35,0},{0,.3},{0,-.3}})do
  local target=p.CFrame:PointToWorldSpace(Vector3.new(sample[1]*p.Size.X,sample[2]*p.Size.Y,sign*(p.Size.Z/2+.025)));rays+=1
  for _,other in parts do if other~=p and (other.Position-p.Position).Magnitude<other.Size.Magnitude/2+p.Size.Magnitude/2+25 then
   if intersect(other,eye,target)then blocked[other:GetFullName()]=true end
  end end
 end
 if next(blocked)then local names={} for name in blocked do table.insert(names,name)end;table.sort(names);table.insert(findings,{Sign=p:GetFullName(),Face=g.Face.Name,Blockers=names})end
end
return {Signs=#signs,Rays=rays,Findings=findings,Method="Oriented bounding boxes; intentionally conservative for cylinders, foliage and wedges. Review screenshots before changing geometry."}
