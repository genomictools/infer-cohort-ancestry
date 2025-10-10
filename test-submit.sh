#!/bin/bash

#SBATCH -o tests/test.out
#SBATCH -e tests/test.err
#SBATCH -J test
#SBATCH -p master-worker
#SBATCH -t 120:00:00

# Setup test directory
mkdir -p tests/ tests/input

# # Download test data
# URL="https://figshare.com/ndownloader/files"

# URL="https://raw.githubusercontent.com/genomictools/test-datasets/refs/heads/infer-cohort-ancestry"
# wget -c $URL/ref.variants.vcf.gz -O tests/input/ref.variants.vcf.gz
# wget -c $URL/ref.variants.vcf.gz.tbi -O tests/input/ref.variants.vcf.gz.tbi
# wget -c $URL/ref.population.txt -O tests/input/ref.population.txt
# wget -c $URL/pheno.variants.vcf.gz -O tests/input/pheno.variants.vcf.gz
# wget -c $URL/pheno.variants.vcf.gz.tbi -O tests/input/pheno.variants.vcf.gz.tbi
# wget -c $URL/pheno.population.txt -O tests/input/pheno.population.txt

# echo -e "cohort,type,size,vars_file,vars_index,population" > tests/input/cohorts_input.csv
# echo -e "ref,references,10,./input/ref.variants.vcf.gz,./input/ref.variants.vcf.gz.tbi,./input/ref.population.txt" >> tests/input/cohorts_input.csv
# echo -e "pheno,cases,6,./input/pheno.variants.vcf.gz,./input/pheno.variants.vcf.gz.tbi,./input/pheno.population.txt" >> tests/input/cohorts_input.csv

# Run nextflow
module load Nextflow

cd tests/

# nextflow run houlstonlab/infer-cohort-ancestry -r main \
nextflow run ../main.nf \
    --output_dir ./results/ \
    -profile cluster,test \
    -params-file ../test-params.json \
    -resume

# usage: nextflow run [ local_dir/main.nf | git_url ]  
# These are the required arguments:
#     -r            {main,dev} to run specific branch
#     -profile      {local,cluster} to run using differens resources
#     -params-file  params.json to pass parameters to the pipeline
#     -resume       To resume the pipeline from the last checkpoint
