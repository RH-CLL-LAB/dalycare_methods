## IPI RAW 
# Sys.Date() # "2024-04-26"
# Calculates all IPI/ISS

# replace with IPI_raw 
IPI = ALL_IPI
CLL2 = CLL %>% 
  mutate(Age = diff_years(date_birth, date_diagnosis)) %>% 
  select(-sex, -status, -date_death_fu) %>% 
  left_join(PATIENT_OS2 %>% select(-date_birth), 'patientid') %>% 
  left_join(IPI %>% select(-Sex), 'patientid') %>% 
  mutate(IPI = factor(IPI, levels = c('Low', 'Intermediate', 'High', 'Very high')),
         # sex = factor(Sex, levels = c('Female', 'Male')),
         PS = factor(PS, levels = c(0:4)),
         across(contains('Polypharmacy'), ~ factor(., levels = c('No', 'Yes'))),
         ATC.all.cut = cut(n.ATC, c(-Inf, 3, 6, 9, 12, Inf), labels = c('0-3', '4-6', '7-9', '10-12', '>12')),
         CCI = CCI.2011.update) %>% 
  filter(!is.na(Age),
         !is.na(sex),
         !is.na(IPI),
         !is.na(Polypharmacy),
         !is.na(CCI.2011.update),
         !is.na(Time))

DLBCL2 = DLBCL %>% 
  mutate(Age = diff_years(date_birth, date_diagnosis)) %>% 
  select(-sex, -status, -date_death_fu) %>% 
  left_join(PATIENT_OS2 %>% select(-date_birth), 'patientid') %>% 
  left_join(IPI %>% select(-Sex), 'patientid') %>% 
  mutate(IPI = factor(IPI, levels = c('Low', 'Intermediate', 'High')),
         sex = factor(sex, levels = c('F', 'M')),
         PS = factor(PS, levels = c(0:4)),
         across(contains('Polypharmacy'), ~ factor(., levels = c('No', 'Yes'))),
         ATC.all.cut = cut(n.ATC, c(-Inf, 3, 6, 9, 12, Inf), labels = c('0-3', '4-6', '7-9', '10-12', '>12')),
         CCI = CCI.2011.update) %>% 
  filter(!is.na(Age),
         !is.na(sex),
         !is.na(IPI),
         !is.na(Polypharmacy),
         !is.na(CCI.2011.update),
         !is.na(Time))

FL2 = FL %>% 
  mutate(Age = diff_years(date_birth, date_diagnosis)) %>% 
  select(-sex, -status, -date_death_fu) %>% 
  left_join(PATIENT_OS2 %>% select(-date_birth), 'patientid') %>% 
  left_join(IPI %>% select(-Sex), 'patientid') %>% # FLIPI2!!!! Previous analysis contained FLIPI!
  mutate(IPI = factor(IPI, levels = c('Low', 'Intermediate', 'High')),
         PS = factor(PS, levels = c(0:4)),
         sex = factor(sex, levels = c('F', 'M')),
         across(contains('Polypharmacy'), ~ factor(., levels = c('No', 'Yes'))),
         ATC.all.cut = cut(n.ATC, c(-Inf, 3, 6, 9, 12, Inf), labels = c('0-3', '4-6', '7-9', '10-12', '>12')),
         CCI = CCI.2011.update) %>% 
  filter(!is.na(Age),
         !is.na(sex),
         !is.na(IPI),
         !is.na(Polypharmacy),
         !is.na(CCI.2011.update),
         !is.na(Time))

HL2 = HL %>% 
  mutate(Age = diff_years(date_birth, date_diagnosis)) %>% 
  select(-sex, -status, -date_death_fu) %>% 
  left_join(PATIENT_OS2 %>% select(-date_birth), 'patientid') %>% 
  left_join(IPI  %>% select(-Sex),  'patientid') %>%
  mutate(IPI = factor(IPI, levels = c('Low', 'High')),
         PS = factor(PS, levels = c(0:4)),
         sex = factor(sex, levels = c('F', 'M')),
         across(contains('Polypharmacy'), ~ factor(., levels = c('No', 'Yes'))),
         ATC.all.cut = cut(n.ATC, c(-Inf, 3, 6, 9, 12, Inf), labels = c('0-3', '4-6', '7-9', '10-12', '>12')),
         CCI = CCI.2011.update) %>% 
  filter(!is.na(Age),
         !is.na(sex),
         !is.na(IPI),
         !is.na(Polypharmacy),
         !is.na(CCI.2011.update),
         !is.na(Time))

MCL2 = MCL %>% 
  mutate(Age = diff_years(date_birth, date_diagnosis)) %>% 
  select(-sex, -status, -date_death_fu) %>% 
  left_join(PATIENT_OS2 %>% select(-date_birth), 'patientid') %>% 
  left_join(IPI %>% select(-Sex), 'patientid') %>%
  mutate(IPI = factor(IPI, levels = c('Low', 'Intermediate', 'High')),
         sex = factor(sex, levels = c('F', 'M')),
         PS = factor(PS, levels = c(0:4)),
         across(contains('Polypharmacy'), ~ factor(., levels = c('No', 'Yes'))),
         ATC.all.cut = cut(n.ATC, c(-Inf, 3, 6, 9, 12, Inf), labels = c('0-3', '4-6', '7-9', '10-12', '>12')),
         CCI = CCI.2011.update) %>% 
  filter(!is.na(Age),
         !is.na(sex),
         !is.na(IPI),
         !is.na(Polypharmacy),
         !is.na(CCI.2011.update),
         !is.na(Time))

MZL2 = MZL %>% 
  mutate(Age = diff_years(date_birth, date_diagnosis)) %>% 
  select(-sex, -status, -date_death_fu) %>% 
  left_join(PATIENT_OS2 %>% select(-date_birth), 'patientid') %>% 
  left_join(IPI %>% select(-Sex) , 'patientid') %>%
  mutate(IPI = factor(IPI, levels = c('Low', 'Intermediate', 'High')),
         sex = factor(sex, levels = c('F', 'M')),
         PS = factor(PS, levels = c(0:4)),
         across(contains('Polypharmacy'), ~ factor(., levels = c('No', 'Yes'))),
         ATC.all.cut = cut(n.ATC, c(-Inf, 3, 6, 9, 12, Inf), labels = c('0-3', '4-6', '7-9', '10-12', '>12')),
         CCI = CCI.2011.update) %>% 
  filter(!is.na(Age),
         !is.na(sex),
         !is.na(IPI),
         !is.na(Polypharmacy),
         !is.na(CCI.2011.update),
         !is.na(Time))

LPL2 = LPL %>% 
  mutate(Age = diff_years(date_birth, date_diagnosis)) %>% 
  select(-sex, -status, -date_death_fu) %>% 
  left_join(PATIENT_OS2 %>% select(-date_birth), 'patientid') %>% 
  left_join(IPI %>% select(-Sex), 'patientid') %>%
  mutate(IPI = factor(IPI, levels = c('Low', 'Intermediate', 'High')),
         sex = factor(sex, levels = c('F', 'M')),
         PS = factor(PS, levels = c(0:4)),
         across(contains('Polypharmacy'), ~ factor(., levels = c('No', 'Yes'))),
         ATC.all.cut = cut(n.ATC, c(-Inf, 3, 6, 9, 12, Inf), labels = c('0-3', '4-6', '7-9', '10-12', '>12')),
         CCI = CCI.2011.update) %>% 
  filter(!is.na(Age),
         !is.na(sex),
         # !is.na(PS),
         !is.na(IPI),
         !is.na(Polypharmacy),
         !is.na(CCI.2011.update),
         !is.na(Time))


MM2 = MM %>% 
  mutate(Age = diff_years(date_birth, date_diagnosis)) %>% 
  select(-sex, -status, -date_death_fu) %>% 
  left_join(PATIENT_OS2 %>% select(-date_birth), 'patientid') %>% 
  left_join(IPI %>% select(-Sex), 'patientid') %>%
  mutate(IPI = factor(IPI, levels = c('Low', 'Intermediate', 'High')), #Yes! R_ISS was calculated
         PS = factor(PS, levels = c(0:4)),
         sex = factor(sex, levels = c('F', 'M')),
         across(contains('Polypharmacy'), ~ factor(., levels = c('No', 'Yes'))),
         ATC.all.cut = cut(n.ATC, c(-Inf, 3, 6, 9, 12, Inf), labels = c('0-3', '4-6', '7-9', '10-12', '>12')),
         CCI = CCI.2011.update) %>% 
  filter(!is.na(Age),
         !is.na(sex),
         # !is.na(PS),
         !is.na(IPI),
         !is.na(Polypharmacy),
         !is.na(CCI.2011.update),
         !is.na(Time))


ALL.DISEASES = bind_rows(CLL2 %>% 
                           mutate(IPI = recode_factor(IPI, 
                                                      `Very high` = 'High')),
                         DLBCL2 ,
                         FL2  ,
                         MZL2 ,
                         MCL2 , 
                         LPL2,
                         MM2 ) %>% 
  mutate(IPI = factor(IPI, levels = c('Low', 'Intermediate', 'High')),
         sex = factor(sex, levels = c('F', 'M')),
         CCI.f = cut(CCI, c(-Inf, 2, Inf), c('0-2', '>2')),
         CCI.f2 = cut(CCI, c(-Inf, 2, 4,6, Inf), c('0-2', '2-4', '5-6', '>6'))) 


# ALL
ALL = ALL.DISEASES %>% 
  dplyr::rename(Sex = sex, ATC = ATC.all.cut) %>% 
  as.data.frame()

# save.image(paste0(getwd(), '/Before_coxmodels.RData'))
# load(paste0(getwd(), '/Before_coxmodels.RData'))

# coxph(Surv(time_dx_death, status) ~ Age + Sex + IPI + ATC + CCI, ALL) %>% publish() ## Error in ggforrest, unless tibble as.dataframe()
PLOT.ALL = ggforest(coxph(Surv(time_dx_death, status) ~ Age + Sex + IPI + ATC + CCI, ALL), cpositions = c(0.02, 0.15, 0.3))

# CLL
PLOT.CLL = ggforest(coxph(Surv(time_dx_death, status) ~ Sex + `CLL-IPI` + ATC + CCI, data = CLL2 %>% 
                            mutate(IPI = recode_factor(IPI, 
                                                       Low  = 'Low',
                                                       Intermediate = 'Intermediate',
                                                       `Very high` ='High' )) %>% 
                            dplyr::rename(Sex = sex, `CLL-IPI` = IPI, ATC = ATC.all.cut)%>% 
                            as.data.frame()), cpositions = c(0.02, 0.15, 0.3))
#DLBCL
# ggforest(coxph(Surv(Time, status) ~ sex + R_IPI + Polypharmacy.all + CCI, data = DLBCL2)) # Age+PSs
PLOT.DLBCL = ggforest(coxph(Surv(Time, status) ~ Sex +`R-IPI` + ATC + CCI, data = DLBCL2 %>% 
                              dplyr::rename(Sex = sex, `R-IPI` = IPI, ATC = ATC.all.cut) %>% 
                              as.data.frame()), cpositions = c(0.02, 0.15, 0.3))

#FL
PLOT.FL = ggforest(coxph(Surv(Time, status) ~ Sex + FLIPI2 + ATC + CCI, data = FL2 %>% 
                           dplyr::rename(Sex = sex, FLIPI2 = IPI, ATC = ATC.all.cut)%>% 
                           as.data.frame()), cpositions = c(0.02, 0.15, 0.3))
# ggforest(coxph(Surv(Time, status) ~ sex + FLIPI2 + ATC.cut + CCI, data = FL2))

#HL
PLOT.HL = ggforest(coxph(Surv(Time, status) ~ IPS + ATC + CCI, data = HL2%>% 
                           dplyr::rename(ATC = ATC.all.cut, IPS = IPI)%>% 
                           as.data.frame()), cpositions = c(0.02, 0.15, 0.3)) 
# ggforest(coxph(Surv(Time, status) ~ IPS + ATC.cut + CCI, data = HL2))

#BL too few

#MCL
PLOT.MCL = ggforest(coxph(Surv(Time, status) ~ Sex + MIPI + ATC + CCI, data = MCL2%>% 
                            dplyr::rename(Sex = sex, MIPI= IPI, ATC = ATC.all.cut)%>% 
                            as.data.frame()), cpositions = c(0.02, 0.15, 0.3)) 
# ggforest(coxph(Surv(Time, status) ~ sex + MIPI + ATC.cut + CCI, data = MCL2)) # try removing Age

#MZL
PLOT.MZL = ggforest(coxph(Surv(Time, status) ~ Sex +  `MALT-IPI` + ATC + CCI, data = MZL2 %>% 
                            dplyr::rename(Sex = sex, `MALT-IPI` = IPI, ATC = ATC.all.cut)%>% 
                            as.data.frame()), cpositions = c(0.02, 0.15, 0.3)) # Try removing AB from ATC?
# ggforest(coxph(Surv(Time, status) ~ sex + MALT_IPI + ATC.cut + CCI, data = MZL2))

#LPL
PLOT.LPL = ggforest(coxph(Surv(Time, status) ~ Sex + IPSSWM + ATC + CCI, data = LPL2 %>% 
                            dplyr::rename(Sex = sex,IPSSWM = IPI, ATC = ATC.all.cut)%>% 
                            as.data.frame()), cpositions = c(0.02, 0.15, 0.3)) 
# ggforest(coxph(Surv(Time, status) ~ sex + IPSSWM + ATC.cut + CCI, data = LPL2))

#MM
# ggforest(coxph(Surv(Time, status) ~ Age + sex + R_ISS + Polypharmacy.all + CCI, data = MM2)) #None
PLOT.MM = ggforest(coxph(Surv(Time, status) ~ Age + Sex + `R-ISS` + ATC + CCI,  data = MM2 %>% 
                           dplyr::rename(Sex = sex, ATC = ATC.all.cut, `R-ISS` = IPI)%>% 
                           as.data.frame()), cpositions = c(0.02, 0.15, 0.3)) 
# PLOT.MM = ggforest(coxph(Surv(Time, status) ~ Age + sex + R_ISS + ATC.cut + CCI, data = MM2)) 

LABELS = c('All', 'cHL', 'DLBCL', 'FL', 'MZL', 'MCL', 'CLL', 'LPL', 'MM')
LABELS %>% length()

if(SAVE==TRUE){
ggsave(paste0(getwd(), '/Figure_4_cox_LARGE.png'),
       ggarrange(PLOT.ALL, PLOT.HL, PLOT.DLBCL, PLOT.FL, PLOT.MZL, PLOT.MCL, PLOT.CLL,  PLOT.LPL, PLOT.MM,
          nrow = 3, ncol = 3, labels = LABELS),
       height = 15,
       width = 22,
       dpi = 300)
}

IPI_data = IPI %>%
  left_join(PATIENT_OS2) %>% 
  mutate(Age = diff_years(date_birth, date_first_dx)) %>% 
  mutate(ATC = cut(n.ATC, c(-Inf, 3, 6, 9, 12, Inf), labels = c('0-3', '4-6', '7-9', '10-12', '>12')),
         Sex = factor(Sex, levels = c('Female', 'Male')),
         IPI = recode_factor(IPI, 
                             Low = 'Low',
                             Intermediate = 'Intermediate',
                             High = 'High',
                             `Very high` = 'High')) %>% 
  mutate(CCI = CCI.2011.update) %>% 
  filter(!is.na(Time),
         !is.na(status),
         !is.na(Sex),
         !is.na(ATC),
         !is.na(CCI),
         !is.na(IPI))


RKKP_IPI_FORREST = 
  ggarrange(
    coxph(Surv(Time, status) ~ Age+ Sex + IPI + ATC + CCI, data = IPI_data %>% 
            as.data.frame()) %>% ggforest(cpositions = c(0.02, 0.1, 0.3)),
    
    coxph(Surv(Time, status) ~ IPS + ATC + CCI, data = IPI_data %>% 
            filter(Disease == 'cHL') %>% 
            mutate(IPS = factor(IPI, levels = c('Low', 'High'))) %>% 
            as.data.frame()) %>% ggforest(cpositions = c(0.02, 0.1, 0.3)),
    
    coxph(Surv(Time, status) ~ Sex + `R-IPI` + ATC + CCI, data = IPI_data %>% 
            filter(Disease == 'DLBCL') %>% 
            mutate(`R-IPI` = IPI) %>% 
            as.data.frame()) %>% ggforest(cpositions = c(0.02, 0.1, 0.3)),
    
    coxph(Surv(Time, status) ~ Sex + FLIPI + ATC + CCI, data = IPI_data %>% 
            filter(Disease == 'FL') %>% 
            mutate(FLIPI = IPI) %>% 
            as.data.frame()) %>% ggforest(cpositions = c(0.02, 0.1, 0.3)),
    
    coxph(Surv(Time, status) ~ Sex + `MALT-IPI` + ATC + CCI, data = IPI_data %>% 
            filter(Disease == 'MZL') %>% 
            mutate(`MALT-IPI` = IPI) %>% 
            as.data.frame()) %>% ggforest(cpositions = c(0.02, 0.1, 0.3)),
    
    coxph(Surv(Time, status) ~ Sex + MIPI + ATC + CCI, data = IPI_data %>% 
            filter(Disease == 'MCL') %>% 
            mutate(MIPI = IPI) %>% 
            as.data.frame()) %>% ggforest(cpositions = c(0.02, 0.1, 0.3)),
    
    
    coxph(Surv(Time, status) ~ Sex + `CLL-IPI` + ATC + CCI, data = IPI_data %>% 
            filter(Disease == 'CLL') %>% 
            mutate(`CLL-IPI` = IPI) %>% 
            as.data.frame()) %>% ggforest(cpositions = c(0.02, 0.1, 0.3)),
    
    
    coxph(Surv(Time, status) ~ Sex + IPSSWM + ATC + CCI, data = IPI_data %>% 
            filter(Disease == 'LPL') %>% 
            mutate(IPSSWM = IPI) %>% 
            as.data.frame()) %>% ggforest(cpositions = c(0.02, 0.1, 0.3)),
    
    
    coxph(Surv(Time, status) ~ Age + Sex + `R-ISS` + ATC + CCI, data = IPI_data %>% 
            filter(Disease == 'MM') %>% 
            mutate(`R-ISS` = recode_factor(IPI,
                                           Low = '1',
                                           Intermediate = '2',
                                           High = '3')) %>% 
            as.data.frame()) %>% ggforest(cpositions = c(0.02, 0.1, 0.3)),
    labels = LABELS,
    nrow = 3,
    ncol = 3)

if(SAVE==TRUE){
ggsave(paste0(getwd(), '/Figure_4_cox_RKKP.png'),
       RKKP_IPI_FORREST,
       height = 15,
       width = 22,
       dpi = 300)
}
#### PRINT FOREST ####
#### Figure S1 #####

# ALL
PLOT.ALL.S2 = ggforest(coxph(Surv(Time, status) ~ Age + Sex + IPI + Polypharmacy + CCI, data = ALL.DISEASES %>% 
                      dplyr::rename(Sex = sex) %>% 
                        as.data.frame()))

# CLL
PLOT.CLL.S2 = ggforest(coxph(Surv(Time, status) ~ Sex + `CLL-IPI` + Polypharmacy + CCI, data = CLL2 %>% 
                               mutate(IPI = recode_factor(IPI, 
                                                          Low = 'Low',
                                                          Intermediate = 'Intermediate',
                                                          High = 'High',
                                                          `Very high` = 'High')) %>% 
                            dplyr::rename(Sex = sex, `CLL-IPI` = IPI, ATC = ATC.all.cut) %>% 
                              as.data.frame()))

#DLBCL
PLOT.DLBCL.S2 = ggforest(coxph(Surv(Time, status) ~ Sex +`R-IPI` + Polypharmacy + CCI, data = DLBCL2 %>% 
                              dplyr::rename(Sex = sex, `R-IPI` = IPI, ATC = ATC.all.cut)%>% 
                                as.data.frame()))
#FL
PLOT.FL.S2 = ggforest(coxph(Surv(Time, status) ~ Sex + FLIPI2 + Polypharmacy + CCI, data = FL2%>% 
                           dplyr::rename(Sex = sex, FLIPI2 = IPI, ATC = ATC.all.cut)%>% 
                             as.data.frame()))

#HL
PLOT.HL.S2 = ggforest(coxph(Surv(Time, status) ~ IPS + Polypharmacy + CCI, data = HL2%>% 
                           dplyr::rename(ATC = ATC.all.cut, IPS = IPI)%>% 
                             as.data.frame())) 
#BL too few

#MCL
PLOT.MCL.S2 = ggforest(coxph(Surv(Time, status) ~ Sex + MIPI + Polypharmacy + CCI, data = MCL2%>% 
                            dplyr::rename(Sex = sex,  ATC = ATC.all.cut, MIPI = IPI)%>% 
                              as.data.frame())) 

#MZL
PLOT.MZL.S2 = ggforest(coxph(Surv(Time, status) ~ Sex +  `MALT-IPI` + Polypharmacy + CCI, data = MZL2 %>% 
                            dplyr::rename(Sex = sex, `MALT-IPI` = IPI, ATC = ATC.all.cut)%>% 
                              as.data.frame()))
#LPL
PLOT.LPL.S2 = ggforest(coxph(Surv(Time, status) ~ Sex + IPSSWM + Polypharmacy + CCI, data = LPL2 %>% 
                            dplyr::rename(Sex = sex, IPSSWM = IPI, ATC = ATC.all.cut)%>% 
                              as.data.frame()))
#MM
PLOT.MM.S2 = ggforest(coxph(Surv(Time, status) ~ Age + Sex + `R-ISS` + Polypharmacy + CCI,  data = MM2 %>% 
                           dplyr::rename(Sex = sex, ATC = ATC.all.cut, `R-ISS` = IPI)%>% 
                             as.data.frame()))
LABELS = c('All', 'cHL', 'DLBCL', 'FL', 'MZL', 'MCL', 'CLL', 'LPL', 'MM')
LABELS %>% length()

if(SAVE == TRUE){
  ggsave(paste0(getwd(), '/Figure_S1_Cox.png'),
                ggarrange(PLOT.ALL.S2, PLOT.HL.S2, PLOT.DLBCL.S2, PLOT.FL.S2, 
                          PLOT.MZL.S2, PLOT.MCL.S2, PLOT.CLL.S2,  PLOT.LPL.S2, PLOT.MM.S2,
                          nrow = 3, ncol = 3, labels = LABELS),
                height = 17,
                width = 17,
                dpi = 300)
}
