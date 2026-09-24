local D={}
D.Tiers={
 {Name='Maple cottage',Floors=1,Price=0,Work=0,Description='Your first home, garage and garden.'},
 {Name='Parkside townhouse',Floors=2,Price=2500,Work=8,Description='A furnished upstairs family lounge and study, with a home lift.'},
 {Name='Family residence',Floors=3,Price=6500,Work=25,Description='An additional bedroom floor for your growing home.'},
 {Name='Skyline residence',Floors=5,Price=16000,Work=60,Description='Five storeys: family rooms, a social lounge and a rooftop-view garden.'},
}
D.Styles={'Sage','Terracotta','Blue'}
function D.Default()return {Tier=1,Renovations=0,ProjectWork=0,Style='Sage'}end
function D.Valid(r)
 local function integer(v,a,b)return type(v)=='number'and v==v and v%1==0 and v>=a and v<=b end
 return type(r)=='table'and integer(r.Tier,1,#D.Tiers)and integer(r.Renovations,0,1000000)and integer(r.ProjectWork,0,1000000000)and table.find(D.Styles,r.Style)~=nil
end
function D.Project(r)return {Price=math.min(10000,1500+r.Renovations*250),Work=8+r.Renovations%5*2}end
return D
