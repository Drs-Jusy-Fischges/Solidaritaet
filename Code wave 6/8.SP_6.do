*******************************
******* Datenmanagement *******
********** Support ************

version 13
clear all
set more off, perm
set linesize 80
capture log close


* Master Do-File
do "C:\Users\Julia\Documents\Studium\M.A.Soziologie\5.Semester\Masterarbeit\Methods-Publikation\Do-Files\Master.do"


use $SHARE\sharew6_rel6-0-0_ALL_datasets_stata/sharew6_rel6-0-0_ch.dta, clear

keep mergeid hhid6 ch001_ ch007_1-ch007_8 ch524_-ch525d20

recode ch007_* (1 2 = 1) (-1 3/8 = 0) (-2 = .)
label def ch007_1 0 "Not in HH" 1 "In HH", replace
label def ch007_2 0 "Not in HH" 1 "In HH", replace
label def ch007_3 0 "Not in HH" 1 "In HH", replace
label def ch007_4 0 "Not in HH" 1 "In HH", replace
label def ch007_5 0 "Not in HH" 1 "In HH", replace
label def ch007_6 0 "Not in HH" 1 "In HH", replace
label def ch007_7 0 "Not in HH" 1 "In HH", replace
label def ch007_8 0 "Not in HH" 1 "In HH", replace
label value ch007_1 ch007_1
label value ch007_2 ch007_2
label value ch007_3 ch007_3
label value ch007_4 ch007_4
label value ch007_5 ch007_5
label value ch007_6 ch007_6
label value ch007_7 ch007_7
label value ch007_8 ch007_8

egen childhh = rowtotal(ch007_1 ch007_2 ch007_3 ch007_3 ch007_4 ch007_5 ch007_6 ch007_7 ch007_8)
label var childhh "Number of children in HH"

use $SHARE\sharew6_rel6-0-0_ALL_datasets_stata/sharew6_rel6-0-0_sp.dta, clear

keep mergeid hhid6 sp009_1 sp009_2 sp009_3 sp011_1 sp011_2 sp011_3 /*
*/ sp029_* sp010d1_* sp029_* sp010d*

* Missing kodieren
do $do\sharetom5.ado
numlabel _all, add

* Whom given help 1-3
gen helpout1= sp009_1
gen helpout2= sp009_2
gen helpout3= sp009_3

recode helpout* (-2 -1 = .) (1/9 = 0) (20/96 = 0) (10 11 = 1)

label var helpout1 "Person 1 - Given help to..."
label var helpout2 "Person 2 - Given help to..."
label var helpout3 "Person 3 - Given help to..."
label def helpout1 1 "(Step) child" 0 "Other person"
label def helpout2 1 "(Step) child" 0 "Other person"
label def helpout3 1 "(Step) child" 0 "Other person"
label val helpout1 helpout1
label val helpout2 helpout2
label val helpout3 helpout3
tab helpout2, m
drop sp009* 


********** Exclude personal care children from help variable *********
gen helpc1 = sp029_1 if sp010d1_1 != 1
gen helpc2 = sp029_2 if sp010d1_2 != 1
gen helpc3 = sp029_3 if sp010d1_3 != 1

label var helpc1 "Person 1 - Given help to child (no pc)"
label var helpc2 "Person 2 - Given help to child (no pc)"
label var helpc3 "Person 3 - Given help to child (no pc)"

recode helpc* (-1 96 = .)
drop sp010d1_*


********** Frequencies *********
gen freqc1 = sp011_1 if helpc1 != .
gen freqc2 = sp011_2 if helpc2 != .
gen freqc3 = sp011_3 if helpc3 != .

recode freqc* (-2 -1 = .)

label var freqc1 "Person 1 - Frequency of help given to child (no pc)"
label var freqc2 "Person 2 - Frequency of help given to child (no pc)"
label var freqc3 "Person 3 - Frequency of help given to child (no pc)"

label value freqc1 howoftensp
label value freqc2 howoftensp
label value freqc3 howoftensp


********** Family solidarity **********
// Children
gen helpc1=helpout1
gen helpc2=helpout2
gen helpc3=helpout3
recode helpc* (1/4=0)(-1 -2=0)(5/12=1) (.=0) // nur Kinder haben Werte, sonst 0

// vorläufige Version nur wie vielen, nicht wie oft
egen helpanteil= rowtotal(helpc1 helpc2 helpc3)


/*
// Time
recode sp011* (1=4)(2=3) (3=2) (4=1) (. -2 -1 =0) // größere Zahlen heißen jetzt öfter nicht weniger
gen chtime= helpc1*sp011_1 + helpc2*sp011_2 + helpc3*sp011_3 // Gesamthilfe
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


* Zahl der Kinder, die NICHT zu hause leben
// erstmal Infos dazu mergen
merge m:1 hhid6 using $out\HHchild.dta, gen(child_m) keepusing(hhid6 nkidshome nKind)
keep if child_m==3
drop child_m

gen nk_away= nKind - nkidshome
recode nk_away (-10/-1=.) // unlogische auf Missing 

gen nk_away3= nk_away
recode nk_away3 (3/10=3) (0=.)
*/

*****************
*****************
* Geschlecht dazu
merge 1:1 mergeid using $out\demographics_IND.dta, keepusing(mergeid eltern)
keep if _merge==3
drop _merge

* Gleichgeschlechtliche Paare raus
sort hhid6 eltern
quietly by hhid6 eltern: gen dup= cond(_N==1,0,_n)
tab dup
keep if dup==0
drop dup

* drop vor umstrukturieren (Var noch nicht rekodiert- noch in Rohform, Liste sollte später leer sein)
drop sp011* sp020* sp021* helpout* helpc* 


* Umstrukturieren, so dass Infos beider Partner in einer Zeile (1=Mann, 2=Frau)
drop mergeid
*reshape wide chtime c1time c2time c3time c4time c5time c6time c7time c8time, i(hhid6) j(eltern)
reshape wide helpanteil, i(hhid6) j(eltern)

// Missings auf 0
*recode ch* (.=0)
*recode c1* c2* c3* c4* c5* c6* c7* c8* (.=0)

// nächste Schritte für time vars: in Kinderformat jew. Kind abziehen
// Eltern addieren
// durch Zahl der Kinder teilen

saveold $out\Support.dta, replace  


