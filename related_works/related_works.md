## Related Work（関連研究）

本研究は、**地上の側面視点（人の目線）で撮影された中距離（mid-range）の樹木画像**を対象に、Vision Transformer（ViT）と Attention-based Multiple Instance Learning（ABMIL）を統合し、さらに**深度推定に基づく構造誘導（学習時のみ）**によって背景バイアスを抑制しながら樹種分類を行う。以下では、(i) 背景バイアス、(ii) 距離・解像度に起因するテクスチャ劣化、(iii) 樹皮/幹特徴とデータセットの前提、(iv) MIL/Transformer による弱教師あり集約、(v) depth-guided 学習、(vi) UAV/衛星/点群など他モダリティの樹種分類、の観点から既存研究を整理し、本研究の位置づけを明確化する。

### A. Significance of Tree Species Classification and Practical Constraints

都市環境における樹種分類は、景観管理・保全計画・都市の緑資源管理に直結する基盤技術である。従来は専門家による目視同定が中心であり、データ取得や同定には時間・コストがかかる。近年は機械学習/深層学習の適用が進み、現場運用（例：収穫・伐採等の作業オペレーション）での効率化も議論されている [33]。

一方、スマートフォンアプリ（例：LeafSnap、Pl@ntNet、Folia など）による自動同定も普及しているが、多くは葉・花などの**近距離（close-range）撮影**を前提とし、背景が支配的になりやすい中距離〜遠距離（mid-/long-range）の観測は依然として手薄である。スマートフォンを用いた森林関連研究の俯瞰でも、種同定の比重は限定的であることが示唆される [32]。

### B. Background Bias and Robustness in In-the-Wild Images

自然画像分類において、モデルが前景ではなく背景に依存して予測する**背景バイアス**は古くから問題視されている。Xiao らは、前景・背景を分離可能なデータ設定を用いて「背景のみ」でも高い分類精度が得られること、背景の入れ替えによって精度が大きく低下し得ることを示し、背景信号の影響を定量化した [1]。また、CNN がテクスチャに強く依存する性質（テクスチャバイアス）も報告されており、形状情報を強制する訓練（スタイライズ画像）によって頑健性が改善することが示されている [2]。

植物画像においても背景の影響は大きい。PlantVillage 由来の研究では、背景画素のみからでも分類が成立し得ることが報告されている [3]。背景依存を緩和する手段としては、背景置換・背景多様化によるデータ拡張が提案され、背景変化で性能が崩壊する状況に対して一定の改善が示されている [4]。ただし、タスク/ドメインが異なるため、樹種分類への直接適用可能性は慎重に評価する必要がある。

本研究の対象である都市・公園・果樹園などの地上環境では、空・建物・道路・他樹木など**複雑で変動する背景**が同一クラス内で大きく揺らぎ、かつ画像内で背景の占有率が高い。このため、背景バイアス抑制は中距離の樹種分類における中核課題となる。

### C. Distance, Resolution, and Texture Degradation in Mid-Range Settings

撮影距離が伸びると、実効解像度の低下により細粒度分類は一般に困難になる。Singh らは低解像度条件での細分類性能低下を定量化し、追加損失による補強で改善できることを示した [5]。また、遠距離・遮蔽条件で ViT が CNN より頑健であるという報告もあり、距離増加に伴う劣化に対して大域的注意が有利となる可能性が示唆される [6]。

樹種分類において近距離では樹皮テクスチャが強い手掛かりとなる一方、中距離では幹領域が小目標化し、テクスチャが潰れやすく、背景が支配的になりやすい。そのため、局所テクスチャだけでなく、幹・枝の配置など**形態学的/構造的手掛かり**を併用して識別する必要がある。

### D. Features (Bark/Trunk/Leaf) and Dataset Assumptions

樹種分類で用いられる代表的特徴は、葉・花・果実・樹皮（幹）などの形態情報である。葉は観察しやすい一方で季節変動の影響を強く受ける。これに対し樹皮は通年観察可能であり、近距離条件では樹皮テクスチャを用いた高精度分類が報告されている [7–11]。

ただし、多くの樹皮データセットは**近距離（close-range）かつ背景干渉が小さい**条件で収集されており [7, 8]、中距離で幹が小目標となる状況では、距離・解像度差によるテクスチャ表現の劣化と背景バイアスが顕在化する。この点は、低解像度条件で細粒度分類が難化する一般的傾向 [5] とも整合する。

近距離で樹皮テクスチャを用いる樹種分類は、高精度が報告されている。BarkNet 1.0 は近距離樹皮画像を収集して高精度分類を示したが、樹皮領域のクロップを手作業で行うなど運用上の前提が強い [7]。CentralBark は大規模な樹皮データセットを整備し、複数 CNN での性能比較を報告している [8]。さらに、CAM による識別的樹皮特徴の解析 [9]、地域データセット（BarkVN-50）での分類 [10]、公開データセットの整備 [11] など、樹皮テクスチャの有効性は広く支持されている。

葉と樹皮を組み合わせた特徴融合も報告されており、単一特徴の限界を補う試みとして位置づけられる [12]。しかし、これらも基本的には近距離条件であり、背景支配の中距離条件への直接適用は容易ではない。

### E. Weakly Supervised Aggregation with MIL and Transformers

Multiple Instance Learning（MIL）は、インスタンス集合（bag）に対してラベルが付与される弱教師あり学習の枠組みである。自然画像への初期提案として Diverse Density があり [13]、深層学習との統合として Wu らの Deep MIL（DMIL）が自然画像分類・自動アノテーションでの実用性を示した [14]。弱教師物体検出の文脈では WSDDN が MIL 的仮定を用いて検出領域の推定を行う [15]。

注意機構を用いた ABMIL は、ソフトアテンションによりインスタンス寄与を学習可能とし、解釈性も提供する枠組みとして広く参照されている [16]。病理 WSI 領域では、Transformer を用いてインスタンス相関や空間情報を導入する TransMIL が高い性能を示し [17]、階層的注意で多倍率観察を模倣する HAG-MIL も提案されている [18]。自然環境・リモートセンシングでも MIL 応用（地滑り検出） [19] や、ハイパースペクトルにおける統計的 MIL（MI-ACE） [20] が報告されている。

一方、多くの MIL 応用は「bag 内に有効インスタンスが比較的多い」か、またはインスタンスの空間配置が一定程度制御できる条件で議論されることが多い。これに対し、中距離の樹木画像では**有効パッチが少数で背景が大半**を占める “background-dominant bag” となり、注意が背景へ逸れやすい。本研究はこの困難条件に対し、深度に基づく構造誘導を統合することで対応する。

### F. Depth-Guided Learning and Structure-Induced Attention

深度情報はセグメンテーションや RGB-D 認識、復元などで広く利用される。例えば RGB-D 顔認識では、深度特徴を用いて「どこを見るべきか」を誘導する depth-as-attention が提案されている [21]。また、深度を学習時の構造信号として利用し、推論時には深度を必要としない枠組みとして、depth-guided な教師なしセグメンテーションが提案され、特徴空間の幾何を深度で誘導できることが示された [22]。

ただし、既存研究の焦点は主にピクセルレベルのセグメンテーションや近距離 RGB-D にあり、**弱教師あり分類（MIL）における背景バイアス抑制**として深度を統合する枠組みは限定的である。本研究は、深度推定に基づく構造信号を用いて幹・枝などの前景構造へ注意を誘導し、背景依存を抑える点で差別化される。

### G. Tree Species Classification with Other Modalities (UAV/Satellite/Point Clouds) and Reviews

森林・樹木分野の深層学習研究は、衛星/UAV の上空視点や LiDAR 点群など、多様なモダリティで進展している。包括的レビューは、森林研究を複数カテゴリに整理し、既存研究が上空視点や近距離器官計測に偏り得る点、距離・視点・遮蔽などの制約を明示している [23]。

応用例として、UAV/衛星/点群を用いた樹種分類・セグメンテーション、マルチモーダル融合、自己教師あり学習などが報告されている [24–31]。しかし多くは樹冠中心の上空視点であり、側面の中距離画像における「幹・枝中心」かつ背景支配の課題設定は依然として空白が残る。スマートフォンを用いた森林計測のレビューでも、種同定は限定的であることが示唆される [32]。

### H. Positioning of This Study

以上より、既存研究は (i) 近距離の樹皮・葉に依存する設定、または (ii) UAV/衛星/点群など上空視点中心の設定に偏りやすい。さらに (iii) 側面の中距離画像における背景支配条件で、幹・枝など前景構造へ注意を誘導しつつ弱教師ありに分類する枠組みは十分に確立されていない。

そこで本研究は、ViT と ABMIL により「局所パッチ（高解像度情報）」と「大域構造（自己注意）」を同時に扱い、深度推定に基づく構造誘導（学習時のみ）で背景依存を抑制し、幹領域への注意集中を促す。MIL 研究では i.i.d. 仮定の限界や domain shift がオープン課題として議論されており [34]、本研究の “background-dominant bag”・環境変動（背景/距離）の問題設定はこれらと整合する。

## 参考文献（References）

[1] Xiao, et al. "Noise or Signal: The Role of Image Backgrounds in Object Recognition." 2020. `https://gradientscience.org/background/`

[2] Geirhos, et al. "ImageNet-trained CNNs are biased towards texture; increasing shape bias improves accuracy and robustness." arXiv:1811.12231, 2019. `https://arxiv.org/abs/1811.12231`

[3] "Background bias study on PlantVillage (background pixels alone yield high accuracy)." arXiv:2206.04374, 2022. `https://ar5iv.labs.arxiv.org/html/2206.04374`

[4] BackRep: background replacement for robust recognition (waste recognition). 2021. `https://pmc.ncbi.nlm.nih.gov/articles/PMC8404942/`

[5] Singh, et al. "Fine-grained recognition at low resolution." IJCNN, 2021. `https://iab-rubric.org/old1/papers/IJCNN21_FineGrained.pdf`

[6] Rodrigo, et al. "Vision Transformers vs CNNs under distance/occlusion in face recognition." Scientific Reports, 2024. `https://www.nature.com/articles/s41598-024-72254-w`

[7] BarkNet 1.0: bark texture dataset and classification. arXiv:1803.00949, 2018. `https://arxiv.org/abs/1803.00949`

[8] CentralBark: large-scale bark dataset and benchmarks. Algorithms, 2024. `https://www.mdpi.com/1999-4893/17/5/179`

[9] Kim, et al. "Bark key features for identification (CNN + CAM)." Scientific Reports, 2022. `https://www.nature.com/articles/s41598-022-08571-9`

[10] BarkVN-50: Vietnamese bark texture dataset. arXiv:2210.09290, 2022. `https://arxiv.org/abs/2210.09290`

[11] Mendeley bark dataset (22 species). `https://data.mendeley.com/datasets/v8xyr7tnbx/2`

[12] Zhao, et al. "Feature fusion of leaf and bark for tree species recognition." MBE, 2020. `https://www.aimspress.com/article/doi/10.3934/mbe.2020222?viewType=HTML`

[13] Maron, O., and Ratan, A. "Multiple-Instance Learning for Natural Scene Classification." 1998. `https://dl.acm.org/doi/10.5555/645527.657284`

[14] Wu, et al. "Deep Multiple Instance Learning for Image Classification and Auto-Annotation." CVPR, 2015. `https://openaccess.thecvf.com/content_cvpr_2015/papers/Wu_Deep_Multiple_Instance_2015_CVPR_paper.pdf`

[15] Bilen, H., and Vedaldi, A. "Weakly Supervised Deep Detection Networks." CVPR, 2016. `https://openaccess.thecvf.com/content_cvpr_2016/papers/Bilen_Weakly_Supervised_Deep_CVPR_2016_paper.pdf`

[16] Ilse, et al. "Attention-based Deep Multiple Instance Learning." ICML, 2018. `https://proceedings.mlr.press/v80/ilse18a.html`

[17] Shao, et al. "TransMIL: Transformer-based Correlated Multiple Instance Learning for Whole Slide Image Classification." arXiv:2106.00908, 2021. `https://arxiv.org/abs/2106.00908`

[18] Chen, et al. "Diagnose Like a Pathologist (HAG-MIL)." IJCAI, 2023. `https://www.ijcai.org/proceedings/2023/0191.pdf`

[19] Tang, et al. "MILL for Landslide Recognition." 2021. `https://dl.acm.org/doi/10.1145/3442381.3450127`

[20] Zou, et al. "Multiple Instance Adaptive Estimator (MI-ACE) for hyperspectral." 2019.

[21] Uppal, et al. "Depth-as-Attention for Face Representation Learning." `https://www.semanticscholar.org/paper/97e3f23043df307cce6e071bcf1e54c9ba75fbb1`

[22] Sick, et al. "Unsupervised Semantic Segmentation Through Depth-Guided Feature Correlation and Sampling (DepthG)." CVPR, 2024. `https://openaccess.thecvf.com/content/CVPR2024/papers/Sick_Unsupervised_Semantic_Segmentation_Through_Depth-Guided_Feature_Correlation_and_Sampling_CVPR_2024_paper.pdf`

[23] "Status, advancements and prospects of deep learning methods applied in forest studies." International Journal of Applied Earth Observation and Geoinformation, 131 (2024) 103938. DOI: `https://doi.org/10.1016/j.jag.2024.103938`

[24] Ferreira, et al. "CNN + LiDAR fusion for urban street trees." 2024.

[25] Wang, et al. "Dual-Branch Vision Transformer for fine-grained tree recognition." 2024.

[26] Herasimchyk, et al. "PlantCLEF solution with DINOv2 and multi-scale tiling." 2025.

[27] Sun, et al. "Point Cloud Transformer for tree species from UAV LiDAR." 2023.

[28] "Multi-branch DenseNet with multimodal data for multi-label tree species." Scientific Reports, 2025.

[29] TreeSatAI benchmark. 2023. `https://essd.copernicus.org/articles/15/681/2023/`

[30] Gaydon, et al. "PureForest: A Large-Scale Aerial LiDAR and Aerial Imagery Dataset for Forest Understanding." WACV, 2025. `https://openaccess.thecvf.com/content/WACV2025/papers/Gaydon_PureForest_A_Large-Scale_Aerial_Lidar_and_Aerial_Imagery_Dataset_for_WACV_2025_paper.pdf`

[31] "Multi-branch & multi-label classification (MMTSC)." Scientific Reports, 2025. `https://www.nature.com/articles/s41598-025-19827-5`

[32] "Review: smartphone-based forest mensuration (species identification proportion)." 2024. `https://www.mdpi.com/2072-4292/16/19/3570`

[33] "Classification of Tree Species in the Process of Timber-Harvesting Operations Using Machine-Learning Methods." 2023. `https://www.mdpi.com/2411-5134/8/2/57`

[34] Waqas, M., Ahmed, S. U., Tahir, M. A., Wu, J., and Qureshi, R. "Exploring Multiple Instance Learning (MIL): A brief survey." Expert Systems with Applications, 2024. DOI: `https://doi.org/10.1016/j.eswa.2024.123893`

[35] "Comparison of Tree Species Classifications at the Individual Tree Level by Combining ALS Data and RGB Images Using Different Algorithms." Remote Sensing, 2016. `https://www.mdpi.com/2072-4292/8/12/1034`

[36] Fricker, G. A., et al. "A convolutional neural network classifier identifies tree species in mixed-conifer forest from hyperspectral imagery." Remote Sensing, 2019. `https://research.fs.usda.gov/treesearch/60422`

[37] Bandyopadhyay, D., et al. "Tree species classification from hyperspectral data using graph-regularized neural networks." arXiv:2208.08675. `https://arxiv.org/abs/2208.08675`
