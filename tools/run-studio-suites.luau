-- Run in Studio Edit mode after syncing the repository. Executes one session at a time.
-- Does not publish or enable pass sales. Live storage modules use isolated fixtures.
assert(game:GetService("RunService"):IsStudio(),"Studio only")
assert(not game:GetService("RunService"):IsRunning(),"Stop Play first")
local Test=game:GetService("StudioTestService")
local suites={
 {"DetailAcceptance",2},{"FurnishingAcceptance",2},{"ValleyAcceptance",2},{"SpaciousAcceptance",2},{"DistrictAcceptance",2},
 {"LifeAcceptance",2},{"LifeCapacity",8},{"LifeWalkAcceptance",2},{"BuildingAcceptance",2},{"BuildingCapacity",8},
 {"AdventureAcceptance",2},{"FoundationAcceptance",2},{"FriendsAcceptance",3},{"PlotChoiceAcceptance",3},
 {"ExplorationAcceptance",2},{"NetworkAcceptance",2},{"LifecycleStress",2},
 {"DisconnectRaceAcceptance",2},{"ArtAcceptance",2},{"CapacityAcceptance",8},
 {"BoutiqueRegression",2},{"UIAcceptance",2},{"StorageStress",1},
}
local results={};local failed={}
for _,suite in ipairs(suites)do
 local ok,result=pcall(function()return Test:ExecuteMultiplayerTestAsync(suite[2],{Name=suite[1]})end)
 local noResult=not ok or type(result)~="table"
 results[suite[1]]=not noResult and result or {Passed=false,Error=ok and "Studio returned no result; inspect and end the test session before retrying."or tostring(result)}
 if not ok or type(result)~="table"or result.Passed~=true then table.insert(failed,suite[1])end
 print("[QA] "..suite[1]..": "..game:GetService("HttpService"):JSONEncode(results[suite[1]]))
 if noResult then break end -- Do not stack new sessions on an abandoned server.
 task.wait(4) -- Allow test clients and the server to finish shutting down.
end
print(game:GetService("HttpService"):JSONEncode({Passed=#failed==0,Failed=failed,Results=results}))
return results
