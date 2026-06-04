# Current Research Summary

## Core Problem

本研究は、地上側面視点から撮影された中距離の樹木画像を対象とする樹種分類である。近距離の葉・花・樹皮画像と異なり、中距離画像では分類に効く幹・枝・樹皮領域が画像内の一部に偏在し、空、道路、建物、車両、他の樹木などの背景が大きな面積を占める。そのため、通常の image-level classifier は樹木固有の形態ではなく背景相関を利用しやすい。

この課題は以下の 2 点に分解できる。

- Background-dominant bag: 有効な前景パッチが少なく、背景パッチが多数を占める。
- Texture degradation: 撮影距離と画像解像度により、近距離樹皮分類で有効な細粒度テクスチャが失われる。

## Proposed Direction

最新方針では、旧稿の Depth-guided Attention を主役にしない。主線は次である。

1. ViT/SSL backbone で局所パッチ特徴を抽出する。
2. ABMIL で画像を bag として扱い、重要パッチを弱教師ありに集約する。
3. Trunk-biased Sampling (TBS) により、Sobel 勾配で幹・枝・樹皮らしい高周波構造を含む候補パッチを優先する。
4. Depth-guided Augmentation (DepthAug) により、学習時に前景構造を保持しつつ背景を撹乱し、背景ショートカットを抑制する。
5. Bag ratio を sweep し、精度と使用パッチ数の Pareto frontier を評価する。

## Fixed Paper-Facing Setting

Overall comparison の標準条件は以下である。

- GAP baseline: trainable backbone
- Sparse MIL / DepthAug: frozen backbone
- epochs: 30
- MIL batch size: 1
- GAP batch size: 32
- normalization: dataset normalization
- attention: softmax
- regularization: balanced elastic net, lambda_l1 = lambda_l2 = 5e-4
- score method: Sobel
- sampler: sliding
- trunk_bias: 0.5
- candidate_multiplier: 4.0
- slide_stride: 160
- bag_ratio: 0.3 for overall comparison

DepthAug dataset は `only_blur/aug_midas_large` を用いる。Pareto efficiency 実験では DINOv2 backbone + TBS Sparse + DepthAug を固定し、bag_ratio = 0.1--1.0 を 4 seeds で評価する。

## Datasets

- FruitsPark: 10 classes, 790 original images, train/validation split, final evaluation uses validation split.
- UrbanStreetTree: 13 classes in the branch subset used here, 1,485 images, train/validation/test split, final evaluation uses test split.
- Augmented training data:
  - FruitsPark: 2,273 training images after DepthAug.
  - UrbanStreetTree: 4,674 training images after DepthAug.

## Overall Comparison Findings

Source: `/Users/takahiro/latex/new_experiments_result/OverallComparison4Seed/analysis_outputs/model_seed_summary.csv`

FruitsPark validation:

- Best mean Macro-F1 overall: DINOv3 GAP, 0.9760 +/- 0.0104, Accuracy 0.9762 +/- 0.0103.
- Best sparse MIL/DepthAug result: DINOv2 DepthAug, Macro-F1 0.9387 +/- 0.0239, Accuracy 0.9381 +/- 0.0237.
- DINOv2 gains strongly from MIL/DepthAug compared with its GAP baseline, but DINOv3 GAP remains strongest on this smaller validation-only dataset.

UrbanStreetTree test:

- Best mean Macro-F1 overall: ViT DepthAug, 0.9427 +/- 0.0237, Accuracy 0.9510 +/- 0.0181.
- Best DINOv2 DepthAug: Macro-F1 0.9413 +/- 0.0274, Accuracy 0.9493 +/- 0.0231.
- ViT DepthAug improves over ViT GAP by +0.1250 Macro-F1 and +0.1049 Accuracy.
- DepthAug improves sparse MIL across all tested backbones on UrbanStreetTree; paired-seed gains are statistically significant for ViT, Swin, and DINOv3 in the existing analysis.

Interpretation:

- On UrbanStreetTree, sparse MIL plus DepthAug directly solves the intended background-dominant setting and outperforms image-level GAP baselines.
- On FruitsPark, pure GAP with strong DINOv3/Swin can be very strong, likely because the validation set shares collection-domain regularities. The paper should avoid overclaiming universal superiority on FruitsPark and instead present it as a secondary dataset for checking whether sparse methods remain competitive.

## Pareto Efficiency Findings

Source: `/Users/takahiro/latex/new_experiments_result/Sparse_experiments/analysis_report.md`

FruitsPark:

- Best accuracy: bag_ratio 1.0, Accuracy 96.79 +/- 1.57, Macro-F1 96.79, instances 66.0.
- Efficient within 1pp: bag_ratio 0.8, Accuracy 96.07 +/- 2.76, Macro-F1 96.01, instances 53.0.
- Efficient ratio loses only 0.71 percentage points while reducing average instances from 66.0 to 53.0.

UrbanStreetTree:

- Best accuracy: bag_ratio 0.9, Accuracy 96.33 +/- 1.84, Macro-F1 95.83, instances 367.2.
- Efficient within 1pp: bag_ratio 0.4, Accuracy 95.98 +/- 0.88, Macro-F1 95.22, instances 163.3.
- Efficient ratio loses only 0.35 percentage points while reducing average instances from 367.2 to 163.3.

Interpretation:

- The strongest journal-level claim is not only "higher accuracy"; it is "near-peak accuracy can be retained with substantially fewer patches."
- UrbanStreetTree provides the clearest efficiency story: about 44.5% of the patches used by the best-accuracy setting preserve accuracy within 0.35 percentage points.
- FruitsPark requires more patches to stay within 1pp, which suggests dataset-specific foreground/background geometry. This is a useful discussion point, not a weakness.

## Claims to Use

1. Mid-range tree recognition is a background-dominant weakly supervised recognition problem.
2. ABMIL provides a natural mechanism for selecting discriminative local regions without manual trunk annotation.
3. TBS makes MIL computationally practical by reducing the number of patch instances.
4. DepthAug improves robustness by discouraging background shortcuts during training while requiring only RGB at inference.
5. The Pareto experiment demonstrates that patch budget can be reduced with little loss of accuracy, especially in UrbanStreetTree.

## Claims to Avoid or Downgrade

- Do not make Depth-guided Attention the main proposed method.
- Do not claim that MiDaS is the only or final depth model; the current paper-facing dataset uses `aug_midas_large`, while the Pareto plan mentions Depth Anything v2 as a controlled option.
- Do not reuse the old 16-condition table as the main result because it belongs to an older protocol.
- Do not claim universal superiority over all GAP baselines on FruitsPark; DINOv3 GAP is stronger in the current 4-seed summary.
