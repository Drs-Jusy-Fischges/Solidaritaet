*******************************
****** Regressionsanalyse *****
*******************************

version 14
clear all
set more off, perm
set linesize 80
capture log close


* Master Do-File
*do "C:\Users\Julia\Documents\Studium\M.A.Soziologie\5.Semester\Masterarbeit\Methods\Do-Files\Master.do"
do "C:\Users\Isy\Documents\GitHub\Solidaritaet\Do-Files_wave6\1.Master.do"

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
Groﬂeltern da: Omps 
Geschwister da: Countbaby (unter 18), otherya (20-39), Countold (40+)
Andere Familie da: Famhome
Alter: Xalter
Gesundheit: xhealth
Income: incprct
Migration: migration
Support other Children: octime
Anzahl Kinder: nKind

// Kinder
Geschlecht: Ksex 
Alter: Kalter 
Life cycle: Kycle 
Education: Keduc 
Occupational status: Kop (Basis: Full-time employed)

*/


******
***
* Modelle
***
******


* 1. Nur Kinder
logit Kcohab Ksex Kalter i.Kycle i.Keduc i.Kop, or vce(cluster hhid6)
fitstat

melogit Kcohab Ksex Kalter i.Kycle i.Keduc i.Kop || hhid5:, or
estimates store m1

*2. mit Haushalt
melogit Kcohab Ksex Kalter i.Kycle i.Keduc i.Kop /*
*/ partner i.Countbaby /*
*/|| hhid6:, or
estimates store m2

*3. mit Eltern-Charakteristika
melogit Kcohab Ksex Kalter i.Kycle i.Keduc i.Kop /*
*/ partner i.Countbaby Omps i.otherya i.valueprct /*
*/ i.incprct i.futkat octime partime i.xisced i.xhealth xalter migration /*
*/ kidsout Countold i.Famhome || hhid5:, or
estimates store m3

*4. mit Macro
melogit Kcohab Ksex Kalter i.Kycle i.Keduc i.Kop /*
*/ partner i.Countbaby Omps i.otherya i.valueprct /*
*/ i.incprct i.futkat octime partime i.xisced i.xhealth xalter migration /*
*/ fam_exp/*
*/ kidsout Countold i.Famhome || hhid5:, or
estimates store m4

melogit Kcohab Ksex Kalter i.Kycle i.Keduc i.Kop /*
*/ partner i.Countbaby Omps i.otherya i.valueprct /*
*/ i.incprct i.futkat octime partime i.xisced i.xhealth xalter migration /*
*/ unemp/*
*/ kidsout Countold i.Famhome || hhid5:, or
estimates store m5

melogit Kcohab Ksex Kalter i.Kycle i.Keduc i.Kop /*
*/ partner i.Countbaby Omps i.otherya i.valueprct /*
*/ i.incprct i.futkat octime partime i.xisced i.xhealth xalter migration /*
*/ oldage_exp/*
*/ kidsout Countold i.Famhome || hhid5:, or
estimates store m6


lrtest m1 m2, stats
lrtest m2 m3, stats
lrtest m3 m4, stats

// Variance components model
*melogit Kcohab, ||country:  || hhid5: // Berechnen ICC:
*melogit Kcohab, || hhid5:  // Berechnen ICC:
