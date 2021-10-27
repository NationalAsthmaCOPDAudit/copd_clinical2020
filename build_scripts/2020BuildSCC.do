clear
set more off

cd "C:\Users\pstone\OneDrive - Imperial College London\Work\National Asthma and COPD Audit Programme\2020 COPD Clinical Audit"


/* create log file */
capture log close
log using build_logs/2020BuildSCC, text replace


local data_dir "D:\National Asthma and COPD Audit Programme (NACAP)\2020 COPD Clinical Audit"


use "`data_dir'/stata_data/COPD_SCC_2020", clear


//DATA CLEANING
tab1 overseas1orinvalid2 duplicate warningsaccepted

drop if overseas1orinvalid2 == 1 | overseas1orinvalid2 == 2
drop overseas1orinvalid2

drop if duplicate == 1
drop duplicate

tab warningsaccepted  //dunno what to do with these

//Check for nonsense dates...

//check for missing data in dates
codebook q1_2aarrivaldate q1_2barrivaltime q4_1aadmissiondate q4_1badmissiontime q10_2dischargedate
codebook q5_1adateofrespiratoryreview q5_1btimeofrespiratoryreview ///
			if q5_1respiratoryreview == 1
codebook q7_1adatenivfirstcommenced q7_1btimenivfirstcommenced ///
			if q7_1acutetreatmentwithniv == 1
codebook q8_1adateoflastrecordedfev1p if q8_11fev1predictednotrecorde != 1
codebook q8_2adateoflastrecordedfev1f if q8_21recentfev1fvcrationotre != 1

//Admission before arrival
drop if q4_1badmissiontime < q1_2barrivaltime

//Admission after discharge
drop if q4_1aadmissiondate > q10_2dischargedate

//Respiratory specialist review before arrival
drop if q5_1btimeofrespiratoryreview < q1_2barrivaltime

//Respiratory specialist review after discharge
drop if q5_1adateofrespiratoryreview > q10_2dischargedate & q5_1adateofrespiratoryreview != .

//NIV before arrival
drop if q7_1btimenivfirstcommenced < q1_2barrivaltime

//NIV after discharge
drop if q7_1adatenivfirstcommenced > q10_2dischargedate & q7_1adatenivfirstcommenced != .

//Discharge before arrival
drop if q10_2dischargedate < q1_2aarrivaldate


count


//Generate No. of admissions for each hospital
gen byte admission = 1
bysort hospitalcode: gen hospadmissions = sum(admission)
by hospitalcode: replace hospadmissions = hospadmissions[_N]
drop admission
order hospadmissions, after(hospital)
gsort patientid q4_1badmissiontime


//Time from arrival to admission
gen double admitwaithours = (((q4_1badmissiontime - q1_2barrivaltime)/1000)/60)/60
order admitwaithours, after(q4_1badmissiontime)


//Generate days of week for admission
gen byte admissionday = dow(q4_1aadmissiondate)+1  //plus one is so that days are 1-7, rather than 0-6
order admissionday, after(q4_1aadmissiondate)
label define days 1 "Sunday" 2 "Monday" 3 "Tuesday" 4 "Wednesday" 5 "Thursday" 6 "Friday" 7 "Saturday"
label values admissionday days


//Generate time categories for admission
local timevars "q4_1badmissiontime"

label define times 1 "00:00-01:59" 2 "02:00-03:59" 3 "04:00-05:59" 4 "06:00-07:59" ///
						5 "08:00-09:59" 6 "10:00-11:59" 7 "12:00-13:59" 8 "14:00-15:59" ///
						9 "16:00-17:59" 10 "18:00-19:59" 11 "20:00-21:59" 12 "22:00-23:59"

foreach timevar of local timevars {

	gen `timevar'time = `timevar' - cofd(dofc(`timevar'))  //remove date from date and time
	order `timevar'time, after(`timevar')
	format %tc_HH:MM `timevar'time
	
	gen `timevar'cat = 1 if `timevar'time >= clock("01/01/1960 00:00", "DMY hm") ///
							& `timevar'time < clock("01/01/1960 02:00", "DMY hm")
	replace `timevar'cat = 2 if `timevar'time >= clock("01/01/1960 02:00", "DMY hm") ///
							& `timevar'time < clock("01/01/1960 04:00", "DMY hm")
	replace `timevar'cat = 3 if `timevar'time >= clock("01/01/1960 04:00", "DMY hm") ///
							& `timevar'time < clock("01/01/1960 06:00", "DMY hm")
	replace `timevar'cat = 4 if `timevar'time >= clock("01/01/1960 06:00", "DMY hm") ///
							& `timevar'time < clock("01/01/1960 08:00", "DMY hm")
	replace `timevar'cat = 5 if `timevar'time >= clock("01/01/1960 08:00", "DMY hm") ///
							& `timevar'time < clock("01/01/1960 10:00", "DMY hm")
	replace `timevar'cat = 6 if `timevar'time >= clock("01/01/1960 10:00", "DMY hm") ///
							& `timevar'time < clock("01/01/1960 12:00", "DMY hm")
	replace `timevar'cat = 7 if `timevar'time >= clock("01/01/1960 12:00", "DMY hm") ///
							& `timevar'time < clock("01/01/1960 14:00", "DMY hm")
	replace `timevar'cat = 8 if `timevar'time >= clock("01/01/1960 14:00", "DMY hm") ///
							& `timevar'time < clock("01/01/1960 16:00", "DMY hm")
	replace `timevar'cat = 9 if `timevar'time >= clock("01/01/1960 16:00", "DMY hm") ///
							& `timevar'time < clock("01/01/1960 18:00", "DMY hm")
	replace `timevar'cat = 10 if `timevar'time >= clock("01/01/1960 18:00", "DMY hm") ///
							& `timevar'time < clock("01/01/1960 20:00", "DMY hm")
	replace `timevar'cat = 11 if `timevar'time >= clock("01/01/1960 20:00", "DMY hm") ///
								& `timevar'time < clock("01/01/1960 22:00", "DMY hm")
	replace `timevar'cat = 12 if `timevar'time >= clock("01/01/1960 22:00", "DMY hm") ///
								& `timevar'time < clock("02/01/1960 00:00", "DMY hm")
	
	label values `timevar'cat times
	order `timevar'cat, after(`timevar'time)
	drop `timevar'time
}
label var q4_1badmissiontimecat "Admission time window"


//Length of stay
gen lengthofstay = q10_2dischargedate - q4_1aadmissiondate
order lengthofstay, after(q10_2dischargedate)


//Time from admission to specialist review (for those who were seen)
gen double reviewwaithours = (((q5_1btimeofrespiratoryreview-q4_1badmissiontime)/1000)/60)/60
order reviewwaithours, after(q5_1btimeofrespiratoryreview)
drop if reviewwaithours <= -24     //not realistic to have a wait time less than this
count

gen byte reviewwithin24hrs = (reviewwaithours <= 24)  //check missing values
order reviewwithin24hrs, after(reviewwaithours)
label values reviewwithin24hrs yn


//Time from arrival to NIV (for those who received it)
gen double nivwaithours = (((q7_1btimenivfirstcommenced-q1_2barrivaltime)/1000)/60)/60
order nivwaithours, after(q7_1btimenivfirstcommenced)

gen byte nivwithin2hrs = 1 if nivwaithours <= 2
replace nivwithin2hrs = 0 if nivwaithours > 2
replace nivwithin2hrs = 2 if q7_1a1nivdatenotrecorded == 1 | q7_1b1nivtimenotrecorded == 1
replace nivwithin2hrs = . if q7_1acutetreatmentwithniv != 1
order nivwithin2hrs, after(nivwaithours)
label define nivwait 0 "No" 1 "Yes" 2 "No time recorded"
label values nivwithin2hrs nivwait

//Generate binary NIV within 2 hours variable
gen byte niv2hrbin = nivwithin2hrs
replace niv2hrbin = 0 if niv2hrbin == 2  //'No time recorded' to be counted as no NIV in 3 hours
order niv2hrbin, after(nivwithin2hrs)

//Generate categorical time from arrival to NIV variable (exposure variable for analysis)
label define nivtimelabel 1 "<=2 Hours" 2 ">2-24 Hours" 3 ">24 Hours"
gen byte nivtime = 1 if nivwaithours <= 2
replace nivtime = 2 if nivwaithours > 2 & nivwaithours <= 24
replace nivtime = 3 if nivwaithours > 24 & nivwaithours != .
label values nivtime nivtimelabel
order nivtime, after(niv2hrbin)


//Any spirometry result available
gen anyspirom = (q8_1mostrecentlyrecordedfev1 != . | q8_2mostrecentlyrecordedfev1 != .)

//Those with and without airflow obstruction
sum q8_2mostrecentlyrecordedfev1, detail
gen byte obstruction = 1 if q8_2mostrecentlyrecordedfev1 < 0.7
replace obstruction = 0 if q8_2mostrecentlyrecordedfev1 >= 0.7 & q8_2mostrecentlyrecordedfev1 != .
label define ratio 0 "No (>=0.7)" 1 "Yes (<0.7)"
label values obstruction ratio

order anyspirom obstruction, after(q8_2a1lastfev1fvcratiodateno)


//Day of discharge
gen byte dischargeday = dow(q10_2dischargedate)+1  //plus one is so that days are 1-7, rather than 0-6
order dischargeday, after(q10_2dischargedate)
label values dischargeday days

//Generate binary discharge bundle variable
gen byte dischargebin = q10_3dischargebundlecomplete
replace dischargebin = . if dischargebin > 1   //self-discharge & death excluded from denominator
order dischargebin, after(q10_3dischargebundlecomplete)


//SUB-ANALYSIS VARIABLES

//Generate binary length of stay variable (above/below median)
sum lengthofstay, detail
local los_median = r(p50)

gen byte longstay = 0 if lengthofstay <= `los_median'
replace longstay = 1 if lengthofstay > `los_median' & lengthofstay != .
order longstay, after(lengthofstay)
label define longloslab 0 "<=`los_median' days" 1 ">`los_median' days"
label values longstay longloslab

//Binary NIV in <=2 hours / >2-24 hours
gen niv2hrbin_excl24 = niv2hrbin
replace niv2hrbin_excl24 = . if nivwaithours > 24
order niv2hrbin_excl24, after(nivtime)
label define niv_ex24 0 ">2-24 Hours" 1 "<=2 Hours"
label values niv2hrbin_excl24 niv_ex24


//MERGE IN LINKED DATA

//Merge in deprivation data
foreach depquin in imd2019 wimd2019 simd2020v2 {

	merge m:1 lsoa11 using "`data_dir'/stata_data/IMD/`depquin'"
	drop if _merge == 2
	drop _merge
}
order imd2019quin wimd2019quin simd2020v2quin, after(lsoa11cd)


//Merge in hospital data
merge m:1 hospitalcode using "`data_dir'/stata_data/hospitals"
drop if _merge == 2
drop _merge
order country trustcode hospitalcode hospital hospadmissions


gsort patientid q4_1badmissiontime
by patientid: gen patadmno = _n
by patientid: gen patadmcount = _N
order patadmno patadmcount, after(patientid)


replace country = 1 if hospitalcode == "GWH"   //All the patients are English so probably in England


//Merge in missing NEWS2 data
merge m:1 studyid using "`data_dir'/stata_data/news2_fix", update
drop if _merge == 2
drop _merge


compress
save "`data_dir'/builds/COPD_SCC_2020_build", replace


log close
