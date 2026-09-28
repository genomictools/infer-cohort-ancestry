process FILL {
    tag "${cohort}:${type}:${key}"

    label 'simple'
    label 'bcftools'

    publishDir("${params.output_dir}/filled", mode: 'copy')

    input:
    tuple val(cohort), val(type), val(key),
          path(file), path(index),
          val(n_samples), val(n_variants)

    output:
    tuple val(cohort), val(type), val(key),
          path("${cohort}.${type}.${key}.filled.vcf.gz"),
          path("${cohort}.${type}.${key}.filled.vcf.gz.tbi"),
          env(n_samples), env(n_variants)

    script:
    """
    #!/bin/bash
    # Fill in genotypes
    bcftools view ${file} | \
    bcftools +setGT -- -t q -n 0 -i 'FMT/GQ < ${params.GQ} | FMT/DP < ${params.DP} | VAF < ${params.VAF}' | \
    bcftools +fill-tags -- -t all | \
    bcftools view -g het --threads ${task.cpus} -Oz -o ${cohort}.${key}.filled.vcf.gz

	# Index the filled VCF
    tabix ${cohort}.${type}.${key}.filled.vcf.gz

    # Count the number of samples and variants
    n_samples=\$(bcftools  query -l ${cohort}.${type}.${key}.filled.vcf.gz | wc -l)
    n_variants=\$(bcftools index -n ${cohort}.${type}.${key}.filled.vcf.gz)
    """
}
