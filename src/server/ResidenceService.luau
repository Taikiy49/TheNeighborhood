local D=require(game.ReplicatedStorage.Neighborhood.Shared.ResidenceDefinitions)
local Factory=require(script.Parent.ResidenceFactory)
local A=require(script.Parent.CityArchitecture)
local R={Hidden={}}
function R:View(player)
 local p=self.Context.Data:Get(player);if not p then return end
 local r=p.Residence;local work=(p.Statistics.CityWork or 0)+(p.Statistics.Delivery or 0)
 return {Tier=r.Tier,Renovations=r.Renovations,Style=r.Style,Work=work,ProjectWork=math.max(0,work-r.ProjectWork)}
end
function R:Restore(player)
 local p=self.Context.Data:Get(player);local h=self.Context.Houses.ByPlayer[player.UserId];if not p or not h then return end
 local m=Factory.Create(h.Model,p.Residence)
 local hidden=self.Hidden[player.UserId]or {};self.Hidden[player.UserId]=hidden
 if p.Residence.Tier>1 then
  for _,v in ipairs(h.Model:GetDescendants())do if v:IsA('BasePart') and (v.Parent==h.Model or v.Parent.Name=='ExteriorTrim')and table.find({'Roof','Gable','Chimney','EaveTrim','CottageRidgeCap'},v.Name)then
   if not hidden[v]then hidden[v]={v.Transparency,v.CanCollide,v.CanQuery}end
   v.Transparency=1;v.CanCollide=false;v.CanQuery=false
  end end
 end
 local old=h.Model:FindFirstChild('ResidenceFloors');if old then old:Destroy()end;m.Parent=h.Model
 h.Model:SetAttribute('ResidenceTier',p.Residence.Tier)
end
function R:Release(player)
 for part,v in pairs(self.Hidden[player.UserId]or {})do if part.Parent then part.Transparency=v[1];part.CanCollide=v[2];part.CanQuery=v[3]end end
 self.Hidden[player.UserId]=nil
 local h=self.Context.Houses.ByPlayer[player.UserId];if h then local m=h.Model:FindFirstChild('ResidenceFloors');if m then m:Destroy()end;h.Model:SetAttribute('ResidenceTier',nil)end
end
function R:Action(player,action,expected)
 local c=self.Context;local p=c.Data:Get(player);local h=c.Houses.ByPlayer[player.UserId]
 if not c.Data:CanAct(player)or not p or not h then return false,'Your home is not ready.'end
 if not c.Interactions:Validate(player,self.Agent)then return false,'Visit Avery at the housing desk in the hotel lobby.'end
 if player:GetAttribute('Carrying')or player:GetAttribute('DeliveryAddress')then return false,'Finish carrying your item first.'end
 local r=p.Residence;local view=self:View(player);local old=require(script.Parent.ProfileSchema).Copy(r);local price
 if action=='Upgrade'then
  if expected~=r.Tier+1 then return false,'Your home plan has changed. Open the housing desk again.'end
  local nextTier=D.Tiers[expected];if not nextTier then return false,'Your building is fully grown. Try a renovation project.'end
  if view.Work<nextTier.Work then return false,'Finish '..(nextTier.Work-view.Work)..' more town jobs or parcel deliveries.'end
  price=nextTier.Price;if p.Currency<price then return false,'Save $'..price..' in game cash for this home.'end
  r.Tier=expected;r.ProjectWork=view.Work
 elseif action=='Renovate'then
  if r.Tier<#D.Tiers or expected~=r.Renovations then return false,'Build your skyline residence first, then review its renovation plan.'end
  local project=D.Project(r);price=project.Price
  if view.ProjectWork<project.Work then return false,'Finish '..(project.Work-view.ProjectWork)..' more jobs for this renovation.'end
  if p.Currency<price then return false,'Save $'..price..' in game cash for this renovation.'end
  if r.Renovations>=1000000 then return false,'You have completed every supported renovation.'end
  r.Renovations+=1;r.ProjectWork=view.Work;r.Style=D.Styles[r.Renovations%#D.Styles+1]
 else return false,'Choose a home plan.'end
 local ok,err=pcall(function()self:Restore(player)end)
 if not ok then p.Residence=old;self:Release(player);self:Restore(player);warn('[RESIDENCE] '..tostring(err));return false,'Construction stopped. Your cash was not spent.'end
 p.Currency-=price;c.Record(player,'Customize')
 return true,action=='Upgrade'and D.Tiers[r.Tier].Name..' is ready! Your items and garage are still yours.'or 'Renovation complete! A fresh interior palette and another project are ready.'
end
function R:Init(context)
 self.Context=context
 local hotel=workspace.Neighborhood.MapleHeights:FindFirstChild('MapleHotel',true)
 if not hotel then for _,m in ipairs(workspace.Neighborhood.MapleHeights.MarketAvenue:GetChildren())do if m.Name:find('Hotel')then hotel=m;break end end end
 assert(hotel,'Housing desk needs the hotel lobby')
 local center=hotel:GetAttribute('Entry')+Vector3.new(-9,0,-10)
 local model=Instance.new('Model');model.Name='HousingDesk';model.Parent=hotel
 local desk=A.Part(model,'Desk',{6,2.5,2.5},center+Vector3.new(0,-1,0),A.Wood)
 local torso=A.Part(model,'Avery',{2,2.5,1},center+Vector3.new(0,1,2.4),Color3.fromRGB(110,142,133),nil,false)
 local head=A.Part(model,'Head',{1.5,1.5,1.5},center+Vector3.new(0,3,2.4),Color3.fromRGB(203,157,117),nil,false);head.Shape=Enum.PartType.Ball
 for _,x in ipairs({-.55,.55})do A.Part(model,'Leg',{.8,2,.8},center+Vector3.new(x,-1,2.4),A.Ink,nil,false)end
 self.Agent=desk;A.Prompt(desk,'HousingDesk','Avery · Housing agent','Home upgrades')
 local sign=A.Part(model,'Sign',{6,1.5,.2},center+Vector3.new(0,1.8,-1.4),A.Ink,nil,false);A.Sign(sign,'HOME UPGRADES')
 model:PivotTo(CFrame.new(center)*CFrame.Angles(0,math.pi,0)*CFrame.new(-center)*model:GetPivot())
 context.Interactions:Register('HousingDesk',function(player)context.Open(player,'Residence');return true end)
 context.Interactions:Register('HomeLift',function(player,target)
  local h=context.Houses.ById[target:GetAttribute('HouseId')];local owner=h and game.Players:GetPlayerByUserId(h.Owner or 0)
  local p=owner and context.Data:Get(owner);local level=target:GetAttribute('Floor')
  if not p or not target:IsDescendantOf(h.Model:FindFirstChild('ResidenceFloors'))or type(level)~='number'or level<1 or level>D.Tiers[p.Residence.Tier].Floors then return false,'This lift is unavailable.'end
  if h.Owner~=player.UserId and h.Locked and not(h.Permissions and h.Permissions[tostring(player.UserId)])then return false,'This home is locked.'end
  local human=player.Character and player.Character:FindFirstChildOfClass('Humanoid')
  if not human or human.Health<=0 or human.Sit or player:GetAttribute('Carrying')or player:GetAttribute('DeliveryAddress')then return false,'Stand up and set down your item before using the lift.'end
  local y=level==1 and 4 or 12.4*(level-1)+4
  player.Character:PivotTo(h.Model.Foundation.CFrame*CFrame.new(0,y,-11));return true,'Floor '..level
 end)
end
return R
