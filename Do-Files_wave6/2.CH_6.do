*******************************
******* Datenmanagement *******
********** Children ***********

version 13
clear all
set more off, perm
set linesize 80
capture log close

* Master Do-File
do "C:\Users\Julia\Documents\GitHub\Solidaritaet\Do-Files_wave6\1.Master.do"
*do "C:\Users\Isy\Documents\GitHub\Solidaritaet\Do-Files_wave6\1.Master.do"

* LOG-Datei
capture log close
log using $log\Children6.log, replace

/* Ziel: Info Ã¼ber Kinder: Wohnort, Beziehungsstatus, 
Ausbildungs- & Erwerbsstatus, Beziehung mit Eltern, letzter Auszug */

*** Wohnort aus allen Wellen (sonst nur VerÃ¤nderung)
* Variablen umbenennen
use $SHARE\sharew6_rel6-1-0_ALL_datasets_stata/sharew6_rel6-1-0_ch.dta, clear
keep mergeid ch001_ ch007_1 ch007_2 ch007_3 ch007_4 ch007_5 ch007_6 ch007_7 ch007_8 ch505_1-ch505_20  ch006_1-ch006_8
rename (ch007_1 ch007_2 ch007_3 ch007_4 ch007_5 ch007_6 ch007_7 ch007_8) (wohn61 wohn62 wohn63 wohn64 wohn65 wohn66 wohn67 wohn68)
saveold $out\wohnort.dta, replace  

use $SHARE\sharew5_rel6-1-0_ALL_datasets_stata/sharew5_rel6-1-0_ch.dta, clear
keep mergeid ch007_1 ch007_2 ch007_3 ch007_4 ch007_5 ch007_6 ch007_7 ch007_8 ch505_1 ch006_1-ch006_8
rename (ch007_1 ch007_2 ch007_3 ch007_4 ch007_5 ch007_6 ch007_7 ch007_8 ch006_1 ch006_2 ch006_3 ch006_4 ch006_5 ch006_6 ch006_7 ch006_8) /*
*/ (wohn51 wohn52 wohn53 wohn54 wohn55 wohn56 wohn57 wohn58 year1 year2 year3 year4 year5 year6 year7 year8)
saveold $out\wohn_5.dta, replace  



use $out\wohnort.dta, clear
merge 1:1 mergeid using $out\wohn_5.dta, gen(mer5)
drop if mer5 != 3
drop mer5

recode ch001_ (. = 0) (-2 -1 = .)
drop if ch001_ > 8
drop if ch001_ == 0


* Zuordnen der Kinder in Welle 5 zu Welle 6
* Child 1
gen wave5to6_c1 = .
replace wave5to6_c1 = 2 if year1 != ch006_1
replace wave5to6_c1 = 0 if year1 == .
replace wave5to6_c1 = 1 if year1 == ch006_1
replace wave5to6_c1 = 3 if ch006_1 == .
label var wave5to6_c1 "Info transmission child 1"
label def wave5to6_c1 0 "Item nonresponse wave 5" 1 "Same info" 2 "Different info" 3 "Item nonresponse wave 6"
label value wave5to6_c1 wave5to6_c1

* Child 2
gen wave5to6_c2 = .
replace wave5to6_c2 = 2 if year2 != ch006_2
replace wave5to6_c2 = 0 if year2 == .
replace wave5to6_c2 = 1 if year2 == ch006_2
replace wave5to6_c2 = 3 if ch006_2 == .
replace wave5to6_c2 = . if ch001_ < 2
label var wave5to6_c2 "Info transmission child 2"
label def wave5to6_c2 0 "Item nonresponse wave 5" 1 "Same info" 2 "Different info" 3 "Item nonresponse wave 6" .a "No such child", replace
label value wave5to6_c2 wave5to6_c2

* Child 3
gen wave5to6_c3 = .
replace wave5to6_c3 = 2 if year3 != ch006_3
replace wave5to6_c3 = 0 if year3 == .
replace wave5to6_c3 = 1 if year3 == ch006_3
replace wave5to6_c3 = 3 if ch006_3 == .
replace wave5to6_c3 = . if ch001_ < 3
label var wave5to6_c3 "Info transmission child 3"
label def wave5to6_c3 0 "Item nonresponse wave 5" 1 "Same info" 2 "Different info" 3 "Item nonresponse wave 6" .a "No such child", replace
label value wave5to6_c3 wave5to6_c3

* Child 4
gen wave5to6_c4 = .
replace wave5to6_c4 = 2 if year4 != ch006_4
replace wave5to6_c4 = 0 if year4 == .
replace wave5to6_c4 = 1 if year4 == ch006_4
replace wave5to6_c4 = 3 if ch006_4 == .
replace wave5to6_c4 = . if ch001_ < 4
label var wave5to6_c4 "Info transmission child 4"
label def wave5to6_c4 0 "Item nonresponse wave 5" 1 "Same info" 2 "Different info" 3 "Item nonresponse wave 6" .a "No such child", replace
label value wave5to6_c4 wave5to6_c4

* Child 5
gen wave5to6_c5 = .
replace wave5to6_c5 = 2 if year5 != ch006_5
replace wave5to6_c5 = 0 if year5 == .
replace wave5to6_c5 = 1 if year5 == ch006_5
replace wave5to6_c5 = 3 if ch006_5 == .
replace wave5to6_c5 = . if ch001_ < 5
label var wave5to6_c5 "Info transmission child 5"
label def wave5to6_c5 0 "Item nonresponse wave 5" 1 "Same info" 2 "Different info" 3 "Item nonresponse wave 6" .a "No such child", replace
label value wave5to6_c5 wave5to6_c5

* Child 6
gen wave5to6_c6 = .
replace wave5to6_c6 = 2 if year6 != ch006_6
replace wave5to6_c6 = 0 if year6 == .
replace wave5to6_c6 = 1 if year6 == ch006_6
replace wave5to6_c6 = 3 if ch006_6 == .
replace wave5to6_c6 = . if ch001_ < 6
label var wave5to6_c6 "Info transmission child 6"
label def wave5to6_c6 0 "Item nonresponse wave 5" 1 "Same info" 2 "Different info" 3 "Item nonresponse wave 6" .a "No such child", replace
label value wave5to6_c6 wave5to6_c6

* Child 7
gen wave5to6_c7 = .
replace wave5to6_c7 = 2 if year7 != ch006_7
replace wave5to6_c7 = 0 if year7 == .
replace wave5to6_c7 = 1 if year7 == ch006_7
replace wave5to6_c7 = 3 if ch006_7 == .
replace wave5to6_c7 = . if ch001_ < 7
label var wave5to6_c7 "Info transmission child 7"
label def wave5to6_c7 0 "Item nonresponse wave 5" 1 "Same info" 2 "Different info" 3 "Item nonresponse wave 6" .a "No such child", replace
label value wave5to6_c7 wave5to6_c7

* Child 8
gen wave5to6_c8 = .
replace wave5to6_c8 = 2 if year8 != ch006_8
replace wave5to6_c8 = 0 if year8 == .
replace wave5to6_c8 = 1 if year8 == ch006_8
replace wave5to6_c8 = 3 if ch006_8 == .
replace wave5to6_c8 = . if ch001_ < 8
label var wave5to6_c8 "Info transmission child 8"
label def wave5to6_c8 0 "Item nonresponse wave 5" 1 "Same info" 2 "Different info" 3 "Item nonresponse wave 6" .a "No such child", replace
label value wave5to6_c8 wave5to6_c8

recode wohn* (1/2=1) (3/9=0) (-2/-1=.)

* Variable zu Info Jahr 5
* Kind 1
gen wohnc1=.
replace wohnc1= wohn51 if wohn51!=. & wave5to6_c1 == 1
lab def wohnc1 0"No" 1"Yes"
lab var wohnc1 "Child 1: Living at parents` home"
lab val wohnc1 wohnc1
tab wohnc1, m

* Kind 2
gen wohnc2=.
replace wohnc2= wohn52 if wohn52!=. & wave5to6_c2 == 1
lab def wohnc2 0"No" 1"Yes"
lab var wohnc2 "Child 2: Living at parents` home"
lab val wohnc2 wohnc2

* Kind 3
gen wohnc3=.
replace wohnc3= wohn53 if wohn53!=. & wave5to6_c3 == 1
lab def wohnc3 0"No" 1"Yes"
lab var wohnc3 "Child 3: Living at parents` home"
lab val wohnc3 wohnc3

* Kind 4
gen wohnc4=.
replace wohnc4= wohn54 if wohn54!=. & wave5to6_c4 == 1
lab def wohnc4 0"No" 1"Yes"
lab var wohnc4 "Child 4: Living at parents` home"
lab val wohnc4 wohnc4
tab wohnc4, m

* Kind 5
gen wohnc5=.
replace wohnc5= wohn55 if wohn55!=. & wave5to6_c5 == 1
lab def wohnc5 0"No" 1"Yes"
lab var wohnc5 "Child 5: Living at parents` home"
lab val wohnc5 wohnc5

* Kind 6
gen wohnc6=.
replace wohnc6= wohn56 if wohn56!=. & wave5to6_c6 == 1
lab def wohnc6 0"No" 1"Yes"
lab var wohnc6 "Child 6: Living at parents` home"
lab val wohnc6 wohnc6

* Kind 7
gen wohnc7=.
replace wohnc7= wohn57 if wohn57!=. & wave5to6_c7 == 1
lab def wohnc7 0"No" 1"Yes"
lab var wohnc7 "Child 7: Living at parents` home"
lab val wohnc7 wohnc7

* Kind 8
gen wohnc8=.
replace wohnc8= wohn58 if wohn58!=. & wave5to6_c8 == 1
lab def wohnc8 0"No" 1"Yes"
lab var wohnc8 "Child 8: Living at parents` home"
lab val wohnc8 wohnc8


* Boomerang
* Child 1
gen boom1 = . 
replace boom1=0 if wohnc1!=.
replace boom1=1 if ((wohn61==1) & (wohnc1==0))
lab def boom1 0 "No" 1"Yes", replace
lab var boom1 "Child 1: Boomerang"
lab val boom1 boom1
tab boom1, m

************ Wann anders fortfÃ¼hren!! ****************



* Move out
* Child 1
gen move1 = . 
replace move1=0 if wohnc1!=.
replace move1=1 if ((wohn61==0) & (wohnc1==1))
lab def move1 0 "No" 1"Yes", replace
lab var move1 "Child 1: Moved out"
lab val move1 move1
tab move1, m



************ Wann anders fortfÃ¼hren!! ****************



* Missing kodieren
do $do\sharetom5.ado
numlabel _all, add







saveold $out\wohnort.dta, replace  



**********************************************
**********************************************
**********************************************

** Kinderdatensatz Welle 6 
use $SHARE\sharew6_rel6-1-0_ALL_datasets_stata/sharew6_rel6-1-0_ch.dta, clear
sort mergeid
keep mergeid coupleid6 hhid6 ch001_ ch005_1-ch005_8  ch006_1-ch006_8 ch007_1-ch007_8 /*
*/ ch012_1-ch012_8 ch013_1-ch013_8 /*
*/ ch014_1-ch014_8 ch015_1-ch015_8 ch016_1-ch016_8 ch019_1-ch019_8 /*
*/ ch102_1-ch102_8 ch103_1-ch103_8 ch104_1-ch104_8 ch105_1-ch105_8 ch106_1-ch106_8 /*
*/ ch107_1-ch107_8 ch108_1-ch108_8 ch303d1-ch303d8 ch302_

* Missing kodieren
do $do\sharetom5.ado
numlabel _all, add

*** Family respondent, Land & Interviewjahr dranmatchen 
merge 1:1 mergeid using $SHARE\sharew6_rel6-1-0_ALL_datasets_stata/sharew6_rel6-1-0_cv_r.dta, /*
*/ keepusing(mergeid fam_resp country int_year) gen(m_gen)
drop m_gen

* nur family resp. behalten
tab fam_resp, m
keep if fam_resp==1

*** Datensatz mit Info aus allen Wellen dazu
merge 1:1 mergeid using $out\wohnort.dta, gen(wohn_mer)
drop if wohn_mer!=3
drop wohn_mer


************************
* SELECTION 1: nur HH mit Kindern behalten
************************

*** Anzahl Kinder HH
* ab 11. Kind werden Kinder ignoriert (sowieso kaum jemand)
gen nKind= ch001_ 
label var nKind "Anzahl Kinder/ Haushalt"
label value nKind nKind
recode nKind (-2/-1=.)
tab nKind, m

* nur Haushalte behalten, die Ã¼berhaupt Kinder haben
keep if nKind>0
drop if nKind==.
tab nKind, m

* alle mit mehr als 8 Kindern raus 
drop if nKind >8

* wie viele Kinder pro Haushalt leben zu hause?
clonevar var1=ch007_1
clonevar var2=ch007_2
clonevar var3=ch007_3
clonevar var4=ch007_4
clonevar var5=ch007_5
clonevar var6=ch007_6
clonevar var7=ch007_7
clonevar var8=ch007_8

recode var* (1/2=1) (3/9=0) (-2/-1=.)
label def var 1  "child lives with parents" 0 "child doesnt live with parents"
label val var* var

gen nkidshome= var1 + var2 + var3 + var4 + var5 + var6 + var7 + var8
drop var*

* Doppelte FÃ¤lle raus
sort hhid6
quietly by hhid6: gen dup= cond(_N==1,0,_n)
tab dup
keep if dup<2
drop dup

*speichern im Haushaltsformat (fÃ¼r andere Datenteile)
saveold $out\HHchild.dta, replace  



***********
*Bildungsinfos dazu

merge 1:1 hhid6 using $out\Isced_child.dta, gen(isced_m)
drop isced_m



************************
* Jedes Kind 1 Episode
************************

*** Anzahl Datenzeilen pro HH entsprechend Anzahl Kindern in HH
* jetzt hat jeder Haushalt so viele Datenblöcke wie Kinder
gen Kzahl= nKind
tab Kzahl, m
expand Kzahl
drop Kzahl

* Spell fÃ¼r Kinder
bysort mergeid: gen Kspell= _n

drop if Kspell >8


*** Geschlecht Eltern dranmatchen
*merge m:1 mergeid using $out\demographics_IND.dta, keepusing(mergeid eltern) gen(eltern_m)
*keep if eltern_m==3
*drop eltern_m mergeid 

*** Geschlecht Kind
gen Ksex=0
replace Ksex=ch005_1 if Kspell==1
replace Ksex=ch005_2 if Kspell==2
replace Ksex=ch005_3 if Kspell==3
replace Ksex=ch005_4 if Kspell==4
replace Ksex=ch005_5 if Kspell==5
replace Ksex=ch005_6 if Kspell==6
replace Ksex=ch005_7 if Kspell==7
replace Ksex=ch005_8 if Kspell==8

recode Ksex(-2/-1=.)
label var Ksex "Geschlecht Kind"
label define Ksex 1 "Male" 2 "Female"
label value Ksex Ksex
tab Ksex, m
drop ch005*

*** Geburtsjahr Kind
gen Kgebj=0
replace Kgebj=ch006_1 if Kspell==1
replace Kgebj=ch006_2 if Kspell==2
replace Kgebj=ch006_3 if Kspell==3
replace Kgebj=ch006_4 if Kspell==4
replace Kgebj=ch006_5 if Kspell==5
replace Kgebj=ch006_6 if Kspell==6
replace Kgebj=ch006_7 if Kspell==7
replace Kgebj=ch006_8 if Kspell==8

recode Kgebj (-2/-1=.)
label var Kgebj "Geburtsjahr Kind"
label value Kgebj Kgebj
tab Kgebj, m

*** Alter Kind
gen Kalter= int_year - Kgebj
recode Kalter (-2/0=0) (83/136=83) (2015=.) // Negative auf 0, 95%- Grenze für hohes Alter
tab Kalter, m

*** Wohnort Kind

gen Kwohn=.

* zu Hause
** nach Auszugsjahr
replace Kwohn=1 if (Kspell==1 & ch015_1==2999)
replace Kwohn=1 if (Kspell==2 & ch015_2==2999)
replace Kwohn=1 if (Kspell==3 & ch015_3==2999)
replace Kwohn=1 if (Kspell==4 & ch015_4==2999)
replace Kwohn=1 if (Kspell==5 & ch015_5==2999)
replace Kwohn=1 if (Kspell==6 & ch015_6==2999)
replace Kwohn=1 if (Kspell==7 & ch015_7==2999)
replace Kwohn=1 if (Kspell==8 & ch015_8==2999)

** nach Wohnort
replace Kwohn=1 if (Kspell==1 & (ch007_1==1 | ch007_1==2))
replace Kwohn=1 if (Kspell==2 & (ch007_2==1 | ch007_2==2))
replace Kwohn=1 if (Kspell==3 & (ch007_3==1 | ch007_3==2))
replace Kwohn=1 if (Kspell==4 & (ch007_4==1 | ch007_4==2))
replace Kwohn=1 if (Kspell==5 & (ch007_5==1 | ch007_5==2))
replace Kwohn=1 if (Kspell==6 & (ch007_6==1 | ch007_6==2))
replace Kwohn=1 if (Kspell==7 & (ch007_7==1 | ch007_7==2))
replace Kwohn=1 if (Kspell==8 & (ch007_8==1 | ch007_8==2))

* nicht zu Hause
** nach Auszugsjahr
*** Dont know auf Ausgezogen, refusal auf missing
recode ch015_1 (-2=.)
recode ch015_2 (-2=.)
recode ch015_3 (-2=.)
recode ch015_4 (-2=.)
recode ch015_5 (-2=.)
recode ch015_6 (-2=.)
recode ch015_7 (-2=.)
recode ch015_8 (-2=.)

replace Kwohn=0 if (Kspell==1 & ch015_1<2999)
replace Kwohn=0 if (Kspell==2 & ch015_2<2999)
replace Kwohn=0 if (Kspell==3 & ch015_3<2999)
replace Kwohn=0 if (Kspell==4 & ch015_4<2999)
replace Kwohn=0 if (Kspell==5 & ch015_5<2999)
replace Kwohn=0 if (Kspell==6 & ch015_6<2999)
replace Kwohn=0 if (Kspell==7 & ch015_7<2999)
replace Kwohn=0 if (Kspell==8 & ch015_8<2999)

** nach Wohnort
replace Kwohn=0 if (Kspell==1 & (ch007_1>2 & ch007_1<9))
replace Kwohn=0 if (Kspell==2 & (ch007_2>2 & ch007_2<9))
replace Kwohn=0 if (Kspell==3 & (ch007_3>2 & ch007_3<9))
replace Kwohn=0 if (Kspell==4 & (ch007_4>2 & ch007_4<9))
replace Kwohn=0 if (Kspell==5 & (ch007_5>2 & ch007_5<9))
replace Kwohn=0 if (Kspell==6 & (ch007_6>2 & ch007_6<9))
replace Kwohn=0 if (Kspell==7 & (ch007_7>2 & ch007_7<9))
replace Kwohn=0 if (Kspell==8 & (ch007_8>2 & ch007_8<9))


label var Kwohn "Wohnort Kind"
label define Kwohn 0 "not with parents" 1 "with parents", replace
label value Kwohn Kwohn
tab Kwohn, m

* Missings weg ( 44%!!)
drop if Kwohn==.
rename Kwohn Kcohab
tab Kcohab, m

***
*** Andere erwachsene Kinder zu hause
tab ch007_1, m
recode ch007* (-2=.) (1/2=1) (3/10=0) (-1=0)
tab ch007_1, m
tab ch015_1, m
recode ch015* (-1=0) (-2=.) (0/2998=0) (2999=1) 
tab ch015_1, m

gen Ch0715_1=.
replace Ch0715_1=1 if ch007_1==1 | ch015_1==1
replace Ch0715_1=0 if ch007_1==0 | ch015_1==0
gen Ch0715_2=.
replace Ch0715_2=1 if ch007_2==1 | ch015_2==1
replace Ch0715_2=0 if ch007_2==0 | ch015_2==0
gen Ch0715_3=.
replace Ch0715_3=1 if ch007_3==1 | ch015_3==1 
replace Ch0715_3=0 if ch007_3==0 | ch015_3==0
gen Ch0715_4=.
replace Ch0715_4=1 if ch007_4==1 | ch015_4==1
replace Ch0715_4=0 if ch007_4==0 | ch015_4==0
gen Ch0715_5=.
replace Ch0715_5=1 if ch007_5==1 | ch015_5==1
replace Ch0715_5=0 if ch007_5==0 | ch015_5==0
gen Ch0715_6=.
replace Ch0715_6=1 if ch007_6==1 | ch015_6==1
replace Ch0715_6=0 if ch007_6==0 | ch015_6==0
gen Ch0715_7=.
replace Ch0715_7=1 if ch007_7==1 | ch015_7==1
replace Ch0715_7=0 if ch007_7==0 | ch015_7==0
gen Ch0715_8=.
replace Ch0715_8=1 if ch007_8==1 | ch015_8==1
replace Ch0715_8=0 if ch007_8==0 | ch015_8==0

tab Ch0715_1, m

egen Countkids=rowtotal(Ch0715_1 - Ch0715_8)
label var Countkids "Anzahl Kinder in Elternhaushalt gesamt (inkl. cohab ya's)"

*gen otherkids= Countkids
*replace otherkids= Countkids - 1 if Kcohab==1
*label var otherkids "Anzahl anderer Kinder in Elternhaushalt (ohne beobachteter ya's, wenn cohab)" 
*tab otherkids, m

// Unter 20-Jährige bei Eltern
gen Kid_1=.
replace Kid_1=1 if Ch0715_1==1 & (int_year - ch006_1<19)
gen Kid_2=.
replace Kid_2=1 if Ch0715_2==1 & (int_year - ch006_2<19)
gen Kid_3=.
replace Kid_3=1 if Ch0715_3==1 & (int_year - ch006_3<19)
gen Kid_4=.
replace Kid_4=1 if Ch0715_4==1 & (int_year - ch006_4<19)
gen Kid_5=.
replace Kid_5=1 if Ch0715_5==1 & (int_year - ch006_5<19)
gen Kid_6=.
replace Kid_6=1 if Ch0715_6==1 & (int_year - ch006_6<19)
gen Kid_7=.
replace Kid_7=1 if Ch0715_7==1 & (int_year - ch006_7<19)
gen Kid_8=.
replace Kid_8=1 if Ch0715_8==1 & (int_year - ch006_8<19)

egen Countbaby=rowtotal(Kid_1 - Kid_8)
label var Countbaby "Children up to age 18 at home"
tab Countbaby, m

// andere Young Adults
gen ya_1=.
replace ya_1=1 if Ch0715_1==1 & (int_year - ch006_1>19) & (int_year - ch006_1<36)
gen ya_2=.
replace ya_2=1 if Ch0715_1==1 & (int_year - ch006_2>19) & (int_year - ch006_2<36)
gen ya_3=.
replace ya_3=1 if Ch0715_1==1 & (int_year - ch006_3>19) & (int_year - ch006_3<36)
gen ya_4=.
replace ya_4=1 if Ch0715_1==1 & (int_year - ch006_4>19) & (int_year - ch006_4<36)
gen ya_5=.
replace ya_5=1 if Ch0715_1==1 & (int_year - ch006_5>19) & (int_year - ch006_5<36)
gen ya_6=.
replace ya_6=1 if Ch0715_1==1 & (int_year - ch006_6>19) & (int_year - ch006_6<36)
gen ya_7=.
replace ya_7=1 if Ch0715_1==1 & (int_year - ch006_7>19) & (int_year - ch006_7<36)
gen ya_8=.
replace ya_8=1 if Ch0715_1==1 & (int_year - ch006_8>19) & (int_year - ch006_8<36)

egen Countya=rowtotal(ya_1 - ya_8)
label var Countya "All Children 20-35 at home"
tab Countya, m

gen otherya= Countya
replace otherya= Countkids - 1 if Kspell==1 & Ch0715_1==1
replace otherya= Countkids - 1 if Kspell==2 & Ch0715_2==1
replace otherya= Countkids - 1 if Kspell==3 & Ch0715_3==1
replace otherya= Countkids - 1 if Kspell==4 & Ch0715_4==1
replace otherya= Countkids - 1 if Kspell==5 & Ch0715_5==1
replace otherya= Countkids - 1 if Kspell==6 & Ch0715_6==1
replace otherya= Countkids - 1 if Kspell==7 & Ch0715_7==1
replace otherya= Countkids - 1 if Kspell==8 & Ch0715_8==1
drop Ch07* 

drop ch006* Kid_* ch015* ch007*

***
* wir wissen hier nicht wer einzelkind ist und bei wem einfach keine geschwister zuhause wohnen!!!
***

*** Ehestatus Kind
gen Kmar=0
replace Kmar=ch012_1 if Kspell==1
replace Kmar=ch012_2 if Kspell==2
replace Kmar=ch012_3 if Kspell==3
replace Kmar=ch012_4 if Kspell==4
replace Kmar=ch012_5 if Kspell==5
replace Kmar=ch012_6 if Kspell==6
replace Kmar=ch012_7 if Kspell==7
replace Kmar=ch012_8 if Kspell==8

recode Kmar (-2/-1=.)
label var Kmar "Marriage status Kind"
label define Kmar 1"Married, living with spouse" 2"Registered partnership" /*
*/ 3"Married, living seperated" 4"never married" 5"divorced" 6"widowed" 7"not married, partner", replace
label val Kmar Kmar
tab Kmar, m
drop ch012*

*** Partnerstatus Kind

***
***
***
***
gen Kpar=0
replace Kpar=ch013_1 if Kspell==1
replace Kpar=ch013_2 if Kspell==2
replace Kpar=ch013_3 if Kspell==3
replace Kpar=ch013_4 if Kspell==4
replace Kpar=ch013_5 if Kspell==5
replace Kpar=ch013_6 if Kspell==6
replace Kpar=ch013_7 if Kspell==7
replace Kpar=ch013_8 if Kspell==8

recode Kpar (-2/-1=.) (5=0)
label var Kpar "Partner status child"
label define Kpar 0"no partner" 1"partner"
label val Kpar Kpar
tab Kpar, m
drop ch013*

replace Kmar=7 if Kpar==1
lab val Kmar Kmar
drop Kpar

*** Kinderzahl Kind
gen Kkind=0
replace Kkind=ch019_1 if Kspell==1
replace Kkind=ch019_2 if Kspell==2
replace Kkind=ch019_3 if Kspell==3
replace Kkind=ch019_4 if Kspell==4
replace Kkind=ch019_5 if Kspell==5
replace Kkind=ch019_6 if Kspell==6
replace Kkind=ch019_7 if Kspell==7
replace Kkind=ch019_8 if Kspell==8

recode Kkind (-2/-1=.)
label var Kkind "Number of children Kind"
label val Kkind Kkind
tab Kkind, m
recode Kkind (4/23=4)
label define Kkind 0 "keine Kinder" 1 "1 Kind" 2 "2 Kinder" 3 "3 Kinder" /*
*/ 4 "4 und mehr Kinder" 
tab Kkind, m
drop ch019*

*** Wie wohnt Kind?

***

gen Kliving=0
replace Kliving=4 if Kcohab==0 
replace Kliving=3 if Kmar==7
replace Kliving=2 if Kmar==1
replace Kliving=1 if Kcohab==1 

label var Kliving "Living situation child"
label def Kliving 1 "Child lives with parents" 2"child lives with spouse" /*
*/ 3"child lives with partner" 4 "child lives out of parents home (no partner info)"

label val Kliving Kliving
tab Kliving

*** Lifecycle Kind
gen Kycle=.
replace Kycle=0 if (Kmar==4 | Kmar==5 | Kmar==6) & Kkind==0
replace Kycle=1 if (Kmar==4 | Kmar==5 | Kmar==6) & Kkind>0 & Kkind<5
replace Kycle=2 if (Kmar==1 | Kmar==2 | Kmar==3) & Kkind==0
replace Kycle=3 if (Kmar==1 | Kmar==2 | Kmar==3) & Kkind>0 & Kkind<5 
recode Kycle (.=4)

label var Kycle "Lifecycle Child"

label def Kycle 0 "unmarried, no children" 1 "unmarried, children" /*
*/ 2 "married, no children"  3 "married, children" /*
*/ 4 "incomplete/ no information"

label val Kycle Kycle
tab Kycle, m

*** Bildung Kind
gen Keduc=0
replace Keduc=isced_c1 if Kspell==1
replace Keduc=isced_c2 if Kspell==2
replace Keduc=isced_c3 if Kspell==3
replace Keduc=isced_c4 if Kspell==4
replace Keduc=isced_c5 if Kspell==5
replace Keduc=isced_c6 if Kspell==6
replace Keduc=isced_c7 if Kspell==7
replace Keduc=isced_c8 if Kspell==8

label var Keduc "Educational level child (ISCED)"
recode Keduc (. 0=6) (5/6=5)
label def Keduc 6 "level of education unknown" 1 "(pre-) primary education" /*
*/2 "lower secondary education" /*
*/ 3 "upper secondary education" 4 "post-secondary non-tertiary education" /*
*/ 5 "tertiary education", replace
label val Keduc Keduc
tab Keduc, m
drop isced_c*

*** Kontakt Kind //
gen Kkon=0
replace Kkon=ch014_1 if Kspell==1
replace Kkon=ch014_2 if Kspell==2
replace Kkon=ch014_3 if Kspell==3
replace Kkon=ch014_4 if Kspell==4
replace Kkon=ch014_5 if Kspell==5
replace Kkon=ch014_6 if Kspell==6
replace Kkon=ch014_7 if Kspell==7
replace Kkon=ch014_8 if Kspell==8

recode Kkon (-2/-1=.)
label var Kkon "Kontact obs. parents-child"
label define Kkon 1"Daily" 2"Several times a week" 3"About once a week" /*
*/4"About every 2 weeks" 5"Abouth 1/month" 6"Less than 1/month" 7"Never"
label val Kkon Kkon
tab Kkon, m
drop ch014*


*** Beschäftigungsstatus Kind
gen Kjob=0
replace Kjob=ch016_1 if Kspell==1
replace Kjob=ch016_2 if Kspell==2
replace Kjob=ch016_3 if Kspell==3
replace Kjob=ch016_4 if Kspell==4
replace Kjob=ch016_5 if Kspell==5
replace Kjob=ch016_6 if Kspell==6
replace Kjob=ch016_7 if Kspell==7
replace Kjob=ch016_8 if Kspell==8

recode Kjob (-2/-1=.)
label var Kjob "Employment status child"
label define Kjob 1"Full-time employed" 2"Part-time employed" /*
*/ 3"self employed/ working for own family" 4"unemployed" /*
*/ 5"vocational training/ retraining/ education" 6"Parental leave" /*
*/ 7"(early) retirement" 8"permanently sick/ disabled" /*
*/ 9"looking after home/ family" 50"Mandatory military service" 97"Other"
label val Kjob Kjob
tab Kjob, m
drop ch016*

gen Kop=Kjob
recode Kop(6 9=6) (7 50 97=7)

label var Kop "Occupational status child"
label def Kop 1 "Full-time employed" /*
*/ 2 "Part-time employed" 3 "self employed/ working for own family" 4 "unemployed" /*
*/ 5 "vocational training/ retraining/ education" /*
*/6 "Parental leave, looking after home/ family" 7 "other" 8"permanently sick/ diasbled"
label val Kop Kop


*** Verhältnis Kind zu Befragten Eltern
** Variablen: 
*ch108 foster child, 
*ch107 adopted child of spouse,
*ch106 adopted child of resp., 
*ch105 child of former rel. of spouse, 
*ch104 child of former rel. resp., 
*ch103 natural child spouse/partner, 
*ch102 natural child respondent 

***
***
***

gen parstatus=.
* Natural child of one/ both parents
replace parstatus=1 if ch303d1==1 & Kspell==1
replace parstatus=1 if ch303d2==1 & Kspell==2
replace parstatus=1 if ch303d3==1 & Kspell==3
replace parstatus=1 if ch303d4==1 & Kspell==4
replace parstatus=1 if ch303d5==1 & Kspell==5
replace parstatus=1 if ch303d6==1 & Kspell==6
replace parstatus=1 if ch303d7==1 & Kspell==7
replace parstatus=1 if ch303d8==1 & Kspell==8

replace parstatus=1 if ch302_==1

* Natural child one partner but not other
replace parstatus=1 if (ch104_1==1 | ch105_1==1) & Kspell==1 
replace parstatus=1 if (ch104_2==1 | ch105_2==1) & Kspell==2 
replace parstatus=1 if (ch104_3==1 | ch105_3==1) & Kspell==3 
replace parstatus=1 if (ch104_4==1 | ch105_4==1) & Kspell==4 
replace parstatus=1 if (ch104_5==1 | ch105_5==1) & Kspell==5 
replace parstatus=1 if (ch104_6==1 | ch105_6==1) & Kspell==6 
replace parstatus=1 if (ch104_7==1 | ch105_7==1) & Kspell==7 
replace parstatus=1 if (ch104_8==1 | ch105_8==1) & Kspell==8 

* Foster/ Adoptive child of one or both 
replace parstatus=2 if (ch106_1==1 | ch107_1==1 | ch108_1==1)& Kspell==1
replace parstatus=2 if (ch106_2==1 | ch107_2==1 | ch108_2==1)& Kspell==2
replace parstatus=2 if (ch106_3==1 | ch107_3==1 | ch108_3==1)& Kspell==3
replace parstatus=2 if (ch106_4==1 | ch107_4==1 | ch108_4==1)& Kspell==4
replace parstatus=2 if (ch106_5==1 | ch107_5==1 | ch108_5==1)& Kspell==5
replace parstatus=2 if (ch106_6==1 | ch107_6==1 | ch108_6==1)& Kspell==6
replace parstatus=2 if (ch106_7==1 | ch107_7==1 | ch108_7==1)& Kspell==7
replace parstatus=2 if (ch106_8==1 | ch107_8==1 | ch108_8==1)& Kspell==8


label def parstatus 1 "child of one/both parents" 2 "Foster/ adoptive child", replace
label val parstatus parstatus
label var parstatus "Parentship status"
tab parstatus, m

***DATENSATZ SPEICHERN
saveold $out\children6.dta, replace  



