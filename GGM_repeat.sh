#!/bin/bash

samples=$(ls /mnt/MSA-data-2/cbettencourt-ATX-20160713-deCODE_WGS/HOU/BAM/*bam)
names=$(ls /mnt/MSA-data-2/cbettencourt-ATX-20160713-deCODE_WGS/HOU/BAM/*bam | cut -d"/" -f7)
arr_s=($samples)
arr_n=($names)
length=$(($(echo $samples | wc -w) - 1))

for i in `seq 0 $length`
do
	/data/kronos/Genetics_Software/ExpansionHunter-v3.0.0-rc1-linux_x86_64/bin/ExpansionHunter \
	--reference /data/kronos/NGS_Reference/fasta/Homo_sapiens.GRCh37.dna.toplevel.fa \
	--reads $(ls ${arr_s[i]}) \
	--variant-catalog /array/psivakumar/NIID/GGM_repeat.json \
	--output-prefix /array/psivakumar/NIID/GGM_repeat_${arr_n[i]} 
done
