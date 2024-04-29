--------------------------------------------------
-- Date: 2024-04-26
-- Author: Casper Møller Frederiksen
-- Description: This script create the view to find all diagnoses for all patients. This view is used by the dalycare_diagnoses view   
-- 

CREATE OR REPLACE VIEW pending.view_diagnosses_all
 AS
 SELECT DISTINCT a.patientid,
    a.date_diagnosis,
    a.diagnosis,
    a.tablename,
    a.datasource,
    a.priority
   FROM ( SELECT DISTINCT view_sds_t_adm_t_diag.patientid::integer AS patientid,
            view_sds_t_adm_t_diag.d_inddto AS date_diagnosis,
            view_sds_t_adm_t_diag.c_diag AS diagnosis,
            't_diag'::text AS tablename,
            'SDS'::text AS datasource,
            3 AS priority
           FROM view_sds_t_adm_t_diag
        UNION
         SELECT DISTINCT "SDS_t_adm".patientid::integer AS patientid,
            date('1970-01-01 00:00:01'::timestamp without time zone) + "SDS_t_adm".d_inddto::integer AS date_diagnosis,
            "SDS_t_adm".c_adiag AS diagnosis,
            't_adm'::text AS tablename,
            'SDS'::text AS datasource,
            3 AS priority
           FROM "SDS_t_adm"
        UNION
         SELECT DISTINCT "SDS_t_tumor".patientid::integer AS patientid,
            date('1970-01-01 00:00:01'::timestamp without time zone) + "SDS_t_tumor".d_diagnosedato::integer AS diagnose_date,
            'D'::text || "SDS_t_tumor".c_icd10 AS diagnose,
            't_tumor'::text AS tablename,
            'SDS'::text AS datasource,
            3 AS priority
           FROM "SDS_t_tumor"
        UNION
         SELECT DISTINCT "SDS_kontakter".patientid::integer AS patientid,
            date('1970-01-01 00:00:01'::timestamp without time zone) + "SDS_kontakter".dato_start::integer AS dato_start,
            "SDS_kontakter".aktionsdiagnose,
            'SDS_kontakter'::text AS tablename,
            'SDS'::text AS datasource,
            3 AS priority
           FROM "SDS_kontakter"
        UNION
         SELECT DISTINCT view_sds_kont_diag.patientid::integer AS patientid,
            view_sds_kont_diag.dato_start AS diagnose_date,
            view_sds_kont_diag.diagnosekode AS diagnose,
            'diagnoser'::text AS tablename,
            'SDS'::text AS datasource,
            3 AS priority
           FROM view_sds_kont_diag
        UNION
         SELECT DISTINCT view_sds_kont_diag.patientid::integer AS patientid,
            view_sds_kont_diag.dato_start AS diagnose_date,
            view_sds_kont_diag.diagnosekode_parent AS diagnose,
            'diagnoser'::text AS tablename,
            'SDS'::text AS datasource,
            3 AS priority
           FROM view_sds_kont_diag
        UNION
         SELECT DISTINCT a_1.patientid,
            a_1.date_death,
            a_1.diagnosis,
            a_1.tablename,
            a_1.datasource,
            a_1.priority
           FROM ( SELECT "SDS_t_dodsaarsag_2".patientid,
                    date('1970-01-01 00:00:01'::timestamp without time zone) + "SDS_t_dodsaarsag_2".d_statdato::integer AS date_death,
                    'D'::text || "SDS_t_dodsaarsag_2".c_dodtilgrundl_acme AS diagnosis,
                    't_dodsaarsag_2'::text AS tablename,
                    'SDS'::text AS datasource,
                    3 AS priority
                   FROM "SDS_t_dodsaarsag_2"
                UNION
                 SELECT "SDS_t_dodsaarsag_2".patientid,
                    date('1970-01-01 00:00:01'::timestamp without time zone) + "SDS_t_dodsaarsag_2".d_statdato::integer AS date_death,
                    'D'::text || "SDS_t_dodsaarsag_2".c_dod_1a AS diagnosis,
                    't_dodsaarsag_2'::text AS tablename,
                    'SDS'::text AS datasource,
                    3 AS priority
                   FROM "SDS_t_dodsaarsag_2"
                UNION
                 SELECT "SDS_t_dodsaarsag_2".patientid,
                    date('1970-01-01 00:00:01'::timestamp without time zone) + "SDS_t_dodsaarsag_2".d_statdato::integer AS date_death,
                    'D'::text || "SDS_t_dodsaarsag_2".c_dod_1b AS diagnosis,
                    't_dodsaarsag_2'::text AS tablename,
                    'SDS'::text AS datasource,
                    3 AS priority
                   FROM "SDS_t_dodsaarsag_2"
                UNION
                 SELECT "SDS_t_dodsaarsag_2".patientid,
                    date('1970-01-01 00:00:01'::timestamp without time zone) + "SDS_t_dodsaarsag_2".d_statdato::integer AS date_death,
                    'D'::text || "SDS_t_dodsaarsag_2".c_dod_1c AS diagnosis,
                    't_dodsaarsag_2'::text AS tablename,
                    'SDS'::text AS datasource,
                    3 AS priority
                   FROM "SDS_t_dodsaarsag_2"
                UNION
                 SELECT "SDS_t_dodsaarsag_2".patientid,
                    date('1970-01-01 00:00:01'::timestamp without time zone) + "SDS_t_dodsaarsag_2".d_statdato::integer AS date_death,
                    'D'::text || "SDS_t_dodsaarsag_2".c_dod_1d AS diagnosis,
                    't_dodsaarsag_2'::text AS tablename,
                    'SDS'::text AS datasource,
                    3 AS priority
                   FROM "SDS_t_dodsaarsag_2") a_1
          WHERE a_1.date_death IS NOT NULL AND length(a_1.diagnosis) >= 5
        UNION
         SELECT DISTINCT a_1.patientid,
            a_1.d_rekvdato AS date_diagnosis,
            b.icd10,
            't_pato'::text AS tablename,
            'PATO'::text AS datasource,
            1 AS prioroty
           FROM ( SELECT view_sds_pato.patientid,
                    view_sds_pato.d_rekvdato,
                    view_sds_pato.c_snomedkode
                   FROM view_sds_pato) a_1
             JOIN ( SELECT codes_snomed2icd10_reviewed.snomed,
                    codes_snomed2icd10_reviewed.icd10
                   FROM _lookup_tables.codes_snomed2icd10_reviewed) b ON a_1.c_snomedkode = b.snomed
        UNION
         SELECT "SP_Behandlingskontakter_diagnoser".patientid,
            to_timestamp("SP_Behandlingskontakter_diagnoser".kontaktdato)::date AS date_diagnosis,
            "SP_Behandlingskontakter_diagnoser".skskode AS diagnosis,
            'Behandlingskontakter_diagnoser'::text AS tablename,
            'SP'::text AS datasource,
            4 AS prioroty
           FROM "SP_Behandlingskontakter_diagnoser"
        UNION
         SELECT "SP_ADT_haendelser".patientid,
            "SP_ADT_haendelser".kontakt_start_local_dttm::date AS kontakt_start_local_dttm,
            "SP_ADT_haendelser".current_icd10_list,
            'ADT_haendelse'::text AS tablename,
            'SP'::text AS datasource,
            4 AS priority
           FROM "SP_ADT_haendelser"
          WHERE "SP_ADT_haendelser".kontakt_start_local_dttm !~~ 'NULL'::text AND "SP_ADT_haendelser".current_icd10_list !~~ 'NULL'::text
        UNION
         SELECT "SP_ADT_haendelser".patientid,
            "SP_ADT_haendelser".kontakt_start_local_dttm::date AS kontakt_start_local_dttm,
            "SP_ADT_haendelser".current_icd10_list_2,
            'ADT_haendelse'::text AS tablename,
            'SP'::text AS datasource,
            4 AS priority
           FROM "SP_ADT_haendelser"
          WHERE "SP_ADT_haendelser".kontakt_start_local_dttm !~~ 'NULL'::text AND "SP_ADT_haendelser".current_icd10_list_2 !~~ 'NULL'::text
        UNION
         SELECT DISTINCT "RKKP_CLL".patientid,
            (((("substring"("RKKP_CLL"."Reg_Diagnose_dt", 7, 4) || '-'::text) || "substring"("RKKP_CLL"."Reg_Diagnose_dt", 4, 2)) || '-'::text) || "substring"("RKKP_CLL"."Reg_Diagnose_dt", 1, 2))::date AS diagnose_date,
            'DC911'::text AS diagnose,
            'RKKP_CLL'::text AS tablename,
            'RKKP'::text AS datasource,
            2 AS priority
           FROM "RKKP_CLL"
        UNION
         SELECT "RKKP_DaMyDa".patientid,
            (((("substring"("RKKP_DaMyDa"."Reg_Diagnose_dt", 7, 4) || '-'::text) || "substring"("RKKP_DaMyDa"."Reg_Diagnose_dt", 4, 2)) || '-'::text) || "substring"("RKKP_DaMyDa"."Reg_Diagnose_dt", 1, 2))::date AS diagnose_date,
                CASE
                    WHEN "RKKP_DaMyDa"."Reg_Diagnose" = '9730'::text THEN 'DC900'::text
                    WHEN "RKKP_DaMyDa"."Reg_Diagnose" = '9731'::text THEN 'DC903'::text
                    WHEN "RKKP_DaMyDa"."Reg_Diagnose" = '9732'::text THEN 'DC900'::text
                    WHEN "RKKP_DaMyDa"."Reg_Diagnose" = '9733'::text THEN 'DC901'::text
                    WHEN "RKKP_DaMyDa"."Reg_Diagnose" = '9734'::text THEN 'DC902'::text
                    WHEN "RKKP_DaMyDa"."Reg_Diagnose" = '9733'::text THEN 'DC901'::text
                    ELSE "RKKP_DaMyDa"."Reg_Diagnose"
                END AS diagnosis,
            'DaMyDa'::text AS tablename,
            'RKKP'::text AS datasource,
            2 AS priority
           FROM "RKKP_DaMyDa"
        UNION
         SELECT DISTINCT a_1.patientid,
            (((("substring"(a_1."Reg_DiagnostiskBiopsi_dt", 7, 4) || '-'::text) || "substring"(a_1."Reg_DiagnostiskBiopsi_dt", 4, 2)) || '-'::text) || "substring"(a_1."Reg_DiagnostiskBiopsi_dt", 1, 2))::date AS diagnose_date,
            b.icd10_code AS diagnose,
            'RKKP_LYFO'::text AS tablename,
            'RKKP'::text AS datasource,
            2 AS priority
           FROM ( SELECT "RKKP_LYFO".patientid,
                    "RKKP_LYFO".subtype,
                    "RKKP_LYFO"."Org_rap",
                    "RKKP_LYFO"."Kommunenr",
                    "RKKP_LYFO"."CPR_Doedsdato",
                    "RKKP_LYFO"."CPR_Opdat_dt",
                    "RKKP_LYFO"."IND_Beh",
                    "RKKP_LYFO"."IND_Relaps",
                    "RKKP_LYFO"."IND_FU",
                    "RKKP_LYFO"."ANTREG",
                    "RKKP_LYFO"."ENODAL",
                    "RKKP_LYFO"."IPI",
                    "RKKP_LYFO"."IPS",
                    "RKKP_LYFO"."aaIPI",
                    "RKKP_LYFO"."FLIPI",
                    "RKKP_LYFO"."FLIPI2",
                    "RKKP_LYFO"."CNSs",
                    "RKKP_LYFO"."Reg_DiagnostiskBiopsi_dt",
                    "RKKP_LYFO"."Reg_WHOHistologikode1",
                    "RKKP_LYFO"."Reg_DiskordantLymfom",
                    "RKKP_LYFO"."Reg_WHOHistologikode2",
                    "RKKP_LYFO"."Reg_Stadium",
                    "RKKP_LYFO"."Reg_BSymptomer",
                    "RKKP_LYFO"."Reg_Tumordiameter",
                    "RKKP_LYFO"."Reg_BulkSygdom",
                    "RKKP_LYFO"."Reg_PerformanceStatusWHO",
                    "RKKP_LYFO"."Reg_AndenMalignSygdom",
                    "RKKP_LYFO"."Reg_SKSKodeAndenMalignSygdom",
                    "RKKP_LYFO"."Reg_IvaerkPlantBehandling",
                    "RKKP_LYFO"."Reg_BehandlingBeslutning_dt",
                    "RKKP_LYFO"."Reg_Sygdomslokalisation_nodal",
                    "RKKP_LYFO"."Reg_Sygdomslokal_extranodel",
                    "RKKP_LYFO"."Reg_Lokal_Rhinopharynx",
                    "RKKP_LYFO"."Reg_Lokal_Waldeyers",
                    "RKKP_LYFO"."Reg_Lokal_TonsillaPalatina",
                    "RKKP_LYFO"."Reg_Lokal_TonsillaPalatina_side",
                    "RKKP_LYFO"."Reg_Lokal_Hals",
                    "RKKP_LYFO"."Reg_Lokal_Hals_side",
                    "RKKP_LYFO"."Reg_Lokal_Supraclaviculaert",
                    "RKKP_LYFO"."Reg_Lokal_Supraclaviculaert_side",
                    "RKKP_LYFO"."Reg_Lokal_Infraclaviculaert",
                    "RKKP_LYFO"."Reg_Lokal_Infraclaviculaert_side",
                    "RKKP_LYFO"."Reg_Lokal_Axiller",
                    "RKKP_LYFO"."Reg_Lokal_Axiller_side",
                    "RKKP_LYFO"."Reg_Lokal_Mediastinum",
                    "RKKP_LYFO"."Reg_Lokal_Lungehili",
                    "RKKP_LYFO"."Reg_Lokal_Lungehili_side",
                    "RKKP_LYFO"."Reg_Lokal_Retroperitoneum",
                    "RKKP_LYFO"."Reg_Lokal_Tarmkroes",
                    "RKKP_LYFO"."Reg_Lokal_Pelvis",
                    "RKKP_LYFO"."Reg_Lokal_Pelvis_side",
                    "RKKP_LYFO"."Reg_Lokal_Ingvinale",
                    "RKKP_LYFO"."Reg_Lokal_Ingvinale_side",
                    "RKKP_LYFO"."Reg_Lokal_Milt",
                    "RKKP_LYFO"."Reg_Lokal_Knoglemarv",
                    "RKKP_LYFO"."Reg_Lokal_Orbita",
                    "RKKP_LYFO"."Reg_Lokal_Oje",
                    "RKKP_LYFO"."Reg_Lokal_Taarekirtel",
                    "RKKP_LYFO"."Reg_Lokal_Bihuler",
                    "RKKP_LYFO"."Reg_Lokal_CavumNasi",
                    "RKKP_LYFO"."Reg_Lokal_Mundhule",
                    "RKKP_LYFO"."Reg_Lokal_Spytkirtler",
                    "RKKP_LYFO"."Reg_Lokal_glThyroidea",
                    "RKKP_LYFO"."Reg_Lokal_Cor",
                    "RKKP_LYFO"."Reg_Lokal_Mamma",
                    "RKKP_LYFO"."Reg_Lokal_Lunge",
                    "RKKP_LYFO"."Reg_Lokal_Ventrikel",
                    "RKKP_LYFO"."Reg_Lokal_Tyndtarm",
                    "RKKP_LYFO"."Reg_Lokal_Tyktarm",
                    "RKKP_LYFO"."Reg_Lokal_Pancreas",
                    "RKKP_LYFO"."Reg_Lokal_Nyrer",
                    "RKKP_LYFO"."Reg_Lokal_Lever",
                    "RKKP_LYFO"."Reg_Lokal_peri_Lymfom",
                    "RKKP_LYFO"."Reg_Lokal_Pleura_Lymfom",
                    "RKKP_LYFO"."Reg_lokal_Ascites",
                    "RKKP_LYFO"."Reg_Lokal_Urinblare",
                    "RKKP_LYFO"."Reg_Lokal_Testis",
                    "RKKP_LYFO"."Reg_Lokal_Ovarier",
                    "RKKP_LYFO"."Reg_Lokal_Vagina",
                    "RKKP_LYFO"."Reg_Lokal_Uterus",
                    "RKKP_LYFO"."Reg_Lokal_Hud",
                    "RKKP_LYFO"."Reg_Lokal_Muskulatur",
                    "RKKP_LYFO"."Reg_Lokal_Knogler",
                    "RKKP_LYFO"."Reg_Lokal_CNS",
                    "RKKP_LYFO"."Reg_Lokal_Leptomeninges",
                    "RKKP_LYFO"."Reg_Haemoglobin",
                    "RKKP_LYFO"."Reg_Thrombocytter",
                    "RKKP_LYFO"."Reg_Leukocytter",
                    "RKKP_LYFO"."Reg_Lymfocytter_mL",
                    "RKKP_LYFO"."Reg_Lymfocytter_pro",
                    "RKKP_LYFO"."Reg_Saenkning",
                    "RKKP_LYFO"."Reg_Albumin_gL",
                    "RKKP_LYFO"."Reg_Albumin_mikmoll",
                    "RKKP_LYFO"."Reg_CalciumAlbuminkorrigeret",
                    "RKKP_LYFO"."Reg_CalciumIoniseret",
                    "RKKP_LYFO"."Reg_Creatinin_mikmoll",
                    "RKKP_LYFO"."Reg_Creatinin_millimoll",
                    "RKKP_LYFO"."Reg_Bilirubin",
                    "RKKP_LYFO"."Reg_ALAT",
                    "RKKP_LYFO"."Reg_BasiskFosfatase",
                    "RKKP_LYFO"."Reg_BasiskPhosphataseVaerdi",
                    "RKKP_LYFO"."Reg_Lactatdehydrogenase",
                    "RKKP_LYFO"."Reg_LDHVaerdi",
                    "RKKP_LYFO"."Reg_Beta2Microglobulin_mgL",
                    "RKKP_LYFO"."Reg_Beta2Microglobulin_nmL",
                    "RKKP_LYFO"."Reg_ImmunglobulinA_gL",
                    "RKKP_LYFO"."Reg_ImmunglobulinA_Mikmoll",
                    "RKKP_LYFO"."Reg_ImmunglobulinG_gL",
                    "RKKP_LYFO"."Reg_ImmunglobulinG_Mikmoll",
                    "RKKP_LYFO"."Reg_ImmunglobulinM_gL",
                    "RKKP_LYFO"."Reg_ImmunglobulinM_Mikmoll",
                    "RKKP_LYFO"."Reg_MProtein",
                    "RKKP_LYFO"."Reg_PatientProtokol",
                    "RKKP_LYFO"."Reg_UddybProtokol",
                    "RKKP_LYFO"."Beh_resource_author_SHAK",
                    "RKKP_LYFO"."Beh_AlligevelIndtastningTrods",
                    "RKKP_LYFO"."Beh_ErDerForetagetKemo",
                    "RKKP_LYFO"."Beh_Kemoterapiregime1",
                    "RKKP_LYFO"."Beh_CycluslaengdeReg1",
                    "RKKP_LYFO"."Beh_CyclusAntalReg1",
                    "RKKP_LYFO"."Beh_Kemoterapiregime2",
                    "RKKP_LYFO"."Beh_CycluslaengdeReg2",
                    "RKKP_LYFO"."Beh_CyclusAntalReg2",
                    "RKKP_LYFO"."Beh_Kemoterapiregime3",
                    "RKKP_LYFO"."Beh_CycluslaengdeReg3",
                    "RKKP_LYFO"."Beh_CyclusAntalReg3",
                    "RKKP_LYFO"."Beh_KemoterapiStart_dt",
                    "RKKP_LYFO"."Beh_KemoterapiSlut_dt",
                    "RKKP_LYFO"."Beh_Immunoterapi",
                    "RKKP_LYFO"."Beh_GivetSynkrontMedKemoterapi",
                    "RKKP_LYFO"."Beh_ImmunoterapiStart_dt",
                    "RKKP_LYFO"."Beh_ImmunoterapiSlut_dt",
                    "RKKP_LYFO"."Beh_ImmunoterapiCyclusantal",
                    "RKKP_LYFO"."Beh_Vedligeholdelsesbehandling",
                    "RKKP_LYFO"."Beh_Radioimmunoterapi",
                    "RKKP_LYFO"."Beh_RadioimmunoterapiBeh_dt",
                    "RKKP_LYFO"."Beh_DosismCiKg",
                    "RKKP_LYFO"."Beh_Straaleterapi",
                    "RKKP_LYFO"."Beh_StraaleterapiBehandlings_dt",
                    "RKKP_LYFO"."Beh_DosisIGray",
                    "RKKP_LYFO"."Beh_AntalFraktioner",
                    "RKKP_LYFO"."Beh_Operationstype",
                    "RKKP_LYFO"."Beh_SpecificerAndet_String",
                    "RKKP_LYFO"."Beh_Operationsdato",
                    "RKKP_LYFO"."Beh_Hoejdosisbehandling",
                    "RKKP_LYFO"."Beh_TypeAutologStamcellestoette",
                    "RKKP_LYFO"."Beh_Stamcelleinfusion_dt",
                    "RKKP_LYFO"."Beh_AndenLymfomspecifikBeh",
                    "RKKP_LYFO"."Beh_StereoidSomMonoterapi",
                    "RKKP_LYFO"."Beh_Responsevaluering",
                    "RKKP_LYFO"."Beh_Responsevaluering_dt",
                    "RKKP_LYFO"."Beh_PerformanceStatus",
                    "RKKP_LYFO"."Rec_RelapsProgressions_dt",
                    "RKKP_LYFO"."Rec_ErDerGennemfoertNyBiopsi",
                    "RKKP_LYFO"."Rec_WHOHistologikode",
                    "RKKP_LYFO"."Rec_HavdePatientenCNS",
                    "RKKP_LYFO"."Rec_ErDerForetagetKemoterapi",
                    "RKKP_LYFO"."Rec_Kemoterapiregime1",
                    "RKKP_LYFO"."Rec_Cycluslaengde1",
                    "RKKP_LYFO"."Rec_Cyclusantal1",
                    "RKKP_LYFO"."Rec_Kemoterapiregime2",
                    "RKKP_LYFO"."Rec_Cycluslaengde2",
                    "RKKP_LYFO"."Rec_Cyclusantal2",
                    "RKKP_LYFO"."Rec_Kemoterapiregime3",
                    "RKKP_LYFO"."Rec_Cycluslaengde3",
                    "RKKP_LYFO"."Rec_Cyclusantal3",
                    "RKKP_LYFO"."Rec_KemoterapiStart_dt",
                    "RKKP_LYFO"."Rec_KemoterapiSlut_dt",
                    "RKKP_LYFO"."Rec_Immunoterapi",
                    "RKKP_LYFO"."Rec_GivetSynkrontMedKemoterapi",
                    "RKKP_LYFO"."Rec_ImmunoterapiStart_dt",
                    "RKKP_LYFO"."Rec_ImmunoterapiSlut_dt",
                    "RKKP_LYFO"."Rec_ImmunoterapiCyclusantal",
                    "RKKP_LYFO"."Rec_PaabegyndtVedligehold",
                    "RKKP_LYFO"."Rec_Radioimmunoterapi",
                    "RKKP_LYFO"."Rec_RadioimmunoterapiBeh_dt",
                    "RKKP_LYFO"."Rec_DosisImCikg",
                    "RKKP_LYFO"."Rec_Straaleterapi",
                    "RKKP_LYFO"."Rec_StraaleterapiBeh_dt",
                    "RKKP_LYFO"."Rec_DosisIGray",
                    "RKKP_LYFO"."Rec_AntalFraktioner",
                    "RKKP_LYFO"."Rec_Operationstype",
                    "RKKP_LYFO"."Rec_SpeciferAndet_String",
                    "RKKP_LYFO"."Rec_Operationsdato",
                    "RKKP_LYFO"."Rec_AndenLymfomspecifik",
                    "RKKP_LYFO"."Rec_Hoejdosisbehandling",
                    "RKKP_LYFO"."Rec_Stamcelleinfusion_dt",
                    "RKKP_LYFO"."Rec_StereoidSomMonoterapi",
                    "RKKP_LYFO"."Rec_Responsevaluering",
                    "RKKP_LYFO"."Rec_Responsevaluering_dt",
                    "RKKP_LYFO"."Rec_Behtoksicitet",
                    "RKKP_LYFO"."Rec_Performancestatus",
                    "RKKP_LYFO"."FU_LeverPatienten",
                    "RKKP_LYFO"."FU_Sygdomsstatus",
                    "RKKP_LYFO"."FU_ErPatientensForloebAfsluttet",
                    "RKKP_LYFO"."FU_Doedsdato",
                    "RKKP_LYFO"."FU_Doedsaarsag"
                   FROM "RKKP_LYFO") a_1
             JOIN ( SELECT codes_snomed_icd10_mapping.snomed_code,
                    codes_snomed_icd10_mapping.icd10_code
                   FROM _lookup_tables.codes_snomed_icd10_mapping) b ON a_1."Reg_WHOHistologikode1" = b.snomed_code) a
  WHERE a.diagnosis !~~ 'DC910'::text AND a.date_diagnosis >= '2002-01-01'::date AND a.date_diagnosis <= now()::date;
  
