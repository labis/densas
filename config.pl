#!/opt/perl/bin/perl -w
##!/usr/bin/perl -w
use strict;
use warnings;

our ($platform, $database, $host, $port, $user, $pw, $split_seqs, $rundir, $PRJ, $blast_run, $rfam_run, $PFAM_run, $DNSASDIR, $IPRS_run, $ncpus_blast, $ncpus_insert, $ncpus_hmm, $qname, $soft_aria, $soft_transdecoder, $soft_hmmscan, $soft_diamond, $soft_pfam_db, $soft_rfam_db, $soft_diamond_refseq, $soft_diamond_merops, $soft_interproscan,$soft_python3);

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

######################
#CONFIG DENSAS OPTIONS
######################

$split_seqs=1000;
$rundir = "./DENSAS_an";
$PRJ = "DENSAS";
$blast_run = "run_blast_DeNSAS.sh";
$rfam_run = "run_Rfam_DeNSAS.sh";
$PFAM_run = "run_Pfam_DeNSAS.sh";
$DNSASDIR = "/home/mmbrand/Experimentos/DeNSAS/";
$IPRS_run = "run_iprs_DeNSAS.sh";

#######################
#CONFIG QUEUE VARIABLES
#######################

$ncpus_blast=12;
$ncpus_insert=2;
$ncpus_hmm=4;
$qname="all.q";

#########################
#CONFIG SOFTWARE LOCATION
#########################

$soft_aria="/usr/bin/aria2c";
$soft_transdecoder="/share/thunderstorm/programs/miniconda2/envs/DeNSAS/bin";
$soft_hmmscan="/share/thunderstorm/programs/miniconda2/envs/DeNSAS/bin/hmmscan";
$soft_diamond="/share/thunderstorm/programs/miniconda2/envs/DeNSAS/bin/diamond";
$soft_pfam_db="/state/partition1/DBs/pfam/Pfam-A.hmm";
$soft_rfam_db="/state/partition1/DBs/rfam/Rfam.hmm";
$soft_diamond_refseq="/state/partition1/DBs/blastdb/refseq_DIAMOND";
$soft_diamond_merops="/state/partition1/DBs/blastdb/MEROPS_diamond";
$soft_interproscan="/share/thunderstorm/programs/interproscan-5.35-74.0/interproscan.sh";
$soft_python3="/share/thunderstorm/programs/miniconda2/envs/interproscan/bin/"