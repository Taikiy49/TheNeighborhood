local A=require(script.Parent.CityArchitecture)
local M={}
function M.Houses(w)
 local plots=require(game.ReplicatedStorage.Neighborhood.Shared.PlotLayout)
 for _,h in ipairs(w.Houses:GetChildren())do
  local id=tonumber(h.Name:match('%d+'));local target=plots.Position(id)
  local old=h.Foundation.CFrame
  local basis=CFrame.new(target.X,old.Position.Y,target.Y)*CFrame.Angles(0,plots.West(id)and -math.pi/2 or math.pi/2,0)
  local transform=basis*old:Inverse();h:PivotTo(transform*h:GetPivot())
  local mailbox=h.Mailbox;local pos=mailbox:GetPivot().Position
  mailbox:PivotTo(CFrame.new(basis:PointToWorldSpace(Vector3.new(9,pos.Y-basis.Position.Y,-33)))*mailbox:GetPivot().Rotation)
  h:SetAttribute('Address',tostring(100+id)..' '..plots.Side(id))
 end
 w:SetAttribute('HouseRowSpacing',100)
end
function M.Skyline(root)
 local old=root:FindFirstChild('Skyline');if old then old:Destroy()end
 local f=Instance.new('Folder');f.Name='Skyline';f.Parent=root
end
return M
