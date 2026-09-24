local M={}
local groups={
 MenuHome={Title='Home & belongings',{'Residence','Grow my home','Earn a townhouse, family home and skyline residence'},{'Inventory','My bag','See your items'},{'Home','My home','Paint, floors and door security'},{'Building','Build & decorate','Add rooms and make furniture'},{'Garage','My garage','Buy or recall your car'},{'Pets','Pets','Meet your companion'},{'Collection','Collection','See what you have found'}},
 MenuExplore={Title='Explore & play',{'Activities','Games & goals','Tasks, quick games and jobs'},{'Life','Neighborhood life','Garden, craft and run a business'},{'Adventures','Story adventures','Follow a rumor'},{'Trials','Sports trials','Beat your best time'},{'Journal','Find the gnome','Follow the clues'},{'Event','Town events','See what is happening'}},
 MenuSocial={Title='Friends & neighbors',{'Friends','Play with friends','Invite friends or choose a home'},{'Neighbors','Neighbors','See who lives nearby'},{'Cases','My cases','Find clues about missing items'},{'Newspaper','Town news','Read what happened'}},
 MenuHelp={Title='Help & settings',{'Settings','Sound & settings','Music, sound and less movement'},{'Progress','My progress','First steps and achievements'},{'Weather','Weather','Check the forecast'},{'Recap','Welcome back','Your last visit'}},
}
function M.Render(s,view)
 local group=groups[view]
 s.Title.Text=group and group.Title or 'Around town'
 if not group then
  for _,v in ipairs({{'Activities','Goals & games','Pick your next activity'},{'MenuHome','Home & belongings','Your house, bag, car and pets'},{'MenuExplore','Explore & play','Games, jobs and adventures'},{'MenuSocial','Friends & neighbors','Friends, visitors and case files'},{'MenuHelp','Help & settings','Sound, progress and a quick tour'}})do s:Row(v[2],v[3],'Open',function()s:Open(v[1])end)end
 else
  s:Row('Around town','Go back to the main menu.','Back to menu',function()s:Open('Phone')end)
  for _,v in ipairs(group)do s:Row(v[2],v[3],'Open',function()s:Open(v[1],v[1]=='Recap'and(s.State.Recap or {Message='This is your first visit. Welcome home!'})or nil)end)end
  if view=='MenuHelp'then s:Row('Quick tour','See where to start.','Show the tour',function()s:Close();require(script.Parent.ArrivalIntro):Start(s.State)end)end
  if view=='MenuHome'then s:Row('Optional styles','Cosmetic packs cost Robux. Playing and earning cash are free.','Browse styles',function()s:Open('Boutique')end)end
 end
end
return M
