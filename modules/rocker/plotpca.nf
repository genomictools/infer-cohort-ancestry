process PLOTPCA {
    tag "${ref}:${cohort}:${mode}"

    label 'simple'
    label 'rocker'

    publishDir("${params.output_dir}/plots", mode: 'copy')

    input:
    tuple val(ref), val(cohort), val(mode),
          path(scaled), path(pop), path(log)
    
    output:
    tuple val(ref), val(cohort), val(mode),
          path("${ref}.${cohort}.${mode}.png"),
          path("${ref}.${cohort}.${mode}.log")
    
    script:
    """
    #!/bin/bash
    plot_pca.R ${ref} ${cohort} ${mode} ${scaled} ${pop} ${params.dimension} 2> ${ref}.${cohort}.${mode}.log
    """
}
