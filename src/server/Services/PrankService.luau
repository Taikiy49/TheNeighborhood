local Players=game:GetService("Players")
local Factory=require(script.Parent.Parent.ItemFactory)
local Service={Active={},Cooldowns={}}
function Service:Init(context)
 self.Context=context
 context.Interactions:Register("CleanPrank",function(player,target)
  local id=target:GetAttribute("PrankHouse");local house=context.Houses.ById[id]
  if not house or house.Owner~=player.UserId then return false,"Only the homeowner may tidy this yard."end
  self:Clear(id);return true,"Yard tidied. No possessions were harmed."
 end)
 Players.PlayerRemoving:Connect(function(p)local house=context.Houses.ByPlayer[p.UserId];if house then self:Clear(house.Model.Name)end end)
end
function Service:Clear(id)
 local active=self.Active[id];if active then active:Destroy();self.Active[id]=nil end
end
function Service:Place(player,id)
 local house=self.Context.Houses.ById[id]
 if not house or not house.Owner or house.Owner==player.UserId then return false,"Choose a neighbor's yard."end
 local victim=self.Context.Data.Profiles[house.Owner]
 if not victim or victim.Settings.Pranks==false then return false,"This neighbor has opted out of pranks."end
 if (house.Model:GetAttribute("ProtectedUntil") or 0)>os.time() or (self.Cooldowns[house.Owner] or 0)>os.time()then return false,"Give this neighbor some peace and quiet first."end
 local valid,why=self.Context.Interactions:Validate(player,house.Door);if not valid then return false,why end
 local profile=self.Context.Data:Get(player);if profile.Currency<50 then return false,"A flock of lawn flamingos costs $50."end
 profile.Currency-=50;self.Cooldowns[house.Owner]=os.time()+300;self:Clear(id)
 local flock=Instance.new("Model");flock.Name="HarmlessFlamingoPrank";flock.Parent=workspace.Neighborhood.Runtime;self.Active[id]=flock
 local base=house.Model.Foundation.CFrame*CFrame.new(0,-0.5,0)
 for _,x in ipairs({-10,-5,5,10})do local model=Factory.Create("LawnFlamingo");model:PivotTo(base*CFrame.new(x,0.3,-21));model.Parent=flock end
 local tidy=Instance.new("Part");tidy.Name="TidySign";tidy.Size=Vector3.new(3,2,0.3);tidy.CFrame=base*CFrame.new(6,2.5,-23);tidy.Color=Color3.fromRGB(35,79,70);tidy.Anchored=true;tidy.CanCollide=false;tidy:SetAttribute("Action","CleanPrank");tidy:SetAttribute("PrankHouse",id);tidy.Parent=flock
 local prompt=Instance.new("ProximityPrompt");prompt.Style=Enum.ProximityPromptStyle.Custom;prompt.ActionText="Tidy yard";prompt.ObjectText="The flamingos have unionized";prompt.MaxActivationDistance=10;prompt:SetAttribute("Action","CleanPrank");prompt.Parent=tidy
 local owner=Players:GetPlayerByUserId(house.Owner);if owner then self.Context.Notify(owner,"Your lawn has acquired a temporary flamingo committee. Tidy it or let them leave in a minute.",true)end
 self.Context.Record(player,"Prank")
 task.delay(60,function()if self.Active[id]==flock then self:Clear(id)end end)
 return true,"The flamingos are holding a meeting. They'll leave in one minute."
end
return Service
