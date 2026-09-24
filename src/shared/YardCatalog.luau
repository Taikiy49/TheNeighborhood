local D={Order={'Flowers','Bench','Picnic','BallRack','Trampoline','Lantern','Pergola','Fountain','Trophy'}}
D.Items={
 Flowers={Name='Flower garden',Price=40,Level=1},Bench={Name='Garden bench',Price=90,Level=1},
 Picnic={Name='Picnic table',Price=300,Level=3},BallRack={Name='Garden ball rack',Price=400,Level=3},
 Trampoline={Name='Backyard trampoline',Price=900,Level=5},Lantern={Name='Lantern garden',Price=1800,Level=8},
 Pergola={Name='Coastal pergola',Price=5000,Level=12},Fountain={Name='Marble fountain',Price=15000,Level=20},
 Trophy={Name='Coast legend sculpture',Price=40000,Level=35},
}
function D.Default()return {Owned={},Slots={}}end
function D.Valid(y)
 if type(y)~='table'or type(y.Owned)~='table'or type(y.Slots)~='table'then return false end
 for id,v in pairs(y.Owned)do if not D.Items[id]or v~=true then return false end end
 for slot,v in pairs(y.Slots)do local n=tonumber(slot);if type(slot)~='string'or not n or n%1~=0 or n<1 or n>6 or type(v)~='table'or not y.Owned[v.Id]or type(v.Rotation)~='number'or v.Rotation%1~=0 or v.Rotation<0 or v.Rotation>3 then return false end end
 return true
end
return D
