*******************************
******* Datenmanagement *******
* Employment, Pension, Income *

version 13
clear all
set more off, perm
set linesize 80
capture log close

* Master Do-File
do "C:\Users\Julia\Documents\GitHub\Solidaritaet\Do-Files_wave6\1.Master.do"
*do "C:\Users\Isy\Documents\GitHub\Solidaritaet\Do-Files_wave6\1.Master.do"

/* Ziel: Info Ã¼ber Kinder: Wohnort, Beziehungsstatus, 
Ausbildungs- & Erwerbsstatus, Beziehung mit Eltern, letzter Auszug */

use $SHARE\sharew6_rel6-1-0_ALL_datasets_stata/sharew6_rel6-1-0_ep.dta, clear
keep hhid6 mergeid  ep205e ep207e ep678e

* Missing kodieren
do $do\sharetom5.ado
numlabel _all, add

*** Einkommen Eltern
recode ep205e ep207e  ep678e (-9999992/-1=.)
egen income=rowtotal(ep205e ep207e ep678e)
recode income (32771.54/ 1.82e+09 =32771.54) // zu große zurück auf 95%
drop ep20* ep678*

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

* Umstrukturieren, so dass Infos beider Partner in einer Zeile (1=Mann, 2=Frau)
drop mergeid
reshape wide income , i(hhid6) j(eltern)

***DATENSATZ SPEICHERN
saveold $out\income.dta, replace  







