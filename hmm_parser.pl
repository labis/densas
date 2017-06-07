#!/thunderstorm/perl5/perls/perl-5.18.1/bin/perl -w
use strict;
use Data::Dumper qw(Dumper);
my $MyFILE   = $ARGV[0];
open( my $MyPARSER, "<",$MyFILE ) || die "Error : $!";
my @lines = <$MyPARSER>;
close( $MyPARSER );

foreach my $line ( @lines ) {
  
  # Skipping if the line is empty or a comment
  next if ( $line =~ /^\s*$/ );
  next if ( $line =~ /^\s*#/ );
  
  my ($targetName, $pfam, $seqName, $seqAccession, $fsEvalue, $fsScore, $fsBias, $bdEvalue, $bdScore, $bdBias, $dneExp, $dneReg, $dneClu, $dneOv, $dneEnv, $dneDom, $dneRep, $dneInc, $targetDesc) = split( /\s+/, $line );
  my ($seqNAME, $waste) = split (/\|/, $seqName);
  print $seqNAME."\t".$targetName."\t".$targetDesc."\t".$pfam."\t".$bdEvalue."\t".$fsEvalue."\n";
  push (my @pfamDec, ["$seqName","$targetName","$targetDesc","$pfam.","$bdEvalue","$fsEvalue"]);
  
  # then do whatever you have to
}
my @sorted = sort { $a->[5] <=> $b->[5] } my @pfamDec;
#print "SEQUENCES BEST HIT\n";
#print "SeqName\tTargetName\tPFAM\n";
#print "$sorted[0][0]\t$sorted[0][1]\t$sorted[0][3]\n";