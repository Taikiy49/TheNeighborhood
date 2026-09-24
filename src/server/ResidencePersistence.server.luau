if not game:GetService('RunService'):IsStudio()then return end
local phase=workspace:GetAttribute('ResidencePersistencePhase');if not phase then return end
assert(type(workspace:GetAttribute('PersistenceFixture'))=='string','Isolated datastore fixture required')
local ok,result=pcall(function()
 local D=require(script.Parent.Services.PlayerDataService);local H=require(script.Parent.Services.HouseService);local R=require(script.Parent.ResidenceService)
 local p;local deadline=os.clock()+45
 repeat task.wait(.2);p=game.Players:GetPlayers()[1]until p and D:Get(p)and D:Get(p)._Restored or os.clock()>deadline
 assert(p and D:Get(p)and not D.SessionOnly,'Persistent fixture did not load')
 local data=D:Get(p)
 if phase==1 then
  data.Residence={Tier=4,Renovations=2,ProjectWork=13,Style='Blue'};data.Statistics.CityWork=15;R:Restore(p)
  assert(D:Save(p,false),'Real datastore save failed')
 else
  assert(data.Residence.Tier==4 and data.Residence.Renovations==2 and data.Residence.ProjectWork==13 and data.Residence.Style=='Blue','Residence state did not survive server restart')
  local h=H.ByPlayer[p.UserId];assert(h.Model.ResidenceFloors:FindFirstChild('ResidenceRoof')and h.Model:GetAttribute('ResidenceTier')==4,'Saved residence not rebuilt')
 end
 return {Passed=true,Phase=phase,Tier=data.Residence.Tier,Renovations=data.Residence.Renovations,Style=data.Residence.Style}
end)
workspace:SetAttribute('ResidencePersistenceResult',game.HttpService:JSONEncode(ok and result or {Passed=false,Error=tostring(result)}))
