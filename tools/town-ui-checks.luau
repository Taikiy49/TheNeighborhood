local S=require(game.Players.LocalPlayer.PlayerScripts.Neighborhood.Screens)
local result={};local size=S.Panel.Size
for _,dims in ipairs({{510,560},{360,480},{360,220}})do
 S.Panel.Size=UDim2.fromOffset(dims[1],dims[2])
 for _,view in ipairs({'Yard','Garage','VehicleReview','Activities','MenuHelp','Progress','Friends'})do
  local ok,e=pcall(function()
   S:Open(view,view=='VehicleReview'and {Id='Bicycle',Action='Buy'}or nil);task.wait(.2)
   assert(S.Panel.Visible and S.Title.Text~='')
   local close=S.Panel.CloseButton;assert(close.AbsolutePosition.Y>=S.Panel.AbsolutePosition.Y and close.AbsolutePosition.Y+48<=S.Panel.AbsolutePosition.Y+S.Panel.AbsoluteSize.Y)
   for _,v in ipairs(S.List:GetDescendants())do if v:IsA('TextLabel')then assert(v.TextFits,'Text clipped: '..v.Text)end end
   S:Close();assert(not S.Panel.Visible)
  end)
  table.insert(result,{view=view,width=dims[1],height=dims[2],pass=ok,error=not ok and tostring(e)or nil})
 end
end
S.Panel.Size=size;S:Close();task.wait(3)
table.insert(result,{view='Closed remains closed after state refresh',pass=not S.Panel.Visible})
game.Players.LocalPlayer.PlayerGui:SetAttribute('TownUIResults',game.HttpService:JSONEncode(result))

