process SAMPLE {
    tag "${ref}:${cohort}"

    label 'simple'
    label 'plink'

    publishDir("${params.output_dir}/sampled", mode: 'copy')

    input:
    tuple val(ref), val(cohort),
          path(bim), path(bed), path(fam), path(log),
          val(n_samples), val(n_variants)

    output:
    tuple val(ref), val(cohort),
          path("${ref}.${cohort}.sampled.bim"),
          path("${ref}.${cohort}.sampled.bed"),
          path("${ref}.${cohort}.sampled.fam"),
          path("${ref}.${cohort}.sampled.log"),
          env(n_samples), env(n_variants)

    script:
    """
    #!/bin/bash
    # Filter variants
    plink --bfile ${bim.baseName} \
        --write-snplist \
        --out filtered

    # Select N_VARS random variants
    RANDOM=42; shuf -n ${params.N_VARS} filtered.snplist > ${ref}.${cohort}.variants.txt

    # Extract variants
    plink --bfile ${bim.baseName} \
        --extract ${ref}.${cohort}.variants.txt \
        --make-bed \
        --out ${ref}.${cohort}.sampled
    
    n_samples=\$(wc -l < "${ref}.${cohort}.sampled.fam")
    n_variants=\$(wc -l < "${ref}.${cohort}.sampled.bim")
    """
}
