# Overall Comparison

## 1. 目的

本実験の目的は、論文の主比較として以下を同一基準で比較することである。

- image-level baseline
- sparse MIL backbone comparison
- sparse Depth Augmentation backbone comparison

`Depth Guided Attention` 系はこの主比較から外す。
必要なら appendix 用の追加比較として別管理する。

---

## 2. 実行場所

比較実験は以下の新構成だけを正式系とする。

- core: `/home/matsumura/vitmil/core`
- experiment definition: `/home/matsumura/vitmil/experiments/overall_compare`
- results: `/home/matsumura/vitmil/runs/OverallComparison`

---

## 3. 最重要方針

この比較では、backbone 凍結方針を以下のように分ける。

- GAP baseline: `model.freeze_backbone = false`
- sparse MIL / DepthAug: `model.freeze_backbone = true`
- staged unfreeze は使わない
- `lr_head / lr_full / unfreeze_epoch` は使わない

この方針は以下の全 run に適用する。

- GAP baseline
- `baseline/resnet18_mil`
- `mil/*`
- `depth_aug/*`

比較の目的は以下である。

- GAP baseline では通常の image-level 学習性能を見る
- sparse MIL / DepthAug では固定特徴に対する pooling / TBS / DepthAug の差を切り分ける

---

## 4. 共通固定条件

全 run で以下を共通にする。

- normalization: `dataset`
- `num_workers = 4`
- `cudnn_deterministic = false`
- `cudnn_benchmark = true`
- `use_amp = true`

---

## 5. GAP baseline の固定条件

GAP baseline は image-level classifier として以下で統一する。

- epochs: `30`
- batch size: `32`
- weight decay: `1e-4`
- backbone: trainable

学習率は以下とする。

- `ResNet18 + GAP`: `5e-4`
- `ViT + GAP`: `1e-4`
- `ViT (DINO v1) + GAP`: `1e-4`
- `ViT (DINO v2) + GAP`: `3e-4`
- `ViT (DINO v3) + GAP`: `1e-4`

`ViT (DINO v2) + GAP` の preset default では frozen backbone が入っているが、
この比較では suite 側で `freeze_backbone = false` を明示して上書きする。

---

## 6. Sparse MIL / Depth Augmentation の固定条件

MIL 系と Depth Augmentation 系は、TBS 0.3 の本線設定で統一する。

- epochs: `30`
- batch size: `1`
- lr: `1e-4`
- weight decay: `1e-4`
- backbone: frozen
- attention: `softmax`
- `lambda_ent = 0.0`
- `lambda_l1 = 5e-4`
- `lambda_l2 = 5e-4`
- `reg_warmup = 0`

sampling は以下で固定する。

- `sampler = sliding`
- `val_sampler = sliding`
- `bag_ratio = 0.3`
- `val_bag_ratio = 0.3`
- `test_bag_ratio = 0.3`
- `slide_stride = 160`
- `score_method = sobel`
- `trunk_bias = 0.5`
- `candidate_multiplier = 4.0`
- `low_score_perturb_prob = 0.0`

---

## 7. 比較対象

### 7.1 GAP baseline

- `baseline/resnet18_gap`
- `baseline/vit_gap`
- `baseline/vit_dinov1_gap`
- `baseline/vit_dinov2_gap`
- `baseline/vit_dinov3_gap`

### 7.2 Sparse MIL

- `baseline/resnet18_mil`
- `mil/vit`
- `mil/vit_dinov1`
- `mil/vit_dinov2`
- `mil/vit_dinov3`
- `mil/swin`

### 7.3 Sparse Depth Augmentation

- `depth_aug/vit`
- `depth_aug/vit_dinov1`
- `depth_aug/vit_dinov2`
- `depth_aug/vit_dinov3`
- `depth_aug/swin`

---

## 8. データセット

### 8.1 通常 RGB dataset

- FruitsPark: `/home/matsumura/datasets/FruitsPark`
- UrbanStreetTree: `/home/matsumura/datasets/UrbanStreetTree/clsdir`

これを使う条件:

- GAP baseline
- sparse MIL

### 8.2 Depth Augmentation dataset

- FruitsPark: `/home/matsumura/datasets/FruitsPark/only_blur/aug_midas_large`
- UrbanStreetTree: `/home/matsumura/datasets/UrbanStreetTree/only_blur/aug_midas_large`

これを使う条件:

- sparse Depth Augmentation

---

## 9. 実行 suite

実行定義は以下に置く。

- FruitsPark: `/home/matsumura/vitmil/experiments/overall_compare/configs/suites/fruitspark.yaml`
- UrbanStreetTree: `/home/matsumura/vitmil/experiments/overall_compare/configs/suites/urbanstreettree.yaml`

実行スクリプトは以下である。

```bash
/home/matsumura/vitmil/experiments/overall_compare/scripts/run_fruitspark.sh
/home/matsumura/vitmil/experiments/overall_compare/scripts/run_urbanstreettree.sh
```

両方まとめて実行する場合:

```bash
/home/matsumura/vitmil/experiments/overall_compare/scripts/run_all.sh
```

---

## 10. 出力単位

各 dataset で 16 run を実行する。

- 5 GAP baselines
- 6 sparse MIL runs
- 5 sparse Depth Augmentation runs

---

## 11. 注意点

`baseline/resnet18_mil` は旧 Table 4 の「full-patch ResNet18 + MIL」を再現するための設定ではない。
この比較では backbone 比較の公平性を優先し、TBS 0.3 + frozen backbone の同一条件で回す。

したがって、これは

- 旧結果の単純再掲

ではなく、

- 新しい paper-facing protocol による統一比較

として扱う。
