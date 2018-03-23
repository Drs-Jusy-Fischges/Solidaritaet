*******************************
******* Datenmanagement *******
******** Demographics *********

version 13
clear all
set more off, perm
set linesize 80
capture log close


* Master Do-File
do "C:\Users\Julia\Documents\Studium\M.A.Soziologie\5.Semester\Masterarbeit\Methods\Do-Files\Master.do"
use $SHARE\sharew5_rel6-0-0_ALL_datasets_stata/sharew5_rel6-0-0_dn.dta, clear

keep mergeid hhid5 country mergeidp coupleid5 dn003 dn004_ dn007_ /*
*/ dn014_ dn030_1 dn030_2 dn032_1 dn032_2 dn033_1 dn033_2 /*
*/ dn034_ dn035_ dn036_ dn037_ dn042_

* Missing kodieren
do $do\sharetom5.ado
numlabel _all, add

sort mergeid

* Interviewjahr dranmatchen
merge 1:1 mergeid using $SHARE\sharew5_rel6-0-0_ALL_datasets_stata/sharew5_rel6-0-0_cv_r.dta, /*
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

*** Alter (30.8% Missing!!!)
gen Gebj= dn003_
recode Gebj(-2 -1=.)
drop dn003_
gen alter=int_year - Gebj
tab alter, m
drop Gebj

*** Migrational background
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
gen Emar=dn014_
recode Emar (-2 -1 .=7)
label var Emar "Marital status Eltern"
label define Emar 1 "Married & living together" 2 "Registered partnership" 3 "Married & living apart" /*
*/ 4 "Never married" 5 "Divorced" 6 "Widowed" 7 "no information"
label val Emar Emar 
tab Emar, m
drop dn014_

*** Cohabitation with parent
gen omacoh=dn030_1
recode omacoh (. -2 -1 3 4 5 6 7 8 9=0) (1 2=1)
replace omacoh=1 if dn030_2==1 | dn030_2==2
label var omacoh "Cohabitation with parent"
label define omacoh 0 "no cohabitation with parent" 1 "cohabitation with parent", replace
label val omacoh omacoh
tab omacoh, m
drop dn030_1 dn030_2

drop dn032_1 dn032_2 dn034_ dn035_ dn036_ dn037_ 

* Gesundheitszustand Großeltern
drop dn033_1 dn033_2

saveold $out\demographics_IND.dta, replace  




