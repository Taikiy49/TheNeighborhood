local D=require(script.Parent.BuildingDefinitions)
local R={}
function R.Integer(v,a,b)return type(v)=="number"and v==v and v%1==0 and v>=a and v<=b end
function R.Default()return {Unlocked={},Owned={},Placed={},Layouts={}}end
function R.Key(zone,cell)return zone..":"..cell end
function R.Placements(build,placements)
 if type(placements)~="table"then return false end
 local counts={};local n=0
 for key,v in pairs(placements)do
  n+=1;if n>15 or type(v)~="table"or type(v.Zone)~="string"then return false end
  local room=D.Rooms[v.Zone]
  if not room or not build.Unlocked[v.Zone]or not R.Integer(v.Cell,1,#room.Cells)or key~=R.Key(v.Zone,v.Cell)or not D.Recipes[v.Kind]or not R.Integer(v.Rotation,0,3)then return false end
  counts[v.Kind]=(counts[v.Kind]or 0)+1;if counts[v.Kind]>(build.Owned[v.Kind]or 0)then return false end
 end
 return true
end
function R.Valid(b)
 if type(b)~="table"or type(b.Unlocked)~="table"or type(b.Owned)~="table"or type(b.Layouts)~="table"then return false end
 for id,v in pairs(b.Unlocked)do local r=D.Rooms[id];if not r or v~=true or (r.Requires and not b.Unlocked[r.Requires])then return false end end
 local total=0
 for id,n in pairs(b.Owned)do if not D.Recipes[id]or not R.Integer(n,1,D.MaxOwned)then return false end;total+=n end
 if total>D.MaxOwned or (total>0 and not b.Unlocked.Workshop)or not R.Placements(b,b.Placed)then return false end
 for id,layout in pairs(b.Layouts)do if id~="1"and id~="2"and id~="3"then return false end;if not R.Placements(b,layout)then return false end end
 return true
end
return R
