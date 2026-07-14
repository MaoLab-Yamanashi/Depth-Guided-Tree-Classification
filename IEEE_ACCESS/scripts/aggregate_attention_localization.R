args <- commandArgs(trailingOnly = FALSE)
file_arg <- args[grep("^--file=", args)][1]
this_file <- sub("^--file=", "", file_arg)
root <- normalizePath(file.path(dirname(this_file), ".."), mustWork = TRUE)
data_dir <- file.path(
  root, "..", "new_experiments_result", "AttentionLocalization",
  "UrbanStreetTree", "sampling_multiseed", "combined"
)

input_path <- file.path(data_dir, "per_image_attention_localization.csv")
per_seed <- read.csv(input_path, check.names = FALSE)
conditions <- c("Random sparse", "TBS sparse", "TBS sparse + DepthAug")
metrics <- c("U_tree", "A_tree", "Delta_tree", "Lift_tree")

# Average the four sampling-seed measurements for each test image. Statistical
# inference then uses the 143 distinct images, rather than 572 correlated
# image-seed observations, as the independent units.
per_image <- aggregate(
  per_seed[metrics],
  per_seed[c("condition", "image_id")],
  mean
)
per_image$condition <- factor(per_image$condition, levels = conditions)
per_image <- per_image[order(per_image$condition, per_image$image_id), ]
per_image$condition <- as.character(per_image$condition)

if (!all(table(per_image$condition) == 143)) {
  stop("Expected 143 seed-averaged images for each condition.")
}

summary_rows <- lapply(conditions, function(condition) {
  x <- per_image[per_image$condition == condition, ]
  data.frame(
    Condition = condition,
    U_tree_mean = mean(x$U_tree),
    U_tree_std = sd(x$U_tree),
    A_tree_mean = mean(x$A_tree),
    A_tree_std = sd(x$A_tree),
    Delta_tree_mean = mean(x$Delta_tree),
    Delta_tree_std = sd(x$Delta_tree),
    Lift_tree_median = median(x$Lift_tree),
    Lift_tree_iqr_q1 = unname(quantile(x$Lift_tree, 0.25)),
    Lift_tree_iqr_q3 = unname(quantile(x$Lift_tree, 0.75)),
    Lift_tree_mean = mean(x$Lift_tree),
    Lift_tree_std = sd(x$Lift_tree),
    n_images = nrow(x)
  )
})
summary_df <- do.call(rbind, summary_rows)

pairs <- list(c(1, 2), c(2, 3), c(1, 3))
test_rows <- list()
for (metric in c("Lift_tree", "Delta_tree")) {
  metric_rows <- lapply(pairs, function(pair) {
    a <- conditions[pair[1]]
    b <- conditions[pair[2]]
    x <- per_image[per_image$condition == a, c("image_id", metric)]
    y <- per_image[per_image$condition == b, c("image_id", metric)]
    names(x)[2] <- "x"
    names(y)[2] <- "y"
    matched <- merge(x, y, by = "image_id")
    result <- wilcox.test(
      matched$x, matched$y,
      paired = TRUE, exact = FALSE, correct = FALSE
    )
    data.frame(
      metric = metric,
      comparison = paste(a, "vs", b),
      n = nrow(matched),
      statistic = unname(result$statistic),
      raw_p_value = result$p.value
    )
  })
  metric_df <- do.call(rbind, metric_rows)
  metric_df$holm_p_value <- p.adjust(metric_df$raw_p_value, method = "holm")
  test_rows[[metric]] <- metric_df
}
tests_df <- do.call(rbind, test_rows)

write.csv(
  per_image,
  file.path(data_dir, "per_image_seed_averaged_attention_localization.csv"),
  row.names = FALSE
)
write.csv(
  summary_df,
  file.path(data_dir, "summary_seed_averaged_attention_localization.csv"),
  row.names = FALSE
)
write.csv(
  tests_df,
  file.path(data_dir, "wilcoxon_seed_averaged_results.csv"),
  row.names = FALSE
)

labels <- c("Random\nsparse", "TBS\nsparse", "TBS sparse\n+ DepthAug")
cols <- c("#6b7280", "#2563eb", "#d97706")
png(
  file.path(root, "figures", "fig25_attention_localization_summary.png"),
  width = 2400, height = 1100, res = 220
)
par(mfrow = c(1, 4), mar = c(5.5, 4.4, 3.2, 1), oma = c(0, 0, 2, 0))

bp <- barplot(
  summary_df$U_tree_mean, ylim = c(0, 0.22), yaxs = "i",
  col = cols, border = "white", names.arg = labels, las = 1,
  cex.names = 0.78, main = "Uniform tree mass",
  ylab = expression(U[tree])
)
arrows(
  bp, summary_df$U_tree_mean,
  bp, summary_df$U_tree_mean + summary_df$U_tree_std,
  angle = 90, length = 0.05, lwd = 1.3
)
grid(nx = NA, ny = NULL, col = "#e5e7eb")

bp <- barplot(
  summary_df$A_tree_mean, ylim = c(0, 0.30), yaxs = "i",
  col = cols, border = "white", names.arg = labels, las = 1,
  cex.names = 0.78, main = "Attention tree mass",
  ylab = expression(A[tree])
)
arrows(
  bp, summary_df$A_tree_mean,
  bp, summary_df$A_tree_mean + summary_df$A_tree_std,
  angle = 90, length = 0.05, lwd = 1.3
)
grid(nx = NA, ny = NULL, col = "#e5e7eb")

bp <- barplot(
  summary_df$Delta_tree_mean, ylim = c(0, 0.12), yaxs = "i",
  col = cols, border = "white", names.arg = labels, las = 1,
  cex.names = 0.78,
  main = expression(paste("Attention-uniform gap, ", Delta[tree])),
  ylab = expression(Delta[tree])
)
arrows(
  bp, summary_df$Delta_tree_mean,
  bp, summary_df$Delta_tree_mean + summary_df$Delta_tree_std,
  angle = 90, length = 0.05, lwd = 1.3
)
grid(nx = NA, ny = NULL, col = "#e5e7eb")

lift_list <- lapply(conditions, function(condition) {
  per_image$Lift_tree[per_image$condition == condition]
})
names(lift_list) <- labels
boxplot(
  lift_list, col = cols, border = "#374151", las = 1,
  cex.axis = 0.78,
  main = expression(paste("Relative attention lift, ", L[tree])),
  ylab = expression(L[tree])
)
abline(h = 1, lty = 2, col = "#111827")
grid(nx = NA, ny = NULL, col = "#e5e7eb")

mtext(
  "Attention localization on tree-mask regions (UrbanStreetTree, n = 143 images)",
  outer = TRUE, cex = 1.0, font = 2
)
dev.off()

print(summary_df)
print(tests_df)
