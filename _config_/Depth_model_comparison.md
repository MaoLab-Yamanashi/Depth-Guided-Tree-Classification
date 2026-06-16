# Depth Model Comparison

## 1. 目的

本実験の目的は、Depth Guided Augmentation で使う depth model の違いが分類性能に与える影響を比較することである。

旧 `/home/matsumura/vitmil/depth_model_exp` は廃止予定のため、本実験では一切参照しない。
実行は必ず以下の新構成で行う。

- core: `/home/matsumura/vitmil/core`
- experiment definition: `/home/matsumura/vitmil/experiments/depth_model_compare`
- results: `/home/matsumura/vitmil/runs/DepthModelComparison`

---

## 2. 固定条件

`_config_` の主実験方針に合わせ、depth model 以外は固定する。

- backbone: `vit_small_patch16_224`
- experiment id: `depth_aug/vit`
- epochs: `30`
- attention: `softmax`
- score method: `sobel`
- normalization: `dataset`
- regularization: balanced elastic net
  - `lambda_l1 = 5e-4`
  - `lambda_l2 = 5e-4`
- `lambda_ent = 0.0`
- `reg_warmup = 0`
- `low_score_perturb_prob = 0.0`

H1 から H6 は完全に廃止する。
本実験では旧 H preset を一切使わない。

---

## 3. TBS 代表設定

sampling は TBS 代表値で統一する。

- `sampler = sliding`
- `val_sampler = sliding`
- `bag_ratio = 0.8`
- `trunk_bias = 0.5`
- `slide_stride = 160`
- `candidate_multiplier = 4.0`

ここでいう `biased rate 0.8` は `bag_ratio = 0.8` として扱う。
`trunk biased 0.5` は `trunk_bias = 0.5` として扱う。

---

## 4. データセット

Depth 比較では、`only_blur` 配下の depth model 別 augmentation dataset を使う。

### FruitsPark

- `/home/matsumura/datasets/FruitsPark/only_blur/aug_midas_hybrid`
- `/home/matsumura/datasets/FruitsPark/only_blur/aug_midas_large`
- `/home/matsumura/datasets/FruitsPark/only_blur/aug_dpt_large`
- `/home/matsumura/datasets/FruitsPark/only_blur/aug_leres`
- `/home/matsumura/datasets/FruitsPark/only_blur/aug_depth_anything_v1`
- `/home/matsumura/datasets/FruitsPark/only_blur/aug_depth_anything_v2`
- `/home/matsumura/datasets/FruitsPark/only_blur/aug_depth_anything_v3`
- `/home/matsumura/datasets/FruitsPark/only_blur/aug_adabins`
- `/home/matsumura/datasets/FruitsPark/only_blur/aug_marigold`
- `/home/matsumura/datasets/FruitsPark/only_blur/aug_zoedepth`

### UrbanStreetTree

- `/home/matsumura/datasets/UrbanStreetTree/only_blur/aug_midas_hybrid`
- `/home/matsumura/datasets/UrbanStreetTree/only_blur/aug_midas_large`
- `/home/matsumura/datasets/UrbanStreetTree/only_blur/aug_dpt_large`
- `/home/matsumura/datasets/UrbanStreetTree/only_blur/aug_leres`
- `/home/matsumura/datasets/UrbanStreetTree/only_blur/aug_depth_anything_v1`
- `/home/matsumura/datasets/UrbanStreetTree/only_blur/aug_depth_anything_v2`
- `/home/matsumura/datasets/UrbanStreetTree/only_blur/aug_depth_anything_v3`
- `/home/matsumura/datasets/UrbanStreetTree/only_blur/aug_adabins`
- `/home/matsumura/datasets/UrbanStreetTree/only_blur/aug_marigold`
- `/home/matsumura/datasets/UrbanStreetTree/only_blur/aug_zoedepth`

`newcrfs` は比較対象に含めない。
理由は以下である。

- `vitmil_core.depth.registry` に `newcrfs` が存在しない
- 現在の `only_blur` dataset に `aug_newcrfs` が存在しない

---

## 5. 実行 suite

実行定義は以下に置く。

- FruitsPark: `/home/matsumura/vitmil/experiments/depth_model_compare/configs/suites/fruitspark.yaml`
- UrbanStreetTree: `/home/matsumura/vitmil/experiments/depth_model_compare/configs/suites/urbanstreettree.yaml`

実行スクリプトは以下である。

```bash
/home/matsumura/vitmil/experiments/depth_model_compare/scripts/run_fruitspark.sh
/home/matsumura/vitmil/experiments/depth_model_compare/scripts/run_urbanstreettree.sh
```

両方まとめて実行する場合:

```bash
/home/matsumura/vitmil/experiments/depth_model_compare/scripts/run_all.sh
```

---

## 6. 出力配置

結果は以下に配置する。

```text
/home/matsumura/vitmil/runs/DepthModelComparison/
  FruitsPark/
    depth_aug/
      midas_hybrid/
      midas_large/
      dpt_large_original/
      leres/
      depth_anything_v1/
      depth_anything_v2/
      depth_anything_v3/
      adabins/
      marigold/
      zoedepth/
  UrbanStreetTree/
    depth_aug/
      midas_hybrid/
      midas_large/
      dpt_large_original/
      leres/
      depth_anything_v1/
      depth_anything_v2/
      depth_anything_v3/
      adabins/
      marigold/
      zoedepth/
```

---

## 7. 現時点の解釈

この Depth 比較は、Depth Guided Attention の depth backend 比較ではない。
今回比較するのは、Depth Guided Augmentation で作成済みの `only_blur/aug_*` dataset 間の差である。

Depth Guided Attention 側の depth backend 比較も必要な場合は、別 suite として切り分ける。
その場合は通常 dataset を使うか、`only_blur/aug_midas_large` を固定入力にするかを別途決める必要がある。
