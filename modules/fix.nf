process FIX {
    tag "${cohort}:${type}:${chrom}:${chunk}"

    label 'simple'
    label 'bcftools'

    publishDir("${params.output_dir}/fixed", mode: 'copy')

    input:
    tuple val(cohort), val(type), val(chrom), val(chunk),
          path(vcf_in), path(index_in),
          env(n_vars),
          val(fasta), path(fasta_in), path(fasta_index)

    output:
    tuple val(cohort), val(type), val(chrom), val(chunk),
          path("${cohort}.${type}.${chrom}.${chunk}.fixed.vcf.gz"),
          path("${cohort}.${type}.${chrom}.${chunk}.fixed.vcf.gz.tbi"),
          env(n_vars)
     
    script:
    """
    #!/bin/bash
    # Fix VCF file
    bcftools +fixref \
        ${vcf_in} \
        -Oz -o ${cohort}.${type}.${chrom}.${chunk}.fixed.vcf.gz \
        -- -d \
        -f ${fasta_in} \
        -m flip

    tabix ${cohort}.${type}.${chrom}.${chunk}.fixed.vcf.gz
    n_vars=\$(bcftools index -n ${cohort}.${type}.${chrom}.${chunk}.fixed.vcf.gz)
    """
}
