*******************************
******* Datenmanagement *******
********** Support ************

version 13
clear all
set more off, perm
set linesize 80
capture log close


* Master Do-File
do "C:\Users\Julia\Documents\Studium\M.A.Soziologie\5.Semester\Masterarbeit\Methods\Do-Files\Master.do"

use $SHARE\sharew5_rel6-0-0_ALL_datasets_stata/sharew5_rel6-0-0_sp.dta, clear

keep mergeid hhid5 sp009_1 sp009_2 sp009_3 sp011_1 sp011_2 sp011_3 /*
*/ sp020 sp021d10- sp021d17

* Missing kodieren
do $do\sharetom5.ado
numlabel _all, add

***** IC Support for parents **********
gen supneed=0
replace supneed=1 if sp020==1
drop sp020

gen supc1=0
replace supc1=1 if sp021d10==1

gen supc2=0
replace supc2=1 if sp021d11==1

gen supc3=0
replace supc3=1 if sp021d12==1

gen supc4=0
replace supc4=1 if sp021d13==1

gen supc5=0
replace supc5=1 if sp021d14==1

gen supc6=0
replace supc6=1 if sp021d15==1

gen supc7=0
replace supc7=1 if sp021d16==1

gen supc8=0
replace supc8=1 if sp021d17==1

drop sp021*


* Whom given help 1-3
gen helpout1= sp009_1
gen helpout2= sp009_2
gen helpout3= sp009_3

recode helpout* (1=1) (2/7=2) (8/9=3)(23/28=3) (20/22=4) (18/19=.)(29/33=.)(1=0) (10=5) /*
*/ (11=6) (12=7) (13=8) (14=9) (15=10) (16=11) (17=12)

label def helpout 1 "Given help to spouse" 2 "Given help to parent generation" /*
*/ 3"Given help to other family member" /*
*/4 "Given help to family of child (laws, gkids)" 5 "Child 1" 6 "Child 2" /*
*/7 "Child 3" 8 "Child 4" 9 "Child 5" 10 "Child 6" 11 "Child 7" 12 "Child 8" 
label val helpout* helpout 
tab helpout2, m
drop sp009* 


********** Family solidarity **********
// Children
gen helpc1=helpout1
gen helpc2=helpout2
gen helpc3=helpout3
recode helpc* (1/4=0)(-1 -2=0)(5/12=1) (.=0)

egen helpkid = rowtotal(helpc1 helpc2 helpc3)


/*
// Time
recode sp011* (1=4)(2=3) (3=2) (4=1) (. -2 -1 =0)
gen chtime= helpc1*sp011_1 + helpc2*sp011_2 + helpc3*sp011_3
recode chtime (.=0)
tab chtime, m

// Pro Kind
gen c1time=0
replace c1time=helpc1*sp011_1 if helpout1==5
replace c1time=helpc2*sp011_2 if helpout2==5
replace c1time=helpc2*sp011_3 if helpout3==5

gen c2time=0
replace c2time=helpc1*sp011_1 if helpout1==6
replace c2time=helpc2*sp011_2 if helpout2==6
replace c2time=helpc2*sp011_3 if helpout3==6

gen c3time=0
replace c3time=helpc1*sp011_1 if helpout1==7
replace c3time=helpc2*sp011_2 if helpout2==7
replace c3time=helpc2*sp011_3 if helpout3==7

gen c4time=0
replace c4time=helpc1*sp011_1 if helpout1==8
replace c4time=helpc2*sp011_2 if helpout2==8
replace c4time=helpc2*sp011_3 if helpout3==8

gen c5time=0
replace c5time=helpc1*sp011_1 if helpout1==9
replace c5time=helpc2*sp011_2 if helpout2==9
replace c5time=helpc2*sp011_3 if helpout3==9

gen c6time=0
replace c6time=helpc1*sp011_1 if helpout1==10
replace c6time=helpc2*sp011_2 if helpout2==10
replace c6time=helpc2*sp011_3 if helpout3==10

gen c7time=0
replace c7time=helpc1*sp011_1 if helpout1==11
replace c7time=helpc2*sp011_2 if helpout2==11
replace c7time=helpc2*sp011_3 if helpout3==11

gen c8time=0
replace c8time=helpc1*sp011_1 if helpout1==12
replace c8time=helpc2*sp011_2 if helpout2==12
replace c8time=helpc2*sp011_3 if helpout3==12

tab c1time

// Parent generation
gen helppar1= helpout1
gen helppar2= helpout2
gen helppar3= helpout3
recode helppar* (2=1) (1=0)(.=0) (3/12=0) 

// Time
gen partime= helppar1*sp011_1 + helppar2*sp011_2 + helppar3*sp011_3
tab partime, m

// Families of children
gen helpfch1= helpout1
gen helpfch2= helpout2
gen helpfch3= helpout3
recode helpfch* (1/3=0)(.=0) (5/12=0) (4=1)(-1 -2=0)

// Time
gen fchtime= helpfch1*sp011_1 + helpfch2*sp011_2 + helpfch3*sp011_3
tab fchtime, m

// Other family members
gen helpof1= helpout1
gen helpof2= helpout2
gen helpof3= helpout3
recode helpof* (1/2=0) (3=1)(.=0) (4/12=0)(-1 -2=0)

// Time
gen oftime= helpof1*sp011_1 + helpof2*sp011_2 + helpof3*sp011_3
tab oftime, m

drop help* sp011*
*/

* Zahl der Kinder, die NICHT zu hause leben
// erstmal Infos dazu mergen
merge m:1 hhid5 using $out\HHchild.dta, gen(child_m) keepusing(hhid5 nkidshome nKind)
keep if child_m==3
drop child_m

gen nk_away= nKind - nkidshome
recode nk_away (-10/-1=.) // unlogische auf Missing 

gen nk_away3= nk_away
recode nk_away3 (3/10=3) (0=.)


*****************
*****************
* Geschlecht dazu
merge 1:1 mergeid using $out\demographics_IND.dta, keepusing(mergeid eltern)
keep if _merge==3
drop _merge

* Gleichgeschlechtliche Paare raus
sort hhid5 eltern
quietly by hhid5 eltern: gen dup= cond(_N==1,0,_n)
tab dup
keep if dup==0
drop dup

* Umstrukturieren, so dass Infos beider Partner in einer Zeile (1=Mann, 2=Frau)
drop mergeid
reshape wide supneed supc* oftime fchtime partime chtime c1time c2time c3time c4time c5time c6time c7time c8time, i(hhid5) j(eltern)

// Missings auf 0
recode ch* (.=0)
recode c1* c2* c3* c4* c5* c6* c7* c8* (.=0)
recode par* fch* of* (.=0)

// nächste Schritte für time vars: in Kinderformat jew. Kind abziehen
// Eltern addieren
// durch Zahl der Kinder teilen

saveold $out\Support.dta, replace  


