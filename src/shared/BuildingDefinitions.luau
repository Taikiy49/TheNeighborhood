-- All positions are relative to the assigned house foundation, never world coordinates.
local D={Order={"GardenRoom","Loft","Garage","Workshop"},RecipeOrder={"Bench","Bookcase","Planter","Desk"},MaxOwned=48,LayoutCount=3}
D.Rooms={
 GardenRoom={Name="Garden room",Price=900,Description="A glazed room opening from your cottage hallway, with two collectible displays.",Cells={{-9,.7,18},{-4,.7,18},{-9,.7,23},{-4,.7,23}},Displays={{-9,.7,26.5},{-3,.7,26.5}}},
 Loft={Name="Upstairs loft",Price=1800,Requires="GardenRoom",Description="A reading loft above the garden room, reached by a real return staircase.",Cells={{-9,11.65,18},{-4,11.65,18},{-9,11.65,23},{-4,11.65,23}},Displays={{-9,11.65,26.5},{-3,11.65,26.5}}},
 Garage={Name="Carriage garage",Price=1400,Description="A sheltered parking bay. Your Maple Compact can be recalled inside.",Cells={{-24,.7,-16.5},{-20,.7,-16.5},{-16,.7,-16.5}},Displays={{-25.5,.7,-28},{-14.5,.7,-28}}},
 Workshop={Name="Backyard workshop",Price=1100,Requires="GardenRoom",Description="A garden studio with a crafting bench. Turn cash into furniture you can rearrange.",Cells={{-8,.7,36},{8,.7,36},{-8,.7,40},{8,.7,40}},Displays={{-8,.7,45},{8,.7,45}}},
}
D.Bounds={GardenRoom={-12.5,12.5,12.2,30.5,-1,25},Loft={-12.5,12.5,12.2,30.5,-1,25},Garage={-28.5,-11.5,-32.5,-13.5,-1,13},Workshop={-12.5,12.5,30.5,49.5,-1,15}}
D.Recipes={Bench={Name="Cushioned bench",Price=90},Bookcase={Name="Little library",Price=140},Planter={Name="Fern planter",Price=60},Desk={Name="Writing desk",Price=120}}
function D.SlotRoom(slot)
 if type(slot)~="number"or slot%1~=0 or slot<7 or slot>14 then return nil end
 return D.Order[math.floor((slot-7)/2)+1]
end
return D
