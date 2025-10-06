#!/usr/bin/env nextflow

nextflow.enable.dsl=2

// Include module
include { subset_variants }  from './subworkflows/subset_variants.nf'
include { prepare_variants } from './subworkflows/prepare_variants.nf'
include { infer_ancestry }   from './subworkflows/infer_ancestry.nf'

// Define input channels
cohorts_ch = Channel.fromPath(params.cohorts)
    | splitCsv(header: true, sep: ',')
    | map { row -> [ 
        row.cohort, row.type, row.size,
        file(row.vars_file), file(row.vars_index),
        file(row.population)
     ] }

population_ch = Channel.fromPath(params.cohorts)
    | splitCsv(header: true, sep: ',')
    | map { row -> [ row.cohort, file(row.population) ] }
dbsnp       = Channel.fromFilePairs(params.dbsnp, flat: true) | map { ['dbsnp', it[1], it[2]] }
fasta       = Channel.fromFilePairs(params.fasta, flat: true)
ld_regions  = Channel.fromPath(params.ld_regions)
chroms_ch   = Channel.of (1..22) | map { "chr$it" }
modes_ch    = Channel.of(params.modes.split(','))

// worflow
workflow {
    cohorts  = subset_variants(dbsnp, cohorts_ch)
    variants = prepare_variants(cohorts.variants, population_ch)
    ancestry = infer_ancestry(variants.cases, variants.references)
}
