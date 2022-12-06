#!/bin/bash

outputHeader=/data/zusers/moorej3/moorej.ghpcc.project/ENCODE/Encyclopedia/V7/Registry/V7-hg38/Differentiation/DNase-DESeq2/Enrichment-Calculations/ #update

tfDir=/data/projects/encode/data
tfExp=ENCSR865RXA #update
tfPeak=ENCFF081USG #update
comparison=PGP1-Astrocyte #update

dataDir=/data/zusers/moorej3/moorej.ghpcc.project/ENCODE/Encyclopedia/V7/Registry/V7-hg38/Differentiation/DNase-DESeq2
ccres=/data/projects/encode/Registry/V4/GRCh38/GRCh38-cCREs.bed

rankedList=$dataDir/$comparison.DESeq2-Results.txt
outputDir=$outputHeader/$comparison/$tfExp-$tfPeak

mkdir -p $outputDir

sbatch --nodes 1 --mem=10G --time=00:30:00 \
    --output=/home/moorej3/Job-Logs/jobid_%A.output \
    --error=/home/moorej3/Job-Logs/jobid_%A.error \
    Group-Enrichment.TF-Peaks.sh $rankedList $tfDir $tfExp $tfPeak $outputDir $ccres


sbatch --nodes 1 --array=1-40 --mem=10G --time=04:00:00 \
    --output=/home/moorej3/Job-Logs/jobid_%A.output \
    --error=/home/moorej3/Job-Logs/jobid_%A.error \
    Background-Enrichment.TF-Peaks.sh $rankedList $tfDir $tfExp $tfPeak $outputDir $ccres
