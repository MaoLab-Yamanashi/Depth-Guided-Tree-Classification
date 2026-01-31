# Normalized Runs: Result Image Summaries

対象画像
- results_heatmap.png
- results_delta_vs_baseline_heatmap.png
- results_delta_vs_vitmil_heatmap.png

## 1) results_heatmap.png（生指標ヒートマップ）
- FruitsPark と UrbanStreetTree の Accuracy / Macro-F1 を横並びで比較する全体俯瞰図。
- ViT+MIL 系や Depth 系が全体として高水準（90%台）に集まり、Baseline 系は低いものが混在。
- DINO v3 系は一部で空欄（学習未完了）があり、比較対象が欠ける行がある。

## 2) results_delta_vs_baseline_heatmap.png（GAPベースライン差分）
- 各手法を「同じバックボーンのGAPベースライン」からどれだけ伸びたかを可視化。
- Depth 系や MIL 系は多くの行でプラス方向（赤）に寄り、GAPに対して改善が見える。
- DINO v1/v3 では差分が不安定な行があり、未完了の行は空欄。

## 3) results_delta_vs_vitmil_heatmap.png（ViT+MIL差分）
- 各手法を「同バックボーンのViT+MIL」からどれだけ上乗せできたかの差分。
- Depth Aug / Depth-guided / LateFusion / Piecewise の効果が、+側／-側で判別しやすい。
- ±10%で色が飽和するスケールに調整済みのため、小さな差分のグラデーションが見やすい。

注意
- いずれも正規化あり（Normalized runs）の結果。
- DINO v3 の一部は学習中／未完了のため空欄がある。
