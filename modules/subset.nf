process SUBSET {
    tag "${cohort}:${type}:${chrom}:${chunk}"

    label 'simple'
    label 'bcftools'

    publishDir("${params.output_dir}/cohorts", mode: 'copy')

    input:
    tuple val(chrom), val(chunk), path(snps),
          val(cohort), val(type), val(size), 
		  path(vcf_in), path(index_in),
          path(population)

    output:
    tuple val(cohort), val(type), val(chrom), val(chunk),
          path("${cohort}.${type}.${chrom}.${chunk}.snps.vcf.gz"),
          path("${cohort}.${type}.${chrom}.${chunk}.snps.vcf.gz.tbi"),
          env(n_vars)
          
    script:
    """
    #!/bin/bash
    # Compress and index the snps
    bgzip -c ${snps} > snps.bed.gz
    tabix -s1 -b2 -e2 snps.bed.gz

	# Extract SNPs
    bcftools view \
        ${vcf_in} \
        -S <(awk '{ print \$2 }' ${population}) \
        -R ${snps} \
        -i 'AC>0' \
        -v snps -m2 -M2 | \
    bcftools norm -d any | \
    bcftools annotate \
        -a snps.bed.gz \
        -c CHROM,POS,ID \
        --threads ${task.cpus} \
        -Oz -o ${cohort}.${type}.${chrom}.${chunk}.snps.vcf.gz
    
    # Index
    tabix ${cohort}.${type}.${chrom}.${chunk}.snps.vcf.gz

    # Count number of variants
    n_vars=\$(bcftools index -n "${cohort}.${type}.${chrom}.${chunk}.snps.vcf.gz")
    """
}
