process PRUNE {
    tag "${cohort}:${category}"

    label 'simple'
    label 'plink'

    publishDir("${params.output_dir}/pruned", mode: 'copy')

    input:
    tuple val(cohort), val(category),
          path(bim), path(bed), path(fam), path(log),
          val(n_samples), val(n_variants)

    output:
    tuple val(cohort), val(category),
          path("${cohort}.${category}.pruned.bim"),
          path("${cohort}.${category}.pruned.bed"),
          path("${cohort}.${category}.pruned.fam"),
          path("${cohort}.${category}.pruned.log"),
          env(n_samples), env(n_variants)

    script:
    def args = []
    if ( params.allow_novariants ) { args << "--allow-no-vars" }
    if ( params.allow_nosamples )  { args << "--allow-no-samples" }
    def args_str = args.join(' ')

    """
    #!/bin/bash        
    plink --bfile ${bim.baseName} \
        --indep-pairwise ${params.window} ${params.step} ${params.rsquared} \
        --out plink_tmp
    
    plink --bfile ${bim.baseName} \
        --extract plink_tmp.prune.in \
        --make-bed \
        ${args_str} \
        --out ${cohort}.${category}.pruned

    # Explicitly rename output files
    mv plink_tmp.prune.in  ${cohort}.${category}.pruned.in
    mv plink_tmp.prune.out ${cohort}.${category}.pruned.out

    n_samples=\$(wc -l < "${cohort}.${category}.pruned.fam")
    n_variants=\$(wc -l < "${cohort}.${category}.pruned.bim")
    """
}
