*******************************
******* Datenmanagement *******
********** Parents ************

version 13
clear all
set more off, perm
set linesize 80
capture log close


* Master Do-File
*do "C:\Users\Julia\Documents\GitHub\Solidaritaet\Do-Files_wave6\1.Master.do"
do "C:\Users\Isy\Documents\GitHub\Solidaritaet\Do-Files_wave6\1.Master.do"

// Personenebene
do $do\4.DM_6.do
do $do\5.ISCED_6.do 
do $do\2.CH_6.do

// dazu fÃ¼r Partner in HH, HH-GrÃ¶ÃŸe
do $do\3.CV_6.do

// Haushaltsebene
*do $do\6.SP_6.do
do $do\7.INC_6.do

* Zusammenfassen
use $out\Demographics_IND.dta
merge 1:1 mergeid using $out\Isced_par.dta, gen(par_m) 
drop if par_m==2

* Schwulen- und Lesbenpaare raus
sort hhid6 eltern
quietly by hhid6 eltern: gen dup= cond(_N==1,0,_n)
tab dup
keep if dup==0
drop dup

* Auf Haushaltsebene umstrukturieren (so, dass Elterninfos in gleichem Spell)
* 1= VÃter, 2=Mütter
sort hhid6 mergeid
drop mergeid mergeidp6 coupleid6 _merge dn004_ dn007_ dn040_
reshape wide alter migr cit birth isced_p Emar int_year partnerinhh, i(hhid6) j(eltern)

* Support dazu
merge 1:1 hhid6 using $out\Support.dta, gen(supp_m)
drop if supp_m==2
drop supp_m

* Employment and Pensions 
merge 1:1 hhid6 using $out\Income.dta, gen(m_ep)
drop if m_ep==2
drop m_ep

* Haushaltsgröße & Partner in HH dranmatchen 
merge 1:1 hhid6 using $out\Coverscreen_HH.dta, gen(cov_m)
drop if cov_m==2
drop cov_m


**************************
*Variablen zusammenfassen
**************************

* Korrektur Partnervariable
*replace partner=1 if ((hhsize>1 | Hnum>1) & (Emar1==1 | Emar2==1))
*tab Emar1 if partner==0
// was mit denen, wo HHsize=1 & nur einer hat Fragebogen beantwortet?


* Marital status
order Emar1 Emar2
tab Emar1 if Emar1==Emar2
gen parmar=0
replace parmar=1 if ((partner==1) & ((Emar1==1) | (Emar2==1))) // mind. einer gibt an "married & living together"
replace parmar=1 if ((partner==1) & ((Emar1==2) | (Emar2==2))) // mind. einer gibt an "registered partnership"
label var parmar "Parents married"
label def parmar 0 "Not married (including singles)" 1 "Parents married/ registered partnership"
label val parmar parmar
*drop Emar1 Emar2
// geht so nicht! Missings sind singles


* Alter Durchschnitt (wenn Paar)
gen xalter=.
replace xalter=(alter1 + alter2)/2 if partner==1
replace xalter= alter1 if alter2==. & partner==0
replace xalter= alter2 if alter1==. & partner==0
replace xalter= alter1 if alter2==.
replace xalter= alter2 if alter1==.
replace xalter= 57 if xalter==.
label var xalter "Average age parents"
tab xalter, m


label var isced_p1 "Educational level father"
label var isced_p2 "Educational level mother"
lab val isced_p1 isced_p1
lab val isced_p2 isced_p2


* Migrationshintergrund
tab migr1, m
lab var migr1 "Migration background father"
lab val migr1 migr1
lab var migr2 "Migration background mother"
lab val migr2 migr2


* Einkommen Eltern
gen xinc=.
replace xinc=(income1 + (income2*0.7))
replace xinc= income1 if income2==. & partner==0
replace xinc= income2 if income1==. & partner==0
replace xinc= log(xinc)
egen incprct = xtile(xinc), n(4) //neue Var mit Quartilen
label var xinc "Cum. Income"

recode incprct (.=5)
label def incprct 1 "lowest quartile" 2 "" 3 "" 4 "highest quartile" 5 "no information"
label val incprct incprct
tab incprct, m



********************
*** Fallauswahl
********************

// Isreal raus
drop if country==25

// Hospital nights
*recode hosnight* (.=0)
*drop if partner==0 & (hosnight1>99 | hosnight2>99) // mehr als 100 Nächte weg, dann raus!
*drop if partner==1 & (hosnight1>99 & hosnight2>99) 

saveold $out\Eltern.dta, replace 

