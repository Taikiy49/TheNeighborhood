-- Give authored layers a real reveal instead of coincident render faces.
local M={}
local protected={Door=true,Foundation=true,Arrival=true,HomeSpawn=true,CarSpawn=true}
local function candidates(w)
 local groups={}
 for _,p in ipairs(w:GetDescendants())do if p:IsA('Part')and p.Transparency==0 and p.Shape==Enum.PartType.Block then
  local cf=p.CFrame;local aligned=true
  for _,v in ipairs({cf.RightVector,cf.UpVector,cf.ZVector})do if math.max(math.abs(v.X),math.abs(v.Y),math.abs(v.Z))<.9999 then aligned=false end end
  if aligned then
   local s=p.Size;local e=Vector3.new(math.abs(cf.RightVector.X)*s.X+math.abs(cf.UpVector.X)*s.Y+math.abs(cf.ZVector.X)*s.Z,math.abs(cf.RightVector.Y)*s.X+math.abs(cf.UpVector.Y)*s.Y+math.abs(cf.ZVector.Y)*s.Z,math.abs(cf.RightVector.Z)*s.X+math.abs(cf.UpVector.Z)*s.Y+math.abs(cf.ZVector.Z)*s.Z)/2
   for _,ax in ipairs({'X','Y','Z'})do for _,sign in ipairs({-1,1})do
    local key=ax..':'..sign..':'..math.floor((p.Position[ax]+e[ax]*sign)*100+.5)
    groups[key]=groups[key]or {};table.insert(groups[key],{Part=p,Extent=e,Axis=ax})
   end end
  end
 end end
 local pairsFound={}
 for _,group in pairs(groups)do for i=1,#group do for j=i+1,#group do
  local a,b=group[i],group[j];local axes=a.Axis=='X'and {'Y','Z'}or a.Axis=='Y'and {'X','Z'}or {'X','Y'};local overlaps=true
  for _,ax in ipairs(axes)do if math.min(a.Part.Position[ax]+a.Extent[ax],b.Part.Position[ax]+b.Extent[ax])-math.max(a.Part.Position[ax]-a.Extent[ax],b.Part.Position[ax]-b.Extent[ax])<.04 then overlaps=false end end
  if overlaps then table.insert(pairsFound,{a.Part,b.Part,a.Axis})end
 end end end
 return pairsFound
end
function M.Audit(w)return #candidates(w)end
function M.Apply(w)
 require(script.Parent.UrbanGround).Apply(w)
 for _,h in ipairs(w.Houses:GetChildren())do
  local lawn=h:FindFirstChild('Lawn');if lawn then lawn.Transparency=1; lawn.CanCollide=false; lawn.CanQuery=false end
  if not h:FindFirstChild('StoneApron')then
   local p=Instance.new('Part');p.Name='StoneApron';p.Size=Vector3.new(h.Foundation.Size.X+3,.3,h.Foundation.Size.Z+3);p.CFrame=h.Foundation.CFrame*CFrame.new(0,-.13,0);p.Material=Enum.Material.Pavement;p.Color=Color3.fromRGB(185,180,165);p.Anchored=true;p.Parent=h
  end
  h.Porch.Material=Enum.Material.Pavement;h.Porch.Color=Color3.fromRGB(185,180,165)
 end
 local orchard=w:FindFirstChild('SideDestinations');orchard=orchard and orchard:FindFirstChild('OrchardStand');if orchard then for _,v in ipairs(orchard:GetDescendants())do if v:IsA('BasePart')and v.Name=='EntryPath'and not v:GetAttribute('PavingReveal')then v.Position+=Vector3.new(0,.035,0);v:SetAttribute('PavingReveal',true)end end end
 local before=M.Audit(w);local changed=0
 for pass=1,6 do
  local scheduled={}
  for _,pair in ipairs(candidates(w))do
   local a,b,axis=table.unpack(pair)
   local function allowed(p)return not protected[p.Name]and not p:GetAttribute('Action')and (p:GetAttribute('SurfaceRefinementCount')or 0)<4 end
   local chosen=allowed(a)and a or allowed(b)and b
   if allowed(a)and allowed(b)and b.Size.X*b.Size.Y*b.Size.Z<a.Size.X*a.Size.Y*a.Size.Z then chosen=b end
   if chosen then
    local localAxis=chosen.CFrame:VectorToObjectSpace(axis=='X'and Vector3.xAxis or axis=='Y'and Vector3.yAxis or Vector3.zAxis)
    local id=math.abs(localAxis.X)>.99 and 'X'or math.abs(localAxis.Y)>.99 and 'Y'or 'Z'
    scheduled[chosen]=scheduled[chosen]or {};scheduled[chosen][id]=true
   end
  end
  if not next(scheduled)then break end
  for p,axes in pairs(scheduled)do
   local size=p.Size;p.Size=Vector3.new(math.max(.05,size.X-(axes.X and .045 or 0)),math.max(.05,size.Y-(axes.Y and .045 or 0)),math.max(.05,size.Z-(axes.Z and .045 or 0)))
   p:SetAttribute('SurfaceRefined',true);p:SetAttribute('SurfaceRefinementCount',(p:GetAttribute('SurfaceRefinementCount')or 0)+1);changed+=1
  end
 end
 local report={Before=before,After=M.Audit(w),Adjusted=changed};w:SetAttribute('SurfaceAudit',game.HttpService:JSONEncode(report));return report
end
return M
