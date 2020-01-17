#!/thunderstorm/perl5/perls/perl-5.18.1/bin/perl -w
use strict;
use Data::Dumper qw(Dumper);
use List::MoreUtils qw(uniq);
use Getopt::Long;
use POSIX;
use 5.010;
use warnings;
use Scalar::Util qw(looks_like_number);
use Term::ANSIColor qw(:constants);
$Term::ANSIColor::AUTORESET = 1; # auto reset colors


my ($rundir,$PRJ,$iprsfile);
    GetOptions ('rundir=s' => \$rundir, 
                'prj=s' => \$PRJ,
                'iprs=s' => \$iprsfile);
    if ((!$PRJ) || (!$rundir) || (!$iprsfile)) {
    print BOLD RED "Some required arguments are missing.\nYou must use this as follow:\n";
    print BOLD MAGENTA "$0 --prj PROJECT --rundir /PATH/TO/THE/RUNDIR/ --iprs [ interproscan TSV file ] \n";
    exit 1
}

unless (-e "$rundir/$iprsfile") {
  
  die BOLD RED "Dammit Lab Goblins!!\n Something is terribly wrong!\nI could not find the Header file in $rundir/$iprsfile.\nPlease check where is this file and try again\n";
}
my @all;

###################
# OPEN FILE AND READ INTO ARRAY
###################

open( my $iprsPARSER, "<",$iprsfile ) || die "Error : $!";
my @lines = <$iprsPARSER>;
close( $iprsPARSER );

###################
# LOOP INTO ARRAY AND CHOOSE SEQNAME AND GOID
# BASED ON SCORE
###################

foreach my $line ( @lines ) {
  # Skipping if the line is empty or a comment
  next if ( $line =~ /^\s*$/ );
  next if ( $line =~ /^\s*#/ );
  
  my ($ProteinAccession, $MD5, $Length, $Analysis, $SigAcc, $SigDesc, $Startloc, $Stoploc, $Score, $Status, $Date, $iprsAccession, $iprsDescription, $GO, $Pathways) = split( /\t/, $line );
        if ((!$GO eq "") && ( (looks_like_number($Score)) && ($Score < 0.00000000001)))
    {
        push (@all, ["$ProteinAccession","$GO"]) # PUSH INTO ARRAY
        }
}

###################
# SUBROUTINE CREATE UNIQUE ROW
###################

sub unique {
     my %seen;
     grep ! $seen{ join $;, @$_ }++, @_
}


my @some = unique(@all);

# for my $row (@some) {
#     #print join("\t", @{$row}), "\n";
#     my ($seqNAME,$GOID) = split /\t/, $row;
#     print $row."\n";
# }

print Dumper (\@some);
# foreach my $row (@some) {
#   my ($seqNAME,$GOID) = split /,/, @$row;
# print $GOID."\n";
#     }