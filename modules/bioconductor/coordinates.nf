process COORDINATES {
    tag "${key}:${genelist.simpleName}:${genome}:${style}"

    label 'simple'
    label 'bioconductor'

    publishDir("${params.output_dir}/coordiantes", mode: 'copy')

    input:
    tuple val(cohort), val(key), val(chrom), val(start), val(end), path(genelist)
    val(genome)
    val(style)

    output:
    tuple val(cohort), val("${key}"), path("${key}.${genelist.simpleName}.bed")

    script:
    """
    #!/bin/bash
    generate_coordinates.R ${chrom} ${start} ${end} ${genelist} ${genome} ${style} ${params.coding} ${params.chunk_width} ${key}.${genelist.simpleName}.bed
    """
}
