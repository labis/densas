use strict;
use warnings;
#use Text::CSV::Simple;
use Getopt::Long;
use Data::Dumper;
use Cwd qw();
use File::Basename;

####################
#GET THE CONFIG FILE
####################

my $name = basename($0);
my ($real_path) = Cwd::abs_path($0)  =~ m/(.*)$name/i;
require "$real_path/config.pl";

####################
#Get all the options
####################

our ($platform, $database, $host, $port, $user, $pw, $split_seqs, $rundir, $PRJ, $blast_run, $rfam_run, $PFAM_run, $DNSASDIR);


my ($infile,$PRJ);
    GetOptions ('infile=s' => \$infile, 'prj=s' => \$PRJ);
    if ((!$PRJ) || (!$infile)) {
    print "Some required arguments are missing.\nYou must use this as follow:\n$0 --prj PROJECT -i MEROPS_RESULT.TSV\n";
    exit 1
}

##########################
#Insert data into database
##########################
open (FILE, $infile);

while (<FILE>) {
chomp;
my ($seqname, $mernun, $pident, $dumb, $dumb2, $dumb3, $dumb4, $dumb5, $dumb6, $dumb7, $evalue, $bitscore) = split("\t");
#my ($locus1, $descarta) = split(/\./, $locus);
print "$seqname\t$mernun\t$pident\t$evalue\t$bitscore\n";

} # fecha looping no arquivo e insere
#
