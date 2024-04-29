HL = [
    "C81.1",
    "C81.2",
    "C81.3",
    "C81.4",
    "C81.7",
    "C81.9",
]  # excluding NLP-HL  == 'DC810',
FL = ["C82.9", "C82.0", "C82.1", "C82.2", "C82.7"]
SLL = ["C83.0"]
LPL = ["C83.0B", "C88.0"]
NMZL = ["C83.0C"]
SMZL = ["C83.0D"]
EMZL = ["C88.4A", "C88.4B", "C88.4C"]
MZL = [x for sublist in [NMZL, SMZL, EMZL] for x in sublist]
MCL = ["C83.1"]
DLBCL = ["C83.3"]
LBL = ["C83.5", "C82.5A", "C83.5B"]
BL = ["C83.7"]
PTCL = ["C84.4"]
BCL_UNS = ["C85.1"]
Lymphoma_UNS = ["C85.9"]
AITL = ["C86.5"]
MM = ["C90.0"]
PCL = ["C90.1"]
SolM = ["C90.2", "C90.2A", "C90.3"]
PCD = [x for sublist in [MM, PCL, SolM] for x in sublist]
CLL = ["C91.1"]
RT = ["C91.1B"]
HCL = ["C91.4"]
Leukemia_UNS = ["C91.7", "C91.9"]
MGUS = ["D47.2", "D47.2A", "D47.2B"]
MBL = ["D47.9B"]
UNS = [x for sublist in [BCL_UNS, Lymphoma_UNS, Leukemia_UNS] for x in sublist]

table = {
    "HL": ", ".join(HL),
    "FL": ", ".join(FL),
    "SLL": ", ".join(SLL),
    "LPL": ", ".join(LPL),
    "NMZL": ", ".join(NMZL),
    "SMZL": ", ".join(SMZL),
    "EMZL": ", ".join(EMZL),
    "MZL": ", ".join(MZL),
    "MCL": ", ".join(MCL),
    "DLBCL": ", ".join(DLBCL),
    "LBL": ", ".join(LBL),
    "BL": ", ".join(BL),
    "PTCL": ", ".join(PTCL),
    "BCL_UNS": ", ".join(BCL_UNS),
    "Lymphoma_UNS": ", ".join(Lymphoma_UNS),
    "AITL": ", ".join(AITL),
    "MM": ", ".join(MM),
    "PCL": ", ".join(PCL),
    "SolM": ", ".join(SolM),
    "PCD": ", ".join(PCD),
    "CLL": ", ".join(CLL),
    "RT": ", ".join(RT),
    "HCL": ", ".join(HCL),
    "Leukemia_UNS": ", ".join(Leukemia_UNS),
    "MGUS": ", ".join(MGUS),
    "MBL": ", ".join(MBL),
    "UNS": ", ".join(UNS),
}

import pandas as pd

dataframe = pd.DataFrame(table.values(), index=table.keys()).reset_index()
dataframe.rename(columns={"index": "Disease", 0: "ICD10"}).to_excel(
    "../../../projects2/dalyca_r/sftp/fromNGC/Table_S6.xlsx", index=False
)

table_s2 = pd.read_csv(
    "/ngc/projects2/dalyca_r/clean_r/shared_projects/DALYCARE_methods/All_tables_variable_names.csv"
)

table_s2 = table_s2[~table_s2["Dataset_name"].str.contains("Codes")].reset_index(
    drop=True
)

table_s2 = table_s2[~table_s2["Dataset_name"].str.contains("CODES")].reset_index(
    drop=True
)

table_s2 = table_s2[~table_s2["Dataset_name"].str.contains("DX")].reset_index(drop=True)

table_s2 = table_s2[~table_s2["Dataset_name"].str.contains("koder")].reset_index(
    drop=True
)

table_s2 = table_s2[~table_s2["Dataset_name"].str.contains("_ny")].reset_index(
    drop=True
)

table_s2 = table_s2[
    ~table_s2["Dataset_name"].str.contains("vaevsanvend_markoer")
].reset_index(drop=True)


table_s2 = table_s2[
    ~table_s2["Dataset_name"].str.contains("_organisationer")
].reset_index(drop=True)

table_s2["Dataset_name"] = table_s2["Dataset_name"].str.replace("_subset", "")


table_s2["Variable_names"] = table_s2["Variable_names"].str.replace(
    "PATIENTID", "patientid"
)

table_s2 = table_s2.drop_duplicates().reset_index(drop=True)

table_s2.loc[table_s2["Dataset_name"].str.contains("RKKP"), "Format"] = "Wide; UTF-8"
table_s2.loc[table_s2["Format"].isna(), "Format"] = "Long; UTF-8"


title_dict = {
    "RKKP_DaMyDa": "RKKP - Danish National Multiple Myeloma Registry (DaMyDa)",
    "RKKP_LYFO": "RKKP - Danish National Lymphoma Registry (LYFO)",
    "RKKP_CLL": "RKKP - Danish National Chronic Lymphocytic Leukemia Registry (CLL)",
    "SDS_t_adm": "SDS - Danish National Patient Registry (LPR) - Administration",
    "SDS_t_udtilsgh": "SDS - Danish National Patient Registry (LPR) - SHAK register",
    "SDS_indberetningmedpris": "SDS - National Hospital Medication Register (SMR) - Reports with Price",
    "SDS_t_tumor": "SDS - Danish Cancer Register (DCR)",
    "SDS_t_diag": "SDS - National Hospital Medication Register (SMR) - Diagnosis",
    "SDS_t_sksube": "SDS - National Hospital Medication Register (SMR) - Surgical Procedure",
    "SDS_t_sksopr": "SDS - National Hospital Medication Register (SMR) - Examination and Treatment",
    "SDS_ekokur": "SDS - Register of Pharmaceutical Sales (LSR) - Ekokur",
    "SDS_epikur": "SDS - Register of Pharmaceutical Sales (LSR) - Epikur",
    "SDS_pato": "SDS - Danish National Pathology Register (PATOBANK) - Pathology",
    "SDS_t_dodsaarsag_2": "SDS - Danish Register of Causes of Death (DAR)",
    "SDS_lab_forsker": "SDS - Clinical Laboratory Information System Research Database (LABKA)",
    "SDS_forloeb": "SDS - Danish National Patient Registry 3 (LPR3) - Course",
    "SDS_forloebsmarkoerer": "SDS - Danish National Patient Registry 3 (LPR3) - Course Indicators",
    "SDS_diagnoser": "SDS - Danish National Patient Registry (LPR) - Diagnosis",
    "SDS_kontakter": "SDS - Danish National Patient Registry 3 (LPR3) - Visits",
    "SDS_procedurer_kirurgi": "SDS - Danish National Patient Registry (LPR) - Surgical Procedure",
    "SDS_procedurer_andre": "SDS - Danish National Patient Registry 3 (LPR3) - Procedure Other",
    "SDS_resultater": "SDS - Danish National Patient Registry 3 (LPR3) - Results",
    "PERSIMUNE_biochemistry": "PERSIMUNE - Clinical Laboratory Information System Research Database (LABKA)",
    "PERSIMUNE_microbiology_analysis": "PERSIMUNE - Danish Microbiology Database (MiBa) - Microbiology Analysis",
    "PERSIMUNE_microbiology_culture": "PERSIMUNE - Danish Microbiology Database (MiBa) - Microbiology Culture",
    "PERSIMUNE_microbiology_microscopy": "PERSIMUNE - Danish Microbiology Database (MiBa) - Microbiology Microscopy",
    "PERSIMUNE_microbiology_extra": "PERSIMUNE - Danish Microbiology Database (MiBa) - Microbiology Extra",
    "SP_Aktive_Problemliste_Diagnoser": "SP - Active Problems Diagnoses (ActiveDx)",
    "SP_AlleProvesvar": "SP - All Test Results (LABKA+)",
    "SP_OrdineretMedicin": "SP - Prescribed Medicine (RxMed)",
    "SP_Journalnotater_del1": "SP - Medical Notes (Notes1)",
    "SP_Journalnotater_del2": "SP - Medical Notes (Notes2)",
    "SP_Behandlingsplaner_del2": "SP - Treatment Plans 2 (Tx_plans2)",
    "SP_Behandlingsplaner_del1": "SP - Treatment Plans 1 (Tx_plans1)",
    "SP_Bloddyrkning_del1": "SP - Microbiology charts 1 (Micro1)",
    "SP_Behandlingskontakter_diagnoser": "SP - Visits and Diagnoses (Visits_Dx)",
    "SP_VitaleVaerdier": "SP - Vital Signs (VitalSigns)",
    "SP_Bloddyrkning_del2": "SP - Microbiology charts 2 (Micro2)",
    "SP_Bloddyrkning_del3": "SP - Microbiology charts 3 (Micro3)",
    "SP_Administreret_Medicin": "SP - Administered Medicine (AdmMed)",
    "SP_ADT_haendelser": "SP - Admissions (ADT) - Hospitalization",
    "SP_Flytningshistorik": "SP - Transfers",
    "SP_SocialHx": "SP - Social History",
    "SP_ItaOphold": "SP - Intensive Care Unit (ICU)",
    "LAB_Flowcytometry": "LAB - Flow cytometry",
    "LAB_IGHVIMGT": "LAB - IGHV analyses",
}


table_s2["Name"] = table_s2["Dataset_name"].apply(lambda x: title_dict.get(x))

table_2 = table_s2[["Name", "Dataset_name", "Variable_names", "Format"]].reset_index(
    drop=True
)

table_s2.to_excel("../../../projects2/dalyca_r/sftp/fromNGC/Table_S2.xlsx", index=False)