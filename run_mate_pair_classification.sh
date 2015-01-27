#!/bin/sh

#Now run kat sect to classify mate-pairs from a 384 plate to per BAC using kmers from ABySS assembly

WORK_DIR='/path/to/working/directory'

BAC=$1

#source the required tools
source jellyfish-1.1.10
source kat-1.0.6

#kat's sect mpodule compares hash -s is your mate-pair fastq processed from nextclip (end result), and specify the hash created from step3 in ABySS assembly. Three output files will be created, of which .cvg is the required in later steps

kat sect -o LMP_${BAC}_R1.profile -s /path/to/mate-pair/plate1_R1.fastq /path/to/paired-end-jellyfish_hash/${BAC}.jf31_0 -t 64 -C
kat sect -o LMP_${BAC}_R2.profile -s /path/to/mate-pair/plate1_R2.fastq /path/to/paired-end-jellyfish_hash/${BAC}.jf31_0 -t 64 -C


#Count the kmers from kat sect's .cvg output file (R1+R2) and estimate it as a percentage
paste -d " " LMP_${i}_R?.profile_counts.cvg | grep -v '>' |awk '{a=NF;gsub("0 ","");print(NF-1)*100/a;}' > present_kmers_$BAC.txt


#classify mate-pairs seen in >95% of reads (users can set their own percentage cut-off)
python /path/to/run_filter_kat_sect.py present_kmers_${BAC}.txt 95 /path/to/mate-pair/plate1_R1.fastq /path/to/mate-pair/plate1_R2.fastq MP_${BAC}_R1.fastq MP_${BAC}_R2.fastq

#Zip all fastq mate-pair reads
gzip -f MP_${BAC}_R1.fastq
gzip -f MP_${BAC}_R2.fastq