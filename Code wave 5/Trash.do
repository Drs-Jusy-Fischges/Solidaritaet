* SSW
gen xagesec=.
replace xagesec=(SSW_gw1 + (SSW_gw2*0.7))/2 if partner==1
replace xagesec= SSW_gw1 if SSW_gw2==. & partner==0
replace xagesec= SSW_gw2 if SSW_gw1==. & partner==0
replace xagesec= log(xagesec)
label var xagesec "Cum. age security parents"
drop SSW_gw1 SSW_gw2


* 2. Nur Kinder. Modell
// Alter2
gen Kaltert= Kalter^2

// Dummy arbeitslos
gen outwork=Kop
recode outwork (1/3=0) (5/7=0)

logit Kcohab Ksex Kalter Kaltert i.Kycle i.Keduc i.Kop, vce(cluster hhid5)

logit Kcohab Ksex Kalter Kaltert i.Kycle i.Keduc outwork, vce(cluster hhid5)



****
*Set 1: Micro
****

* 1. Nur Eltern. Modelle, Beginnen mit Haushaltsinfos: Value, partner, who else lives home
melogit Kcohab partner i.Countbaby Omps i.otherya i.valueprct Countold i.Famhome || hhid5:, or
estimates store m1

estat
fitstat

// 2. Nur Eltern: Individual characteristics: Age, Health, Educ, Migration, Income, other Kids
melogit Kcohab partner i.Countbaby Omps i.otherya i.valueprct /*
*/ i.incprct i.futkat octime partime i.xisced i.xhealth xalter migration kidsout Countold i.Famhome || hhid5:, or
estimates store m2


// Modell besser geworden?
lrtest m1 m2, stats


* 3. Alle. Modell
melogit Kcohab partner i.Countbaby Omps i.otherya i.valueprct /*
*/ i.incprct i.futkat octime partime i.xisced i.xhealth xalter migration /*
*/Ksex Kalter i.Kycle i.Keduc i.Kop kidsout Countold i.Famhome || hhid5:, or

