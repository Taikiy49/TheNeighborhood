-- Quiet, local-only music; the preference is saved separately from feedback sounds.
local M={}
function M.Init()
 local player=game.Players.LocalPlayer
 local audio=game:GetService("SoundService")
 local old=audio:FindFirstChild("NeighborhoodMusic");if old then old:Destroy()end
 local sound=Instance.new("Sound");sound.Name="NeighborhoodMusic";sound.SoundId="rbxassetid://133008423061710";sound.Looped=true;sound.Volume=0;sound.Parent=audio
 local tween
 local function update()
  if tween then tween:Cancel()end
  if not sound.IsPlaying then sound:Play()end
  tween=game:GetService("TweenService"):Create(sound,TweenInfo.new(2),{Volume=player:GetAttribute("MusicEnabled")==false and 0 or .12});tween:Play()
 end
 player:GetAttributeChangedSignal("MusicEnabled"):Connect(update);update()
end
return M
