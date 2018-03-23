

*******************************
******* Datenmanagement *******
********** Boomerangs ********

version 13
clear all
set more off, perm
set linesize 80
capture log close


* Master Do-File
do "C:\Users\Julia\Documents\Studium\M.A.Soziologie\5.Semester\Masterarbeit\Methods\Do-Files\Master.do"

* LOG-Datei
capture log close
log using $log\Children45.log, replace



*********
* Welle 4
*********

use $SHARE\sharew4_rel6-0-0_ALL_datasets_stata/sharew4_rel6-0-0_ch.dta, clear
sort mergeid
keep mergeid hhid4 ch001_ ch007_1-ch007_8 ch006_1-ch006_8

* Missing kodieren
do $do\sharetom5.ado
numlabel _all, add

*** Family respondent, Land & Interviewjahr dranmatchen 
merge 1:1 mergeid using $SHARE\sharew4_rel6-0-0_ALL_datasets_stata/sharew4_rel6-0-0_cv_r.dta, /*
*/ keepusing(mergeid fam_resp country int_year) gen(m_gen)
drop m_gen

* nur fam resp. behalten (andere haben keine Infos)
tab fam_resp, m
keep if fam_resp==1
drop fam_resp


* jeder Haushalt darf nur einmal vorkommen, doppelte raus
sort hhid4
quietly by hhid4: gen dup = cond(_N==1,0,_n)
tab dup
drop if dup>1

** kennzeichnen als Welle 4: alle heißen v_
foreach x of varlist _all {
	rename `x' v_`x'
}

* jetzt hhid umbenennen zu hhid (dann mit Hhid5 mergen) 
gen hhid= v_hhid4

* speichern
saveold $out\child4.dta, replace  


*********
* Welle 5
*********

use $SHARE\sharew5_rel6-0-0_ALL_datasets_stata/sharew5_rel6-0-0_ch.dta, clear
sort mergeid
keep mergeid hhid5 ch001_ ch006_1-ch006_8 ch007_1-ch007_8 ch015_1 - ch015_8

* Missing kodieren
do $do\sharetom5.ado
numlabel _all, add

*** Family respondent, Land & Interviewjahr dranmatchen 
merge 1:1 mergeid using $SHARE\sharew5_rel6-0-0_ALL_datasets_stata/sharew5_rel6-0-0_cv_r.dta, /*
*/ keepusing(mergeid fam_resp country int_year) gen(m_gen)
drop m_gen

* nur fam resp. behalten (andere haben keine Infos)
tab fam_resp, m
keep if fam_resp==1

* jeder Haushalt darf nur einmal vorkommen, doppelte raus
sort hhid5
quietly by hhid5: gen dup = cond(_N==1,0,_n)
tab dup
drop if dup>1

** kennzeichnen als Welle 5: alle heißen f_
foreach x of varlist _all {
	rename `x' f_`x'
}

* jetzt hhid neu zu hhid (dann mit Hhid5 mergen) 
generate hhid=f_hhid5

* speichern
saveold $out\child5.dta, replace  


*** Infos aus Welle 4 dranmatchen
merge 1:1 hhid using $out\child4.dta 

* nur behalten, wenn Infos aus beiden Wellen da
keep if _merge==3
drop _merge

* nur behalten, wenn Haushalt Kinder hat
recode v_ch001_ (-2/0=0)
recode f_ch001_ (-2/0=0)

keep if v_ch001>0
keep if f_ch001_>0
drop if v_ch001==.
drop if f_ch001==.

* alle mit mehr als 8 Kindern raus
keep if v_ch001_<9
keep if f_ch001_<9

gen boom=0
replace boom=1 if v_ch007_1>2 & v_ch007_1<10 & (f_ch007_1==1 | f_ch007_1==2)



*** Kinderzahl 
generate Kzahl=v_ch001_

*** Anzahl Datenzeilen pro HH entsprechend Anzahl Kindern in HH
* jetzt hat jeder Haushalt so viele Datenblöcke wie Kinder
tab Kzahl, m
expand Kzahl

* Spell für Kinder
bysort v_mergeid: gen Kspell= _n

********************************
* Jedes Kind bekommt seinen Wert
********************************

*Geburtsjahr Welle 4
gen Kgebj4=0
replace Kgebj4=v_ch006_1 if Kspell==1
replace Kgebj4=v_ch006_2 if Kspell==2
replace Kgebj4=v_ch006_3 if Kspell==3
replace Kgebj4=v_ch006_4 if Kspell==4
replace Kgebj4=v_ch006_5 if Kspell==5
replace Kgebj4=v_ch006_6 if Kspell==6
replace Kgebj4=v_ch006_7 if Kspell==7
replace Kgebj4=v_ch006_8 if Kspell==8

recode Kgebj4 (-2/-1=.)
label var Kgebj4 "Geburtsjahr Kind Welle 4"
label value Kgebj4 Kgebj4
tab Kgebj4, m
drop v_ch006*

*Geburtsjahr Welle 5
gen Kgebj5=0
replace Kgebj5=f_ch006_1 if Kspell==1
replace Kgebj5=f_ch006_2 if Kspell==2
replace Kgebj5=f_ch006_3 if Kspell==3
replace Kgebj5=f_ch006_4 if Kspell==4
replace Kgebj5=f_ch006_5 if Kspell==5
replace Kgebj5=f_ch006_6 if Kspell==6
replace Kgebj5=f_ch006_7 if Kspell==7
replace Kgebj5=f_ch006_8 if Kspell==8

recode Kgebj5 (-2/-1=.)
label var Kgebj5 "Geburtsjahr Kind Welle 5"
label value Kgebj5 Kgebj5
tab Kgebj5, m
drop f_ch006*

* Wohnort Welle 4
gen Kwohn4=0
replace Kwohn4=v_ch007_1 if (Kspell==1) 
replace Kwohn4=v_ch007_2 if (Kspell==2)
replace Kwohn4=v_ch007_3 if (Kspell==3)
replace Kwohn4=v_ch007_4 if (Kspell==4)
replace Kwohn4=v_ch007_5 if (Kspell==5)
replace Kwohn4=v_ch007_6 if (Kspell==6)
replace Kwohn4=v_ch007_7 if (Kspell==7)
replace Kwohn4=v_ch007_8 if (Kspell==8)

recode Kwohn4 (-2/0=.) (1/2=1) (3/4=2) (5=3) (6=4) (7/9=5)
label var Kwohn4 "Wohnort Kind Welle 4"
label define Kwohn4 1"same HH/ building" 2"less than 5km away" 3"5-25km away" 4 "25-100km" 5"more than 100km away"
label value Kwohn4 Kwohn4
tab Kwohn4, m

* Wohnort Welle 5
gen Kwohn5=0
replace Kwohn5=f_ch007_1 if Kspell==1
replace Kwohn5=f_ch007_2 if Kspell==2
replace Kwohn5=f_ch007_3 if Kspell==3
replace Kwohn5=f_ch007_4 if Kspell==4
replace Kwohn5=f_ch007_5 if Kspell==5
replace Kwohn5=f_ch007_6 if Kspell==6
replace Kwohn5=f_ch007_7 if Kspell==7
replace Kwohn5=f_ch007_8 if Kspell==8
tab Kwohn5, m

recode Kwohn5 (-2/0=.) (1/2=1) (3/4=2) (5=3) (6=4) (7/8=5)
label var Kwohn5 "Wohnort Kind Welle 5"
label define Kwohn5 1"same HH/ building" 2"less than 5km away" 3"5-25km away" 4 "25-100km" 5"more than 100km away"
label value Kwohn5 Kwohn5
tab Kwohn5, m

*** Gleiches Kind?
gen Gleich=0
replace Gleich=1 if Kgebj4== Kgebj5
tab Gleich, m

** Boomerangs?
generate boom=0
label define boom 1 "Boomerang", replace
replace boom=1 if (((Kwohn4==2) | (Kwohn4==3) | (Kwohn4==4) | (Kwohn4==5)) & (Kwohn5==1))
label value boom boom
tab boom, m

keep hhid5

saveold $out\boom.dta, replace  


