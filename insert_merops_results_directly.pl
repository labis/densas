use strict;
use warnings;
#use Text::CSV::Simple;
use Getopt::Long;
use Data::Dumper;
use Cwd qw();
use File::Basename;
use DBI;
use DBD::mysql;

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

#########################
#Conects to the database
#########################

my $dbh = DBI->connect("dbi:mysql:$database:$host:$port", "$user", "$pw",
                    { RaiseError => 1, AutoCommit => 1 });

##################################
# set the value of your SQL query
##################################

my $query = "INSERT INTO  $PRJ\_MEROPS (Seqname, mernum , pident, evalue, bitscore) VALUES (?,?,?,?,?)";

# prepare your statement for connecting to the database
my $sth = $dbh->prepare($query);

##########################
#Insert data into database
##########################
open (FILE, $infile);

while (<FILE>) {
chomp;
my ($seqname, $mernun, $pident, $dumb, $dumb2, $dumb3, $dumb4, $dumb5, $dumb6, $dumb7, $evalue, $bitscore) = split("\t");
#my ($locus1, $descarta) = split(/\./, $locus);
print "$seqname\t$mernun\t$pident\t$evalue\t$bitscore\n";
$sth->execute($seqname,$mernun,$pident,$evalue,$bitscore) or die "Query failed: $!";

} # fecha looping no arquivo e insere
#
print "All clear, closing here!";
$dbh->disconnect();
