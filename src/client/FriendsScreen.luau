local Players=game:GetService('Players')
local Social=game:GetService('SocialService')
local Screen={}
function Screen.Render(ui,view,detail)
 local state=ui.State.Friends or {Saved={},Incoming={},Friends={},Invites={}}
 local uid=Players.LocalPlayer.UserId
 local function action(verb,arg)ui.Request('Friends',verb,arg)end
 if view=='ChoosePlot'then
  ui.Title.Text='Choose your home'
  local plots,locked
  if detail then
   for _,circle in ipairs(state.Saved or {})do if circle.Id==detail then
    ui:Row('Your address is saved',circle.Address..'. It stays yours when you return.','Back to Friends',function()ui:Open('Friends')end);return
   end end
   for _,invite in ipairs(state.Incoming or {})do if invite.Id==detail and not invite.Expired then plots=invite.Plots end end
   ui:Row('Move in near your friends','Choose an available address below, or let us pick the closest free plot to the founder. Your choice stays reserved while you are offline.',plots and 'Pick nearest & accept'or nil,function()action('AcceptSaved',detail)end)
  else
   local party=state.Party;plots=party and party.Plots;locked=party and (party.PlotsLocked or party.Busy)
   ui:Row('Your place on Maple Street',locked and 'These addresses are already saved for your circle.'or 'Nearby homes are picked automatically. Choose a different free address if you prefer. Changing a plot resets the ready check.')
  end
  if not plots then ui:Row('No plots to choose','Join a party or refresh your neighborhood invitations.')end
  for _,plot in ipairs(plots or {})do
   local description=plot.Side..' · '..(plot.Yours and 'Your chosen address'or plot.Available and 'Available'or 'Reserved for another member')
   ui:Row(plot.Address,description,plot.Available and not locked and ('Choose '..plot.Address)or nil,function()
    if detail then action('AcceptSaved',{Id=detail,Slot=plot.Slot})else action('ChoosePlot',plot.Slot)end
   end)
  end
  ui:Row('Your party and circles','Return to the ready check and saved neighborhoods.','Back to Friends',function()ui:Open('Friends')end)
  return
 end
 if view=='InviteFriends'then
  ui.Title.Text='Invite to your circle'
  ui:Row('Your Roblox friends','Invites last 24 hours. Friends can accept from any server. Eight members can share this neighborhood.','Load Roblox friends',function()action('LoadFriends')end)
  for _,friend in ipairs(state.Friends or {})do ui:Row(friend.Name,'Invite to this saved neighborhood.','Invite '..friend.Name,function()action('InviteSaved',{Id=detail,UserId=friend.UserId})end)end
  if state.PreviousFriends then ui:Row('Previous friends','Page '..state.FriendsPage,'Previous page',function()action('PreviousFriends')end)end
  if state.MoreFriends then ui:Row('More friends','Page '..state.FriendsPage,'Next page',function()action('NextFriends')end)end
  if #(state.Friends or {})==0 then ui:Row('No friends loaded','Use the button above. Account permissions may limit invitations.')end
  ui:Row('Your circles','Return to the party and saved neighborhoods.','Back to Friends',function()ui:Open('Friends')end)
  return
 end
 ui.Title.Text='Friends & neighborhoods'
 if state.Error then ui:Row('Could not refresh',state.Error)end
 if state.Travel then ui:Row('Moving to your neighborhood','Your progress is saved before departure. If travel fails, you stay here and can retry.');return end
 ui:Row('Your progress comes with you','Money, possessions, finishes, cars and pets follow you. Each saved circle keeps your home plot.','Refresh invitations',function()action('Refresh')end)
 for _,invite in ipairs(state.Invites or {})do
  ui:Row(invite.Name.."'s party",'Join this group of up to eight. Ready up to create a saved neighborhood together.','Join party',function()action('AcceptParty',invite.Id)end)
  ui:Row('Not this time','Decline this party invitation.','Decline party',function()action('DeclineParty',invite.Id)end)
 end
 local party=state.Party
 if party then
  local names={};local ready=0;local myReady=false
  for _,p in ipairs(party.Members)do table.insert(names,(p.Ready and 'Ready · 'or 'Waiting · ')..p.Name..(p.UserId==party.Leader and ' (leader)'or '')..'\n'..p.Address);if p.Ready then ready+=1 end;if p.UserId==uid then myReady=p.Ready end end
  ui:Row('Your party · '..#party.Members..' / 8',table.concat(names,'\n'))
  if party.Busy then ui:Row('Preparing your circle','Please wait while your neighborhood is saved.')else
   ui:Row('Your home address',party.PlotsLocked and 'Your circle keeps the addresses you selected.'or 'Keep the nearby default, or pick an available plot before moving in.',party.PlotsLocked and 'View plots'or 'Choose home plot',function()ui:Open('ChoosePlot')end)
   ui:Row('Ready check',ready..' / '..#party.Members..' ready. Ready means you agree to join this saved circle and move together.',myReady and 'Not ready'or 'Ready to move',function()action('Ready')end)
   if party.Leader==uid then
    ui:Row('A street of your own','Create a saved circle with the home addresses shown above. Everyone must be ready.','Move party together',function()action('Launch')end)
    for _,neighbor in ipairs(ui.State.Neighbors or {})do
     local present=false;for _,p in ipairs(party.Members)do if p.UserId==neighbor.UserId then present=true end end
     if not present then ui:Row(neighbor.Name,'Invite this neighbor to your party.','Invite to party',function()action('Invite',neighbor.UserId)end)end
    end
   end
   ui:Row('Leave this party','Your saved neighborhoods and progress remain yours.','Leave party',function()action('Leave')end)
  end
 else ui:Row('Start with your neighbors','Invite people here, ready up, then move together. You can also create a circle solo and invite Roblox friends from other servers.','Create party',function()action('Create')end)end
 for _,invite in ipairs(state.Incoming or {})do
  ui:Row('Invitation · '..invite.Title,invite.Expired and 'This invitation expired. Decline it to clear your list.'or invite.Count..' / 8 members. Pick a home next to your friends, then accept.',not invite.Expired and 'Choose home & accept'or nil,function()ui:Open('ChoosePlot',invite.Id)end)
  ui:Row('Pass on this circle','Decline the invitation.','Decline neighborhood',function()action('DeclineSaved',invite.Id)end)
 end
 for _,group in ipairs(state.Saved or {})do
  local here=state.Current==group.Id
  ui:Row(group.Title,(group.Address or 'Home '..group.Slot)..' · '..group.Count..' / 8 members'..(here and ' · You are here'or ''),not here and 'Visit neighborhood'or nil,function()action('Return',group.Id)end)
  if group.Owner==uid and group.Count<8 then ui:Row('Bring your friends','Invite Roblox friends even when they are in another server.','Choose friends',function()ui:Open('InviteFriends',group.Id)end)end
 end
 if #(state.Saved or {})==0 then ui:Row('No saved circles yet','Create a party, ready up and move together, or accept a neighborhood invitation.')end
 ui:Row('Invite friends to the game','Roblox controls who can receive invitations. They can open Friends after joining.','Open Roblox invites',function()
  local ok,allowed=pcall(function()return Social:CanSendGameInviteAsync(Players.LocalPlayer)end)
  local shown=false;if ok and allowed then shown=pcall(function()Social:PromptGameInvite(Players.LocalPlayer)end)end
  ui:Resolve(false);if not shown then ui:Row('Invites unavailable','Try the published game and check your Roblox privacy settings.')end
 end)
 if state.Current then ui:Row('Meet new neighbors','Leave this visit and join a public neighborhood. Your circle stays saved.','Visit public neighborhood',function()action('Public')end)end
 if state.Studio then ui:Row('Studio playtest','Party controls can be tested here. Moving between neighborhoods requires the published Roblox game.')end
end
return Screen
