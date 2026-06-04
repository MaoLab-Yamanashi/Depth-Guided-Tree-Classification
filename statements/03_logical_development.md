# Logical Development for the Paper

## Title Direction

Working title:

`Depth-Regularized Sparse Multiple Instance Learning for Mid-Range Tree Species Classification under Background-Dominant Conditions`

This title emphasizes the actual contribution: sparse MIL, depth regularization through augmentation, mid-range tree classification, and background-dominant conditions.

## Paper Thesis

Mid-range tree images are difficult not because image classifiers are weak in general, but because the visual evidence is distributed sparsely across trunk and branch regions while background occupies most of the frame. A classifier must therefore identify informative local regions without trunk-level annotation and must avoid treating background as a shortcut. The proposed TBS-DepthAug MIL framework addresses this by combining weakly supervised patch aggregation, trunk-biased sparse sampling, and depth-guided training-time background perturbation.

## Section Flow

### 1. Introduction

Start with the practical need: urban forestry, orchard monitoring, landscape management, and smartphone/ground-level imaging. Then state the mismatch: many existing methods assume close-up organs or aerial/remote sensing; practical ground-level images are often mid-range and background-heavy.

The key problem statement:

- In mid-range side-view images, discriminative evidence is sparse.
- Background correlations can dominate learning.
- Close-up bark texture methods do not transfer cleanly because texture degrades with distance.
- Manual trunk annotation is costly.

Contributions:

1. Formulate mid-range tree species classification as background-dominant weakly supervised patch aggregation.
2. Propose TBS-DepthAug MIL: ABMIL with trunk-biased sparse patch sampling and depth-guided training augmentation.
3. Compare image-level GAP, sparse MIL, and sparse DepthAug under a unified 4-seed protocol on FruitsPark and UrbanStreetTree.
4. Quantify the accuracy/patch-budget Pareto frontier and show near-peak performance with reduced patches.

### 2. Related Work

Keep it structured:

- Tree species classification from leaves, bark, street-level images, and remote sensing.
- Background bias and texture/degradation.
- MIL and attention-based weakly supervised aggregation.
- Vision foundation models and depth-guided structural learning.

Avoid a long catalog. Each paragraph should end by narrowing toward the paper gap.

### 3. Method

Use the following hierarchy:

1. Image-to-bag construction.
2. Trunk-biased sampling:
   - sliding candidate patches
   - Sobel score
   - select a fraction according to bag_ratio
   - trunk_bias controls preference for high-score patches
3. Feature extraction:
   - ViT / DINO / Swin backbone
   - frozen backbone for sparse MIL in the main protocol
4. ABMIL aggregation:
   - attention score
   - softmax attention
   - bag representation
   - classifier
   - balanced elastic-net attention regularization
5. Depth-guided augmentation:
   - training only
   - preserve depth-derived foreground
   - perturb background by blur/replacement/degradation
   - no depth required at inference

Depth-guided Attention should not be described as a main method. It can be mentioned only as an excluded prior internal variant if needed, but the current paper should remain focused.

### 4. Experimental Setup

Report:

- Datasets and splits.
- Backbones and comparison groups.
- Overall comparison protocol:
  - GAP baselines trainable
  - sparse MIL/DepthAug frozen
  - TBS 0.3
  - 4 seeds
- Pareto protocol:
  - DINOv2 + TBS + DepthAug
  - bag_ratio 0.1--1.0
  - 4 seeds
- Metrics:
  - Accuracy
  - Macro-F1
  - average instances per bag
  - efficiency ratio / patch budget

Do not overemphasize latency unless verified wall-clock timing exists. The current available evidence is average patch instances, not measured end-to-end milliseconds.

### 5. Results

Subsection plan:

1. Overall comparison across backbones.
   - UrbanStreetTree: DepthAug gives best result, ViT DepthAug 95.10% Accuracy / 94.27 Macro-F1.
   - FruitsPark: DINOv3 GAP is best; DINOv2 DepthAug is best sparse method.
2. DepthAug effect.
   - Strong on UrbanStreetTree across backbones.
   - Mixed on FruitsPark; discuss dataset-specific domain regularities.
3. Pareto frontier.
   - UrbanStreetTree: ratio 0.4 within 0.35pp of best while using 163.3 vs 367.2 instances.
   - FruitsPark: ratio 0.8 within 0.71pp while using 53.0 vs 66.0 instances.
4. Qualitative/diagnostic evidence.
   - Existing attention figures can support the background-suppression narrative, but they should be secondary because they come from old visualizations.

### 6. Discussion

Key points:

- Why sparse MIL helps: it avoids collapsing the image into a single global resized representation and lets the model weight local evidence.
- Why DepthAug helps more on UrbanStreetTree: background complexity is high and test split provides a stronger check for background shortcut suppression.
- Why FruitsPark is mixed: validation-only evaluation and park-specific visual regularities make image-level GAP surprisingly strong.
- Why the Pareto result matters: a practical system need not process all candidate patches.
- Limitations:
  - FruitsPark lacks an independent test set.
  - Patch instances are a proxy for compute unless wall-clock latency is measured.
  - Depth maps are pseudo-depth and may fail in cluttered vegetation.
  - Current TBS scoring is hand-designed Sobel; learnable selection is future work.

### 7. Conclusion

Restate the core finding conservatively:

TBS-DepthAug MIL provides an effective and efficient framework for mid-range tree classification under background-dominant conditions. On UrbanStreetTree it improves over image-level baselines and achieves near-peak accuracy with substantially fewer patch instances; on FruitsPark it remains competitive and reveals dataset-dependent patch-budget requirements.

## Main Numerical Claims for Abstract

- UrbanStreetTree: ViT DepthAug reaches 95.10% Accuracy and 94.27 Macro-F1 over four seeds.
- UrbanStreetTree Pareto: bag_ratio 0.4 reaches 95.98% Accuracy, within 0.35pp of the 96.33% best, using 163.3 instead of 367.2 instances.
- FruitsPark Pareto: bag_ratio 0.8 reaches 96.07% Accuracy, within 0.71pp of the 96.79% best, using 53.0 instead of 66.0 instances.

## Writing Stance

The paper should be rigorous and conservative:

- Claim robust gains on UrbanStreetTree.
- Claim efficiency frontier across both datasets.
- Present FruitsPark as a real-world validation dataset with no independent test split.
- Avoid saying the proposed method always beats all strong image-level foundation baselines.
