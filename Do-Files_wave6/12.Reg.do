*******************************
****** Regressionsanalyse *****
*******************************

version 13
clear all
set more off, perm
set linesize 80
capture log close


* Master Do-File
do "C:\Users\Julia\Documents\GitHub\Solidaritaet\Do-Files_wave6\1.Master.do"
*do "C:\Users\Isy\Documents\GitHub\Solidaritaet\Do-Files_wave6\1.Master.do"

do $do\9.CH+P+M.do
*do $do\10.Macro.do


use $out\sample.dta


***
*relevante Variablen
***

// Kinder
/*
Geschlecht: Ksex
Alter: Kalter
Life cycle: Kycle
Education: Keduc
Job: Kop
*/

/*
Partnership status: partner
Education level: xisced (basis: primary education)
Geschwister da: Countbaby (unter 18), otherya (18-35)
Andere Familie da: Famhome
Alter: Xalter
Gesundheit: xhealth
Income: incprct
Migration: migr
Support: support
Anzahl Kinder: nKind

// Kinder
Geschlecht: Ksex 
Alter: Kalter 
Life cycle: Kycle 
Education: Keduc 
Occupational status: Kop (Basis: Full-time employed)

*/


// Variance components model
*melogit Kcohab, ||country:  || hhid5: // Berechnen ICC:
*melogit Kcohab, || hhid5:  // Berechnen ICC:




recode Ksex (1 = 0) (2 = 1)
label def Ksex 1 "Female" 0 "Male", replace



******
***
* Modelle
***
******


/* 1. Nur Kinder
logit Kcohab i.Ksex c.Kalter i.Kycle i.Keduc i.Kop, or vce(cluster hhid6)
fitstat

melogit Kcohab i.Ksex Kalter i.Kycle i.Keduc i.Kop || hhid6:, or
estimates store m1

*2. mit Haushalt
melogit Kcohab i.Ksex c.Kalter i.Kycle i.Keduc i.Kop /*
*/ i.Countbaby i.otherya  || hhid6:, or
estimates store m2 */

*3. mit Eltern-Charakteristika
melogit Kcohab i.support i.Ksex c.Kalter i.Kycle i.Keduc i.Kop /*
*/ c.Countbaby c.otherya  /*
*/ i.incprct i.isced_p1 i.isced_p2 c.xalter i.migr1 i.migr2  || hhid6:, or
estimates store m3

/*4. mit Macro
melogit Kcohab i.Ksex c.Kalter i.Kycle i.Keduc i.Kop /*
*/ c.Countbaby c.otherya /*
*/ i.incprct helpanteilvater helpanteilmutter i.xisced c.xalter i.migration /*
*/ fam_exp|| hhid6:, or
estimates store m4

melogit Kcohab i.Ksex c.Kalter i.Kycle i.Keduc i.Kop /*
*/ c.Countbaby c.otherya /*
*/ i.incprct helpanteilvater helpanteilmutter i.xisced c.xalter i.migration /*
*/ unemp || hhid6:, or
estimates store m5

melogit Kcohab i.Ksex c.Kalter i.Kycle i.Keduc i.Kop /*
*/ c.Countbaby c.otherya  /*
*/ i.incprct i.futkat helpanteilvater helpanteilmutter i.xisced c.xalter i.migration /*
*/ oldage_exp || hhid6:, or
estimates store m6 */




outreg2 [m3] using cohab.doc, replace



lrtest m1 m2, stats
lrtest m2 m3, stats
lrtest m3 m4, stats

// Variance components model
melogit Kcohab, ||country:  || hhid6: // Berechnen ICC:
melogit Kcohab, || hhid6:  // Berechnen ICC:





*Generate Predicted Probabilities

logit Kcohab helpanteilmutter Countkids
estimate store test

*For 0 support
mgen, 		at(Countkids=(0(1)6) helpanteilmutter=0) atmeans stub(zero)
*For 1 support
mgen, 		at(Countkids=(0(1)6) helpanteilmutter=1) atmeans stub(one)
*For 2 support
mgen, 		at(Countkids=(0(1)6) helpanteilmutter=2) atmeans stub(two)
*For 2 support
mgen, 		at(Countkids=(0(1)6) helpanteilmutter=3) atmeans stub(three)

lab var zeropr1 "No child supp."
lab var onepr1  "1 child supp."
lab var twopr1  "2 children supp."
lab var threepr1 "Three children supp."

*With Confidence Intervals 	
graph twoway ///
	(rarea zeroul1 zeroll1 zeroCountkids, col(gs10)) ///
	(rarea oneul1 onell1 oneCountkids, col(gs10)) ///
	(rarea twoul1 twoll1 twoCountkids, col(gs10)) ///
	(rarea threeul1 threell1 threeCountkids, col(gs10)) ///
	(connected zeropr1 onepr1 twopr1 threepr1 oneCountkids, ///
	lwid(medium medium) msize(vlarge vlarge vlarge) ///
	msym(d s) mcol(red blue) lcol(red blue)), ///
	title("Predicted Probabilites of Intergenerational Cohabitation" /// 
	"by Mother Support and Number of children") ///
	ytitle("Probability of intergenerational cohabitation") ylab() /// 
	xtitle("Number of children") ///
	xlab(0(1)5) caption(`tag', size(small)) ///
	legend(order(2 3 4))

	graph export a06-PrKcohab-CI.emf, replace

 
 

logit Kcohab i.Ksex c.Kalter i.Kycle i.Keduc i.Kop /*
*/ c.Countkids /*
*/ i.incprct support i.Keduc c.xalter i.migr /*
*/ fam_exp
estimate store test

*For 0 support
mgen, 		at(Countkids=(0(1)6) helpanteilmutter=0) atmeans stub(zero)
*For 1 support
mgen, 		at(Countkids=(0(1)6) helpanteilmutter=1) atmeans stub(one)
*For 2 support
mgen, 		at(Countkids=(0(1)6) helpanteilmutter=2) atmeans stub(two)
*For 2 support
mgen, 		at(Countkids=(0(1)6) helpanteilmutter=3) atmeans stub(three)

lab var zeropr1 "No child supp."
lab var onepr1  "1 child supp."
lab var twopr1  "2 children supp."
lab var threepr1 "3 children supp."

* Without CI
graph twoway ///
	(connected zeropr1 onepr1 twopr1 threepr1 oneCountkids, ///
	lwid(medium medium) msize(vlarge vlarge vlarge) ///
	msym(d s) mcol(red blue) lcol(red blue)), ///
	title("Predicted Probabilites of Intergenerational Cohabitation" /// 
	"by Mother Support and Number of children") ///
	ytitle("Probability of intergenerational cohabitation") ylab() /// 
	xtitle("Number of children") ///
	xlab(0(1)6) caption(`tag', size(small)) ///
	legend(order(1 2 3 4))
 
 
