--------------------------------------------------
-- Date: 2024-04-26
-- Author: Casper Møller Frederiksen
-- Description: This script create the view to find patients with dalycare diagnoses according to the rules described in supplementary information.
-- 
CREATE OR REPLACE VIEW public.view_dalycare_diagnoses
 AS
 SELECT DISTINCT oaa.patientid,
    oaa.date_diagnosis,
    oaa.diagnosis,
    oaa.tablename,
    oaa.datasource,
    oaa.priority
   FROM ( SELECT a.patientid,
            a.date_diagnosis,
            a.diagnosis,
            a.tablename,
            a.datasource,
            a.priority,
            ((a.date_diagnosis - b.date_birth)::numeric / 365.25)::real AS age
           FROM ( SELECT view_diagnosses_all.patientid,
                    view_diagnosses_all.date_diagnosis,
                    view_diagnosses_all.diagnosis,
                    view_diagnosses_all.tablename,
                    view_diagnosses_all.datasource,
                    view_diagnosses_all.priority
                   FROM pending.view_diagnosses_all) a
             JOIN ( SELECT patient.patientid,
                    patient.sex,
                    patient.date_birth::date AS date_birth
                   FROM pending.patient) b ON a.patientid = b.patientid::double precision
          WHERE ((a.date_diagnosis - b.date_birth)::numeric / 365.25)::real > 18::double precision AND a.date_diagnosis > '2002-01-01'::date AND ((a.diagnosis = ANY (ARRAY['DC951'::text, 'DC957'::text, 'DC959'::text, 'DD472'::text, 'DD472A'::text, 'DD472B'::text, 'DD479B'::text, 'DE858A'::text])) OR a.diagnosis > 'DC81%'::text AND a.diagnosis < 'DC92%'::text) AND a.diagnosis !~~ 'DC910%'::text AND a.diagnosis !~~ 'DC92'::text) oaa
EXCEPT
 SELECT DISTINCT b.patientid,
    b.date_diagnosis,
    b.diagnosis,
    b.tablename,
    b.datasource,
    b.priority
   FROM ( SELECT DISTINCT ua.patientid,
            ua.date_diagnosis,
            ua.diagnosis,
            ua.tablename,
            ua.datasource,
            ua.priority,
            ua.age
           FROM ( SELECT a_1.patientid,
                    a_1.date_diagnosis,
                    a_1.diagnosis,
                    a_1.tablename,
                    a_1.datasource,
                    a_1.priority,
                    ((a_1.date_diagnosis - b_1.date_birth)::numeric / 365.25)::real AS age
                   FROM ( SELECT view_diagnosses_all.patientid,
                            view_diagnosses_all.date_diagnosis,
                            view_diagnosses_all.diagnosis,
                            view_diagnosses_all.tablename,
                            view_diagnosses_all.datasource,
                            view_diagnosses_all.priority
                           FROM pending.view_diagnosses_all
                          WHERE view_diagnosses_all.datasource <> 'PATO'::text) a_1
                     JOIN ( SELECT patient.patientid,
                            patient.sex,
                            patient.date_birth::date AS date_birth
                           FROM pending.patient) b_1 ON a_1.patientid = b_1.patientid::double precision
                  WHERE ((a_1.date_diagnosis - b_1.date_birth)::numeric / 365.25)::real < 18::double precision AND a_1.date_diagnosis > '2002-01-01'::date AND ((a_1.diagnosis = ANY (ARRAY['DC951'::text, 'DC957'::text, 'DC959'::text, 'DD472'::text, 'DD472A'::text, 'DD472B'::text, 'DD479B'::text, 'DE858A'::text])) OR a_1.diagnosis > 'DC81%'::text AND a_1.diagnosis < 'DC92%'::text) AND a_1.diagnosis !~~ 'DC910%'::text AND a_1.diagnosis !~~ 'DC92'::text) ua) a
     JOIN ( SELECT oa.patientid,
            oa.date_diagnosis,
            oa.diagnosis,
            oa.tablename,
            oa.datasource,
            oa.priority,
            oa.age
           FROM ( SELECT a_1.patientid,
                    a_1.date_diagnosis,
                    a_1.diagnosis,
                    a_1.tablename,
                    a_1.datasource,
                    a_1.priority,
                    ((a_1.date_diagnosis - b_1.date_birth)::numeric / 365.25)::real AS age
                   FROM ( SELECT view_diagnosses_all.patientid,
                            view_diagnosses_all.date_diagnosis,
                            view_diagnosses_all.diagnosis,
                            view_diagnosses_all.tablename,
                            view_diagnosses_all.datasource,
                            view_diagnosses_all.priority
                           FROM pending.view_diagnosses_all
                          WHERE view_diagnosses_all.datasource <> 'PATO'::text) a_1
                     JOIN ( SELECT patient.patientid,
                            patient.sex,
                            patient.date_birth::date AS date_birth
                           FROM pending.patient) b_1 ON a_1.patientid = b_1.patientid::double precision
                  WHERE ((a_1.date_diagnosis - b_1.date_birth)::numeric / 365.25)::real >= 18::double precision AND a_1.date_diagnosis > '2002-01-01'::date AND ((a_1.diagnosis = ANY (ARRAY['DC951'::text, 'DC957'::text, 'DC959'::text, 'DD472'::text, 'DD472A'::text, 'DD472B'::text, 'DD479B'::text, 'DE858A'::text])) OR a_1.diagnosis > 'DC81%'::text AND a_1.diagnosis < 'DC92%'::text) AND a_1.diagnosis !~~ 'DC910%'::text AND a_1.diagnosis !~~ 'DC92'::text) oa) b ON a.patientid = b.patientid AND a.diagnosis = b.diagnosis;


