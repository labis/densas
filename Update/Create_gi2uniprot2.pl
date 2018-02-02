#!/bin/perl -w
use strict;
use Data::Dumper qw(Dumper);
my $file = $ARGV[0] or die "Need to get idmaping file on the command line\n";
 
open(my $data, '<', $file) or die "Could not open '$file' $!\n";
 
while (my $line = <$data>) {
  chomp $line;
  my ($Uniprot, $GI) = split( /\t/, $line );
  #print $Uniprot."\t".$GI."\n";
  my @GIs = split /;/, $GI;
  foreach my $loopGI (@GIs)
  {
    print "$Uniprot\t$loopGI\n";
    }
  }
close( $data );
