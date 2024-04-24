from helpers.sql_helper import *
from helpers.preprocessing_helper import *
from helpers.constants import *
import seaborn as sns
import matplotlib.pyplot as plt
import matplotlib as mpl
from tqdm import tqdm
from tqdm.notebook import tqdm as tq

sns.set(rc={"figure.figsize": (20.7, 16.27)})
sns.set_style("whitegrid")
tq.pandas()

log_scale = (False, False)

cut_below = pd.to_datetime("2002-01-01")
cut_above = pd.to_datetime("2023-11-15")

all_data = pd.read_parquet("data/all_data_processed.parquet")
list_of_categories = list(all_data["data_source"].unique())

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

colors = {
    "LPR3": "#114F65",
    "RKKP": "#4AB065",
    "LPR": "#228AB0",
    "SP": "#EB9497",
    "PERSIMUNE": "#60121F",
    "LAB": "#FA5959",
}


bins = mpl.dates.date2num(
    pd.date_range(start="2002-01-01", end="2023-11-15", freq="6M")
)


title_dict = {
    "RKKP_DaMyDa": "RKKP - DaMyDa",
    "RKKP_LYFO": "RKKP - LYFO",
    "RKKP_CLL": "RKKP - CLL",
    "SDS_t_diag": "SDS (LPR) - Diagnoses",
    "SDS_epikur": "SDS - Epikur",
    "SDS_lab_forsker": "SDS - LABKA",
    "SDS_diagnoser": "SDS (LPR3) - Diagnoses",
    "SDS_pato": "SDS - PATOBANK",
    "PERSIMUNE_biochemistry": "PERSIMUNE - LABKA",
    "SP_ADT_haendelser": "SP - Admissions",
    "SP_Journalnotater_del1": "SP - Medical Notes 1",
    "PERSIMUNE_microbiology_analysis": "PERSIMUNE - MiBa",
}

list_of_categories = list(title_dict.items())


fig, axes = plt.subplots(
    4,
    3,
    gridspec_kw={
        "hspace": 0.7,
    },
    figsize=(11.69, 8.27),
    sharex="all",
    sharey="all",
)
counter = 0

plt.rcParams.update({"font.size": 9})

for j, ax in enumerate(tqdm(axes)):
    for i, ele in enumerate(ax):
        data_dist_subset = all_data[
            all_data["data_source"] == list_of_categories[counter][0]
        ].reset_index(drop=True)
        if len(data_dist_subset):
            category_of_data_source = data_dist_subset.head()["Data Source"].values[0]
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
            1.25,
            f"{chr(97+counter)}",
            horizontalalignment="center",
            verticalalignment="center",
            fontsize="xx-large",
            transform=ele.transAxes,
            weight="bold",
        )
        ele.set_title(list_of_categories[counter][1], fontdict={"fontsize": 12})
        ele.set_xlim(left=cut_below, right=cut_above)
        ele.set_yscale("log")
        ele.set_ylim(1, 5000000)
        ele.tick_params(axis="x", labelsize="medium", labelrotation=45)
        ele.tick_params(axis="y", labelsize="medium")
        counter += 1

axes[-1][0].set_xlabel("Year")
axes[-1][1].set_xlabel("Year")
axes[-1][2].set_xlabel("Year")

fig.savefig(
    f"../../../projects2/dalyca_r/sftp/fromNGC/combined_plot_small.pdf",
    bbox_inches="tight",
)

plt.savefig(
    f"../../../projects2/dalyca_r/sftp/fromNGC/combined_plot_small.png",
    bbox_inches="tight",
    dpi=300,
)
