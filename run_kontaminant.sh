#!/bin/sh

WORK_DIR='/path/to/working/directory'

#This script is to screen and filter all contaminants from the contaminant database provided by the user. 
#Variable name BAC holds your BAC id from standard input
BAC=$1


#source the required tools
source kontaminant-2.0.3

#Kontaminant works only on unzipped files
zcat /path/to/reads/${BAC}_R1.fastq.gz > /path/to/reads/${BAC}_R1.fastq
zcat /path/to/reads/${BAC}_R2.fastq.gz > /path/to/reads/${BAC}_R2.fastq

#Run Kontaminant using this command. Parameters are available using kontaminant -h. Using -c supply list of contaminant prefixes, for eg.: ecoli,phix,vector
kontaminant -s -1 /path/to/reads/${BAC}_R1.fastq -2 /path/to/reads/${BAC}_R2.fastq -c contaminant_prefixes -d contaminants_directory -k 21 -o filtered_ -r dirty_reads_

#Zip up the filtered FASTQ files (optional)
gzip -f /path/to/reads/${PLATE}/filtered_${BAC}_R1.fastq
gzip -f /path/to/reads/${PLATE}/filtered_${BAC}_R2.fastq
