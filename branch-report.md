# Remote Branch Report

**Generated:** 2026-02-27

> A branch is considered **stale** if its last commit is older than 6 months.

> A branch is considered **safe to delete** if it is fully merged into `develop` (i.e., 0 commits ahead).

---

## Methodology

This report covers all remote feature branches (excluding `master` and `develop`) across the following repositories under `/Users/tom/projects/mvg-dc/`:

- `immutable-collections`
- `dclare`
- `dclareForJava`
- `dclareForMPS`
- `cdm`
- `cds-runtime`
- `cdm-generator`

Each repository is assumed to have a local clone with an up-to-date `origin` remote. Before regenerating, fetch all remotes:

```bash
for repo in immutable-collections dclare dclareForJava dclareForMPS cdm cds-runtime cdm-generator; do
  git -C "/Users/tom/projects/mvg-dc/$repo" fetch --prune
done
```

### Data per branch

All comparisons are made against the `origin/develop` branch.

| Column              | How to obtain                                                                                                                                 |
|---------------------|-----------------------------------------------------------------------------------------------------------------------------------------------|
| **Branch**          | `git branch -r` (excluding `origin/master`, `origin/develop`, `origin/HEAD`)                                                                  |
| **Owner**           | Author of the tip commit: `git log origin/<branch> -1 --format="%an"`. If the author is `automation`, look at the next non-automation commit. |
| **Last Activity**   | Date of the tip commit: `git log origin/<branch> -1 --format="%as"`                                                                           |
| **Age**             | Time between Last Activity and the report generation date.                                                                                    |
| **Stale?**          | Yes if Age > 6 months.                                                                                                                        |
| **Ahead**           | Commits on the branch not in develop: `git rev-list --count origin/develop..origin/<branch>`                                                  |
| **Behind**          | Commits in develop not on the branch: `git rev-list --count origin/<branch>..origin/develop`                                                  |
| **Merged?**         | Yes if Ahead = 0 (all branch commits are reachable from develop).                                                                             |
| **Files Changed**   | From the three-dot diff: `git diff --shortstat origin/develop...origin/<branch>` (files changed count)                                        |
| **Lines Changed**   | From the three-dot diff: insertions + deletions from the same `--shortstat` output.                                                           |
| **Safe to Delete?** | Yes if Merged = Yes (Ahead = 0). The branch contains no unique work.                                                                          |

### Regeneration

To regenerate this report, run the above git commands for each branch in each repository and compile the results into the tables below. The three-dot diff (`develop...branch`) shows only changes introduced by the branch, excluding changes made on develop since the branch diverged.

---

## immutable-collections

*No remaining feature branches.*

---

## dclare

| Branch            | Owner             | Last Activity | Age               | Stale? | Merged? | Ahead | Behind | Files Changed | Lines Changed | Safe to Delete? |
|-------------------|-------------------|---------------|-------------------|--------|---------|-------|--------|---------------|---------------|-----------------|
| `jeroen`          | Jeroen Thunnissen | 2025-07-17    | ~7 months         | Yes    | No      | 1     | 6      | 1             | 2             | No              |
| `lazy-derivation` | Wim Bast          | 2023-11-13    | ~2 years 3 months | Yes    | No      | 1     | 176    | 11            | 268           | No              |
| `previousState`   | Wim Bast          | 2023-02-08    | ~3 years          | Yes    | No      | 6     | 275    | 7             | 192           | No              |

---

## dclareForJava

| Branch          | Owner    | Last Activity | Age      | Stale? | Merged? | Ahead | Behind | Files Changed | Lines Changed | Safe to Delete? |
|-----------------|----------|---------------|----------|--------|---------|-------|--------|---------------|---------------|-----------------|
| `previousState` | Wim Bast | 2023-02-08    | ~3 years | Yes    | No      | 1     | 57     | 1             | 7             | No              |

---

## dclareForMPS

| Branch               | Owner             | Last Activity | Age               | Stale? | Merged? | Ahead | Behind | Files Changed | Lines Changed | Safe to Delete? |
|----------------------|-------------------|---------------|-------------------|--------|---------|-------|--------|---------------|---------------|-----------------|
| `MPS2021.2`          | Wim Bast          | 2022-12-02    | ~3 years 3 months | Yes    | No      | 1     | 551    | 5             | 82            | No              |
| `MPS_2022.3`         | Wim Bast          | 2024-07-17    | ~1 year 7 months  | Yes    | No      | 43    | 95     | 32            | 25,040        | No              |
| `develop-MPS-2019.1` | Wim Bast          | 2019-10-28    | ~6 years 4 months | Yes    | No      | 3     | 1,815  | 26            | 2,345         | No              |
| `jeroen`             | Jeroen Thunnissen | 2025-07-17    | ~7 months         | Yes    | No      | 1     | 5      | 6             | 121           | No              |
| `lazy-derivation`    | Wim Bast          | 2023-11-13    | ~2 years 3 months | Yes    | No      | 1     | 248    | 12            | 817           | No              |
| `master-MPS-2019.1`  | Wim Bast          | 2019-10-28    | ~6 years 4 months | Yes    | No      | 3     | 1,815  | 26            | 2,345         | No              |
| `natives`            | Wim Bast          | 2023-01-11    | ~3 years 1 month  | Yes    | No      | 1     | 519    | 64            | 141           | No              |
| `previousState`      | Wim Bast          | 2023-02-08    | ~3 years          | Yes    | No      | 2     | 498    | 3             | 148           | No              |

---

## cdm

| Branch            | Owner             | Last Activity | Age               | Stale? | Merged? | Ahead | Behind | Files Changed | Lines Changed | Safe to Delete? |
|-------------------|-------------------|---------------|-------------------|--------|---------|-------|--------|---------------|---------------|-----------------|
| `FixBeforeSplit`  | Wim Bast          | 2023-07-11    | ~2 years 7 months | Yes    | No      | 1     | 473    | 3             | 7             | No              |
| `clusters`        | Jeroen Thunnissen | 2025-10-18    | ~4 months         | No     | No      | 13    | 62     | 15            | 2,678         | No              |
| `lazy-derivation` | Wim Bast          | 2023-11-13    | ~2 years 3 months | Yes    | No      | 1     | 267    | 2             | 6             | No              |
| `modularEnums`    | Jeroen Thunnissen | 2025-04-15    | ~10 months        | Yes    | No      | 1     | 62     | 2             | 55            | No              |
| `objectcreation`  | Wim Bast          | 2024-03-26    | ~1 year 11 months | Yes    | No      | 9     | 190    | 12            | 9,670         | No              |

---

## cds-runtime

| Branch           | Owner    | Last Activity | Age               | Stale? | Merged? | Ahead | Behind | Files Changed | Lines Changed | Safe to Delete? |
|------------------|----------|---------------|-------------------|--------|---------|-------|--------|---------------|---------------|-----------------|
| `objectcreation` | Wim Bast | 2024-03-26    | ~1 year 11 months | Yes    | No      | 6     | 21     | 5             | 233           | No              |

---

## cdm-generator

| Branch            | Owner    | Last Activity | Age               | Stale? | Merged? | Ahead | Behind | Files Changed | Lines Changed | Safe to Delete? |
|-------------------|----------|---------------|-------------------|--------|---------|-------|--------|---------------|---------------|-----------------|
| `lazy-derivation` | Wim Bast | 2023-11-13    | ~2 years 3 months | Yes    | No      | 1     | 234    | 1             | 2             | No              |
| `objectcreation`  | Wim Bast | 2024-03-26    | ~1 year 11 months | Yes    | No      | 6     | 150    | 10            | 5,234         | No              |

---

## Summary: Branches Safe to Delete

All previously identified safe-to-delete branches have been deleted. No remaining branches are safe to delete.

## Summary: Branches Requiring Review

These branches have unique commits (not merged) but are stale (>6 months old). Consider reviewing with their owners before deciding:

| Project       | Branch               | Owner             | Last Activity | Ahead | Files | Lines  |
|---------------|----------------------|-------------------|---------------|-------|-------|--------|
| dclare        | `jeroen`             | Jeroen Thunnissen | 2025-07-17    | 1     | 1     | 2      |
| dclare        | `lazy-derivation`    | Wim Bast          | 2023-11-13    | 1     | 11    | 268    |
| dclare        | `previousState`      | Wim Bast          | 2023-02-08    | 6     | 7     | 192    |
| dclareForJava | `previousState`      | Wim Bast          | 2023-02-08    | 1     | 1     | 7      |
| dclareForMPS  | `MPS2021.2`          | Wim Bast          | 2022-12-02    | 1     | 5     | 82     |
| dclareForMPS  | `MPS_2022.3`         | Wim Bast          | 2024-07-17    | 43    | 32    | 25,040 |
| dclareForMPS  | `develop-MPS-2019.1` | Wim Bast          | 2019-10-28    | 3     | 26    | 2,345  |
| dclareForMPS  | `jeroen`             | Jeroen Thunnissen | 2025-07-17    | 1     | 6     | 121    |
| dclareForMPS  | `lazy-derivation`    | Wim Bast          | 2023-11-13    | 1     | 12    | 817    |
| dclareForMPS  | `master-MPS-2019.1`  | Wim Bast          | 2019-10-28    | 3     | 26    | 2,345  |
| dclareForMPS  | `natives`            | Wim Bast          | 2023-01-11    | 1     | 64    | 141    |
| dclareForMPS  | `previousState`      | Wim Bast          | 2023-02-08    | 2     | 3     | 148    |
| cdm           | `FixBeforeSplit`     | Wim Bast          | 2023-07-11    | 1     | 3     | 7      |
| cdm           | `lazy-derivation`    | Wim Bast          | 2023-11-13    | 1     | 2     | 6      |
| cdm           | `modularEnums`       | Jeroen Thunnissen | 2025-04-15    | 1     | 2     | 55     |
| cdm           | `objectcreation`     | Wim Bast          | 2024-03-26    | 9     | 12    | 9,670  |
| cds-runtime   | `objectcreation`     | Wim Bast          | 2024-03-26    | 6     | 5     | 233    |
| cdm-generator | `lazy-derivation`    | Wim Bast          | 2023-11-13    | 1     | 1     | 2      |
| cdm-generator | `objectcreation`     | Wim Bast          | 2024-03-26    | 6     | 10    | 5,234  |

## Active Branches (Not Stale)

| Project | Branch     | Owner             | Last Activity | Ahead | Files | Lines |
|---------|------------|-------------------|---------------|-------|-------|-------|
| cdm     | `clusters` | Jeroen Thunnissen | 2025-10-18    | 13    | 15    | 2,678 |

---

## Cleanup Script

All 12 previously identified safe-to-delete branches have been deleted. No cleanup actions remaining.
