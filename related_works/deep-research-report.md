# Related Work for Sparse Patch Selection in MIL-based Tree Species Classification

## Overall assessment

The most defensible related-work frame for your paper is **not** only “tree species classification,” but **tree species classification plus sparse/efficient MIL under weak supervision**. The closest mature literature comes from computational pathology, where researchers also work with very large bags of image patches, only bag-level labels, strong patch redundancy, and attention-based aggregators. Recent surveys of MIL for whole-slide images and transformer-based pathology analysis explicitly describe these as central problems: weak labels, huge image scale, patch redundancy, interpretability, and the need to model both local and global context. citeturn23view1turn23view0

That literature maps unusually well onto your claims. In particular, your study asks whether **using all patches is actually optimal**, whether **patch choice matters more than raw patch count**, and whether **a small set of dominant patches can drive classification**. Those questions are now directly studied in recent MIL papers on patch selection, hard-instance mining, attention concentration, and removal of irrelevant regions. The tree-species literature is still important, but mostly to justify **why trunk/bark-centered cues and multi-organ structure matter** for the application domain, not to supply the strongest methodological baselines. citeturn14view0turn15view0turn14view1turn27view0turn13view0turn26view2

A careful reading of the literature supports two different levels of claim. **Fact-based**: there is solid prior evidence that full-bag processing is often redundant, and that selecting, masking, or pruning instances/tokens can preserve accuracy and sometimes improve it. **Expectation-based**: those benefits should transfer cleanly to urban tree species classification with your exact Trunk Biased Sampling plus Depth Augmentation design. The first claim is well supported. The second is plausible, but the directly matching application evidence is much thinner, so it should be phrased more cautiously. citeturn14view0turn15view0turn14view1turn27view0turn10view0turn11view0turn11view1

I found a clear public paper and dataset page for **UrbanStreetTree**, but I did **not** find an equally clear indexed public source for **FruitsPark** in the sources reviewed here. In the paper, that means UrbanStreetTree can be positioned as the externally anchorable benchmark, while FruitsPark will need especially careful documentation if it is locally collected or otherwise less visible to reviewers. UrbanStreetTree is documented as a public dataset covering 50 tree species, 41,467 classification images, and multiple organ-specific subsets including leaf, tree, trunk, branch, flower, and fruit. citeturn13view0turn13view3

## Papers closest to your actual claims

The following papers are the **closest methodological neighbors** to your current story. These are the ones I would treat as the primary “directly related” block in the paper.

| Paper | Why it is close to your study | How it helps your narrative |
|---|---|---|
| **PAMIL, CVPR 2024** | Proposes dynamic instance sampling inside MIL and explicitly identifies storage, preprocessing cost, overfitting, and robustness as problems of many-instance bags. | Strong support for the claim that **instance sampling is a core design axis**, not just an implementation detail. It is especially useful if you discuss efficiency and robustness together. citeturn14view0 |
| **MHIM-MIL, ICCV 2023** | Argues that attention-based MIL tends to focus on easy salient instances while neglecting harder but useful ones, and introduces masked hard instance mining. | Very relevant to your “**which patches matter**” argument, especially when comparing against random downsampling. It supports the idea that naive saliency or naive subsampling can miss discriminative structure. citeturn19search0turn19search6 |
| **ACMIL, ECCV 2024** | Studies attention concentration explicitly, shows that a tiny number of instances can dominate attention, and links over-concentration to overfitting. | This is one of the best papers for your “**dominant patches**” and attention-analysis section. It directly supports the idea that sparse subsets can dominate prediction and that attention distribution quality matters. citeturn15view0 |
| **Key Patches Are All You Need, CVPRW 2024** | States that discriminative information can be localized in a small subset of regions and reports better cross-dataset generalization with MIL-based patch selection. | Very close to your main thesis that **all patches are not always necessary**, and useful if you want a concise citation for localized discriminative evidence. citeturn14view1turn7search3 |
| **HDMIL, CVPR 2025** | Explicitly targets faster WSI classification by eliminating irrelevant patches and reports both speed gains and accuracy gains/improvements over prior methods. | Possibly the single strongest recent citation for your “**sparsification can improve both efficiency and accuracy**” claim. It also gives you a modern counterpart to full-patch baselines. citeturn27view0 |
| **TDA-MIL, MICCAI 2025** | Uses a first-pass global representation followed by selection of task-relevant instances and a second attention pass. | Good for positioning your work against newer “**global first, focus later**” MIL designs. I would cite it as an emerging related method, not as the main anchor. citeturn33view0 |

Taken together, these papers already justify most of your present argument structure. PAMIL and HDMIL motivate the **efficiency** side. MHIM-MIL and ACMIL motivate the **selection quality** and **attention concentration** side. Key Patches Are All You Need gives you the most compact external support for the sentence “a small subset of regions may be sufficient for accurate prediction.” citeturn14view0turn27view0turn19search0turn15view0turn14view1

If you want to be precise and conservative, the literature most clearly supports this wording: **“prior work has shown that many-instance MIL often contains redundant or low-value instances, and that better instance selection, masking, or pruning can preserve or improve performance.”** What it does **not** yet prove for your exact case is that trunk-biased sampling is the universally best selector for tree species classification. That part remains your contribution. citeturn14view0turn19search0turn15view0turn27view0

## Foundational MIL and ViT-MIL papers you should cite

Your paper still needs the standard MIL backbone, because reviewers will expect you to situate sparse-patch selection relative to the standard “full bag + learned pooling/aggregation” family.

### Classical MIL foundations

MIL was formalized around the setting where labels belong to **bags** rather than to individually labeled instances, and later surveys emphasized that bag composition, label ambiguity, and data distribution strongly affect algorithm behavior. Those two citations are still the cleanest way to open the technical background section. citeturn28search5turn28search9

A modern deep-learning foundation is **Attention-based Deep Multiple Instance Learning** by Ilse, Tomczak, and Welling, which introduced a permutation-invariant attention-based aggregation operator and made attention pooling the de facto baseline for deep MIL. This is a must-cite paper for any MIL study that discusses attention maps or instance importance. citeturn46search0turn46search1

### Strong standard baselines in weakly supervised visual MIL

For weakly supervised high-resolution image analysis, **CLAM** is still one of the most important references. Nature Biomedical Engineering describes it as an interpretable slide-level framework that identifies representative high-diagnostic-value regions and uses instance-level clustering to refine the feature space, while outperforming standard weakly supervised classification in the studied pathology tasks. Even if your domain is trees rather than pathology, CLAM remains a standard citation for **interpretable MIL with representative region discovery**. citeturn45view0

**DSMIL** is another standard reference. The CVPR 2021 paper frames WSI classification as MIL, models relations among instances in a dual-stream architecture, addresses large or unbalanced bags, and includes multiscale fusion. It is useful in your related work because it sits between plain attention pooling and transformer-era correlation modeling. citeturn42view0

**TransMIL** is the main transformer-era milestone. Its official NeurIPS abstract explicitly argues that previous MIL methods assume i.i.d. instances and therefore neglect correlation among instances; TransMIL instead models morphological and spatial information through correlated transformer-based MIL. This is the clearest prior for your “ViT-based MIL” positioning. citeturn7search18turn43search0

**SETMIL** is a strong follow-on paper if you want a more spatially explicit ViT-MIL reference. Its MICCAI abstract highlights comprehensive encoding of all instances, simultaneous aggregation of neighboring and globally correlated instances, joint absolute-relative positional encoding, and multi-scale fusion. It is especially useful if your paper argues that sparse selection should be evaluated **against spatially aware full-bag transformers**, not only against simple ABMIL. citeturn41view0

If you want one more architectural citation beyond TransMIL and SETMIL, **H²-MIL** and **KAT** are reasonable options. H²-MIL targets hierarchical heterogeneous multi-resolution representation in WSI analysis, and KAT argues that vanilla token-wise self-attention and positional embeddings are not ideal for gigapixel images, proposing kernel attention instead. I would treat these as optional, depending on space. citeturn21search5turn40search1turn40search10

### Adjacent efficient-ViT literature

Even though these papers are not MIL papers, they are very useful for the broad introduction because they support the more general proposition that **dense token processing is often redundant** in vision transformers. **DynamicViT** states that final predictions rely on a subset of informative tokens and shows that pruning 66% of input tokens can reduce FLOPs substantially with little accuracy loss. **EViT** argues that not all tokens contribute positively and reorganizes attentive versus inattentive tokens for a better speed-accuracy trade-off. **ToMe** shows that merging similar tokens at runtime can roughly double throughput of some ViTs with only small accuracy drops. **TokenLearner** learns a handful of adaptive tokens instead of processing dense patch sets. These papers are not substitutes for sparse MIL citations, but they are excellent **supporting motivation** if your introduction says the issue is broader than only MIL. citeturn10view0turn11view0turn11view1turn11view2

## Tree-species and urban-tree papers that support the application story

The application-side related work should be much narrower and more targeted. It should mainly justify **why urban tree recognition is difficult**, **why organ-specific cues matter**, and **why trunk/bark and depth cues are plausible priors**.

### Urban tree recognition and datasets

The **UrbanStreetTree dataset** paper is essential. It introduces a large-scale public urban street tree dataset with 50 species and 41,467 high-resolution classification images from 10 city scenes, including organ-specific subsets for leaf, tree, trunk, branch, flower, and fruit. The public dataset page confirms those organ splits. This is highly relevant to your work because it directly legitimizes a design that treats different organs as differently informative rather than assuming uniform patch value. citeturn13view0turn13view3

For broader urban-tree context, **Choi et al. 2022** propose an automatic urban street tree inventory system using Google Street View and deep learning, noting that relatively few studies had combined street-view images and deep learning for urban tree species detection and profile estimation. **Arevalo-Ramirez et al. 2024** then argue that urban-tree screening via street-view imagery remains challenging, and that more automation is still needed for unresolved computer-vision tasks in urban-tree assessment. These two papers are useful for motivating UrbanStreetTree as a realistic and difficult benchmark rather than a trivial species-recognition setting. citeturn13view1turn13view2

### Why trunk and bark cues matter

Your **Trunk Biased Sampling** idea has meaningful support from tree-identification literature. **Bertrand et al. 2018** argue that bark can be a very distinctive feature and show that combining bark and leaf information improves recognition over leaf-only pipelines. **Zhao et al. 2020** similarly report that bark helps when single-organ identification is difficult because of intra-class variation and inter-class similarity, and they show fusion of bark and leaves outperforming single-organ recognition in their setting. citeturn26view2turn26view0

There is also stronger evidence that bark contains human-recognizable diagnostic structure. **Kim et al. 2022** report that CNNs identified bark images from 42 species with greater than 90% accuracy, and that the salient diagnostic keys matched recognizable bark traits such as stripes, lenticels, and crevices. That is not the same as proving trunk-focused sampling is optimal in MIL, but it does make your trunk prior **biologically and visually plausible**. citeturn26view1

An additional recent paper, **Surendran et al. 2025**, investigates why researchers often prefer segment-specific bark images to larger or whole-tree images for deep tree-species classification. I would treat this as supportive but secondary, because it is useful conceptually yet less central than the earlier organ-fusion and bark-diagnostic papers. citeturn37search0

### Why depth cues are plausible

Your **Depth Augmentation** idea has weaker direct literature support than TBS, but there is still a reasonable application-side citation path. **Fan et al. 2023** study tree species classification from point-cloud projection images and conclude that adding depth information helps compensate for information lost in 2D projection and improves classification performance. This is not the same modality as your work, so it should be cited cautiously, but it supports the idea that shape/depth cues can add discriminative information beyond plain RGB appearance. citeturn36view0

The right way to phrase this in your paper is therefore something like: **“prior tree-species studies indicate that bark/trunk structure can be strongly discriminative and that geometric/depth-related cues can improve species recognition, motivating our trunk bias and depth augmentation design.”** That wording stays close to what the literature actually shows. citeturn26view2turn26view0turn26view1turn36view0

## Recommended citation stack for your manuscript

If page budget is tight, I would prioritize the citations in three layers.

### Essential citations

These are the papers I would consider hardest to omit.

- **Dietterich et al. 1997** for the MIL problem formulation, plus **Carbonneau et al. 2018** for the MIL survey. citeturn28search5turn28search9
- **Ilse et al. 2018** for attention-based deep MIL. citeturn46search0turn46search1
- **CLAM 2021**, **DSMIL 2021**, and **TransMIL 2021** for mainstream weakly supervised visual MIL baselines. citeturn45view0turn42view0turn43search0
- **PAMIL 2024**, **MHIM-MIL 2023**, **ACMIL 2024**, **Key Patches Are All You Need 2024**, and **HDMIL 2025** for the sparse-selection / dominant-patch / efficiency block most directly aligned with your central claim. citeturn14view0turn19search0turn15view0turn14view1turn27view0
- **UrbanStreetTree dataset 2023** for the dataset anchor. citeturn13view0turn13view3

### Strong optional citations

These are especially useful if you have enough space, or if reviewers are likely to want stronger architectural or application justification.

- **SETMIL 2022** if you want a stronger spatially aware transformer baseline in the related-work section. citeturn41view0
- **TDA-MIL 2025** if you want to acknowledge recent top-down refocusing approaches. citeturn33view0
- **DynamicViT**, **EViT**, **ToMe**, and **TokenLearner** if your introduction makes a general claim that dense patches/tokens are often redundant outside MIL too. citeturn10view0turn11view0turn11view1turn11view2
- **Choi et al. 2022** and **Arevalo-Ramirez et al. 2024** if your opening section frames the practical problem of urban street-tree inspection and recognition. citeturn13view1turn13view2
- **Bertrand et al. 2018**, **Zhao et al. 2020**, and **Kim et al. 2022** if you want the TBS prior to look application-aware rather than purely heuristic. citeturn26view2turn26view0turn26view1

### Use selectively for interpretability caveats

If you discuss attention maps as evidence, I would recommend adding at least one caveat citation.

- **Additive MIL 2022** argues that exact spatial credit assignment can improve over classical attention heatmaps in interpretability. citeturn31view0
- **Attention is not Explanation** is not MIL-specific, but it is the standard broad caution that attention weights should not be overclaimed as faithful explanations. citeturn29search0

For your paper, I would therefore avoid saying that attention proves causal importance. A safer formulation is that attention analysis provides **qualitative evidence consistent with** dominant patch behavior. That wording aligns better with the interpretability literature. citeturn31view0turn29search0

## Suggested positioning for your paper

A strong and careful positioning would be:

Your work sits at the intersection of **weakly supervised MIL aggregation**, **sparse instance selection**, and **urban tree species classification**. Standard deep MIL papers such as ABMIL, CLAM, DSMIL, and TransMIL mainly assume that all extracted instances are available to the aggregator, though they often reweight them. Recent sparse and efficient MIL papers then question that assumption by showing that removing irrelevant, redundant, or over-dominant instances can improve efficiency and sometimes performance. Your paper contributes to that second line, but in the urban-tree domain and with an application-specific selector grounded in tree morphology. citeturn46search0turn45view0turn42view0turn43search0turn14view0turn19search0turn15view0turn27view0

The cleanest high-level contribution statement is therefore **not** “we beat the SOTA while being sparse,” because the literature already contains multiple efficiency-oriented MIL papers and your own summary suggests the outcomes are dataset-dependent. A stronger statement is: **“we show that full-patch learning is not always optimal in MIL-based tree species classification, and that informed patch selection can maintain or improve accuracy while reducing computation.”** That is both better aligned with your current evidence and better aligned with the literature. citeturn14view1turn27view0turn15view0

For **UrbanStreetTree**, you can position the result as a realistic test of sparse MIL under diverse street conditions and organ variability, because the dataset was explicitly constructed to contain different organs and varied acquisition conditions. For **FruitsPark**, based on your own experimental observations, I would present it as a contrast case that highlights dataset dependence, especially if it has lower diversity or stronger near-duplicate effects. The literature gives you cover for that framing because both MIL and urban-tree papers repeatedly emphasize that data distribution, local context, and domain difficulty strongly influence what helps. citeturn13view0turn13view3turn28search9turn13view2

## Open questions and limitations

The main limitation of this literature map is that the **strongest sparse-patch MIL papers are mostly from computational pathology**, not from tree-species recognition. That makes them methodologically relevant, but not application-identical. In the paper, that should be acknowledged explicitly rather than hidden. citeturn23view1turn23view0

A second limitation is that the evidence for **trunk-biased sampling** is indirect. Tree-identification studies clearly show that bark and trunk cues can be discriminative and can complement leaves, but I did not find a prior paper that tests your exact **trunk-biased sparse MIL** design on urban street-tree bags. That means TBS still looks genuinely novel, but the justification should be phrased as **motivated by** organ-specific evidence rather than **established by** prior MIL results. citeturn26view2turn26view0turn26view1

The same is true for **Depth Augmentation**. Tree-species work supports the usefulness of depth or geometry-related information, but the exact combination of RGB patch bags, MIL aggregation, trunk bias, and synthetic or auxiliary depth augmentation appears underexplored in the literature I reviewed. That makes it interesting, but it also means your paper should separate **observed empirical findings** from **broader generalization claims**. citeturn36view0

Finally, for the attention-analysis section, the safest scholarly stance is that attention maps are **useful qualitative diagnostics**, not conclusive explanations. If you keep that distinction clear, your current “dominant patch” story will read as careful and credible rather than overstated. citeturn31view0turn29search0