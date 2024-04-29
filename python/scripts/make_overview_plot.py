from helpers.sql_helper import *
from helpers.preprocessing_helper import *
from helpers.constants import *
import seaborn as sns
import matplotlib.pyplot as plt
import matplotlib as mpl
import math
from tqdm import tqdm
from tqdm.notebook import tqdm as tq

sns.set(rc={"figure.figsize": (20.7, 16.27)})
sns.set_style("whitegrid")
tq.pandas()


path = "data/all_data.parquet"

log_scale = (False, False)

cut_below = pd.to_datetime("2002-01-01")
cut_above = pd.to_datetime("2023-11-15")

all_data = pd.read_parquet("data/all_data_processed.parquet")
all_data_patients = pd.read_parquet("data/all_data_patients.parquet")

list_of_categories = list(all_data["data_source"].unique())


table_3_supplement = (
    all_data.groupby(["id"]).agg(first_region=("region_id", "last")).reset_index()
)

table_3_supplement.loc[
    table_3_supplement["first_region"].isnull(), "first_region"
] = "None"


all_data_patients.loc[
    all_data_patients["data_source"] == "view_sds_t_adm_t_diag", "data_source"
] = "SDS_t_diag"

all_data_patients.loc[
    all_data_patients["data_source"] == "view_sds_t_adm_t_sksube", "data_source"
] = "SDS_t_sksube"

all_data_patients.loc[
    all_data_patients["data_source"] == "view_sds_t_adm_t_sksopr", "data_source"
] = "SDS_t_sksopr"

all_data.loc[
    all_data["data_source"] == "view_sds_t_adm_t_diag", "data_source"
] = "SDS_t_diag"

all_data.loc[
    all_data["data_source"] == "view_sds_t_adm_t_sksube", "data_source"
] = "SDS_t_sksube"

all_data.loc[
    all_data["data_source"] == "view_sds_t_adm_t_sksopr", "data_source"
] = "SDS_t_sksopr"
all_data["Data Source"] = all_data["data_source"].progress_apply(
    lambda x: x.split("_")[0]
)

LPR_data_sources = [
    "SDS_t_diag",
    "SDS_t_sksube",
    "SDS_t_sksopr",
    "SDS_t_adm",
    "SDS_t_udtilsgh",
]

all_data.loc[all_data["Data Source"] == "SDS", "Data Source"] = "LPR3"
all_data.loc[all_data["data_source"].isin(LPR_data_sources), "Data Source"] = "LPR"


all_data_region_patients = (
    all_data.groupby(["data_source", "region_id"])
    .agg(n_patients=("id", "nunique"))
    .reset_index()
)

colors = {
    "LPR3": "#114F65",
    "RKKP": "#4AB065",
    "LPR": "#228AB0",
    "SP": "#EB9497",
    "PERSIMUNE": "#60121F",
    "LAB": "#FA5959",
}

bins = mpl.dates.date2num(
    pd.date_range(start="2002-01-01", end="2023-11-15", freq="3M")
)

data_sources_grouped = (
    all_data.groupby(["Data Source", "data_source"])
    .agg(first_date=("date", "first"))
    .reset_index()
)

data_sources_grouped = data_sources_grouped.sort_values("data_source").reset_index(
    drop=True
)
rkkp_list = list(
    data_sources_grouped[data_sources_grouped["Data Source"] == "RKKP"][
        "data_source"
    ].values
)
sp_list = list(
    data_sources_grouped[data_sources_grouped["Data Source"] == "SP"][
        "data_source"
    ].values
)
lpr_list = list(
    data_sources_grouped[data_sources_grouped["Data Source"] == "LPR"][
        "data_source"
    ].values
)
lpr3_list = list(
    data_sources_grouped[data_sources_grouped["Data Source"] == "LPR3"][
        "data_source"
    ].values
)
persimune_list = list(
    data_sources_grouped[data_sources_grouped["Data Source"] == "PERSIMUNE"][
        "data_source"
    ].values
)
lab_list = list(
    data_sources_grouped[data_sources_grouped["Data Source"] == "LAB"][
        "data_source"
    ].values
)

# quick fix to get ordering for plot correct
shak = [lpr_list.pop()]
shak.extend(lpr_list)

rkkp_list.extend(shak)
rkkp_list.extend(lpr3_list)
rkkp_list.extend(persimune_list)
rkkp_list.extend(sp_list)
rkkp_list.extend(lab_list)

list_of_categories = [x for x in rkkp_list if x != "SDS_t_adm"]
rows = math.ceil(len(list_of_categories) / 3)
supplement = [x for x in range(19, 45)]

index_list = [0, 1, 2, 3, 4, 5, 6, 7, 18, 8, 9, 12, 10, 11, 13, 14, 15, 16, 17]

index_list.extend(supplement)

list_of_categories = [list_of_categories[x] for x in index_list]


for region in [
    "All",
    "Region Nordjylland",
    "Region Syddanmark",
    "Region Midtjylland",
    "Region Sjælland",
    "Region Hovedstaden",
]:
    if region == "All":
        all_data_subset = all_data.copy()
        all_data_patient_subset = all_data_patients.copy()
    else:
        all_data_subset = all_data[all_data["region_id"] == region].reset_index(
            drop=True
        )
        all_data_patient_subset = all_data_region_patients[
            all_data_region_patients["region_id"] == region
        ].reset_index(drop=True)

    fig, axes = plt.subplots(
        rows,
        8,
        gridspec_kw={
            "width_ratios": [8, 1, 2.2, 8, 1, 2.2, 8, 1],
            "hspace": 0.7,
            "wspace": 0,
        },
        figsize=(38.23, 50.8),
        sharex="col",
    )
    counter = 0

    for j, ax in enumerate(tqdm(axes)):
        for i, ele in enumerate(ax):
            if counter == len(list_of_categories):
                last_real_element = i
                break
            if i in [2, 5]:
                ele.axis("off")
                continue
            elif i in [0, 3, 6]:
                col_counter = int(i / 3) + 1
                data_dist_subset = all_data_subset[
                    all_data_subset["data_source"] == list_of_categories[counter]
                ].reset_index(drop=True)
                if len(data_dist_subset):
                    category_of_data_source = data_dist_subset.head()[
                        "Data Source"
                    ].values[0]
                else:
                    category_of_data_source = None

                chosen_color = colors.get(category_of_data_source)

                sns.histplot(
                    data=data_dist_subset,
                    x="date",
                    color=chosen_color,
                    kde=True,
                    bins=bins,
                    kde_kws={"bw_adjust": 0.5},
                    discrete=False,
                    multiple="dodge",
                    ax=ele,
                    legend=False,
                )
                ele.text(
                    0,
                    1.15,
                    f"${chr(65+j)}_{col_counter}$",
                    horizontalalignment="center",
                    verticalalignment="center",
                    fontsize="xx-large",
                    transform=ele.transAxes,
                    style="italic",
                    weight="bold",
                )
                ele.set_title(title_dict.get(list_of_categories[counter]))
                ele.set_xlim(left=cut_below, right=cut_above)
                ele.set_yscale("log")
                ele.set_ylim(1, 3000000)
                ele.xaxis.set_tick_params(which="both", labelbottom=True)

            elif i in [1, 4, 7]:
                data_patient_subset = all_data_patient_subset[
                    all_data_patient_subset["data_source"]
                    == list_of_categories[counter]
                ].reset_index(drop=True)

                if len(data_patient_subset):
                    size = data_patient_subset["n_patients"].values[0]
                else:
                    size = 0
                ele.scatter(
                    x=[0],
                    y=[0],
                    s=size / 100,
                    color="black",
                )
                ele.annotate(
                    rf"$N = {size}$",
                    xy=(0.02, 0),
                    xycoords="data",
                    xytext=(3, 0),
                    textcoords="offset points",
                )
                ele.grid(False)
                ele.set_xlabel("")
                ele.set_ylabel("")
                ele.set(xticklabels=[])
                ele.set(yticklabels=[])
                ele.spines["top"].set_visible(False)
                ele.spines["right"].set_visible(False)
                ele.spines["bottom"].set_visible(False)
                ele.spines["left"].set_visible(False)
                counter += 1

    axes[-1][0].set_xlabel("Year")
    axes[-1][3].set_xlabel("Year")
    axes[-1][6].set_xlabel("Year")

    fig.savefig(
        f"../plots/combined_plot_{region}.pdf",
        bbox_inches="tight",
    )

    plt.savefig(
        f"../plots/combined_plot_{region}.png",
        bbox_inches="tight",
        dpi=300,
    )
