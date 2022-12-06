#!/bin/bash

rankedList=$1
tfDir=$2
tfExp=$3
tfPeak=$4
outputDir=$5
ccres=$6

jid=$SLURM_ARRAY_TASK_ID
mkdir -p /tmp/moorej3/$SLURM_JOBID-$jid
cd /tmp/moorej3/$SLURM_JOBID-$jid
key=$tfExp-$tfPeak

cp $tfDir/$tfExp/$tfPeak.bed.gz tf.bed.gz
gunzip tf.bed.gz
awk -F "\t" '{print $1 "\t" $2+$10-10 "\t" $2+$10+11 "\t" "Peak-"NR}' tf.bed > tmp.bed

bedtools intersect -u -a $ccres -b tmp.bed | awk -F "\t" 'FNR==NR {x[$4];next} ($1 in x)' - $rankedList | \
    awk '{print $1 "\t" $5 "\t" 1}' | grep -v NA > tmp.raw
groupN=$(wc -l tmp.raw | awk '{print $1}')
groupStat=$(awk 'BEGIN{sum = 0}{if ($2 < 0) stat=$2*(-1); else stat=$2; sum += stat}END{print sum}' tmp.raw)

bedtools intersect -v -a $ccres -b tmp.bed | awk -F "\t" 'FNR==NR {x[$4];next} ($1 in x)' - $rankedList | \
    awk '{print $1 "\t" $5 "\t" 0}' | grep -v NA >> tmp.raw
totalN=$(wc -l tmp.raw | awk '{print $1}')

sort -k2,2rg tmp.raw | grep -v pvalue > tmp.sort

for i in `seq 1 1 25`
do
    echo $i
    awk '{print $3}' tmp.sort | shuf | paste tmp.sort - | awk '{print $1 "\t" $2 "\t" $4}' > tmp.random
    awk 'function abs(x){return ((x < 0.0) ? -x : x)} \
        BEGIN{sum=0; max=0; groupStat='$groupStat'; groupN='$groupN'; \
        totalN='$totalN'}{if ($NF == 1) sum += abs($2)/groupStat; \
        else sum = sum-1/(totalN-groupN); if (sum > max) max=sum}END{print max}' \
        tmp.random >> tmp.random-results
done

mv tmp.random-results $outputDir/$key.Background-$jid.txt

rm -r /tmp/moorej3/$SLURM_JOBID-$jid
