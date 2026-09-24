local Space=require(game.ReplicatedStorage.Neighborhood.Shared.WorldSpace)
local Config=require(game.ReplicatedStorage.Neighborhood.Shared.Config)
local Factory=require(script.Parent.Parent.ItemFactory)
local Service={Markers={}}
local clues={
 {Id="Gnome1",Title="The park regular",Hint="Look near the middle of Maple Green, where neighbors take a breather.",Position=Vector3.new(18,0.2,-16)},
 {Id="Gnome2",Title="Questionable company",Hint="Someone is lingering behind the Totally Legal Pawn Shop.",Position=Vector3.new(40,0.2,175)},
 {Id="Gnome3",Title="After-hours shopper",Hint="Check the quiet edge beside Maple & Co.",Position=Vector3.new(-42,0.2,169)},
 {Id="Gnome4",Title="Garden enthusiast",Hint="The backyard at 101 Maple Street has a very small visitor.",House="House01"},
 {Id="Gnome5",Title="First on the street",Hint="At the north end of the green, look beyond the community board.",Position=Vector3.new(0,0.2,-120)},
}
function Service:Init(context)
 self.Context=context
 local folder=Instance.new("Folder");folder.Name="GnomeTrail";folder.Parent=workspace.Neighborhood.Runtime
 for _,clue in ipairs(clues)do
  local model=Factory.Create("GardenGnome");model.Name=clue.Id;model:ScaleTo(0.65)
  local position=clue.Position and Space.Point(clue.Position)or workspace.Neighborhood.Houses[clue.House].Foundation.CFrame:PointToWorldSpace(Space.Point(Vector3.new(-18,0.2,31)))
  model:PivotTo(CFrame.new(position));model.Parent=folder
  local sign=Instance.new("Part");sign.Name="TrailTag";sign.Size=Vector3.new(1.2,0.8,0.2);sign.CFrame=CFrame.new(position+Vector3.new(0,1,-1.5));sign.Color=Color3.fromRGB(210,187,113);sign.Anchored=true;sign.CanCollide=false;sign:SetAttribute("Action","Discover");sign:SetAttribute("DiscoveryId",clue.Id);sign.Parent=model
  local prompt=Instance.new("ProximityPrompt");prompt.Style=Enum.ProximityPromptStyle.Custom;prompt.ActionText="Read tiny note";prompt.ObjectText="A suspiciously well-travelled gnome";prompt.MaxActivationDistance=8;prompt:SetAttribute("Action","Discover");prompt.Parent=sign
  self.Markers[clue.Id]=sign
 end
 context.Interactions:Register("Discover",function(player,target)return self:Find(player,target)end)
end
function Service:Find(player,target)
 if typeof(target)~="Instance"then return false,"Find a gnome's trail tag."end
 local id=target:GetAttribute("DiscoveryId")
 if not id or self.Markers[id]~=target then return false,"That is not a trail marker."end
 local valid,why=self.Context.Interactions:Validate(player,target);if not valid then return false,why end
 local profile=self.Context.Data:Get(player);if not profile then return false,"Profile unavailable."end
 if profile.Discoveries[id]then return false,"You've already read this note. Your journal remembers."end
 profile.Discoveries[id]=true;self.Context.Record(player,"Discovery")
 local count=0;for _ in pairs(profile.Discoveries)do count+=1 end
 if count==Config.DiscoveryCount then
  local claimed,message=self:Claim(player)
  return true,claimed and message or "Five notes found! Free an inventory slot, then claim your gnome in the journal."
 end
 return true,"A tiny note, signed 'Definitely Not A Gnome'. "..count.." / "..Config.DiscoveryCount.." found."
end
function Service:Claim(player)
 local profile=self.Context.Data:Get(player);if not profile then return false,"Profile unavailable."end
 if profile.DiscoveryRewardClaimed then return false,"Your Moonlight Gnome has already been claimed."end
 for _,clue in ipairs(clues)do if not profile.Discoveries[clue.Id]then return false,"Follow all five clues first."end end
 if #profile.Inventory>=Config.MaxInventory then return false,"Free one inventory slot before claiming your gnome."end
 local item=self.Context.Items:Create(player,"MoonGnome");if not item then return false,"Your reward could not be created. Try again."end
 profile.DiscoveryRewardClaimed=true;self.Context.Record(player,"TrailComplete")
 return true,"The Moonlight Gnome is yours. Its alibi is surprisingly detailed."
end
function Service:View(player)
 local profile=self.Context and self.Context.Data:Get(player);local entries={}
 for _,clue in ipairs(clues)do table.insert(entries,{Title=clue.Title,Hint=clue.Hint,Found=profile and profile.Discoveries[clue.Id]==true or false})end
 return {Entries=entries,Claimed=profile and profile.DiscoveryRewardClaimed or false}
end
return Service
