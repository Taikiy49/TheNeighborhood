local Players=game:GetService("Players")
local Service={Attempts={}}
function Service:Init(context)
 self.Context=context
 Players.PlayerRemoving:Connect(function(p)self.Attempts[p.UserId]=nil end)
end
function Service:Accuse(player,id,suspectId)
 if type(suspectId)~="number" or suspectId~=suspectId or suspectId%1~=0 or suspectId==player.UserId then return false,"Choose a neighbor from the case screen."end
 local profile=self.Context.Data:Get(player);if not profile then return false,"Profile unavailable."end
 local incident;for _,entry in ipairs(profile.Incidents)do if entry.Id==id then incident=entry;break end end
 if not incident or (incident.Status~="Missing" and incident.Status~="Investigating" and incident.Status~="Fenced")then return false,"This case is already resolved or unavailable."end
 local truth=profile.CaseTruth[id];if not truth then return false,"There is not enough recorded evidence to verify an accusation."end
 if os.time()-(self.Attempts[player.UserId] or 0)<60 then return false,"Review the evidence before making another accusation."end
 self.Attempts[player.UserId]=os.time()
 if truth~=suspectId then profile.Reputation=math.max(-10,profile.Reputation-1);return false,"The evidence does not support that accusation. No public accusation was posted."end
 self.Context.Evidence:Transition(incident,"Solved","The evidence confirmed the homeowner's accusation.")
 profile.Reputation=math.min(10000,profile.Reputation+2);self.Context.Record(player,"Solved")
 local suspect=Players:GetPlayerByUserId(suspectId)
 if suspect then suspect:SetAttribute("Heat",math.min(100,(suspect:GetAttribute("Heat") or 0)+20));self.Context.Notify(suspect,"A homeowner solved a case involving your theft. Your heat increased.",false)end
 local item=self.Context.Items.Items[incident.ItemId]
 if item and item.State=="Carried" or item and item.State=="Escaped"then self.Context.Robbery:Recover(player,item)end
 return true,item and item.State=="Fenced" and "Case solved. Identify your property at the pawn counter to reclaim it." or "Case solved. Your evidence held up."
end
return Service
