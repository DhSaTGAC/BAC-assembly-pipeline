################fetch_fasta_subset.pl#################
#This script extracts fasta sequences for a list of sequence IDs. 
#This is run as perl fetch_fasta_subset.pl sequence.fa list_ids > extracted_sequences.fa

#!/usr/bin/perl -w
use strict;

my $fasta = $ARGV[0];
my $list = $ARGV[1];

my %list; #store the ids of interest
open (IN, $list) or die "Can't open $list $! \n";
while(<IN>){
  chomp;
  $list{$_} = 1;
}
close IN;

local $/ = ">";

open (IN, $fasta) or die "Can't open $list $! \n";
while(<IN>){
  chomp;

  my @seq = split /\n/, $_;
  my $id = shift @seq;
  if (exists $list{$id}){
    print ">$id\n";
    foreach my $s(@seq){
      print "$s\n";
    }
  }
}
close IN;
