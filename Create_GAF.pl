#!/usr/bin/perl -w
use strict;
use DBI;
use DateTime;

# CONFIG VARIABLES
my $st_time = time(); # set the starting time for calculation
my $platform = "mysql";
my $database = "midgutomics";
my $host = "143.106.4.249";
my $port = "3306";
my $user = "annotate";
my $pw = "b10ine0!";
#my $fstFILE   = $ARGV[0];
    my $usage = "You must use this as follow:\n perl Create_GAF.pl [PROJ NAME] [TAXID]\n";
    my $PROJ_NAME = shift or die $usage;
    my $taxID = shift or die $usage;
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
    #All variables
    my $COL1 = "MidgutDB";
    #my $COL2 = '';
    #my $COL3 = '';
    my $COL4 = "";
    #my $COL5 = "";
    my $COL6 = "DB:MidgutDB";
    my $COL7 = "IEA";
    my $COL8 = "";
    #my $COL9 = "";
    my $COL10 = "";
    my $COL11 = "";
    my $COL12 = "Transcript";
    my $COL13 = "taxon:$taxID";
    my $COL14 = DateTime->now(time_zone => "local")->ymd('');
    my $COL15 = "LABIS";
    my $COL16 = "";
    my $COL17 = "";


#Conects to the MySQL database
my $dbh = DBI->connect("dbi:mysql:$database:$host:$port", "$user", "$pw",
                    { RaiseError => 1, AutoCommit => 0 });

  my $CREATEGAF = $dbh->selectall_arrayref("
SELECT
  Description.Seqname,
  Description.`Desc`,
  Annotation.GOID,
  CASE WHEN Annotation.Aspect = 'B' THEN 'P' WHEN Annotation.Aspect = 'M' THEN 'F' WHEN Annotation.Aspect = 'C' THEN 'C' END AS category
FROM (SELECT
    Description.Seqname,
    Description.`Desc`
  FROM Description
  WHERE Description.Seqname LIKE '%".$PROJ_NAME."%') Description
  INNER JOIN Annotation
    ON Description.Seqname = Annotation.Seqname
    
")
  or die "print unable to connect to the DB";

open(my $fh, '>', $PROJ_NAME.".gaf"); # Open file to write
  #Start creating the file
  print $fh "!gaf-version: 2.0\n";
foreach my $row (@$CREATEGAF) {
     my ($COL2, $COL3, $COL5, $COL9) = @$row;
     print "col2 = $COL2, col3 = $COL3, col 5 = $COL5, col 9 = $COL9\n";
     print $fh "$COL1\t$COL2\t$COL3\t$COL4\t$COL5\t$COL6\t$COL7\t$COL8\t$COL9\t$COL10\t$COL11\t$COL12\t$COL13\t$COL14\t$COL15\t$COL16\t$COL17\n";
     }
close $fh; # close file to write
    my $endtime = time();
    my $runtime = $endtime - $st_time;
    print "The file $PROJ_NAME\.gaf was created in $runtime seconds.\nNice job!\n"
