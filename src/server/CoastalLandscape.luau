local A=require(script.Parent.CityArchitecture)
local M={}
function M.Build(W)
 local root=Instance.new('Folder');root.Name='Landscape';root.Parent=W.Root
 local function p(n,s,x,y,z,c,mat,solid,class)return W.Part(root,n,s,x,y,z,c,mat,solid,class)end
 local stone=Color3.fromRGB(202,193,174);local green=Color3.fromRGB(91,130,87)
 local function path(x,z,sx,sz)p('GardenPath',{sx,.14,sz},x,.12,z,stone,Enum.Material.Pavement)end
 local function bed(x,z,sx,sz)
  p('PlanterBase',{sx,.6,sz},x,.3,z,A.Cream,Enum.Material.Concrete)
  p('Planting',{sx-.5,.8,sz-.5},x,.85,z,green,Enum.Material.Grass,false)
  for i=-1,1 do local f=p('Flowers',{1.3,.8,1.3},x+i*math.max(1,sx/4),1.5,z,Color3.fromRGB(205,153+i*20,123),Enum.Material.Grass,false);f.Shape=Enum.PartType.Ball end
 end
 local function bench(x,z,yaw)
  local cf=CFrame.new(x,0,z)*CFrame.Angles(0,yaw or 0,0)
  for _,d in ipairs({{'BenchSeat',{8,.4,2},0,1.7,0},{'BenchBack',{8,2,.3},0,2.7,1},{'BenchLeg',{.5,1.5,2},-3,.75,0},{'BenchLeg',{.5,1.5,2},3,.75,0}})do
   local v=p(d[1],d[2],0,0,0,A.Wood,nil,true,d[1]=='BenchSeat'and 'Seat'or nil);v.CFrame=cf*CFrame.new(d[3],d[4],d[5])
  end
 end
 -- Cottage back gardens, low fences and shade trees stay clear of drives and doorways.
 for _,h in ipairs(workspace.Neighborhood.Houses:GetChildren())do
  local cf=h.Foundation.CFrame
  local shade=cf*Vector3.new(34,0,48);W.Tree(root,shade.X,shade.Z,false)
  local at=cf*Vector3.new(0,0,25);local patio=p('BackPatio',{24,.14,9},0,0,0,stone,Enum.Material.Pavement);patio.CFrame=cf*CFrame.new(0,-.35,25)
  for _,x in ipairs({-20,20})do for _,z in ipairs({14,24})do local post=p('GardenFencePost',{.5,3,.5},0,0,0,A.Cream);post.CFrame=cf*CFrame.new(x,1,z)end;local rail=p('GardenFence',{.25,1,10},0,0,0,A.Cream);rail.CFrame=cf*CFrame.new(x,1,19)end
 end
 -- Park paths connect the houses, community buildings and play equipment.
 path(-280,5,320,7)
 for _,x in ipairs({-440,-260,-80})do path(x,-18,7,46)end
 for _,x in ipairs({-350,-230,-150})do bench(x,15);bed(x,25,12,5)end
 -- Boulevard shopfront courts and a planted civic garden fill the space between destinations.
 path(195,170,155,9);path(195,170,9,130)
 path(405,170,155,9);path(405,170,9,130)
 for _,x in ipairs({140,250,350,460})do for _,z in ipairs({120,220})do bed(x,z,18,12);W.Tree(root,x,z,true)end end
 for _,x in ipairs({170,220,380,430})do bench(x,180);bed(x,158,15,5)end
 local pavilion=p('GardenPavilionRoof',{28,1,24},405,15,125,A.Ink,Enum.Material.Slate)
 for _,x in ipairs({393,417})do for _,z in ipairs({115,135})do p('PavilionColumn',{.7,15,.7},x,7.5,z,A.Cream)end end
 bench(405,125)
 W.Sign(root,'GardenSign','COAST GARDENS',380,245,0)
 -- Retail promenade: storefront-to-storefront paths and orderly outdoor tables.
 path(-295,175,460,9)
 for _,x in ipairs({-460,-375,-265,-140})do path(x,165,6,20)end
 for _,x in ipairs({-410,-310,-185})do
  bed(x,177,10,5);bench(x,188);W.Tree(root,x,120,false)
 end
 -- A walking circuit around the sports field, separate from the playable grass.
 path(-440,553,135,7);path(-505,475,7,155);path(-375,475,7,155)
 for _,z in ipairs({435,470,505})do bench(-362,z,math.pi/2)end
 for _,x in ipairs({-357,-313})do p('CourtLine',{.2,.02,70},x,.183,425,A.Cream,nil,false)end
 for _,z in ipairs({390,425,460})do p('CourtLine',{44,.02,.2},-335,.183,z,A.Cream,nil,false)end
 for _,z in ipairs({395,455})do for i=0,11 do
  local a=i*math.pi/6;local b=(i+1)*math.pi/6
  local v1=Vector3.new(-335+math.cos(a)*1.4,9,z+math.sin(a)*1.4);local v2=Vector3.new(-335+math.cos(b)*1.4,9,z+math.sin(b)*1.4)
  local rim=p('BasketballRim',{.15,.15,(v2-v1).Magnitude},0,0,0,Color3.fromRGB(210,110,60),Enum.Material.Metal,false);rim.CFrame=CFrame.lookAt((v1+v2)/2,v2)
 end end
 -- Trees frame rural fields and district boundaries, never the traffic lanes.
 for x=-660,460,55 do for _,z in ipairs({-570,-335,630})do W.Tree(root,x,z,x>80)end end
 for z=-520,590,50 do W.Tree(root,-665,z,false)end
 for _,side in ipairs({-1,1})do
  local roof=p('BarnPitchedRoof',{28,1,40},-370+side*12.5,18,-480,A.Ink,Enum.Material.Slate);roof.CFrame*=CFrame.Angles(0,0,-side*math.rad(23))
 end
 for _,x in ipairs({-535,-25,45})do for _,z in ipairs({310,370,430,490,550})do W.Tree(root,x,z,false)end end
 -- Crosswalks only where a road actually meets a junction.
 local directions={}
 for _,e in ipairs(W.Edges)do
  for i=1,2 do local a=W.Nodes[e[i]];local b=W.Nodes[e[3-i]];local v=(b-a).Unit;directions[e[i]]=directions[e[i]]or{};table.insert(directions[e[i]],v)end
 end
 for id,dirs in pairs(directions)do if #dirs>=3 then
  local at=W.Nodes[id]
  for _,dir in ipairs(dirs)do local side=Vector3.new(-dir.Z,0,dir.X)
   for i=-4,4 do local pos=at+dir*18+side*i*2.7;local stripe=p('Crosswalk',{1.6,.02,5},pos.X,.232,pos.Z,A.Cream,nil,false);stripe.CFrame=CFrame.lookAt(stripe.Position,stripe.Position+dir)end
  end
 end end
 -- Airport threshold bars, helipad identification and taxiway guidance.
 for _,z in ipairs({325,565})do for i=-3,3 do p('RunwayThreshold',{2,.02,12},415+i*5,.245,z,A.Cream,nil,false)end end
 for _,x in ipairs({152,168})do p('HelipadH',{2,.02,20},x,.255,525,A.Cream,nil,false)end;p('HelipadH',{18,.02,2},160,.255,525,A.Cream,nil,false)
 path(270,370,85,7)
 -- Warm sidewalk lights carry a recognizable visual rhythm through the city.
 for _,x in ipairs({275,325})do for z=-330,220,65 do if math.abs(z+60)>22 then
  p('Streetlamp',{.35,14,.35},x,7,z,A.Ink,Enum.Material.Metal)
  local lamp=p('Lantern',{1.4,1.8,1.4},x,14,z,A.Cream,Enum.Material.Neon,false)
  local light=Instance.new('PointLight');light.Range=22;light.Brightness=.5;light.Color=Color3.fromRGB(255,224,175);light.Parent=lamp
 end end end
end
return M
