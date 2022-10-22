#!/bin/bash

# make read align list
ls /data/kronos/jvand74/EH_AR/*.log > /data/kronos/jvand74/EH_AR/log_files.txt
ls /data/kronos/jvand74/EH_AR/*.vcf > /data/kronos/jvand74/EH_AR/vcf_files.txt
paste -d "," /array/psivakumar/Kennedys/Kennedys_samples.txt /data/kronos/jvand74/EH_AR/log_files.txt /data/kronos/jvand74/EH_AR/vcf_files.txt > /data/kronos/jvand74/EH_AR/EH_AR_read_align_file_list.csv

python3.6 /array/psivakumar/Pileup/GraphAlignmentViewer-master/GraphAlignmentViewer.py \
  --variant_catalog /array/psivakumar/Kennedys/Kristina_AR_jsons/ \
  --read_align_list /data/kronos/jvand74/EH_AR/EH_AR_read_align_file_list.csv \
  --file_format v2.5 \
  --reference_fasta /data/kronos/NGS_Reference/fasta/GRCh38_full_analysis_set_plus_decoy_hla.fa \
  --dpi 300 \
  --output_dir /data/kronos/jvand74/EH_AR/pileups
