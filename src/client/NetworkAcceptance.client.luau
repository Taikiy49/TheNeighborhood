if not game:GetService("RunService"):IsStudio()then return end
local started=false
local function begin()
 if started or workspace:GetAttribute("AdversarialNetworkTest")~=true then return end;started=true
 local root=game.ReplicatedStorage:WaitForChild("Neighborhood");local probe=root:WaitForChild("NetworkProbe",10);if not probe then return end
 local player=game.Players.LocalPlayer;local request=root.Remotes.Request
 probe.OnClientEvent:Connect(function(phase,ownedId)
  if phase=="fuzz"then
   local cases={};local values={false,{},0/0,math.huge,-math.huge,0.5,"invalid",string.rep("x",1000),9e18,-9e18}
   for _,value in ipairs(values)do
    table.insert(cases,table.pack("Buy",value,nil))
    for _,action in ipairs({"Buy","Craft","Place","Pack","SaveLayout","LoadLayout"})do table.insert(cases,table.pack("Building",action,value))end
    table.insert(cases,table.pack("Boutique","Equip",value))
    table.insert(cases,table.pack("Friends","ChoosePlot",value))
    table.insert(cases,table.pack("Event","HighFive",value))
    table.insert(cases,table.pack("Accuse","missing-case",value))
    if type(value)~="boolean"then table.insert(cases,table.pack("Setting","Sound",value))end
   end
   for _,value in ipairs({{},0/0,math.huge,-1,0,7,"1"})do table.insert(cases,table.pack("Place",ownedId,value))end
   for _,id in ipairs({"1e309","-1e309","nan","missing"})do table.insert(cases,table.pack("Permission",id,"Roommate"))end
   table.insert(cases,table.pack({},"",nil));table.insert(cases,table.pack(string.rep("x",1000),"",nil))
   table.insert(cases,table.pack("Customize","Color",{}));table.insert(cases,table.pack("ClaimDiscovery","",nil))
   local sent=0
   for _,entry in ipairs(cases)do request:FireServer(entry[1],entry[2],entry[3],1000000+sent);sent+=1;task.wait(0.34)end
   for index=1,100 do request:FireServer("Buy","NotARealItem",nil,1100000+index);sent+=1 end
   for _,value in ipairs(values)do root.Remotes.Drive:FireServer(value,value);sent+=1 end
   task.wait(1);probe:FireServer("fuzz",{Sent=sent})
  elseif phase=="building"then
   request:FireServer("Building","Buy","GardenRoom",1200001);task.wait(.4)
   for i=1,100 do request:FireServer("Building","Buy","GardenRoom",1200001+i)end
   task.wait(1);probe:FireServer("building",{Sent=101})
  else
   task.wait(2)
   local rain=workspace.CurrentCamera:FindFirstChild("LocalRain");local visible=0;local total=0
   if rain then for _,part in ipairs(rain:GetChildren())do if part:IsA("BasePart")then total+=1;if part.Transparency<1 then visible+=1 end end end end
   local errors={};for _,entry in ipairs(game:GetService("LogService"):GetLogHistory())do if entry.messageType==Enum.MessageType.MessageError then table.insert(errors,entry.message)end end
   local apps=0;for _,gui in ipairs(player.PlayerGui:GetChildren())do if gui.Name=="NeighborhoodApp"then apps+=1 end end
   probe:FireServer(phase,{RainParts=total,Visible=visible,Errors=errors,Weather=workspace.Neighborhood:GetAttribute("Weather"),ReducedMotion=player:GetAttribute("ReducedMotion"),AppCount=apps})
  end
 end)
 probe:FireServer("ready",{})
end
workspace:GetAttributeChangedSignal("AdversarialNetworkTest"):Connect(begin);begin()
