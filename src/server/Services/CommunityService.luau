local Service={Feed={},Counts={},Last={}}
local headlines={GoldenEscape={"ROYAL RELOCATION","An unusually shiny bathroom fixture made a very slow getaway."},Solved={"CASE CLOSED","A homeowner followed the evidence and solved a neighborhood case."},Recovery={"BACK WHERE IT BELONGS","A missing possession has been reunited with its homeowner."},Customize={"FRESH COAT, FRESH START","A neighbor gave their home a new look."},Delivery={"THE POST GETS THROUGH","Another parcel reached the right mailbox."},Breach={"LOCK TROUBLE ON MAPLE STREET","A front door was forced open. Neighbors are checking their locks."}}
function Service:Record(event)
 self.Counts[event]=(self.Counts[event] or 0)+1
 local template=headlines[event];if not template or os.clock()-(self.Last[event] or -60)<30 then return end
 self.Last[event]=os.clock();table.insert(self.Feed,1,{Title=template[1],Text=template[2],Time=os.time()})
 while #self.Feed>24 do table.remove(self.Feed)end
end
return Service
