local Config=require(game.ReplicatedStorage.Neighborhood.Shared.Config)
local Lighting=game:GetService("Lighting")
local Service={Current="Clear"}
local definitions={
 Clear={Title="Sunny on Maple Street",Description="A good day for wandering into other people's business.",Density=0.22,Exposure=0,Seconds=Config.WeatherClearSeconds},
 Rain={Title="Passing showers",Description="Bring the parcel in out of the rain. Roofs shelter you; possessions keep their value.",Density=0.32,Exposure=-0.3,Seconds=Config.WeatherRainSeconds},
 Overcast={Title="A little overcast",Description="Clouds are gathering. The gnomes deny involvement.",Density=0.27,Exposure=-0.15,Seconds=90},
}
function Service:View()
 local d=definitions[self.Current];return {Kind=self.Current,Title=d.Title,Description=d.Description,EndsAt=self.EndsAt}
end
function Service:Set(kind)
 local definition=definitions[kind];if not definition then return false end
 self.Current=kind;self.EndsAt=os.time()+definition.Seconds
 workspace.Neighborhood:SetAttribute("Weather",kind);workspace.Neighborhood:SetAttribute("WeatherEndsAt",self.EndsAt)
 local tween=game:GetService("TweenService")
 if self.LightTween then self.LightTween:Cancel()end
 self.LightTween=tween:Create(Lighting,TweenInfo.new(3),{ExposureCompensation=definition.Exposure});self.LightTween:Play()
 local atmosphere=Lighting:FindFirstChildOfClass("Atmosphere")
 if atmosphere then if self.AirTween then self.AirTween:Cancel()end;self.AirTween=tween:Create(atmosphere,TweenInfo.new(3),{Density=definition.Density});self.AirTween:Play()end
 if self.Context then for _,player in ipairs(game.Players:GetPlayers())do self.Context.Sync(player)end end
 return true
end
function Service:Init(context)
 self.Context=context;self:Set("Clear")
 if game:GetService("RunService"):IsStudio()then local args=game:GetService("StudioTestService"):GetTestArgs();if type(args)=="table" and args.Name then return end end
 task.spawn(function()
  local sequence={"Clear","Overcast","Rain","Clear"};local index=1
  while true do task.wait(definitions[self.Current].Seconds);index=index%#sequence+1;self:Set(sequence[index])end
 end)
end
return Service
