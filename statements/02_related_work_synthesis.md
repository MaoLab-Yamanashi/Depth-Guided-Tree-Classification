# Related Work Synthesis

## Positioning

本研究は、近距離器官画像や上空リモートセンシングではなく、地上側面視点の中距離画像を扱う。したがって関連研究は、単なる tree species classification の列挙ではなく、次の流れで整理する。

1. 樹種分類の既存設定: 葉・樹皮・都市樹木 dataset。
2. 背景バイアスとテクスチャ/解像度劣化。
3. MIL/ABMIL による弱教師あり局所集約。
4. Vision foundation model / Transformer backbone。
5. Depth-guided learning と training-only structural guidance。
6. 本研究の空白: background-dominant mid-range side-view tree classification.

## Tree Species Classification

近距離の葉画像では LeafSnap や Pl@ntNet などが代表的である。これらは市民利用や植物同定を促進したが、葉・花・果実は季節依存があり、撮影者が対象器官を近距離で撮影する前提が強い。

樹皮分類では BarkNet 1.0 が 23 種・23,000 枚超の高解像度 bark image dataset を示し、single crop 93.88%、tree-level majority voting 97.81% を報告した。CentralBark は 2024 年に 19,000 枚超の大規模樹皮 dataset を提示し、標準化された bark recognition dataset の不足を補う研究である。これらは樹皮が通年利用可能な手がかりであることを示す一方、近距離・樹皮中心画像を前提とするため、中距離で幹が小さく背景が大半を占める設定とは異なる。

UrbanStreetTree は、50 種、41,467 high-resolution classification images、22,872 annotated images、10 city scenes を含む大規模 street-tree dataset であり、branch organ annotation を含む点が本研究と近い。2026 年には StreetTree という大規模 global benchmark も公開され、street-level tree species classification が急速に拡大している。これは本研究の重要性を補強するが、本研究の焦点は大規模収集そのものではなく、限られた mid-range RGB 画像から背景依存を抑え、効率的に前景パッチを選ぶ方法にある。

## Background Bias

Xiao et al. は ImageNet-9 により foreground/background signal を分離し、background-only でも非自明な精度が出ること、背景によって誤分類が誘発されることを示した。PlantVillage bias study では、背景のわずかな画素だけで 49.0% の分類精度が得られ、random guess 2.6% を大きく上回ることが報告された。

この知見は、中距離樹木画像に直接関係する。画像内で背景面積が大きく、データセットが特定の場所や季節に偏る場合、モデルは樹種そのものではなく撮影場所・地面・看板・道路・周辺樹木を shortcut として利用し得る。

## MIL and ABMIL

MIL は bag に画像ラベルだけが付与され、instance-level label がない弱教師あり学習である。Deep MIL は自然画像分類や自動 annotation に MIL を導入し、ABMIL は attention による differentiable pooling と instance importance の可視化を可能にした。

病理 whole-slide image では TransMIL や HAG-MIL のように Transformer/MIL を組み合わせた研究が発展している。しかし、多くの成功例では有効 instance が比較的豊富であり、また task-specific tissue structure が画像全体に繰り返し現れる。一方、本研究の mid-range tree images では、樹種判別に有効な幹・枝パッチが少なく、背景が多数派となる。この "background-dominant bag" 条件が本研究の MIL 的な難しさである。

## Vision Transformers and Self-Supervised Backbones

ViT は画像を patch token として処理し、大域的な self-attention により局所テクスチャと形状配置を同時に扱える。Swin Transformer は階層的な shifted-window attention により vision task で有効性を示した。DINO/DINOv2/DINOv3 はラベルなし大規模データから汎用視覚特徴を学習する self-supervised foundation backbones である。

本研究では、これらの backbone を image-level GAP と sparse MIL の両方で比較する。重要なのは、foundation backbone の単体性能ではなく、TBS/DepthAug と組み合わせたときに background-dominant patch aggregation がどの程度改善するかである。

## Depth-Guided Learning

Depth Anything V2 などの単眼深度推定は、RGB 画像から scene geometry の相対構造を推定できる。DepthG のように、深度を training-time structural signal として使い、推論時には深度を必要としない研究も現れている。

本研究の DepthAug は、深度を追加入力として推論時に要求するのではなく、学習時の背景撹乱と前景保持に使う。これにより、現場運用では RGB のみで推論できる。これは、RGB-D センサや LiDAR を前提とする研究と異なる実用上の利点である。

## Latest Related-Work Notes Verified Online

- Ilse et al., "Attention-based Deep Multiple Instance Learning", ICML/PMLR 2018.
- Oquab et al., "DINOv2: Learning Robust Visual Features without Supervision", arXiv 2023.
- DINOv3, arXiv:2508.10104, published in 2025, extends self-supervised vision foundation models at scale.
- Yang et al., "Urban street tree dataset for image classification and instance segmentation", 2023, reports 41,467 high-resolution classification images across 50 species.
- Depth Anything V2, arXiv:2406.09414 / NeurIPS 2024.
- CentralBark, Algorithms 2024, reports more than 19,000 bark images.
- StreetTree, arXiv:2602.19123, introduces a global street-tree benchmark; useful as evidence that street-level tree species classification is an active and expanding area.

## Novelty Statement

本研究の新規性は、個別要素の初提案ではない。ViT、ABMIL、DepthAug、背景置換、樹皮分類はそれぞれ既存研究がある。新規性は、それらを地上側面視点の中距離樹木画像という background-dominant condition に合わせて統合し、TBS によって patch budget と分類性能の Pareto frontier を実験的に明らかにした点にある。

国際ジャーナル向けには、"we propose a new backbone" ではなく、"we formulate mid-range tree recognition as background-dominant weakly supervised patch aggregation and demonstrate an efficient depth-regularized sparse MIL solution" と書くのが最も強い。
