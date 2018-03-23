*******************************
******* Descriptives *******
*********************

version 13
clear all
set more off, perm
set linesize 80
capture log close

* Master Do-File
do "C:\Users\Julia\Documents\Studium\M.A.Soziologie\5.Semester\Masterarbeit\Methods\Do-Files\Master.do"

* LOG-Datei
capture log close
log using $log\Descriptives.log, replace

use $SHARE\sharew5_rel6-0-0_ALL_datasets_stata\sharew5_rel6-0-0_gv_weights.dta, clear

// Doppelte Fälle raus
sort hhid5
quietly by hhid5: gen dup= cond(_N==1,0,_n)
tab dup
keep if dup<2
drop dup

saveold $out\weights.dta, replace  


***********************************
***********************************

do $do\CH+P+M.do

use $out\sample.dta, clear

*** Weights dranmatchen ***

merge m:1 hhid5 using $out\weights.dta, /*
*/ keepusing(hhid5 cchw_w5) gen(weight_m)

keep if weight_m==3
drop weight_m

svyset country [pweight=cchw_w5] // cntry als clustervariable und Gewichtung
rename cchw_w5 gewicht

set scheme vg_s2c
***********************************
***********************************

* Kinder allgemein
tab country [aw=gewicht]
sum Kalter [aw=gewicht]

sum Keduc [aw=gewicht], detail
tab Keduc [aw=gewicht]
tab Kmar [aw=gewicht]
tab Kkind [aw=gewicht]

tab Kcohab [aw=gewicht]

tab Kwohn [aw=gewicht]

tab Ksex [aw=gewicht]


* Eltern allgemein
sum alter1 [aw=gewicht], detail
sum alter2 [aw=gewicht], detail

gen altfirst1= alter1 - Kalterfirstborn
sum altfirst1 [aw=gewicht]

gen altfirst2= alter2 - Kalterfirstborn
sum altfirst2 [aw=gewicht]

tab erwerb1 [aw=gewicht]

tab isced_p1 [aw=gewicht]
tab isced_p2 [aw=gewicht]

sum nKind [aw=gewicht]

tab owner [aw=gewicht]
tab partner [aw=gewicht]

tab xhealth [aw=gewicht]

* Kontakt
tab Kkon [aw=gewicht]
sort Kwohn
bysort Kwohn: tab Kkon [aw=gewicht]


* IC vs. Moveout
tab Keduc if Kcohab==0 & Keduc!=5 [aw=gewicht] 
tab Keduc if Kcohab==1 & Keduc!=5 [aw=gewicht]

tab Kop if Kcohab==0 [aw=gewicht] 
tab Kop if Kcohab==1 [aw=gewicht]

tab Ksex if Kcohab==0 [aw=gewicht] 
tab Ksex if Kcohab==1 [aw=gewicht] 

tab Kmar if Kcohab==0 [aw=gewicht] 
tab Kmar if Kcohab==1 [aw=gewicht] 

tab Kpar if Kcohab==0 [aw=gewicht] 
tab Kpar if Kcohab==1 [aw=gewicht] 

tab Kkind if Kcohab==0 [aw=gewicht] 
tab Kkind if Kcohab==1 [aw=gewicht] 


* Kohabitationsstatus nach Land
bysort country: tab Kcohab [aw=gewicht] 

* Haushaltskomposition nach Land
bysort country: sum otherkids [aw=gewicht] 



* Auszugsalter nach Land
sort country
bysort country: sum moveage [aw=gewicht]

gen cntr=country
recode cntr(11=.)(12=1)(13=2) (14=.) (15=4) (16/22=.) (23/27=.) (28=3) (29/35=.)
label def cntr 1 "Germany" 2 "Sweden" 3 "Czech Republic" 4 "Spain", replace
label value cntr cntr
tab cntr

bysort cntr: tab moveage [aw=gewicht]

gen altaus=moveage
recode altaus(0/14=.) (40/100=.)


# delimit ;
twoway (kdensity altaus, bwidth(2) range(16 40) area(100) ytitle("")), by(cntr, note("")) 
xlabel(15(5)40) xline(20 30) 
xtitle("Age of leaving the parental home")
ylabel(0 "0%" 5 "5%" 10 "10%" 15 "15%")
;
# delimit cr

graph export Cntrmove.emf, replace


* Moveout nach Education
gen Educv=Keduc
recode Educv (6=.) (1 4=.)
label def Educv 2 "Lower seoncdary educ." 3 "Upper secondary educ." 5 "Tertiary educ."
label val Educv Educv


//Graph wie im Text mit nur bis 5 Jahre her und weniger Kategorien
*keep if Kalter-moveage<6
# delimit ;
kdensity altaus if (Educv==2) [aw=gewicht], gauss plot
(kdensity altaus if (Educv==3),gauss ||
kdensity altaus if (Educv==5), gauss) 
title("")
legend(symxsize(5) size(medium) ring(0) pos(2) 
label (1 "Lower secondary educ.")
label (2 "Upper secondary educ.")
label (3 "Tertiary educ."))
xlabel(15(5)40)
ylabel(0 "0%" 0.05 "5%" 0.1 "10%" 0.15 "15%")
ytitle("")
note("")
xtitle ("Age of leaving the parental home");
# delimit cr

graph export Educmove.emf, replace


bysort Keduc: sum altaus, detail


* Moveouts Graph

*by altaus, sort: gen freq = _N
*by altaus: gen cumfreq = _N if _n == 1
*replace cumfreq = sum(cumfreq)
*tabdisp altaus, cell(freq cumfreq)

*cumul altaus, gen(altcum)
*sort altcum

*cdfplot altaus, saving(cum)
*distplot altaus, recast(drop)
*line altcum altaus, saving(cum2)

ghistcum altaus, bin(10)

# delimit ;
twoway 
(histogram altaus, percent width(1) bfcolor(gs15) lcolor(gs15) leg(off)) 
(kdensity altaus, gauss area(100) clwidth(thick) clcolor(emidblue)), 
xtitle(Age of leaving home) ytitle(Share in Percent);
# delimit cr


akdensity altaus , nograph gen(fx) at(altaus) cdf(Fx)
cumul altaus , gen(aucum)
tw (line fx altaus) (line Fx altaus, yaxis(2)) (line ecdf aucum, connect(stairstep) sort yaxis(2) ) `gropts´













