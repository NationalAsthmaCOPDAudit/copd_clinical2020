clear
set more off

cd "C:\Users\pstone\OneDrive - Imperial College London\Work\National Asthma and COPD Audit Programme\2020 COPD Clinical Audit"


local data_dir "D:\National Asthma and COPD Audit Programme (NACAP)\2020 COPD Clinical Audit"


//Welsh Index of Multiple Deprivation 2019
import delimited ///
	   "`data_dir'/raw_data/IMD/welsh-index-multiple-deprivation-2019-index-and-domain-ranks-by-small-area_DecileQuintileQuartile.csv" ///
	   , asdouble clear

keep lsoacode wimd2019overallquintile

rename lsoacode lsoa11cd
rename wimd2019overallquintile wimd2019quin

compress
save "`data_dir'/stata_data/IMD/wimd2019", replace


//Scottish Index of Multiple Deprivation 2020 v2
import excel ///
		"`data_dir'/raw_data/IMD/SIMD+2020v2+-+postcode+lookup%232.xlsx" ///
		, sheet("All postcodes") firstrow case(lower) clear

keep dz simd2020v2_quintile

rename dz lsoa11cd
rename simd2020v2_quintile simd2020v2quin

bysort lsoa11: keep if _n == 1

compress
save "`data_dir'/stata_data/IMD/simd2020v2", replace


//English Index of Multiple Deprivation 2019
import excel ///
		"`data_dir'/raw_data/IMD/File_1_-_IMD2019_Index_of_Multiple_Deprivation" ///
	   , sheet("IMD2019") firstrow case(lower) clear
	   
keep lsoacode2011 f

rename lsoacode2011 lsoa11cd
rename f imd2019decile

gen imd2019quin = ceil(imd2019decile/2)

tab imd2019decile imd2019quin, missing

drop imd2019decile

compress
save "`data_dir'/stata_data/IMD/imd2019", replace


//Hospital country codes
import delimited "`data_dir'/raw_data/COPD-OrgList1912.csv", varnames(1) clear

keep trust code name country

rename code hospitalcode
rename name hospital
rename trust trustcode

label define country 1 "England" 2 "Scotland" 3 "Wales"
replace country = "1" if country == "England"
replace country = "2" if country == "Scotland"
replace country = "3" if country == "Wales"
destring country, replace
label values country country

compress
save "`data_dir'/stata_data/hospitals", replace
