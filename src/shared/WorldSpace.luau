-- Authored layout coordinates remain stable so saved plot/slot/layout IDs need no migration.
-- Only horizontal space grows. Avatars, usable props, interaction range and walk speed do not.
local S={Scale=2}
function S.Point(v)return Vector3.new(v.X*S.Scale,v.Y,v.Z*S.Scale)end
function S.Unpoint(v)return Vector3.new(v.X/S.Scale,v.Y,v.Z/S.Scale)end
function S.Frame(x,y,z)
 local v=typeof(x)=="Vector3"and x or Vector3.new(x,y,z)
 return CFrame.new(S.Point(v))
end
function S.Part(part,basis)
 local cf=basis:ToObjectSpace(part.CFrame)
 local x,y,z=S.Point(cf.RightVector),S.Point(cf.UpVector),S.Point(cf.ZVector)
 local right=x.Unit;local back=x:Cross(y).Unit;local up=back:Cross(right)
 -- Keep roof planes joined when a sloped beam gets wider without becoming taller.
 local size=part.Size
 part.Size=Vector3.new(size.X*x.Magnitude,size.Y*math.abs(y:Dot(up)),size.Z*math.abs(z:Dot(back)))
 part.CFrame=basis*CFrame.fromMatrix(S.Point(cf.Position),right,up,back)
end
function S.Stretch(model,basis)
 assert(not model:GetAttribute("HorizontalScale"),"Geometry was already expanded")
 for _,part in ipairs(model:GetDescendants())do if part:IsA("BasePart")then S.Part(part,basis)end end
 model:SetAttribute("HorizontalScale",S.Scale)
end
return S
