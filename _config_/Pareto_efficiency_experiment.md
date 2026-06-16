了解です。ここまでの議論を踏まえて、**そのまま実行できて、そのまま論文に落とせる「実験計画 完全版」**を整理します。

---

# 実験計画 完全版

（Sparse MIL + DepthAug の Pareto最適化）

---

# 0. 研究目的（明文化）

本実験の目的：

> TBS Sparse + DepthAug において、BagRatioを連続的に変化させたときの
> **精度と計算効率のトレードオフ構造（Pareto frontier）を明らかにする**

---

# 1. 実験対象

## 1.1 Dataset

```text
Main:
- UrbanStreetTree

Secondary:
- FruitsPark
```

---

## 1.2 Backbone

```text
ViT DINOv2（固定）
```

理由：

* 最も安定
* MILとの相性が良い
* 実験のばらつきを減らす

---

## 1.3 手法

```text
TBS Sparse + DepthAug（固定）
```

---

## 1.4 Depthモデル

```text
Depth Anything v2（固定）
```

補足：

* 主実験では固定
* dataset依存性は別実験で補足

---

# 2. ハイパーパラメータ

## 2.1 BagRatio（最重要）

```text
0.1, 0.2, 0.3, 0.4, 0.5,
0.6, 0.7, 0.8, 0.9, 1.0
```

---

## 2.2 解釈

| Ratio   | 意味             |
| ------- | -------------- |
| 0.1〜0.2 | 極端Sparse（崩壊領域） |
| 0.3〜0.4 | 不安定領域          |
| 0.5〜0.7 | 実用領域（knee候補）   |
| 0.8〜0.9 | 高精度領域          |
| 1.0     | Full ABMIL     |

---

# 3. Seed設計

```text
全条件 × 4 seeds
```

---

## 3.1 理由

* variance評価
* reviewer対策
* kneeの信頼性確保

---

## 3.2 optional

```text
0.4〜0.8のみ 5 seeds
```

---

# 4. 評価指標

## 4.1 精度

```text
- Accuracy
- Micro-F1
- Macro-F1（必須）
```

---

## 4.2 効率

```text
- inference latency（ms/image）
- throughput（img/sec）
- instances per bag
- training time / epoch
- GPU memory
```

---

# 5. 推論時間測定

## 5.1 必須（end-to-end）

以下すべて含める：

```text
- patch生成
- TBS scoring
- patch selection
- ViT forward
- MIL aggregation
```

---

## 5.2 分解（推奨）

```text
- patch/scoring
- encoder
- MIL
- total
```

---

# 6. 実験手順

## Step 1

全BagRatioで学習・評価：

```text
ratio ∈ [0.1〜1.0] × 4 seeds
```

---

## Step 2

各seedで以下を記録：

```text
- best_val_acc
- primary_acc
- F1
- inference_time
- instances_per_bag
- training_time
```

---

## Step 3

統計量を計算：

```text
mean ± std
```

---

# 7. 主要図（論文用）

---

## Figure 1（最重要）

### Pareto Frontier

```text
x軸: 推論時間（ms/image, log推奨）
y軸: Accuracy（or Macro-F1）
点: BagRatio
エラーバー: std
```

---

## Figure 2

### Accuracy vs BagRatio

目的：

* 非線形性の可視化
* 崩壊領域の確認

---

## Figure 3

### Time vs BagRatio

目的：

* 計算量との関係

---

## Figure 4（強く推奨）

### Variance vs BagRatio

```text
std(accuracy)
```

目的：

* 不安定領域の定量化

---

# 8. テーブル

## Table 1: Best Pareto Points

例：

| Ratio | Acc   | ΔAcc | Time | Speedup |
| ----- | ----- | ---- | ---- | ------- |
| 1.0   | 0.942 | 0    | 400  | 1.0x    |
| 0.7   | 0.940 | -0.2 | 260  | 1.5x    |
| 0.5   | 0.936 | -0.6 | 200  | 2.0x    |
| 0.3   | 0.913 | -2.9 | 130  | 3.1x    |

---

# 9. 解析（重要）

## 9.1 knee point

例：

```text
ΔAccuracy / ΔTime
```

最大点を特定

---

## 9.2 正規化指標（任意）

```text
Efficiency = Accuracy / Time
```

---

## 9.3 安定性

```text
std vs ratio
```

---



# 11. 最終主張

---

## 主張①

👉 BagRatioと性能は非線形関係

---

## 主張②

👉 極端Sparseは性能崩壊

---

## 主張③（コア）

👉 **最適BagRatio（knee point）が存在**

---

## 主張④

👉 **0.5〜0.7が実用最適**

---

## 主張⑤

👉 DepthAugは中〜高ratioで有効

---

# 12. 期待結果（現実的）

```text
0.1〜0.2 → 崩壊
0.3〜0.4 → 不安定
0.5〜0.6 → 最適
0.7〜0.8 → 高精度
1.0 → Full
```

---

# 13. 実験総量

```text
10 ratios × 4 seeds = 40 runs / dataset
```

2 datasetで：

```text
計 80 runs
```

---

# 最終まとめ

```text
本実験は、
「どのモデルが最強か」ではなく、

👉「どの設定が最も効率よく高精度を出せるか」

を明らかにする
```

---

# 最後に

この設計はかなり強いです。

👉 単なるモデル比較ではなく
👉 **設計空間の構造を解く論文**

になっています。

---

必要なら次は

* 論文の構成（章立て）
* アブストラクト
* Figureの具体プロットコード

まで一気に詰められます。
