*******************************
******* Datenmanagement *******
********** Parents ************

version 14
clear all
set more off, perm
set linesize 80
capture log close


* Master Do-File
* do "C:\Users\Julia\Documents\Studium\M.A.Soziologie\5.Semester\Masterarbeit\Methods-Publikation\Do-Files\1.Master.do"
do "C:\Users\Isy\Documents\GitHub\Solidaritaet\Do-Files_wave6\1.Master.do"

// Personenebene
do $do\4.DM_6.do
do $do\5.ISCED_6.do 
do $do\2.CH_6.do

// dazu für Partner in HH, HH-Größe
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
* 1= Väter, 2=Mütter
*sort hhid6 mergeid
*drop mergeid mergeidp6 coupleid6 omacoh
*reshape wide alter migr fborn fcit isced_p casp subges Emar int_year hosnight, i(hhid6) j(eltern)

* hier neu nur für poster
drop mergeid mergeidp6 coupleid6 dn044_
reshape wide alter migr fborn fcit isced_p Emar int_year, i(hhid6) j(eltern)

* ende neu


* Support dazu
*merge 1:1 hhid6 using $out\Support.dta, gen(supp_m)
*drop if supp_m==2
*drop supp_m

* Employment and Pensions 
merge 1:1 hhid6 using $out\Income.dta, gen(m_ep)
drop if m_ep==2
drop m_ep

* Haushaltsgr��e & Partner in HH dranmatchen 
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


* Bildung Durchschnitt (Vater trotzdem behalten)
gen xisced=.
replace xisced= (isced_p1 + isced_p2)/2 if partner==1
replace xisced= isced_p1 if isced_p2==. & partner==0
replace xisced= isced_p2 if isced_p1==. & partner==0
recode xisced (0=.) (0.5=1) (1.5=2) (2.5=3) (3.5=4) (4.5=5)
label var xisced "Average ISCED parents"
label val xisced K_educ
recode xisced (.=6)
label def xisced 6 "level of education unknown" 1 "(pre-) primary education" /*
*/2 "lower secundary education" /*
*/ 3 "upper secondary education" 4 "post-secondary non-tertiary education" /*
*/ 5 "tertiary education", replace
label val xisced xisced
tab xisced

*gen pisced=isced_p1
*recode pisced (.=6) (0=6)

*gen misced=isced_p2
*recode misced (.=6) (0=6)


label var isced_p1 "Educational level father"

* Migrationsstatus
// Zusammengefasst
gen migration=.
replace migration=0 if migr1==0 | migr2==0
replace migration=1 if migr1==1 | migr2==1
recode migration (.=2)
label var migration "Parents have migrational background"
label def migr 0 "both passport of country of interview & born there" 1 "born somewhere else/ passport of other nation" 2"no information", replace
label val migration migr
tab migration, m
drop migr1 migr2

// Einzeln 
gen fborn=.
replace fborn=0 if fborn1==0 | fborn2==0
replace fborn=1 if fborn1==1 | fborn2==1
recode fborn(.=2)
label var fborn "Parent(s) born in another country"
label val fborn fborn
tab fborn, m

gen fcit=.
replace fcit=0 if fcit1==0 | fcit2==0
replace fcit=1 if fcit1==1 | fcit2==1
recode fcit (.=2)
label var fcit "Parent(s) hold citizenship of another country"
label val fcit fcit
tab fcit, m

drop fborn1 fborn2 fcit1 fcit2


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
*drop if partner==0 & (hosnight1>99 | hosnight2>99) // mehr als 100 N�chte weg, dann raus!
*drop if partner==1 & (hosnight1>99 & hosnight2>99) 

saveold $out\Eltern.dta, replace 

