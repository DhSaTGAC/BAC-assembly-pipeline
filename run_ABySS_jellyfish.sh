#!/bin/sh

WORK_DIR='/path/to/working/directory'

#This script is to run ABySS on filtered BAC reads and count kmers using jellyfish 

#source the required tools
source jellyfish-1.1.10
source abyss-1.5.1
source exonerate-2.2.0

BAC=$1

#create a directory for each BAC
mkdir ${BAC}_k71;
cd ${BAC}_k71; 

#Run ABySS with the filtered read set for each BAC
abyss-pe name=${BAC}_k71 k=71 l=91 in="/path/to/reads/filtered_${BAC}_R1.fastq.gz /path/to/reads/filtered_${BAC}_R2.fastq.gz"

#rename abyss contig headers and filter shorter contigs <500bp
cut -f1 -d " " ${BAC}_k71-contigs.fa |sed "s/>/>contig_/g" > ${BAC}_k71.v1.fa

# count all 31 k-mers for all BACs - if doing only paired-end assembly, skip this step. The kmer hash profile is used to classify mate-pairs (step 5 - main script)
jellyfish count -t 8 -s 1000000 -m31 -C -o ${BAC}.jf31 ${BAC}_k71.v1.fa

