process MERGE {
    tag "${ref}:${cohort}"

    label 'simple'
    label 'plink'

    publishDir("${params.output_dir}/merged", mode: 'copy')

    input:
    tuple val(cohort), val(cohort_type),
          path(cohort_bim), path(cohort_bed), path(cohort_fam), path(cohort_log),
          val(n_samples), val(n_variants)
    tuple val(ref), val(ref_type),
          path(ref_bim), path(ref_bed), path(ref_fam), path(ref_log),
          val(n_ref_samples), val(n_ref_variants)

    output:
    tuple val(ref), val(cohort),
          path("${ref}.${cohort}.bim"),
          path("${ref}.${cohort}.bed"),
          path("${ref}.${cohort}.fam"),
          path("${ref}.${cohort}.log"),
          env(n_samples), env(n_variants)

    script:
    """
    #!/bin/bash
    # Get common snps
    comm -12 \
        <( cat ${ref_bim}    | awk '{print \$2}' | sort ) \
        <( cat ${cohort_bim} | awk '{print \$2}' | sort ) \
        > common_snps.txt

    # Merge
    plink --bfile ${ref_bim.baseName} \
        --bmerge ${cohort_bed} ${cohort_bim} ${cohort_fam} \
        --extract common_snps.txt \
        --make-bed \
        --out ${ref}.${cohort}
    n_samples=\$(wc -l < "${ref}.${cohort}.fam")
    n_variants=\$(wc -l < "${ref}.${cohort}.bim")
    """
}

    // # Return population file
    // cat \
    //     <(cat ${ref_pop}    | awk '{print \$0, "${ref_type}"}') \
    //     <(cat ${cohort_pop} | awk '{print \$0, "${cohort_type}"}') \
    //     > ${ref}.${cohort}.pop
    
    // # Extract snp lists, missnps and flipped snps
    // plink --bfile ${ref_bim.baseName} --write-snplist --out ref || true
    // plink --bfile ${cohort_bim.baseName} --write-snplist --out cohort || true
    // plink --bfile ${ref_bim.baseName} --bmerge ${cohort_bed} ${cohort_bim} ${cohort_fam} --write-snplist --out merged || true
    
    // # Get common snps
    // comm -12 <(sort refsnps.snplist) <(sort cohortsnps.snplist) | \
    // > common_snps.txt

    // # Merge
    // plink --bfile ${ref_bim.baseName} \
    //     --extract common_snps.txt \
    //     --make-bed \
    //     --allow-no-vars \
    //     --out ref

    // plink --bfile ${cohort_bim.baseName} \
    //     --extract common_snps.txt \
    //     --make-bed \
    //     --allow-no-vars \
    //     --out cohort
    
    // plink --bfile ref \
    //     --bmerge cohort.bed cohort.bim cohort.fam \
    //     --extract common_snps.txt \
    //     --allow-no-vars \
    //     --make-bed \
    //     --out ${ref}.${cohort}