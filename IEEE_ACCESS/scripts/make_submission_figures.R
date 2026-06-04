args <- commandArgs(trailingOnly = FALSE)
file_arg <- args[grep("^--file=", args)][1]
this_file <- sub("^--file=", "", file_arg)
root <- normalizePath(file.path(dirname(this_file), ".."), mustWork = TRUE)
fig_dir <- file.path(root, "figures")
data_root <- normalizePath(file.path(root, "..", "new_experiments_result"), mustWork = TRUE)

save_png <- function(path, width = 2400, height = 1200, res = 220) {
  png(path, width = width, height = height, res = res)
  par(family = "sans")
}

box <- function(x1, y1, x2, y2, label, col, border = "#4b5563", cex = 0.9) {
  rect(x1, y1, x2, y2, col = col, border = border, lwd = 1.5)
  text((x1 + x2) / 2, (y1 + y2) / 2, label, cex = cex)
}

arrow <- function(x1, y1, x2, y2, col = "#374151") {
  arrows(x1, y1, x2, y2, length = 0.08, lwd = 1.5, col = col)
}

make_framework <- function() {
  save_png(file.path(fig_dir, "fig04_framework_current.png"), 2400, 1300)
  par(mar = c(1, 1, 2, 1))
  plot(0, 0, type = "n", xlim = c(0, 1), ylim = c(0, 1), axes = FALSE, xlab = "", ylab = "")
  title("Depth-regularized sparse MIL pipeline", cex.main = 1.35, font.main = 2)

  box(0.04, 0.70, 0.20, 0.84, "Mid-range\nRGB image", "#e0f2fe")
  box(0.27, 0.70, 0.45, 0.84, "Sliding-window\ncandidate patches", "#e0f2fe")
  box(0.52, 0.70, 0.73, 0.84, "Trunk-biased sampling\nSobel score + bag ratio", "#dcfce7")
  box(0.80, 0.70, 0.96, 0.84, "Sparse\npatch bag", "#dcfce7")

  box(0.24, 0.40, 0.45, 0.55, "Frozen visual backbone\nViT / DINO / Swin", "#fef3c7")
  box(0.53, 0.40, 0.73, 0.55, "ABMIL\nattention pooling", "#fee2e2")
  box(0.81, 0.40, 0.96, 0.55, "Species\nprediction", "#e5e7eb")

  box(0.05, 0.14, 0.26, 0.29, "Training only:\nmonocular depth map", "#ede9fe")
  box(0.34, 0.14, 0.60, 0.29, "Depth-guided augmentation\nforeground preserved\nbackground perturbed", "#ede9fe")
  box(0.70, 0.14, 0.93, 0.29, "RGB-only inference\nno depth required", "#e5e7eb")

  arrow(0.20, 0.77, 0.27, 0.77)
  arrow(0.45, 0.77, 0.52, 0.77)
  arrow(0.73, 0.77, 0.80, 0.77)
  arrow(0.88, 0.70, 0.36, 0.55)
  arrow(0.45, 0.475, 0.53, 0.475)
  arrow(0.73, 0.475, 0.81, 0.475)
  arrow(0.26, 0.215, 0.34, 0.215, "#6d28d9")
  arrow(0.60, 0.215, 0.70, 0.215, "#6d28d9")
  arrow(0.47, 0.29, 0.35, 0.40, "#6d28d9")
  text(0.5, 0.06, "Depth regularizes training data; deployed inference processes only RGB patches.", cex = 0.85, col = "#374151")
  dev.off()
}

make_overall <- function() {
  df <- read.csv(file.path(data_root, "OverallComparison4Seed", "analysis_outputs", "model_seed_summary.csv"))
  selected <- c("ResNet18 GAP", "ViT GAP", "Swin GAP", "ViT MIL", "DINOv2 MIL", "ViT DepthAug", "DINOv2 DepthAug")
  label_map <- c(
    "ResNet18 GAP" = "ResNet18\nGAP",
    "ViT GAP" = "ViT\nGAP",
    "Swin GAP" = "Swin\nGAP",
    "ViT MIL" = "ViT\nMIL",
    "DINOv2 MIL" = "DINOv2\nMIL",
    "ViT DepthAug" = "ViT\nDepthAug",
    "DINOv2 DepthAug" = "DINOv2\nDepthAug"
  )
  group_cols <- c("baseline" = "#6b7280", "mil" = "#2563eb", "depth_aug" = "#d97706")
  save_png(file.path(fig_dir, "fig15_overall_comparison_selected.png"), 2400, 1050)
  par(mfrow = c(1, 2), mar = c(5.5, 4.2, 3.2, 1), oma = c(0.5, 0, 2, 0))
  for (dataset in c("FruitsPark", "UrbanStreetTree")) {
    sub <- df[df$dataset == dataset & df$label %in% selected, ]
    sub <- sub[match(selected, sub$label), ]
    vals <- sub$mean_macro_f1 * 100
    errs <- sub$std_macro_f1 * 100
    cols <- group_cols[sub$method]
    title_txt <- ifelse(dataset == "FruitsPark", "FruitsPark (val)", "UrbanStreetTree (test)")
    bp <- barplot(vals, ylim = c(75, 100), col = cols, border = "white", names.arg = label_map[sub$label], las = 1, cex.names = 0.72, main = title_txt, ylab = "Macro-F1 (%)")
    arrows(bp, vals - errs, bp, vals + errs, angle = 90, code = 3, length = 0.035, lwd = 1.2)
    grid(nx = NA, ny = NULL, col = "#e5e7eb")
    text(bp, pmin(vals + errs + 1.0, 99.4), sprintf("%.1f", vals), cex = 0.65)
  }
  mtext("Representative four-seed model comparison", outer = TRUE, cex = 1.1, font = 2)
  dev.off()
}

make_depth_delta <- function() {
  df <- read.csv(file.path(data_root, "OverallComparison4Seed", "analysis_outputs", "baseline_delta_summary.csv"))
  labels <- list(
    ViT = c("ViT MIL", "ViT DepthAug"),
    DINOv1 = c("DINOv1 MIL", "DINOv1 DepthAug"),
    DINOv2 = c("DINOv2 MIL", "DINOv2 DepthAug"),
    DINOv3 = c("DINOv3 MIL", "DINOv3 DepthAug"),
    Swin = c("Swin MIL", "Swin DepthAug")
  )
  save_png(file.path(fig_dir, "fig16_depth_aug_delta_submission.png"), 2200, 850)
  par(mfrow = c(1, 2), mar = c(5, 4.5, 3.2, 1), oma = c(0, 0, 2, 0))
  for (dataset in c("FruitsPark", "UrbanStreetTree")) {
    deltas <- sapply(names(labels), function(backbone) {
      pair <- labels[[backbone]]
      vals <- df[df$dataset == dataset & df$label %in% pair, c("label", "mean_macro_f1")]
      vals <- vals$mean_macro_f1[match(pair, vals$label)]
      (vals[2] - vals[1]) * 100
    })
    cols <- ifelse(deltas >= 0, "#0f766e", "#b91c1c")
    title_txt <- ifelse(dataset == "FruitsPark", "FruitsPark (val)", "UrbanStreetTree (test)")
    bp <- barplot(deltas, ylim = c(min(-4, min(deltas) - 1.2), max(6, max(deltas) + 1)), col = cols, border = "white", main = title_txt, ylab = "DepthAug - MIL Macro-F1 (pp)", las = 2)
    abline(h = 0, lwd = 1.2, col = "#111827")
    grid(nx = NA, ny = NULL, col = "#e5e7eb")
    text(bp, deltas + ifelse(deltas >= 0, 0.35, -0.35), sprintf("%+.1f", deltas), cex = 0.75, pos = ifelse(deltas >= 0, 3, 1))
  }
  mtext("Depth-guided augmentation effect by backbone", outer = TRUE, cex = 1.1, font = 2)
  dev.off()
}

make_pareto <- function() {
  ratio <- read.csv(file.path(data_root, "Sparse_experiments", "ratio_summary.csv"))
  rec <- read.csv(file.path(data_root, "Sparse_experiments", "recommended_ratios.csv"))
  save_png(file.path(fig_dir, "fig17_pareto_frontier_submission.png"), 2300, 950)
  par(mfrow = c(1, 2), mar = c(4.6, 4.4, 3.2, 1), oma = c(1.7, 0, 2, 0))
  cols <- c("FruitsPark" = "#0f766e", "UrbanStreetTree" = "#b91c1c")
  for (dataset in c("FruitsPark", "UrbanStreetTree")) {
    d <- ratio[ratio$dataset == dataset, ]
    d <- d[order(d$instances), ]
    color <- cols[[dataset]]
    title_txt <- ifelse(dataset == "FruitsPark", "FruitsPark (val)", "UrbanStreetTree (test)")
    plot(d$instances, d$acc_mean, type = "b", pch = 16, col = color, lwd = 2, ylim = c(85, 99), xlab = "Average instances per bag", ylab = "Accuracy (%)", main = title_txt)
    polygon(c(d$instances, rev(d$instances)), c(d$acc_mean - d$acc_std, rev(d$acc_mean + d$acc_std)), col = adjustcolor(color, alpha.f = 0.13), border = NA)
    lines(d$instances, d$acc_mean, type = "b", pch = 16, col = color, lwd = 2)
    grid(col = "#e5e7eb")
    text(d$instances, d$acc_mean + 0.45, labels = sprintf("%.1f", d$ratio), cex = 0.72)
    rd <- rec[rec$dataset == dataset, ]
    best <- rd[rd$choice == "best_acc", ]
    eff <- rd[rd$choice == "efficient_1pp", ]
    points(best$instances, best$acc_mean, pch = 1, cex = 2.0, lwd = 2.2)
    points(eff$instances, eff$acc_mean, pch = 0, cex = 2.0, lwd = 2.2)
    text(best$instances, best$acc_mean - 0.9, labels = "best", cex = 0.75)
    text(eff$instances, eff$acc_mean + 1.0, labels = "efficient", cex = 0.75)
  }
  mtext("Patch-budget Pareto frontier", outer = TRUE, cex = 1.1, font = 2)
  legend("bottom", inset = -0.04, xpd = NA, horiz = TRUE, bty = "n", legend = c("Best accuracy", "Efficient <= 1pp"), pch = c(1, 0), pt.cex = 1.4, cex = 0.82)
  dev.off()
}

make_framework()
make_overall()
make_depth_delta()
make_pareto()
