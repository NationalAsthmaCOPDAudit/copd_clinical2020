clear
set more off

cd "C:\Users\pstone\OneDrive - Imperial College London\Work\National Asthma and COPD Audit Programme\2020 COPD Clinical Audit"


local data_dir "D:\National Asthma and COPD Audit Programme (NACAP)\2020 COPD Clinical Audit"


//BRO fixes
import delimited "`data_dir'/raw_data/NACAP-BRO-Fix-v102.csv", asdouble clear

rename v16 news2

keep studyid news2

save "`data_dir'/stata_data/news2_fix", replace
