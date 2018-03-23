*******************************
******* Datenmanagement *******
********** Housing  ***********

version 13
clear all
set more off, perm
set linesize 80
capture log close


* Master Do-File
do "C:\Users\Julia\Documents\Studium\M.A.Soziologie\5.Semester\Masterarbeit\Methods\Do-Files\Master.do"

use $SHARE\sharew5_rel6-0-0_ALL_datasets_stata/sharew5_rel6-0-0_ho.dta, clear

keep mergeid hhid5 ho002_ ho032_ ho024e 

*** Household respondent dranmatchen 
merge 1:1 mergeid using $SHARE\sharew5_rel6-0-0_ALL_datasets_stata/sharew5_rel6-0-0_cv_r.dta, /*
*/ keepusing(hhid5 hou_resp) gen(m_gen)
drop m_gen

* Nur household respondents behalten (andere haben keine Infos)
keep if hou_resp==1

sort hhid5
drop hou_resp
drop mergeid

* Missing kodieren
do $do\sharetom5.ado
numlabel _all, add

* Owner vs. Tennant
gen owner =ho002_
recode owner (-2 -1=.)(3/5=0) (2=1)
label var owner "Houshould owner"
label define owner 0"no owner" 1"owner (incl. member of cooperative)"
label val owner owner
tab owner, m
drop ho002_

* Value of property
* sollte eig nur Wert für owner haben
gen value= ho024e
replace value=. if value<0 // Verweigern auf Missing
egen valueprct = xtile(value), n(4) //neue Var mit Perzentilen
replace valueprct=11 if value==. // Missing als eigene Kategorie
replace valueprct =0 if owner ==0 // keine Owner
label var valueprct "Value of house in deciles"
label def valueprct 0 "no house owner" 1"owner-lowest quartile" 4"owner- highest quartile" 11"no information"
label val valueprct valueprct
tab valueprct, m
drop ho024e value 


* Number of rooms
gen rooms=ho032_
recode rooms(-2 -1=.)
label var rooms "Number of rooms"
tab rooms, m
drop ho032_

saveold $out\Housing.dta, replace  




