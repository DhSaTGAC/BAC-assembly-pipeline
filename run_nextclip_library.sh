#!/bin/bash

source nextclip-0.8;
if [ "$#" -eq 0 ];then
        echo "Usage: $0 input_r1.fastq input_r1.fastq out_prefix processes"
fi

lines=`wc -l $1|awk '{print $1}'`
chunkseqs=$((($lines/4)/$4 + 1))

split -l $((chunkseqs * 4)) $1 $1.part_ &
split -l $((chunkseqs * 4)) $2 $2.part_ &
wait

#run nextclip. For more parameters, check the manual

for i in $1.part_*; do
  nextclip -i $i -j `echo $i|sed 's/'$1'/'$2'/'` -o $3.$i > $3.$i.report &
done

wait

#join the individual chinks of A, B, C and D
cat $3.$1*A_R1.fastq > $3_A_R1.fastq &
cat $3.$1*A_R2.fastq > $3_A_R2.fastq &
cat $3.$1*B_R1.fastq > $3_B_R1.fastq &
cat $3.$1*B_R2.fastq > $3_B_R2.fastq &
cat $3.$1*C_R1.fastq > $3_C_R1.fastq &
cat $3.$1*C_R2.fastq > $3_C_R2.fastq &
cat $3.$1*D_R1.fastq > $3_D_R1.fastq &
cat $3.$1*D_R2.fastq > $3_D_R2.fastq &

wait

#delete temporary files
rm $1.part_* $2.part_* $3.$1.part_*.fastq