#!/bin/sh

#Running FLASH
#The reads will be FLASHed together giving longer reads before nextclip is run

WORK_DIR='/path/to/working/directory/flash'

source FLASH-1.2.9
source fastx_toolkit-0.0.13

#for each library FLASH reads R1 and R2 to create longer reads
for LIB in `cat /path/to/libs.list`; do

     flash -t 32 -o $LIB /path/to/data/${LIB}_R?.fastq.gz &
	 
done
wait

#take reverse complement of FLASHed reads to create virtual R2
for LIB in `cat /path/to/libs.list`; do
    fastx_reverse_complement -Q33 -i $LIB.extendedFrags.fastq -o $LIB.extendedFrags.reverse.fastq &
done
wait

#edit the fasta header from 1 to 2 for R2 reads
for LIB in `cat /path/to/libs.list`; do
     sed -i 's/1:N:0/2:N:0/' $LIB.extendedFrags.reverse.fastq &
done
wait

#recreate "virtual R1 and virtual R2"
for LIB in `cat /path/to/libs.list`; do
     cat $LIB.notCombined_1.fastq $LIB.extendedFrags.fastq > ${LIB}_extended_R1.fastq
     cat $LIB.notCombined_2.fastq $LIB.extendedFrags.reverse.fastq > ${LIB}_extended_R2.fastq
done
wait

#clean up the mess
for LIB in `cat /path/to/libs.list`; do
     rm $LIB.*
done
