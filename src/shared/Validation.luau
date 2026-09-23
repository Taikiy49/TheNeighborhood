local Validation={}
function Validation.UserId(value)
 return type(value)=="number" and value==value and value%1==0 and math.abs(value)<1000000000000
end
return table.freeze(Validation)
