# TBS Story Mainline Design

## Goal

Paper-facing story:

1. Mid-distance tree classification suffers from background shortcuts.
2. ABMIL reduces shortcut reliance by selecting informative patches.
3. Full-patch MIL is expensive.
4. TBS keeps only informative patches and cuts training/inference cost.
5. Depth Augmentation stabilizes TBS by reducing bad patch selection.

`Depth Guided Attention` is moved out of the main line.
It remains a fallback/appendix experiment if the main story needs an extra gain.

## Main claims to support

- `ABMIL vs full-image baseline`: background shortcut mitigation
- `full-patch ABMIL vs sparse TBS-ABMIL`: efficiency without major accuracy loss
- `random sparse vs TBS sparse`: trunk-bias selection is useful
- `TBS sparse vs TBS sparse + DepthAug`: depth augmentation improves sparse selection robustness

## Fixed paper setting

- sparse target: `30%` patch budget
- TBS sampler: `sliding`
- sparse ratio: `bag_ratio = 0.3`
- trunk bias: `0.5`
- attention: `softmax`
- patch score: `sobel`
- depth-aug dataset: `only_blur_aug_midas_large`

This is a paper setting chosen from the latency target, not the previous best-accuracy TBS search point.

## Required comparisons

| ID | Train | Inference | Purpose |
| --- | --- | --- | --- |
| C1 | full patch | full patch | standard ABMIL reference |
| C2 | full patch | sparse 30% | can inference alone be reduced |
| C3 | random sparse 30% | random sparse 30% | patch-count reduction only |
| C4 | TBS sparse 30% | TBS sparse 30% | main efficient method |
| C5 | TBS sparse 30% + DepthAug | TBS sparse 30% | depth-aug benefit |

## Metrics

- accuracy
- macro-F1
- average instances per bag
- wall-clock inference time per image
- wall-clock training time per epoch
- total training time

Inference timing should report exact conditions:

- hardware
- batch size
- whether patch sampling is included
- whether preprocessing is included
- number of warmup / measured iterations

## Implementation note

The asymmetric comparison `C2` needs separate train/eval patch budgets.
For that, `SamplerConfig` now supports:

- `val_bag_ratio`
- `test_bag_ratio`

This keeps the suite runnable without hacking run-time overrides.

## Experiment files

Main experiment family:

- `/home/matsumura/vitmil/experiments/tbs_story`

Single-seed suites:

- `configs/urbanstreettree_mainline.yaml`
- `configs/fruitspark_mainline.yaml`

Multi-seed suites:

- `configs/urbanstreettree_multiseed.yaml`
- `configs/fruitspark_multiseed.yaml`

## Scope boundary

FruitsPark uses the standard existing split under `/home/matsumura/datasets/FruitsPark`.
No additional holdout split is assumed in the main line.

This design intentionally excludes:

- Depth Guided Attention from the main table
- additional TBS parameter search
- DINO backbone comparisons
- non-normalized variants

Those can return later only if the main story needs reinforcement.
