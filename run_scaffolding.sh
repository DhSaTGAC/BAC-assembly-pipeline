#!/bin/sh

WORKDIR='/path/to/working/directory'

#This script takes in a BAC name and performs scaffolding only on ABySS contigs using classified mate-pairs, formats SOAP_scaffolded.fa for long stretch of C/G's to Ns and runs gap closer. Use sample_SOAP_config.txt file to create config files for each BAC (use shell commands).
 

BAC=$1

#source required tools
source soapdenovo-2.04;
source exonerate-2.2.0;
source fastx_toolkit-0.0.13.2;
source gapcloser-1.12;

#prepare data
finalFusion -s config_soap_$BAC.txt -g soap_$BAC -D -K 71 -c /path_to_PE_assembly/${BAC}_k71.v1.fa

#SOAP map module
SOAPdenovo-63mer map -s config_soap_$BAC.txt -g soap_$BAC -k 41

#SOAP scaff module (alter parameters according to SOAP manual)
SOAPdenovo-63mer scaff -g soap_$BAC -G 30 -F -w -L 100

#This step is optional, formatting the fasta header to be renamed all contigs/scaffolds to scaffold and mark them in numerical order
sed  s/0.0//g soap_$BAC.scafSeq| sed "s/>C/>scaffold_/g" |awk '{$1=$1}1' |sed "s/>scaffold/>scaffold_/g" |awk '{if(/^>/){a++;print ">scaffold_" a}else{print}}' > soap_$BAC.scafSeq.fa

#gapcorrector - format the SOAP scaffolded fasta and reoplace long stretches (>20) of C/G's to N's
scaff_file=soap_$BAC.scafSeq.fa

#format the fasta files
fasta_formatter -i $scaff_file -o ${scaff_file}.oneline

# replace Cs
cat ${scaff_file}.oneline | perl -pe 's/(C{20,})/"N" x length($1)/gei' > ${scaff_file}.noC

# replace Gs
cat ${scaff_file}.noC | perl -pe 's/(G{20,})/"N" x length($1)/gei' > ${scaff_file}.noG

# wrap the fasta again
fasta_formatter -w 90 -i $scaff_file.noG -o gpcorr_${BAC}.fa

# remove intermediate files (optional)
rm ${scaff_file}.oneline
rm ${scaff_file}.noC
rm ${scaff_file}.noG

#Run gapcloser
GapCloser -a gpcorr_${BAC}.fa -o gapcloser_$BAC.v1.fa -b config_soap_$BAC.txt -l 151 -p 13

#filter shorter contigs <500 from the final scaffolds using fetch_fasta_subset.pl script
fastalength gapcloser_$BAC.v1.fa|awk '{if ($1>500) {print $2}'} > ctg_ids_500_$BAC; 
perl fetch_fasta_subset.pl gapcloser_$BAC.v1.fa ctg_ids_500_$BAC > final_$BAC.flt500.fa