# TBS Presence Ablation

## 1. 目的

本実験の目的は、TBS を本線に残すべきかどうかを判定することである。

ここで知りたいのは、以下の 2 点である。

- TBS は、使わない場合よりも本当に精度を上げるか
- TBS は、Depth Guided Augmentation と組み合わせたときに特に有効か

---

## 2. 前提

本実験では、TBS の代表設定は [`TBS_paramater.md`](/home/matsumura/vitmil/_detail/TBS_paramater.md) に基づき、系統的探索によって事前に決めておく。

したがって、本ファイルでは

- TBS の最適化

ではなく、

- TBS の採否判定

だけを扱う。

---

## 3. 固定条件

sampling と augmentation 以外は、以下で固定する。

- dataset: まずは `UrbanStreetTree`
- backbone: `vit_small_patch16_224`
- attention: `softmax`
- regularization: `elastic_net_balanced`
- score method: `sobel`

---

## 4. 比較条件

TBS の必要性を明確にするため、以下の 4 条件を比較する。

1. No TBS / No Aug
2. TBS / No Aug
3. No TBS / Aug
4. TBS / Aug

---

## 5. 各条件の定義

### 5.1 No TBS / No Aug

- TBS を使わない基準条件
- sampler は `random`
- Bag サイズは割合で制御する

### 5.2 TBS / No Aug

- TBS 単独の効果を見る条件
- sampler は `sliding`
- `bag_ratio` と `trunk_bias` は、等間隔グリッド探索と安定性評価によって選ばれた代表設定を使う

### 5.3 No TBS / Aug

- Depth Guided Augmentation 単独の効果を見る条件
- sampler は `random`
- augmentation dataset を使う

### 5.4 TBS / Aug

- TBS と Depth Guided Augmentation の組合せ効果を見る条件
- sampler は `sliding`
- `bag_ratio` と `trunk_bias` は、等間隔グリッド探索と安定性評価によって選ばれた代表設定を使う

---

## 6. この比較で分かること

この 2x2 比較により、以下を分離して確認できる。

- TBS 単独の効果
- Augmentation 単独の効果
- TBS と Augmentation の相互作用

例えば、

- `TBS / No Aug` は弱い
- `TBS / Aug` は強い

という結果になれば、「TBS は単独では不要だが、Aug と相性が良い」と解釈できる。

---

## 7. 評価指標

各条件について、少なくとも以下を比較する。

- `best_val_acc`
- `final_val_acc`
- 終盤 5 epoch 平均の `val_acc`
- 終盤 5 epoch の標準偏差

可能なら複数 seed で再確認し、seed 間の安定性も評価する。

---

## 8. 結論の出し方

本実験では、最終的に以下のいずれかを結論とする。

### 結論候補 1

TBS は単独でも有効であり、本線に残すべきである。

### 結論候補 2

TBS は単独では不要だが、Depth Guided Augmentation と組み合わせる場合のみ有効である。

### 結論候補 3

TBS を使わなくても同等以上の性能が出るため、本線から外してよい。

---

## 9. 実行順序

実行順は以下とする。

1. `TBS_paramater.md` に基づいて TBS 代表設定を決める
2. その設定で 4 条件比較を行う
3. TBS の必要性を判断する
4. 必要なら `FruitsPark` で再確認する
