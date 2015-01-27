#!/bin/sh

#Next step is to run next clip. Store the "run_nextclip_library.sh" script in nextclip directory and run this script. Nextclip is run and post-processing of joining useful reads (A,B,C)_R1.fastq is done in this script. Please read the Nextclip manual for more information

WORK_DIR='/path/to/working/directory/nextclip'

source nextclip-0.8;
 
#link the FLASHed reads to the current directory
ln -s /path/to/flash/*.fastq .

#for each library
for LIB in `cat /path/to/libs.list`; do

		cd $PWD;
       /path/to/run_nextclip_library.sh ${LIB}_extended_R1.fastq ${LIB}_extended_R2.fastq ${LIB}_nc 64
        rm *.report
done

#join A, B, C the useful mate-pairs that are processed from Nextclip
for LIB in `cat /path/to/libs.list`; do
        cd $PWD;
        cat ${LIB}_nc_[ABC]_R1.fastq>${LIB}_nc_ABC_R1.fastq &
        cat ${LIB}_nc_[ABC]_R2.fastq>${LIB}_nc_ABC_R2.fastq &
done
wait

#delete some intermediate files
rm *_nc_?_R?.fastq *extended*
