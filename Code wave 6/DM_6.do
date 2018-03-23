*******************************
******* Datenmanagement *******
******** Demographics *********

version 13
clear all
set more off, perm
set linesize 80
capture log close


* Master Do-File
do "C:\Users\Julia\Documents\Studium\M.A.Soziologie\5.Semester\Masterarbeit\Methods-Publikation\Do-Files\Master.do"

* jetzt DN Datnesatz aufmachen
use $SHARE\sharew6_rel6-0-0_ALL_datasets_stata/sharew6_rel6-0-0_dn.dta, clear

keep mergeid hhid6 country mergeidp coupleid6 dn003 dn004_ dn007_ dn044_ dn042_

* Missing kodieren
do $do\sharetom5.ado
numlabel _all, add

sort mergeid

* Interviewjahr dranmatchen
merge 1:1 mergeid using $SHARE\sharew6_rel6-0-0_ALL_datasets_stata/sharew6_rel6-0-0_cv_r.dta, /*
*/ keepusing(mergeid int_year) gen(m_gen)
drop if m_gen==2
drop m_gen

*** Väter & Mütter identifizieren
gen eltern=dn042_
drop dn042_
label var eltern "Elternteil"
label define eltern 1 "Vater" 2 "Mutter"
label val eltern eltern
tab eltern, m

*** Alter
gen Gebj= dn003_
recode Gebj(-2 -1=.)
drop dn003_
gen alter=int_year - Gebj
tab alter, m
drop Gebj

*** Migrational background

*
*hier fehlen noch die die sich nicht geändert haben aus den anderen wellen 
*

gen migr= dn004_
recode migr (1=0) (5=1)
replace migr=1 if dn007==5
recode migr (.=2)
label var migr "migrational background"
label define migr 0 "born in country of interview & citizenship" 1 "born in other country/ other citizenship" 2"no information", replace
label val migr migr
tab migr, m

// 2 Dummys Variablen
gen fborn= dn004_
recode fborn (1=0) (5=1) (.=2)
label var fborn "Born in other country"
label def fborn 0 "born in country of interview" 1 "born in other country" 2 "no information"
label val fborn fborn
tab fborn, m

gen fcit= dn007_
recode fcit (1=0) (5=1) (.=2)
label var fcit "Citizenship of other country"
label def fbcit 0 "Citizenship of country of interview" 1 "Citizenship of other country" 2 "no information"
label val fcit fcit
tab fcit, m

drop dn004_ dn007_ 

*** Marital status
* Marital status dranmatchen aus IMputation (sonst muss man es aus allen Wellen zusammensuchen)
merge 1:1 mergeid using $SHARE\sharew6_rel6-0-0_ALL_datasets_stata/sharew6_rel6-0-0_gv_imputations.dta, /*
*/ keepusing(mergeid mstat) gen(m_imp)
drop m_imp

rename mstat Emar // so heist es später

saveold $out\demographics_IND.dta, replace  
