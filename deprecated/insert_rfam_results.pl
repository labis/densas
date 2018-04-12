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
    print "Some required arguments are missing.\nYou must use this as follow:\n$0 --prj PROJECT\n";
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

my $Check_table = $dbh->selectall_arrayref("show tables like '$PRJ\_RFAM'")
or die "print unable to connect to the DB";

if (scalar(@$Check_table) == 0) {
print "Table Does not exists, creating\n"; #check if The table exists
$dbh->do("
CREATE TABLE `$PRJ\_RFAM`(
  `rfamID` int(11) NOT NULL AUTO_INCREMENT,
  `Seqname` varchar(50) DEFAULT NULL,
  `rfam_id` varchar(50) DEFAULT NULL,
  `rfam_acc` varchar(50) DEFAULT NULL,
  `Best_domain` double DEFAULT NULL,
  `Full_sequence` double DEFAULT NULL,
  PRIMARY KEY (`rfamID`),
  KEY `IDX_SPDK_RFAM_Seqname` (`Seqname`),
  KEY `Full_sequence` (`Full_sequence`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
");
  $dbh->commit();
} #else {
print "Table ok! Continuing RFAM\n";
#}

##########################
#Insert data into database
##########################

open (FILE, $infile);
$dbh->commit();    
while (<FILE>) {
chomp;
my ($seqname, $rfamA_id, $Description, $rfamA_acc, $Best_domain, $Full_sequence) = split("\t");

#print "$seqname\t$seqGI\t$seqACC\t$pident\t$evalue\t$bitscore\n";
$dbh->do("INSERT INTO  $PRJ\_RFAM (Seqname, rfam_id, rfam_acc, Best_domain, Full_sequence) VALUES ('$seqname', '$rfamA_id', '$rfamA_acc', '$Best_domain', '$Full_sequence')");
  $dbh->commit();

} # fecha looping no arquivo e insere
#
print "All clear, closing here!";
$dbh->disconnect();
