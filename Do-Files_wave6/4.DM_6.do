*******************************
******* Datenmanagement *******
******** Demographics *********

version 14
clear all
set more off, perm
set linesize 80
capture log close


* Master Do-File
* do "C:\Users\Julia\Documents\Studium\M.A.Soziologie\5.Semester\Masterarbeit\Methods-Publikation\Do-Files\1.Master.do"
do "C:\Users\Isy\Documents\GitHub\Solidaritaet\Do-Files_wave6\1.Master.do"


* Imputationsdatensatz aufmachen
use $SHARE\sharew6_rel6-1-0_ALL_datasets_stata/sharew6_rel6-1-0_gv_imputations.dta, clear

* nur Ehe behalten
keep mergeid mstat implicat

* Datensatz umformen
reshape wide mstat,j(implicat) i(mergeid)

/* Modus über 5 Variablen berechnen

gen foo = . 
gen mode = . 

qui forval i = 1/`=_N' { 
	forval j = 1/5 { 
		replace foo = mstat`j'[`i'] in `j' 
	} 
	egen bar = mode(foo) in 1/5 
	replace mode = bar[1] in `i' 
	drop bar 
} 
*

rename mode marstat_imp
lab val marstat_imp mstat
drop mstat* foo
saveold $out\imp_mstat.dta, replace  
*/

* jetzt DN Datensatz aufmachen
use $SHARE\sharew6_rel6-1-0_ALL_datasets_stata/sharew6_rel6-1-0_dn.dta, clear

keep mergeid hhid6 country mergeidp coupleid6 dn003 dn004_ dn007_ dn042_ dn040_

*Marital status aus Extrateil
merge 1:1 mergeid using $out/imp_mstat.dta


* Missing kodieren
do $do\sharetom5.ado
numlabel _all, add

sort mergeid

* Interviewjahr und Pertnerinfo dranmatchen
merge 1:1 mergeid using $SHARE\sharew6_rel6-1-0_ALL_datasets_stata/sharew6_rel6-1-0_cv_r.dta, /*
*/ keepusing(mergeid partnerinhh int_year) gen(m_gen)
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


*** Marital status
* Marital status dranmatchen aus Imputation (sonst muss man es aus allen Wellen zusammensuchen)
tab marstat_imp
rename marstat_imp Emar

* Parter im HH
tab partnerinhh, m


saveold $out\demographics_IND.dta, replace  


*** Migrational background
* Variablen umbenennen
use $SHARE\sharew6_rel6-1-0_ALL_datasets_stata/sharew6_rel6-1-0_dn.dta, clear
keep mergeid dn004_ dn007_
rename dn004_ birth6
rename dn007_ cit6
saveold $out\migration.dta, replace  

use $SHARE\sharew5_rel6-1-0_ALL_datasets_stata/sharew5_rel6-1-0_dn.dta, clear
keep mergeid dn004_ dn007_
rename dn004_ birth5
rename dn007_ cit5
saveold $out\dn_5.dta, replace  

use $SHARE\sharew4_rel6-1-0_ALL_datasets_stata/sharew4_rel6-1-0_dn.dta, clear
keep mergeid dn004_ dn007_
rename dn004_ birth4
rename dn007_ cit4
saveold $out\dn_4.dta, replace  

use $SHARE\sharew2_rel6-1-0_ALL_datasets_stata/sharew2_rel6-1-0_dn.dta, clear
keep mergeid dn004_ dn007_
rename dn004_ birth2
rename dn007_ cit2
saveold $out\dn_2.dta, replace  

use $SHARE\sharew1_rel6-1-0_ALL_datasets_stata/sharew1_rel6-1-0_dn.dta, clear
keep mergeid dn004_ dn007_
rename dn004_ birth1
rename dn007_ cit1
saveold $out\dn_1.dta, replace  

use $out\migration.dta, clear
merge 1:1 mergeid using $out\dn_5.dta, gen(mer5)
merge 1:1 mergeid using $out\dn_4.dta, gen(mer4)
merge 1:1 mergeid using $out\dn_2.dta, gen(mer2)
merge 1:1 mergeid using $out\dn_1.dta, gen(mer1)

* Variable zu letzter Info
gen birth=.
replace birth= birth1 if birth1!=. 
replace birth= birth2 if birth2!=.
replace birth= birth4 if birth4!=.
replace birth= birth5 if birth5!=.
replace birth= birth6 if birth6!=.

* Missing kodieren
do $do\sharetom5.ado
numlabel _all, add

recode birth (5=1) (1=0) (-2 -1=.)
lab def birth 0 "No" 1 "Yes"
lab var birth "Foreign birth"
lab val birth birth

gen cit=.
replace cit= cit1 if cit1!=. 
replace cit= cit2 if cit2!=.
replace cit= cit4 if cit4!=.
replace cit= cit5 if cit5!=.
replace cit= cit6 if cit6!=.

recode cit (5=1) (1=0) (-2 -1=.)
lab def cit 0 "No" 1 "Yes"
lab var cit "Foreign citizenship"
lab val cit cit

gen migr= .
replace migr=0 if (birth==0 & cit==0)
replace migr=1 if (birth==1 | cit==1)
label var migr "migrational background"
label define migr 0 "born in country of interview & citizenship" 1 "born in other country or other citizenship", replace
label val migr migr
tab migr, m

!del $out\dn_5.dta $out\dn_4.dta $out\dn_2.dta $out\dn_1.dta 

merge 1:1 mergeid using $out\demographics_IND.dta, gen(mig_m)
drop if mig_m !=3
drop mig_m birth6 -mer1

saveold $out\demographics_IND.dta, replace  


