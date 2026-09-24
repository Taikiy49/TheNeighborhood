local Theme=require(game.ReplicatedStorage.Neighborhood.Shared.Theme)
local UI={Theme=Theme}
function UI.New(class,props,parent)
    local item=Instance.new(class)
    for key,value in pairs(props or {}) do item[key]=value end
    item.Parent=parent; return item
end
function UI.Panel(parent,size,pos)
    local panel=UI.New("Frame",{Size=size,Position=pos,BackgroundColor3=Theme.Surface,BorderSizePixel=0},parent)
    UI.New("UICorner",{CornerRadius=UDim.new(0,Theme.Radius)},panel)
    return panel
end
function UI.Label(parent,text,size,pos,fontSize,color)
    return UI.New("TextLabel",{Size=size,Position=pos,BackgroundTransparency=1,Text=text,TextColor3=color or Theme.Text,Font=Theme.Body,TextSize=fontSize or Theme.BodySize,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true},parent)
end
function UI.Button(parent,text,size,pos,callback)
    local button=UI.New("TextButton",{Size=size,Position=pos,BackgroundColor3=Theme.Primary,TextColor3=Theme.Surface,Text=text,Font=Theme.Body,TextSize=Theme.BodySize,BorderSizePixel=0,AutoButtonColor=true,Selectable=true},parent)
    button.Name=text:gsub("%W","").."Button"
    UI.New("UICorner",{CornerRadius=UDim.new(0,Theme.Radius)},button)
    button.Activated:Connect(function()if button.Active then callback()end end)
    local focus=UI.New('UIStroke',{Color=Theme.Accent,Thickness=3,Enabled=false,ApplyStrokeMode=Enum.ApplyStrokeMode.Border},button)
    button.SelectionGained:Connect(function()focus.Enabled=true end)
    button.SelectionLost:Connect(function()focus.Enabled=false end)
    return button
end
function UI.Progress(parent,size,pos)
    local frame=UI.New('Frame',{Name='Progress',Size=size,Position=pos,BackgroundTransparency=1},parent)
    local label=UI.Label(frame,'',UDim2.new(1,0,0,22),UDim2.new(),Theme.Small)
    local track=UI.Panel(frame,UDim2.new(1,0,0,12),UDim2.fromOffset(0,26));track.Name='Track';track.BackgroundColor3=Theme.Track;track.ClipsDescendants=true
    local fill=UI.Panel(track,UDim2.new(),UDim2.new());fill.Name='Fill';fill.BackgroundColor3=Theme.Primary
    local p={Frame=frame,Fill=fill,Label=label}
    function p:Set(value,total,text)
        value=type(value)=='number'and value==value and value or 0;total=type(total)=='number'and total>0 and total or 1
        local ratio=math.clamp(value/total,0,1);fill.Size=UDim2.fromScale(ratio,1);fill.Visible=ratio>0
        label.Text=text or math.min(value,total)..' / '..total;frame:SetAttribute('Value',value);frame:SetAttribute('Total',total)
    end
    p:Set(0,1,'Getting ready…');return p
end
return UI
