local D=require(game.ReplicatedStorage.Neighborhood.Shared.ResidenceDefinitions)
local R={}
function R.Render(s)
 s.Title.Text='Grow your home'
 local r=s.State.Residence;if not r then s:Row('Getting ready','Your home plan is loading.');return end
 local tier=D.Tiers[r.Tier];s:Row(tier.Name,tier.Floors..' floor(s) • Renovation '..r.Renovations..' • '..r.Style)
 s:Row('A home to grow into','Finish jobs and deliveries. Visit Avery at the hotel to upgrade. Keep your items, garage and rooms.','Find Avery',function()
  local w=workspace.Neighborhood:FindFirstChild('MapleHeights');local target=w and w:FindFirstChild('HousingDesk',true);local desk=target and target:FindFirstChild('Desk')
  require(script.Parent.TaskGuide).Selected='Housing';require(script.Parent.TaskGuide):Show({Key='HousingDesk',Title='Housing agent',Position=desk and desk.Position or Vector3.new(12,2,-112)},s.State,game.Players.LocalPlayer);s:Close()
 end)
 local nextTier=D.Tiers[r.Tier+1]
 if nextTier then
  s:ProgressRow('Next: '..nextTier.Name,nextTier.Description,r.Work,nextTier.Work)
  s:ProgressRow('Save for your upgrade','Costs $'..nextTier.Price..' in game cash.',s.State.Currency or 0,nextTier.Price,'Review upgrade',function()s:Open('ResidenceReview',r.Tier+1)end)
 else
  local project=D.Project(r)
  s:ProgressRow('Renovation '..(r.Renovations+1),'Refresh your furnished floors with '..D.Styles[(r.Renovations+1)%#D.Styles+1]..' colors. Your home is never reset.',r.ProjectWork,project.Work)
  s:ProgressRow('Renovation budget','Costs $'..project.Price..' in game cash.',s.State.Currency or 0,project.Price,'Review renovation',function()s:Open('ResidenceReview','Renovate')end)
 end
 s:Row('Play your way','Jobs, decorating, neighbors and exploration build your life here. Investigations and house mischief are optional.')
end
function R.Review(s,detail)
 s.Title.Text='Confirm home plan';local r=s.State.Residence;if not r then return end
 local renovation=detail=='Renovate';local tier=not renovation and D.Tiers[detail];if not renovation and not tier then return end
 local price=renovation and D.Project(r).Price or tier.Price
 s:Row(renovation and 'Refresh your home' or tier.Name,'Spend $'..price..' in game cash at Avery’s desk. Keep your current possessions and garage.','Confirm · $'..price,function()s.Request('Residence',renovation and 'Renovate'or 'Upgrade',renovation and r.Renovations or detail)end)
 s:Row('Not yet?','Keep saving at your own pace.','Back',function()s:Open('Residence')end)
end
return R
