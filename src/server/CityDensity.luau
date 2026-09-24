local A=require(script.Parent.CityArchitecture)
local M={}
function M.Houses(w)
 local plots=require(game.ReplicatedStorage.Neighborhood.Shared.PlotLayout)
 for _,h in ipairs(w.Houses:GetChildren())do
  local id=tonumber(h.Name:match('%d+'));local target=plots.Position(id)
  local delta=Vector3.new(target.X-h.Foundation.Position.X,0,0)
  if delta.Magnitude>.01 then
   local box=h.Mailbox;local mailbox=box:GetPivot()
   h:PivotTo(h:GetPivot()+delta);box:PivotTo(mailbox)
   -- Shorten the front path toward the house while retaining its street endpoint.
   local path=h:FindFirstChild('FrontPath')
   if path then local axis=math.abs(path.CFrame.RightVector.X)>.9 and 'X'or 'Z';local s=path.Size
    path.Size=Vector3.new(axis=='X'and math.max(1,s.X-delta.Magnitude)or s.X,s.Y,axis=='Z'and math.max(1,s.Z-delta.Magnitude)or s.Z)
    path.Position-=delta/2
   end
  end
 end
 w:SetAttribute('HouseRowSpacing',218)
end
function M.Skyline(root)
 local old=root:FindFirstChild('Skyline');if old then old:Destroy()end
 local f=Instance.new('Folder');f.Name='Skyline';f:SetAttribute('Decorative',true);f.Parent=root
 local function tower(x,z,height,index)
  local m=Instance.new('Model');m.Name='CityTower'..index;m.ModelStreamingMode=Enum.ModelStreamingMode.Atomic;m:SetAttribute('Enterable',false);m:SetAttribute('Role','Skyline architecture');m.Parent=f
  local stone=index%2==0 and Color3.fromRGB(141,137,127)or Color3.fromRGB(114,123,128)
  local function p(n,s,dx,y,dz,c,mat)return A.Part(m,n,s,Vector3.new(x+dx,y,z+dz),c or stone,mat or Enum.Material.Concrete)end
  p('Podium',{46,16,32},0,8,0,A.Brick,Enum.Material.Brick)
  p('LowerTower',{28,height*.62,26},0,16+height*.31,0)
  local upperBase=16+height*.62
  p('SetbackTerrace',{30,.8,28},0,upperBase+.4,0,A.Cream)
  p('UpperTower',{22,height*.38,21},0,upperBase+height*.19+.8,0)
  for y=22,height+10,9 do
   local upper=y>upperBase;local width=upper and 22 or 28;local depth=upper and 21 or 26
   for _,side in ipairs({-1,1})do
    p('WindowBand',{width-3,4,.12},0,y,side*(depth/2+.1),Color3.fromRGB(87,117,132),Enum.Material.Glass)
    p('SideWindowBand',{.12,4,depth-3},side*(width/2+.1),y,0,Color3.fromRGB(87,117,132),Enum.Material.Glass)
   end
  end
  for _,dx in ipairs({-8,0,8})do p('VerticalPier',{.5,height*.62,.3},dx,16+height*.31,-13.3,A.Cream)end
  p('Crown',{24,1.2,23},0,height+17.3,0,A.Cream)
  p('RoofPlant',{8,4,8},0,height+20,0,A.Ink,Enum.Material.Metal)
  if index%5==0 then p('Spire',{.6,17,.6},0,height+30,0,A.Ink,Enum.Material.Metal)end
 end
 for _,z in ipairs({-333,334})do A.Part(f,'CityBlockPaving',{730,.18,44},Vector3.new(0,.09,z),Color3.fromRGB(161,159,149),Enum.Material.Pavement)end
 local n=0
 for _,side in ipairs({-1,1})do for i=-5,5 do n+=1;tower(side*382,i*53,90+(n%5)*19,n)end end
 for i=-5,5 do n+=1;tower(i*61,334,95+(n%4)*24,n)end
 for _,x in ipairs({-270,-205,-140,-70,0,70,140,205,270})do n+=1;tower(x,-333,90+(n%5)*20,n)end
 f:SetAttribute('TowerCount',n)
end
return M
