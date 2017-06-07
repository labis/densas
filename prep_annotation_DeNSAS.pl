#!/opt/perl/bin/perl -w
##!/usr/bin/perl -w
use Getopt::Long;
use strict;
use DBI;

####################
#Get all the options
####################

my $split_seqs=1000;
my $count=0;
my $filenum=0;
my $len=0;
my $rundir = "./DENSAS_an";
my $PRJ = "DENSAS";
my $infile = "";
my $blast_run = "run_blast_DeNSAS.sh";
my $rfam_run = "run_Rfam_DeNSAS.sh";
my $PFAM_run = "run_Pfam_DeNSAS.sh";
my $filename;
my $DNSASDIR = "/home/mmbrand/annotate/Runscripts/";

GetOptions ('split=s' => \$split_seqs,
            'rundir=s' => \$rundir,
            'prj=s' => \$PRJ,
            'infile=s' => \$infile,
            );

# ###################################            
# # CHECK IF ALL VARIABLES ARE THERE
# ###################################
if ((!$split_seqs) || (!$rundir) || (!$PRJ) || (!$infile)) {
print "Some required arguments are missing.\nYou must use this as follow:\n$0 --split [number of sequences/file] --rundir [/where/to/output/results/ ] --prj [ PROJECT ] --infile [ FASTA FILE ]\n";
exit 1
}
            
my $fastadir = "$rundir/fasta"; 
my $out_template="${PRJ}_NUMBER.fasta";

#####################
#CONFIG DB VARIABLES
#####################


my $platform = "mysql";
my $database = "annotate";
my $host = "143.106.4.249";
#my $host = "localhost";
my $port = "3306";
my $user = "annotate";
my $pw = "b10ine0!";

#Conects to the SQLite database
my $dbh = DBI->connect("dbi:mysql:$database:$host:$port", "$user", "$pw",
                    { RaiseError => 1, AutoCommit => 0 });
                    

##################################
#CHECK IF THE PROJECT NAME EXISTS
##################################

my $Check_PRJ = $dbh->selectall_arrayref("show tables like '$PRJ%'")
or die "print unable to connect to the DB";                    
                    
if (scalar(@$Check_PRJ) == 0) {
print "The project name $PRJ is available, Let's continue\n";

###########################
#CREATE TABLE BLASTresults
###########################

print "Finding a place for your similarity search\n";
$dbh->do("
CREATE TABLE IF NOT EXISTS `$PRJ\_blastRESULTS` (
  `blstRSLTSID` int(11) NOT NULL AUTO_INCREMENT,
  `Seqname` varchar(50) DEFAULT NULL,
  `seqGI` varchar(50) DEFAULT NULL COMMENT 'GI number',
  `seqACC` varchar(50) DEFAULT NULL COMMENT 'Access number',
  `pident` double DEFAULT NULL COMMENT 'Percentage of identical matches',
  `evalue` double DEFAULT NULL COMMENT ' Expect value',
  `bitscore` double DEFAULT NULL COMMENT 'Bitscore from blast',
  PRIMARY KEY (`blstRSLTSID`),
  KEY `IDX_blastRSLTS` (`Seqname`,`seqGI`,`seqACC`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
");
  $dbh->commit();

###########################
#CREATE TABLE EXISTS MEROPS_results
###########################

print "Building a home for the MEROPS search\n";

$dbh->do("
CREATE TABLE IF NOT EXISTS `$PRJ\_MEROPS` (
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

###########################
#CREATE TABLE PFAM_results
###########################

print "PFAM, where you lay your head is home\n";

$dbh->do("
CREATE TABLE IF NOT EXISTS `$PRJ\_PFAM`(
  `pfamID` int(11) NOT NULL AUTO_INCREMENT,
  `Seqname` varchar(50) DEFAULT NULL,
  `pfamA_id` varchar(50) DEFAULT NULL,
  `pfamA_acc` varchar(50) DEFAULT NULL,
  `Best_domain` double DEFAULT NULL,
  `Full_sequence` double DEFAULT NULL,
  PRIMARY KEY (`pfamID`),
  KEY `Seqname` (`Seqname`),
  KEY `Full_sequence` (`Full_sequence`),
  KEY `pfamA_acc` (`pfamA_acc`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
");
  $dbh->commit();

###########################
#CREATE TABLE RFAM_results
###########################

print "Building a storage for RFAM\n";

$dbh->do("
CREATE TABLE IF NOT EXISTS `$PRJ\_RFAM`(
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
  
  ##############################
  # CLOSE IF TABLE DO NOT EXIST
  ##############################
  
  } else {
  
  ##############################
  # BE NICE AND EXIT
  ##############################

die "Sorry, the project name $PRJ was already choosen :(\nBut, no fear just choose another one ;)\n";
}

                   

##########################
#create Directories rundir
##########################

unless(-d $rundir){
    mkdir $rundir;
    print "Creating directory $rundir\n"
}

#############################
#create Directories fastadir
#############################

unless(-d $fastadir){
    mkdir $fastadir;
    print "Creating directory $fastadir\n";
}

#####################################
#Open infile and split all sequences
#####################################

print "starting project name ${PRJ}\n";

open(my $fh, $infile)
  or die "Could not open file '$infile' $!";
 
while (<$fh>) {
    s/\r?\n//;
    if (/^>/) {
	if ($count % $split_seqs == 0) {
	    $filenum++;
	    $filename = $out_template;
	    $filename =~ s/NUMBER/$filenum/g;
	    print "Creating file $filename\n";
	    if ($filenum > 1) {
		close SHORT;
		
	    }
	    open (SHORT, ">$fastadir/$filename") or die $!;
	    
	}
	$count++;
	
    }
    else {
    $len += length($_)
    }
    $_ =~ s/\(\+\)/sen/g;
    print SHORT "$_\n";
}
close(SHORT);

warn "\nSplit $count FASTA records in $. lines, with total sequence length $len\nCreated $filenum files like $filename\n\n";
print "Sending to the queue system\n";
# print "qsub -t 1-${filenum} ${DNSASDIR}/$blast_run -N ${PRJ}_blast -d ./ -o $rundir/OUT/BLAST.out -v 'RUNDIR=$rundir, FSTDIR=$fastadir, DNSASDIR=$DNSASDIR, PRJ=$PRJ, where=2'\n";
# print "qsub -t 1-${filenum} ${DNSASDIR}/$blast_run -N ${PRJ}_blast -d ./ -o $rundir/OUT/MEROPSout -v 'RUNDIR=$rundir, FSTDIR=$fastadir, DNSASDIR=$DNSASDIR, PRJ=$PRJ, where=4'\n";
# print "qsub -t 1-${filenum} ${DNSASDIR}/$rfam_run -N ${PRJ}_rfam -d ./ -o $rundir/OUT/RFAM.out -v 'RUNDIR=$rundir, FSTDIR=$fastadir, DNSASDIR=$DNSASDIR, PRJ=$PRJ'\n";
# print "qsub -t 1-${filenum} ${DNSASDIR}/$PFAM_run -N ${PRJ}_pfam -d ./ -o $rundir/OUT/PFAM.out -v 'RUNDIR=$rundir, FSTDIR=$fastadir, DNSASDIR=$DNSASDIR, PRJ=$PRJ'\n";
my $result_blast = system("qsub -t 1-${filenum} ${DNSASDIR}/$blast_run -N ${PRJ}_blast -d ./ -o $rundir/OUT/BLAST.out -v 'RUNDIR=$rundir, FSTDIR=$fastadir, DNSASDIR=$DNSASDIR, PRJ=$PRJ, where=2'");
my $result_MEROPS = system("qsub -t 1-${filenum} ${DNSASDIR}/$blast_run -N ${PRJ}_blast -d ./ -o $rundir/OUT/MEROPSout -v 'RUNDIR=$rundir, FSTDIR=$fastadir, DNSASDIR=$DNSASDIR, PRJ=$PRJ, where=4'");
my $result_RFAM = system("qsub -t 1-${filenum} ${DNSASDIR}/$rfam_run -N ${PRJ}_rfam -d ./ -o $rundir/OUT/RFAM.out -v 'RUNDIR=$rundir, FSTDIR=$fastadir, DNSASDIR=$DNSASDIR, PRJ=$PRJ'");
my $result_PFAM = system("qsub -t 1-${filenum} ${DNSASDIR}/$PFAM_run -N ${PRJ}_pfam -d ./ -o $rundir/OUT/PFAM.out -v 'RUNDIR=$rundir, FSTDIR=$fastadir, DNSASDIR=$DNSASDIR, PRJ=$PRJ'");
#print "Blast is running under $result_blast and RFAM under $result_RFAM";
# 
print "Done\n Have a nice day \;)\n";
my $RUNDIR = $rundir;
my $BLSTDIR="$RUNDIR/blastXML";
my $MRPSDIR="$RUNDIR/MEROPS";
my $PFAMDIR="$RUNDIR/PFAM";
my $RFAMDIR="$RUNDIR/RFAM";
my $FSTDIR="$RUNDIR/fasta";
print "qsub ${DNSASDIR}/run_insert_results_DeNSAS.sh -t 1-${filenum}%3 -N ${PRJ}_inDIAM -d ./ -o $RUNDIR/OUT/Insert_BLASTDiamon.out -v 'RUNDIR=$RUNDIR, DNSASDIR=$DNSASDIR, PRJ=$PRJ, where=2'\n";
print "qsub ${DNSASDIR}/run_insert_results_DeNSAS.sh -t 1-${filenum}%3 -N ${PRJ}_inMRPS -d ./ -o $RUNDIR/OUT/Insert_MEROPSDiamon.out -v 'RUNDIR=$RUNDIR, DNSASDIR=$DNSASDIR, PRJ=$PRJ, where=3'\n";
print "qsub ${DNSASDIR}/run_insert_results_DeNSAS.sh -t 1-${filenum}%3 -N ${PRJ}_inPFAM -d ./ -o $RUNDIR/OUT/Insert_PFAM.out -v 'RUNDIR=$RUNDIR, DNSASDIR=$DNSASDIR, PRJ=$PRJ, where=4'\n";
print "qsub ${DNSASDIR}/run_insert_results_DeNSAS.sh -t 1-${filenum}%3 -N ${PRJ}_inRFAM -d ./ -o $RUNDIR/OUT/Insert_RFAM.out -v 'RUNDIR=$RUNDIR, DNSASDIR=$DNSASDIR, PRJ=$PRJ, where=5'\n";
