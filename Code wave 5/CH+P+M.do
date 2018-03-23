********************************
******* Datenmanagement ********
** Children und Eltern mergen **

version 13
clear all
set more off, perm
set linesize 80
capture log close


* Master Do-File
do "C:\Users\Julia\Documents\Studium\M.A.Soziologie\5.Semester\Masterarbeit\Methods\Do-Files\Master.do"

* LOG-Datei
capture log close
log using $log\Parents.log, replace

do $do\Eltern_5.do

do $do\Macro.do

use $out\children5.dta, clear


*************
* Children und eltern_5 mergen
*************

merge m:1 hhid5 using $out\Eltern.dta, gen(chp_merge)
keep if chp_merge==3

numlabel _all, add

drop coupleid5 
*Support
gen octime=0
replace octime= (chtime1 + chtime2)- (c1time1 + c1time2) if Kspell==1
replace octime= (chtime1 + chtime2)- (c2time1 + c2time2) if Kspell==2
replace octime= (chtime1 + chtime2)- (c3time1 + c3time2) if Kspell==3
replace octime= (chtime1 + chtime2)- (c4time1 + c4time2) if Kspell==4
replace octime= (chtime1 + chtime2)- (c5time1 + c5time2) if Kspell==5
replace octime= (chtime1 + chtime2)- (c6time1 + c6time2) if Kspell==6
replace octime= (chtime1 + chtime2)- (c7time1 + c7time2) if Kspell==7
replace octime= (chtime1 + chtime2)- (c8time1 + c8time2) if Kspell==8
recode octime (0=.)

drop chtime* c1time* c2time* c3time* c4time* c5time* c6time* c7time* c8time*

replace octime= octime/nk_away // damit mehr Kinder nicht mehr Support
recode octime (.=0)
label var octime "Support for children"
tab octime, m


*** Kinder Wohnort
replace Kcohab=0 if Kmar==1 // wenn verheiratet und zusammenlebend, dann nicht mit Eltern
replace Kcohab=1 if Kwohn==1 | Kwohn==2
replace Kcohab=0 if Kwohn==3 | Kwohn==4 | Kwohn==5
tab Kcohab, m

*** Variable für andere Kinder zuhause
// egal welches Alter
tab Khome
gen chilhome=Khome
replace chilhome = Khome -1 if Kcohab ==1
label var chilhome "(Other) children in parents households (all ages)"
tab chilhome, m

tab Countkids // Gesamtzahl Kinder in Haushalt


* Anzahl Kinder nicht zu hause
gen kidsout= nKind -Countkids
recode kidsout(-2 -1=0)
tab kidsout


// nur young adults
tab Countya, m

// nur Kinder
tab Countbaby, m

// nur 40+ Kinder
tab Countold, m

********************
***Variablen droppen
********************
drop fam_resp


*******************
*** Fallauswahl
*******************
drop if Kalter < 20 | Kalter > 39 // nur Kinder 20-39 behalten
drop if parstatus !=1 // nur leibliche Kinder behalten
drop parstatus
drop if Kcohab==. // keine Info Wohnort
drop if Kjob==8 // permanently sick, disabled   


// Eltern
recode Famhome (2/6=2)
label def Famhome 0"no family" 1"1 family member" 2"2+ family members"
label val Famhome Famhome

recode Countold (1/4=1)
label def Countold 1 "40+ cohabitating"
label val Countold Countold

recode otherya (2/5=2)
label def otherya 0 "no other ya" 1 "1 other ya" 2 "2+ other ya" 
label val otherya otherya

recode Countbaby (2/4=2)
label def Countbaby 0"no under 20" 1 "1 under 20" 2 "2+ under 20"
label val Countbaby Countbaby

recode Omps (1/3=1)
label def Omps 0 "no Omps " 1 "Omps"
label val Omps Omps

******************
*** Macro 
******************

merge m:1 country using $out\macro.dta, gen(macro_m)



saveold $out\sample.dta, replace  

*** Missings testen
// misschk parstatus Kwohn Keduc Kjob Kkind // BEVOR man parstatus drop macht!

// für Deskription eltern in Kinderteil
*keep alter1 alter2 partner hhsize Kspell hhid5
*reshape wide alter1 alter2 partner hhsize, i(hhid5) j(Kspell)
*keep alter11 alter12 parter1 hhsize1



