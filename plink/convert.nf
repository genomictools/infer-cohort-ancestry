process CONVERT {
    tag "${cohort}:${key}:${category}"

    label 'simple'
    label 'plink'

    publishDir("${params.output_dir}/plinked", mode: 'copy')

    input:
    tuple val(cohort), val(key), val(category),
          path(file), path(index),
          val(n_samples), val(n_variants),
          path(pedigree)

    output:
    tuple val(cohort), val(key), val(category),
          path("${cohort}.${key}.${category}.bim"),
          path("${cohort}.${key}.${category}.bed"),
          path("${cohort}.${key}.${category}.fam"),
          path("${cohort}.${key}.${category}.log"),
          env(n_samples), env(n_variants)

    script:
    args = []
    if ( !params.family_ids ) { args << "--const-fid" }
    args_str = args.join(" ")
    """
    #!/bin/bash
    # if params.family_ids is false, set all family IDs to 0
    if [ "${params.family_ids}" = "false" ]; then
        awk '{print "0", \$2, \$6}' ${pedigree} > phenotype.tsv
        awk '{print "0", \$2, \$5}' ${pedigree} > sex.tsv
    else
        awk '{print \$1, \$2, \$6}' ${pedigree} > phenotype.tsv
        awk '{print \$1, \$2, \$5}' ${pedigree} > sex.tsv
    fi

    plink \
        --vcf ${file} \
        --pheno phenotype.tsv \
        --update-sex sex.tsv \
        ${args_str} \
        --vcf-half-call ${params.halfcalls} \
        --make-bed \
        --out ${cohort}.${key}.${category}

    n_samples=\$(wc -l < "${cohort}.${key}.${category}.fam")
    n_variants=\$(wc -l < "${cohort}.${key}.${category}.bim")
    """
}
