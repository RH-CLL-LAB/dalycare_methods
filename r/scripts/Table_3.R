## Table 3
# Sys.Date() # "2024-04-25"

#### OS ####

DX.FIRST.POLY %>% head2()
DX.FIRST.CCI %>% n_patients()

t_dalycare_diagnoses$tablename  %>% table
t_dalycare_last_diagnosis = t_dalycare_diagnoses %>%
  filter(tablename != 't_dodsaarsag_2') %>% 
  group_by(patientid) %>% 
  arrange(desc(date_diagnosis)) %>% 
  slice(1) %>% 
  ungroup() %>% 
  dplyr::rename(date_last_diagnosis = date_diagnosis)
t_dalycare_last_diagnosis %>% nrow_npatients()

DX.FIRST.POLY$date_first_dx %>% summary #5063 NA!
DX.FIRST %>% head2
PATIENT_OS2 = patient %>% 
  left_join(DX.FIRST %>% select(patientid, date_first_dx = date_diagnosis)) %>% 
  left_join(DX.FIRST.POLY %>% 
              transmute(patientid, n.ATC, Polypharmacy = factor(Polypharmacy, levels = c('No', 'Yes'))),
            by = 'patientid') %>% 
  left_join(DX.FIRST.CCI %>% transmute(patientid, CCI.score, CCI.2011.update), 'patientid') %>%
  left_join(t_dalycare_last_diagnosis %>% select(patientid, date_last_diagnosis)) %>% 
  mutate(date_death_fu2 = if_else(date_death_fu < date_first_dx, date_last_diagnosis, date_death_fu)) %>% 
  mutate(Time = diff_years(date_first_dx, date_death_fu2))  %>%
  filter(Time >= 0) #29
PATIENT_OS2$Time %>% summary
PATIENT_OS2 %>% filter(Time ==0) %>% nrow
PATIENT_OS2 %>% n_patients() # Sanity check
PATIENT_OS2$Polypharmacy %>% table(exclude =NULL)
PATIENT_OS2$CCI.2011.update %>% table(exclude =NULL)

if(SAVE == TRUE){
  write_csv2(PATIENT_OS2, paste0(getwd(),'/PATIENT_OS2.csv'))
}

quantile(prodlim(Hist(Time, status) ~ 1, 
                 data=PATIENT_OS2,
                 reverse=TRUE)) # Median FU time (years)

##### ENTITIES OS #####
summary(survfit(Surv(time_dx_death, status) ~ Disease, data = ENTITIES %>% filter(time_dx_death >= 0)), times = 5)
palette(brewer.pal(10, 'Paired'))
# palette(brewer.pal(11, 'Paired'))
ENTITIES$Disease %>% levels
ENTITIES$Disease %>% table
ENTITIES = ENTITIES %>% 
  # filter(Disease != 'MGUS') %>% 
  mutate(Disease = factor(Disease, levels = c( "MZL", "FL", "LPL", "SLL", "CLL", "cHL", "MCL", "MM", 
                                               # "MGUS",
                                               "DLBCL", "BL")))
if(SAVE == TRUE){
ggsave(paste0(getwd(), '/Figure_3_KM_plot.png'),
       arrange_ggsurvplots(list(KM_plot(survfit(Surv(time_dx_death, status) ~ Disease, ENTITIES %>% filter(time_dx_death >= 0)),
                                        title = 'Disease',
                                        labs = ENTITIES$Disease %>% levels,
                                        palette = c(10:1)) ),
                           ncol = 1),
       height = 10, 
       width = 7,
       dpi = 300) #1000 less MZL!?
}

# summary(survfit(Surv(Time, status) ~ Disease, ENTITIES %>% filter(time_dx_death >= 0)), times = 5)

##### TABLE 3 ######
PATIENT_OS2 %>% nrow_npatients()
PATIENT_OS2$n.ATC %>% summary()
PATIENT_OS3 = PATIENT_OS2 %>% 
  mutate(Age = diff_years(date_birth, date_first_dx),
         n.ATC = ifelse(is.na(n.ATC) & date_first_dx < as.Date(date_max_atc), 0, n.ATC)) # in LSR
PATIENT_OS3$n.ATC %>% summary
# utable(~ Q(Age) + sex , DX.FIRST.DATES) # no missing!
utable(~ Q(Age) + sex , PATIENT_OS3) # no missing!
PATIENT_OS3$Polypharmacy
TABLE3 = PATIENT_OS3 %>% mutate(CCI.score = CCI.2011.update)
TABLE3$n.ATC %>% summary # no n.ATC within the year before first DX with 0!
TABLE3 %>%  filter(is.na(n.ATC)) %>% pull(date_first_dx) %>% summary #all diagnosed after date_max_atc
date_max_atc

TABLE3 %>% filter(!is.na(n.ATC)) %>% n_patients() # REPORT, patients with Rx in SI
TABLE3 %>% n_patients()
utable(~ Q(Age) + sex + Q(CCI.score) + Q(n.ATC) + Polypharmacy, TABLE3)

if(SAVE == TRUE){
write_csv2(utable(~ Q(Age) + sex + Q(CCI.score) + Q(n.ATC) + Polypharmacy, TABLE3) %>% summary %>%  as.data.frame(),
           paste0(getwd() ,'/Table_3.csv'))
}

TABLES7 = ENTITIES %>% 
  left_join(TABLE3 %>% select(patientid, -sex, CCI.score, n.ATC, Polypharmacy), 'patientid') 
TABLES7$Disease %>% table
utable(Disease ~ Q(Age) + sex + Q(CCI.score) + Q(n.ATC) + Polypharmacy, TABLES7) # more than in table 1, due to str_detect, which is ok


if(SAVE == TRUE){
  write_csv2(utable(Disease ~ Q(Age) + sex + Q(CCI.score) + Q(n.ATC) + Polypharmacy, TABLES7) %>% summary %>%  as.data.frame(),
             paste0(getwd(),'/Table_S8.csv'))
}
