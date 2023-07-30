use strict;
use warnings;
#use Text::CSV::Simple;
use Getopt::Long;
use Data::Dumper;
use DBI;
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

# # CONFIG VARIABLES
# my $platform = "mysql";
# my $database = "annotate";
# my $host = "143.106.4.249";
# #my $host = "localhost";
# my $port = "3306";
# my $user = "annotate";
# my $pw = "b10ine0!";

#Conects to the SQLite database
my $dbh = DBI->connect("dbi:mysql:$database:$host:$port", "$user", "$pw",
                    { RaiseError => 1, AutoCommit => 0 });

##################################
#Check is the table is in the bank
##################################

my $Check_table = $dbh->selectall_arrayref("show tables like '$PRJ\_MEROPS'")
or die "print unable to connect to the DB";

if (scalar(@$Check_table) == 0) {
print "Table Does not exists, creating\n"; #check if The table exists
$dbh->do("
CREATE TABLE `$PRJ\_MEROPS` (
  `MeropsID` int(11) NOT NULL AUTO_INCREMENT,
  `Seqname` varchar(50) DEFAULT NULL,
  `mernum` varchar(50) DEFAULT NULL COMMENT 'MEROPS number',
  `pident` double DEFAULT NULL COMMENT 'Percentage of identical matches',
  `evalue` double DEFAULT NULL COMMENT ' Expect value',
  `bitscore` double DEFAULT NULL COMMENT 'Bitscore from blast',
  PRIMARY KEY (`MeropsID`),
  KEY `IDX_MEROPS` (`Seqname`,`mernum`),
  KEY `pident` (`pident`),
  KEY `evalue` (`evalue`),
  KEY `Seqname` (`Seqname`),
  KEY `evalue_2` (`evalue`),
  KEY `pident_2` (`pident`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 AVG_ROW_LENGTH=83 COMMENT='Merops Blast results';

");
  $dbh->commit();
} else {
print "Table ok! Continuing MEROPS\n";
}

##########################
#Insert data into database
##########################
open (FILE, $infile);
$dbh->commit();    
while (<FILE>) {
chomp;
my ($seqname, $mernun, $pident, $dumb, $dumb2, $dumb3, $dumb4, $dumb5, $dumb6, $dumb7, $evalue, $bitscore) = split("\t");
#my ($locus1, $descarta) = split(/\./, $locus);
$dbh->do("INSERT INTO  $PRJ\_MEROPS (Seqname, mernum , pident, evalue, bitscore) VALUES ('$seqname', '$mernun', '$pident', '$evalue', '$bitscore')");
  $dbh->commit();
#
} # fecha looping no arquivo e insere
#
print "Done!";
$dbh->disconnect();
