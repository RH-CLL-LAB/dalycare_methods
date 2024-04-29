#### LOAD SUBSETS ####
library(stringi)
source('/ngc/projects2/dalyca_r/clean_r/load_data.R')
load_dataset(c('patient'))

DALYCARE_DATASETS = c("PERSIMUNE_biochemistry", 
                      "PERSIMUNE_microbiology_analysis",
                      "PERSIMUNE_microbiology_culture", 
                      # "PERSIMUNE_microbiology_culture_resistance",
                      "PERSIMUNE_microbiology_extra", 
                      "PERSIMUNE_microbiology_microscopy", 
                      "RKKP_CLL",                                 
                      "RKKP_DaMyDa",                              
                      "RKKP_LYFO",      
                      # "SDS_diagnoser",                           
                      # "SDS_doso_tekster",                         
                      "SDS_ekokur",                                
                      "SDS_epikur",                                
                      "SDS_forloeb",                              
                      # "SDS_forloebsmarkoerer",         
                      "SDS_indberetningmedpris",                  
                      # "SDS_indo_tekster",                         
                      # "SDS_koder",                     
                      "SDS_kontakter",  #needed
                      "SDS_lab_forsker",                          
                      # "SDS_lab_labidcodes",  
                      # "SDS_lab_optaelling",       
                      # "SDS_laegemiddel",                          
                      # "SDS_laegemiddeloplysninger",             
                      # "SDS_organisationer",                
                      "SDS_pato",                                 
                      # "SDS_procedurer_andre",               
                      # "SDS_procedurer_kirurgi",        
                      # "SDS_resultater",                           
                      "SDS_t_adm",                                 
                      # "SDS_t_diag",                                
                      "SDS_t_dodsaarsag_2",                       
                      # "SDS_t_konk_ny",                             
                      # "SDS_t_mikro_ny",                            
                      # "SDS_t_mikro_ny_distinct",                  
                      # "SDS_t_sksopr",                     
                      # "SDS_t_sksube",                            
                      "SDS_t_tumor",                              
                      # "SDS_t_udtilsgh",
                      "SDS_t_vaevsanvend_markoer",             
                      "SP_Administreret_Medicin",
                      "SP_ADT_haendelser",  
                      "SP_Aktive_Problemliste_Diagnoser", 
                      "SP_AlleProvesvar",
                      "SP_Behandlingskontakter_diagnoser",      
                      "SP_Behandlingsplaner_del1",
                      "SP_Behandlingsplaner_del2",
                      "SP_Bloddyrkning_del1",                      
                      "SP_Bloddyrkning_del2",                      
                      "SP_Bloddyrkning_del3",
                      "SP_Bloddyrkning_del4",                      
                      "SP_Flytningshistorik",                      
                      "SP_ItaOphold",
                      # "SP_Journalnotater_del1",
                      # # "SP_Journalnotater_del2",                  
                      "SP_OrdineretMedicin",
                      "SP_OS",                                     
                      "SP_Patientinfo",                            
                      "SP_SocialHx",
                      "SP_VitaleVaerdier"
)
set.seed(NULL)
for (i in DALYCARE_DATASETS) {print(i)
  COHORT = sample(patient$patientid, 500)
  load_dataset(i, value = COHORT)
}

load_dataset('SDS_t_adm')
load_dataset('SDS_kontakter')

DALYCARE_LPR = LPR[c(-1, -2, -3)]
for (i in DALYCARE_LPR) {print(i)
  COHORT = sample(SDS_t_adm$k_recnum %>% unique(), 500)
  load_dataset(i, value = COHORT, column = 'v_recnum')
}

DALYCARE_LPR3_kontakt = LPR3[c(-1, -3, -4, -5)]
for (i in DALYCARE_LPR3_kontakt) {print(i)
  COHORT = sample(SDS_kontakter$dw_ek_kontakt %>% unique(), 500)
  load_dataset(i, value = COHORT, column = 'dw_ek_kontakt')
}


DALYCARE_LPR3_forloeb = LPR3[c(3, 4)]
for (i in DALYCARE_LPR3_forloeb) {print(i)
  COHORT = sample(SDS_kontakter_subset$dw_ek_forloeb %>% unique(), 500)
  load_dataset(i, value = COHORT, column = 'dw_ek_forloeb')
}


#SDS_organisationer, no patients
load_dataset(c("LAB_Flowcytometry", "LAB_IGHVIMGT", "LAB_CLLPANEL_WIDE", 'LAB_BIOBANK_SAMPLES', "CLL_TREAT", "MM_TREAT_DARA", "CLL_TREAT_IBRUTINIB", "PERSIMUNE_microbiology_culture_resistance"))

# Remove data.frames
rm(list=ls(pattern=c("CODES|Codes|DX")))
rm(SDS_t_adm)
rm(SDS_kontakter)

# save.image('/ngc/projects2/dalyca_r/clean_r/shared_projects/data/DUMMY.RData')
load('/ngc/projects2/dalyca_r/clean_r/shared_projects/data/DUMMY.RData')


#### DUMMIES ####

# helper function for getting all the tables
get_dummy_tables = function(){
  # note that the function looks in the global environment.
  # If the user has other stuff in their environment, this
  # will also list all of those tables
  dfs = Filter(function(x) is.data.frame(x), mget(ls(.GlobalEnv), envir = .GlobalEnv))
  return(dfs)
}

dfs = get_dummy_tables()

get_names_dummy_tables = function(){
  NAMES = c()
  CLASSES = c()
  
  for(i in 1:length(dfs)){
    NAMES[i] = dfs[i] %>% names()  
    CLASSES = c(CLASSES, unlist(lapply(dfs[[i]],class))) %>% unique()
  }
  return(NAMES)
}

NAMES = get_names_dummy_tables()

random_dummy_tables = function(dfs){
  dfs = get_dummy_tables()
  
  
  
  LIST = list()
  for (i in 1:length(dfs)){print(i)
    DUMMY = matrix(ncol = ncol(dfs[[i]]), nrow = 10)
    for (j in 1:ncol(dfs[[i]])){print(paste('j', j))
      dfs[[i]][,j] %>% class
      if (dfs[[i]][,j] %>% class %in% c('Date', 'numeric', 'integer', 'integer64') %>% sort(decreasing = T) %>% head(1)){
        DUMMY[,j] = sample(dfs[[i]][,j], 10, replace = T)+sample(-10:10, 10)
      }
      if (dfs[[i]][,j] %>% class %in% c(  'POSIXt', 'POSIXct') %>% sort(decreasing = T) %>% head(1)){
        DUMMY[,j] = sample(dfs[[i]][,j], 10, replace = T)+sample(-864000:864000, 10)
      }
      
      if (dfs[[i]][,j] %>% class %in% c( 'character', 'logical') %>% sort(decreasing = T) %>% head(1)){
        DUMMY[,j] = sample(dfs[[i]][,j], 10)
      }
      colnames(DUMMY) = colnames(dfs[[i]])
      DUMMY = DUMMY %>% as.data.frame()
      
      # if ('patientid' %in% colnames(dfs[[i]]) %>% sort(decreasing = T) %>% head(1)) {
      #   DUMMY = DUMMY %>% select(-patientid)
      # }
      
      LIST[[i]] = DUMMY
    }
  }
  assign('NAMES', NAMES)
  return(LIST)
}

list_of_dummy_tables = random_dummy_tables()

for (i in 1:length(dfs)) {print(i)
  print_color(NAMES[i], 'red')
  print_color(dfs[[i]] %>% names, 'blue')
  # print(dfs[[i]] %>% head(5))
}

NAMES = gsub('_subset', '', NAMES)

list_names = list()
for (i in 1:length(NAMES)) {
  list_names[[i]] = names(dfs[[i]])
}

ALL_V = stri_list2matrix(list_names, byrow=TRUE) %>% t()
colnames(ALL_V) = NAMES
# write_csv2(ALL_V %>% as_data_frame(), '/ngc/projects2/dalyca_r/clean_r/shared_projects/DALYCARE_methods/dummy_tables/All_variables.csv')
All_variables = read_csv2('/ngc/projects2/dalyca_r/clean_r/shared_projects/DALYCARE_methods/dummy_tables/All_variables.csv')

#### WRITE APPENDIX 3 ####
library(xlsx)
NAMES = gsub('_subset', '', NAMES)
NAMES = paste0(NAMES, '_dummy')
NAMES[11] = 'PERSIMUNE_microbiology_resistance_dummy' 



write.xlsx(list_of_dummy_tables[[1]], file="/ngc/projects2/dalyca_r/clean_r/shared_projects/DALYCARE_methods/dummy_tables/Table_S2_dummy.xlsx",
           sheetName=NAMES[1], append=FALSE)
for(i in 2:length(NAMES)){print(paste(i, NAMES[i]))
  write.xlsx(list_of_dummy_tables[[i]], file="/ngc/projects2/dalyca_r/clean_r/shared_projects/DALYCARE_methods/dummy_tables/Table_S2_dummy.xlsx",
             sheetName=NAMES[i], append=TRUE)
}

all_v = load_all_variables()
all_v %>% print_data()
