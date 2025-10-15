#!/usr/bin/env nextflow

nextflow.enable.dsl=2

// Include module
include { get_coordinates }  from './subworkflows/get_coordinates.nf'
include { select_variants }  from './subworkflows/select_variants.nf'
include { prepare_variants } from './subworkflows/prepare_variants.nf'
include { infer_ancestry }   from './subworkflows/infer_ancestry.nf'

// Define input channels
cohorts_ch = Channel.fromPath(params.cohorts)
    | splitCsv(header: true, sep: ',')
    | map { row -> [ row.cohort, row.type, file(row.vars_file), file(row.vars_index) ] }

population_ch = Channel.fromPath(params.cohorts)
    | splitCsv(header: true, sep: ',')
    | map { row -> [ row.cohort, file(row.population) ] }
fasta       = Channel.fromFilePairs(params.fasta, flat: true)
modes_ch    = Channel.of(params.modes.split(','))

chroms_ch =  Channel.of( [ cohort: 'dbsnp', chrom: '', start: '', end: '', genelist: file(params.genelist) ] )
    | map { it ->
        chrom = it.chrom ?: (1..22).collect { "chr$it" } + ['chrX', 'chrY']
        key   = (it.start && it.end) ? "${chrom}:${it.start}-${it.end}" : chrom
        [ it.cohort, key, chrom, it.start ?: null, it.end ?: null, it.genelist ? file(it.genelist) : null ]
    }
    | transpose
    | unique

dbsnp = Channel.fromFilePairs(params.dbsnp, flat: true) | map { ['dbsnp', it[1], it[2], '', '' ] }

// worflow
workflow {
    // If snp list is not provided
    if ( params.snplist == null) {
        coords   = get_coordinates(chroms_ch, params.genome, params.style)
        variants = select_variants( dbsnp, coords.chunks )
        snplist  = variants.variants | collectFile(){ [ it.first(), it.last()]}
    } else {
        snplist  = Channel.fromPath(params.snplist)
    }
    snplist
        | splitText( by: params.chunk_size, limit: params.limit, file: 'chunk' )
        | map { [ it.fileName, it ] }
        | set { chunks }

    cohorts  = prepare_variants( cohorts_ch, chunks, population_ch )
    all_population = population_ch | map { it.last() }| collectFile(name: 'all.population.txt')
    ancestry = infer_ancestry(cohorts.cases, cohorts.references, all_population )
}
