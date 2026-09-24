local UI=require(script.Parent.UI)
local Prompts=game:GetService("ProximityPromptService")
local Controller={}
function Controller.Init(gui)
 local card=UI.Panel(gui,UDim2.fromOffset(280,112),UDim2.new(0.5,0,1,-32));card.AnchorPoint=Vector2.new(0.5,1);card.Name="InteractionCard";card.Visible=false;card.ZIndex=5
 local label=UI.Label(card,"",UDim2.new(1,-24,0,38),UDim2.fromOffset(12,6),14)
 local current
 local button=UI.Button(card,"Interact",UDim2.new(1,-24,0,48),UDim2.fromOffset(12,52),function()
  if current and current.Parent then current:InputHoldBegin();current:InputHoldEnd() end
 end)
 Prompts.PromptShown:Connect(function(prompt,inputType)
  if not prompt:IsDescendantOf(workspace.Neighborhood) then return end
  current=prompt;label.Text=prompt.ObjectText
  local prefix=inputType==Enum.ProximityPromptInputType.Keyboard and "["..prompt.KeyboardKeyCode.Name.."] " or inputType==Enum.ProximityPromptInputType.Gamepad and "[X] " or ""
  button.Text=prefix..prompt.ActionText;card.Visible=true;gui:SetAttribute("InteractionActive",true)
 end)
 Prompts.PromptHidden:Connect(function(prompt)if current==prompt then current=nil;card.Visible=false;gui:SetAttribute("InteractionActive",false) end end)
end
return Controller
