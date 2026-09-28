# Introduction

Nextflow pipeline to infer genetic ancestry of a cohort by selecting informative variants and calculating principal components.

# Usage 

```bash
nextflow run genomictools/infer-cohort-ancestry \
    -r main \
    --output_dir results/ \
    --cohorts cohorts_info.csv
```

## Inputs & Parameters

*   **Core Inputs:** `--cohorts`, `--fasta`, `--dbsnp`, and `--ld_regions` define the reference datasets and regional exclusions.
*   **Thresholds & Filters:** Standard tuning parameters include `--AF`, `--HWE`, `--F_MISSING`, `--window`, `--step`, `--rsquared`, `--relatedness`, `--N_VARS`, `--N_DIMS`, and `--modes`, alongside boolean flags like `--common`, `--fill`, `--prune`, `--fix`, and `--remove`.

## Output

Results are structured under `--output_dir` including subdirectories for `cohorts/`, `updated/`, `removed/`, `fixed/`, `pruned/`, `plinked/`, `combined/`, `merged/`, `filtered/`, `selected/`, `scaled/`, `assigned/`, and `plots/`.
