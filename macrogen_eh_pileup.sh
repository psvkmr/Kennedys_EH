#!/bin/bash

WD=/hades/psivakumar/cohorts/macrogen_eh
SET=macrogen
TRACKED=/hades/psivakumar/cohorts/tracked.csv
REF=/hades/psivakumar/pipeline/grch38/GRCh38_full_analysis_set_plus_decoy_hla.fa
EH=/hades/Software/NGS_Software/ExpansionHunter-v3.1.2-linux_x86_64/bin/ExpansionHunter
VC=/hades/Software/NGS_Software/ExpansionHunter-v3.1.2-linux_x86_64/variant_catalog/hg38/variant_catalog.json
PILEUP=/hades/Software/NGS_Software/Pileup/GraphAlignmentViewer-master/GraphAlignmentViewer.py
LOC_IDS=("AFF2" "AR" "ATN1" "ATXN1" "ATXN10" "ATXN2" "ATXN3" "ATXN7" "ATXN8OS" "C9ORF72" "CACNA1A" "CBL" "CNBP" "CSTB" "DIP2B" "DMPK" "FMR1" "FXN" "HTT" "JPH3" "NOP56" "PHOX2B" "PPP2R2B" "TBP" "TCF4")

plup(){
    for loc in ${LOC_IDS[@]};
    do
        /home/hades/anaconda3/bin/python3.5 ${PILEUP} \
          --variant_catalog ${VC} \
          --read_align ${1} \
          --gt_file ${2} \
          --locus_id ${loc} \
          --file_format v3 \
          --reference_fasta ${REF} \
          --dpi 100 \
          --output_dir ${WD}/eh_res \
          --output_prefix ${3}
    done
}

while IFS=, read -r name bam json;
do
  plup ${bam} ${json} ${name}
done < ${WD}/${SET}_res_list.txt
