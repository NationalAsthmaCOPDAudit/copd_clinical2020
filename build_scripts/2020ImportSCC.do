clear
set more off

cd "C:\Users\pstone\OneDrive - Imperial College London\Work\National Asthma and COPD Audit Programme\2020 COPD Clinical Audit"


/* create log file */
capture log close
log using build_logs/2020ImportSCC, text replace


local data_dir "D:\National Asthma and COPD Audit Programme (NACAP)\2020 COPD Clinical Audit"


import delimited using "`data_dir'/raw_data/NACAP-COPD-1910-2002-ImperialAuditData-v101.csv", varnames(nonames) rowrange(1:1) clear

//clean up and replace the var names
foreach var of varlist _all {
	
	//clean characters Stata doesn't like from variable names
	replace `var' = subinstr(`var', " ", "", .)
	replace `var' = subinstr(`var', "?", "", .)
	replace `var' = subinstr(`var', "#", "", .)
	replace `var' = subinstr(`var', ":", "", .)
	replace `var' = subinstr(`var', "%", "", .)
	replace `var' = subinstr(`var', "/", "", .)
	replace `var' = subinstr(`var', "=", "", .)
	replace `var' = subinstr(`var', "-", "", .)
	replace `var' = subinstr(`var', ".", "_", .)
	
	//prefix a "q" to variables that start with a number
	if real(substr(`var', 1, 1)) != . {
	
		replace `var' = "q"+`var'
	}
	
	//truncate long variable names
	replace `var' = substr(`var', 1, 28)
	
	//fix variable names that are identical when truncated
	if "`var'" == "v60" {
		
		replace `var' = "q10_4Discharge_DrugProvided"
	}
	else if "`var'" == "v61" {
	
		replace `var' = "q10_4Discharge_DrugNotProvided"
	}
	
	local name = lower(`var')
	rename `var' `name'
}

describe, varlist
local varnames = r(varlist)

import delimited "`data_dir'/raw_data/NACAP-COPD-1910-2002-ImperialAuditData-v101.csv", asdouble clear
rename (_all) (`varnames')


//Generate datetime variables
local datevars "q1_2aarrivaldate q4_1aadmissiondate q5_1adateofrespiratoryreview"
local datevars "`datevars' q7_1adatenivfirstcommenced q8_1adateoflastrecordedfev1p"
local datevars "`datevars' q8_2adateoflastrecordedfev1f q10_2dischargedate"
foreach datevar of local datevars {
	
	rename `datevar' `datevar'_old
	
	gen `datevar' = date(`datevar'_old, "DMY")
	format %td `datevar'
	order `datevar', after(`datevar'_old)
	
	_crcslbl `datevar' `datevar'_old
	
	//generate accompanying time version of variable
	local timevar = subinstr(subinstr("`datevar'", "a", "b", 1), "date", "time", 1)
	display "`timevar'"
	
	capture confirm variable `timevar'
	if !_rc {
		
		di "Date not deleted yet. Required for datetime."
	}
	else {
		
		drop `datevar'_old
	}
}

local timevars "q1_2barrivaltime q4_1badmissiontime q5_1btimeofrespiratoryreview"
local timevars "`timevars' q7_1btimenivfirstcommenced"
foreach timevar of local timevars {
	
	rename `timevar' `timevar'_old
	
	//generate accompanying date version of variable
	local datevar = subinstr(subinstr("`timevar'", "b", "a", 1), "time", "date", 1)
	display "`datevar'"
	
	display `timevar'_old
	
	gen double `timevar' = clock(`datevar'_old + `timevar'_old, "DMY hm")
	format %tc `timevar'
	order `timevar', after(`timevar'_old)
	
	_crcslbl `timevar' `timevar'_old
	
	drop `datevar'_old `timevar'_old
}


rename ageatadmissionyears age
rename q2_3gender gender


//Encode gender
tab gender, missing
replace gender = "1" if gender == "Male"
replace gender = "2" if gender == "Female"
replace gender = "3" if gender == "Transgender"
replace gender = "4" if gender == "Other"
replace gender = "5" if gender == "Not recorded/Preferred not to say"
destring gender, replace
label define sex 1 "Male" 2 "Female" 3 "Transgender" 4 "Other" ///
				 5 "Not recorded/Preferred not to say"
label values gender sex
tab gender, missing


//Smoking status
replace q2_5smokingstatus = "1" if q2_5smokingstatus == "Never smoked"
replace q2_5smokingstatus = "2" if q2_5smokingstatus == "Ex-smoker"
replace q2_5smokingstatus = "3" if q2_5smokingstatus == "Current smoker"
replace q2_5smokingstatus = "4" if q2_5smokingstatus == "Ex-smoker and current vaper"
replace q2_5smokingstatus = "5" if q2_5smokingstatus == "Never smoked and current vaper"
replace q2_5smokingstatus = "6" if q2_5smokingstatus == "Not recorded"
destring q2_5smokingstatus, replace
label define smokstat 1 "Never smoked" 2 "Ex-smoker" 3 "Current smoker" ///
					  4 "Ex-smoker and current vaper" ///
					  5 "Never smoked and current vaper" 6 "Not recorded"
label values q2_5smokingstatus smokstat


//NEWS2
gen news2source = 1
replace news2source = 2 if q3_1firstrecordednewsscore == "Calculate score"
replace news2source = 0 if q3_1firstrecordednewsscore == "Score not available"
label define news2source 0 "Score not available" 1 "Score entered" 2 "Score calculated"
label values news2source news2source
order news2source, before(q3_1firstrecordednewsscore)

replace q3_1firstrecordednewsscore = "" if q3_1firstrecordednewsscore == "Calculate score"
replace q3_1firstrecordednewsscore = "" if q3_1firstrecordednewsscore == "Score not available"
//remove random "d"
replace q3_1firstrecordednewsscore = "7" if q3_1firstrecordednewsscore == "7d"
destring q3_1firstrecordednewsscore, replace

gen news2 = q3_1firstrecordednewsscore if q3_1firstrecordednewsscore != .
replace news2 = q3_2newsscoretotal if q3_2newsscoretotal != .
order news2, after(news2source)

//looks like some NEWS2 scores have not been calculated using the available data


//Yes/No variables
local ynvars "q5_1respiratoryreview q6_1oxygenprescribedduringad q6_2oxygenadministeredduring"
local ynvars "`ynvars' q7_1acutetreatmentwithniv q9_1historyofcardiovasculard q9_1aifyes"
local ynvars "`ynvars' q9_2historyofhistoryofmental q9_2aifyes"
label define yn 0 "No" 1 "Yes"
foreach ynvar of local ynvars {
	
	replace `ynvar' = "0" if `ynvar' == "No"
	replace `ynvar' = "1" if `ynvar' == "Yes"
	destring `ynvar', replace
	label values `ynvar' yn
}


//Oxygen target saturation
replace q6_1aoxygenstipulatedtargetr = "1" if q6_1aoxygenstipulatedtargetr == "88-92%"
replace q6_1aoxygenstipulatedtargetr = "2" if q6_1aoxygenstipulatedtargetr == "94-98%"
replace q6_1aoxygenstipulatedtargetr = "3" if q6_1aoxygenstipulatedtargetr == "Target range not stipulated"
replace q6_1aoxygenstipulatedtargetr = "4" if q6_1aoxygenstipulatedtargetr == "Other"
destring q6_1aoxygenstipulatedtargetr, replace
label define o2pres 1 "88-92%" 2 "94-98%" 3 "Target range not stipulated" 4 "Other"
label values q6_1aoxygenstipulatedtargetr o2pres


//Not recorded variables
local nrvars "q7_1a1nivdatenotrecorded q7_1b1nivtimenotrecorded q8_11fev1predictednotrecorde"
local nrvars "`nrvars' q8_1a1fev1predicteddatenotre q8_21recentfev1fvcrationotre"
local nrvars "`nrvars' q8_2a1lastfev1fvcratiodateno"
label define nr 1 "Not recorded"
foreach nrvar of local nrvars {
	
	replace `nrvar' = "1" if `nrvar' == "Not recorded"
	destring `nrvar', replace
	label values `nrvar' nr
	replace `nrvar' = 0 if `nrvar' == .
}


//Discharge
replace q10_1dischargelifestatus = "0" if q10_1dischargelifestatus == "Alive"
replace q10_1dischargelifestatus = "1" if q10_1dischargelifestatus == "Died as inpatient"
destring q10_1dischargelifestatus, replace
label define died 0 "Alive" 1 "Died as inpatient"
label values q10_1dischargelifestatus died

**PREVIOUS AUDIT EXCLUDED DISCHARGE DATE FOR PATIENTS THAT DIED**
replace q10_2dischargedate = . if q10_1dischargelifestatus == 1

replace q10_3dischargebundlecomplete = "0" if q10_3dischargebundlecomplete == "No"
replace q10_3dischargebundlecomplete = "1" if q10_3dischargebundlecomplete == "Yes"
replace q10_3dischargebundlecomplete = "2" if q10_3dischargebundlecomplete == "Self discharge"
destring q10_3dischargebundlecomplete, replace
label define discharge 0 "No" 1 "Yes" 2 "Self-discharge"
label values q10_3dischargebundlecomplete discharge

rename q10_4dischargeelementsinhale q10_4discharge_inhaler
rename q10_4dischargeelementsmedica q10_4discharge_medication
rename q10_4dischargeelementsselfma q10_4discharge_selfmanagement
rename q10_4dischargeelementsoxygen q10_4discharge_oxygen
rename q10_4dischargeelementssmokin q10_4discharge_smokingcess
rename q10_4dischargeelementsassess q10_4discharge_pr
rename q10_4dischargeelementsfollow q10_4discharge_followup
rename q10_4dischargeelementspatien q10_4discharge_mdt
rename q10_4dischargeelementsblfpas q10_4discharge_blfpassport
rename q10_4dischargeelementsnone q10_4discharge_none

drop q10_4dischargeelements

//Patients that died wrongly marked as not receiving discharge items - should be missing
foreach var of varlist q10_4discharge_inhaler-q10_4discharge_none {
	
	replace `var' = . if q10_1dischargelifestatus == 1
}

//non-smokers don't need smoking cessation treatment, so make smoking cessation blank for these
tab1 q2_5smokingstatus q10_4discharge_smokingcess
replace q10_4discharge_smokingcess = . if q2_5smokingstatus < 3 //never and ex smokers
tab q10_4discharge_smokingcess


//Dataset version
tab datasetversion
drop datasetversion  //no useful information


//Dataset details
tab1 draftstatus overseas1orinvalid2 duplicate warningsaccepted

drop draftstatus  //no drafts


compress
save "`data_dir'/stata_data/COPD_SCC_2020", replace


log close
