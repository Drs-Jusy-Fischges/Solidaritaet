*******************************
******* Datenmanagement *******
********** Parents ************

version 13
clear all
set more off, perm
set linesize 80
capture log close


* Master Do-File
do "C:\Users\Julia\Documents\Studium\M.A.Soziologie\5.Semester\Masterarbeit\Methods\Do-Files\Master.do"

// Personenebene
do $do\DM_5.do
do $do\ISCED_5.do
do $do\HL_5.do
do $do\CH_5.do

// dazu für Partner in HH, HH-Größe
do $do\CV_5.do

// Haushaltsebene
do $do\HO_5.do
do $do\SP_5.do
do $do\INC_5.do

* Zusammenfassen
use $out\Demographics_IND.dta
merge 1:1 mergeid using $out\Isced_par.dta, gen(par_m) 
drop if par_m==2
merge 1:1 mergeid using $out\Health.dta, gen(health_m) 
drop if health_m==2
drop par_m health_m 

* Schwulen- und Lesbenpaare raus
sort hhid5 eltern
quietly by hhid5 eltern: gen dup= cond(_N==1,0,_n)
tab dup
keep if dup==0
drop dup


* Auf Haushaltsebene umstrukturieren (so, dass Elterninfos in gleichem Spell)
* 1= Väter, 2=Mütter
sort hhid5 mergeid
drop mergeid mergeidp5 coupleid5 omacoh
reshape wide alter migr fborn fcit isced_p casp subges Emar int_year hosnight, i(hhid5) j(eltern)

* Housing dazu
merge 1:1 hhid5 using $out\Housing.dta, gen(house_m)
drop if house_m==2
drop house_m

* Support dazu
merge 1:1 hhid5 using $out\Support.dta, gen(supp_m)
drop if supp_m==2
drop supp_m

* Employment and Pensions 
merge 1:1 hhid5 using $out\Income.dta, gen(m_ep)
drop if m_ep==2
drop m_ep

* Haushaltsgröße & Partner in HH dranmatchen 
merge 1:1 hhid5 using $out\Coverscreen_HH.dta, gen(cov_m)
drop if cov_m==2
drop cov_m



**************************
*Variablen zusammenfassen
**************************

* Korrektur Partnervariable
replace partner=1 if ((hhsize>1 | Hnum>1) & (Emar1==1 | Emar2==1))
tab Emar1 if partner==0
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

* Gesundheit
gen xhealth=.
replace xhealth= (subges1 + subges2)/2 if partner==1
replace xhealth= subges1 if subges2==. & partner==0
replace xhealth= subges2 if subges1==. & partner==0
label var xhealth "Average subj. health parents"
recode xhealth (1.5=2) (2.5=3) (3.5=4) (4.5=5) (.=6)
lab def xhea 1 "Excellent" 2 "Very good" 3 "Good" 4 "Fair" 5 "Poor" 6"no information"
lab val xhealth xhea
tab xhealth, m

* CASP- Happiness
gen xhappy=.
replace xhappy=(casp1 + casp2)/2
replace xhappy= casp1 if casp2==. & partner==0
replace xhappy= casp2 if casp1==. & partner==0
label var xhappy "Average happiness parents"
tab xhappy, m

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

*Family solidarity (außer children)
// Parents
gen partime= partime1 + partime2
replace partime= partime/2 if partner==1
label var partime "Support for parents' parents"
recode partime(-5/0=0) (.=0)
tab partime, m

// Family of children
gen fchtime= fchtime1 + fchtime2
replace fchtime= fchtime/2 if partner==1
label var fchtime "Support for childrens' families"
recode fchtime(-5/0=0) (.=0)
tab fchtime, m

// Other family
gen oftime= oftime1 + oftime2
replace oftime= oftime/2 if partner==1
label var oftime "Support for other family members"
recode oftime(-5/0=0) (.=0)
tab oftime, m



*Anzahl lebende Großeltern fehlt für Pflege!!



* Erwerbsstatus Eltern
tab erwerb1 erwerb2


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

*Future pension
gen futkat=futshare1
recode futkat (0/25=1) (26/50=2) (51/75=3) (76/150=4)(.=6)

egen futs1= xtile(futshare1), n(4)
replace futs1=10 if futshare1==.

*egen futs2= xtile(futshare2), n(4)
*replace futs2=10 if futshare2==.

gen xfut=.
replace xfut=(income1*futshare1) + (income2*futshare2*0.7)
replace xfut=(income1*futshare1) if income2==. & partner==0
replace xfut=(income2*futshare2) if income1==. & partner==0

gen xfsh= xfut/xinc
egen futprct = xtile(xfsh), n(4) //neue Var mit Quartilen
replace futprct=5 if xfut==.
label def futprct 1"lowest quartile" 4"highest quartile" 5"no information"
label val futprct futprct


*drop income1 income2 xinc xfsh xfut futshare*


********************
*** Fallauswahl
********************

// Isreal raus
drop if country==25

// Hospital nights
recode hosnight* (.=0)
drop if partner==0 & (hosnight1>99 | hosnight2>99) // mehr als 100 Nächte weg, dann raus!
drop if partner==1 & (hosnight1>99 & hosnight2>99) 

saveold $out\Eltern.dta, replace 

