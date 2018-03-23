*******************************
******* Datenmanagement *******
******** Coverscreen **********

version 13
clear all
set more off, perm
set linesize 80
capture log close


* Master Do-File
do "C:\Users\Julia\Documents\Studium\M.A.Soziologie\5.Semester\Masterarbeit\Methods\Do-Files\Master.do"

use $SHARE\sharew5_rel6-0-0_ALL_datasets_stata/sharew5_rel6-0-0_cv_r.dta, clear

keep mergeid hhsize hhid5 cvresp relrpers deceased

* nur Lebende behalten
drop if deceased==1
drop deceased

* neue Variable für Partner im HH
gen spouse=.
replace spouse=1 if relrpers==1 | relrpers==11
tab spouse

egen partner = count(spouse), by(hhid5)
label var partner "(Ex-)Partner in HH"
recode partner (2=1)
tab partner, m
drop spouse


*neue Var für Kind im HH
gen child=.
replace child=1 if relrpers==3
tab child

egen Khome = count(child), by(hhid5)
tab Khome, m
label var Khome "Anzahl Kinder, die im HH leben"
drop child

*Großeltern
gen grand=.
replace grand=1 if relrpers==5 | relrpers==6
tab grand

egen Omps = count(grand), by(hhid5)
tab Omps
label var Omps "Anzahl Großeltern, die im HH leben"
drop grand

* Sonstige Familienmitglieder (Child-in-law, sibling, Grand-child, other relative)
gen fams=.
replace fams=1 if relrpers==4 | relrpers==7 | relrpers==8 | relrpers==9
tab fams

egen Famhome = count(fams), by(hhid5)
tab Famhome, m
label var Famhome "Anzahl sonstige Familienmitglieder, die im HH leben"
drop fams

* Sonstige nicht verwandte
gen sonst=.
replace sonst=1 if relrpers==10
tab sonst

egen Shome = count(sonst), by(hhid5)
tab Shome, m
label var Shome "Anzahl nicht Verwandte, die im HH leben"
drop sonst

drop relrpers mergeid cvresp

* jetzt nur noch 1 Zeile pro Haushalt (egal welche)
sort hhid5
quietly by hhid5: gen dup= cond(_N==1,0,_n)
tab dup
drop if dup>1
drop dup

* Missing kodieren 
do $do\sharetom5.ado
numlabel _all, add

* HHsize kontrollieren
gen Hnum= 1+ partner + Khome + Famhome + Shome + Omps
label var Hnum "selbst errechnete HHsize"
gen Hneu= hhsize - Hnum
drop Hneu

// Haushalte droppen, bei denen Anzahl Personen nicht stimmt??

saveold $out\coverscreen_HH.dta, replace  











