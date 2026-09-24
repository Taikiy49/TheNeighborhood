local Policy={}
function Policy.IsInterior(light)
 if light:GetAttribute("LightingRole")=="Interior"then return true end
 local parent=light.Parent
 while parent do
  if parent.Name=="BuiltInInterior"or parent.Name=="HomeExpansion"then return true end
  parent=parent.Parent
 end
 return false
end
function Policy.Enabled(light,hours,outage)
 return not outage and (Policy.IsInterior(light)or hours>18 or hours<6)
end
return Policy
