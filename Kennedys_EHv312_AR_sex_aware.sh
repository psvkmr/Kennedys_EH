#!/bin/bash

names=$(cat /array/psivakumar/Kennedys/Kennedys_samples.txt)
arr_n=($names)
length=$(($(echo $names | wc -w) -1))

echo $length

eh(){
	sex_info=$(if [[ $1 =~ 02183|02187|02189 ]];then echo "female";else echo "male";fi)
	/data/kronos/Genetics_Software/ExpansionHunter-v3.1.2-linux_x86_64/bin/ExpansionHunter \
	--reference /data/kronos/NGS_Reference/fasta/GRCh38_full_analysis_set_plus_decoy_hla.fa \
	--reads /data/kronos/jvand74/EH_AR/$1.bam \
	--variant-catalog /array/psivakumar/Kennedys/Kristina_ehv312_AR_jsons/variant_catalog_GRCh38_AR.json \
	--sex $sex_info \
  --output-prefix /array/psivakumar/Kennedys/EHv312/$1
}

for i in `seq 0 $length`
do
	eh ${arr_n[i]}
done

bams=$(ls /array/psivakumar/Kennedys/EHv312/*.bam)
jsons=$(ls /array/psivakumar/Kennedys/EHv312/*.json)

printf "%s\n" $names > names_list.txt
printf "%s\n" $bams > bams_list.txt
printf "%s\n" $jsons > jsons_list.txt
paste names_list.txt bams_list.txt jsons_list.txt -d"," > Kennedys_AR_ehv312_file_list.csv

python3.6 /array/psivakumar/Pileup/GraphAlignmentViewer-master/GraphAlignmentViewer.py \
  --variant_catalog /array/psivakumar/Kennedys/Kristina_ehv312_AR_jsons/variant_catalog_GRCh38_AR.json \
  --read_align_list /array/psivakumar/Kennedys/EHv312/Kennedys_AR_ehv312_file_list.csv \
  --file_format v3 \
  --reference_fasta /data/kronos/NGS_Reference/fasta/GRCh38_full_analysis_set_plus_decoy_hla.fa \
  --dpi 300 \
  --output_dir /array/psivakumar/Kennedys/EHv312
