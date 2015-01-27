#!/usr/bin/env python
#this script writes fastq reads a text file based on uesr's percenetage cut-off from kat sect output

#Usage: python run_filter_kat_sect.py perc_cut_off mate-pair_R1.fastq mate_pair_R2.fastq output_file_R1.fastq output_file_R2.fastq

import sys

sf=open(sys.argv[1],"r")
t=float(sys.argv[2])
i1=open(sys.argv[3],"r")
i2=open(sys.argv[4],"r")
o1=open(sys.argv[5],"w")
o2=open(sys.argv[6],"w")

for score in sf.readlines():
	s1 = ""
	s2 = ""
	for x in xrange(4):
		s1+=i1.readline()
		s2+=i2.readline()
	if float(score)>t:
		o1.write(s1)
		o2.write(s2)
i1.close()
i2.close()
o1.close()
o2.close()
