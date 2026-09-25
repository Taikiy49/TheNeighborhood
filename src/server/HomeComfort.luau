-- Room boundaries meet the existing shell; all furnishings retain their original scale.
local M={Doors={}}
function M.Init(context)
 local A=require(script.Parent.CityArchitecture)
 for _,h in ipairs(workspace.Neighborhood.Houses:GetChildren())do
  local b=h.Foundation.CFrame;local interior=h.BuiltInInterior
  for _,v in ipairs(interior:GetChildren())do if v.Name=='HallPartition'then v:Destroy()end end
  local function p(name,size,x,y,z,color,solid)
   local v=A.Part(interior,name,size,Vector3.zero,color,Enum.Material.SmoothPlastic,solid)
   v.CFrame=b*CFrame.new(x,y,z);return v
  end
  local cream=Color3.fromRGB(244,245,236);local oak=Color3.fromRGB(177,145,107);local sage=Color3.fromRGB(119,147,135)
  -- Bedroom occupies the rear-left quarter; the kitchen stays open to the dining room.
  p('BedroomSideWall',{.3,10.35,14.25},-4.8,5.875,9.975,cream)
  p('BedroomFrontWall',{7.8,10.35,.3},-16,5.875,2.85,cream)
  p('BedroomDoorJamb',{1.2,10.35,.3},-5.4,5.875,2.85,cream)
  p('BedroomLintel',{6.2,2.15,.3},-9.1,9.975,2.85,cream)
  local door=p('BedroomDoor',{5.9,8.1,.25},-9.1,4.75,2.85,oak)
  door:SetAttribute('HouseId',h.Name);A.Prompt(door,'BedroomDoor','Bedroom','Open / close')
  local hinge=b*CFrame.new(-12.1,4.75,2.85)
  M.Doors[door]={Closed=door.CFrame,Opened=hinge*CFrame.Angles(0,math.pi/2,0)*CFrame.new(3,0,0),Open=false}
  local wardrobe=p('BedroomWardrobe',{2.7,6.5,4},-18,3.95,10,oak)
  p('WardrobeFront',{.12,5.8,3.7},-16.59,4.05,10,sage,false)
  p('BedsideTable',{2,.2,2},-6.6,2,13,oak)
  p('BedsideBase',{1.7,1.15,1.7},-6.6,1.3,13,oak)
  local lamp=p('BedsideLamp',{.8,.9,.8},-6.6,2.6,13,cream,false)
  local light=Instance.new('PointLight');light.Brightness=.35;light.Range=10;light:SetAttribute('LightingRole','Interior');light.Parent=lamp
  h:SetAttribute('InteriorDesignVersion','defined-bedroom-1')
 end
 context.Interactions:Register('BedroomDoor',function(player,target)
  local door=M.Doors[target];if not door then return false,'Door unavailable.'end
  local root=player.Character and player.Character:FindFirstChild('HumanoidRootPart')
  local destination=door.Open and door.Closed or door.Opened
  -- Leave the leaf open if somebody is standing in its closed opening.
  if door.Open then for _,p in ipairs(game.Players:GetPlayers())do local r=p.Character and p.Character:FindFirstChild('HumanoidRootPart');if r and (r.Position-door.Closed.Position).Magnitude<3 then return false,'Step away from the doorway first.'end end end
  door.Open=not door.Open
  game:GetService('TweenService'):Create(target,TweenInfo.new(.3),{CFrame=destination}):Play()
  return true,door.Open and 'Bedroom open.'or 'Bedroom closed.'
 end)
end
return M
