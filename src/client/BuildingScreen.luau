local D=require(game.ReplicatedStorage.Neighborhood.Shared.BuildingDefinitions)
local Screen={}
function Screen.Render(s,view,detail)
 local b=s.State.Building or {Unlocked={},Owned={},Placed={},Layouts={}}
 local function nav(title,body,label,target,data)s:Row(title,body,label,function()s:Open(target,data)end)end
 if view=="Building"then
  s.Title.Text="Room to grow"
  s:Row("Your cottage, your next chapter","Build with in-game cash while at home. Expansions, crafted furniture and three layouts follow your saved profile.")
  nav("Make it yours","Craft at your backyard bench, then arrange furniture on the rugs.","Arrange furniture","Furnish")
  nav("Keep a favorite arrangement","Save three furniture layouts and switch between them.","Saved layouts","Layouts")
  for _,id in ipairs(D.Order)do local r=D.Rooms[id];local owned=b.Unlocked[id];local ready=not r.Requires or b.Unlocked[r.Requires]
   s:Row(r.Name,(owned and "Built · "or "")..r.Description..(not ready and " Build the "..D.Rooms[r.Requires].Name:lower().." first."or ""),not owned and ready and "Review · $"..r.Price or nil,function()s:Open("BuildReview",id)end)
  end
 elseif view=="BuildReview"then
  s.Title.Text="Your expansion plan";local r=D.Rooms[detail];if not r then return end
  s:Row(r.Name,r.Description.." Permanent purchase: $"..r.Price.." in game cash. Your current balance is $"..(s.State.Currency or 0)..".","Build · $"..r.Price,function()s.Request("Building","Buy",detail)end)
  nav("Keep planning","Return without spending cash.","Back to plans","Building")
 elseif view=="Crafting"then
  s.Title.Text="The backyard workbench"
  s:Row("Furniture that stays yours","Stand beside your own workshop bench. Crafted furnishings can be packed and reused; they are separate from stealable collectible displays. Collection limit: 48 pieces.")
  for _,id in ipairs(D.RecipeOrder)do local r=D.Recipes[id];s:Row(r.Name,(b.Owned[id]or 0).." owned",b.Unlocked.Workshop and "Craft · $"..r.Price or nil,function()s.Request("Building","Craft",id)end)end
  nav("Find a place for it","Choose an unlocked room and an empty rug.","Arrange furniture","Furnish")
 elseif view=="Layouts"then
  s.Title.Text="Your favorite layouts"
  s:Row("A fresh arrangement","Loading a layout moves crafted furniture only. Rooms and collectible displays are unchanged.")
  for i=1,3 do local id=tostring(i);local saved=b.Layouts[id];local n=0;if saved then for _ in pairs(saved)do n+=1 end end
   s:Row("Layout "..i,saved and n.." pieces saved. Saving again replaces this arrangement."or "No arrangement saved yet.","Save layout "..i,function()s.Request("Building","SaveLayout",id)end)
   if saved then s:Row("Restore layout "..i,"Reuse your owned furniture. No cost.","Load layout "..i,function()s.Request("Building","LoadLayout",id)end)end
  end
 else
  s.Title.Text="Arrange your home"
  nav("Craft something new","Four recipes at your workshop bench.","Open crafting","Crafting")
  if not detail or not D.Rooms[detail.Zone]or not b.Unlocked[detail.Zone]then
   for _,id in ipairs(D.Order)do if b.Unlocked[id]then nav(D.Rooms[id].Name,#D.Rooms[id].Cells.." furnishing rugs", "Choose room","Furnish",{Zone=id})end end
   if not next(b.Unlocked)then nav("Your first new room","Build an expansion to unlock furnishing rugs.","View expansion plans","Building")end
  elseif not detail.Cell then
   local r=D.Rooms[detail.Zone]
   for i=1,#r.Cells do local placed=b.Placed[detail.Zone..":"..i];nav(r.Name.." · Rug "..i,placed and D.Recipes[placed.Kind].Name.." · "..tostring(placed.Rotation*90).."°"or "Empty rug","Choose furniture","Furnish",{Zone=detail.Zone,Cell=i})end
   nav("Other rooms","Keep exploring your home.","Choose another room","Furnish")
  else
   local current=b.Placed[detail.Zone..":"..detail.Cell];local rotation=detail.Rotation or (current and current.Rotation)or 0
   s:Row(D.Rooms[detail.Zone].Name.." · Rug "..detail.Cell,"Facing "..tostring(rotation*90).."°. Use Rotate before placing a piece.","Rotate 90°",function()s:Open("Furnish",{Zone=detail.Zone,Cell=detail.Cell,Rotation=(rotation+1)%4})end)
   for _,id in ipairs(D.RecipeOrder)do local owned=b.Owned[id]or 0;if owned>0 then
    local used=0;for _,v in pairs(b.Placed)do if v.Kind==id then used+=1 end end
    s:Row(D.Recipes[id].Name,owned.." owned · "..used.." placed","Place here",function()s.Request("Building","Place",{Zone=detail.Zone,Cell=detail.Cell,Kind=id,Rotation=rotation})end)
   end end
   if current then s:Row("Pack this piece","Remove it from this rug. It stays in your collection.","Pack furniture",function()s.Request("Building","Pack",{Zone=detail.Zone,Cell=detail.Cell})end)end
   nav("Another spot","Return to this room's rugs.","Choose another rug","Furnish",{Zone=detail.Zone})
  end
 end
end
return Screen
