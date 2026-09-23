local Guide={}
local definitions={
 Mabel={Name="Mabel · Neighborhood guide (NPC)",Position=Vector3.new(8,0,-95),Color=Color3.fromRGB(212,168,95),Lines={{"Welcome to Maple Street","The address at the top of your screen is your home. Open the door and place your starter furniture on the marked spots."},{"Honest work pays","The community board gives parcel deliveries. Deliver to the correct mailbox, then spend your earnings at Maple & Co."},{"Keep it yours","Stored items are protected. Displayed items may tempt a visitor. Locks slow thieves down; cameras provide clues."}}},
 Detective={Name="Ellis · Retired detective (NPC)",Position=Vector3.new(-9,0,0),Color=Color3.fromRGB(103,134,150),Lines={{"Follow the evidence","Camera descriptions are incomplete observations, not a name tag. Compare what you saw with the neighbors around you."},{"A useful case file","Open Cases to review the timeline. A supported accusation helps recover possessions. Random accusations cost reputation."},{"Check the pawn counter","If a stolen possession was fenced, its original owner can identify and reclaim it."}}},
 Dealer={Name="Frank · Pawn clerk (NPC)",Position=Vector3.new(28,1,164),Color=Color3.fromRGB(141,119,151),Lines={{"Entirely respectable business","We buy stored possessions for less than retail. The counter also handles missing-property claims."},{"Heavy merchandise","If you're carrying something questionable, get clear of the house before approaching the counter. We dislike paperwork."}}},
}
function Guide.Install()
 local world=workspace.Neighborhood
 local folder=world:FindFirstChild("GuideCharacters") or Instance.new("Folder");folder.Name="GuideCharacters";folder.Parent=world
 for id,definition in pairs(definitions)do if not folder:FindFirstChild(id)then
  local model=Instance.new("Model");model.Name=id;model.Parent=folder
  local function part(name,size,offset,color)
   local p=Instance.new("Part");p.Name=name;p.Size=size;p.CFrame=CFrame.new(definition.Position+offset);p.Color=color;p.Anchored=true;p.CanCollide=false;p.Parent=model;return p
  end
  local torso=part("Torso",Vector3.new(2.2,2.6,1),Vector3.new(0,3.6,0),definition.Color)
  local head=part("Head",Vector3.new(1.6,1.6,1.6),Vector3.new(0,5.7,0),Color3.fromRGB(207,162,124));head.Shape=Enum.PartType.Ball
  for _,side in ipairs({-1,1})do part("Arm",Vector3.new(0.7,2.5,0.8),Vector3.new(side*1.5,3.6,0),definition.Color);part("Leg",Vector3.new(0.8,2.3,0.9),Vector3.new(side*0.55,1.4,0),Color3.fromRGB(57,70,65))end
  torso:SetAttribute("Action","Guide");torso:SetAttribute("GuideId",id)
  local prompt=Instance.new("ProximityPrompt");prompt.Style=Enum.ProximityPromptStyle.Custom;prompt.ActionText="Talk";prompt.ObjectText=definition.Name;prompt.MaxActivationDistance=10;prompt:SetAttribute("Action","Guide");prompt.Parent=torso
  local label=Instance.new("BillboardGui");label.Size=UDim2.fromOffset(220,36);label.StudsOffset=Vector3.new(0,1.8,0);label.MaxDistance=50;label.Parent=head
  local text=Instance.new("TextLabel");text.Size=UDim2.fromScale(1,1);text.BackgroundColor3=Color3.fromRGB(35,79,70);text.BackgroundTransparency=0.1;text.TextColor3=Color3.fromRGB(244,245,236);text.TextSize=12;text.Font=Enum.Font.GothamBold;text.Text=definition.Name;text.Parent=label
 end end
end
function Guide.Init(context)
 context.Interactions:Register("Guide",function(player,target)local def=definitions[target:GetAttribute("GuideId")];if not def then return false,"This neighbor is unavailable."end;context.Open(player,"Guide",{Name=def.Name,Lines=def.Lines});return true end)
end
return Guide
