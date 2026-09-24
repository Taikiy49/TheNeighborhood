local D={}
D.Flowers={Daisy={Price=10,Seconds=120,Color=Color3.fromRGB(255,244,190)},Lavender={Price=15,Seconds=180,Color=Color3.fromRGB(167,139,205)},Sunflower={Price=20,Seconds=240,Color=Color3.fromRGB(239,180,49)}}
D.Beds={{17.5,17},{22.5,17},{17.5,23},{22.5,23}}
D.FlowerOrder={"Daisy","Lavender","Sunflower"}
D.Goods={Bouquet={Daisy=2,Lavender=1},Planter={Sunflower=2,Daisy=1}}
D.Businesses={Nursery={Room="GardenRoom",Name="Petal & Pot",Steps={"Wrap","Ribbon","Deliver"}},Furniture={Room="Workshop",Name="Little Woodworks",Steps={"Cut","Sand","Finish"}},Repair={Room="Garage",Name="Fix-it Corner",Steps={"Diagnose","Tighten","Test"}}}
D.Customers={"Mrs. Willow","Leo the librarian","Nora the baker"}
D.Projects={Cafe={Name="Corner Cafe",Goal=12,Position=Vector3.new(-22,1,-153),Task="Restore the counter"},Clubhouse={Name="Maple Clubhouse",Goal=18,Position=Vector3.new(22,1,-153),Task="Fit the shelves"},Greenhouse={Name="Community Greenhouse",Goal=15,Position=Vector3.new(0,1,153),Task="Tend the seedlings"}}
D.ProjectOrder={"Cafe","Clubhouse","Greenhouse"}
D.Blueprints={WindChime={XP=30,Price=30},Birdhouse={XP=100,Price=50},TeaTable={XP=250,Price=80},Lantern={XP=500,Price=100}}
D.BlueprintOrder={"WindChime","Birdhouse","TeaTable","Lantern"}
D.Styles={Meadow={XP=0,Color=Color3.fromRGB(100,151,112)},Coastal={XP=150,Color=Color3.fromRGB(105,155,176)},Autumn={XP=350,Color=Color3.fromRGB(191,121,69)}}
D.Themes={"CozyCorners","GardenRetreat","CreativeWorkshop"}
D.Seasons={"Spring","Summer","Autumn","Winter"}
D.SeasonColors={Spring=Color3.fromRGB(211,154,182),Summer=Color3.fromRGB(236,193,77),Autumn=Color3.fromRGB(190,106,53),Winter=Color3.fromRGB(136,187,211)}
D.Decor={Flag=3,Wreath=5,Lantern=8}
D.Stops={Vector3.new(-12,2,-90),Vector3.new(-12,2,-20),Vector3.new(12,2,20),Vector3.new(12,2,92)}
D.Cases={
 LostLantern={Name="The wandering lantern",People={"Nora","Leo","Willow"},Notes={"Flour dust glitters on the handle.","A library return slip is tucked under the base.","A lavender ribbon is tied around the hook."},Endings={"Return it to the owner","Light the community window"}},
 SecretRecipe={Name="The secret picnic recipe",People={"Nora","Leo","Willow"},Notes={"The margin mentions the bakery's early shift.","Every ingredient is arranged alphabetically.","The paper smells of fresh-cut lavender."},Endings={"Keep a family recipe","Share it at the cafe"}},
 PaintedBench={Name="Who painted the bench?",People={"Nora","Leo","Willow"},Notes={"A flour-covered apron has the same paint splash.","A bookmark is caught beneath the bench.","Lavender petals are pressed into the wet paint."},Endings={"Thank the artist privately","Host a little unveiling"}},
}
D.CaseOrder={"LostLantern","SecretRecipe","PaintedBench"}
function D.Season(now)local month=os.date("!*t",now).month;return D.Seasons[month>=3 and month<=5 and 1 or month>=6 and month<=8 and 2 or month>=9 and month<=11 and 3 or 4]end
return D
