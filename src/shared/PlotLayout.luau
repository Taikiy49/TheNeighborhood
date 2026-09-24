local Layout={Count=12}
function Layout.Valid(slot)return type(slot)=='number'and slot%1==0 and slot>=1 and slot<=Layout.Count end
function Layout.Position(slot)
 assert(Layout.Valid(slot),'Invalid plot')
 local west=slot<=4 or slot==9 or slot==10
 local row=slot<=8 and ((slot-1)%4)or (slot<=10 and slot-5 or slot-7)
 return Vector2.new(west and -109 or 109,-150+row*60)
end
function Layout.Nearest(used,anchor)
 anchor=Layout.Valid(anchor)and anchor or 1;local best,distance=nil,math.huge
 for slot=1,Layout.Count do if not used[slot]then local d=(Layout.Position(slot)-Layout.Position(anchor)).Magnitude;if d<distance then best,distance=slot,d end end end
 return best
end
function Layout.Side(slot)return Layout.Position(slot).X<0 and 'West side'or 'East side'end
return Layout
