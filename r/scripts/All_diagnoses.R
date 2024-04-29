#### ALL DIAGNOSES ####
##### RKKP #####
rm(LOAD)
source('/ngc/projects2/dalyca_r/clean_r/load_data.R')

load_dataset(c('RKKP_LYFO', 'RKKP_CLL', 'RKKP_DaMyDa'))
RKKP_DAMYDA = RKKP_DaMyDa
RKKP_CLL$Reg_Umuteret %>% table
RKKP_CLL %>% names %>% head(10)
RKKP_CLL2 = RKKP_CLL %>% 
  transmute(patientid, 
            Date_diagnosis = as.Date(Reg_Diagnose_dt, format = '%d/%m/%Y'),
            icd10 = 'DC911') 

RKKP_DAMYDA %>% names %>% head(15)
RKKP_DAMYDA$Reg_Diagnose %>% table
RKKP_DAMYDA2= RKKP_DAMYDA %>% 
  transmute(patientid, 
            Date_diagnosis = as.Date(Reg_Diagnose_dt, format = '%d/%m/%Y'),
            icd10 = recode(Reg_Diagnose, 
                           `9730`  = 'DC900',  #SMM
                           `9731` = 'DC903', ## solitært knogleplasmacytom == Solitært ossøst plasmacytom
                           `9732 ` = 'DC900',
                           `9733` = 'DC901',
                           `9734` = 'DC902'))
  

RKKP_LYFO$Reg_DiagnostiskBiopsi_dt %>% table
RKKP_LYFO2 = RKKP_LYFO %>%
  mutate(patientid = as.integer(patientid),
         Date_diagnosis = as.Date(Reg_DiagnostiskBiopsi_dt, format = '%d/%m/%Y'),
         LYMPHOMA_type_short = recode_factor(Reg_WHOHistologikode1, 
                                             `9591` = 'NHL_NOS',
                                             `9610` ='iNHL',
                                             `9650` = 'cHL_NOS',
                                             `9651` = 'cHL_lr',
                                             `9652` = 'cHL_mc',
                                             `9653` = 'cHL_ld',
                                             `9659` = 'NLP_HL',
                                             `9663` = 'cHL_ns',
                                             `9670` = 'SLL',
                                             `9671` = 'LPL',
                                             `9673` = 'MCL',
                                             `9679` = 'PMBCL',
                                             `9680` = 'DLBCL',
                                             `9689` = 'SMZL',
                                             `968H` = '968H Unknown, not in SNOMED ICD3-O',
                                             `968I` = '968I Unknown, not in SNOMED ICD3-O',
                                             `9690` = 'FL_NOS',
                                             `9691` = 'FL1',
                                             `9695` = 'FL2',
                                             `9698` = 'FL3',
                                             `9699` = 'EMZL',
                                             `9735` = 'PBL')) %>% 
  select(patientid, Date_diagnosis, LYMPHOMA_type_short, everything())
RKKP_LYFO2$Date_diagnosis %>% class
RKKP_ICD10 = bind_rows(RKKP_CLL2 %>% transmute(patientid, Date_diagnosis, DX = icd10, source = 'RKKP'),
                       RKKP_LYFO2 %>% transmute(patientid, Date_diagnosis, DX = LYMPHOMA_type_short, source = 'RKKP'),
                       RKKP_DAMYDA2 %>% transmute(patientid, Date_diagnosis, DX = icd10, source = 'RKKP')) %>% 
  mutate(DX = recode(DX, 
                     NLP_HL = 'DC810',
                     cHL_ns = 'DC811', #nodulær
                     cHL_mc = 'DC812', #blandet cell
                     cHL_ld = 'DC813', #lymfocytfattigt 
                     cHL_lr = 'DC814', #lymfocytrigt
                     cHL_NOS = 'DC819', #UNS 
                     FL1 = 'DC820', 
                     FL2 = 'DC821',
                     FL3 = 'DC822',   
                     FL_NOS = 'DC829', 
                     SLL = 'DC830',
                     LPL = 'DC830B', 
                     SMZL = 'DC830D', 
                     MCL = 'DC831', 
                     DLBCL = 'DC833',
                     PBL  = 'DC833E',
                     PMBCL = 'DC852', 
                     NHL_NOS = 'DC857', #NOS
                     iNHL = 'DC857', #NOS
                     EMZL = 'DC884',
                     `Unknown, not in SNOMED ICD3-O` = 'DC857', #NOS
                     `968H Unknown, not in SNOMED ICD3-O` = 'DC857', #NOS
                     `968I Unknown, not in SNOMED ICD3-O` = 'DC857', #NOS
                     MM = 'DC900',
                     SMM = 'DC900',
                     PCL = 'DC901',
                     eSM = 'DC902',
                     bSM = 'DC903',
                     CLL = 'DC911')) %>% 
  dplyr::rename(date = Date_diagnosis,
                icd10 = DX)
RKKP_ICD10$date
# write_csv2(RKKP_ICD10, '/ngc/projects2/dalyca_r/chribr_r/DALYCARE/data/RKKP_diagnoses.csv')
RKKP_ICD10 %>% nrow_npatients()
RKKP_ICD10 = read_csv2('/ngc/projects2/dalyca_r/chribr_r/DALYCARE/data/RKKP_diagnoses.csv')
RKKP_ICD10$date %>% summary

#### LPR ####
load_dataset(c('SDS_t_tumor', 'SDS_t_adm', 'SDS_t_diag', 'SDS_t_dodsaarsag_2', 'Codes_DST_DIAG_CODES'))

SDS_t_adm$k_recnum
SDS_t_adm %>% head(3)
SDS_t_diag2$c_tildiag %>% tail(50)
SDS_t_dodsaarsag_2 %>% head
SDS_t_diag %>% head2

Codes_ICD10.3 = Codes_ICD10 %>% 
  filter(nchar(icd10) >= 3)
SDS_t_diag %>% head2
SDS_t_diag2 = SDS_t_diag %>% 
  mutate(rec = v_recnum) %>% 
  left_join(SDS_t_adm %>% transmute(patientid, date = as.Date(d_inddto, origin = '1970-01-01'),
                                    c_adiag, rec = k_recnum), by = 'rec') %>% 
  mutate(icd10 = c_diag)

SDS_t_diag3 = SDS_t_diag %>% 
  mutate(rec = v_recnum) %>% 
  left_join(SDS_t_adm %>% transmute(patientid, date = as.Date(d_inddto, origin = '1970-01-01'),
                                    rec = k_recnum), by = 'rec') %>% 
  mutate(icd10 = c_tildiag) %>% 
  filter(icd10 %in% Codes_ICD10.3$icd10)

SDS_t_adm %>% head2
SDS_t_adm2 = SDS_t_adm %>% transmute(patientid, date = as.Date(d_inddto, origin = '1970-01-01'),
                        icd10 = c_adiag, rec = k_recnum)


SDS_t_dodsaarsag_3 = SDS_t_dodsaarsag_2 %>% 
  transmute(patientid, date = as.Date(d_statdato, origin = '1970-01-01'),
            c_dodtilgrundl_acme, c_dod_1a, c_dod_1b, c_dod_1c, c_dod_1d, X = 'ICD__10') %>% 
  gather('variable',  'icd10', -patientid, -date) %>% 
  mutate(icd10 = paste0('D', icd10))


LPR_ICD10_all = bind_rows(SDS_t_adm %>% transmute(patientid, date = as.Date(d_inddto, origin = '1970-01-01'),
                                              icd10 = c_adiag, source = 't_adm'),
                      SDS_t_tumor %>% transmute(patientid, date = as.Date(d_diagnosedato, origin = '1970-01-01'),
                                                icd10 = paste0('D', c_icd10), source = 't_tumor'),
                      SDS_t_diag2 %>% transmute(patientid, date, icd10 = c_diag, source = 't_diag'),
                      SDS_t_diag3 %>% transmute(patientid, date, icd10 = c_diag, source = 't_diag'),
                      SDS_t_dodsaarsag_3 %>% transmute(patientid, date, icd10, source = 't_dar')) %>% 
  distinct()  
LPR_ICD10_all$icd10 %>% head
LPR_ICD10_all %>% nrow()
# write_csv2(LPR_ICD10, '/ngc/projects2/dalyca_r/chribr_r/DALYCARE/data/LPR_ICD10_all.csv')
LPR_ICD10_all = read_csv2('/ngc/projects2/dalyca_r/chribr_r/DALYCARE/data/LPR_ICD10_all.csv')

#### LPR3 ####
SDS_DATASETS
load_dataset(c('SDS_diagnoser','SDS_kontakter',  'Codes_DST_DIAG_CODES', 'DALYCARE'))

SDS_diagnoser %>% head2
SDS_kontakter %>% head2

SDS_diagnoser2 = SDS_diagnoser %>%  
  transmute(dw_ek_kontakt, icd10 = diagnosekode, diagnosekode_parent) %>% 
  left_join(SDS_kontakter %>% transmute(patientid, 
                                        date = as.Date(dato_start, origin = '1970-01-01'), 
                                        dw_ek_kontakt),
            by = 'dw_ek_kontakt') %>% 
  select(-dw_ek_kontakt) %>% 
  mutate(X = 'ICD__10') %>% 
  gather('variable',  'icd10', -patientid, -date) %>% 
  mutate(source = 'LPR3') %>% 
  select(-variable) %>% 
  distinct()

# write_csv2(SDS_diagnoser2, '/ngc/projects2/dalyca_r/chribr_r/DALYCARE/data/LPR3_ICD10_all.csv')
LPR3_ICD10_all = read_csv2('/ngc/projects2/dalyca_r/chribr_r/DALYCARE/data/LPR3_ICD10_all.csv')

#### SP #####
load_dataset(dataset = c('SP_Behandlingskontakter_diagnoser',
                         # 'SP_Aktive_Problemliste_Diagnoser', 
                         'SP_ADT_haendelser')) #  Excluded 4/3-24 

# 'SP_Flytningshistorik',# no icd10

# SP_Aktive_Problemliste_Diagnoser %>% head2
# SP_aktiv = SP_Aktive_Problemliste_Diagnoser %>% 
#   transmute(patientid, 
#             date = as.Date(noted_date),
#             icd10 = current_icd10_list, 
#             source = 'SP') %>% 
#   distinct()

SP_ADT_haendelser %>% head2
SP_adt = SP_ADT_haendelser %>% 
  transmute(patientid, 
            date = as_date(kontakt_start_local_dttm),
            icd10 = current_icd10_list, 
            icd10.2 = current_icd10_list_2) %>% 
  distinct() %>% 
  gather('nons', 'icd10', -patientid, -date) %>% 
  mutate(source = 'SP') %>% 
  select(-nons) %>% 
  distinct() %>% 
  filter(icd10 != 'NULL')

SP_Behandlingskontakter_diagnoser %>% head2
SP_Beh = SP_Behandlingskontakter_diagnoser %>% 
  transmute(patientid, 
            date = clean_Date(kontaktdato),
            icd10 = skskode, 
            source = 'SP') %>% 
  mutate(date = as_date(as.character(date))) %>% 
  distinct()

SP_ICD10_all = bind_rows(
  # SP_aktiv,
                     SP_adt,
                     SP_Beh) %>% 
  distinct()

# write_csv2(SP_ICD10_all, '/ngc/projects2/dalyca_r/chribr_r/DALYCARE/data/SP_ICD10_all.csv')
SP_ICD10_all = read_csv2('/ngc/projects2/dalyca_r/chribr_r/DALYCARE/data/SP_ICD10_all.csv')

#### PATO ####
IMPORT.LOOKUP.TABLES
load_dataset(c('SDS_pato', 'Codes_DST_DIAG_CODES', "CTCAEv4.0tov5.0Mapping",
         "CTCAEv5.0CleanCopy", "CTCAEv5.0TrackedChanges", "ICD10_to_ICDO3",
         "ICDO3_to_ICD10_1_to_1", "ICDO3_to_ICD10_1_to_m"))

# KEY = ICDO3_to_ICD10_1_to_1 %>% 
#   mutate(snomed = paste0('M', morphology_code_in, dignity_in),
#          icd10 = paste0('D', gsub('\\.', '',icd10_code_out))) %>% 
#   select(snomed, icd10) %>% 
#   left_join(Codes_DST_DIAG_CODES %>% select(icd10 = Kode, text =Tekst), by = 'icd10') %>% 
#   distinct()
KEY = read_csv2('/ngc/projects2/dalyca_r/chribr_r/DALYCARE/data/snomed_icd10_reviewed.csv') %>% 
  group_by(snomed) %>% 
  slice(1) %>% 
  ungroup()

Codes_DST_DIAG_CODES %>% head
KEY$snomed %>% n_distinct()
KEY$icd10 %>% n_distinct()
KEY %>% head

SDS_pato2 = SDS_pato %>% 
  transmute(patientid, 
            date = as.Date(d_rekvdato, origin = '1970-01-01'), 
            snomed = c_snomedkode) %>% 
  filter(snomed %in% KEY$snomed) %>% 
  left_join(KEY %>% select(snomed, icd10), relationship = "many-to-many", by = 'snomed') %>% 
  distinct() %>% 
  select(-snomed) %>% 
  mutate(source = 'pato')
SDS_pato2$icd10 %>% table

# write_csv2(SDS_pato2, '/ngc/projects2/dalyca_r/chribr_r/DALYCARE/data/PATO_ICD10.csv')
SDS_pato2 = read_csv2('/ngc/projects2/dalyca_r/chribr_r/DALYCARE/data/PATO_ICD10.csv')

#### BYPASS DATA ####
RKKP_ICD10 = read_csv2('/ngc/projects2/dalyca_r/chribr_r/DALYCARE/data/RKKP_diagnoses.csv') # Only LC DX
LPR_ICD10_all = read_csv2('/ngc/projects2/dalyca_r/chribr_r/DALYCARE/data/LPR_ICD10_all.csv')
LPR3_ICD10_all = read_csv2('/ngc/projects2/dalyca_r/chribr_r/DALYCARE/data/LPR3_ICD10_all.csv')

SP_ICD10_all = read_csv2('/ngc/projects2/dalyca_r/chribr_r/DALYCARE/data/SP_ICD10_all.csv')
# SDS_pato2 = read_csv2('/ngc/projects2/dalyca_r/chribr_r/DALYCARE/data/PATO_ICD10.csv') # Only LC DX
PATO_ICD10 = read_csv2('/ngc/projects2/dalyca_r/chribr_r/DALYCARE/data/PATO_ICD10_reviewed.csv') ## Updated 4/1-24

PATIENT_OS = load_PATIENT_OS()
PATIENT_OS %>% n_patients()
LPR_ICD10$icd10 %>% head
ALL_ICD10$source %>% table
ALL_ICD10 %>% nrow_npatients()
ALL_ICD10_all = bind_rows(RKKP_ICD10,
                      LPR_ICD10_all,
                      LPR3_ICD10_all, #LPR3
                      SP_ICD10_all, #ok
                      # SDS_pato2,
                      PATO_ICD10) %>% 
  distinct() %>% 
  filter(patientid %in% view_patient$patientid) #4/3-24

ALL_ICD10_all %>% nrow_npatients()
DX.LONG = load_dalycare_dx_longformat()
DX.LONG %>% n_patients()
# write_csv2(ALL_ICD10_all, '/ngc/projects2/dalyca_r/chribr_r/DALYCARE/data/ALL_ICD10_all.csv')
ALL_ICD10_all = read_csv2('/ngc/projects2/dalyca_r/chribr_r/DALYCARE/data/ALL_ICD10_all.csv')
ALL_ICD10_all %>% n_patients()
#### END OF SCRIPT ####