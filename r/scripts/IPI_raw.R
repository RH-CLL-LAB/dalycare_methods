## IPI RAW 
# Sys.Date() # "2024-04-26"
# Calculates all IPI/ISS

#### RKKP IPI ####
load_dataset(c('RKKP_CLL', 'RKKP_DaMyDa', 'RKKP_LYFO', 'LAB_IGHVIMGT'))
ALL_RKKP = c(RKKP_CLL$patientid, RKKP_DaMyDa$patientid, RKKP_LYFO$patientid) %>% unique()
ALL_RKKP %>% n_distinct()

## Join all patients! - 19/12-23
load_npu_common()
BIOCHEMISTRY = load_biochemistry(c(NPU.ALB, NPU.B2M, NPU.LDH, NPU.IGM, NPU.HGB, NPU.LEU, NPU.LYM, NPU.LDH)) %>% 
  filter(patientid %in% ALL_RKKP) %>% 
  clean_lab_values()

lab_helper = function(data, lab_name){
  name = lab_name
  npu_code = get(paste0('NPU.', {{lab_name}}))
  data %>% 
  filter(NPU %in% npu_code) %>% 
    transmute(patientid, 
              'date_{name}' := as_date(samplingdate), 
              '{name}_value' := value2)
}

B2M = BIOCHEMISTRY %>% 
  lab_helper(lab_name = 'B2M') %>% 
  mutate(B2M_lab = factor(ifelse(B2M_value < 4.0, '<4.0 mg/L', '>4.0 mg/L')))

ALB = BIOCHEMISTRY %>% 
  lab_helper(lab_name = 'ALB')

IGM = BIOCHEMISTRY %>% 
  lab_helper(lab_name = 'IGM')

HGB = BIOCHEMISTRY %>% 
  lab_helper(lab_name = 'HGB')

WBC =  BIOCHEMISTRY %>% 
  lab_helper(lab_name = 'LEU')

ALC = BIOCHEMISTRY %>% 
  lab_helper(lab_name = 'LYM')

LDH =  BIOCHEMISTRY %>% 
  lab_helper(lab_name = 'LDH')

#### CLL ####
RKKP_CLL %>% filter(CPR_Doedsdato != '') %>% nrow # Use this! 
RKKP_CLL %>% filter(FU_Doedsdato != '') %>% nrow

RKKP_CLL_clean = RKKP_CLL %>% 
  clean_RKKP_CLL() %>% 
  left_join(patient, 'patientid') %>%  
  left_join(LAB_IGHVIMGT %>% transmute(patientid, IGHVIMGT = factor(IGHV)), 'patientid') %>% 
  mutate(IGHV = if_else(is.na(IGHV), IGHVIMGT, IGHV)) %>% 
  left_join(B2M, 'patientid', relationship = "many-to-many") %>% 
  slice_closest_value(date_diagnosis, date_B2M, value = B2M_value, interval_days = c(-30, 30), name = 'B2M') %>% 
  mutate(B2M = if_else(is.na(B2M), B2M_lab, B2M)) %>% 
  CLL_IPI() %>%
  mutate(CLL.IPI = if_else(IPI.score.minus.B2M >= 7, 'Very high', CLL.IPI),
         CLL.IPI = if_else(IPI.score.minus.IGHV >= 7, 'Very high', CLL.IPI),
         CLL.IPI = if_else(IPI.score.minus.B2M == 4, 'High', CLL.IPI),
         CLL.IPI = if_else(IPI.score.minus.IGHV == 4, 'High', CLL.IPI),
         CLL.IPI = factor(CLL.IPI, levels = c('Low', 'Intermediate', 'High', 'Very high')))

RKKP_CLL_clean %>%  nrow_npatients()
RKKP_CLL_clean$CLL.IPI %>% table
RKKP_CLL_clean$IPI.score.minus.B2M %>% table(exclude = NULL)

#### DAMYDA ####

RKKP_DaMyDa_clean = RKKP_DaMyDa %>% 
  clean_RKKP_DAMYDA() %>% 
  left_join(RKKP_DaMyDa %>% 
              select(patientid, contains('Cyto_FishResultat')) %>% 
              mutate(across(contains('Cyto_FishResultat'), ~ ifelse(is.na(.), 'N', .))) %>% 
              mutate(across(contains('Cyto_FishResultat'), ~ recode_factor(., 
                                                                           N = 'No',
                                                                           Y = 'Yes'))),
            by = 'patientid') %>% 
  left_join(patient) %>% 
  left_join(B2M, 'patientid', relationship = "many-to-many") %>% 
  slice_closest_value(date_diagnosis, date_B2M, value = B2M_value,  interval_days = c(-30, 30)) %>% 
  mutate(B2M = if_else(is.na(B2M), B2M_value, B2M))  %>% 
  mutate(ALB = ifelse(is.na(ALB), ALB_gL_corrected, ALB)) %>% 
  left_join(ALB, 'patientid', relationship = "many-to-many") %>% 
  slice_closest_value(date_diagnosis, date_ALB, value = ALB_value, interval_days = c(-30, 30)) %>% 
  mutate(ALB = if_else(is.na(ALB), ALB_value, ALB)) %>% 
  mutate(ISS_ext = ifelse(ALB >= 35 & B2M <3.5, 1, 2),
         ISS_ext = ifelse(B2M >= 5.5, 3, ISS_ext),
         ISS = ifelse(is.na(ISS), ISS_ext, ISS)) %>% 
  mutate(LDH_high = ifelse(Age < 70 & LDH > 205, 'Yes', NA),
         LDH_high = ifelse(Age < 70 & LDH <= 205, 'No', LDH_high),
         LDH_high = ifelse(Age >= 70 & LDH > 255, 'Yes', LDH_high),
         LDH_high = ifelse(Age >= 70 & LDH <= 255, 'No', LDH_high),
         FISH.score = ifelse(FISH_t4_14 =='Yes' | FISH_t14_16 =='Yes' | FISH_DEL17P =='Yes', 'Yes', 'No')) %>%
  mutate(RISS_Addon = ifelse(LDH_high =='Yes' | FISH.score =='Yes', 'Yes', 'No')) %>%
  mutate(RISS = ifelse(ISS == 3 & RISS_Addon == 'Yes', 3, NA),
         RISS = ifelse(ISS == 1 & RISS_Addon == "No", 1, RISS),
         RISS = ifelse(ISS == 3 & RISS_Addon == "No", 2, RISS),
         RISS = ifelse(ISS == 1 & RISS_Addon == "Yes", 2, RISS),
         RISS = ifelse(ISS == 2, 2, RISS)) 

utable(FISH.score~ FISH_t4_14 + FISH_t14_16 + FISH_t11_14+FISH_DEL17P+FISH_AMP1Q,RKKP_DaMyDa_clean)
RKKP_DaMyDa_clean$RISS %>% table(exclude = NULL)
RKKP_DaMyDa_clean$ISS %>% table(exclude = NULL)

#### LYFO ####
RKKP_LYFO_clean = RKKP_LYFO %>% 
  clean_RKKP_LYFO() %>% 
  left_join(patient)  %>% 
  left_join(HGB, by = 'patientid', relationship = "many-to-many") %>%
  slice_closest_value(Date_diagnosis, date_HGB, value = HGB_value, interval_days = c(-30,30), name = 'HGB') %>% 
  left_join(WBC, by = 'patientid', relationship = "many-to-many") %>% 
  slice_closest_value(Date_diagnosis, date_LEU, value = LEU_value, interval_days = c(-30,30), name = 'WBC') %>% 
  left_join(ALC, by = 'patientid', relationship = "many-to-many") %>% 
  slice_closest_value(Date_diagnosis, date_LYM, value = LYM_value, interval_days = c(-30,30), name = 'ALC') %>% 
  left_join(LDH,  by = 'patientid', relationship = "many-to-many") %>% 
  slice_closest_value(Date_diagnosis, date_LDH, value = LDH_value, interval_days = c(-30,30), name = 'LDH') %>% 
  left_join(IGM,  by = 'patientid', relationship = "many-to-many") %>% 
  slice_closest_value(Date_diagnosis, date_IGM, value = IGM_value, interval_days = c(-30,30), name = 'IGM')  %>%
  mutate(HB = ifelse(is.na(HB), valueHGB, HB),
         WBC = ifelse(is.na(WBC), valueWBC, WBC),
         ALC = ifelse(is.na(ALC), valueALC, ALC),
         LDH = ifelse(is.na(LDH), valueLDH, LDH),
         IgM_gL = ifelse(is.na(IgM_gL), valueIGM, IgM_gL))

#### table S8 ####
RKKP_DaMyDa_clean$DX %>% table
ALL_IPI = bind_rows(RKKP_CLL_clean %>% 
                      transmute(patientid, 
                                Sex,
                                PS,
                                IPI = CLL.IPI,
                                # IPI = recode_factor(CLL.IPI,  `Very high` = 'High'),
                                Disease = 'CLL'),
                    RKKP_DaMyDa_clean %>% 
                      filter(DX == 'DC900') %>% 
                      transmute(patientid, 
                                Sex,
                                PS,
                                IPI = recode_factor(RISS,
                                                    `1` = 'Low',
                                                    `2` = 'Intermediate',
                                                    `3` = 'High'),
                                Disease = 'MM'),
                    RKKP_LYFO_clean %>% 
                      filter(SUBTYPE  == 'DLBCL') %>% 
                      transmute(patientid, 
                                Sex,
                                PS,
                                IPI = RIPI,
                                Disease = 'DLBCL'),
                    RKKP_LYFO_clean %>% 
                      filter(SUBTYPE  == 'FL') %>% 
                      transmute(patientid, 
                                Sex,
                                PS,
                                IPI = FLIPI2,
                                Disease = 'FL'),
                    RKKP_LYFO_clean %>% 
                      filter(SUBTYPE  == 'MCL') %>% 
                      MIPI(SUBTYPE = SUBTYPE) %>% 
                      transmute(patientid, 
                                Sex,
                                PS,
                                IPI = MIPI,
                                Disease = 'MCL'),
                    RKKP_LYFO_clean %>% 
                      filter(SUBTYPE  == 'WM') %>% 
                      IPSSWM() %>%
                      # rIPSSWM(SUBTYPE = SUBTYPE) %>%
                      transmute(patientid, 
                                Sex,
                                PS,
                                IPI = IPSSWM,
                                # IPI = r.IPSSWM,
                                Disease = 'LPL'),
                    RKKP_LYFO_clean %>% 
                      filter(SUBTYPE == 'MZL') %>% 
                      MALT_IPI() %>% 
                      transmute(patientid, 
                                Sex,
                                PS,
                                IPI = MALT_IPI,
                                Disease = 'MZL'),
                    RKKP_LYFO_clean %>% 
                      filter(SUBTYPE =='cHL') %>% 
                      IPS() %>%
                      mutate(IPS = cut(IPS.score, c(-Inf, 2, Inf), labels = c('Low', 'High'))) %>% 
                      transmute(patientid, 
                                Sex,
                                PS,
                                # IPI = IPS,
                                IPI = cut(IPS.score, c(-Inf, 2, Inf), labels = c('Low', 'High')),
                                Disease = 'cHL'))  %>% 
  mutate(IPI = factor(IPI, levels =  c('Low', 'Intermediate', 'High', 'Very high')))
ALL_IPI %>% nrow_npatients()
ALL_IPI$IPI %>% table

if(SAVE == TRUE){
  write_csv2(ALL_IPI, paste0(getwd(), '/IPI_2.csv'))
  TAB_S9 = utable(Disease ~ IPI, ALL_IPI) %>% publish %>% as.data.frame()
  names(TAB_S9) = c('Variable', 'Level', 'CLL (n=6737)',  'MM (n=7533)', 'DLBCL (n=7977)', 'FL (n=3825)', 'MCL (n=1237)',
                    'LPL (n=2509)', 'MZL (n=1881)',  'cHL (n=2296)', 'Total (n=33995)',  'p-value' ) # please see list[[4]]
  write_csv(TAB_S9, paste0(getwd(), '/Table_S9.csv'))
}

