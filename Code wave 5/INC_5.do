*******************************
******* Datenmanagement *******
* Employment, Pension, Income *

version 13
clear all
set more off, perm
set linesize 80
capture log close

* Master Do-File
do "C:\Users\Julia\Documents\Studium\M.A.Soziologie\5.Semester\Masterarbeit\Methods\Do-Files\Master.do"

/* Ziel: Info über Kinder Welle 4: Wohnort, Beziehungsstatus, 
Ausbildungs- & Erwerbsstatus, Beziehung mit Eltern, letzter Auszug */

use $SHARE\sharew5_rel6-0-0_ALL_datasets_stata/sharew5_rel6-0-0_ep.dta, clear
keep hhid5 mergeid ep005_ ep205e ep207e ep109_1

* Missing kodieren
do $do\sharetom5.ado
numlabel _all, add


*** Erwerbsstatus Eltern
gen erwerb= ep005_
drop ep005_
label var erwerb "Erwerbssituation Eltern"
label def erwerb 1 "Retired" 2 "Employed" 3 "Unemployed" 4 "Sick/ Disabled" 5 "Homemaker" 97 "Other"
label val erwerb erwerb
tab erwerb, m

recode ep205e (.=0)
recode ep207e (.=0)
gen income=ep205e + ep207e
recode income (-10000000/0=.)
drop ep20*

*** Future pension Eltern Anteil Gehalt
gen futshare=ep109_1
recode futshare(-2 -1=.)
drop ep109_1
label var futshare "Future pension as share of current income"

* Geschlecht dazu
merge 1:1 mergeid using $out\demographics_IND.dta, keepusing(mergeid eltern)
keep if _merge==3
drop _merge

* Gleichgeschlechtliche Paare raus
sort hhid5 eltern
quietly by hhid5 eltern: gen dup= cond(_N==1,0,_n)
tab dup
keep if dup==0
drop dup

* Umstrukturieren, so dass Infos beider Partner in einer Zeile (1=Mann, 2=Frau)
drop mergeid
reshape wide erwerb income futshare, i(hhid5) j(eltern)

// in Eltern_5 Variablen zusammenfassen!

***DATENSATZ SPEICHERN
saveold $out\income.dta, replace  







