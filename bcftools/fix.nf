process FIX {
    tag "${cohort}:${type}:${chunk}"

    label 'simple'
    label 'bcftools'

    publishDir("${params.output_dir}/fixed", mode: 'copy')

    input:
    tuple val(cohort), val(type), val(chunk),
          path(vcf_in), path(index_in),
          val(n_samples), val(n_variants),
          val(assembly), path(fasta), path(fasta_in)

    output:
    tuple val(cohort), val(type), val(chunk),
          path("${cohort}.${type}.${chunk}.fixed.vcf.gz"),
          path("${cohort}.${type}.${chunk}.fixed.vcf.gz.tbi"),
          env(n_samples), env(n_variants)

    script:
    """
    #!/bin/bash
    # Fix VCF file
    bcftools +fixref \
        ${vcf_in} \
        -Oz -o ${cohort}.${type}.${chunk}.fixed.vcf.gz \
        -- -d \
        -f ${fasta} \
        -m flip

    tabix ${cohort}.${type}.${chunk}.fixed.vcf.gz
    n_samples=\$(bcftools  query -l ${cohort}.${type}.${chunk}.fixed.vcf.gz | wc -l)
    n_variants=\$(bcftools index -n ${cohort}.${type}.${chunk}.fixed.vcf.gz)
    """
}
