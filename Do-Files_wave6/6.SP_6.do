*******************************
******* Datenmanagement *******
********** Support ************

version 13
clear all
set more off, perm
set linesize 80
capture log close


* Master Do-File
do "C:\Users\Julia\Documents\GitHub\Solidaritaet\Do-Files_wave6\1.Master.do"
*do "C:\Users\Isy\Documents\GitHub\Solidaritaet\Do-Files_wave6\1.Master.do"


use $SHARE\sharew6_rel6-1-0_ALL_datasets_stata/sharew6_rel6-1-0_sp.dta, clear

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

label var helpc1 "Person 1 - Given help to which child (no pc)"
label var helpc2 "Person 2 - Given help to which child (no pc)"
label var helpc3 "Person 3 - Given help to which child (no pc)"

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

* drop vor umstrukturieren (Var noch nicht rekodiert- noch in Rohform, Liste sollte sp�ter leer sein)
drop sp011* helpout* sp010* sp029*

* Umstrukturieren, so dass Infos beider Partner in einer Zeile (1=Mann, 2=Frau)
drop mergeid
reshape wide helpc1-helpc3  freqc1-freqc3 , i(hhid6) j(eltern)

// Missings auf 0
*recode ch* (.=0)
*recode c1* c2* c3* c4* c5* c6* c7* c8* (.=0)

// nächste Schritte für time vars: in Kinderformat jew. Kind abziehen
// Eltern addieren
// durch Zahl der Kinder teilen

saveold $out\Support.dta, replace  

Kspell = helpc dann 0
dann nach eltern variablen 

