## Table 1
# Sys.Date() # "2024-04-25"

#### Prepare data ####s
source('/ngc/projects2/dalyca_r/clean_r/load_data.R')

load_dataset(c('t_dalycare_diagnoses', 'patient', 'ICDO3_to_ICD10_1_to_1'))

ICD10_key = ICDO3_to_ICD10_1_to_1 %>%
  transmute(icd10 = paste0('D', gsub('\\.', '',icd10_code_out)),
            label = icd10_label_out) %>%
  distinct()

ALL_ICD10 = t_dalycare_diagnoses %>% 
  select(patientid, date = date_diagnosis, icd10 = diagnosis, source = tablename, source2 = datasource) %>% 
  filter(date < as.Date('2024-1-1'),
         str_detect(icd10, 'DC92', negate = T))

##### TABLE 2 #####
ALL_ICD10.1 = ALL_ICD10 %>%
  select(patientid, icd10) %>% 
  distinct() %>% 
  mutate(N = n_distinct(patientid)) %>% 
  group_by(icd10) %>% 
  arrange(icd10) %>% 
  mutate(n = n()) %>% 
  slice(1) %>% 
  ungroup() %>% 
  select(-patientid) %>% 
  arrange(desc(n)) %>% 
  mutate(freq = round((n/N)*100, 1),
         freq = ifelse(str_detect(freq, '\\.'), paste0(freq, '%'), paste0(freq, '.0%'))) %>% 
  left_join(Codes_DST_DIAG_CODES %>% select(icd10 = Kode, Disease = Tekst), by = 'icd10' ) %>% 
  select(Disease, icd10, n, freq) %>% 
  mutate(Disease = ifelse(icd10 == 'DD472A', 'MGUS af IgM type', Disease),
         Disease = ifelse(icd10 == 'DD472B', 'MGUS af non-IGM type', Disease)) %>% 
  left_join(ICD10_key, 'icd10') %>% 
  mutate(label = ifelse(is.na(label), icd10, label),
         label = recode(label,
                        DC911 = 'Chronic lymphocytic leukaemia',
                        DC81 = 'Hodgkin lymphoma', DC817 = 'Other Hodgkin lymphoma', DC82 = 'Follicular lymphoma', 
                        DC825 = 'Diffuse follicle center lymphoma', DC827 = 'Other follicular lymphoma', 
                        DC83 = 'Non-follicular lymphoma', DC830B = 'Lymphoplasmacytic lymphoma', 
                        DC830C = 'Nodal marginal zone lymphoma', 
                        DC830D = 'Splenic marginal zone lymphoma', 
                        DC831A = 'Centrocystic lymphoma', DC831B = 'Malignt lymphomatous polyposis',  #
                        DC832 = 'Lymphoma mal non-Hodgkin diffuse type mixed small and large cell', 
                        DC833A = 'Anaplastic diffuse large cell B cell lymphaoma', 
                        DC833B = 'CD30-positive diffuse large B cell lymphoma', 
                        DC833C = 'Centroblastic diffuse large B cell lymphoma', 
                        DC833D = 'Immunoblastic diffuse large B cell lymphoma', 
                        DC833E = 'Plasmablastic diffuse large B cell lymphoma', 
                        DC833F = 'T cell rich diffuse large B cell lymphoma', 
                        DC834 = 'Lymphoma mal non-Hodgkin diffuse immunoblastic type', 
                        DC835A = 'Lymphoblastic B cell lymphoma', 
                        DC835B = 'Lymphoblastic T cell lymphoma',  
                        DC835C = 'Lymphoblastic lymphoma UNS',  
                        DC836 = 'Lymphoma mal non-Hodgkin diffuse undifferentiated type', 
                        DC837A = 'Atypic Burkitt lymphoma', 
                        DC837B = 'Burkitt-like lymphoma', 
                        DC838A = 'Primary effusion lymphoma (PEL)', 
                        DC838B = 'Intravascular large B-cell lymphoma', 
                        DC839 = 'Non-follicular (diffuse) lymphoma, UNS', DC84 = 'Mature T/NK-cell lymphomas', 
                        DC840A = 'Mycosis fungoides associated with follicular mucinosis', 
                        DC840B = 'Pagetoid reticulosis', 
                        DC840C = 'Granulomatous slack skin (lymphoma malignum)', 
                        DC842 = 'T-zone lymphoma', DC843 = 'Lymphoepithelial lymphoma', 
                        DC844A = 'Large pleomorphic CD30+ T cell lymphoma', 
                        DC844D = 'Large immunoblastic CD30+ T cell lymphoma', 
                        DC844E = 'Small/medium pleomorphic T cell lymphoma', 
                        DC844F = 'Lymphoepithelial lymphoma', 
                        DC844H = 'Mature T-cell lymphoma UNS', 
                        DC845A = 'Large anaplastic CD30+ T cell lymphoma',  
                        DC845B = 'Primary cutaneous anaplastic CD30+ large cell lymphoma', 
                        DC845C = 'Subcutaneous panniculitis-like T-cell lymphoma (SPTCL)', 
                        DC845D = 'Angiocentric T/NK cell lymphoma', 
                        DC846A = 'CD30+ anaplastic large cell lymphoma (ALCL)', 
                        DC847 = 'Anaplastic large cell lymphoma, ALK-negative', 
                        DC849 = 'Mature T/NK-cell lymphomas, UNS', DC85 = 'Other non-Hodgkin lymphoma', 
                        DC850 = 'Lymphosarcoma', DC851 = 'B cell lymphoma, UNS', 
                        DC851A = 'Follicle centre B cell lymphoma', DC851B = 'Marginal zone B cell lymphoma (immunocytoma)', 
                        DC851C = 'Diffuse large B cell lymphoma', DC851D = 'T cell rich B cell lymphoma', 
                        DC851E = 'Large cell intravascular B cell lymphoma', 
                        DC857B = 'Polymorphic post-transplantat lymphoproliferative disorder (PTLD)', 
                        DC859  = 'Bon-Hodgkin lymphoma, UNS',
                        DC859A = 'Malignant lymphoma UNS', DC859B = 'Lymphoma UNS', 
                        DC86 = 'Other T/NK-cell lymphoma', DC864 = 'Blastic NK cell lymphoma', 
                        DC866A = 'Lymphomatoid papulosis', DC866B = 'Primary cutaneous anaplastic large cell lymphoma (PCALCL)', 
                        DC866C = 'Primary cutaneous CD30-positive large cell lymphoma', 
                        DC88 = 'Malignant immunoproliferative diseases and certain other B-cell lymphomas', 
                        DC881 = 'Paraproteinaemia alpha heavy chain', DC882A = 'Gamma heavy chain disease', 
                        DC882B = 'My heavy chain disease', DC883A = 'Alpha heavy chain disease', 
                        DC884A = 'Mucosa-associated lymphoid tissue lymphoma', 
                        DC884B = 'Skin-associated lymphoid tissue lymphoma',
                        DC884C = 'Bronchus-associated lymphoid tissue lymphoma', 
                        DC90 = 'Multiple myeloma and malignant plasma cell neoplasms', 
                        DC902A = 'Myeloma solitarium', DC903 = 'Solitary plasmacytoma', 
                        DC91 = 'Lymphoid leukemia', DC911A = 'Lymphoplasmacytic leukemia', 
                        DC911B = 'Richter syndrome', DC912 = 'Leukemia lymphatica subacuta', 
                        DC915B = 'Adult T-cell lymphoma/leukemia (ATL), chronic variant', 
                        DC915C = 'Adult T-cell lymphoma/leukemia (ATL), lymphomatoid variant', 
                        DC915D = 'Adult T-cell lymphoma/leukemia (ATL), smoldering variant', 
                        DC917B = 'Large granular T cell lymfocytic leukemia', 
                        DC951 = 'Chronic leukemia of unspecified cell type', DC957 = 'Leukemia UNS', 
                        DD472A = 'IgM type MGUS', DD472B = 'Non-IgM type MGUS', DD479B = 'Monoclonal B cell lymphocytosis (MBL)', 
                        DE858A = 'AL amyloidosis')) %>% 
  mutate(n = ifelse(n<5, '<5', as.character(n))) %>% 
  select(-Disease) %>% 
  select(Disease = label, ICD10 = icd10, n, freq)

ALL_ICD10.1  %>% filter(is.na(Disease)) %>% pull(ICD10) %>% sort() %>% paste0(collapse = ' = , ')
ALL_ICD10.1$Disease_eng %>% unique %>% sort
ALL_ICD10.1

if(SAVE == TRUE){
  write_csv2(ALL_ICD10.1, paste0(getwd(), '/Table_S6_patients_long.csv'))
  write_csv2(ALL_ICD10.1 %>%  head(20), paste0(getwd(), '/Table_1.csv'))
}


TOP20 = ALL_ICD10.1 %>%  head(20) %>% pull(ICD10)

#### LC DX EPIDEMIO ####

ALL_ICD10 %>% n_patients()
ALL_ICD10.1_2 = ALL_ICD10 %>% 
  group_by(patientid, icd10) %>% 
  arrange(date) %>% 
  slice(1) %>% 
  ungroup() 

ALL_ICD10.1_2 %>% nrow_npatients

ALL_ICD10.1_3 = ALL_ICD10.1_2 %>% 
  group_by(patientid) %>% 
  mutate(N = n()) %>% 
  slice(1) %>% 
  ungroup() %>% 
  mutate(N.cut = cut(N, c(0, 1,2, 3,4, Inf)))

cat('Patients with n no. of dalycare diagnoses:')
ALL_ICD10.1_3 %>% nrow_npatients()
ALL_ICD10.1_3$N %>% table
ALL_ICD10.1_3$N.cut %>% table #REPORT
ALL_ICD10.1_3$N.cut %>% table%>% prop.table()#REPORT

cat('Proportion of patients with TOP10 dalycare diagnoses:')
ALL_ICD10 %>% 
  filter(icd10 %in% TOP20) %>% 
  n_patients()/ n_patients(patient) # Report


