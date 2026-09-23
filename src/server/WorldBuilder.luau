local Builder={}
local palette={Grass=Color3.fromRGB(132,164,101),Road=Color3.fromRGB(67,76,79),Paving=Color3.fromRGB(218,214,195),Trim=Color3.fromRGB(246,237,210),Roof=Color3.fromRGB(61,78,77),Wood=Color3.fromRGB(127,88,59),Teal=Color3.fromRGB(35,79,70)}
local function folder(name,parent,class) local f=Instance.new(class or "Folder"); f.Name=name; f.Parent=parent; return f end
local function part(parent,name,size,cf,color,material)
    local p=Instance.new("Part"); p.Name=name; p.Size=size; p.CFrame=cf; p.Color=color; p.Material=material or Enum.Material.SmoothPlastic; p.Anchored=true; p.TopSurface=Enum.SurfaceType.Smooth; p.BottomSurface=Enum.SurfaceType.Smooth; p.Parent=parent; return p
end
local function sign(p,text,color)
    local gui=Instance.new("SurfaceGui");gui.Name="SurfaceGui";gui.Face=Enum.NormalId.Front;gui.CanvasSize=Vector2.new(600,200);gui.Parent=p
    local label=Instance.new("TextLabel");label.Name="TextLabel";label.Size=UDim2.fromScale(1,1);label.BackgroundTransparency=1;label.Text=text;label.TextColor3=color or palette.Trim;label.Font=Enum.Font.GothamBold;label.TextScaled=true;label.Parent=gui
    local padding=Instance.new("UIPadding");padding.PaddingLeft=UDim.new(0,12);padding.PaddingRight=UDim.new(0,12);padding.PaddingTop=UDim.new(0,12);padding.PaddingBottom=UDim.new(0,12);padding.Parent=label
end
local function prompt(p,action,text,object,houseId,secondary)
    p:SetAttribute(secondary and "SecondaryAction" or "Action",action)
    if houseId then p:SetAttribute("HouseId",houseId) end
    local pp=Instance.new("ProximityPrompt"); pp.Name=action;pp.ActionText=text;pp.ObjectText=object;pp.MaxActivationDistance=10;pp.RequiresLineOfSight=true;pp.HoldDuration=0;pp.KeyboardKeyCode=secondary and Enum.KeyCode.F or Enum.KeyCode.E;pp.GamepadKeyCode=secondary and Enum.KeyCode.ButtonY or Enum.KeyCode.ButtonX;pp:SetAttribute("Action",action);pp.Parent=p
end
local function tree(parent,x,z,scale)
    local trunk=part(parent,"Trunk",Vector3.new(1.8,9,1.8)*scale,CFrame.new(x,4.5*scale,z),palette.Wood,Enum.Material.Wood)
    local crown=part(parent,"Canopy",Vector3.new(12,12,12)*scale,CFrame.new(x,12*scale,z),Color3.fromRGB(81,125,79),Enum.Material.Grass);crown.Shape=Enum.PartType.Ball
    local crown2=part(parent,"Canopy",Vector3.new(9,10,9)*scale,CFrame.new(x+3*scale,14*scale,z-2*scale),Color3.fromRGB(102,148,87),Enum.Material.Grass);crown2.Shape=Enum.PartType.Ball
end
function Builder.Build()
    assert(not workspace:FindFirstChild("Neighborhood"),"World already exists; preserve it and edit deliberately.")
    local baseline=folder("NeighborhoodBaseline",game.ServerStorage)
    for _,name in ipairs({"Baseplate","SpawnLocation"}) do local old=workspace:FindFirstChild(name);if old then old.Parent=baseline end end
    local world=folder("Neighborhood",workspace)
    local map=folder("Map",world);local houses=folder("Houses",world);local shops=folder("Shops",world);folder("Runtime",world)
    part(map,"VillageGround",Vector3.new(360,4,350),CFrame.new(0,-2,0),palette.Grass,Enum.Material.Grass)
    -- Compact loop around a park; rear paths connect all four rows of gardens.
    for _,x in ipairs({-42,42}) do
        part(map,"MapleStreet",Vector3.new(20,0.18,266),CFrame.new(x,0.08,0),palette.Road,Enum.Material.Asphalt)
        for _,offset in ipairs({-14,14}) do part(map,"Sidewalk",Vector3.new(7,0.5,270),CFrame.new(x+offset,0.25,0),palette.Paving,Enum.Material.Concrete) end
        for z=-112,112,16 do part(map,"LaneMark",Vector3.new(0.3,0.02,6),CFrame.new(x,0.18,z),palette.Trim) end
    end
    for _,z in ipairs({-127,127}) do part(map,"CrossStreet",Vector3.new(104,0.18,20),CFrame.new(0,0.08,z),palette.Road,Enum.Material.Asphalt) end
    part(map,"ParkWalk",Vector3.new(10,0.25,220),CFrame.new(0,0.15,0),palette.Paving,Enum.Material.Concrete)
    part(map,"ParkCrosswalk",Vector3.new(130,0.25,8),CFrame.new(0,0.2,0),palette.Paving,Enum.Material.Concrete)
    local parkSign=part(map,"MapleGreenSign",Vector3.new(18,4,0.6),CFrame.new(0,5,-104),palette.Teal);sign(parkSign,"MAPLE GREEN\nGood fences. Interesting neighbors.")
    for _,x in ipairs({-17,17}) do for _,z in ipairs({-76,-36,36,76}) do tree(map,x,z,0.8) end end
    for _,z in ipairs({-54,54}) do
        for _,x in ipairs({-14,14}) do
            local bench=folder("ParkBench",map,"Model")
            part(bench,"Seat",Vector3.new(8,0.6,2.5),CFrame.new(x,2,z),palette.Wood,Enum.Material.Wood)
            part(bench,"Back",Vector3.new(8,2,0.5),CFrame.new(x,3,z+1),palette.Wood,Enum.Material.Wood)
            for _,dx in ipairs({-3,3}) do part(bench,"Leg",Vector3.new(0.5,2,2),CFrame.new(x+dx,1,z),palette.Roof) end
        end
    end
    local colors={Color3.fromRGB(175,202,185),Color3.fromRGB(223,178,144),Color3.fromRGB(154,187,205),Color3.fromRGB(226,211,157),Color3.fromRGB(209,163,158),Color3.fromRGB(168,180,204),Color3.fromRGB(211,208,180),Color3.fromRGB(153,197,187)}
    local n=0
    for _,side in ipairs({-1,1}) do for _,z in ipairs({-93,-31,31,93}) do
        n+=1
        local id=string.format("House%02d",n);local house=folder(id,houses,"Model")
        house:SetAttribute("Address",tostring(100+n).." Maple Street"); house:SetAttribute("OwnerUserId",0);house:SetAttribute("Locked",false)
        local base=CFrame.new(side*94,0,z)*CFrame.Angles(0,side==1 and math.pi/2 or -math.pi/2,0)
        local function hp(name,size,position,color,material) return part(house,name,size,base*CFrame.new(position),color,material) end
        hp("Lawn",Vector3.new(49,0.2,54),Vector3.new(0,0.1,2),palette.Grass,Enum.Material.Grass)
        hp("Foundation",Vector3.new(30,1,26),Vector3.new(0,0.5,0),palette.Trim,Enum.Material.Concrete)
        hp("Floor",Vector3.new(28,0.2,24),Vector3.new(0,1.1,0),Color3.fromRGB(193,153,104),Enum.Material.WoodPlanks)
        hp("BackWall",Vector3.new(30,11,0.7),Vector3.new(0,6.5,12.6),colors[n])
        hp("LeftWall",Vector3.new(0.7,11,26),Vector3.new(-14.6,6.5,0),colors[n])
        hp("RightWall",Vector3.new(0.7,11,26),Vector3.new(14.6,6.5,0),colors[n])
        -- Front window openings expose the valuables instead of hiding solid walls behind glass.
        hp("FrontSill",Vector3.new(30,3,0.7),Vector3.new(0,2.5,-12.6),colors[n])
        hp("FrontHeader",Vector3.new(30,2.5,0.7),Vector3.new(0,10.75,-12.6),colors[n])
        for _,x in ipairs({-14,-4,4,14}) do hp("FrontPost",Vector3.new(1.3,7,0.9),Vector3.new(x,6.5,-12.6),palette.Trim) end
        -- Clear the doorway through the sill by splitting the front lower wall.
        house.FrontSill:Destroy()
        for _,x in ipairs({-9,9}) do hp("FrontSill",Vector3.new(12,3,0.7),Vector3.new(x,2.5,-12.6),colors[n]) end
        for _,x in ipairs({-9,9}) do
            local glass=hp("Window",Vector3.new(8.5,5.4,0.2),Vector3.new(x,6.75,-12.65),Color3.fromRGB(183,222,220),Enum.Material.Glass);glass.Transparency=0.7
            hp("WindowMullion",Vector3.new(0.25,5.8,0.4),Vector3.new(x,6.7,-12.8),palette.Trim)
            hp("WindowCrossbar",Vector3.new(9,0.3,0.4),Vector3.new(x,6.4,-12.8),palette.Trim)
            for _,dx in ipairs({-5,5}) do hp("Shutter",Vector3.new(1.3,6,0.6),Vector3.new(x+dx,6.7,-13),palette.Teal) end
        end
        local roofHeight=5+(n%3)
        local pitch=math.atan(roofHeight/16)
        for _,slope in ipairs({-1,1}) do
            part(house,"Roof",Vector3.new(math.sqrt(16*16+roofHeight*roofHeight),0.8,29),base*CFrame.new(slope*8,12.4+roofHeight/2,0)*CFrame.Angles(0,0,-slope*pitch),palette.Roof,Enum.Material.Slate)
        end
        hp("Ceiling",Vector3.new(29,0.5,25),Vector3.new(0,11.9,0),palette.Trim)
        hp("Chimney",Vector3.new(3,7,3),Vector3.new(9,15,6),Color3.fromRGB(149,99,78),Enum.Material.Brick)
        local door=hp("Door",Vector3.new(5.8,8,0.55),Vector3.new(0,5,-12.6),palette.Teal)
        prompt(door,"Door","Open / close","Front door",id)
        local lock=hp("Lock",Vector3.new(0.45,0.8,0.5),Vector3.new(3.6,4.6,-13.2),Color3.fromRGB(203,165,74),Enum.Material.Metal);prompt(lock,"Lock","Lock / unlock","Homeowner only",id)
        hp("Porch",Vector3.new(17,0.8,6),Vector3.new(0,0.4,-16),palette.Paving)
        hp("FrontPath",Vector3.new(7,0.25,17),Vector3.new(0,0.15,-24),palette.Paving)
        for _,x in ipairs({-7,7}) do hp("PorchColumn",Vector3.new(0.7,10,0.7),Vector3.new(x,5.5,-17),palette.Trim) end
        hp("PorchRoof",Vector3.new(18,0.7,6),Vector3.new(0,10.2,-15.5),palette.Roof)
        local bell=hp("Doorbell",Vector3.new(0.6,0.9,0.5),Vector3.new(-3.6,4.6,-13.2),Color3.fromRGB(203,165,74));prompt(bell,"Doorbell","Ring","Doorbell",id)
        local light=hp("PorchLamp",Vector3.new(0.7,1.1,0.7),Vector3.new(4.5,8.8,-13.2),Color3.fromRGB(255,216,142),Enum.Material.Neon)
        local pl=Instance.new("PointLight");pl.Brightness=0.7;pl.Range=14;pl.Color=light.Color;pl.Parent=light
        local number=hp("AddressPlaque",Vector3.new(4,1.3,0.3),Vector3.new(0,9.3,-13.2),palette.Teal);sign(number,tostring(100+n))
        local arrival=hp("Arrival",Vector3.new(1,1,1),Vector3.new(0,4,-24),palette.Trim);arrival.Transparency=1;arrival.CanCollide=false;arrival.CanQuery=false
        local mailbox=folder("Mailbox",house,"Model")
        part(mailbox,"Post",Vector3.new(0.8,3.5,0.8),base*CFrame.new(10,1.75,-28),palette.Wood)
        part(mailbox,"Box",Vector3.new(3,1.8,2),base*CFrame.new(10,3.9,-28),palette.Teal)
        local ms=part(mailbox,"Sign",Vector3.new(5,1.6,0.25),base*CFrame.new(10,5.2,-29),palette.Teal);sign(ms,tostring(100+n).." Maple Street\nAvailable")
        part(mailbox,"Flag",Vector3.new(0.15,1.2,0.7),base*CFrame.new(11.6,4.7,-28),Color3.fromRGB(194,83,63))
        local slots=folder("DisplaySlots",house)
        for slot=1,6 do
            local x=((slot-1)%3-1)*9;local sz=slot<=3 and -5 or 7
            local pad=part(slots,"Slot"..slot,Vector3.new(6,0.15,6),base*CFrame.new(x,1.3,sz),Color3.fromRGB(221,204,171));pad:SetAttribute("Slot",slot);pad:SetAttribute("HouseId",id)
        end
        for _,x in ipairs({-24,24}) do hp("GardenFence",Vector3.new(0.5,3.5,36),Vector3.new(x,1.75,8),palette.Trim,Enum.Material.WoodPlanks) end
        -- Leave a generous rear gate opening for future chase routes.
        for _,x in ipairs({-15,15}) do hp("RearFence",Vector3.new(18,3.5,0.5),Vector3.new(x,1.75,27),palette.Trim,Enum.Material.WoodPlanks) end
        for _,x in ipairs({-12,12}) do local shrub=hp("PorchShrub",Vector3.new(4,3,3),Vector3.new(x,1.7,-16),Color3.fromRGB(73,120,73),Enum.Material.Grass);shrub.Shape=Enum.PartType.Ball end
        local treePos=(base*CFrame.new(-18,0,19)).Position;tree(house,treePos.X,treePos.Z,0.9)
    end end
    for _,x in ipairs({-127,127}) do part(map,"BackyardShortcut",Vector3.new(6,0.12,263),CFrame.new(x,0.08,0),Color3.fromRGB(184,169,130),Enum.Material.Ground) end
    for _,x in ipairs({-29,29}) do for _,z in ipairs({-111,-48,48,111}) do
        part(map,"LampPost",Vector3.new(0.5,12,0.5),CFrame.new(x,6,z),palette.Roof,Enum.Material.Metal)
        local head=part(map,"Lantern",Vector3.new(1.6,2,1.6),CFrame.new(x,12,z),Color3.fromRGB(255,218,151),Enum.Material.Neon)
        local light=Instance.new("PointLight");light.Brightness=0.6;light.Range=20;light.Color=head.Color;light.Parent=head
    end end
    for _,shopDef in ipairs({{Name="GeneralStore",X=-28,Title="MAPLE & CO.\nGood things for your home",Color=Color3.fromRGB(215,168,119)},{Name="PawnShop",X=28,Title="TOTALLY LEGAL\nPAWN SHOP",Color=Color3.fromRGB(143,175,158)}}) do
        local shop=folder(shopDef.Name,shops,"Model"); local x=shopDef.X
        part(shop,"Floor",Vector3.new(38,1,25),CFrame.new(x,0.5,157),palette.Paving)
        part(shop,"Back",Vector3.new(38,14,1),CFrame.new(x,7,169),shopDef.Color)
        for _,dx in ipairs({-19,19}) do part(shop,"Wall",Vector3.new(1,14,25),CFrame.new(x+dx,7,157),shopDef.Color) end
        part(shop,"Roof",Vector3.new(40,1,28),CFrame.new(x,14.5,157),palette.Roof)
        local s=part(shop,"Sign",Vector3.new(35,4,0.7),CFrame.new(x,11,144),palette.Teal);sign(s,shopDef.Title)
        part(shop,"Awning",Vector3.new(40,0.4,7),CFrame.new(x,9,142)*CFrame.Angles(math.rad(8),0,0),shopDef.Color)
        local counter=part(shop,"Counter",Vector3.new(20,3,3),CFrame.new(x,1.5,159),palette.Wood,Enum.Material.Wood)
        counter:SetAttribute("Shop",shopDef.Name)
    end
    local spawn=Instance.new("SpawnLocation");spawn.Name="CommunitySpawn";spawn.Size=Vector3.new(5,0.2,5);spawn.CFrame=CFrame.new(0,0.4,-95);spawn.Transparency=1;spawn.Anchored=true;spawn.CanCollide=false;spawn.Neutral=true;spawn.Duration=0;spawn.Parent=map
    local lighting=game:GetService("Lighting");lighting.ClockTime=15.5;lighting.Brightness=2.2;lighting.Ambient=Color3.fromRGB(135,143,147);lighting.OutdoorAmbient=Color3.fromRGB(145,150,140);lighting.GlobalShadows=true
    local atmosphere=lighting:FindFirstChildOfClass("Atmosphere");if atmosphere then atmosphere.Density=0.22;atmosphere.Color=Color3.fromRGB(219,231,226);atmosphere.Decay=Color3.fromRGB(180,198,207);atmosphere.Haze=0.8 end
    local dof=lighting:FindFirstChildOfClass("DepthOfFieldEffect");if dof then dof.Enabled=false end
    world:SetAttribute("BuildVersion","foundation-1")
    return "Built 8 houses and Maple Green; "..#world:GetDescendants().." instances."
end
return Builder
