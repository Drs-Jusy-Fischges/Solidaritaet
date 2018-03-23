*******************************
******* Datenmanagement *******
******** ISCED CH & P *********

version 13
clear all
set more off, perm
set linesize 80
capture log close


* Master Do-File
do "C:\Users\Julia\Documents\Studium\M.A.Soziologie\5.Semester\Masterarbeit\Methods\Do-Files\Master.do"

use $SHARE\sharew5_rel6-0-0_ALL_datasets_stata/sharew5_rel6-0-0_gv_health.dta, clear

keep mergeid hhid5 casp sphus

* Missing kodieren
do $do\sharetom5.ado
numlabel _all, add

* Subj. Health
clonevar subges= sphus
recode subges (-2 -1=.)
label value subges rate
tab subges
drop sphus

merge 1:1 mergeid using $SHARE\sharew5_rel6-0-0_ALL_datasets_stata/sharew5_rel6-0-0_hc.dta, keepusing(mergeid hc066_ hc014_ hc031_) gen(hc_merge)
drop if hc_merge==2

recode hc066_ hc014_ hc031_ (-2 -1 .=0)
gen hosnight= hc066_ + hc014_ + (hc031_*7)
recode hosnight (-2 -1 .=0) (.=0)
label var hosnight "Nights spend in institutions"
drop hc066_ hc014_ hc031_

saveold $out\Health.dta, replace  



