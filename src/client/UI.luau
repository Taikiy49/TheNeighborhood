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
    button.Activated:Connect(callback); return button
end
return UI
