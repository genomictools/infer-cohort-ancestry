process ASSIGN {
    tag "${ref}:${cohort}:${mode}"

    label 'simple'
    label 'rocker'

    publishDir("${params.output_dir}/assigned", mode: 'copy')

    input:
    tuple val(ref), val(cohort), val(mode), path(pop),
          path(scaled), path(log)

    output:
    tuple val(ref), val(cohort), val(mode), path(scaled),
          path("${ref}.${cohort}.${mode}.assigned.pop"),
          path("${ref}.${cohort}.${mode}.assigned.log")

    script:
    """
    #!/bin/bash
    assign_pop.R ${ref} ${cohort} ${mode} ${scaled} ${pop} ${params.family_ids} ${params.dimension} 2> ${ref}.${cohort}.${mode}.assigned.log
    """
}