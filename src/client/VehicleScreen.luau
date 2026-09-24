local D=require(game.ReplicatedStorage.Neighborhood.Shared.VehicleCatalog)
local S={}
function S.Render(s,review)
 local v=s.State.Vehicles or{};s.Title.Text=review and 'Review vehicle'or 'Coast Motors'
 if review then
  local d=D.Items[review.Id];if not d then return end
  local sell=review.Action=='Sell';local price=sell and math.floor(d.Price*.5)or d.Price
  s:Row(d.Name,sell and 'Sell this vehicle for $'..price..'. You can buy it again later for the full price.'or 'Buy for $'..price..' earned cash. Required level: '..d.Level..'.',sell and 'Sell for $'..price or 'Buy for $'..price,function()s.Request('Vehicle',review.Action,review.Id)end)
  s:Row('Keep browsing','Nothing changes until you confirm.','Back',function()s:Open('Garage')end);return
 end
 s:Row('Your next ride','Buy and sell at Coast Motors. Resale pays half the purchase price. Recall an owned ride to your garage. Level '..D.Level(s.State.Progress and s.State.Progress.XP)..'.')
 for _,id in ipairs(D.Order)do local d=D.Items[id]
  if D.Owned(v,id)then
   s:Row(d.Name,d.Description..' • Owned','Recall to garage',function()s.Request('Vehicle','Select',id)end)
   s:Row('Sell '..d.Name,'Return to Coast Motors. Resale: $'..math.floor(d.Price*.5),'Review sale',function()s:Open('VehicleReview',{Id=id,Action='Sell'})end)
  else
   s:ProgressRow(d.Name,d.Description..' • Level '..d.Level..' • $'..d.Price,s.State.Currency or 0,d.Price,'Review purchase',function()s:Open('VehicleReview',{Id=id,Action='Buy'})end)
  end
 end
 for _,color in ipairs({'Mint','Peach','Blue','Butter'})do s:Row(color,'Free paint for your selected vehicle.','Apply paint',function()s.Request('Vehicle','Color',color)end)end
end
return S
