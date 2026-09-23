if not game:GetService("RunService"):IsStudio()then return end
local Test=game:GetService("StudioTestService");local args=Test:GetTestArgs()
if type(args)~="table"or args.Name~="StorageStress"then return end
local ok,result=pcall(function()
 local run=require(script.Parent.ProfileTests);local runs={};local requests=0;local cycles=0
 for index=1,20 do
  local r=run({Seed=88217+index*7919,Cycles=250});assert(r.Passed)
  requests+=r.Requests;cycles+=r.Cycles;table.insert(runs,{Seed=r.Seed,Requests=r.Requests,Cycles=r.Cycles});task.wait()
 end
 return {Passed=true,Seeds=20,Cycles=cycles,StorageRequests=requests,Runs=runs,Scope="Injected UpdateAsync storage: leases, retries, duplicate settlements, lost acknowledgements, later spending, corrupt records and schema migration. Separate live-storage suites verify actual Roblox DataStore."}
end)
Test:EndTest(ok and result or {Passed=false,Error=tostring(result)})
