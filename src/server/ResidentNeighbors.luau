-- Lightweight, clearly labelled NPC routines. NPCs never own player save data.

local M={Actors={}}

-- Door-relative route works on both sides of the street and after layout changes.
function M.HomePoints(h)
 local door=h.ClosedCFrame.Position
 local inward=h.Model.Foundation.Position-door;inward=Vector3.new(inward.X,0,inward.Z).Unit
 local ground=Vector3.new(door.X,h.Model.Foundation.Position.Y+h.Model.Foundation.Size.Y/2,door.Z)
 return ground+inward*6,ground-inward*6
end

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

  local inside,outside=M.HomePoints(h)
  local street=require(game.ReplicatedStorage.Neighborhood.Shared.PlotLayout).Street(id)
  local curb=street+(home.X<street and -23 or 23)
  local points={inside,outside,Vector3.new(curb,0,home.Z),Vector3.new(curb,0,-82),Vector3.new(curb,0,-38),Vector3.new(street,0,-28)}

  model:SetAttribute("HomeId",h.Model.Name);model:SetAttribute("RoutineState","At home")
  model:PivotTo(CFrame.new(points[1]+Vector3.new(0,3,0)))

  local dog
  if id%3==0 then
   dog=require(script.Parent.Services.PetService).CreateModel(CFrame.new(points[1]),name.."'s dog",model)
   for _,v in ipairs(dog:GetDescendants())do if v:IsA('BillboardGui')then v:Destroy()end end
   local hand=Instance.new('Attachment');hand.Position=Vector3.new(1,-.4,0);hand.Parent=torso
   local collar=Instance.new('Attachment');collar.Position=Vector3.new(0,.2,-1);collar.Parent=dog.PrimaryPart
   local leash=Instance.new('Beam');leash.Attachment0=hand;leash.Attachment1=collar;leash.Width0=.045;leash.Width1=.045;leash.FaceCamera=true;leash.Color=ColorSequence.new(Color3.fromRGB(94,70,47));leash.Parent=torso
   model:SetAttribute('DogWalker',true)
  end
  M.Actors[h]={Model=model,Dog=dog,Points=points,Index=2,Direction=1,Pause=8+id,Label=text,Name=name,House=h,Junction=Vector3.new(street,.12,-60)}

  h.Model:SetAttribute("NPCResident",name);h.Model.Mailbox.Sign.SurfaceGui.TextLabel.Text=name.."'s House (NPC)\n"..h.Model:GetAttribute("Address")

 end

 context.Interactions:Register("Resident",function(player,target)context.Record(player,"Visit");return true,target:GetAttribute("ResidentName")..": I live here and take walks around town. Try the meadow trials to earn medals and home-upgrade money!"end)

 local tick=0

 game:GetService("RunService").Heartbeat:Connect(function(dt)

  tick+=dt

  if tick>=1 then tick=0;for _,h in pairs(context.Houses.ById)do

   if h.Owner and M.Actors[h]then M.Actors[h].Model:Destroy();M.Actors[h]=nil;h.Model:SetAttribute("NPCResident",nil)

   elseif not h.Owner and not M.Actors[h]then spawn(h)end

  end end

  for h,a in pairs(M.Actors)do
   -- Ownership can change between the one-second population updates.
   if h.Owner then a.Model:Destroy();M.Actors[h]=nil;h.Model:SetAttribute("NPCResident",nil);continue end
   if a.CloseDoor then
    local nearby=false
    for _,player in ipairs(game:GetService("Players"):GetPlayers())do
     local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
     if root and (root.Position-h.ClosedCFrame.Position).Magnitude<7 then nearby=true;break end
    end
    if not nearby then context.Houses:SetDoor(h,false);a.CloseDoor=nil end
   end

   if a.Dog then
    local cf=a.Model.Torso.CFrame
    a.Dog:PivotTo(cf*CFrame.new(2,-1.65,2.5))
   end
   if a.Pause>0 then a.Pause-=dt else
    local streetCrossing=(a.Direction==1 and a.Index==5)or(a.Direction==-1 and a.Index==4)
    if streetCrossing and not a.Crossing then
     if not require(script.Parent.StreetDressing).CanCross(a.Junction)then a.Model:SetAttribute('RoutineState','Waiting at crossing');continue end
     a.Crossing=true;a.Model:SetAttribute('RoutineState','Crossing on walk signal')
    end

    -- Open the real door before traversing the threshold; allow its tween to finish.
    local crossing=(a.Direction==1 and a.Index==2)or(a.Direction==-1 and a.Index==1)
    if crossing and not h.Open then
     context.Houses:SetDoor(h,true);a.OpenedDoor=true;a.CloseDoor=nil;a.Pause=.6
     a.Model:SetAttribute("RoutineState",a.Direction==1 and "Leaving home"or "Returning home")
     continue
    end
    local cf=a.Model:GetPivot();local target=a.Points[a.Index]+Vector3.new(0,3,0);local delta=target-cf.Position

    if delta.Magnitude<.3 then
     if streetCrossing then a.Crossing=nil end
     if crossing and a.OpenedDoor then a.CloseDoor=true;a.OpenedDoor=nil end

     if a.Index==#a.Points then a.Direction=-1;a.Pause=12;a.Label.Text=a.Name.." · enjoying the park";a.Model:SetAttribute("RoutineState","At park")

     elseif a.Index==1 then a.Direction=1;a.Pause=18;a.Label.Text=a.Name.." · at home";a.Model:SetAttribute("RoutineState","At home")end

     a.Index+=a.Direction

    else local pos=cf.Position+delta.Unit*math.min(delta.Magnitude,dt*7);a.Model:PivotTo(CFrame.lookAt(pos,pos+delta.Unit))end

   end

  end

 end)

end

return M
