local Http=game:GetService("HttpService")
local Config=require(game.ReplicatedStorage.Neighborhood.Shared.Config)
local Defs=require(game.ReplicatedStorage.Neighborhood.Shared.ItemDefinitions)
local Service={}
function Service:Init(context)self.Context=context end
function Service:Transition(incident,status,description)
 if incident.Status==status then return end
 incident.Status=status;incident.Timeline=incident.Timeline or {}
 table.insert(incident.Timeline,{Time=os.time(),Status=status,Description=description})
end
function Service:Observe(player,house,item)
 local evidence={{Kind="Alarm log",Time=os.time(),Description="Display sensor triggered inside the house.",Quality="Clear"}}
 local camera=house.Model:FindFirstChild("SecurityCamera")
 local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
 if camera and root then
  local direction=root.Position-camera.Position
  local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude;params.FilterDescendantsInstances={camera,player.Character,self.Context.Items.Models[item.Id]}
  local hit=workspace:Raycast(camera.Position,direction,params)
  if direction.Magnitude<35 and direction.Unit:Dot(camera.CFrame.LookVector)>0.25 and not hit then
   local torso=player.Character:FindFirstChild("UpperTorso") or player.Character:FindFirstChild("Torso")
   table.insert(evidence,{Kind="Camera observation",Time=os.time(),Description="Clothing: "..(torso and torso.BrickColor.Name or "unclear")..". Carrying: "..(Defs[item.DefinitionId].Weight>30 and "large gold object" or "household object")..".",Quality="Partial view"})
  end
 end
 return evidence
end
function Service:Incident(session,status)
 local profile=self.Context.Data.Profiles[session.Item.OwnerUserId]
 if not profile then return end
 local incident={Id=Http:GenerateGUID(false),Time=os.time(),HouseId=session.House.Model.Name,ItemName=Defs[session.Item.DefinitionId].Name,ItemId=session.Item.Id,Evidence=session.Evidence,Status=status}
 incident.Timeline={{Time=incident.Time,Status=status,Description=status=="Recovered" and "The possession was returned before a sale." or "The possession left the property."}}
 table.insert(profile.Incidents,1,incident)
 while #profile.Incidents>Config.MaxIncidents do table.remove(profile.Incidents) end
 session.Incident=incident
 local owner=game.Players:GetPlayerByUserId(session.Item.OwnerUserId)
 if owner then self.Context.Notify(owner,status=="Recovered" and "Your property is back home." or "Break-in recorded. Open Cases to see what happened.",status=="Recovered");self.Context.Sync(owner) end
end
return Service
