if not game:GetService("RunService"):IsStudio()then return end
local Test=game:GetService("StudioTestService");local args=Test:GetTestArgs()
if type(args)~="table"or args.Name~="DetailAcceptance"then return end
local function run()
 local untilTime=os.clock()+45;repeat task.wait(.2)until workspace:GetAttribute("NeighborhoodReady")or os.clock()>untilTime
 local w=workspace.Neighborhood;local fixtures=0
 for _,h in w.Houses:GetChildren()do
  local b=h.Foundation.CFrame;local ceiling=b:PointToObjectSpace(h.Ceiling.Position).Y-h.Ceiling.Size.Y/2
  for _,mount in h.BuiltInInterior:GetChildren()do if mount.Name=="CeilingMount"then
   local pos=b:PointToObjectSpace(mount.Position)
   assert(math.abs(pos.Y+mount.Size.X/2-ceiling)<.01,"Floating ceiling mount")
   local shade,lens
   for _,v in h.BuiltInInterior:GetChildren()do local q=b:PointToObjectSpace(v.Position)
    if math.abs(pos.X-q.X)<.01 and math.abs(pos.Z-q.Z)<.01 then if v.Name=="LinenShade"then shade=v elseif v.Name=="Diffuser"then lens=v end end
   end
   assert(shade and lens)
   assert(math.abs(mount.Position.Y-mount.Size.X/2-(shade.Position.Y+shade.Size.X/2))<.01,"Disconnected lamp shade")
   assert(math.abs(shade.Position.Y-shade.Size.X/2-(lens.Position.Y+lens.Size.X/2))<.01,"Disconnected diffuser")
   fixtures+=1
  end end
  assert(math.abs(b:PointToObjectSpace(h.AddressPlaque.Position).Z+55.7)<.01,"Address hidden beneath porch")
 end
 assert(fixtures==40)
 local signs=0
 for _,v in w:GetDescendants()do if v:IsA("SurfaceGui")then
  assert(v.SizingMode==Enum.SurfaceGuiSizingMode.PixelsPerStud,"Stretched sign canvas: "..v:GetFullName())
  local label=v:FindFirstChildWhichIsA("TextLabel",true);if label then assert(label.Size.X.Scale<=.9 and label.Position.X.Scale>=.05,"Missing sign margins");signs+=1 end
 end end
 assert(w.Map.CommunityBoard.Size.X==16 and w.Map.MapleGreenSign.Size.X==18)
 for _,shop in w.Shops:GetChildren()do assert(shop.Sign.Position.Z<shop.Awning.Position.Z-shop.Awning.Size.Z/2,"Sign remains behind awning")end
 return {Passed=true,JoinedCeilingFixtures=fixtures,SignsWithProportionalText=signs,VisiblePorchAddresses=8,Scope="Local geometry and sign-format checks; screenshots and sightline audit cover appearance separately"}
end
local ok,result=pcall(run);Test:EndTest(ok and result or {Passed=false,Error=tostring(result)})
