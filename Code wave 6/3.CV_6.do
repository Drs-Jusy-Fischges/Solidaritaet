*******************************
******* Datenmanagement *******
******** Coverscreen **********

version 13
clear all
set more off, perm
set linesize 80
capture log close


* Master Do-File
do "C:\Users\Julia\Documents\Studium\M.A.Soziologie\5.Semester\Masterarbeit\Methods-Publikation\Do-Files\Master.do"

use $SHARE\sharew6_rel6-0-0_ALL_datasets_stata/sharew6_rel6-0-0_cv_r.dta, clear

keep mergeid hhsize hhid6 cvresp relrpers deceased

* nur Lebende behalten
drop if deceased==1
drop deceased

* neue Variable f�r Partner im HH
gen spouse=.
replace spouse=1 if relrpers==1 | relrpers==2 |  relrpers==11
tab spouse

egen partner = count(spouse), by(hhid6) 
label var partner "(Ex-)Partner in HH"
drop if partner>1 
tab partner, m  
drop spouse

* Korrektur HHsize
recode hhsize (0=1) // damit keine leeren Haushalte mehr (Tote sind ja weg)

* Missing kodieren 
do $do\sharetom5.ado
numlabel _all, add


* jetzt nur noch 1 Zeile pro Haushalt (egal welche)
sort hhid6
quietly by hhid6: gen dup= cond(_N==1,0,_n)
tab dup
drop if dup>1
drop dup

saveold $out\coverscreen_HH.dta, replace  