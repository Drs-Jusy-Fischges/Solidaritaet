*******************************
******* Datenmanagement *******
******** ISCED CH & P *********

version 13
clear all
set more off, perm
set linesize 80
capture log close


* Master Do-File
*do "C:\Users\Julia\Documents\GitHub\Solidaritaet\Do-Files_wave6\1.Master.do"
do "C:\Users\Isy\Documents\GitHub\Solidaritaet\Do-Files_wave6\1.Master.do"

*** Isced Eltern
use $SHARE\sharew6_rel6-1-0_ALL_datasets_stata/sharew6_rel6-1-0_gv_isced.dta, clear

keep mergeid hhid6 isced1997_r 

gen isced_p= isced1997_r
recode isced_p (-2 -1 .=0) (5/6=5) (95 97= 2)
label var isced_p "ISCED Parent"
label define isced_p 0 "level of education unknown" 1 "pre-primary & primary education" /*
*/ 2 "lower secundary education" 3 "upper secondary education" /*
*/ 4 "post-secondary non-tertiary education" 5 "tertiary education ", replace
label val isced_p isced_p
tab isced_p, m
drop isced1997_r

saveold $out\Isced_par.dta, replace  


*** Children
use $SHARE\sharew6_rel6-1-0_ALL_datasets_stata/sharew6_rel6-1-0_gv_isced.dta, clear

keep hhid6 mergeid isced1997_c1 isced1997_c2 isced1997_c3 /*
*/ isced1997_c4 isced1997_c5 isced1997_c6 isced1997_c7 isced1997_c8

*** Family respondent dranmatchen 
merge 1:1 mergeid using $SHARE\sharew6_rel6-1-0_ALL_datasets_stata/sharew6_rel6-1-0_cv_r.dta, /*
*/ keepusing(mergeid fam_resp country int_year) gen(m_gen)
drop m_gen

* nur family resp. behalten
tab fam_resp, m
keep if fam_resp==1
drop fam_resp mergeid

gen isced_c1= isced1997_c1
gen isced_c2= isced1997_c2
gen isced_c3= isced1997_c3
gen isced_c4= isced1997_c4
gen isced_c5= isced1997_c5
gen isced_c6= isced1997_c6
gen isced_c7= isced1997_c7
gen isced_c8= isced1997_c8

recode isced_c* (-2 -1 .=0) (5/6=5) (95 97= 2)

label define isced_c 0 "level of education unknown" 1 "pre-primary & primary education" /*
*/ 2 "lower secundary education" 3 "upper secondary education" /*
*/ 4 "post-secondary non-tertiary education" 5 "tertiary education ", replace
label val isced_c1 isced_c

label val isced_c1 isced_c2 isced_c3 isced_c4 isced_c5 isced_c6 /*
*/isced_c7 isced_c8 isced_c

drop *1997*

* Doppelte Fälle raus
sort hhid6
quietly by hhid6: gen dup= cond(_N==1,0,_n)
tab dup
keep if dup<2
drop dup


saveold $out\Isced_child.dta, replace  

