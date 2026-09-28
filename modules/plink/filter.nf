process FILTER {
    tag "${cohort}:${key}:${category}"

    label 'simple'
    label 'plink'

    publishDir("${params.output_dir}/filtered", mode: 'copy')

    input:
    tuple val(cohort), val(key), val(category),
          path(bim), path(bed), path(fam), path(log),
          val(n_samples), val(n_variants)

    output:
    tuple val(cohort), val(key), val(category),
          path("${cohort}.${key}.${category}.filtered.bim"),
          path("${cohort}.${key}.${category}.filtered.bed"),
          path("${cohort}.${key}.${category}.filtered.fam"),
          path("${cohort}.${key}.${category}.filtered.log"),
          env(n_samples), env(n_variants)

    script:
    def args = []
    if ( params.nonfounders ) { args << "--nonfounders" }
    if ( params.allow_novariants ) { args << "--allow-no-vars" }
    if ( params.allow_nosamples )  { args << "--allow-no-samples" }
    def args_str = args.join(' ')

    """
    # Filter variants
    plink --bfile ${bim.baseName} \
        --mac ${params.mac} \
        --maf ${params.maf} \
        --hwe ${params.hwe} \
        --geno ${params.geno} \
        ${args_str} \
        --make-bed \
        --out ${cohort}.${key}.${category}.filtered

    n_samples=\$(wc -l < "${cohort}.${key}.${category}.filtered.fam")
    n_variants=\$(wc -l < "${cohort}.${key}.${category}.filtered.bim")
    """
}
