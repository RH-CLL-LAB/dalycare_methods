from helpers.sql_helper import *
from helpers.preprocessing_helper import *
from helpers.constants import *
import seaborn as sns
import os
import matplotlib as mpl
import numpy as np
from tqdm import tqdm
from tqdm.notebook import tqdm as tq

from data_processing.sds_lab_map import sds_lab
from data_processing.sds_special_cases import subset_of_sds_data

# SDS_t_vaevsanvend_markoer has no date and is excluded here
from data_processing.lpr_three import list_of_lpr_three_merged_data

from data_processing.shak_codes_mapping import SHAK_CODES_MERGE_TABLE

sns.set(rc={"figure.figsize": (20.7, 16.27)})
sns.set_style("whitegrid")
tq.pandas()


path = "data/all_data.parquet"
bins = mpl.dates.date2num(
    pd.date_range(start="2002-01-01", end="2023-11-15", freq="3M")
)

log_scale = (False, False)

cut_below = pd.to_datetime("2002-01-01")
cut_above = pd.to_datetime("2023-11-15")  # new cutoff date from Christian

if not os.path.isfile(path):
    print("Downloading LPR tables")
    list_of_data = [
        download_and_rename_data(table_name=table_name, config_dict=LPR_TABLES)
        for table_name in tqdm(LPR_TABLES)
    ]

    list_of_data.extend(list_of_lpr_three_merged_data)

    print("Downloading journal data")

    journal_tables = [
        download_and_rename_data(x, JOURNAL_TABLES) for x in tqdm(JOURNAL_TABLES)
    ]

    journal_tables_dfs = [
        journal_tables[0][["id", "date", "data_source"]].reset_index(drop=True),
        journal_tables[1]
        .merge(journal_tables[0][["note_id", "id"]])[["id", "date", "data_source"]]
        .reset_index(drop=True),
    ]
    list_of_data.extend(journal_tables_dfs)
    list_of_data.extend(subset_of_sds_data)
    list_of_data.append(sds_lab)

    merged_data = pd.concat(list_of_data).reset_index(drop=True)

    merged_data = merged_data[
        ["id", "hospital_id", "date", "data_source", "region"]
    ].reset_index(drop=True)

    del list_of_lpr_three_merged_data

    merged_data["id"] = pd.to_numeric(merged_data["id"], downcast="unsigned")
    merged_data["data_source"] = merged_data["data_source"].astype("category")

    print("Downloading all the other tables")
    list_of_data = [
        download_and_rename_data(
            table_name=table_name, config_dict=COLUMNS_OF_RELEVANCE
        )
        for table_name in tqdm(COLUMNS_OF_RELEVANCE)
    ]

    all_data = pd.concat(list_of_data)
    all_data["data_source"] = all_data["data_source"].astype("category")

    all_data["id"] = pd.to_numeric(all_data["id"], downcast="unsigned")
    del list_of_data
    print("Concatenating dataframes")

    # concatenate all data
    all_data = pd.concat([all_data, merged_data]).reset_index(drop=True)

    date_dates = [x for x in DATE_CONVERTER if DATE_CONVERTER.get(x) == date_from_date]

    timestamp_dates = [
        x for x in DATE_CONVERTER if DATE_CONVERTER.get(x) == date_from_timestamp
    ]
    unix_dates = [
        x for x in DATE_CONVERTER if DATE_CONVERTER.get(x) == date_from_origin_unix
    ]

    from scripts.data_processing.define_cohort import (
        COHORT as patients,
    )

    all_data = all_data[all_data["id"].isin(patients)].reset_index(drop=True)

    data_sources = all_data["data_source"].unique()

    date_list_concatenated = [
        x
        for date_lists in [date_dates, timestamp_dates, unix_dates]
        for x in date_lists
    ]

    # fixing stupid typos
    all_data.loc[all_data["date"] == "0220-12-30 06:00:00.0000000", "date"] = (
        "2020-12-30 06:00:00.0000000"
    )
    all_data.loc[all_data["date"] == "2313-02-21 23:00:00.0000000", "date"] = (
        "2013-02-21 23:00:00.0000000"
    )

    print("Converting dates to consistent format")

    for data_source in tqdm(data_sources):
        if data_source in date_dates:
            all_data.loc[all_data["data_source"] == data_source, "date"] = (
                pd.to_datetime(
                    all_data[all_data["data_source"] == data_source]["date"],
                    errors="coerce",
                    utc=True,
                ).dt.date
            )
        elif data_source in timestamp_dates:
            all_data.loc[all_data["data_source"] == data_source, "date"] = (
                pd.to_datetime(
                    all_data[all_data["data_source"] == data_source]["date"],
                    unit="s",
                    errors="coerce",
                ).dt.date
            )
        elif data_source in unix_dates:
            all_data.loc[all_data["data_source"] == data_source, "date"] = (
                pd.to_datetime(
                    all_data[all_data["data_source"] == data_source]["date"],
                    origin="unix",
                    unit="d",
                    errors="coerce",
                ).dt.date
            )

    print("Convert data types")
    all_data["region"] = all_data["region"].astype(str)
    all_data["hospital_id"] = all_data["hospital_id"].astype(str)
    all_data["hospital_id"] = all_data["hospital_id"].progress_apply(
        lambda x: x.split(".")[0]
    )

    print("Apply Hospital -> Region Mapping")

    hospital_to_region_dataframe = pd.DataFrame(
        HOSPITAL_REGION_MAPPING.items(),
        columns=["hospital_id", "region_id_from_hospital_id"],
    )

    SHAK_CODES_MERGE_TABLE = SHAK_CODES_MERGE_TABLE.drop_duplicates().reset_index(
        drop=True
    )

    SHAK_CODES_MERGE_TABLE["hospital_id"] = SHAK_CODES_MERGE_TABLE[
        "hospital_id"
    ].astype(str)

    SHAK_CODES_MERGE_TABLE = SHAK_CODES_MERGE_TABLE.rename(
        columns={"region": "region_id_from_hospital_id"}
    ).reset_index(drop=True)

    organisation_table = load_data_from_table(
        "SDS_organisationer", subset_columns=["sorenhed", "region_tekst"]
    )
    organisation_table = organisation_table.rename(
        columns={"sorenhed": "hospital_id", "region_tekst": "region"}
    )
    organisation_table = (
        organisation_table.groupby("hospital_id")
        .agg(region_id_from_hospital_id=("region", "first"))
        .reset_index()
    )
    organisation_table["hospital_id"] = organisation_table["hospital_id"].astype(str)

    list_of_mapping_dfs = [
        hospital_to_region_dataframe,
        SHAK_CODES_MERGE_TABLE,
        organisation_table,
    ]

    hospital_merge_table = pd.concat(list_of_mapping_dfs).reset_index(drop=True)

    hospital_merge_table = hospital_merge_table[
        hospital_merge_table["region_id_from_hospital_id"] != "Ukendt"
    ].reset_index(drop=True)

    all_data = all_data.merge(hospital_merge_table, how="left")

    region_to_region_dataframe = pd.DataFrame(
        REGION_REGION_MAPPING.items(), columns=["region", "region_id"]
    )

    all_data = all_data.merge(region_to_region_dataframe, how="left")

    all_data.loc[all_data["region_id"].isna(), "region_id"] = all_data.loc[
        all_data["region_id"].isna()
    ]["region_id_from_hospital_id"]

    print("Sort dataset")
    all_data = all_data.sort_values("date").reset_index(drop=True)

    print("Save data")

    all_data.to_parquet("../data/all_data.parquet")

    REGION_TO_NUMERIC = {
        "Region Nordjylland": 0,
        "Region Syddanmark": 1,
        "Region Sjælland": 2,
        "Region Midtjylland": 3,
        "Region Hovedstaden": 4,
    }

    REVERSE_REGION_TO_NUMERIC = {value: key for key, value in REGION_TO_NUMERIC.items()}

    print("Convert Region to numeric")
    all_data["region_id"] = all_data["region_id"].progress_apply(
        lambda x: REGION_TO_NUMERIC.get(x, np.nan)
    )
    print("Forward + backward fill regions")
    all_data["region_id"] = all_data.groupby("id")["region_id"].ffill()
    all_data["region_id"] = all_data.groupby("id")["region_id"].bfill()

    all_data["region_id"] = all_data["region_id"].progress_apply(
        lambda x: REVERSE_REGION_TO_NUMERIC.get(x, np.nan)
    )

    all_data_patients = (
        all_data.groupby(["data_source"])
        .agg(n_patients=("id", "nunique"))
        .reset_index()
    )

    all_data_patients["Data Source"] = all_data_patients["data_source"].apply(
        lambda x: x.split("_")[0]
    )

    all_data = all_data[
        ["id", "date", "region", "data_source", "region_id"]
    ].reset_index(drop=True)

    print("Save all data")

    all_data.to_parquet("../data/all_data_processed.parquet")
    all_data_patients.to_parquet("../data/all_data_patients.parquet")
