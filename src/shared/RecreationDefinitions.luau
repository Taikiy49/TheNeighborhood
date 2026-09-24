-- 100 named activities, built from ten reusable mechanics. Coordinates are world studs.
local D={Version="recreation-cozy-4",Zones={},Activities={},Kinds={"Toss","Bowl","Ride","Bounce","Balance","Sprint","Lantern","Water","Dig","Domino"}}
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
-- A small, intentional park replaces the 100 scattered stations.
local keep={Activity001=Vector3.new(20,0,-42),Activity002=Vector3.new(-20,0,-42),Activity005=Vector3.new(252,0,-35),Activity006=Vector3.new(284,0,-35),Activity008=Vector3.new(-20,0,42),Activity003=Vector3.new(252,0,25)}
for id,d in pairs(D.Activities)do
 if not keep[id]then D.Activities[id]=nil else d.Position=keep[id];d.Zone=(id=="Activity005"or id=="Activity006"or id=="Activity003")and "Meadow"or "Green";d.Name=({Activity001="Park toy shelf",Activity002="Park skittles",Activity005="Balance trial",Activity006="Sprint trial",Activity008="Community flower bed",Activity003="Meadow carousel"})[id]end
end
D.Version="curated-park-1"
D.Count=6
D.Zones={{Id="Green",Name="Maple Green",Position=Vector3.new(0,0,0),Color=Color3.fromRGB(122,154,128)},{Id="Meadow",Name="Meadow sports garden",Position=Vector3.new(268,0,0),Color=Color3.fromRGB(122,154,128)}}
return D
