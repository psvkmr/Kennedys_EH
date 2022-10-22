#!/bin/bash

WD=/hades/psivakumar/cohorts/macrogen_eh
SET=macrogen

TRACKED=/hades/psivakumar/cohorts/tracked.csv
REF=/hades/psivakumar/pipeline/grch38/GRCh38_full_analysis_set_plus_decoy_hla.fa
EH=/hades/Software/NGS_Software/ExpansionHunter-v3.1.2-linux_x86_64/bin/ExpansionHunter
VC=/hades/Software/NGS_Software/ExpansionHunter-v3.1.2-linux_x86_64/variant_catalog/hg38/variant_catalog.json
PILEUP=/hades/Software/NGS_Software/Pileup/GraphAlignmentViewer-master/GraphAlignmentViewer.py

# check if all samples in tracked
logid_in_tracked(){
  l1=$(grep -F -f ${WD}/${SET}_logIds.txt ${TRACKED} | wc -l)
  l2=$(wc -l ${WD}/${SET}_logIds.txt | cut -d' ' -f1)
  cat ${TRACKED} | grep -F -w -f ${WD}/${SET}_logIds.txt > ${WD}/${SET}_samples_in_tracked.txt
  if [ $l1 != $l2 ]
    then
      echo "some log ids missing from tracked file"
    else
      echo "all log ids in tracked file"
  fi
}

# get bam locs
bam_in_tracked(){
  cat ${TRACKED} | grep -F -w -f ${WD}/${SET}_logIds.txt | cut -d',' -f2,6 > ${WD}/${SET}_bam_locs.csv
  awk '$1=$1' FS="," OFS="\t" ${WD}/${SET}_bam_locs.csv > ${WD}/${SET}_bam_locs.txt
  awk -F',' '{print $2}' ${WD}/${SET}_bam_locs.csv > ${WD}/${SET}_bams_only.txt
  #sed -i 's/,/     /g' ${WD}/${SET}_bam_locs.txt
  l1=$(grep -F 'bam' ${WD}/${SET}_bam_locs.txt | wc -l)
  l2=$(cat ${WD}/${SET}_samples_in_tracked.txt | wc -l)
  if [ $l1 != $l2 ]
    then
      echo "some tracked file log ids have no associated bams"
    else
      echo "all tracked file log ids have associated bams"
  fi
}


eh(){
  SAMPLE_NAME=$( echo ${1} | awk -F/ '{print $NF}' )
  echo $SAMPLE_NAME >> ${WD}/${SET}_names_list.txt
	${EH} \
	--reference ${REF} \
	--reads ${1} \
	--variant-catalog ${VC} \
  --output-prefix ${WD}/eh_res/${SAMPLE_NAME}
}

while IFS= read -r line
do
   eh ${line} 2>> ${WD}/eh_res/eh_res.log
done < "${WD}/${SET}_bams_only.txt"

########################################
# need to amend below

BAMS=$(ls ${WD}/eh_res/*.bam)
JSONS=$(ls ${WD}/eh_res/*.json)
VCFS=$(ls ${WD}/eh_res/*.vcf)

printf "%s\n" ${BAMS} > ${WD}/${SET}_bams_list.txt
printf "%s\n" ${JSONS} > ${WD}/${SET}_jsons_list.txt
printf "%s\n" ${VCFS} > ${WD}/${SET}_vcfs_list.txt
#paste ${WD}/${SET}_names_list.txt ${WD}/${SET}_bams_list.txt ${WD}/${SET}_jsons_list.txt -d',' > ${WD}/${SET}_res_list.txt

# In R
library(data.table)
library(tidyverse)

names <- fread('macrogen_names_list.txt', header = F)
bams <- fread('macrogen_bams_list.txt', header = F)
jsons <- fread('macrogen_jsons_list.txt', header = F)

names.df <- separate(names, 'V1', c(NA, 'id'), sep = '_', remove = F) %>% separate('id', c('ID', NA), sep = '\\.')
bams.df <- separate(bams, 'V1', c(NA, NA, NA, 'id', NA), sep = '_', remove = F) %>% separate('id', c('ID', NA), sep = '\\.')
jsons.df <- separate(jsons, 'V1', c(NA, NA, NA, 'id'), sep = '_', remove = F) %>% separate('id', c('ID', NA, NA), sep = '\\.')
res.df <- left_join(names.df, bams.df, by = 'ID') %>% left_join(jsons.df, by = 'ID') %>% na.omit() %>% dplyr::select('NAME' = 'ID', 'BAM' = 'V1.y', 'JSON' = 'V1')

fwrite(res.df, 'macrogen_res_list.txt', header = F)

# back to bash

LOC_IDS=("AFF2" "AR" "ATN1" "ATXN1" "ATXN10" "ATXN2" "ATXN3" "ATXN7" "ATXN8OS" "C9ORF72" "CACNA1A" "CBL" "CNBP" "CSTB" "DIP2B" "DMPK" "FMR1" "FXN" "HTT" "JPH3" "NOP56" "PHOX2B" "PPP2R2B" "TBP" "TCF4")

plup(){
    for loc in ${LOC_IDS[@]};
    do
        python3.5 ${PILEUP} \
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

while IFS=, read -r name bam json
do
  plup ${bam} ${json} ${name} &>> ${WD}/eh_res/pileup.log
done < "${WD}/${SET}_res_list.txt"
