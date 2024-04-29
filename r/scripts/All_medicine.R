## All_medicine 
# Created:
## Sys.Date() # "2024-04-25"
## Defines all prescription medicine

load_dataset(c('SDS_ekokur', 'SDS_epikur', 'SDS_indberetningmedpris', 'SP_Administreret_Medicin', 'SP_OrdineretMedicin'))
# PATIENT_OS = load_PATIENT_OS() # rplaced by patient_view

SDS_ekokur %>% head2
SDS_epikur %>% head2
SDS_indberetningmedpris %>% head2
SDS_indberetningmedpris %>% ls

SP_Administreret_Medicin %>% head2
SP_OrdineretMedicin %>% head2

SDS_ekokur$eksd %>% head() %>% as.numeric() %>% as.Date(origin  = '1970-01-01')
SP_Administreret_Medicin$taken_time%>% head %>% clean_Date()
SP_OrdineretMedicin$order_start_time %>% head %>% as_date()
SDS_ekokur %>% head2
SDS_indberetningmedpris$d_adm %>% head
SDS_indberetningmedpris %>% 
  head() %>% 
  transmute(patientid,
            date = clean_Date(as.numeric(d_adm)),
            atc = c_atc,
            source = 'SMR') %>% 
  pull(date) 

Medicine_all = bind_rows(SDS_ekokur %>% transmute(patientid,
                                                  date = as.Date(as.numeric(eksd), origin  = '1970-01-01'),
                                                  atc,
                                                  source = 'LSR'),
                         SDS_ekokur %>% transmute(patientid,
                                                  date = as.Date(as.numeric(eksd), origin  = '1970-01-01'),
                                                  atc,
                                                  source = 'LSR'),
                         SDS_indberetningmedpris %>% transmute(patientid,
                                                               date = clean_Date(d_adm),
                                                               atc = c_atc,
                                                               source = 'SMR'),
                         SP_Administreret_Medicin %>% transmute(patientid,
                                                               date = clean_Date(taken_time),
                                                               atc = atc,
                                                               source = 'SP'),
                         SP_OrdineretMedicin %>% transmute(patientid,
                                                                date = as_date(order_start_time),
                                                                atc = atc,
                                                                source = 'SP')) %>% 
  distinct() %>% 
  filter(patientid %in% view_patient$patientid) %>% 
  filter(date > as.Date('1970-01-01'),
         date < as.Date('2023-11-01'))
Medicine_all$date %>% summary
Medicine_all %>% nrow_npatients()
view_patient %>% n_patients()
write_csv(Medicine_all, '/ngc/projects2/dalyca_r/chribr_r/DALYCARE/data/ALL_ATC_all.csv')

rm(list = c('SDS_ekokur', 'SDS_epikur', 'SDS_indberetningmedpris', 'SP_Administreret_Medicin', 'SP_OrdineretMedicin'))
  