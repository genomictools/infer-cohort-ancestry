process SPLIT {
    tag "${cohort}:${key}"

    label 'simple'
	label 'bcftools'

    publishDir("${params.output_dir}/split", mode: 'copy')

    input:
    tuple val(cohort), path(file), path(index),
          val(n_samples), val(n_variants),
          val(key), path(coordinates)

    output:
    tuple val(cohort), val(key),
          path("${cohort}.${key}.split.vcf.gz"),
          path("${cohort}.${key}.split.vcf.gz.tbi"),
          env(n_samples),
          env(n_variants)

    script:
    """
    #!/bin/bash
    # Subset cohort
    bcftools view -R ${coordinates} ${file} --threads ${task.cpus} -Oz -o ${cohort}.${key}.split.vcf.gz

    # Index the VCF
    tabix ${cohort}.${key}.split.vcf.gz

    # Count the number of samples and variants
    n_samples=\$(bcftools  query -l ${cohort}.${key}.split.vcf.gz | wc -l)
    n_variants=\$(bcftools index -n ${cohort}.${key}.split.vcf.gz)
    """
}
