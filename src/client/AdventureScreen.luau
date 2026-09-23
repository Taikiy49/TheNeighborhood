local Screen={}
function Screen.Render(s,view)
 local a=s.State.Adventures or {};local active=a.Active
 if view=="Projects"then
  s.Title.Text="Make Maple Green bloom"
  local project=a.Project or {}
  s:Row(project.Title or "Loading projects",project.Description or "")
  s:Row("Built together",(project.Completed or 0).." / 3 park improvements in this server. "..(project.Goal and project.Goal>0 and (project.Progress.." / "..project.Goal.." contributions toward the next one.")or "Visit the garden at the shop end of the park."))
  s:Row("Every helpful adventure counts","Finish a parcel delivery, complete a rumor trail, find a new gnome note or earn a community-event reward. Each adds one contribution. Everyone shares the result; solo players can finish every project too.")
  s:Row("Your neighborhood legacy",(a.Contributions or 0).." lifetime contributions. These and earned trophies stay saved; the shared park build belongs to this server.","Open story album",function()s:Open("Adventures")end)
 else
  s.Title.Text="Maple Adventures"
  s:Row("A street full of stories",(a.Completed or 0).." / 6 story stamps. First endings award $90 and 30 XP. Replay for personal bests and park contributions. No deadlines; pausing saves your chapter and ends the timed run.","Shared park projects",function()s:Open("Projects")end)
  if active then
   s:Row(active.Title,"Chapter "..active.Next.." / 3 · "..(active.Paused and "Paused · "or "")..active.Hint)
   if active.Note then s:Row("The story so far",active.Note)end
   s:Row("Pick up where you left off","Your next chapter survives leaving the game.",active.Paused and "Resume on foot"or "Pause story",function()s.Request("Adventure",active.Paused and "Resume"or "Pause","")end)
   s:Row("Choose another story","Abandon only the unfinished run. Completed stamps and records stay safe.","Put this story away",function()s.Request("Adventure","Abandon","")end)
  end
  for _,r in ipairs(a.Routes or {})do
   local text=r.Completed and r.Ending or "An unopened neighborhood rumor. Follow three clues on foot."
   if r.BestMs then text..=string.format(" · Best uninterrupted walk: %.1fs",r.BestMs/1000)end
   if r.Runs>0 then text..=" · "..r.Runs.." completions"end
   s:Row((r.Completed and "Stamped · "or "")..r.Title,text,not active and (r.Completed and "Revisit story"or "Follow this rumor")or nil,function()s.Request("Adventure","Start",r.Id)end)
  end
 end
 for _,r in ipairs(a.Rewards or {})do
  s:Row(r.Title,r.Claimed and "Trophy claimed. Your album remembers even if you sell it."or math.min(r.Count,r.Target).." / "..r.Target..(r.Id=="NeighborLantern"and " neighborhood contributions"or " different story endings"),not r.Claimed and r.Count>=r.Target and "Claim display trophy"or nil,function()s.Request("Adventure","Claim",r.Id)end)
 end
end
return Screen
