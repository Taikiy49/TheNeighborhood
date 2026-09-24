return function(screens)
 local M=require(script.Parent.HomeMarker);local player=game.Players.LocalPlayer
 local original=screens.State;local root=player.Character.HumanoidRootPart
 assert(type(original.HomePosition)=='table','Server omitted home coordinates')
 screens:Close();M:Update()
 assert(M.Badge.Parent==player.PlayerGui and M.Badge:GetAttribute('HouseId')==original.HouseId,'Marker belongs to wrong house')
 local expected=Vector3.new(table.unpack(original.HomePosition))+Vector3.new(0,20,0)
 assert((M.Anchor.Position-expected).Magnitude<.1,'Incorrect marker anchor')
 local function fixture(id,position)screens.State={HouseId=id,HomePosition={position.X,position.Y,position.Z}};M:Update()end
 fixture('UnstreamedTestHouse',root.Position+Vector3.new(500,0,0));assert(M.Badge.Enabled,'Distant/unstreamed home hidden')
 fixture('NearTestHouse',root.Position);assert(not M.Badge.Enabled,'Nearby marker obstructs home')
 fixture('ChangedTestHouse',root.Position+Vector3.new(-500,0,0));assert(M.Badge.Enabled and M.Badge:GetAttribute('HouseId')=='ChangedTestHouse','Reassignment not followed')
 screens.Panel.Visible=true;M:Update();assert(not M.Badge.Enabled,'Marker covers menu');screens:Close()
 screens.State={};M:Update();assert(not M.Badge.Enabled,'Unassigned player sees marker')
 screens.State=original;M:Update()
 local count=0;for _,v in ipairs(player.PlayerGui:GetChildren())do if v.Name=='MyHomeMarker'then count+=1 end end
 assert(count==1,'Duplicate or other-player home marker')
 return {HouseId=original.HouseId,PrivateMarkerCount=count,Passed=true}
end
