## TRIANGLE: Figure 2 
# Created:
## Sys.Date() # "2024-04-25"

library(RColorBrewer)
cat('Visualizes pair-wise Fishers exact tests between TOP20 icd-10:')
TOP20

# from t_dalycare_diagnoses => ALL_ICD10
ALL_ICD10.text = ALL_ICD10 %>%  
  filter(icd10 %in% TOP20) %>% 
  left_join(patient %>% select(patientid, date_birth), by = 'patientid') %>%
  mutate(icd10 = recode(icd10,
                        DC859 = 'NHL UNS',
                        DD472 = 'MGUS',
                        DC959 = 'Leukemia UNS',
                        DC919 = 'LL UNS',
                        DC911 = 'CLL',
                        DD479B = 'MBL',
                        DC900 = 'MM',
                        DC884 = 'EMZL',
                        DC830C = 'NMZL',
                        DC880= 'WM',
                        DC857 = 'HL other',
                        DC851 = 'BCL UNS',
                        DC833 = 'DLBCL',
                        DC831= 'MCL',
                        DC830B = 'LPL',
                        DC830 = 'SLL',
                        DC829 = 'FL UNS',
                        DC822 = 'FL3',
                        DC821 = 'FL2',
                        DC820  = 'FL1',
                        DC819 = 'HL UNS',
                        DC811 = 'HL-ns')) 
ALL_ICD10.text$icd10 %>% table(exclude = NULL)

#### WRANGLING ####
icd10_above = ALL_ICD10.1 %>%
  mutate(icd10 = recode(ICD10,
                        DC859= 'NHL UNS',
                        DD472 = 'MGUS',
                        DC959 = 'Leukemia UNS',
                        DC919 = 'LL UNS',
                        DC911 = 'CLL',
                        DD479B = 'MBL',
                        DC900= 'MM',
                        DC884= 'EMZL',
                        DC830C= 'NMZL',
                        DC880= 'WM',
                        DC857 = 'HL other',
                        DC851 = 'BCL UNS',
                        DC833 = 'DLBCL',
                        DC831= 'MCL',
                        DC830B = 'LPL',
                        DC830 = 'SLL',
                        DC829 = 'FL UNS',
                        DC822 = 'FL3',
                        DC821 = 'FL2',
                        DC820  = 'FL1',
                        DC819 = 'HL UNS',
                        DC811 = 'HL-ns')) %>% 
  head(20) %>% 
  pull(icd10)

ALL_ICD10 %>% nrow_npatients
FISHER = ALL_ICD10.text %>%  
  transmute(patientid, icd10, nons = 1) %>% 
  group_by(patientid, icd10) %>% 
  slice(1) %>% 
  ungroup() %>% 
  spread(icd10, nons) %>% 
  select(-patientid) %>% 
  mutate(across(all_of(icd10_above), ~ ifelse(is.na(.), 0, 1)))

FISHER %>% names  
# Test order of VECT
SUB.VECT = c()
VECT = c()
for (i in ncol(FISHER):1){print(i)
  COL = colnames(FISHER[i])
  for (j in ncol(FISHER):1){
    SUB.VECT[j] = paste0(COL, ':',  colnames(FISHER[j]))
  }
  VECT = append(SUB.VECT, VECT, after = length(VECT))
}

TRIANGLE = matrix(VECT, nrow = length(names(FISHER)), ncol = length(names(FISHER))) 
colnames(TRIANGLE) = names(FISHER)
rownames(TRIANGLE) = names(FISHER)
TRIANGLE = as.data.frame(TRIANGLE)

# Create vector og p-values
options("scipen"=99999, "digits"=4)
SUB.VECT = c()
VECT = c()
for (i in ncol(FISHER):1){print(i)
  GENE = FISHER[, i]
  for (j in ncol(FISHER):1){
    SUB.VECT[j] = fisher.test(table(pull(GENE), pull(FISHER[,j])))$p.value
  }
  VECT = append(SUB.VECT, VECT, after = length(VECT))
}

#Create matrix with VECT of p-values
TRIANGLE = matrix(VECT, nrow = length(names(FISHER)), ncol = length(names(FISHER))) 
colnames(TRIANGLE) = names(FISHER)
rownames(TRIANGLE) = names(FISHER)

#### P-values ####

# Generate decending values from 100 to 1 to simulate retention over time
TRIANGLE  = as.data.frame(TRIANGLE) 

# Make a triangle
TRIANGLE[lower.tri(TRIANGLE, diag = T)] = NA
# TRIANGLE[TRIANGLE== 0] = NA # 12/11-23

# Convert to a data frame, and add tenure labels
TRIANGLE = TRIANGLE[-nrow(TRIANGLE),]
TRIANGLE = TRIANGLE[, -1]

# Adjust p-values => q-values
p = TRIANGLE[!is.na(TRIANGLE)]
TRIANGLE[!is.na(TRIANGLE)] = p.adjust(p, method = "fdr", n = length(p))

TRIANGLE$tenure = seq(0,ncol(TRIANGLE)-1)
ROWS = row.names(TRIANGLE)

# Reshape to suit ggplot, remove NAs, and sort the labels
TRIANGLE = na.omit(reshape2::melt(TRIANGLE, 'tenure', variable='cohort')) #cohort = Gene_ID
TRIANGLE$cohort <- factor(TRIANGLE$cohort, levels=rev(levels(TRIANGLE$cohort))) #$cohort = $Gene_ID
TRIANGLE %>% dim

#### ODDS ###

# Create vector og log odds ratios
options("scipen"=100, "digits"=4)
SUB.VECT.ODDS = c()
VECT.ODDS = c()
for (i in ncol(FISHER):1){print(i)
  GENE = FISHER[, i]
  for (j in ncol(FISHER):1){
    SUB.VECT.ODDS[j] = as.numeric(fisher.test(table(pull(GENE), pull(FISHER[,j])))$estimate)
  }
  VECT.ODDS = append(SUB.VECT.ODDS, VECT.ODDS, after = length(VECT.ODDS))
}

# as.numeric(fisher.test(table(FISHER$`IGHV-U` , FISHER$NOTCH1))$estimate)
TRIANGLE.ODDS = matrix(VECT.ODDS, nrow = length(names(FISHER)), ncol = length(names(FISHER))) 

TRIANGLE.ODDS  = as.data.frame(TRIANGLE.ODDS) 
colnames(TRIANGLE.ODDS) = names(FISHER)
rownames(TRIANGLE.ODDS) = names(FISHER)


#### Plot TRIANGLE.ODDS Heatmap ####
# Generate decending values from 100 to 1 to simulate retention over time

# Make a triangle: TRIANGLE.ODDS
TRIANGLE.ODDS[lower.tri(TRIANGLE.ODDS, diag = T)] = NA

# Convert to a data frame, and add tenure labels
TRIANGLE.ODDS = TRIANGLE.ODDS[-nrow(TRIANGLE.ODDS),]
TRIANGLE.ODDS = TRIANGLE.ODDS[, -1]


TRIANGLE.ODDS$tenure = seq(0,ncol(TRIANGLE.ODDS)-1)
ROWS = row.names(TRIANGLE.ODDS)
TRIANGLE.ODDS %>% dim
# TRIANGLE.ODDS3= TRIANGLE.ODDS

# Reshape to suit ggplot, remove NAs, and sort the labels
TRIANGLE.ODDS = na.omit(reshape2::melt(TRIANGLE.ODDS, 'tenure', variable='cohort')) #cohort = Gene_ID
TRIANGLE.ODDS$cohort <- factor(TRIANGLE.ODDS$cohort, levels=rev(levels(TRIANGLE.ODDS$cohort))) #$cohort = $Gene_ID

# TRIANGLE.ODDS %>% value
# TRIANGLE.ODDS: Combine q-values + odds ratio
TRIANGLE.BOTH = TRIANGLE.ODDS %>% 
  transmute(odds = round(value, 2),
            odds.log = log10(odds)) %>% 
  cbind(TRIANGLE) %>% 
  mutate(correlation = ifelse(odds > 1, 1, 0),
         odds.log = ifelse(value>=0.1, NA, odds.log),
         q.value.cut = cut(value, c(1, 10^-3, 10^-6, 10^-9, 10^-12, 10^-15,10^-18,10^-21, -Inf)),
         legends= NA) 

## in specific:
cat('CLL:SLL')
fisher.test(table(FISHER$CLL, FISHER$SLL))[[3]] #Odds ratio!
cat('CLL:DLBCL')
fisher.test(table(FISHER$CLL, FISHER$DLBCL))[[3]] #Odds ratio!
cat('MM:MGUS')
fisher.test(table(FISHER$MM, FISHER$MGUS))[[3]] #Odds ratio!

#### PLOT ####
# Triangle heatmap to compare cohorts
library(viridis)

palette(c(brewer.pal(11,"RdBu"), 'white'))
TRIANGLE.BOTH$odds.log %>% table(exclude=NULL)
TRIANGLE_plot = ggplot(TRIANGLE.BOTH, aes(cohort, tenure)) +
  geom_tile(aes(fill = odds.log), color='black', size = 0.4) +
  # scale_fill_continuous() +
  scale_fill_binned('log-odds ratio', type = "viridis", na.value="#FFFFFF00") +
  # scale_color_viridis(na.value="#FFFFFF00") +
  # scale_fill_manual('Q-value', values=c('>0.2' = 'white',
  #                                       '<0.1 exclussive' = "#FDDBC7" ,
  #                                       '<<0.0001 exclussive' = "#D6604D",
  #                                       '<0.0000000001 exclussive' =  "#B2182B" ,
  #                                       
  #                                       # '<0.0000000001 cooccurrent' = "#D1E5F0",
  #                                       # '<0.1 cooccurrent' =  "#92C5DE",
  #                                       # '<0.05 cooccurrent' = "#4393C3",
  #                                       '<0.0000000001 cooccurrent' =  "#2166AC")) +
  ggtitle('Correlogram of LC diagnoses') +
  theme_minimal() + 
  theme(legend.title = element_text(angle = 45),
        panel.grid.major.x = element_blank(),
        panel.grid.major.y = element_blank(),
        panel.grid.minor = element_blank(),
        axis.text.x=element_text(angle=45, face = 'bold', hjust=1,vjust=1.0),
        axis.text.y=element_text(face = 'bold'),
        axis.ticks=element_blank(),
        axis.line=element_blank(),
        panel.border=element_blank(),
        axis.title.x=element_blank(),
        axis.title.y=element_blank(),
        panel.grid.major=element_line(color='#eeeeee')) +
  scale_y_continuous(breaks=seq(0, (ncol(FISHER)-2)), labels=ROWS) + coord_flip()

if(SAVE == TRUE){
  ggsave(paste0(getwd(), '/Figure_2A.png'),
         TRIANGLE_plot,
         height = 6,
         width = 8,
         dpi = 300)
}


