import pandas as pd
import numpy as np

from data_processing.define_cohort import COHORT as patients
from data_processing.define_cohort import data as patient_table

cut_below = pd.to_datetime("2002-01-01")
cut_above = pd.to_datetime("2023-11-15")

all_data = pd.read_parquet("data/all_data_processed.parquet")


disease_dict = {"DC900": "MM", "DC833": "LYMPH", "DC911": "CLL"}

patient_table["disease"] = patient_table["diagnosis"].progress_apply(
    lambda x: disease_dict.get(x, np.nan)
)

patient_diags = (
    patient_table.groupby(["patientid", "disease"])
    .agg(icd=("diagnosis", "first"))
    .reset_index()
    .rename(columns={"patientid": "id"})
)

merged_data = all_data.merge(patient_diags)
merged_data_agg = (
    merged_data.groupby(["disease", "region_id", "id", "data_source"])
    .agg(date=("date", "first"))
    .reset_index()
)


merged_data_agg = merged_data_agg[
    (merged_data_agg["date"] > cut_below.date())
    & (merged_data_agg["date"] < cut_above.date())
].reset_index(drop=True)


data_sources = (
    merged_data_agg.groupby(["disease", "region_id", "data_source"])
    .agg(n_patients=("id", "nunique"))
    .reset_index()
)


data_sources = data_sources.sort_values("n_patients", ascending=False).reset_index(
    drop=True
)


merged_data_agg.groupby(["disease", "region_id"]).agg(n_patients=("id", "nunique"))