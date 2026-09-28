#!/bin/bash

#SBATCH -o test-datasets/tests.out
#SBATCH -e test-datasets/tests.err
#SBATCH -J tests
#SBATCH -p master-worker
#SBATCH -t 120:00:00

# Run nextflow
module load Nextflow

# Run nextflow
nextflow run main.nf \
    --output_dir test-datasets/results/ \
    -profile local,test \
    -resume
