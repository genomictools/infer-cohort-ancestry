process COMBINE {
    tag "${cohort}:${category}"

    label 'simple'
    label 'plink'

    publishDir("${params.output_dir}/combined", mode: 'copy')

    input:
    tuple val(cohort), val(category), val(key),
          path(bim), path(bed), path(fam), path(log),
          val(n_samples), val(n_variants)

    output:
    tuple val(cohort), val(category),
          path("${cohort}.${category}.bim"),
          path("${cohort}.${category}.bed"),
          path("${cohort}.${category}.fam"),
          path("${cohort}.${category}.log"),
          env(n_samples), env(n_variants)

    script:
    """
    #!/bin/bash
    # Create a list of all files
    echo "${bed.join('\n')}" > bed.txt
    echo "${bim.join('\n')}" > bim.txt
    echo "${fam.join('\n')}" > fam.txt
    paste -d ' ' bed.txt bim.txt fam.txt | sort -V > allfiles.txt

    # Merge all files
    plink \
        --make-bed \
        --merge-list allfiles.txt \
        --allow-no-sex \
        --out ${cohort}.${category}

    n_samples=\$(wc -l < "${cohort}.${category}.fam")
    n_variants=\$(wc -l < "${cohort}.${category}.bim")
    """
}
