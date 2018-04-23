*******************************
******* Datenmanagement *******
********** Children ***********

version 13
clear all
set more off, perm
set linesize 80
capture log close

* Master Do-File
do "C:\Users\Julia\Documents\Studium\M.A.Soziologie\5.Semester\Masterarbeit\Methods-Publikation\Do-Files\1.Master.do"

* LOG-Datei
capture log close
log using $log\Children6.log, replace

/* Ziel: Info über Kinder: Wohnort, Beziehungsstatus, 
Ausbildungs- & Erwerbsstatus, Beziehung mit Eltern, letzter Auszug */

use $SHARE\sharew6_rel6-1-0_ALL_datasets_stata/sharew6_rel6-1-0_ch.dta, clear
sort mergeid
keep mergeid coupleid6 hhid6 ch001_ ch005_1-ch005_8  ch006_1-ch006_8 /*
*/ ch007_1-ch007_8 ch012_1-ch012_8 ch013_1-ch013_8 /*
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

* nur Haushalte behalten, die überhaupt Kinder haben
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

* Doppelte Fälle raus
sort hhid6
quietly by hhid6: gen dup= cond(_N==1,0,_n)
tab dup
keep if dup<2
drop dup

*speichern im Haushaltsformat (für andere Datenteile)
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

* Spell für Kinder
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

// Unter 18-Jährige bei Eltern
gen Kid_1=.
replace Kid_1=1 if Ch0715_1==1 & (int_year - ch006_1<18)
gen Kid_2=.
replace Kid_2=1 if Ch0715_2==1 & (int_year - ch006_2<18)
gen Kid_3=.
replace Kid_3=1 if Ch0715_3==1 & (int_year - ch006_3<18)
gen Kid_4=.
replace Kid_4=1 if Ch0715_4==1 & (int_year - ch006_4<18)
gen Kid_5=.
replace Kid_5=1 if Ch0715_5==1 & (int_year - ch006_5<18)
gen Kid_6=.
replace Kid_6=1 if Ch0715_6==1 & (int_year - ch006_6<18)
gen Kid_7=.
replace Kid_7=1 if Ch0715_7==1 & (int_year - ch006_7<18)
gen Kid_8=.
replace Kid_8=1 if Ch0715_8==1 & (int_year - ch006_8<18)

egen Countbaby=rowtotal(Kid_1 - Kid_8)
label var Countbaby "Children up to age 17 at home"
tab Countbaby, m

// andere Young Adults
gen ya_1=.
replace ya_1=1 if Ch0715_1==1 & (int_year - ch006_1>19) & (int_year - ch006_1<40)
gen ya_2=.
replace ya_2=1 if Ch0715_1==1 & (int_year - ch006_2>19) & (int_year - ch006_2<40)
gen ya_3=.
replace ya_3=1 if Ch0715_1==1 & (int_year - ch006_3>19) & (int_year - ch006_3<40)
gen ya_4=.
replace ya_4=1 if Ch0715_1==1 & (int_year - ch006_4>19) & (int_year - ch006_4<40)
gen ya_5=.
replace ya_5=1 if Ch0715_1==1 & (int_year - ch006_5>19) & (int_year - ch006_5<40)
gen ya_6=.
replace ya_6=1 if Ch0715_1==1 & (int_year - ch006_6>19) & (int_year - ch006_6<40)
gen ya_7=.
replace ya_7=1 if Ch0715_1==1 & (int_year - ch006_7>19) & (int_year - ch006_7<40)
gen ya_8=.
replace ya_8=1 if Ch0715_1==1 & (int_year - ch006_8>19) & (int_year - ch006_8<40)

egen Countya=rowtotal(ya_1 - ya_8)
label var Countya "All Children 20-39 at home"
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
* wir wissen hier nicht wer einzelkind ist und bei wem einfach keine gewschwister zuhause wohnen!!!
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



