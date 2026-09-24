local R=game.ServerScriptService.Neighborhood;local M=require(R.TownLifeExpansion);local I=require(R.Services.InteractionService);local p=game.Players:GetPlayers()[1];local rail=M.Root.CoastalRail
local output={}
local v=M.Traffic[1];local start=v.Position;local obstacle=Instance.new('Part');obstacle.Name='TrafficTestObstacle';obstacle.Anchored=true;obstacle.Size=Vector3.new(8,5,8);obstacle.CFrame=v.Model:GetPivot()*CFrame.new(0,0,-12);obstacle.Parent=workspace
task.wait(2);output.stopsForObstacle=(v.Position-start).Magnitude<2;obstacle:Destroy();start=v.Position;task.wait(2);output.resumes=(v.Position-start).Magnitude>20
repeat task.wait(.1)until rail:GetAttribute('Boarding')
local station=rail:GetAttribute('Station');local target;for _,b in ipairs(rail:GetChildren())do if b.Name=='StationBoard'and b:GetAttribute('Station')==station then target=b end end
p.Character:PivotTo(target.CFrame*CFrame.new(0,0,-4));task.wait(.2);local ok,e=I:Request(p,target,'CoastRail');assert(ok,e);task.wait(1)
local seat=M.Passengers[p];seat.Disabled=true;p.Character.Humanoid.Sit=false;local weld=seat:FindFirstChild('SeatWeld');if weld then weld:Destroy()end
p.Character:PivotTo(CFrame.new(573,6,target.Position.Z+8));task.wait(3);output.earlyExitClearsPassenger=M.Passengers[p]==nil
local before=p.Character.HumanoidRootPart.Position;task.wait(20);output.noLaterTeleport=(p.Character.HumanoidRootPart.Position-before).Magnitude<8
workspace:SetAttribute('MobilityDeepResults',game.HttpService:JSONEncode(output))

