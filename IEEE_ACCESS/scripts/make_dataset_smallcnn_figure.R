args <- commandArgs(trailingOnly = FALSE)
file_arg <- args[grep("^--file=", args)][1]
this_file <- sub("^--file=", "", file_arg)
root <- normalizePath(file.path(dirname(this_file), ".."), mustWork = TRUE)
output_path <- file.path(root, "figures", "fig_dataset_smallcnn_mask_ablation.png")

scores <- c(0.756, 0.728, 0.767, 0.701, 0.778, 0.763)
labels <- c(
  "Full\nvalidation",
  "Full\ntest",
  "Background-only\nvalidation",
  "Background-only\ntest",
  "Tree-only\nvalidation",
  "Tree-only\ntest"
)

png(output_path, width = 2400, height = 700, res = 220)
par(
  family = "sans",
  mar = c(4.4, 4.8, 0.5, 0.7),
  cex.axis = 1.05,
  cex.lab = 1.14
)

positions <- barplot(
  scores,
  names.arg = labels,
  ylim = c(0, 1),
  yaxs = "i",
  las = 1,
  col = "#2c7fb8",
  border = NA,
  ylab = "Balanced accuracy",
  cex.names = 0.98
)

abline(h = 1 / 13, col = "#6b7280", lty = 2, lwd = 1.7)
text(positions, scores + 0.035, sprintf("%.3f", scores), cex = 0.94)
legend(
  "topright",
  legend = "Chance (1/13)",
  lty = 2,
  lwd = 1.7,
  col = "#6b7280",
  bty = "n",
  cex = 0.94
)

dev.off()
