local D={Order={'Bicycle','Compact','Trail','Roadster','CoastGT'}}
D.Items={
 Bicycle={Name='Boardwalk bicycle',Price=350,Level=1,Speed=22,Kind='Bike',Description='An affordable first ride.'},
 Compact={Name='Maple Compact',Price=2400,Level=3,Speed=28,Kind='Compact',Description='Your first everyday car.'},
 Trail={Name='Trail wagon',Price=9500,Level=8,Speed=30,Kind='Wagon',Description='A taller wagon with roof luggage and room for adventures.'},
 Roadster={Name='Sunset roadster',Price=28000,Level=16,Speed=36,Kind='Roadster',Description='A low open-top sports car earned through town work.'},
 CoastGT={Name='Coast Grand Tourer',Price=125000,Level=30,Speed=40,Kind='GT',Description='A long-term collection goal with gold trim and a rear wing.'},
}
function D.Level(xp)return 1+math.floor(math.sqrt(math.max(0,xp or 0)/50))end
function D.Owned(v,id)return v.Owned and v.Owned[id]~=nil or id=='Compact'and v.Compact==true end
function D.Normalize(v)
 v.Owned=v.Owned or{};if v.Compact and not v.Owned.Compact then v.Owned.Compact=2400 end
 if v.Selected==nil or not D.Owned(v,v.Selected)then v.Selected=next(v.Owned)or ''end
 return v
end
function D.Valid(v)
 if type(v)~='table'then return false end
 if v.Owned~=nil then if type(v.Owned)~='table'then return false end;for id,paid in pairs(v.Owned)do if not D.Items[id]or type(paid)~='number'or paid~=D.Items[id].Price then return false end end end
 return v.Selected==nil or v.Selected==''or D.Items[v.Selected]~=nil
end
return D
