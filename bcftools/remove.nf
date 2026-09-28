process REMOVE {
    tag "${cohort}:${type}:${chunk}"

    label 'simple'
    label 'bcftools'

    publishDir("${params.output_dir}/removed", mode: 'copy')

    input:
    tuple val(cohort), val(type), val(chunk),
          path(vcf_in), path(index_in),
          val(n_samples), val(n_variants)

    output:
    tuple val(cohort), val(type), val(chunk),
          path("${cohort}.${type}.${chunk}.removed.vcf.gz"),
          path("${cohort}.${type}.${chunk}.removed.vcf.gz.tbi"),
          env(n_samples), env(n_variants)

    script:
    """
    #!/bin/bash
    # Remove A/T and G/C SNPs
    bcftools view \
        -e '(REF="A" & ALT="T") || (REF="G" & ALT="C")' \
        ${vcf_in} \
        --threads ${task.cpus} \
        -Oz -o ${cohort}.${type}.${chunk}.removed.vcf.gz
    
    tabix ${cohort}.${type}.${chunk}.removed.vcf.gz
    n_samples=\$(bcftools query -l ${cohort}.${type}.${chunk}.picked.vcf.gz | wc -l)
    n_variants=\$(bcftools index -n ${cohort}.${type}.${chunk}.removed.vcf.gz)
    """
}
