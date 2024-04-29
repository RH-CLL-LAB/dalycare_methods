INSERT INTO public.diagnoses_all(
	 patientid, date_diagnosis, diagnosis, tablename, datasource)
SELECT patientid::int, date_diagnosis, diagnosis, tablename, datasource
	FROM pending.view_diagnosses_all
where patientid in (SELECT distinct patientid FROM public.t_dalycare_diagnoses) -- This ensures only adult patients with a dalycare diagnoses are included in the diagnoses_all table
;

