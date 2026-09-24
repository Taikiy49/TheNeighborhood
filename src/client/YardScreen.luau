local D=require(game.ReplicatedStorage.Neighborhood.Shared.YardCatalog)
local S={Slot=1,Rotation=0}
function S.Render(s)
 local y=s.State.Yard or D.Default();s.Title.Text='Your garden'
 s:Row('Build your own outdoor space','Six spaces beside your home. Blueprints can be reused. Furniture stays saved when you leave.')
 local placed=y.Slots[tostring(S.Slot)]
 s:Row('Space '..S.Slot,(placed and D.Items[placed.Id].Name or 'Empty')..' • Rotation: '..(S.Rotation*90)..' degrees. Spaces run in pairs from the front gate.','Next space',function()S.Slot=S.Slot%6+1;s:Open('Yard')end)
 s:Row('Turn furniture','Choose direction before placing.','Rotate 90°',function()S.Rotation=(S.Rotation+1)%4;s:Open('Yard')end)
 for _,id in ipairs(D.Order)do local d=D.Items[id]
  s:Row(d.Name,'Level '..d.Level..' • '..(y.Owned[id]and 'Blueprint owned'or '$'..d.Price),y.Owned[id]and 'Place in space '..S.Slot or 'Unlock · $'..d.Price,function()s.Request('Yard',y.Owned[id]and 'Place'or 'Buy',y.Owned[id]and S.Slot..':'..id..':'..S.Rotation or id)end)
 end
 s:Row('Clear space '..S.Slot,'Keeps your blueprint.','Pack decoration',function()s.Request('Yard','Clear',tostring(S.Slot))end)
end
return S
