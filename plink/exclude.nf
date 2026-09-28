process EXCLUDE {
    tag "${cohort}:${category}"

    label 'simple'
    label 'plink'

    publishDir("${params.output_dir}/excluded", mode: 'copy')

    input:
    tuple val(cohort), val(category),
          path(bim), path(bed), path(fam), path(log),
          val(n_samples), val(n_variants)

    output:
    tuple val(cohort), val(category),
          path("${cohort}.${category}.excluded.bim"),
          path("${cohort}.${category}.excluded.bed"),
          path("${cohort}.${category}.excluded.fam"),
          path("${cohort}.${category}.excluded.log"),
          env(n_samples), env(n_variants)

    script:
    def args = []
    if ( params.allow_novariants ) { args << "--allow-no-vars" }
    if ( params.allow_nosamples )  { args << "--allow-no-samples" }
    def args_str = args.join(' ')

    """
    # Filter variants
    plink --bfile ${bim.baseName} \
        --exclude range ${file(params.exclude_regions)} \
        --make-bed \
        ${args_str} \
        --out ${cohort}.${category}.excluded
    
    n_samples=\$(wc -l < "${cohort}.${category}.excluded.fam")
    n_variants=\$(wc -l < "${cohort}.${category}.excluded.bim")
    """
}
