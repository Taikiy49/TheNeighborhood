-- Lightweight, clearly labelled NPC routines. NPCs never own player save data.

local M={Actors={}}

local names={"Mabel","Rowan","Juniper","Theo","Hazel","Finn","Olive","Jasper","Poppy","Miles","Cleo","Arthur"}

function M.Init(context)

 M.Context=context

 local folder=Instance.new("Folder");folder.Name="ResidentNeighbors";folder.Parent=workspace.Neighborhood.Runtime

 local function spawn(h)

  local id=tonumber(h.Model.Name:match("%d+"));local name=names[id]

  local model=workspace.Neighborhood.GuideCharacters.Mabel:Clone();model.Name=name.." (NPC)";model.Parent=folder

  for _,v in ipairs(model:GetDescendants())do if v:IsA("ProximityPrompt")or v:IsA("BillboardGui")then v:Destroy()elseif v:IsA("BasePart")then v.CanCollide=false;v.CanQuery=false;v.CanTouch=false end end

  local torso=model.Torso;torso:SetAttribute("Action","Resident");torso:SetAttribute("ResidentName",name);torso.CanQuery=true

  local q=Instance.new("ProximityPrompt");q.ActionText="Say hello";q.ObjectText=name.." · NPC neighbor";q.Style=Enum.ProximityPromptStyle.Custom;q.MaxActivationDistance=10;q.RequiresLineOfSight=false;q:SetAttribute("Action","Resident");q.Parent=torso

  local tag=Instance.new("BillboardGui");tag.Size=UDim2.fromOffset(160,38);tag.StudsOffset=Vector3.new(0,2,0);tag.MaxDistance=45;tag.Parent=model.Head

  local text=Instance.new("TextLabel");text.Size=UDim2.fromScale(1,1);text.BackgroundTransparency=1;text.TextColor3=Color3.fromRGB(245,240,222);text.TextStrokeTransparency=.4;text.TextSize=13;text.Text=name.." · NPC";text.Parent=tag

  local home=h.Model.Foundation.Position;local side=home.X<0 and -1 or 1

  local points={Vector3.new(side*84,0,home.Z),Vector3.new(side*75,0,home.Z),Vector3.new(side*75,0,60),Vector3.new(side*43,0,60),Vector3.new(side*43,0,0),Vector3.new(side*20,0,0)}

  model:PivotTo(CFrame.new(points[1]+Vector3.new(0,3,0)))

  M.Actors[h]={Model=model,Points=points,Index=2,Direction=1,Pause=0,Label=text,Name=name}

  h.Model:SetAttribute("NPCResident",name);h.Model.Mailbox.Sign.SurfaceGui.TextLabel.Text=name.."'s House (NPC)\n"..h.Model:GetAttribute("Address")

 end

 context.Interactions:Register("Resident",function(player,target)context.Record(player,"Visit");return true,target:GetAttribute("ResidentName")..": I'm heading around the green. Try the meadow trials to earn medals and home-upgrade money!"end)

 local tick=0

 game:GetService("RunService").Heartbeat:Connect(function(dt)

  tick+=dt

  if tick>=1 then tick=0;for _,h in pairs(context.Houses.ById)do

   if h.Owner and M.Actors[h]then M.Actors[h].Model:Destroy();M.Actors[h]=nil;h.Model:SetAttribute("NPCResident",nil)

   elseif not h.Owner and not M.Actors[h]then spawn(h)end

  end end

  for _,a in pairs(M.Actors)do

   if a.Pause>0 then a.Pause-=dt else

    local cf=a.Model:GetPivot();local target=a.Points[a.Index]+Vector3.new(0,3,0);local delta=target-cf.Position

    if delta.Magnitude<.3 then

     if a.Index==#a.Points then a.Direction=-1;a.Pause=12;a.Label.Text=a.Name.." · enjoying the park"

     elseif a.Index==1 then a.Direction=1;a.Pause=18;a.Label.Text=a.Name.." · NPC neighbor"end

     a.Index+=a.Direction

    else local pos=cf.Position+delta.Unit*math.min(delta.Magnitude,dt*7);a.Model:PivotTo(CFrame.lookAt(pos,pos+delta.Unit))end

   end

  end

 end)

end

return M
