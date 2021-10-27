//SECTION 1: General information

//Average age
//hist age, discrete normal  //normally distributed
sum age, detail
bysort gender: sum age

//Gender ratio
tab gender, mi

//Proportion of patients in each quintile of IMD
tab imd2019quin
tab simd2020v2quin
tab wimd2019quin

//Average number of admissions per hospital
preserve
bysort hospitalcode: keep if _n == 1
sum hospadmissions, detail
restore

//Average time from arrival to admission
sum admitwaithours, detail

//Day & time of admission
tab q4_1badmissiontimecat admissionday, col mi

//Average length of stay
sum lengthofstay, detail

//Proportion of patients that died as an in-patient
tab q10_1dischargelifestatus, mi


//SECTION 2: Respiratory review

//Proportion of patients reviewed by an acute physician
tab q5_1respiratoryreview, mi

//Proportion of patients reviewed by a member of the specialist review team within 24 hours of admission
tab reviewwithin24hrs, mi

//Average time form admission to specialist review
sum reviewwaithours, detail


//SECTION 3: Oxygen

//Proportion of patients prescibed oxygen
tab q6_1oxygenprescribedduringad, mi

//If O2 prescribed, was it to a target range
tab q6_1aoxygenstipulatedtargetr if q6_1oxygenprescribedduringad == 1, mi

//Oxygen administered (in those prescribed)
tab q6_2oxygenadministeredduring if q6_1oxygenprescribedduringad == 1, mi


//SECTION4: Non-invasive ventilation (NIV)

//Proportion of patients that receive NIV
tab q7_1acutetreatmentwithniv, mi

//Proportion receiving NIV in 2 hours
tab nivwithin2hrs

//Average time from arrival to NIV
sum nivwaithours, detail
tab nivtime


//SECTION 5: Spirometry

//Proportion of patients that have any spirometry result
tab anyspirom, mi

//Degree of airflow obstruction
tab obstruction

//Median FEV1 % predicted for patients with recent spirometry
sum q8_1mostrecentlyrecordedfev1, detail


//SECTION 6: Smoking

//Proportion of patients asked about smoking status
tab q2_5smokingstatus, mi

//Proportion prescribed stop smoking pharmacotherapy
tab q10_4discharge_smokingcess if q2_5smokingstatus == 3, mi


//SECTION 7: Acute observation

//NEWS2 score recorded
tab news2source, mi

//NEWS2 score
tab news2 if news2source != 0, mi


//SECTION 8: Comorbidites

//History of CV disease recorded
tab q9_1historyofcardiovasculard, mi
tab q9_1aifyes if q9_1historyofcardiovasculard == 1, mi

//History of mental illness recorded
tab q9_2historyofhistoryofmental, mi
tab q9_2aifyes if q9_2historyofhistoryofmental == 1, mi


//SECTION 9: Discharge processes - I've excluded patients that died

//Day of discharge
tab dischargeday if q10_1dischargelifestatus != 1, mi

//Proportion of patients who received a discharge bundle
tab q10_3dischargebundlecomplete if q10_1dischargelifestatus != 1, mi

//Discharge elements received
tab1 q10_4discharge_inhaler q10_4discharge_medication q10_4discharge_selfmanagement ///
	 q10_4discharge_drugprovided q10_4discharge_drugnotprovided q10_4discharge_oxygen ///
	 q10_4discharge_smokingcess q10_4discharge_pr q10_4discharge_followup q10_4discharge_mdt ///
	 q10_4discharge_blfpassport q10_4discharge_none if q10_1dischargelifestatus != 1, mi


//SECTION 10: Sub-analyses

//exposures
tab niv2hrbin_excl24   //also used as outcome
tab reviewwithin24hrs

//outcomes
tab longstay
tab q10_1dischargelifestatus
tab q6_1oxygenprescribedduringad
tab q10_4discharge_smokingcess
tab dischargebin


//NIV

//Association between time from arrival to NIV and length of stay
tab longstay niv2hrbin_excl24, col chi

//Association between time from arrival to NIV and in-patient mortality
tab q10_1dischargelifestatus niv2hrbin_excl24, col chi


//Respiratory specialist review

//Association between specialist review in 24 hours and length of stay
tab longstay reviewwithin24hrs, col chi

//Association between specialist review in 24 hours and in-patient mortality
tab q10_1dischargelifestatus reviewwithin24hrs, col chi

//Association between specialist review in 24 hours and oxygen prescription
tab q6_1oxygenprescribedduringad reviewwithin24hrs, col chi

//Association between specialist review in 24 hours and receiving NIV in 2 hours
tab niv2hrbin_excl24 reviewwithin24hrs, col chi

//Association between specialist review in 24 hours and receiving smoking cessation pharmacotherapy
tab q10_4discharge_smokingcess reviewwithin24hrs if q2_5smokingstatus == 3, col chi

//Association between specialist review in 24 hours and receipt of a discharge bundle
tab dischargebin reviewwithin24hrs, col chi
