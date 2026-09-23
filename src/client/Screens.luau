local UI=require(script.Parent.UI)
local Defs=require(game.ReplicatedStorage.Neighborhood.Shared.ItemDefinitions)
local Screens={State={Inventory={}}}
function Screens:Init(gui,request)
 self.Request=request
 self.Panel=UI.Panel(gui,UDim2.new(0.9,0,0.72,0),UDim2.fromScale(0.5,0.5));self.Panel.AnchorPoint=Vector2.new(0.5,0.5);self.Panel.Visible=false
 UI.New("UISizeConstraint",{MaxSize=Vector2.new(510,560)},self.Panel)
 self.Title=UI.Label(self.Panel,"",UDim2.new(1,-92,0,48),UDim2.fromOffset(16,8),UI.Theme.Title);self.Title.Font=UI.Theme.Display
 UI.Button(self.Panel,"Close",UDim2.fromOffset(72,48),UDim2.new(1,-80,0,8),function() self.Panel.Visible=false end)
 self.List=UI.New("ScrollingFrame",{Size=UDim2.new(1,-24,1,-76),Position=UDim2.fromOffset(12,64),BackgroundTransparency=1,BorderSizePixel=0,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(),ScrollBarThickness=6,ScrollBarImageColor3=UI.Theme.Primary},self.Panel)
 UI.New("UIListLayout",{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder},self.List)
end
function Screens:Row(title,subtitle,action,callback)
 local row=UI.Panel(self.List,UDim2.new(1,-10,0,116),UDim2.new())
 UI.Label(row,title,UDim2.new(1,-16,0,25),UDim2.fromOffset(8,0),18)
 UI.Label(row,subtitle,UDim2.new(1,-16,0,30),UDim2.fromOffset(8,26),14,UI.Theme.Muted)
 if action then UI.Button(row,action,UDim2.new(1,-16,0,48),UDim2.fromOffset(8,60),function()
  callback(); self.Panel.Visible=false
 end) end
end
function Screens:Open(view,detail)
 for _,child in ipairs(self.List:GetChildren()) do if child:IsA("GuiObject") then child:Destroy() end end
 self.Title.Text=view=="Shop" and "Maple & Co." or view=="Pawn" and "Make a deal" or view=="Place" and "Make it yours" or view=="Item" and "A closer look" or view=="Cases" and "Your case files" or "Your inventory"
 local count=0
 if view=="Shop" then
  local ids={};for id in pairs(Defs) do table.insert(ids,id) end;table.sort(ids,function(a,b)return Defs[a].Value<Defs[b].Value end)
  for _,id in ipairs(ids) do local def=Defs[id];self:Row(def.Name,def.Rarity.." • "..def.Description,"Buy · $"..def.Value,function()self.Request("Buy",id)end) end
 elseif view=="Item" then
  local def=Defs[detail.DefinitionId]
  local recover=detail.State=="Carried" or detail.State=="Escaped"
  local action=detail.Owned and (recover and "Recover your possession" or "Put in protected inventory") or "Steal · triggers display alarm"
  self:Row(def.Name,def.Rarity.." • "..def.Weight.." kg • $"..def.Value,action,function()self.Request(detail.Owned and (recover and "Recover" or "Store") or "Steal",detail.Id)end)
  if not detail.Owned then self:Row("Know the risk","Stay beside it to lift. Cameras may see you. Heavy items slow you down.") end
 elseif view=="Cases" then
  for _,incident in ipairs(self.State.Incidents or {}) do
   count+=1
   self:Row(incident.ItemName,incident.Status.." • "..os.date("!%H:%M UTC",incident.Time),incident.Status=="Missing" and "Open case" or nil,function()self.Request("Case",incident.Id)end)
   for _,evidence in ipairs(incident.Evidence) do self:Row(evidence.Kind,evidence.Quality.." · "..evidence.Description) end
  end
  if count==0 then self:Row("Quiet on Maple Street","No incidents recorded. Your protected inventory is safe; displayed items may attract attention.") end
 elseif view=="Place" or view=="Pawn" or view=="Inventory" then
  if view=="Pawn" and self.State.Carrying then self:Row(self.State.Carrying,"Found it? Of course you did.","Fence carried item",function()self.Request("Fence","")end) end
  for _,item in ipairs(self.State.Inventory or {}) do
   if item.State=="Stored" or view=="Inventory" then
    count+=1;local def=Defs[item.DefinitionId]
    local action=view=="Place" and "Place here" or view=="Pawn" and "Sell · $"..math.floor(def.Value*0.4) or nil
    self:Row(def.Name,def.Rarity.." • "..item.State,action,function()self.Request(view=="Place" and "Place" or "Sell",item.Id,detail)end)
   end
  end
  if count==0 then self:Row("Nothing stored yet","Buy something at Maple & Co., or put a displayed item back in your inventory.") end
 end
 self.List.CanvasPosition=Vector2.zero;self.Panel.Visible=true
end
return Screens
