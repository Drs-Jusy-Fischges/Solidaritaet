/******************************************************************************

                                    ##                                        
                             ##    ###   ###                                  
                            ##           ##   #                               
                   ####                     ###                               
                                                                              
             ##                                                               
           ####                                                               
                       #######   ###    ###       ###      ########    #######
                      ####  #    ###    ###      #####     #### ####   ####   
     ###              ####       ###### ###     ### ###    ###   ###   ###    
    ###                ######    ##########     ##  ###    ########    #######
                          ####   ###    ###    #########   #### ###    ###    
   #                   ##  ###   ###    ###   ###########  ###   ###   #######
####                  #######    ###    ###   ###     ###  ###   ###   #######
#                                                                             
                             
 ###                    #    
###                   #####            
     ###      ###     ###                   
   ####     ####                       
   #        ##               
										


******************************************************************************/



*   --- SHARETOM5.ADO
*     - version 1.0
*     - last update 26th of January 2016


 capture program drop sharetom5
 program define sharetom5, rclass
 syntax varlist [, replace]


 qui ds
 local n `r(varlist)'


*error codes if replace is wrongly specified

 if "`replace'"=="replace" & "`varlist'"!="`n'" {
  di as error "replace requires _all in varlist;"
  di as error "no action taken"
  exit
 }


*procedure if replace option correctly specified:

 if "`replace'"=="replace" & "`varlist'"=="`n'" {

 preserve

 uselabel, var clear

 qui sum value
 if r(min)>=0 {
  di as error "no labels containing valid missing codes found;"
  di as error "no action taken"
  exit 9
 }

 qui {
  keep lname value
  drop if value>=0
  drop if value<=-9999991
 }

 if _N>1 {
  by lname, sort: gen j=_n
  qui reshape wide value, i(lname) j(j)
  foreach i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 {
   capture tostring value`i', replace
  }
 }
 if _N==1 {
  capture tostring value, gen(value1)
 }

 if _N>0 {

 capture gen _miss=value1
 capture replace _miss="" if _miss=="."
  foreach i in 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 {
   capture replace value`i'="" if value`i'=="."
   capture replace _miss=_miss+" "+value`i' 
  }

 foreach i of numlist 1/18 {
  capture drop value`i'
 }
 
 tempname Nlab
 scalar `Nlab'=_N+1

 local N=_N+1
 local i=1
 while `i'<`N' {
  qui gen l_n`i'=lname[`i'] 
  local i=`i'+1
 }

 foreach var of varlist l_n* {
  tempname `var'
  local `var' = `var'
 }

 keep lname _miss

 local N=_N+1
 local i=1
 while `i'<`N' {
  qui gen l_m`i'=_miss[`i'] 
  local i=`i'+1
 }

 foreach var of varlist l_m* {
  tempname `var'
  local `var' = `var'
 }
 
 }

 restore

 local i=1
 while `i'<`Nlab' {
  qui lab li `l_n`i''
  if `r(min)'>=-99 & `r(min)'<=-1 {   
	if strpos("`l_m`i''","-1") !=0 {
     lab de `l_n`i'' .a "Don't know" -1 "", modify
    }
    if strpos("`l_m`i''","-2") !=0 {
     lab de `l_n`i'' .b "Refusal" -2 "", modify
    }
    if strpos("`l_m`i''","-3") !=0 {
     lab de `l_n`i'' .c "Implausible/suspected wrong" -3 "", modify
    }
    if strpos("`l_m`i''","-4") !=0 {
     lab de `l_n`i'' .d "Not codable" -4 "", modify
    }
    if strpos("`l_m`i''","-5") !=0 {
     lab de `l_n`i'' .e "Not answered" -5 "", modify
    }
	if strpos("`l_m`i''","-6") !=0 {
     lab de `l_n`i'' .z "Old code (not used at the moment)" -6 "", modify
    }
    if strpos("`l_m`i''","-7") !=0 {
     lab de `l_n`i'' .g "Not yet coded" -7 "", modify
    }
	if strpos("`l_m`i''","-8") !=0 {
     lab de `l_n`i'' .z "Old code (not used at the moment)" -8 "", modify
    }
    if strpos("`l_m`i''","-9") !=0 {
     lab de `l_n`i'' .i "Not applicable" -9 "", modify
    }	
	if strpos("`l_m`i''","-12") !=0 {
     lab de `l_n`i'' .j "Don't know or refusal" -12 "", modify
    }
	if strpos("`l_m`i''","-13") !=0 {
     lab de `l_n`i'' .k "Not asked in this wave" -13 "", modify
    }
	if strpos("`l_m`i''","-14") !=0 {
     lab de `l_n`i'' .l "Not asked in this country" -14 "", modify
    }
	if strpos("`l_m`i''","-15") !=0 {
     lab de `l_n`i'' .m "No information" -15 "", modify
    }	
	if strpos("`l_m`i''","-91") !=0 {
     lab de `l_n`i'' .i "Not applicable" -91 "", modify
    }
	if strpos("`l_m`i''","-92") !=0 {
     lab de `l_n`i'' .i "Not applicable" -92 "", modify
    }
	if strpos("`l_m`i''","-93") !=0 {
     lab de `l_n`i'' .i "Not applicable" -93 "", modify
    }
	if strpos("`l_m`i''","-94") !=0 {
     lab de `l_n`i'' .i "Not applicable" -94 "", modify
    }
	if strpos("`l_m`i''","-95") !=0 {
     lab de `l_n`i'' .i "Not applicable" -95 "", modify
    }
	if strpos("`l_m`i''","-98") !=0 {
     lab de `l_n`i'' .i "Not applicable" -98 "", modify
    }
	if strpos("`l_m`i''","-99") !=0 {
     lab de `l_n`i'' .i "Not applicable" -99 "", modify    
	}
   }
  local i=`i'+1
  }

  qui label dir
  foreach lab in `r(names)' {
   qui lab list `lab'
   if `r(min)'==-9999992|`r(min)'==-9999991 {
    lab def `lab' .a "Don't know" .b "Refusal" -9999992 "" -9999991 "", modify
   }
  }
 }


*missing recode:

 qui ds `varlist', has(vall)
 return local varlist `r(varlist)'
 if "`r(varlist)'" == "" {
  di as error "no value labels found;"
  di as error "no action taken"
  exit 9
 }
 foreach var of varlist `r(varlist)' {
  capture confirm numeric variable `var'  
   if !_rc {                               
    qui {
	 tempname min
     sum `var'
     scalar `min'=r(min)
     mvdecode `var' if `min'>=-99 & `min'<=-1, mv(-1=.a\-2=.b\-3=.c\-4=.d\-5=.e\-6=.z\-7=.g\-8=.z\-9=.i\-12=.j\-13=.k\-14=.l\-15=.m\-91 -92 -93 -94 -95 -98 -99 =.i)
     mvdecode `var' if `min'==-9999992 | `min'==-9999991, mv(-9999992=.b\-9999991=.a)
    }
   }
  }




 end




