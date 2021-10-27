clear
set more off

cd "C:\Users\pstone\OneDrive - Imperial College London\Work\National Asthma and COPD Audit Programme\2020 COPD Clinical Audit"


local data_dir "D:\National Asthma and COPD Audit Programme (NACAP)\2020 COPD Clinical Audit"

local country = "Wales"

/* create log file */
capture log close
log using analysis_logs/COPD_SCC_Analysis_`country', smcl replace


use "`data_dir'/builds/COPD_SCC_2020_build", clear

label list country
keep if country == 3
tab country, missing

do analysis_scripts/COPD_SCC_Analysis


log close

translate analysis_logs/COPD_SCC_Analysis_`country'.smcl ///
		  outputs/COPD_SCC_Analysis_`country'.pdf, replace
