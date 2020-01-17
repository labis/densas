#!/bin/perl -w
use strict;
use Data::Dumper qw(Dumper);
my $file = $ARGV[0] or die "Need to get idmaping file on the command line\n";
 
open(my $data, '<', $file) or die "Could not open '$file' $!\n";
 
while (my $line = <$data>) {
  chomp $line;
  my ($UniprotAcc, $UniprotId, $GI, $Acc) = split( /\t/, $line );
  #print $Uniprot."\t".$GI."\n";
  my @Acc = split /;/, $Acc;
  foreach my $loopAcc (@Acc)
  {
    print "$UniprotId\t$UniprotAcc\t$loopAcc\t$GI\n";
    }
  }
close( $data );
