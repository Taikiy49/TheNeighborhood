-- 100 named activities, built from ten reusable mechanics. Coordinates are world studs.
local D={Version="recreation-cozy-3",Zones={},Activities={},Kinds={"Toss","Bowl","Ride","Bounce","Balance","Sprint","Lantern","Water","Dig","Domino"}}
local zones={
 {"Clover Commons",-470,-550,"Clover"},{"Sunrise Gardens",0,-550,"Sunrise"},{"Foxglove Fair",470,-550,"Foxglove"},
 {"Willow Playfield",-660,-230,"Willow"},{"Meadow Works",660,-230,"Meadow"},
 {"Pebble Playground",-660,290,"Pebble"},{"Firefly Court",660,290,"Firefly"},
 {"Orchard Carnival",-470,550,"Orchard"},{"Maple Makers",0,550,"Maple"},{"Starlight Grove",470,550,"Starlight"},
}
local toys={"Beach ball","Foam comet","Pumpkin ball","Apple ball","Soft cube","Pebble ball","Moon ball","Orange ball","Mint cube","Star ball"}
local titles={Toss="Toy toss",Bowl="Skittle lane",Ride="Orbit ride",Bounce="Spring pad",Balance="Balance trail",Sprint="Shuttle sprint",Lantern="Color lanterns",Water="Bloom garden",Dig="Treasure patch",Domino="Domino cascade"}
for z,v in ipairs(zones)do
 local zone={Id="Zone"..z,Name=v[1],Position=Vector3.new(v[2]*1.4/3,0,v[3]*1.4/3),Color=Color3.fromHSV((z*.087+.24)%1,.32,.76)}
 table.insert(D.Zones,zone)
 for k,kind in ipairs(D.Kinds)do
  local col=(k-1)%5;local row=math.floor((k-1)/5)
  local d={Id=string.format("Activity%03d",(z-1)*10+k),Zone=zone.Id,Kind=kind,Name=v[4].." "..titles[kind],Position=zone.Position+Vector3.new((col-2)*32,0,row==0 and -29 or 29),Color=zone.Color,Variant=z,Toy=toys[z],Speed=30+z*2,Height=43+z,Length=16+z*.5}
  if d.Id=="Activity091" then d.Position+=Vector3.new(0,0,14) end -- Clear the existing orchard bench approach.
  D.Activities[d.Id]=d
 end
end
return D
