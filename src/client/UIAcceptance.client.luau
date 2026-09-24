if not game:GetService("RunService"):IsStudio()then return end
local started=false
local function begin()
 if started or workspace:GetAttribute("UIAcceptance")~=true then return end;started=true
 local root=game.ReplicatedStorage:WaitForChild("Neighborhood")
 local probe=root:WaitForChild("UIProbe",15);if not probe then return end
 local ok,result=pcall(function()
  local screens=require(script.Parent.Screens);local deadline=os.clock()+30
  repeat task.wait(.2)until screens.Panel and screens.State.House or os.clock()>deadline
  assert(screens.Panel and screens.State.House,"UI/profile not ready")
  local oldSize=screens.Panel.Size;local checks={}
  for _,width in ipairs({510,360})do
   screens.Panel.Size=UDim2.fromOffset(width,480)
   for _,view in ipairs({"Life","LifeGarden","LifeBusiness","LifeProjects","LifeMystery","LifeTours","LifeMastery","LifeFestival","LifeStop","Building","Crafting","Furnish","Layouts","Adventures","Projects","Phone","Inventory","Cases","Progress","Home","Garage","Pets","Event","Journal","Weather","Collection","Neighbors","Newspaper","Settings","Friends","Boutique","Shop","Pawn"})do
    screens:Open(view);task.wait(.15)
    assert(screens.Panel.Visible and screens.Title.Text~="","Screen failed to open: "..view)
    local rows=0
    for _,row in ipairs(screens.List:GetChildren())do if row:IsA("GuiObject")then
     rows+=1
     assert(row.AbsoluteSize.X<=screens.List.AbsoluteSize.X+1,"Horizontal overflow: "..view)
     for _,label in ipairs(row:GetDescendants())do if label:IsA("TextLabel")then assert(label.TextFits,"Clipped text: "..view.." / "..label.Text)end end
    end end
    table.insert(checks,{View=view,Width=width,Rows=rows})
    screens:Close();assert(not screens.Panel.Visible,"Close failed")
   end
  end
  for _,width in ipairs({510,360})do
   screens.Panel.Size=UDim2.fromOffset(width,480)
   for _,entry in ipairs({{"BuildReview","GardenRoom"},{"Furnish",{Zone="Loft"}},{"Furnish",{Zone="Loft",Cell=1}},{"Furnish",{Zone="Workshop",Cell=2,Rotation=3}}})do
    screens:Open(entry[1],entry[2]);task.wait(.15)
    for _,label in ipairs(screens.List:GetDescendants())do if label:IsA("TextLabel")then assert(label.TextFits,"Expansion text clips: "..label.Text)end end
    local button=screens.List:FindFirstChildWhichIsA("TextButton",true)
    assert(button and button.AbsoluteSize.Y>=48,"Missing accessible expansion action")
    local before=button.AbsoluteSize;screens.Pending={Button=button,Text=button.Text,RequestId=918};button.Text="Working…";button.Active=false
    screens:Resolve(true,917);assert(screens.Pending,"Unrelated response resolved pending action")
    screens:Resolve(false,918);assert(not screens.Pending and screens.Panel.Visible and button.Active and button.AbsoluteSize==before,"Failure did not preserve usable screen")
    table.insert(checks,{View=entry[1],Width=width,ExpansionDetail=true,PendingFailure=true})
    screens:Close()
   end
  end
  for _,width in ipairs({510,360})do for _,height in ipairs({480,220})do
   screens.Panel.Size=UDim2.fromOffset(width,height);screens:Open("Building")
   screens:ShowNotice("You need $900 in game cash. Your current balance has not changed.",false);task.wait(.15)
   assert(screens.Notice.Visible and screens.NoticeText.TextFits,"Notice text does not fit")
   assert(screens.Notice.AbsolutePosition.Y>=screens.Panel.CloseButton.AbsolutePosition.Y+screens.Panel.CloseButton.AbsoluteSize.Y,"Notice covers header controls")
   assert(screens.List.AbsolutePosition.Y>=screens.Notice.AbsolutePosition.Y+screens.Notice.AbsoluteSize.Y,"Notice overlaps action list")
   assert(screens.List.AbsoluteSize.Y>=64,"Notice leaves no usable scrolling area")
   local before=screens.List.AbsoluteSize.Y;screens:ClearNotice();task.wait(.05)
   assert(not screens.Notice.Visible and screens.List.AbsoluteSize.Y>before,"Notice did not release layout space")
   table.insert(checks,{View="Building",Width=width,Height=height,NonOverlappingNotice=true});screens:Close()
  end end
  local gui=game.Players.LocalPlayer.PlayerGui.NeighborhoodApp
  local card=gui:WaitForChild("InteractionCard",10);local hint=gui.NavigationHint
  local host=Instance.new("Frame");host.BackgroundTransparency=1;host.Parent=gui
  card.Parent=host;hint.Parent=host
  for _,size in ipairs({Vector2.new(854,393),Vector2.new(390,844),Vector2.new(640,360)})do
   host.Size=UDim2.fromOffset(size.X,size.Y);gui:SetAttribute("InteractionActive",true);card.Visible=true;task.wait(.1)
   assert(not hint.Visible,"Navigation hint covers interaction card")
   assert(card.AbsolutePosition.Y>=host.AbsolutePosition.Y and card.AbsolutePosition.Y+card.AbsoluteSize.Y<=host.AbsolutePosition.Y+host.AbsoluteSize.Y,"Interaction card outside viewport")
   assert(card:FindFirstChildWhichIsA("TextButton").AbsoluteSize.Y>=48,"Interaction target too small")
   gui:SetAttribute("InteractionActive",false);card.Visible=false;task.wait(.05);assert(hint.Visible,"Hint did not return after interaction")
   table.insert(checks,{View="InteractionHUD",Width=size.X,Height=size.Y,HintHiddenDuringInteraction=true})
  end
  card.Parent=gui;hint.Parent=gui;host:Destroy()
  screens.Panel.Size=oldSize
  local errors={};for _,entry in ipairs(game:GetService("LogService"):GetLogHistory())do if entry.messageType==Enum.MessageType.MessageError then table.insert(errors,entry.message)end end
  assert(#errors==0,table.concat(errors,";"))
  return {Passed=true,Checks=checks,Errors=errors}
 end)
 probe:FireServer(ok and result or {Passed=false,Error=tostring(result)})
end
workspace:GetAttributeChangedSignal("UIAcceptance"):Connect(begin);begin()
