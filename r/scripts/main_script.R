#### DALY-CARE main script ####
## Sources scripts to DALY-CARE methods paper 2024
## Sys.Date() #"2024-04-25"

SAVE = TRUE #Saves all Figure tables if TRUE
setwd('insert_your_wd_for_where_to_save_output_if_SAVE = T') #
# setwd('/ngc/projects2/dalyca_r/clean_r/shared_projects/end_of_project_scripts_to_gihub/DALYCARE_methods/output/') # E.g.

source('/ngc/projects2/dalyca_r/clean_r/shared_projects/end_of_project_scripts_to_gihub/DALYCARE_methods/Table1.R') #output Table 1 + Table S6 #ETA 1 min
source('/ngc/projects2/dalyca_r/clean_r/shared_projects/end_of_project_scripts_to_gihub/DALYCARE_methods/DALYCARE_entities.R') # creates dalycare entities #ETA 0.1 min
source('/ngc/projects2/dalyca_r/clean_r/shared_projects/end_of_project_scripts_to_gihub/DALYCARE_methods/TRIANGLE.R') #output Figure 2 #ETA 2-3 min
source('/ngc/projects2/dalyca_r/clean_r/shared_projects/end_of_project_scripts_to_gihub/DALYCARE_methods/CCI_polyRX.R') #Calculates CCI scores and polypharmacy # ETA 6-8 min
source('/ngc/projects2/dalyca_r/clean_r/shared_projects/end_of_project_scripts_to_gihub/DALYCARE_methods/Table_3.R') # output Figure 3 + Table 3 + Table S7 # 0.5 min
source('/ngc/projects2/dalyca_r/clean_r/shared_projects/end_of_project_scripts_to_gihub/DALYCARE_methods/IPI_raw.R') #output Table S9 ##ETA 2-3 mins
source('/ngc/projects2/dalyca_r/clean_r/shared_projects/end_of_project_scripts_to_gihub/DALYCARE_methods/Polypharmacy_cox.R') #output Figure 4 + Figure S1 # ETA 1 min