import requests
import geopandas as gpd
from shapely.geometry import Polygon
from mpl_toolkits.axes_grid1 import make_axes_locatable
import matplotlib.pyplot as plt
import pandas as pd


LINK = "https://api.dataforsyningen.dk/regioner?format=geojson"
r = requests.get(url=LINK)
data = r.json()
list_of_geometries = []
list_of_dfs = []
for feature, region in zip(
    data["features"],
    ["Nordjylland", "Midtjylland", "Syddanmark", "Hovedstaden", "Sjælland"],
):
    polygons = [
        Polygon(polygon)
        for feature_extracted in feature["geometry"]["coordinates"]
        for polygon in feature_extracted
    ]
    df = gpd.GeoDataFrame({"geometry": polygons})
    df["region"] = region
    list_of_dfs.append(df)

df = gpd.GeoDataFrame(pd.concat(list_of_dfs, ignore_index=True))
df = df.reset_index()

df = df.sort_values(by=["region", "index"]).reset_index(drop=True)

df.iloc[4:129, 1] = df.iloc[4:129, 1].translate(xoff=-2.5, yoff=2)

df.crs = {"init": "epsg:4326"}

df = df.to_crs(epsg=3857)

import matplotlib.patches as patches

patients_per_disease = {
    "CLL": [2163, 3308, 3517, 7037, 4353],
    "DLBCL": [1467, 3014, 3249, 5032, 4256],
    "MM": [1338, 2788, 3661, 4904, 3472],
}

patients_per_disease = {
    "CLL": {
        "Nordjylland": 2386,
        "Midtjylland": 4902,
        "Syddanmark": 4069,
        "Hovedstaden": 8121,
        "Sjælland": 4541,
    },
    "DLBCL": {
        "Nordjylland": 1883,
        "Midtjylland": 4910,
        "Syddanmark": 3930,
        "Hovedstaden": 7052,
        "Sjælland": 4460,
    },
    "MM": {
        "Nordjylland": 1734,
        "Midtjylland": 4898,
        "Syddanmark": 4491,
        "Hovedstaden": 6930,
        "Sjælland": 3752,
    },
}


people = {
    "Nordjylland": 594426,
    "Midtjylland": 1360054,
    "Syddanmark": 1238252,
    "Hovedstaden": 1898426,
    "Sjælland": 850230,
}

df["geometry"] = df["geometry"].simplify(tolerance=320)
df.set_geometry("geometry")
df["geometry"] = df["geometry"].scale(1.2, 1.2, origin=(0, 0))

bounds = df.iloc[4:129, 1].total_bounds

constant_push_border = 10000

df = df.cx[1e6:1.81e6, 8.71e6:9.61e6]

fig, axes = plt.subplots(1, 3, figsize=(11, 9))
keys_dfs = {}
for ax, key in zip(axes, patients_per_disease.keys()):
    relevant_dict = patients_per_disease.get(key)
    df["patients"] = df["region"].apply(lambda x: relevant_dict.get(x))
    df["people"] = df["region"].apply(lambda x: people.get(x))
    df["patients_adjusted"] = (df["patients"] / df["people"]) * 100000
    keys_dfs[key] = (
        df.groupby(["region"])
        .agg(patients=("patients_adjusted", "first"))
        .reset_index()
    )
    divider = make_axes_locatable(ax)

    rect = patches.Rectangle(
        (bounds[0] - constant_push_border, bounds[1] - constant_push_border),
        bounds[2] - bounds[0] + constant_push_border,
        bounds[3] - bounds[1] + constant_push_border,
        linewidth=1,
        edgecolor="black",
        facecolor="none",
    )

    if key == "MM":
        legend_status = True
        divider = make_axes_locatable(ax)
        cax = divider.append_axes("right", size="3%", pad=0.0001)
    else:
        legend_status = False
        cax = None
    plotting = df.plot(
        column="patients_adjusted",
        ax=ax,
        legend=legend_status,
        legend_kwds={"label": r"Patients per $100,000$ inhabitants"},
        vmin=0,
        cmap="viridis",
        cax=cax,
        figsize=(15, 10),
    )
    plotting.set_axis_off()
    plotting.set_title(key)
    ax.add_patch(rect)
fig.tight_layout(pad=4)
fig.savefig("../../plots/denmark_region_counts.pdf")
plt.savefig("../../plots/denmark_region_counts.png", dpi=300)
