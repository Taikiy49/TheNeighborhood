local Layout={Count=12}
function Layout.Valid(slot)return type(slot)=='number'and slot%1==0 and slot>=1 and slot<=Layout.Count end
function Layout.Position(slot)
 assert(Layout.Valid(slot),'Invalid plot')
 local street=math.floor((slot-1)/4);local localId=(slot-1)%4
 return Vector2.new(-440+street*180+(localId<2 and -50 or 50),localId%2==0 and -230 or -120)
end
function Layout.Street(slot)return -440+math.floor((slot-1)/4)*180 end
function Layout.West(slot)return(slot-1)%4<2 end
function Layout.Nearest(used,anchor)
 anchor=Layout.Valid(anchor)and anchor or 1;local best,distance=nil,math.huge
 for slot=1,Layout.Count do if not used[slot]then local d=(Layout.Position(slot)-Layout.Position(anchor)).Magnitude;if d<distance then best,distance=slot,d end end end
 return best
end
function Layout.Side(slot)return({'Maple Lane','Palm Lane','Sunset Lane'})[math.floor((slot-1)/4)+1]end
return Layout
