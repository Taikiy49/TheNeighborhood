local Factory=require(script.Parent.ItemFactory)
local Defs=require(game.ReplicatedStorage.Neighborhood.Shared.ItemDefinitions)
local World={}
local function prompt(part,action,text,object)
 part:SetAttribute("Action",action)
 if part:FindFirstChildOfClass("ProximityPrompt") then return end
 local p=Instance.new("ProximityPrompt");p.ActionText=text;p.ObjectText=object;p.MaxActivationDistance=10;p:SetAttribute("Action",action);p.Parent=part
end
function World.Install()
 local world=workspace.Neighborhood
 prompt(world.Shops.GeneralStore.Counter,"Shop","Browse","Maple & Co.")
 prompt(world.Shops.PawnShop.Counter,"Pawn","Sell items","Totally Legal Pawn Shop")
 for _,house in ipairs(world.Houses:GetChildren()) do
  for _,slot in ipairs(house.DisplaySlots:GetChildren()) do prompt(slot,"Place","Place furniture","Display spot "..slot:GetAttribute("Slot")) end
  house.Arrival.CFrame=house.Arrival.CFrame*CFrame.Angles(0,math.pi,0)
 end
 local display=world.Shops.GeneralStore:FindFirstChild("CatalogDisplay")
 if not display then
  display=Instance.new("Folder");display.Name="CatalogDisplay";display.Parent=world.Shops.GeneralStore
  local ids={};for id in pairs(Defs) do table.insert(ids,id) end;table.sort(ids)
  for index,id in ipairs(ids) do
   local model=Factory.Create(id);model:ScaleTo(0.65);model:PivotTo(CFrame.new(-43+((index-1)%5)*7,1.1,151+math.floor((index-1)/5)*13));model.Parent=display
  end
 end
 return "World prompts and catalog displays installed."
end
return World
