*******************************
****** Regressionsanalyse *****
*******************************

version 13
clear all
set more off, perm
set linesize 80
capture log close


* Master Do-File
do "C:\Users\Julia\Documents\Studium\M.A.Soziologie\5.Semester\Masterarbeit\Methods\Do-Files\Master.do"

import excel "C:\Users\Julia\Documents\Studium\M.A.Soziologie\5.Semester\Masterarbeit\Methods\Macro.xlsx", sheet("Table") firstrow clear

label var fam_exp "Family expenditures as % of GDP"

saveold $out\macro.dta, replace  
 
