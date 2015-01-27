#!/bin/sh

#This script helps to asesmble BACs from contaminant read filtering and scaffold ssemblies using paired-end and mate-pair data
#edit memory requirements for jobs according to the input files and run each step seperately as it depends on results from previous steps

#step 1:create a contaminant database by running kmer_hash_build_31 for each contaminant.fa file. If using more than one contaminant, please make sure all your contaminants are stored in the same directory 
bsub -oo kontaminant_hash_build.log -R "rusage[mem=5000]" "source kontaminant-2.0.3; kmer_hash_build_31 -n 25 -b 120 -f FASTA -i /path/to/contaminant.fa -o /path/to/contaminant.fasta.21.kmers -k 21" 

#step 2:Run Kontaminant using script run_kontaminant.sh. Here, bac_ids_plate1.txt is a text file containing 384 BAC ids (one well plate) - 384 jobs will be submitted from this command
for BAC in `cat bac_ids_plate1.txt` ; do bsub -oo kontaminant_filter_$BAC.log -R "rusage[mem=5000]" "/path/to/run_kontaminant.sh ${BAC}" ; done 

#step 3:Run ABySS and create kmer hash for each BAC's paired-end assembly. kmer hash is used in later stages for mate-pair processing
for BAC in `cat bac_ids_plate1.txt` ; do  bsub -oo abyss_$BAC.log -R "rusage[mem=5000]" "/path/to/run_ABySS_jellyfish.sh ${BAC}"; done 

#step 4: Prepare mate-pair libraries and do nextclip
#step4a: copy all mate-pair raw reads to data directory and create a text file with prefix of mate-pair libraries
mkdir data;

ls mate-pair_reads*R1.fastq.gz |cut -f1-5 -d "_" > libs.list

#step 4b: Run FLASH tool to obtain extended reads R1 and R2 for all libraries.
mkdir flash;

#in this directory copy the run_FLASH.sh script (run in PBS environment) (can also be run on LSF environment)
echo "cd $PWD; /path/to/run_FLASH.sh" |qsub -l select=1:ncpus=16:mem=50G;

#step 4c: Run Nextclip tool to clip junction adapters
#This step contains 2 scripts (run_nextclip.sh and run_nextclip_library.sh) that trims adapters using nextclip and performs post-processing. This will give us adapter clipped mate-pair fastq files that will be used for classifying mate-pairs per BAC
mkdir nextclip;
echo "cd $PWD; /path/to/run_nextclip.sh" |qsub -l select=1:ncpus=16:mem=50G;

#step 5: Classify mate-pairs per BAC from a 384 plate, using kmer hash of paired-end assembly. If you have more than one mate-pair library, edit the script 
for BAC in `cat bac_ids_plate1.txt` ; do bsub -oo map_mate_pairs_$BAC.log -R "rusage[mem=7000]" "/path/to/run_mate_pair_classification.sh ${BAC}" ; done ;

#step 6: Using mate-pairs per BAC, scaffold each BAC and run Gapcloser for gapfilling and filter <500bp contigs to obtain final assembly
for BAC in `cat bac_ids_plate1.txt` ; do bsub -oo scaffolding_$BAC.log -R "rusage[mem=5000]" "/path/to/run_scaffolding.sh ${BAC}" ; done ;
