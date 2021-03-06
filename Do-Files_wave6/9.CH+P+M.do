********************************
******* Datenmanagement ********
** Children und Eltern mergen **

version 13
clear all
set more off, perm
set linesize 80
capture log close


* Master Do-File
*do "C:\Users\Julia\Documents\GitHub\Solidaritaet\Do-Files_wave6\1.Master.do" 
do "C:\Users\Isy\Documents\GitHub\Solidaritaet\Do-Files_wave6\1.Master.do"

* LOG-Datei
capture log close
log using $log\Parents.log, replace

do $do\8.Eltern_6.do

*do $do\10.Macro.do // falsche Jahre

use $out\children6.dta, clear


*************
* Children und eltern_6 mergen
*************

merge m:1 hhid6 using $out\Eltern.dta, gen(chp_merge)
keep if chp_merge==3

numlabel _all, add
drop coupleid6

** Support operationalisieren
tab1 freqc11 helpc11, m

* erstmal die Missings auf 0
foreach var of varlist helpc11 - freqc32 {
recode `var' (.=0)
}
*

* Kinderindentifikation f�r Hilfe auf 0 wenn untersuchter YA betroffen
order helpc11 helpc12 helpc21 helpc22 helpc31 helpc32 freqc11 freqc12 freqc21 freqc22 freqc31 freqc32
foreach var of varlist helpc11 - helpc31 {
replace `var'=0 if `var'==Kspell
}
* dann freq auch auf 0
replace freqc11=0 if helpc11==0
replace freqc12=0 if helpc12==0
replace freqc21=0 if helpc21==0
replace freqc22=0 if helpc22==0
replace freqc31=0 if helpc31==0
replace freqc32=0 if helpc32==0

// jetzt haben nur noch die Geschwister Werte, man selbst z�hlt nicht mit!

* Collapse categories
foreach var of varlist freqc11-freqc32 {
recode `var' (3 4 = 1) (1 2 = 2)
label def `var' 0 "Not at all" 1 "Rarely" 2 "Regularly"
label value `var' `var'
}
*

* Rename vars
label var freqc11 "First mentioned child support frequency - father" 
label var freqc12 "First mentioned child support frequency - mother"
label var freqc21 "Second mentioned child support frequency - father"
label var freqc22 "Second mentioned child support frequency - mother"
label var freqc31 "Third mentioned child support frequency - father"
label var freqc32 "Third mentioned child support frequency - mother"


/* Percentage of children supported
* 3 Nennungen

sup_prct=.

*/


* Categorical variable support per family
gen support = .
replace support = 0 if helpc11 == 0 & helpc12 == 0 & helpc21 == 0 & helpc22 == 0 & helpc31 == 0 & helpc32 == 0 // no one supports
replace support = 1 if (helpc11 != 0 | helpc21 != 0 | helpc31 != 0 | helpc12 !=0 | helpc22 !=0 | helpc32 != 0) // one parent supports (at this stage, also two parents)
replace support = 2 if ((helpc11 != 0 | helpc21 != 0 | helpc31 != 0) & (helpc12 !=0 | helpc22 !=0 | helpc32 != 0)) // two parents support
label var support "Sibling of YA - supported"



*** Variable f�r andere Kinder zuhause
// egal welches Alter
tab Khome
gen chilhome=Khome
replace chilhome = Khome -1 if Kcohab ==1
label var chilhome "(Other) children in parents households (all ages)"
tab chilhome, m

tab Countkids // Gesamtzahl Kinder in Haushalt

* Anzahl Kinder nicht zu hause
*gen kidsout= nKind -Countkids
*recode kidsout(-2 -1=0)
*tab kidsout


// nur young adults
tab Countya, m

// nur Kinder
tab Countbaby, m

// nur 40+ Kinder
*tab Countold, m


*******************
*** Fallauswahl
*******************
drop if Kalter < 18 | Kalter > 35 // nur Kinder 20-35 behalten
drop if parstatus !=1 // nur leibliche Kinder behalten
drop if Kcohab==. // keine Info Wohnort
drop if Kjob==8 // permanently sick, disabled   

********************
***Variablen droppen
********************
drop fam_resp parstatus ch10* ch30* wohn* ch5* year* ya* cvres chp_mer int_year2 alter1 alter2 

*recode otherya (2/5=2)
*label def otherya 0 "no other ya" 1 "1 other ya" 2 "2+ other ya" 
*label val otherya otherya

*recode Countbaby (2/4=2)
*label def Countbaby 0"no under 18" 1 "1 under 18" 2 "2+ under 18"
*label val Countbaby Countbaby

******************
*** Macro 
******************

* merge m:1 country using $out\macro.dta, gen(macro_m)



saveold $out\sample.dta, replace  

*** Missings testen
// misschk parstatus Kwohn Keduc Kjob Kkind // BEVOR man parstatus drop macht!

// f�r Deskription eltern in Kinderteil
*keep alter1 alter2 partner hhsize Kspell hhid5
*reshape wide alter1 alter2 partner hhsize, i(hhid5) j(Kspell)
*keep alter11 alter12 parter1 hhsize1



