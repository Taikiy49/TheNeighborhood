local Marketplace=game:GetService("MarketplaceService")
local player=game.Players.LocalPlayer
local Catalog=require(game.ReplicatedStorage.Neighborhood.Shared.BoutiqueCatalog)
local Screen={Prices={},Loading={}}
function Screen.Render(ui)
 ui.Title.Text="Maple Style Boutique"
 local state=ui.State.Boutique or {Owned={}}
 ui:Row("Make yourself at home","Optional permanent cosmetics. No gameplay bonuses. Each pack includes all three finishes; no random rewards.")
 for _,key in ipairs({"Cottage","Coastal"})do
  local pack=Catalog[key];local owned=state.Owned[key];local info=Screen.Prices[key]
  if pack.PassId>0 and not owned and not info and not Screen.Loading[key]then
   Screen.Loading[key]=true
   task.spawn(function()
    local ok,result=pcall(function()return Marketplace:GetProductInfoAsync(pack.PassId,Enum.InfoType.GamePass)end)
    Screen.Loading[key]=nil
    Screen.Prices[key]=ok and result or {IsForSale=false}
    if ui.Panel.Visible and ui.CurrentView=="Boutique"then ui:Open("Boutique")end
   end)
  end
  local available=pack.PassId>0 and info and info.IsForSale and type(info.PriceInRobux)=="number"
  local label=owned and "Owned permanently"or pack.PassId==0 and "Not on sale yet"or available and ("Buy pass · "..info.PriceInRobux.." Robux")or "Currently unavailable"
  ui:Row(pack.Name,pack.Description.." "..(owned and "Owned permanently."or "One-time purchase."),not owned and available and label or nil,function()
   ui:Resolve(false)
   -- Roblox's native confirmation displays the final, personalized price.
   local ok=pcall(function()Marketplace:PromptGamePassPurchase(player,pack.PassId)end)
   if not ok then Screen.Prices[key]=nil;ui:Open("Boutique")end
  end)
  if not owned then ui:Row(label,"Roblox confirms the exact price before you buy.")end
  local ids={};for id in pairs(pack.Styles)do table.insert(ids,id)end;table.sort(ids)
  for _,id in ipairs(ids)do
   local choice=key..":"..id
   ui:Row(pack.Styles[id].Name,state.Selected==choice and "Your selected finish"or "Coordinated wall paint and flooring",owned and "Apply finish"or nil,function()ui.Request("Boutique","Equip",choice)end)
  end
 end
 ui:Row("Your everyday home","Restore the paint and floor you selected in Home.","Use everyday finishes",function()ui.Request("Boutique","Reset")end)
 ui:Row("Already purchased?","Restore access after buying a pass or retry a failed ownership check.","Check my purchases",function()Screen.Prices={};ui.Request("Boutique","Refresh")end)
end
return Screen
