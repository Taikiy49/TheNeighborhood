local function value(v)
 local kind=typeof(v)
 if kind=="Vector3"then return {v.X,v.Y,v.Z}
 elseif kind=="Vector2"then return {v.X,v.Y}
 elseif kind=="Color3"then return {v.R,v.G,v.B}
 elseif kind=="CFrame"then return {v:GetComponents()}
 elseif kind=="UDim2"then return {UDim2={{v.X.Scale,v.X.Offset},{v.Y.Scale,v.Y.Offset}}}
 elseif kind=="UDim"then return {UDim={v.Scale,v.Offset}}
 elseif kind=="EnumItem"then return {Enum=v.Value}
 elseif kind=="string" or kind=="number" or kind=="boolean"then return v end
end
local function export(instance)
 local node={Name=instance.Name,ClassName=instance.ClassName,Properties={},Children={}}
 local function properties(names)for _,name in ipairs(names)do local ok,v=pcall(function()return instance[name]end);if ok then node.Properties[name]=value(v)end end end
 if instance:IsA("BasePart")then properties({"Size","CFrame","Color","Material","Transparency","Reflectance","Anchored","CanCollide","CanQuery","CanTouch","CastShadow","TopSurface","BottomSurface"});if instance:IsA("Part")then properties({"Shape"})end end
 if instance:IsA('MeshPart')then properties({'MeshId','TextureID','DoubleSided','RenderFidelity','CollisionFidelity','MeshSize'})end
 if instance:IsA('Decal')then properties({'Texture','Face','Color3','Transparency','ZIndex'})end
 if instance:IsA('Texture')then properties({'StudsPerTileU','StudsPerTileV','OffsetStudsU','OffsetStudsV'})end
 if instance:IsA("SpawnLocation")then properties({"Neutral","Duration","Enabled"})end
 if instance:IsA("ProximityPrompt")then properties({"ActionText","ObjectText","Style","HoldDuration","MaxActivationDistance","RequiresLineOfSight","KeyboardKeyCode","GamepadKeyCode","Enabled"})end
 if instance:IsA("PointLight")then properties({"Brightness","Range","Color","Enabled","Shadows"})end
 if instance:IsA("GuiObject")then properties({"Size","Position","AnchorPoint","BackgroundColor3","BackgroundTransparency","BorderSizePixel","Visible","ZIndex"})end
 if instance:IsA("TextLabel")then properties({"Text","TextColor3","TextSize","TextScaled","TextWrapped","Font","TextXAlignment","TextYAlignment"})end
 if instance:IsA("SurfaceGui")then properties({"Face","CanvasSize","LightInfluence","AlwaysOnTop","PixelsPerStud","SizingMode"})end
 if instance:IsA("BillboardGui")then properties({"Size","StudsOffset","MaxDistance","AlwaysOnTop","LightInfluence"})end
 if instance:IsA("UIPadding")then properties({"PaddingLeft","PaddingRight","PaddingTop","PaddingBottom"})end
 if instance:IsA("UICorner")then properties({"CornerRadius"})end
 local attrs={}
 for k,v in pairs(instance:GetAttributes())do local kind=typeof(v);attrs[k]={[kind=="number" and "Float64" or kind=="boolean" and "Bool" or "String"]=v}end
 if instance:IsA("Model")and instance.PrimaryPart then attrs.ExportPrimaryPart={String=instance.PrimaryPart.Name}end
 if next(attrs)then node.Properties.Attributes={Attributes=attrs}end

 if #node.Children==0 then node.Children=nil end
 if not next(node.Properties)then node.Properties=nil end
 return node
end
local objects={workspace.Neighborhood};for _,v in ipairs(workspace.Neighborhood:GetDescendants())do table.insert(objects,v)end
local indices={};for i,v in ipairs(objects)do indices[v]=i end
local records={};for i,v in ipairs(objects)do records[i]={Index=i,Parent=indices[v.Parent] or 0,Node=export(v)}end
_G.CodexNeighborhoodSceneExport=records
return #records
