process REMOVE {
    tag "${cohort}:${type}:${chrom}:${chunk}"

    label 'simple'
    label 'bcftools'

    publishDir("${params.output_dir}/removed", mode: 'copy')

    input:
    tuple val(cohort), val(type), val(chrom), val(chunk),
          path(vcf_in), path(index_in),
          env(n_vars)

    output:
    tuple val(cohort), val(type), val(chrom), val(chunk),
          path("${cohort}.${type}.${chrom}.${chunk}.removed.vcf.gz"),
          path("${cohort}.${type}.${chrom}.${chunk}.removed.vcf.gz.tbi"),
          env(n_vars)
     
    script:
    """
    #!/bin/bash
    # Remove A/T and G/C SNPs
    bcftools view \
        -e '(REF="A" & ALT="T") || (REF="G" & ALT="C")' \
        ${vcf_in} \
        --threads ${task.cpus} \
        -Oz -o ${cohort}.${type}.${chrom}.${chunk}.removed.vcf.gz
    
    tabix ${cohort}.${type}.${chrom}.${chunk}.removed.vcf.gz
    n_vars=\$(bcftools index -n ${cohort}.${type}.${chrom}.${chunk}.removed.vcf.gz)
    """
}
