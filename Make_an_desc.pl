#!/thunderstorm/perl5/perls/perl-5.18.1/bin/perl -w
use strict;
use DBI;
use Getopt::Long;
use Cwd qw();
use File::Basename;
use POSIX;
use 5.010;
use warnings;
use Term::ANSIColor qw(:constants);
$Term::ANSIColor::AUTORESET = 1; # auto reset colors


####################
#GET THE CONFIG FILE
####################

my $name = basename($0);
my ($real_path) = Cwd::abs_path($0)  =~ m/(.*)$name/i;
require "$real_path/config.pl";


# Define blast indentity
my $pidentBL = 40;
# Define blast e-Value
my $evalueBL = 0.00000000001;

my ($rundir,$PRJ);
    GetOptions ('rundir=s' => \$rundir, 
                'prj=s' => \$PRJ,
                'idt=s' => \$pidentBL,
                'evl=s' => \$evalueBL);
    if ((!$PRJ) || (!$rundir)) {
    print BOLD RED "Some required arguments are missing.\nYou must use this as follow:\n";
    print BOLD MAGENTA "$0 --prj PROJECT --rundir /PATH/TO/THE/RUNDIR/ --idt [ BLAST SEQUENCE SIMILARITY ] --evl [ BLAST EVALUE ] \n";
    exit 1
}

################################
#TEST IF THE HEADER FILE EXISTS
################################

unless (-e "$rundir/$PRJ\_header.txt") {
  
  die BOLD RED "Dammit Lab Goblins!! Something is terribly wrong!\nI could not find the Header file in $rundir/EXP_$PRJ\_header.txt.\nPlease check where is this file and try again\n";
}


###################
# CONFIG VARIABLES
###################
# all will came from config.pl
our ($platform, $database, $host, $port, $user, $pw, $split_seqs, $blast_run, $rfam_run, $PFAM_run, $DNSASDIR);
my $seqNUM = 1; #count the number of sequences
my $runtime;

################
# CONFIG TIMING
################
my $strtTIME = time;
sub timing{
  my ($seqN) = @_; # Get the uniprot ACC to consult
  my $endtime = time;
  my $difTIME = ($endtime - $strtTIME);
  
  if ($difTIME > 60) {
    $runtime = floor($seqN / $difTIME);
     } else {
    $runtime = "60";
  }
  return $runtime;
    }

#Conects to the MySQL database
my $dbh = DBI->connect("dbi:mysql:$database:$host:$port", "$user", "$pw",
                    { RaiseError => 1, AutoCommit => 0 });    

############################################# Routines
sub blastRES {
  my ($seqNAME_blst) = @_; # Get the sequence name
  my $noBLSTRES = ();
  #Search the Blast results for seqName
  my $blastRESDB = $dbh->selectall_arrayref("
SELECT
  SubQuery.Seqname,
  gene2accession.tax_id,
  gene_info.description,
  gene_info.symbol
FROM (SELECT
    EXP_$PRJ\_blastRESULTS.Seqname,
    EXP_$PRJ\_blastRESULTS.seqACC,
    EXP_$PRJ\_blastRESULTS.pident,
    EXP_$PRJ\_blastRESULTS.evalue,
    EXP_$PRJ\_blastRESULTS.bitscore
  FROM EXP_$PRJ\_blastRESULTS
  WHERE EXP_$PRJ\_blastRESULTS.Seqname = '".$seqNAME_blst."' 
  AND EXP_$PRJ\_blastRESULTS.pident >= $pidentBL
  AND EXP_$PRJ\_blastRESULTS.evalue <= $evalueBL
  GROUP BY EXP_$PRJ\_blastRESULTS.seqACC,
           EXP_$PRJ\_blastRESULTS.bitscore) SubQuery
  INNER JOIN gene2accession
    ON SubQuery.seqACC = gene2accession.protein_accession
  INNER JOIN gene_info
    ON gene2accession.GeneID = gene_info.GeneID
  INNER JOIN species
    ON gene_info.tax_id = species.ncbi_taxa_id
GROUP BY gene_info.description,
         SubQuery.evalue,
         SubQuery.pident,
         SubQuery.bitscore
ORDER BY SubQuery.bitscore DESC, SubQuery.pident DESC, SubQuery.evalue
LIMIT 0, 1
")
  or die "print unable to connect to the DB";

# Test for no results
if (scalar(@$blastRESDB) == 0) {
  return "1"; #check if there is some information. If not set it as 1 and pass to the MEROPS annotation
}

foreach my $row (@$blastRESDB) {
     my ($Seqname, $tax_id, $desc_blst,$symbol) = @$row;
     return "$desc_blst ($symbol\) [taxid: $tax_id] ";
}
  
}
###END blastRES

sub meropsRES {
  my ($seqNAME_mrps) = @_; # Get the sequence name
  #Search the Blast results for seqName
  my $meropsRESDB = $dbh->selectall_arrayref("
SELECT
  EXP_$PRJ\_MEROPS.mernum,
  MEROPS_domain.code,
  MEROPS_domain.protein,
  MEROPS_domain.type
FROM EXP_$PRJ\_MEROPS
  INNER JOIN MEROPS_domain
    ON EXP_$PRJ\_MEROPS.mernum = MEROPS_domain.mernum
WHERE EXP_$PRJ\_MEROPS.Seqname = '".$seqNAME_mrps."'
GROUP BY MEROPS_domain.code
ORDER BY EXP_$PRJ\_MEROPS.pident DESC, EXP_$PRJ\_MEROPS.evalue
LIMIT 0, 1
")
  or die "print unable to connect to the DB";

# Test for no results
if (scalar(@$meropsRESDB) == 0) {
return "1"; #check if there is some information. If not set it as 1 and pass to the MEROPS annotation
}

foreach my $row (@$meropsRESDB) {
     my ($mernum, $code, $protein, $type) = @$row;
     return "$type: $protein ($mernum:$code) ";
}
  
}
###END meropsRES

sub rfamRES {
  my ($seqNAME_rfam) = @_; # Get the sequence name
  #Search the Blast results for seqName
  my $rfamRESDB = $dbh->selectall_arrayref("
SELECT
  RFAM.description,
  RFAM.rfam_id,
  EXP_$PRJ\_RFAM.rfam_acc
FROM EXP_$PRJ\_RFAM
  INNER JOIN RFAM
    ON EXP_$PRJ\_RFAM.rfam_id = RFAM.rfam_id
WHERE EXP_$PRJ\_RFAM.Seqname = '".$seqNAME_rfam."'
AND EXP_$PRJ\_RFAM.Full_sequence <= 0.00000000001
LIMIT 0, 1
")
  or die "print unable to connect to the DB";

# Test for no results
if (scalar(@$rfamRESDB) == 0) {
return "1"; #check if there is some information. If not set it as 1 and pass to the annotation
}

foreach my $row (@$rfamRESDB) {
     my ($desc, $rfamID, $rfamACC) = @$row;
     return "RFAM: $desc($rfamACC:$rfamID) ";
}
  
}
###END rfamRES

sub pfamRES {
  my ($seqNAME_pfam) = @_; # Get the sequence name
  #Search the Blast results for seqName
  my $pfamRESDB = $dbh->selectall_arrayref("
SELECT
  pfamA.description,
  EXP_$PRJ\_PFAM.pfamA_id,
  EXP_$PRJ\_PFAM.pfamA_acc
FROM EXP_$PRJ\_PFAM
  INNER JOIN pfamA
    ON EXP_$PRJ\_PFAM.pfamA_id = pfamA.pfamA_id
WHERE EXP_$PRJ\_PFAM.Seqname = '".$seqNAME_pfam."'
AND EXP_$PRJ\_PFAM.Best_domain <= 0.00000000001
ORDER BY EXP_$PRJ\_PFAM.Full_sequence
LIMIT 0, 1
")
  or die "print unable to connect to the DB";

# Test for no results
if (scalar(@$pfamRESDB) == 0) {
return "1"; #check if there is some information. If not set it as 1 and pass to the annotation
}

foreach my $row (@$pfamRESDB) {
     my ($desc, $pfamID, $pfamACC) = @$row;
     return "PFAM: $desc($pfamACC:$pfamID) ";
}
  
}
###END pfamRES

############################################# Routines END

# Count the number of lines on the header file

open FILECOUNT, "$rundir/$PRJ\_header.txt" or die $!;
my $lines = 0;
$lines++ while <FILECOUNT>;
close(FILECOUNT);

#Open file header for looping

open FILE, "$rundir/$PRJ\_header.txt" or die $!;
open(my $descFILE, '>', "$rundir/$PRJ\_DESC.txt");
#Start looping the fasta file
while (my $fstHEADER = <FILE>) {
    $fstHEADER =~ s/\n//g;
#     print $fstHEADER."\n"; #Just the first word
    print $descFILE $fstHEADER."\t"; 
    my $blastRES1 = blastRES($fstHEADER); # call blastRES to check and mount blast description of the contig
    my $meropsRES1 = meropsRES($fstHEADER); # call meropsRES to mount peptidase annotation
    my $rfamRES1 = rfamRES($fstHEADER); # call rfamRES to mount RNA families annotation
    my $pfamRES1 = pfamRES($fstHEADER); # call rfamRES to mount Protein families annotation
    #check if there are some information to present
    #if both searchs does not return any results mark this as UNKNOWN ANNOTATION
    if (($blastRES1 eq  1) && ($meropsRES1 eq 1) && ($rfamRES1 eq 1) && ($pfamRES1 eq 1)) {
      print $descFILE "UNKNOWN ANNOTATION";
    } else {
      unless ($blastRES1 eq 1) {
        print $descFILE "$blastRES1";
      }
      unless ($meropsRES1 eq 1) {
       print $descFILE $meropsRES1;
      }
      unless ($rfamRES1 eq 1) {
      print $descFILE $rfamRES1;
      }
      unless ($pfamRES1 eq 1) {
      print $descFILE $pfamRES1;
      }
    } #close if there are results from blast and merops
    print $descFILE "\n"; #new line
    $seqNUM ++; #COUNT SEQS
    #print some statistics
    my $seqDONE = floor(( $seqNUM / $lines) * 100);
    my $seqETA = floor(( $lines - $seqNUM ) / timing($seqNUM));
    print BOLD BLUE "  $seqDONE% done running at ",timing($seqNUM)," sequences per minute, need more $seqETA minutes to finish         \r";
} #close while loop
close(FILE);
close $descFILE;

my $finalTIME = time() / 60;
my $finaltotTIME = $finalTIME - $strtTIME;
my $avrgTIME = $seqNUM / $finaltotTIME;
print BOLD BLUE "All done running in ",$finaltotTIME,"  minutes averaging ".$avrgTIME." sequences per minute\n";
