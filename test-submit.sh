#!/bin/bash

#SBATCH -o tests/test.out
#SBATCH -e tests/test.err
#SBATCH -J test
#SBATCH -p master-worker
#SBATCH -t 120:00:00

# Setup test directory
mkdir -p tests/

TESTDATA="git@github.com:genomictools/test-datasets.git"
BRANCH="infer-cohort-ancestry"
SRC="tests/input"

git -C $SRC pull || \
git clone -b $BRANCH $TESTDATA $SRC

# Run nextflow
module load Nextflow

cd tests/

# nextflow run genomictools/infer-cohort-ancestry -r main \
nextflow run ../main.nf \
    --output_dir ./results/ \
    -profile local,test \
    -params-file ../test-params.json \
    -resume

# usage: nextflow run [ local_dir/main.nf | git_url ]  
# These are the required arguments:
#     -r            {main,dev} to run specific branch
#     -profile      {local,cluster} to run using differens resources
#     -params-file  params.json to pass parameters to the pipeline
#     -resume       To resume the pipeline from the last checkpoint
