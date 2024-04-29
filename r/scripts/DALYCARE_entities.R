## DALYCARE ENTITIES 
# Created:
## Sys.Date() # "2024-04-25"

## Loads RKKP dalycare_dx and divides patients into different LC entities 
source('/ngc/projects2/dalyca_r/clean_r/load_dalycare_entities.R') #Also saved as #load_dalycare_icd10()

t_dalycare_diagnoses$diagnosis

CLL = t_dalycare_diagnoses %>% 
  filter_first_diagnosis(ICD10.CLL, str_contains = F)
SLL = t_dalycare_diagnoses %>% 
  filter_first_diagnosis(ICD10.SLL, str_contains = F)
FL = t_dalycare_diagnoses %>% 
  filter_first_diagnosis(ICD10.FL, str_contains = F)
MCL = t_dalycare_diagnoses %>% 
  filter_first_diagnosis(ICD10.MCL, str_contains = F)
HL = t_dalycare_diagnoses %>% 
  filter_first_diagnosis(ICD10.HL, str_contains = F)
LPL = t_dalycare_diagnoses %>% 
  filter_first_diagnosis(ICD10.LPL, str_contains = F)
MZL = t_dalycare_diagnoses %>% 
  filter_first_diagnosis(ICD10.MZL, str_contains = F)
DLBCL = t_dalycare_diagnoses %>% 
  filter_first_diagnosis(ICD10.DLBCL, str_contains = F)
BL = t_dalycare_diagnoses %>% 
  filter_first_diagnosis(ICD10.BL, str_contains = F)
MM = t_dalycare_diagnoses %>% 
  filter_first_diagnosis(ICD10.MM, str_contains = F)
MGUS = t_dalycare_diagnoses %>% 
  filter_first_diagnosis(ICD10.MGUS, str_contains = F)

ENTITIES = bind_rows(CLL %>% mutate(Disease = 'CLL'), 
                     SLL %>% mutate(Disease = 'SLL'), 
                     FL %>% mutate(Disease = 'FL'), 
                     MCL %>% mutate(Disease = 'MCL'), 
                     LPL %>% mutate(Disease = 'LPL'), 
                     MZL %>% mutate(Disease = 'MZL'), 
                     DLBCL %>% mutate(Disease = 'DLBCL'), 
                     BL %>% mutate(Disease = 'BL'), 
                     HL %>% mutate(Disease = 'cHL'), 
                     MM %>% mutate(Disease = 'MM'), 
                     MGUS %>% mutate(Disease = 'MGUS')) %>% 
  mutate(Disease = factor(Disease, levels = c('cHL',  'FL', 'MZL', 'SLL','CLL', 'LPL',  'DLBCL',  'BL', 'MCL','MM', 'MGUS'))) %>% 
  mutate(Age = diff_years(date_birth, date_diagnosis))

ENTITIES %>% filter(time_dx_death <0) %>% n_patients() ##!
cat(paste0('\nENTITIES has ', ENTITIES %>% n_patients(), ' patients in ', ENTITIES %>% nrow(), ' rows\n'))
quantile(prodlim(Hist(time_dx_death, status) ~ 1, 
                 data=ENTITIES %>% filter(time_dx_death >= 0),
                 reverse=TRUE)) # Median FU time (years)
