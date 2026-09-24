local player=game.Players.LocalPlayer
local marker
local function refresh()
 if marker then marker:Destroy();marker=nil end
 local id=player:GetAttribute("HouseId");if not id then return end
 task.spawn(function()
  local world=workspace:WaitForChild("Neighborhood");local h=world:WaitForChild("Houses"):WaitForChild(id,30)
  if not h or player:GetAttribute("HouseId")~=id then return end
  local door=h:WaitForChild("Door",20);if not door then return end
  marker=Instance.new("BillboardGui");marker.Name="YourHomeMarker";marker.Size=UDim2.fromOffset(180,42);marker.StudsOffset=Vector3.new(0,6,0);marker.MaxDistance=160;marker.AlwaysOnTop=true;marker.Adornee=door;marker.Parent=player.PlayerGui
  local t=Instance.new("TextLabel");t.Size=UDim2.fromScale(1,1);t.BackgroundColor3=Color3.fromRGB(37,83,69);t.BackgroundTransparency=.1;t.Text="YOUR HOME\n"..h:GetAttribute("Address");t.TextColor3=Color3.fromRGB(255,247,213);t.TextSize=14;t.Font=Enum.Font.GothamBold;t.Parent=marker
 end)
end
player:GetAttributeChangedSignal("HouseId"):Connect(refresh);refresh()
