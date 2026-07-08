import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

data = [
    ("Marigold",            90.00, 97.99, "other"),
    ("Depth Anything V2",   89.52, 93.96, "other"),
    ("MiDaS Hybrid",        89.52, 96.64, "selected"),
    ("AdaBins",             89.05, 95.97, "other"),
    ("Depth Anything V1",   84.76, 98.66, "other"),
    ("Depth Anything V3",   83.81, 95.30, "other"),
    ("ZoeDepth",            80.95, 99.33, "other"),
    ("DPT Large Original",  80.48, 97.32, "other"),
    ("LeReS",               80.00, 95.30, "other"),
    ("MiDaS Large",         79.05, 99.33, "other"),
]

colors  = {"selected": "#d62728", "other": "#aaaaaa"}
markers = {"selected": "*",       "other": "x"}
sizes   = {"selected": 220,       "other": 60}

fig, ax = plt.subplots(figsize=(6.5, 6.0))

# Use the same range and tick spacing on both axes so that horizontal and
# vertical differences have the same visual magnitude.
xlim = (78, 101)
ylim = (78, 101)

for name, fp, ust, status in data:
    ax.scatter(fp, ust,
               c=colors[status], marker=markers[status],
               s=sizes[status], zorder=3,
               edgecolors="white" if status == "selected" else "none",
               linewidths=0.8)

label_offsets = {
    "MiDaS Hybrid":        (5, 5),
    "Marigold":            (5, 5),
    "Depth Anything V2":   (5, 5),
    "AdaBins":             (5, -14),
    "Depth Anything V1":   (5, 5),
    "Depth Anything V3":   (5, 5),
    "ZoeDepth":            (5, 5),
    "DPT Large Original":  (5, -14),
    "LeReS":               (5, 5),
    "MiDaS Large":         (5, -14),
}
for name, fp, ust, status in data:
    dx, dy = label_offsets.get(name, (5, 5))
    ax.annotate(name, (fp, ust), xytext=(dx, dy),
                textcoords="offset points",
                fontsize=7.5, color="#333333",
                arrowprops=None)

ax.set_xlabel("FruitsPark validation accuracy (%)", fontsize=10)
ax.set_ylabel("UrbanStreetTree validation accuracy (%)", fontsize=10)
ax.set_title("Cross-dataset depth-source stability", fontsize=11)
ax.set_xlim(*xlim)
ax.set_ylim(*ylim)
ticks = np.arange(78, 101, 2)
ax.set_xticks(ticks)
ax.set_yticks(ticks)
ax.set_aspect("equal", adjustable="box")
ax.plot(xlim, ylim, linestyle="--", linewidth=0.8, color="#777777",
        alpha=0.7, zorder=1, label="Equal accuracy")
ax.grid(True, linewidth=0.4, alpha=0.5)

legend_handles = [
    mpatches.Patch(color=colors["selected"], label="Selected (MiDaS Hybrid)"),
    mpatches.Patch(color=colors["other"],    label="Other depth sources"),
    plt.Line2D([0], [0], color="#777777", linestyle="--",
               linewidth=0.8, label="Equal accuracy"),
]
ax.legend(handles=legend_handles, fontsize=8, loc="lower right")

plt.tight_layout()
out = "/Users/takahiro/latex/IEEE_ACCESS/figures/fig23_depth_model_comparison.png"
plt.savefig(out, dpi=200, bbox_inches="tight")
print(f"Saved: {out}")
