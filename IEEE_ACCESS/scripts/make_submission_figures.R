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
  df <- read.csv(file.path(data_root, "OverallComparison4Seed", "all_frozen_comparison_analysis_outputs_frozen_unified_seed42", "frozen_unified_seed42_summary.csv"))
  selected <- c("ResNet18 GAP", "ViT GAP", "Swin GAP", "ViT MIL", "DINOv2 MIL", "ViT DepthAug", "DINOv2 DepthAug")
  label_map <- c(
    "ResNet18 GAP" = "ResNet18\nGAP",
    "ViT GAP" = "ViT\nGAP",
    "Swin GAP" = "Swin\nGAP",
    "ViT MIL" = "ViT\nMIL",
    "DINOv2 MIL" = "DINOv2\nMIL",
    "ViT DepthAug" = "ViT\nDA",
    "DINOv2 DepthAug" = "DINOv2\nDA"
  )
  group_cols <- c("baseline" = "#6b7280", "mil" = "#2563eb", "depth_aug" = "#d97706")
  save_png(file.path(fig_dir, "fig15_overall_comparison_selected.png"), 2400, 1050)
  par(mfrow = c(1, 2), mar = c(5.6, 4.8, 3.2, 1), oma = c(0.5, 0, 2, 0),
      cex.axis = 0.98, cex.lab = 1.08, cex.main = 1.18)
  for (dataset in c("FruitsPark", "UrbanStreetTree")) {
    sub <- df[df$dataset == dataset & df$label %in% selected, ]
    sub <- sub[match(selected, sub$label), ]
    vals <- sub$macro_f1 * 100
    cols <- group_cols[sub$method]
    title_txt <- ifelse(dataset == "FruitsPark", "FruitsPark (val)", "UrbanStreetTree (test)")
    bp <- barplot(vals, ylim = c(0, 105), yaxs = "i", col = cols, border = "white",
                  names.arg = rep("", length(vals)), las = 1,
                  main = title_txt, ylab = "Macro-F1 (%)")
    text(bp, -2.5, label_map[sub$label], cex = c(0.78, rep(0.95, length(vals) - 1)),
         adj = c(0.5, 1), xpd = NA)
    text(bp, vals + 2.5, sprintf("%.1f", vals), cex = 0.92)
  }
  mtext("Representative model comparison", outer = TRUE, cex = 1.22, font = 2)
  dev.off()
}

make_depth_delta <- function() {
  df <- read.csv(file.path(data_root, "OverallComparison4Seed", "all_frozen_comparison_analysis_outputs_frozen_unified_seed42", "frozen_unified_seed42_summary.csv"))
  labels <- list(
    ViT = c("ViT MIL", "ViT DepthAug"),
    DINOv1 = c("DINOv1 MIL", "DINOv1 DepthAug"),
    DINOv2 = c("DINOv2 MIL", "DINOv2 DepthAug"),
    DINOv3 = c("DINOv3 MIL", "DINOv3 DepthAug"),
    Swin = c("Swin MIL", "Swin DepthAug")
  )
  save_png(file.path(fig_dir, "fig16_depth_aug_delta_submission.png"), 2400, 1000)
  par(mfrow = c(1, 2), mar = c(5.0, 5.0, 3.5, 1.4), oma = c(0, 0, 2.5, 0),
      cex.axis = 1.02, cex.lab = 1.08, cex.main = 1.18)
  for (dataset in c("FruitsPark", "UrbanStreetTree")) {
    deltas <- sapply(names(labels), function(backbone) {
      pair <- labels[[backbone]]
      vals <- df[df$dataset == dataset & df$label %in% pair, c("label", "macro_f1")]
      vals <- vals$macro_f1[match(pair, vals$label)]
      (vals[2] - vals[1]) * 100
    })
    cols <- ifelse(deltas >= 0, "#0f766e", "#b91c1c")
    title_txt <- ifelse(dataset == "FruitsPark", "FruitsPark (val)", "UrbanStreetTree (test)")
    y_lo <- min(-5, min(deltas, na.rm = TRUE) - 2.5)
    y_hi <- max(7, max(deltas, na.rm = TRUE) + 2.5)
    bp <- barplot(deltas, ylim = c(y_lo, y_hi), col = cols, border = "white",
                  main = title_txt, ylab = "DepthAug - MIL Macro-F1 (pp)",
                  las = 1, cex.names = 1.02)
    abline(h = 0, lwd = 2.4, col = "#111827")
    par(xpd = TRUE)
    lbl_y <- ifelse(deltas >= 0, deltas + 0.4, deltas - 0.4)
    text(bp, lbl_y, sprintf("%+.1f", deltas), cex = 1.00,
         pos = ifelse(deltas >= 0, 3, 1))
    par(xpd = FALSE)
  }
  mtext("Depth-guided augmentation effect by backbone", outer = TRUE, cex = 1.22, font = 2)
  dev.off()
}

make_sampling_seed_comparison <- function() {
  summ <- read.csv(file.path(data_root, "TBSStory4KindSamplingSeed", "summary_by_method.csv"))
  method_order <- c(
    "full_train_full_eval",
    "full_train_sparse_eval",
    "random_sparse_sparse_eval",
    "tbs_sparse_sparse_eval",
    "tbs_sparse_depth_aug_sparse_eval"
  )
  label_map <- c(
    "full_train_full_eval" = "Full/\nfull",
    "full_train_sparse_eval" = "Full/\nsparse",
    "random_sparse_sparse_eval" = "Random",
    "tbs_sparse_sparse_eval" = "TBS",
    "tbs_sparse_depth_aug_sparse_eval" = "TBS+\nDepthAug"
  )
  cols <- c("#5b7fa8", "#7dbdb6", "#f28e2b", "#62a65b", "#e15f62")
  panels <- list(
    list(dataset = "FruitsPark", metric = "final_acc_mean", sd = "final_acc_std",
         title = "FruitsPark: Accuracy (val)", ylab = "Accuracy (%)"),
    list(dataset = "FruitsPark", metric = "final_macro_f1_mean", sd = "final_macro_f1_std",
         title = "FruitsPark: Macro-F1 (val)", ylab = "Macro-F1 (%)"),
    list(dataset = "UrbanStreetTree", metric = "final_acc_mean", sd = "final_acc_std",
         title = "UrbanStreetTree: Accuracy (test)", ylab = "Accuracy (%)"),
    list(dataset = "UrbanStreetTree", metric = "final_macro_f1_mean", sd = "final_macro_f1_std",
         title = "UrbanStreetTree: Macro-F1 (test)", ylab = "Macro-F1 (%)")
  )

  save_png(file.path(fig_dir, "fig24_sampling_seed_comparison.png"), 3200, 1800)
  par(mfrow = c(2, 2), mar = c(4.4, 4.7, 2.6, 0.9), oma = c(0.1, 0, 1.7, 0),
      cex.axis = 1.47, cex.lab = 1.49, cex.main = 1.55)
  for (panel in panels) {
    d <- summ[summ$dataset == panel$dataset, ]
    d <- d[match(method_order, d$method), ]
    vals <- d[[panel$metric]] * 100
    errs <- d[[panel$sd]] * 100
    bp <- barplot(vals, ylim = c(0, 100), yaxs = "i", col = cols, border = "white",
                  names.arg = rep("", length(vals)), las = 1,
                  main = panel$title, ylab = panel$ylab)
    text(bp, -3.0, label_map[method_order], cex = 1.44,
         adj = c(0.5, 1), xpd = NA)
    arrows(bp, pmax(vals - errs, 0), bp, pmin(vals + errs, 100), angle = 90,
           code = 3, length = 0.05, lwd = 1.35, col = "#111827")
    text(bp, pmin(vals + errs + 3.8, 98.5), sprintf("%.1f", vals), cex = 1.33)
  }
  mtext("Replicated sparse-selection comparison by dataset", outer = TRUE, line = 0.4,
        cex = 1.71, font = 2)
  dev.off()
}

make_condition_ablation <- function() {
  cond <- data.frame(
    dataset = rep(c("FruitsPark", "UrbanStreetTree"), each = 5),
    condition = rep(c(
      "Full Train / Full Eval",
      "Full Train / Sparse Eval",
      "Random Sparse / Sparse Eval",
      "TBS Sparse / Sparse Eval",
      "TBS Sparse + DepthAug / Sparse Eval"
    ), 2),
    accuracy = c(0.886, 0.789, 0.763, 0.782, 0.850,
                 0.942, 0.904, 0.883, 0.897, 0.913),
    sd = c(0.052, 0.080, 0.020, 0.018, 0.030,
           0.009, 0.028, 0.045, 0.046, 0.021)
  )
  label_map <- c(
    "Full Train / Full Eval" = "Full Train /\nFull Eval",
    "Full Train / Sparse Eval" = "Full Train /\nSparse Eval",
    "Random Sparse / Sparse Eval" = "Random Sparse /\nSparse Eval",
    "TBS Sparse / Sparse Eval" = "TBS Sparse /\nSparse Eval",
    "TBS Sparse + DepthAug / Sparse Eval" = "TBS Sparse + DepthAug /\nSparse Eval"
  )
  cols <- c("#283f60", "#1f766d", "#747b86", "#a85c1d", "#c9791f")
  save_png(file.path(fig_dir, "fig18_condition_ablation.png"), 2600, 1050)
  par(mfrow = c(1, 2), mar = c(7.2, 4.4, 3.2, 1.0), oma = c(0, 0, 2, 0))
  for (dataset in c("FruitsPark", "UrbanStreetTree")) {
    d <- cond[cond$dataset == dataset, ]
    vals <- d$accuracy
    errs <- d$sd
    title_txt <- ifelse(dataset == "FruitsPark", "FruitsPark: Final eval Accuracy", "UrbanStreetTree: Test Accuracy")
    bp <- barplot(vals, ylim = c(0, 1), yaxs = "i", col = cols, border = "white",
                  names.arg = label_map[d$condition], las = 2, cex.names = 0.68,
                  main = title_txt, ylab = "Accuracy")
    arrows(bp, pmax(vals - errs, 0), bp, pmin(vals + errs, 1), angle = 90, code = 3, length = 0.05, lwd = 1.2, col = "#111827")
    text(bp, pmin(vals + errs + 0.035, 0.98), sprintf("%.3f", vals), cex = 0.72)
  }
  mtext("Condition Ranking by Dataset", outer = TRUE, cex = 1.1, font = 2)
  dev.off()
}

make_foreground_diagnostics <- function() {
  fg_path <- file.path(data_root, "Sparse_experiments", "mil_diagnostics", "foreground_diagnostics", "foreground_diagnostics_by_ratio.csv")
  if (!file.exists(fg_path)) {
    return(invisible(NULL))
  }
  fg <- read.csv(fg_path)
  fg <- fg[fg$dataset == "UrbanStreetTree", ]
  fg <- fg[order(fg$bag_ratio), ]
  metrics <- list(
    list(title = "Foreground coverage", ylab = "Covered foreground (%)", value = fg$foreground_coverage_mean * 100),
    list(title = "Foreground IoU", ylab = "Patch/foreground IoU (%)", value = fg$foreground_iou_mean * 100)
  )
  save_png(file.path(fig_dir, "fig19_foreground_diagnostics_by_ratio.png"), 2200, 850)
  par(mfrow = c(1, 2), mar = c(4.8, 5.0, 3.1, 1.2), oma = c(0, 0, 2, 0))
  for (metric in metrics) {
    plot(fg$bag_ratio, metric$value, type = "b", pch = 16, col = "#c94f52", lwd = 2,
         xlim = c(0, 1), ylim = c(0, 100), xaxs = "i", yaxs = "i",
         xlab = "Bag ratio", ylab = metric$ylab, main = paste("UrbanStreetTree:", metric$title),
         cex.axis = 0.95, cex.lab = 1.05, cex.main = 1.1)
    grid(col = "#e5e7eb")
    axis(1, at = seq(0, 1, 0.2))
  }
  mtext("Foreground diagnostics from segmentation masks", outer = TRUE, cex = 1.1, font = 2)
  dev.off()
}

make_pareto <- function() {
  ratio <- read.csv(file.path(data_root, "Pareto_analysis", "Pareto_curve", "data", "run_level_metrics.csv"))
  ratio <- ratio[ratio$seed == 42, ]
  ratio$acc_mean <- ratio$final_eval_acc * 100
  ratio$f1_mean <- ratio$final_eval_macro_f1 * 100
  ratio <- ratio[ratio$method %in% c("Proposed (TBS)", "Random"), ]
  ratio <- do.call(rbind, lapply(split(ratio, interaction(ratio$dataset, ratio$method, drop = TRUE)), function(d) {
    full <- d$acc_mean[d$bag_ratio == 1.0][1]
    d$delta_acc <- d$acc_mean - full
    d$rel_acc <- d$acc_mean / full * 100
    d
  }))
  rec <- do.call(rbind, lapply(split(ratio[ratio$method == "Proposed (TBS)", ], ratio$dataset[ratio$method == "Proposed (TBS)"]), function(d) {
    best <- d[which.max(d$acc_mean), ]
    full <- d[d$bag_ratio == 1.0, ][1, ]
    eff <- d[d$acc_mean >= best$acc_mean - 1, ]
    eff <- eff[which.min(eff$bag_ratio), ]
    rbind(
      data.frame(dataset = full$dataset, choice = "full", ratio = full$bag_ratio, delta_acc = full$delta_acc, rel_acc = full$rel_acc),
      data.frame(dataset = best$dataset, choice = "best_acc", ratio = best$bag_ratio, delta_acc = best$delta_acc, rel_acc = best$rel_acc),
      data.frame(dataset = eff$dataset, choice = "efficient_1pp", ratio = eff$bag_ratio, delta_acc = eff$delta_acc, rel_acc = eff$rel_acc)
    )
  }))
  save_png(file.path(fig_dir, "fig17_pareto_frontier_submission.png"), 2400, 1000)
  par(mfrow = c(1, 2), mar = c(5.0, 5.0, 3.2, 1.0), oma = c(0.4, 0, 2.4, 0),
      cex.axis = 1.00, cex.lab = 1.08, cex.main = 1.18, las = 1)
  cols <- c("Proposed (TBS)" = "#0f766e", "Random" = "#d96532")
  pchs <- c("Proposed (TBS)" = 16, "Random" = 15)
  ltys <- c("Proposed (TBS)" = 1, "Random" = 2)
  for (dataset in c("FruitsPark", "UrbanStreetTree")) {
    d <- ratio[ratio$dataset == dataset, ]
    d <- d[order(d$bag_ratio), ]
    title_txt <- ifelse(dataset == "FruitsPark", "FruitsPark (val)", "UrbanStreetTree (test)")
    y_lim <- range(d$rel_acc, na.rm = TRUE)
    y_pad <- max(1.5, diff(y_lim) * 0.18)
    plot(NA, xlim = c(0.08, 1.02), ylim = c(y_lim[1] - y_pad, y_lim[2] + y_pad),
         xaxs = "i", yaxs = "i", xaxt = "n",
         xlab = "Bag ratio",
         ylab = "Accuracy relative to full patch (%)", main = title_txt)
    shown_rates <- seq(0.1, 1.0, by = 0.1)
    axis(1, at = shown_rates, labels = sprintf("%.1f", shown_rates), cex.axis = 0.92)
    abline(h = 100, lwd = 2.3, col = "#111827")
    for (method in c("Proposed (TBS)", "Random")) {
      dm <- d[d$method == method, ]
      lines(dm$bag_ratio, dm$rel_acc, type = "b", pch = pchs[[method]],
            col = cols[[method]], lwd = 2.4, lty = ltys[[method]])
    }
    rd <- rec[rec$dataset == dataset, ]
    eff <- rd[rd$choice == "efficient_1pp", ]
    points(eff$ratio, eff$rel_acc, pch = 21, cex = 2.1, lwd = 2.2, bg = "white")
    text(eff$ratio, eff$rel_acc, labels = sprintf("%.1f%%", eff$rel_acc),
         cex = 0.82, pos = 3, offset = 0.8)
    legend("bottomright", bty = "n", cex = 0.92,
           legend = c("Proposed (TBS)", "Random", "Efficient point"),
           col = c(cols[["Proposed (TBS)"]], cols[["Random"]], "#111827"),
           lty = c(1, 2, NA), lwd = c(2.4, 2.4, NA), pch = c(16, 15, 21),
           pt.bg = c(NA, NA, "white"))
  }
  mtext("Patch-budget Pareto frontier", outer = TRUE, cex = 1.22, font = 2)
  dev.off()
}

make_learning_efficiency_local <- function() {
  lc <- read.csv(file.path(data_root, "learning_efficiency", "data", "learning_curve_summary.csv"))
  lc <- lc[lc$method == "TBS sparse" & lc$bag_ratio %in% c(0.3, 1.0), ]
  lc$best_pct <- lc$best_val_acc_so_far_mean * 100
  lc$sd_pct   <- lc$best_val_acc_so_far_std * 100

  cols  <- list("0.3" = "#2563eb", "1.0" = "#374151")
  ltys  <- list("0.3" = 1,         "1.0" = 2)
  pchs  <- list("0.3" = 16,        "1.0" = 17)
  ratios <- c(1.0, 0.3)

  save_png(file.path(fig_dir, "fig21_learning_efficiency_main.png"), 2400, 1000)
  par(mfrow = c(1, 2), mar = c(5.2, 4.6, 3.5, 1.5), oma = c(0, 0, 2.5, 0))

  for (dataset in c("FruitsPark", "UrbanStreetTree")) {
    d <- lc[lc$dataset == dataset, ]
    x_max <- max(d$cumulative_time_min_mean, na.rm = TRUE) * 1.07
    title_txt <- ifelse(dataset == "FruitsPark", "FruitsPark (val)", "UrbanStreetTree (test)")
    plot(NA, xlim = c(0, x_max), ylim = c(50, 103), xaxs = "i", yaxs = "i",
         xlab = "Cumulative training time (min)", ylab = "Best val. accuracy so far (%)",
         main = title_txt, cex.lab = 1.0)
    grid(col = "#e5e7eb")
    abline(h = 95, lty = 3, col = "#9ca3af", lwd = 1.2)
    text(x_max * 0.02, 96.2, "95%", cex = 0.72, col = "#9ca3af", adj = 0)
    for (ratio in ratios) {
      rk  <- sprintf("%.1f", ratio)
      dr  <- d[d$bag_ratio == ratio, ]
      dr  <- dr[order(dr$cumulative_time_min_mean), ]
      col <- cols[[rk]]
      lty <- ltys[[rk]]
      pch <- pchs[[rk]]
      lines(dr$cumulative_time_min_mean, dr$best_pct, col = col, lwd = 2, lty = lty)
      idx <- seq(1, nrow(dr), by = 5)
      points(dr$cumulative_time_min_mean[idx], dr$best_pct[idx], pch = pch, cex = 0.7, col = col)
      last <- dr[nrow(dr), ]
      end_lbl <- sprintf("ratio=%.1f\n(30 epochs, %.0f min)", ratio, last$cumulative_time_min_mean)
      text(last$cumulative_time_min_mean, last$best_pct + ifelse(ratio == 0.3, 2.5, -2.5),
           end_lbl, cex = 0.65, col = col, pos = 2)
    }
    legend("bottomright", bty = "n", cex = 0.82,
           legend = c("ratio = 0.3 (sparse)", "ratio = 1.0 (full)"),
           col = c(cols[["0.3"]], cols[["1.0"]]),
           lty = c(ltys[["0.3"]], ltys[["1.0"]]), lwd = 2,
           pch = c(pchs[["0.3"]], pchs[["1.0"]]))
  }
  mtext("Learning efficiency: TBS sparse MIL (DINOv2 backbone)", outer = TRUE, cex = 1.1, font = 2)
  dev.off()
}

make_attention_localization <- function() {
  al_dir <- file.path(data_root, "AttentionLocalization", "UrbanStreetTree", "sampling_multiseed", "combined")
  per_seed <- read.csv(file.path(al_dir, "per_image_attention_localization.csv"))
  conditions <- c("Random sparse", "TBS sparse", "TBS sparse + DepthAug")
  labels <- c("Random\nsparse", "TBS\nsparse", "TBS sparse\n+ DepthAug")
  cols <- c("#6b7280", "#2563eb", "#d97706")
  metrics <- c("U_tree", "A_tree", "Delta_tree", "Lift_tree")
  per_img <- aggregate(per_seed[metrics], per_seed[c("condition", "image_id")], mean)
  summ <- do.call(rbind, lapply(conditions, function(cnd) {
    x <- per_img[per_img$condition == cnd, ]
    data.frame(
      Condition = cnd,
      U_tree_mean = mean(x$U_tree),
      U_tree_std = sd(x$U_tree),
      A_tree_mean = mean(x$A_tree),
      A_tree_std = sd(x$A_tree),
      Delta_tree_mean = mean(x$Delta_tree),
      Delta_tree_std = sd(x$Delta_tree)
    )
  }))

  save_png(file.path(fig_dir, "fig25_attention_localization_summary.png"), 2400, 1100)
  par(mfrow = c(1, 4), mar = c(5.5, 4.8, 3.2, 1), oma = c(0, 0, 2, 0),
      cex.axis = 1.20, cex.lab = 1.25, cex.main = 1.35)

  bp <- barplot(summ$U_tree_mean, ylim = c(0, 0.22), yaxs = "i", col = cols, border = "white",
                names.arg = labels, las = 1, cex.names = 1.05, main = "Uniform tree mass", ylab = expression(U[tree]))
  arrows(bp, summ$U_tree_mean, bp, summ$U_tree_mean + summ$U_tree_std, angle = 90, length = 0.05, lwd = 1.3)

  bp <- barplot(summ$A_tree_mean, ylim = c(0, 0.30), yaxs = "i", col = cols, border = "white",
                names.arg = labels, las = 1, cex.names = 1.05, main = "Attention tree mass", ylab = expression(A[tree]))
  arrows(bp, summ$A_tree_mean, bp, summ$A_tree_mean + summ$A_tree_std, angle = 90, length = 0.05, lwd = 1.3)

  bp <- barplot(summ$Delta_tree_mean, ylim = c(0, 0.12), yaxs = "i", col = cols, border = "white",
                names.arg = labels, las = 1, cex.names = 1.05, main = expression(paste("Attention-uniform gap, ", Delta[tree])), ylab = expression(Delta[tree]))
  arrows(bp, summ$Delta_tree_mean, bp, summ$Delta_tree_mean + summ$Delta_tree_std, angle = 90, length = 0.05, lwd = 1.3)

  lift_list <- lapply(conditions, function(cnd) per_img$Lift_tree[per_img$condition == cnd])
  names(lift_list) <- labels
  boxplot(lift_list, col = cols, border = "#374151", las = 1, cex.axis = 1.05,
          xaxt = "n", main = expression(paste("Relative attention lift, ", L[tree])),
          ylab = expression(L[tree]))
  axis(1, at = seq_along(labels), labels = labels, tick = FALSE,
       line = 0.7, cex.axis = 1.05)
  abline(h = 1, lty = 2, col = "#111827")

  mtext("Attention localization on tree-mask regions (UrbanStreetTree, n = 143 images)", outer = TRUE, cex = 1.30, font = 2)
  dev.off()
}

make_framework()
make_overall()
make_depth_delta()
make_sampling_seed_comparison()
make_condition_ablation()
make_foreground_diagnostics()
make_pareto()
make_attention_localization()
