#!/opt/perl/bin/perl -w
##!/usr/bin/perl -w
use strict;
use warnings;

our ($platform, $database, $host, $port, $user, $pw, $split_seqs, $rundir, $PRJ, $blast_run, $rfam_run, $PFAM_run, $DNSASDIR);

#####################
#CONFIG DB VARIABLES
#####################

$platform = "mysql";
$database = "densas";
$host = "143.106.4.87";
#$host = "localhost";
$port = "3306";
$user = "annotate";
$pw = "b10ine0!";

####################
#CONFIG DENSAS OPTIONS
####################

$split_seqs=1000;
$rundir = "./DENSAS_an";
$PRJ = "DENSAS";
$blast_run = "run_blast_DeNSAS.sh";
$rfam_run = "run_Rfam_DeNSAS.sh";
$PFAM_run = "run_Pfam_DeNSAS.sh";
$DNSASDIR = "/home/mmbrand/DeNSAS/";
