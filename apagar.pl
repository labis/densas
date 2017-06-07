#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use Cwd qw();
use File::Basename;

####################
#GET THE CONFIG FILE
####################

my $name = basename($0);
my ($real_path) = Cwd::abs_path($0)  =~ m/(.*)$name/i;
require "$real_path/config.pl";

my $strtTIME = time() / 60;
my $seqCOUNT = 1;
my ($infile,$PRJ);
    GetOptions ('infile=s' => \$infile, 'prj=s' => \$PRJ);
    if ((!$PRJ) || (!$infile)) {
    print "Some required arguments are missing.\nYou must use this as follow:\n$0 --prj PROJECT --infile [ FASTA HEADER FILE ]\n";
    exit 1
}
open FILE, $infile or die $!;
open(my $descFILE, '>', "$PRJ\_DESCApagar.txt");

#Start looping the fasta file
while (my $fstHEADER = <FILE>) {
print $descFILE $fstHEADER;
my $a = 0;
do{
   $a = $a + 1;
}while( $a < 2000 );
$seqCOUNT ++; # COUNT NUMBER OF SEQUENCES
} #close while loop
close(FILE);
close $descFILE;
my $difTIME = (time()/60) - $strtTIME;
my $seqTIME = $seqCOUNT / $difTIME;
print "Sequences per time ".$seqTIME."\n";
