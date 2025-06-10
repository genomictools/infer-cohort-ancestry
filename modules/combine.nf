process COMBINE {
    tag "${cohort}:${type}"

    label 'simple'
    label 'plink'

    publishDir("${params.output_dir}/combined", mode: 'copy')

    input:
    tuple val(cohort), val(type), val(chrom), val(chunk),
          path(bim), path(bed), path(fam), path(nosex),
          path(log)

    output:
    tuple val(cohort), val(type),
          path("${cohort}.${type}.bim"),
          path("${cohort}.${type}.bed"),
          path("${cohort}.${type}.fam"),
          path("${cohort}.${type}.nosex"),
          path("${cohort}.${type}.log")

    script:
    """
    #!/bin/bash
    # Create a list of all files
    echo "${bed.join('\n')}" > bed.txt
    echo "${bim.join('\n')}" > bim.txt
    echo "${fam.join('\n')}" > fam.txt
    paste -d ' ' bed.txt bim.txt fam.txt | sort -V > allfiles.txt

    # Createa list of duplicate variants
    cat ${bim} | cut -f 2 | sort > allvariants.txt
    cat allvariants.txt | uniq -d > duplicates.txt
    grep -vwFf duplicates.txt allvariants.txt > uniquevariants.txt

    # Merge all files
    plink \
        --make-bed \
        --extract uniquevariants.txt \
        --merge-list allfiles.txt \
        --out ${cohort}.${type}
    """
}
