-- Plot numbers match House01..House08 in the authored neighborhood.
local Layout={}
function Layout.Valid(slot)return type(slot)=='number'and slot%1==0 and slot>=1 and slot<=8 end
function Layout.Position(slot)
 assert(Layout.Valid(slot),'Invalid plot')
 return Vector2.new(slot<=4 and -282 or 282,-279+((slot-1)%4)*186)
end
function Layout.Nearest(used,anchor)
 anchor=Layout.Valid(anchor)and anchor or 1
 local best,distance=nil,math.huge
 for slot=1,8 do if not used[slot]then
  local d=(Layout.Position(slot)-Layout.Position(anchor)).Magnitude
  if d<distance then best,distance=slot,d end
 end end
 return best
end
function Layout.Side(slot)return slot<=4 and 'West side'or 'East side'end
return Layout
