#!/bin/bash

#Jill Moore
#Moore Lab
#UMass Chan Medical School
#December 2022

list=~/Lab/ENCODE/Encyclopedia/V7/Registry/V7-hg38/hg38-TF/hg38-TF-List.Filtered.txt
for i in `seq 1 1 2509`
do
    tf=$(awk '{if (NR == '$i') print $1"-"$2}' $list)
    group=$(awk '{print $1}' $tf/$tf.Group.txt)
    cat $tf/*Background-*.txt | awk '{if ('$group' > $1) sum += 1; mean+=$1}END{if (1-sum/NR < 0.05) print "'$tf'" "\t" '$group'/(mean/NR); else print "'$tf'" "\t" 0}'
done




