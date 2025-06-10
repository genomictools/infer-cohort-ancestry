process CONVERT {
    tag "${cohort}:${type}:${chrom}:${chunk}"

    label 'simple'
    label 'plink'

    publishDir("${params.output_dir}/plinked", mode: 'copy')

    input:
    tuple val(cohort), val(type), val(chrom), val(chunk),
          path(vcf_in), path(index_in),
          env(n_vars)

    output:
    tuple val(cohort), val(type), val(chrom), val(chunk),
          path("${cohort}.${type}.${chrom}.${chunk}.bim"),
          path("${cohort}.${type}.${chrom}.${chunk}.bed"),
          path("${cohort}.${type}.${chrom}.${chunk}.fam"),
          path("${cohort}.${type}.${chrom}.${chunk}.nosex"),
          path("${cohort}.${type}.${chrom}.${chunk}.log")

    script:
    """
    #!/bin/bash
    echo '.' > tmp.exclude
    plink \
        --vcf ${vcf_in} \
        --make-bed \
        --const-fid 0 \
        --exclude tmp.exclude \
        --fill-missing-a2 \
        --out ${cohort}.${type}.${chrom}.${chunk}
    """
}