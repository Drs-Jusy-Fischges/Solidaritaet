***************************************
**** Master Do-File Julia Büschges ****
***************************************

*** Default settings
clear all
version 12.0
set more off

* Globals 
global SHARE "C:\Users\Julia\Documents\Studium\M.A.Soziologie\5.Semester\Masterarbeit\Methods\SHARE"          // Orignaldatensatz
global out "C:\Users\Julia\Documents\Studium\M.A.Soziologie\5.Semester\Masterarbeit\Methods\Out"	         // bearbeiteter Datensatz
global results "C:\Users\Julia\Documents\Studium\M.A.Soziologie\5.Semester\Masterarbeit\Methods\Results"  // Ergebnisse
global do "C:\Users\Julia\Documents\Studium\M.A.Soziologie\5.Semester\Masterarbeit\Methods\Do-Files"		 // Do-File
global log "C:\Users\Julia\Documents\Studium\M.A.Soziologie\5.Semester\Masterarbeit\Methods\Log-Files"    // Log-File 

*************************************
*************************************
capture log close
exit


/* Abfolge Do-Files ----> 
1. Master     jo
2. Mergen     ..
3. DM_case    ..
4. DM_vari    ..
5. Macro      ..
6. Uni-Bi     ..
7. Multi      ..

*/
