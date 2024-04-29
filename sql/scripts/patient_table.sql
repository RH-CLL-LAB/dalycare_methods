--------------------------------------------------
-- Date: 2024-04-26
-- Author: Casper Møller Frederiksen
-- Description: This script create the patienttable which include death date, followup date and status. 
-- 
--


CREATE OR REPLACE VIEW pending.view_patient_table_os
 AS
 SELECT p.patientid,
    p.sex,
    p.date_birth,
    os.date_death,
    os.status,
    os.date_followup
   FROM ( SELECT patient.patientid,
            patient.sex,
            patient.date_birth
           FROM pending.patient) p
     JOIN ( SELECT df.patientid,
            df.true_date_death AS date_death,
            df.status,
            df.date_max_followup AS date_followup
           FROM ( SELECT dd.patientid,
                    dd.true_date_death,
                    fu.date_sp_followup,
                    fu.date_lyfo_followup,
                    fu.date_damyda_followup,
                    fu.date_cll_followup,
                    fu.date_sds_followup,
                        CASE
                            WHEN dd.true_date_death IS NULL THEN 0
                            ELSE 1
                        END AS status,
                        CASE
                            WHEN dd.true_date_death IS NULL THEN GREATEST(fu.date_sp_followup, fu.date_lyfo_followup, fu.date_damyda_followup, fu.date_cll_followup, fu.date_sds_followup)
                            ELSE NULL::date
                        END AS date_max_followup
                   FROM ( SELECT view_true_date_death.patientid,
                            view_true_date_death.true_date_death
                           FROM pending.view_true_date_death) dd
                     JOIN ( SELECT view_date_followup.patientid,
                            view_date_followup.date_sp_followup,
                            view_date_followup.date_lyfo_followup,
                            view_date_followup.date_damyda_followup,
                            view_date_followup.date_cll_followup,
                            view_date_followup.date_sds_followup
                           FROM pending.view_date_followup) fu ON dd.patientid = fu.patientid) df) os ON p.patientid = os.patientid;

