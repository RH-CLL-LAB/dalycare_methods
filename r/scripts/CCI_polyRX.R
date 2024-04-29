## CCI & polyRx  
# Created:
## Sys.Date() # "2024-04-25"
## Calculates CCI score and polypharmacy

#### load data ####
SDS_DATASETS
load_dataset(c('SDS_ekokur', 'SDS_epikur', 'diagnoses_all'))

Medicine_all = bind_rows(SDS_ekokur %>% transmute(patientid,
                                                      date = as.Date(as.numeric(eksd), origin  = '1970-01-01'),
                                                      atc,
                                                      source = 'LSR'),
                             SDS_ekokur %>% transmute(patientid,
                                                      date = as.Date(as.numeric(eksd), origin  = '1970-01-01'),
                                                      atc,
                                                      source = 'LSR')) %>% 
  mutate(atc = gsub(':|_|\u008f\u008f|ÅÅ|XXX', '', atc),
         atc = gsub('Å', '', atc)) %>% 
  filter(! atc %in% c("N/A", "NUL", '', 'X')) # Time-lapse 15-20 min

load_dataset('diagnoses_all')

Medicine_all %>% nrow_npatients()
diagnoses_all %>% nrow_npatients()

#### CCI ####
# Load all diagnoses from all_diagnoses.R in DALYCARE folder
diagnoses_all %>% head2
ALL_ICD10_all = diagnoses_all %>% 
  filter(date_diagnosis > as.Date('1970-01-01'),
         date_diagnosis <= as.Date('2023-11-15'))

ALL_ICD10_all %>% nrow_npatients()

ALL_ICD10_all.1 = ALL_ICD10_all %>% 
  select(patientid, diagnosis) %>% 
  distinct() %>% #only distinct diagnoses 
  group_by(patientid) %>% 
  mutate(N = n()) %>% 
  slice(1) %>% 
  ungroup()

ALL_ICD10_all.1 %>% nrow_npatients()
cat('Median no. of distinct diagnoses')
utable(~Q(N), ALL_ICD10_all.1) ## Suppl. result

DX.FIRST = t_dalycare_diagnoses %>% 
  group_by(patientid) %>% 
  arrange(date_diagnosis) %>% 
  slice(1) %>% 
  ungroup()
ALL_ICD10_all %>% head2
DX.FIRST.DXX = DX.FIRST %>% 
  select(patientid, date_first_dx = date_diagnosis) %>% 
  left_join(ALL_ICD10_all %>% select(patientid, date_icd10 = date_diagnosis, icd10 = diagnosis)) %>% 
  filter(date_icd10 <= date_first_dx)

DX.FIRST.DXX %>% nrow_npatients()

DX.FIRST.CCI = DX.FIRST.DXX %>% 
  CCI(patientid = patientid, icd10 = icd10, include_LC_score = T)

DX.FIRST.CCI$CCI.Cancer.and.Hem.score %>% summary #Must be 2
DX.FIRST.CCI %>% names
utable(~ Q(CCI.2011.update), DX.FIRST.CCI)

##### PolyRX #####
if(SAVE == TRUE){
# save.image(paste0(getwd(), 'Before_calculating_PolyRx.RData'))
}
# load(paste0(getwd(), 'Before_calculating_PolyRx.RData')

Medicine_all$atc %>% unique() %>% sort
Medicine_all.1 = Medicine_all %>% 
  group_by(patientid) %>% 
  mutate(N = n()) %>% 
  slice(1) %>% 
  ungroup() %>% 
  right_join(patient, by = 'patientid') %>% 
  mutate(N = ifelse(is.na(N), 0, N))

## ANY ATC level
ggplot(Medicine_all) +
  geom_histogram(aes(date))
date_max_atc = Medicine_all$date %>% max
DX.FIRST %>% head2
DX.FIRST.ATC = DX.FIRST %>% 
  select(patientid, date_first_dx = date_diagnosis) %>% 
  filter(date_first_dx >= as.Date('2002-01-01'), # t_dalycare_diagnosis first date
         date_first_dx <= as.Date(date_max_atc)) %>%  #LSR max date
  left_join(Medicine_all %>% select(patientid, date_atc = date, atc), 'patientid') %>% 
  distinct()

DX.FIRST.ATC %>% nrow # REPORT in Suppl Info #n.Rx
DX.FIRST.ATC$atc %>% n_distinct() #n.ATC among Rx
DX.FIRST.ATC %>% n_patients() #sanity check

# LSR before first DX
DX.FIRST.ATC %>% head2
DX.FIRST.ATC$date_first_dx %>% summary
DX.FIRST.ATC2 = DX.FIRST.ATC %>% 
  mutate(Time = diff_days(date_first_dx, date_atc)) %>% 
  filter(Time <= 0,
         Time > -365.25) %>% 
  right_join(DX.FIRST %>% select(patientid, date = date_diagnosis) %>% 
               filter(date <= as.Date(date_max_atc)), 'patientid')
DX.FIRST.ATC2 %>% nrow_npatients()
DX.FIRST %>% nrow_npatients()

DX.FIRST.ATC2$date_first_dx %>% summary
DX.FIRST.POLY = DX.FIRST.ATC2 %>% 
  group_by(patientid, atc) %>% 
  slice(1) %>% 
  ungroup() %>% 
  group_by(patientid) %>% 
  mutate(n.ATC = n()) %>% 
  slice(1) %>% 
  ungroup() %>% 
  right_join(DX.FIRST %>% select(patientid, date = date_diagnosis) %>% 
               filter(date <= as.Date(date_max_atc)), 'patientid') %>% 
  mutate(n.ATC = ifelse(is.na(n.ATC), 0, n.ATC),
         Polypharmacy = ifelse(n.ATC < 5, 'No', 'Yes'))

DX.FIRST.POLY %>% nrow_npatients() # report Suppl info
DX.FIRST.POLY$n.ATC %>% summary
utable(~ Q(n.ATC) + Polypharmacy, DX.FIRST.POLY) # report Suppl. Info

