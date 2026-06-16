# 実験設定メモ

## 更新日: 2026-04-09

## 1. 計算機環境

- GPU: NVIDIA RTX A6000 x2
- GPUメモリ: 49140 MiB x2
- NVIDIA Driver: 575.57.08
- CUDA: 12.9
- CPU: AMD Ryzen Threadripper 7960X 24-Cores
- CPU論理コア数: 48
- メモリ: 62 GiB

---

## 2. 現在の標準学習方針

今後の主実験では、以下を共通標準とする。

- `unfreeze` は完全に使わない
- backbone comparison の本線では
  - GAP baseline: `freeze_backbone = false`
  - sparse MIL / DepthAug: `freeze_backbone = true`
- MIL の前処理順は `画像単位 Aug -> patch 分割 -> patch ごとは resize + normalize のみ`
- 正規化は `ImageNet` ではなく `dataset normalization` を使う
- `attn_type = softmax`
- `score_method = sobel`
- `low_score_perturb_prob = 0.0`
- 正則化は balanced elastic net
  - `lambda_l1 = 5e-4`
  - `lambda_l2 = 5e-4`
- `lambda_ent = 0.0`
- `reg_warmup = 0`

補足:

- `dataset normalization` は各 dataset の `train` split から mean/std を計算して使う
- 初回実行時に cache を作成し、以後は再利用する
- `nonorm` は不安定だったため主実験から除外する

---

## 3. 実装上の反映状況

### 3.1 共通 core

共通実装は以下に集約されている。

- 共有実装: `/home/matsumura/vitmil/core/src/vitmil_core`
- 実験定義: `/home/matsumura/vitmil/experiments`
- 実行結果: `/home/matsumura/vitmil/runs`

現在の core は以下の標準を反映済みである。

- `data.normalization = dataset`
- `attn_type = softmax`
- `score_method = sobel`
- `lambda_l1 = lambda_l2 = 5e-4`
- MIL の online augmentation は画像単位で適用

### 3.2 preset 方針

- `r1` から `r6` は今後使わない
- 実行用 suite は `main_standard.yaml` を使う
- `r1` から `r6` の preset は現行系から削除済みで、主実験では参照しない

---

## 4. データセット方針

### 4.1 通常時のデータセット

通常の Baseline / MIL / Depth-guided / Late Fusion / Piecewise では、従来どおり通常 dataset を使う。

- FruitsPark: `/home/matsumura/datasets/FruitsPark`
- UrbanStreetTree: `/home/matsumura/datasets/UrbanStreetTree/clsdir`

### 4.2 Depth Augmentation 用データセット

Depth Augmentation 系では、従来の `/aug_midas_large` 直下ではなく、`only_blur` 配下の dataset を使う。

- FruitsPark: `/home/matsumura/datasets/FruitsPark/only_blur/aug_midas_large`
- UrbanStreetTree: `/home/matsumura/datasets/UrbanStreetTree/only_blur/aug_midas_large`

注意:

- `only_blur` の root 自体は `train/val/test` 構造ではない
- 実際に学習で使うのは、その中の `aug_midas_large` subtree である
- これは現在の directory layout に合わせた設定である

---

## 5. 現在の比較対象

### 5.1 Baseline

- `baseline/resnet18_gap`
- `baseline/vit_gap`
- `baseline/vit_dinov1_gap`
- `baseline/vit_dinov2_gap`
- `baseline/vit_dinov3_gap`
- `baseline/resnet18_mil`

### 5.2 MIL

- `mil/vit`
- `mil/vit_dinov1`
- `mil/vit_dinov2`
- `mil/vit_dinov3`
- `mil/swin`

### 5.3 Depth Augmentation

- `depth_aug/vit`
- `depth_aug/vit_dinov1`
- `depth_aug/vit_dinov2`
- `depth_aug/vit_dinov3`
- `depth_aug/swin`

### 5.4 Depth-guided Attention

- `depth_guided/vit`
- `depth_guided/vit_dinov1`
- `depth_guided/vit_dinov2`
- `depth_guided/vit_dinov3`

### 5.5 Depth-guided Late Fusion

- `depth_guided_late_fusion/vit`
- `depth_guided_late_fusion/vit_dinov1`
- `depth_guided_late_fusion/vit_dinov2`
- `depth_guided_late_fusion/vit_dinov3`

### 5.6 Depth-guided Piecewise

- `depth_guided_piecewise/vit`
- `depth_guided_piecewise/vit_dinov1`
- `depth_guided_piecewise/vit_dinov2`
- `depth_guided_piecewise/vit_dinov3`

### 5.7 TBS

- `search_grid.yaml`
- `ablation.yaml`

### 5.8 Overall Comparison

- `overall_compare/configs/suites/fruitspark.yaml`
- `overall_compare/configs/suites/urbanstreettree.yaml`

この比較では以下を一括比較する。

- GAP baseline
- sparse MIL
- sparse Depth Augmentation

また、この比較では GAP baseline は unfrozen、sparse MIL / DepthAug は frozen とする。

### 5.9 Pareto Efficiency

- `Pareto_efficiency_experiment.md`

この実験では以下を比較する。

- Random Sparse
- TBS Sparse
- TBS Sparse + DepthAug

`bag_ratio = 0.1 - 0.5` を sweep し、
精度と速度の Pareto front を評価する。

TBS でも主実験の標準は同じである。
ただし `bag_ratio` と `trunk_bias` のみ探索する。

---

## 6. 参照する suite / base config

### 6.1 通常 dataset を使う suite

- `experiments/baseline/configs/suites/*.yaml`
- `experiments/mil/configs/suites/*.yaml`
- `experiments/depth_guided/configs/suites/fruitspark.yaml`
- `experiments/depth_guided/configs/suites/urbanstreettree.yaml`
- `experiments/depth_guided_late_fusion/configs/suites/*.yaml`
- `experiments/depth_guided_piecewise/configs/suites/*.yaml`
- `experiments/tbs/configs/search_grid.yaml`

これらは以下を参照する。

- FruitsPark: `datasets_fruitspark_attention.yaml`
- UrbanStreetTree: `datasets_urbanstreettree_attention.yaml`

### 6.2 blur-only depth aug dataset を使う suite

- `experiments/depth_aug/configs/suites/*.yaml`
- `experiments/depth_guided/configs/suites/*_depth_aug_joint.yaml`
- `experiments/tbs/configs/ablation.yaml` の `*_aug` 条件

これらは以下を参照する。

- FruitsPark: `datasets_fruitspark_depth_aug_only_blur.yaml`
- UrbanStreetTree: `datasets_urbanstreettree_depth_aug_only_blur.yaml`

---

## 7. 実行前チェック結果

2026-04-09 時点での確認結果:

- `experiments` 配下の実行用 suite は `main_standard.yaml` を参照するよう更新済み
- `r1` から `r6` は suite から外れている
- TBS の旧ジョブは停止済み
- 現在 tmux 上で走っている学習はない
- 構文チェックは通過済み
- GPU は空いている

未解決ではないが、実行前に理解しておく点:

- 初回の `dataset normalization` では train split 全体から統計を計算するため、開始直後に待ち時間が出る
- その後は cache を使うため再実行は軽くなる
- `only_blur` は root ではなく `only_blur/aug_midas_large` を使う設定にしている

---

## 8. 結論

**今の状態で、これから全学習を開始してよい。**

理由:

- 主実験の標準条件は code / config / notes に反映済み
- 実行用 suite は新方針に揃っている
- 旧 `unfreeze` 前提のジョブは止めてある
- Depth Augmentation の参照先も `only_blur` 系へ切り替えてある

したがって、以後の学習はこの設定を正式な本線として開始できる。
