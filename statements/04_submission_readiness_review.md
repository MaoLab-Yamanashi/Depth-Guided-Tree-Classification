# Submission Readiness Review

## Verdict

現時点の `IEEE_ACCESS/access.tex` は、論文としての骨格、主張、主要結果は成立している。追加された TBS/random/TBS+DepthAug の比較により、前回最大の弱点だった「random sparse に対する直接比較不足」はかなり改善された。

判定:

- Internal draft / pre-submission draft: yes
- International journal submission-ready: close, but still needs final polish / optional timing

理由は、実験結果の弱さではなく、まだ最終投稿前に詰めるべき防御線が残るためである。`deep-research-report.md` が指摘する sparse/efficient MIL 文献との接続と、旧ストーリー由来の図の混入は本文更新で改善済み。TBS の直接比較も追加データで改善された。残る主な弱点は、wall-clock latency と FruitsPark の independent test split 不足である。

## What Is Already Strong

1. 主張の軸はよい。
   - "mid-range tree classification as background-dominant weakly supervised patch aggregation" は明確で、旧稿より強い。
   - Depth-guided Attention を主役から外し、TBS Sparse MIL + DepthAug + Pareto efficiency に絞った判断は妥当。

2. UrbanStreetTree の結果は説得力がある。
   - ViT DepthAug: 95.10% Accuracy / 94.27 Macro-F1.
   - ViT GAP から +10.49pp Accuracy / +12.50pp Macro-F1.
   - 外部公開 dataset の test split なので主結果として使いやすい。

3. Pareto 実験は論文の核になり得る。
   - UrbanStreetTree で ratio 0.4 が best から 0.35pp 以内、平均 instances は 367.2 から 163.3。
   - 単なる高精度論文ではなく、効率的 patch selection 論文として主張できる。

4. FruitsPark の扱いは現在のように慎重でよい。
   - validation-only であることを明記し、DINOv3 GAP が強いことを隠していない。
   - ここを過剰主張しない判断は正しい。

5. TBS/random/TBS+DepthAug の比較が追加された。
   - 固定 sparse 条件では TBS+DepthAug が Random Sparse と TBS Sparse を上回る。
   - ratio sweep では random sparse も強いが、proposed は両 dataset で最高精度点を更新する。
   - これにより「patch-count reduction だけではないのか」という査読コメントに答えやすくなった。

## Blocking Issues Before Submission

### 1. Related Work Is Still Too Thin for Sparse MIL

現在の本文は ABMIL / TransMIL 程度までしか入っていない。`deep-research-report.md` の指摘通り、主張は「Sparse patch selection in MIL」なので、病理 WSI の sparse/efficient MIL 文献を入れないと、査読者から「既存の efficient MIL と何が違うのか」と問われる。

必須で入れるべき文献群:

- CLAM
- DSMIL
- PAMIL
- MHIM-MIL
- ACMIL
- Key Patches Are All You Need
- HDMIL

必要なら追加:

- SETMIL
- DynamicViT / EViT / ToMe / TokenLearner は補助動機としてだけ使う。

重要なのは、これらを「病理だから関係ない」と切るのではなく、「高解像度画像を bag of patches として扱う weakly supervised sparse aggregation の最も成熟した先行研究」として位置づけること。

### 2. TBS の直接証拠は改善されたが、主張は慎重にする

追加結果により、以下が言える。

- fixed-budget condition ablation:
  - FruitsPark: Random Sparse 76.3%, TBS Sparse 78.2%, TBS Sparse + DepthAug 85.0%.
  - UrbanStreetTree: Random Sparse 88.3%, TBS Sparse 89.7%, TBS Sparse + DepthAug 91.3%.
- ratio-wise comparison:
  - FruitsPark: Random is very competitive and reaches 96.07% at ratio 0.6; proposed reaches higher best accuracy, 96.79%, at ratio 1.0.
  - UrbanStreetTree: Proposed reaches 96.33% best accuracy and 95.98% at ratio 0.4; Random best is 95.80% at ratio 0.3.

したがって、TBS は「常に random を支配する」とは言わない。正しい主張は、「random sparse は強い baseline だが、固定 sparse 条件では TBS+DepthAug が改善し、ratio sweep では proposed が最高精度点と実用的 Pareto 点を形成する」である。

### 3. Efficiency Claim Needs Either Timing or Careful Wording

現在の本文は "instances are a proxy for encoder workload" と慎重に書けているので、これは悪くない。ただし abstract の "computationally practical" は、査読者によっては latency を求める。

投稿前に追加できるなら:

- inference time per image
- preprocessing / patch scoring / encoder / MIL aggregation の分解
- GPU, batch size, warmup, measured iterations

追加できないなら:

- "computationally practical" を "patch-efficient" または "instance-efficient" に寄せる。
- latency claim は Discussion に限定する。

### 4. Figures Are Mostly Repaired

旧方針の `Depth-guided Attention` を含む framework 図は本文から外し、新しい `fig04_framework_current.png` に置き換えた。日本語ラベルの全モデルランキング図も本文から外し、代表比較図へ置き換えた。

現在の本文図:

- `fig04_framework_current.png`
- `fig15_overall_comparison_selected.png`
- `fig16_depth_aug_delta_submission.png`
- `fig17_pareto_frontier_submission.png`
- `fig18_condition_ablation.png`
- `fig19_random_vs_proposed_efficiency.png`

これで主張と図の整合性はかなり改善された。

#### Use cautiously

- `fig09_vit_mil_attention.png`
- `fig10_vit_mil_depth_aug_attention.png`

注意図は旧実験由来の可能性がある。現在の最終設定、seed、ratio、model と対応していないなら、投稿本文の主要証拠にしない方がよい。使うなら "qualitative diagnostic" に限定し、attention is not causal explanation という caveat を入れる。

## Recommended Figure Set

投稿用には以下の 5 枚に絞るのがよい。

1. Problem samples
   - FruitsPark / UrbanStreetTree の中距離画像。
   - 背景が大きく、幹・枝が小さいことを示す。

2. Method pipeline
   - RGB image -> candidate patches -> Sobel/TBS selection -> ViT features -> ABMIL -> prediction.
   - Training-only DepthAug を side branch として示す。
   - Depth-guided Attention は出さない。

3. Overall comparison
   - UrbanStreetTree を主、FruitsPark を副として、GAP / MIL / DepthAug の代表モデルを比較。
   - 全 23 モデルランキングではなく、主張に必要な代表だけにする。

4. Pareto frontier
   - x: average instances
   - y: accuracy or macro-F1
   - best point and efficient point を明示。
   - FruitsPark と UrbanStreetTree を side-by-side。

5. Patch/attention diagnostic
   - TBS selected patches + ABMIL attention overlay.
   - random sparse と TBS の違いが見えるなら最もよい。

## What Should Not Be Changed

以下は現時点で変えない方がよい。

- 論文の主線を TBS Sparse MIL + DepthAug + Pareto efficiency に置くこと。
- Depth-guided Attention を主役に戻さないこと。
- FruitsPark を validation-only として慎重に扱うこと。
- patch instances を efficiency proxy として扱い、latency を過剰主張しないこと。
- UrbanStreetTree を主たる外部 benchmark として据えること。

## Minimum Work to Reach Submission-Ready

最低限、以下を行えば「投稿可能な初稿」に近づく。

1. wall-clock latency を測定できるなら追加する。
2. `fig18_condition_ablation.png` の元 CSV があるなら、再描画して投稿用の統一スタイルにする。
3. random sparse comparison の統計検定または paired delta の補足を追加する。
4. FruitsPark については validation-only の制約を最後まで隠さない。
5. bibliography の一部 arXiv / 2025 文献は投稿前に出版情報を再確認する。

## Final Judgment

現在の原稿は、研究の方向性としては十分に国際ジャーナル級になり得る。追加比較により、前回より投稿可能性は上がった。ただし、このまま出すと、査読で主に以下を突かれる可能性がある。

- sparse MIL の最近の先行研究を十分に扱っていない。
- 効率性が latency ではなく instance count に留まっている。
- FruitsPark の外部妥当性が弱い。
- random sparse が強い比率もあるため、TBS の優位性を過剰に書くと危険。

したがって、今の適切な判断は「投稿可能稿にかなり近づいたが、latency と図の最終整形を入れるとさらに強くなる」である。
