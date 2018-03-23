*******************************
******* Datenmanagement *******
********** Children ***********

version 13
clear all
set more off, perm
set linesize 80
capture log close

* Master Do-File
do "C:\Users\Julia\Documents\Studium\M.A.Soziologie\5.Semester\Masterarbeit\Methods\Do-Files\Master.do"

* LOG-Datei
capture log close
log using $log\Children5.log, replace

/* Ziel: Info über Kinder Welle 4: Wohnort, Beziehungsstatus, 
Ausbildungs- & Erwerbsstatus, Beziehung mit Eltern, letzter Auszug */

use $SHARE\sharew5_rel6-0-0_ALL_datasets_stata/sharew5_rel6-0-0_ch.dta, clear
sort mergeid
keep mergeid coupleid5 hhid5 ch001_ ch005_1-ch005_8  ch006_1-ch006_8 /*
*/ ch007_1-ch007_8 ch012_1-ch012_8 ch013_1-ch013_8 /*
*/ ch014_1-ch014_8 ch015_1-ch015_8 ch016_1-ch016_8 ch019_1-ch019_8 /*
*/ ch002_1-ch002_8 ch010_1-ch010_8 ch011_1-ch011_8

* Missing kodieren
do $do\sharetom5.ado
numlabel _all, add

*** Family respondent, Land & Interviewjahr dranmatchen 
merge 1:1 mergeid using $SHARE\sharew5_rel6-0-0_ALL_datasets_stata/sharew5_rel6-0-0_cv_r.dta, /*
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

recode var* (1/2=1) (3/9=0) (-10/-1=0) (.=0)
label def var 1  "child lives with parents" 0 "all other (missing, no child, child not at home)"
label val var* var

gen nkidshome= var1 + var2 + var3 + var4 + var5 + var6 + var7 + var8
drop var*

* Doppelte Fälle raus
sort hhid5
quietly by hhid5: gen dup= cond(_N==1,0,_n)
tab dup
keep if dup<2
drop dup

*speichern im Haushaltsformat (für andere Datenteile)
saveold $out\HHchild.dta, replace  



***********
*Bildungsinfos dazu

merge 1:1 hhid5 using $out\Isced_child.dta, gen(isced_m)
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
merge m:1 mergeid using $out\demographics_IND.dta, keepusing(mergeid eltern) gen(eltern_m)
keep if eltern_m==3
drop eltern_m mergeid 

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
recode Kalter (-2/0=0) (83/136=83) // Negative auf 0, 95%- Grenze für hohes Alter
tab Kalter, m

gen Kalsq=Kalter*Kalter

gen Kalterfirstborn= int_year - ch006_1

*** Wohnort Kind
// zu viele Missings!! woher???

gen Kwohn=0
replace Kwohn=ch007_1 if Kspell==1
replace Kwohn=ch007_2 if Kspell==2
replace Kwohn=ch007_3 if Kspell==3
replace Kwohn=ch007_4 if Kspell==4
replace Kwohn=ch007_5 if Kspell==5
replace Kwohn=ch007_6 if Kspell==6
replace Kwohn=ch007_7 if Kspell==7
replace Kwohn=ch007_8 if Kspell==8

replace Kwohn=1 if (Kspell==1 & ch015_1==2999)
replace Kwohn=1 if (Kspell==2 & ch015_2==2999)
replace Kwohn=1 if (Kspell==3 & ch015_3==2999)
replace Kwohn=1 if (Kspell==4 & ch015_4==2999)
replace Kwohn=1 if (Kspell==5 & ch015_5==2999)
replace Kwohn=1 if (Kspell==6 & ch015_6==2999)
replace Kwohn=1 if (Kspell==7 & ch015_7==2999)
replace Kwohn=1 if (Kspell==8 & ch015_8==2999)

recode Kwohn (-2/-1=.)(3/4=3)(5/6=4) (7=5) (8=6)
label var Kwohn "Wohnort Kind"
label define Kwohn 1"same HH" 2"same building" 3"less than 5km away" /*
*/ 4"5-100 km away" 5"100-500 km away" 6 "more than 500 km away"
label value Kwohn Kwohn
tab Kwohn, m

*** für Regression
gen Kcohab=.
replace Kcohab=1 if Kwohn==1 | Kwohn==2
replace Kcohab=0 if Kwohn==3 | Kwohn==4 | Kwohn==5
tab Kcohab, m

*** Auszugsjahr Kind
gen moveout=0
replace moveout=ch015_1 if Kspell==1
replace moveout=ch015_2 if Kspell==2
replace moveout=ch015_3 if Kspell==3
replace moveout=ch015_4 if Kspell==4
replace moveout=ch015_5 if Kspell==5
replace moveout=ch015_6 if Kspell==6
replace moveout=ch015_7 if Kspell==7
replace moveout=ch015_8 if Kspell==8

recode moveout ( -2 -1 2999=.)
label var moveout "Auszugsjahr (nur Ausgezogene)"
tab moveout, m

*** Andere erwachsene Kinder zu hause
tab ch007_1, m
recode ch007* (-2/-1=.) (1/2=1) (3/10=0)
tab ch007_1, m
tab ch015_1, m
recode ch015* (0/2998=0) (2999=1)
tab ch015_1, m

gen Ch0715_1=0
replace Ch0715_1=1 if ch007_1==1 | ch015_1==1
gen Ch0715_2=0
replace Ch0715_2=1 if ch007_2==1 | ch015_2==1
gen Ch0715_3=0
replace Ch0715_3=1 if ch007_3==1 | ch015_3==1 
gen Ch0715_4=0
replace Ch0715_4=1 if ch007_4==1 | ch015_4==1
gen Ch0715_5=0
replace Ch0715_5=1 if ch007_5==1 | ch015_5==1
gen Ch0715_6=0
replace Ch0715_6=1 if ch007_6==1 | ch015_6==1
gen Ch0715_7=0
replace Ch0715_7=1 if ch007_7==1 | ch015_7==1
gen Ch0715_8=0
replace Ch0715_8=1 if ch007_8==1 | ch015_8==1

tab Ch0715_1, m

gen Countkids= Ch0715_1 + Ch0715_2 + Ch0715_3 + Ch0715_4 + /*
*/ Ch0715_5 + Ch0715_6 + Ch0715_7 + Ch0715_8
label var Countkids "Anzahl Kinder in Elternhaushalt gesamt (inkl. cohab ya's)"

gen otherkids= Countkids
replace otherkids= Countkids - 1 if Kspell==1 & Ch0715_1==1
replace otherkids= Countkids - 1 if Kspell==2 & Ch0715_2==1
replace otherkids= Countkids - 1 if Kspell==3 & Ch0715_3==1
replace otherkids= Countkids - 1 if Kspell==4 & Ch0715_4==1
replace otherkids= Countkids - 1 if Kspell==5 & Ch0715_5==1
replace otherkids= Countkids - 1 if Kspell==6 & Ch0715_6==1
replace otherkids= Countkids - 1 if Kspell==7 & Ch0715_7==1
replace otherkids= Countkids - 1 if Kspell==8 & Ch0715_8==1
label var otherkids "Anzahl anderer Kinder in Elternhaushalt (kontrolliert für cohab ya's)" 

// Unter 20-Jährige bei Eltern
gen Kid_1=0
replace Kid_1=1 if (ch007_1==1 | ch015_1==1) & (int_year - ch006_1<20)
gen Kid_2=0
replace Kid_2=1 if (ch007_2==1 | ch015_2==1) & (int_year - ch006_2<20)
gen Kid_3=0
replace Kid_3=1 if (ch007_3==1 | ch015_3==1) & (int_year - ch006_3<20)
gen Kid_4=0
replace Kid_4=1 if (ch007_4==1 | ch015_4==1) & (int_year - ch006_4<20)
gen Kid_5=0
replace Kid_5=1 if (ch007_5==1 | ch015_5==1) & (int_year - ch006_5<20)
gen Kid_6=0
replace Kid_6=1 if (ch007_6==1 | ch015_6==1) & (int_year - ch006_6<20)
gen Kid_7=0
replace Kid_7=1 if (ch007_7==1 | ch015_7==1) & (int_year - ch006_7<20)
gen Kid_8=0
replace Kid_8=1 if (ch007_8==1 | ch015_8==1) & (int_year - ch006_8<20)

gen Countbaby= Kid_1 +  Kid_2 + Kid_3 + Kid_4 + Kid_5 + Kid_6 + Kid_7 + Kid_8
label var Countbaby "Children up to age 19 at home"
tab Countbaby, m

// Anteil andere Young Adults
gen ya_1=0
replace ya_1=1 if (ch007_1==1 | ch015_1==1) & (int_year - ch006_1>19) & (int_year - ch006_1<40)
gen ya_2=0
replace ya_2=1 if (ch007_2==1 | ch015_2==1) & (int_year - ch006_2<19) & (int_year - ch006_2<40)
gen ya_3=0
replace ya_3=1 if (ch007_3==1 | ch015_3==1) & (int_year - ch006_3<19) & (int_year - ch006_3<40)
gen ya_4=0
replace ya_4=1 if (ch007_4==1 | ch015_4==1) & (int_year - ch006_4<19) & (int_year - ch006_4<40)
gen ya_5=0
replace ya_5=1 if (ch007_5==1 | ch015_5==1) & (int_year - ch006_5<19) & (int_year - ch006_5<40)
gen ya_6=0
replace ya_6=1 if (ch007_6==1 | ch015_6==1) & (int_year - ch006_6<19) & (int_year - ch006_6<40)
gen ya_7=0
replace ya_7=1 if (ch007_7==1 | ch015_7==1) & (int_year - ch006_7<19) & (int_year - ch006_7<40)
gen ya_8=0
replace ya_8=1 if (ch007_8==1 | ch015_8==1) & (int_year - ch006_8<19) & (int_year - ch006_8<40)

gen Countya= ya_1 +  ya_2 + ya_3 + ya_4 + ya_5 + ya_6 + ya_7 + ya_8
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

// Anteil ältere Kinder zu hause
gen old_1=0
replace old_1=1 if (ch007_1==1 | ch015_1==1) & (int_year - ch006_1>39) & (int_year - ch006_1<100)
gen old_2=0
replace old_2=1 if (ch007_2==1 | ch015_2==1) & (int_year - ch006_2>39) & (int_year - ch006_2<100)
gen old_3=0
replace old_3=1 if (ch007_3==1 | ch015_3==1) & (int_year - ch006_3>39) & (int_year - ch006_3<100)
gen old_4=0
replace old_4=1 if (ch007_4==1 | ch015_4==1) & (int_year - ch006_4>39) & (int_year - ch006_4<100)
gen old_5=0
replace old_5=1 if (ch007_5==1 | ch015_5==1) & (int_year - ch006_5>39) & (int_year - ch006_5<10)
gen old_6=0
replace old_6=1 if (ch007_6==1 | ch015_6==1) & (int_year - ch006_6>39) & (int_year - ch006_6<10)
gen old_7=0
replace old_7=1 if (ch007_7==1 | ch015_7==1) & (int_year - ch006_7>39) & (int_year - ch006_7<10)
gen old_8=0
replace old_8=1 if (ch007_8==1 | ch015_8==1) & (int_year - ch006_8>39) & (int_year - ch006_8<10)

gen Countold= old_1 +  old_2 + old_3 + old_4 + old_5 + old_6 + old_7 + old_8
label var Countold "Children 40+ at home"
tab Countold, m

drop ch006* Kid_* ch015* ch007*



*** Alter bei Auszug
gen moveage=moveout - Kgebj
recode moveage (-91/-1=.)
tab moveage, m
drop Kgebj moveout


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
*/ 3"Married, living seperated" 4"never married" 5"divorced" 6"widowed"
label val Kmar Kmar
tab Kmar, m
drop ch012*

*** Partnerstatus Kind
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
gen Kliving=0
replace Kliving=4 if Kwohn==3 | Kwohn==4 | Kwohn==5
replace Kliving=3 if Kpar==1
replace Kliving=2 if Kmar==1
replace Kliving=1 if Kwohn==1 | Kwohn==2

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
*/ 4 "uncomplete/ no information"

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
*/2 "lower secundary education" /*
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
*/6 "Parental leave, looking after home/ family" 7 "other"
label val Kop Kop

*** Verhältnis Kind zu Befragten Eltern
gen parstatus=.
* Natural child
replace parstatus=1 if (ch002_1==1 | ch011_1==1) & Kspell==1
replace parstatus=1 if (ch002_2==1 | ch011_2==1)& Kspell==2
replace parstatus=1 if (ch002_3==1 | ch011_3==1)& Kspell==3
replace parstatus=1 if (ch002_4==1 | ch011_4==1)& Kspell==4
replace parstatus=1 if (ch002_5==1 | ch011_5==1)& Kspell==5
replace parstatus=1 if (ch002_6==1 | ch011_6==1)& Kspell==6
replace parstatus=1 if (ch002_7==1 | ch011_7==1)& Kspell==7
replace parstatus=1 if (ch002_8==1 | ch011_8==1)& Kspell==8

* Child of father
replace parstatus=2 if Kspell==1 & eltern==1 & ch011_1==2
replace parstatus=2 if Kspell==2 & eltern==1 & ch011_2==2
replace parstatus=2 if Kspell==3 & eltern==1 & ch011_3==2
replace parstatus=2 if Kspell==4 & eltern==1 & ch011_4==2
replace parstatus=2 if Kspell==5 & eltern==1 & ch011_5==2
replace parstatus=2 if Kspell==6 & eltern==1 & ch011_6==2
replace parstatus=2 if Kspell==7 & eltern==1 & ch011_7==2
replace parstatus=2 if Kspell==8 & eltern==1 & ch011_8==2

replace parstatus=2 if Kspell==1 & eltern==2 & (ch011_1==3 | ch010_1==2)
replace parstatus=2 if Kspell==2 & eltern==2 & (ch011_2==3 | ch010_2==2)
replace parstatus=2 if Kspell==3 & eltern==2 & (ch011_3==3 | ch010_3==2)
replace parstatus=2 if Kspell==4 & eltern==2 & (ch011_4==3 | ch010_4==2)
replace parstatus=2 if Kspell==5 & eltern==2 & (ch011_5==3 | ch010_5==2)
replace parstatus=2 if Kspell==6 & eltern==2 & (ch011_6==3 | ch010_6==2)
replace parstatus=2 if Kspell==7 & eltern==2 & (ch011_7==3 | ch010_7==2)
replace parstatus=2 if Kspell==8 & eltern==2 & (ch011_8==3 | ch010_8==2)

* Child of mother
replace parstatus=3 if Kspell==1 & eltern==2 & ch011_1==2
replace parstatus=3 if Kspell==2 & eltern==2 & ch011_2==2
replace parstatus=3 if Kspell==3 & eltern==2 & ch011_3==2
replace parstatus=3 if Kspell==4 & eltern==2 & ch011_4==2
replace parstatus=3 if Kspell==5 & eltern==2 & ch011_5==2
replace parstatus=3 if Kspell==6 & eltern==2 & ch011_6==2
replace parstatus=3 if Kspell==7 & eltern==2 & ch011_7==2
replace parstatus=3 if Kspell==8 & eltern==2 & ch011_8==2

replace parstatus=3 if Kspell==1 & eltern==1 & (ch011_1==3 | ch010_1==2)
replace parstatus=3 if Kspell==2 & eltern==1 & (ch011_2==3 | ch010_2==2)
replace parstatus=3 if Kspell==3 & eltern==1 & (ch011_3==3 | ch010_3==2)
replace parstatus=3 if Kspell==4 & eltern==1 & (ch011_4==3 | ch010_4==2)
replace parstatus=3 if Kspell==5 & eltern==1 & (ch011_5==3 | ch010_5==2)
replace parstatus=3 if Kspell==6 & eltern==1 & (ch011_6==3 | ch010_6==2)
replace parstatus=3 if Kspell==7 & eltern==1 & (ch011_7==3 | ch010_7==2)
replace parstatus=3 if Kspell==8 & eltern==1 & (ch011_8==3 | ch010_8==2)

* Foster/ Adoptive child
replace parstatus=4 if Kspell==1 & (ch010_1==3 | ch010_1==4 | ch011_1==4 | ch011_1==5)
replace parstatus=4 if Kspell==2 & (ch010_2==3 | ch010_2==4 | ch011_2==4 | ch011_2==5)
replace parstatus=4 if Kspell==3 & (ch010_3==3 | ch010_3==4 | ch011_3==4 | ch011_3==5)
replace parstatus=4 if Kspell==4 & (ch010_4==3 | ch010_4==4 | ch011_4==4 | ch011_4==5)
replace parstatus=4 if Kspell==5 & (ch010_5==3 | ch010_5==4 | ch011_5==4 | ch011_5==5)
replace parstatus=4 if Kspell==6 & (ch010_6==3 | ch010_6==4 | ch011_6==4 | ch011_6==5)
replace parstatus=4 if Kspell==7 & (ch010_7==3 | ch010_7==4 | ch011_7==4 | ch011_7==5)
replace parstatus=4 if Kspell==8 & (ch010_8==3 | ch010_8==4 | ch011_8==4 | ch011_8==5)

label def parstatus 1 "child of parents" 2 "child of father" 3 "child of mother" 4"Foster/ adoptive child"
label val parstatus parstatus
label var parstatus "Parentship status"
tab parstatus, m
drop ch010* ch011* ch002*


***DATENSATZ SPEICHERN
saveold $out\children5.dta, replace  



