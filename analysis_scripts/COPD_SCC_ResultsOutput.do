clear
set more off

cd "C:\Users\pstone\OneDrive - Imperial College London\Work\National Asthma and COPD Audit Programme\2020 COPD Clinical Audit"


local data_dir "D:\National Asthma and COPD Audit Programme (NACAP)\2020 COPD Clinical Audit"


use "`data_dir'/builds/COPD_SCC_2020_build", clear


rename q8_1mostrecentlyrecordedfev1 fev1pp

keep country hospitalcode age gender imd2019quin wimd2019quin simd2020v2quin ///
	 q2_5smokingstatus news2source news2 q3_2newsscoretotal ///
	 admissionday q4_1badmissiontimecat admitwaithours ///
	 q5_1respiratoryreview reviewwaithours reviewwithin24hrs q6_1oxygenprescribedduringad ///
	 q6_1aoxygenstipulatedtargetr q6_2oxygenadministeredduring q7_1acutetreatmentwithniv ///
	 nivwithin2hrs nivtime fev1pp anyspirom obstruction q9_1historyofcardiovasculard ///
	 q9_1aifyes q9_2historyofhistoryofmental q9_2aifyes q10_1dischargelifestatus ///
	 dischargeday lengthofstay q10_3dischargebundlecomplete q10_4discharge_inhaler ///
	 q10_4discharge_medication q10_4discharge_selfmanagement q10_4discharge_drugprovided ///
	 q10_4discharge_drugnotprovided q10_4discharge_oxygen q10_4discharge_smokingcess ///
	 q10_4discharge_pr q10_4discharge_followup q10_4discharge_mdt ///
	 q10_4discharge_blfpassport q10_4discharge_none

order age gender imd2019quin simd2020v2quin wimd2019quin admitwaithours admissionday ///
	  q4_1badmissiontimecat lengthofstay q10_1dischargelifestatus ///
	  q5_1respiratoryreview reviewwithin24hrs reviewwaithours ///
	  q6_1oxygenprescribedduringad q6_1aoxygenstipulatedtargetr ///
	  q6_2oxygenadministeredduring q7_1acutetreatmentwithniv nivwithin2hrs nivtime ///
	  anyspirom obstruction fev1pp q2_5smokingstatus q10_4discharge_smokingcess ///
	  news2source news2 q3_2newsscoretotal q9_1historyofcardiovasculard ///
	  q9_1aifyes q9_2historyofhistoryofmental q9_2aifyes dischargeday ///
	  q10_3dischargebundlecomplete q10_4discharge_inhaler q10_4discharge_medication ///
	  q10_4discharge_selfmanagement q10_4discharge_drugprovided ///
	  q10_4discharge_drugnotprovided q10_4discharge_oxygen ///
	  q10_4discharge_pr q10_4discharge_followup q10_4discharge_mdt ///
	  q10_4discharge_blfpassport q10_4discharge_none, after(hospitalcode)


local bundlevars "q10_4discharge_inhaler q10_4discharge_medication"
local bundlevars "`bundlevars' q10_4discharge_selfmanagement q10_4discharge_drugprovided"
local bundlevars "`bundlevars' q10_4discharge_drugnotprovided q10_4discharge_oxygen"
local bundlevars "`bundlevars' q10_4discharge_pr"
local bundlevars "`bundlevars' q10_4discharge_followup q10_4discharge_mdt"
local bundlevars "`bundlevars' q10_4discharge_blfpassport q10_4discharge_none"

local sumvars "age admitwaithours lengthofstay reviewwaithours fev1pp"


local date "$S_DATE"
 	

encode hospitalcode, gen(hospcode)
order hospcode
drop hospitalcode


preserve


//National analysis

gensumstat `sumvars'
drop `sumvars'

gennumdenom gender, pre(gender) num(5) pc
drop gender

gennumdenom imd2019quin, pre(imd) num(5) pc
drop imd2019quin

gennumdenom simd2020v2quin, pre(simd) num(5) pc
drop simd2020v2quin

gennumdenom wimd2019quin, pre(wimd) num(5) pc
drop wimd2019quin

gennumdenom admissionday, pre(admitday) num(7) pc
drop admissionday

gennumdenom q4_1badmissiontimecat, pre(admittime) num(12) pc
drop q4_1badmissiontimecat

gennumdenom q10_1dischargelifestatus, pre(died) pc
drop q10_1dischargelifestatus

gennumdenom q5_1respiratoryreview, pre(resprev) pc
drop q5_1respiratoryreview

gennumdenom reviewwithin24hrs, pre(revin24hrs) pc
drop reviewwithin24hrs

gennumdenom q6_1oxygenprescribedduringad, pre(o2presc) pc
drop q6_1oxygenprescribedduringad

gennumdenom q6_1aoxygenstipulatedtargetr, pre(o2targ) num(4) pc
drop q6_1aoxygenstipulatedtargetr

gennumdenom q6_2oxygenadministeredduring, pre(o2admin) pc
drop q6_2oxygenadministeredduring

gennumdenom q7_1acutetreatmentwithniv, pre(niv) pc
drop q7_1acutetreatmentwithniv

gennumdenom nivwithin2hrs, pre(nivin3hrs) num(2) zero pc
drop nivwithin2hrs

gennumdenom nivtime, pre(nivtime) num(3) pc
drop nivtime

gennumdenom anyspirom, pre(spirom) pc
drop anyspirom

gennumdenom obstruction, pre(obstruction) pc
drop obstruction

gennumdenom q2_5smokingstatus, pre(smokstat) num(6) pc
drop q2_5smokingstatus

gennumdenom q10_4discharge_smokingcess, pre(smokcess) pc
drop q10_4discharge_smokingcess

gennumdenom news2source, pre(news2) num(2) zero pc
drop news2source

gennumdenom news2, pre(news2score) num(20) zero pc
drop news2

gennumdenom q9_1historyofcardiovasculard, pre(histcv) pc
drop q9_1historyofcardiovasculard

gennumdenom q9_1aifyes, pre(cvintervention) pc
drop q9_1aifyes

gennumdenom q9_2historyofhistoryofmental, pre(histmental) pc
drop q9_2historyofhistoryofmental

gennumdenom q9_2aifyes, pre(mentalintervention) pc
drop q9_2aifyes

gennumdenom dischargeday, pre(dischargeday) num(7) pc
drop dischargeday

gennumdenom q10_3dischargebundlecomplete, pre(bundle) num(2) zero pc
drop q10_3dischargebundlecomplete


foreach bundlevar of local bundlevars {
	
	local bundleprefix = substr("`bundlevar'", 16, .)
	
	gennumdenom `bundlevar', pre(bun_`bundleprefix') pc
	drop `bundlevar'
}


keep if _n == 1
drop hospcode country

gen hospitalcode = "National"
gen country = "UK"
order hospitalcode country

export excel using "outputs/COPD_SCC2020_Analysis_`date'.xlsx", firstrow(variables) replace


restore, preserve


//Each UK country level analysis

gensumstat `sumvars', by(country)
drop `sumvars'

gennumdenom gender, pre(gender) num(5) pc by(country)
drop gender

gennumdenom imd2019quin, pre(imd) num(5) pc by(country)
drop imd2019quin

gennumdenom simd2020v2quin, pre(simd) num(5) pc by(country)
drop simd2020v2quin

gennumdenom wimd2019quin, pre(wimd) num(5) pc by(country)
drop wimd2019quin

gennumdenom admissionday, pre(admitday) num(7) pc by(country)
drop admissionday

gennumdenom q4_1badmissiontimecat, pre(admittime) num(12) pc by(country)
drop q4_1badmissiontimecat

gennumdenom q10_1dischargelifestatus, pre(died) pc by(country)
drop q10_1dischargelifestatus

gennumdenom q5_1respiratoryreview, pre(resprev) pc by(country)
drop q5_1respiratoryreview

gennumdenom reviewwithin24hrs, pre(revin24hrs) pc by(country)
drop reviewwithin24hrs

gennumdenom q6_1oxygenprescribedduringad, pre(o2presc) pc by(country)
drop q6_1oxygenprescribedduringad

gennumdenom q6_1aoxygenstipulatedtargetr, pre(o2targ) num(4) pc by(country)
drop q6_1aoxygenstipulatedtargetr

gennumdenom q6_2oxygenadministeredduring, pre(o2admin) pc by(country)
drop q6_2oxygenadministeredduring

gennumdenom q7_1acutetreatmentwithniv, pre(niv) pc by(country)
drop q7_1acutetreatmentwithniv

gennumdenom nivwithin2hrs, pre(nivin3hrs) num(2) zero pc by(country)
drop nivwithin2hrs

gennumdenom nivtime, pre(nivtime) num(3) pc by(country)
drop nivtime

gennumdenom anyspirom, pre(spirom) pc by(country)
drop anyspirom

gennumdenom obstruction, pre(obstruction) pc by(country)
drop obstruction

gennumdenom q2_5smokingstatus, pre(smokstat) num(6) pc by(country)
drop q2_5smokingstatus

gennumdenom q10_4discharge_smokingcess, pre(smokcess) pc by(country)
drop q10_4discharge_smokingcess

gennumdenom news2source, pre(news2) num(2) zero pc by(country)
drop news2source

gennumdenom news2, pre(news2score) num(20) zero pc by(country)
drop news2

gennumdenom q9_1historyofcardiovasculard, pre(histcv) pc by(country)
drop q9_1historyofcardiovasculard

gennumdenom q9_1aifyes, pre(cvintervention) pc by(country)
drop q9_1aifyes

gennumdenom q9_2historyofhistoryofmental, pre(histmental) pc by(country)
drop q9_2historyofhistoryofmental

gennumdenom q9_2aifyes, pre(mentalintervention) pc by(country)
drop q9_2aifyes

gennumdenom dischargeday, pre(dischargeday) num(7) pc by(country)
drop dischargeday

gennumdenom q10_3dischargebundlecomplete, pre(bundle) num(2) zero pc by(country)
drop q10_3dischargebundlecomplete


foreach bundlevar of local bundlevars {
	
	local bundleprefix = substr("`bundlevar'", 16, .)
	
	gennumdenom `bundlevar', pre(bun_`bundleprefix') pc by(country)
	drop `bundlevar'
}


by country: keep if _n == 1
drop hospcode

gen hospitalcode = "National"
order hospitalcode


export excel using "outputs/COPD_SCC2020_Analysis_`date'.xlsx", cell(A3) sheetmodify


restore


//Hospital-level analysis

gensumstat `sumvars', by(hospcode)
drop `sumvars'

gennumdenom gender, pre(gender) num(5) pc by(hospcode)
drop gender

gennumdenom imd2019quin, pre(imd) num(5) pc by(hospcode)
drop imd2019quin

gennumdenom simd2020v2quin, pre(simd) num(5) pc by(hospcode)
drop simd2020v2quin

gennumdenom wimd2019quin, pre(wimd) num(5) pc by(hospcode)
drop wimd2019quin

gennumdenom admissionday, pre(admitday) num(7) pc by(hospcode)
drop admissionday

gennumdenom q4_1badmissiontimecat, pre(admittime) num(12) pc by(hospcode)
drop q4_1badmissiontimecat

gennumdenom q10_1dischargelifestatus, pre(died) pc by(hospcode)
drop q10_1dischargelifestatus

gennumdenom q5_1respiratoryreview, pre(resprev) pc by(hospcode)
drop q5_1respiratoryreview

gennumdenom reviewwithin24hrs, pre(revin24hrs) pc by(hospcode)
drop reviewwithin24hrs

gennumdenom q6_1oxygenprescribedduringad, pre(o2presc) pc by(hospcode)
drop q6_1oxygenprescribedduringad

gennumdenom q6_1aoxygenstipulatedtargetr, pre(o2targ) num(4) pc by(hospcode)
drop q6_1aoxygenstipulatedtargetr

gennumdenom q6_2oxygenadministeredduring, pre(o2admin) pc by(hospcode)
drop q6_2oxygenadministeredduring

gennumdenom q7_1acutetreatmentwithniv, pre(niv) pc by(hospcode)
drop q7_1acutetreatmentwithniv

gennumdenom nivwithin2hrs, pre(nivin3hrs) num(2) zero pc by(hospcode)
drop nivwithin2hrs

gennumdenom nivtime, pre(nivtime) num(3) pc by(hospcode)
drop nivtime

gennumdenom anyspirom, pre(spirom) pc by(hospcode)
drop anyspirom

gennumdenom obstruction, pre(obstruction) pc by(hospcode)
drop obstruction

gennumdenom q2_5smokingstatus, pre(smokstat) num(6) pc by(hospcode)
drop q2_5smokingstatus

gennumdenom q10_4discharge_smokingcess, pre(smokcess) pc by(hospcode)
drop q10_4discharge_smokingcess

gennumdenom news2source, pre(news2) num(2) zero pc by(hospcode)
drop news2source

gennumdenom news2, pre(news2score) num(20) zero pc by(hospcode)
drop news2

gennumdenom q9_1historyofcardiovasculard, pre(histcv) pc by(hospcode)
drop q9_1historyofcardiovasculard

gennumdenom q9_1aifyes, pre(cvintervention) pc by(hospcode)
drop q9_1aifyes

gennumdenom q9_2historyofhistoryofmental, pre(histmental) pc by(hospcode)
drop q9_2historyofhistoryofmental

gennumdenom q9_2aifyes, pre(mentalintervention) pc by(hospcode)
drop q9_2aifyes

gennumdenom dischargeday, pre(dischargeday) num(7) pc by(hospcode)
drop dischargeday

gennumdenom q10_3dischargebundlecomplete, pre(bundle) num(2) zero pc by(hospcode)
drop q10_3dischargebundlecomplete


foreach bundlevar of local bundlevars {
	
	local bundleprefix = substr("`bundlevar'", 16, .)
	
	gennumdenom `bundlevar', pre(bun_`bundleprefix') pc by(hospcode)
	drop `bundlevar'
}


by hospcode: keep if _n == 1


export excel using "outputs/COPD_SCC2020_Analysis_`date'.xlsx", cell(A6) sheetmodify


log using outputs/COPD_SCC_ResultsOutput_Labels, text replace
label list
log close
