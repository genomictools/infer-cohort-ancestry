process FILL {
    tag "${cohort}:${type}:${chrom}:${chunk}"

    label 'simple'
    label 'bcftools'

    publishDir("${params.output_dir}/filled", mode: 'copy')

    input:
    tuple val(cohort), val(type), val(chrom), val(chunk),
          path(vcf_in), path(index_in),
          env(n_vars)

    output:
    tuple val(cohort), val(type), val(chrom), val(chunk),
          path("${cohort}.${type}.${chrom}.${chunk}.filled.vcf.gz"),
          path("${cohort}.${type}.${chrom}.${chunk}.filled.vcf.gz.tbi"),
          env(n_vars)
     
    script:
    """
    #!/bin/bash
    # Fill VCF file
	bcftools view ${vcf_in} | \
    bcftools +fill-tags -- -t all | \
    bcftools +setGT -- -t q -n 0 -i 'FMT/GQ < ${params.GQ} | FMT/DP < ${params.DP} | VAF < ${params.VAF}' | \
    bcftools +fill-tags -- -t all | \
    bcftools view -e 'MAF < ${params.MAF}' | \
 	bcftools view -g het --threads ${task.cpus} -Oz -o ${cohort}.${type}.${chrom}.${chunk}.filled.vcf.gz

    # Index
    tabix ${cohort}.${type}.${chrom}.${chunk}.filled.vcf.gz

    # Count number of variants
    n_vars=\$(bcftools index -n ${cohort}.${type}.${chrom}.${chunk}.filled.vcf.gz)
	"""
}
