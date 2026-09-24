assert(not game:GetService("RunService"):IsRunning(),"Edit mode required")
local names={BackWall=true,LeftWall=true,RightWall=true,FrontHeader=true,FrontPost=true,FrontSill=true,Window=true,WindowMullion=true,WindowCrossbar=true,Shutter=true,Roof=true,Ceiling=true,Chimney=true,Door=true,PorchColumn=true,PorchRoof=true,Gable=true}
local V=1.3
local function vector(v)return Vector3.new(v.X,v.Y*V,v.Z)end
for _,h in ipairs(workspace.Neighborhood.Houses:GetChildren())do if not h:GetAttribute("InteriorHeightScale")then
 local b=h.Foundation.CFrame
 for _,p in ipairs(h:GetChildren())do if p:IsA("BasePart")and names[p.Name]then
  local cf=b:ToObjectSpace(p.CFrame);local x,y,z=vector(cf.RightVector),vector(cf.UpVector),vector(cf.ZVector)
  local right=x.Unit;local back=x:Cross(y).Unit;local up=back:Cross(right);local size=p.Size
  p.Size=Vector3.new(size.X*x.Magnitude,size.Y*math.abs(y:Dot(up)),size.Z*math.abs(z:Dot(back)))
  local pos=cf.Position;p.CFrame=b*CFrame.fromMatrix(Vector3.new(pos.X,.7+(pos.Y-.7)*V,pos.Z),right,up,back)
 end end
 for _,name in ipairs({"PorchLamp","AddressPlaque"})do local p=h[name];local cf=b:ToObjectSpace(p.CFrame);local pos=cf.Position;p.CFrame=b*CFrame.new(pos.X,.7+(pos.Y-.7)*V,pos.Z)*cf.Rotation end
 h:SetAttribute("InteriorHeightScale",V)
end end
return "Raised eight cottage wall and roof systems by 30%; floor levels remain unchanged"
