#!/thunderstorm/perl5/perls/perl-5.18.1/bin/perl -w
use strict;
use DBI;
use Getopt::Long;
my ($infile,$PRJ);
    GetOptions ('infile=s' => \$infile, 'prj=s' => \$PRJ);
    if ((!$PRJ) || (!$infile)) {
    print "Some required arguments are missing.\nYou must use this as follow:\n$0 --prj PROJECT --infile FASTA\n";
    exit 1
}


# CONFIG VARIABLES
my $platform = "mysql";
my $database = "annotate";
my $host = "143.106.4.249";
my $port = "3306";
my $user = "annotate";
my $pw = "b10ine0!";

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
  gene_info.description
FROM (SELECT
    $PRJ\_blastRESULTS.Seqname,
    $PRJ\_blastRESULTS.seqGI,
    $PRJ\_blastRESULTS.seqACC,
    $PRJ\_blastRESULTS.pident,
    $PRJ\_blastRESULTS.evalue,
    $PRJ\_blastRESULTS.bitscore
  FROM $PRJ\_blastRESULTS
  WHERE $PRJ\_blastRESULTS.Seqname = '".$seqNAME_blst."' 
  AND $PRJ\_blastRESULTS.pident >= 40
  AND $PRJ\_blastRESULTS.evalue <= 1e-10
  GROUP BY $PRJ\_blastRESULTS.seqGI,
           $PRJ\_blastRESULTS.bitscore) SubQuery
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
     my ($Seqname, $tax_id, $desc_blst) = @$row;
     return " $desc_blst ($tax_id\)";
}
  
}
###END blastRES

sub meropsRES {
  my ($seqNAME_mrps) = @_; # Get the sequence name
  #Search the Blast results for seqName
  my $meropsRESDB = $dbh->selectall_arrayref("
SELECT
  $PRJ\_MEROPS.mernum,
  MEROPS_domain.code,
  MEROPS_domain.protein,
  MEROPS_domain.type
FROM $PRJ\_MEROPS
  INNER JOIN MEROPS_domain
    ON $PRJ\_MEROPS.mernum = MEROPS_domain.mernum
WHERE $PRJ\_MEROPS.Seqname = '".$seqNAME_mrps."'
GROUP BY MEROPS_domain.code
ORDER BY $PRJ\_MEROPS.pident DESC, $PRJ\_MEROPS.evalue
LIMIT 0, 1
")
  or die "print unable to connect to the DB";

# Test for no results
if (scalar(@$meropsRESDB) == 0) {
return "1"; #check if there is some information. If not set it as 1 and pass to the MEROPS annotation
}

foreach my $row (@$meropsRESDB) {
     my ($mernum, $code, $protein, $type) = @$row;
     return " $type: $protein ($mernum:$code)";
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
  $PRJ\_RFAM.rfam_acc
FROM $PRJ\_RFAM
  INNER JOIN RFAM
    ON $PRJ\_RFAM.rfam_id = RFAM.rfam_id
WHERE $PRJ\_RFAM.Seqname = '".$seqNAME_rfam."'
AND $PRJ\_RFAM.Full_sequence <= 0.00000000001
LIMIT 0, 1
")
  or die "print unable to connect to the DB";

# Test for no results
if (scalar(@$rfamRESDB) == 0) {
return "1"; #check if there is some information. If not set it as 1 and pass to the annotation
}

foreach my $row (@$rfamRESDB) {
     my ($desc, $rfamID, $rfamACC) = @$row;
     return " RFAM: $desc($rfamACC:$rfamID)";
}
  
}
###END rfamRES

sub pfamRES {
  my ($seqNAME_pfam) = @_; # Get the sequence name
  #Search the Blast results for seqName
  my $pfamRESDB = $dbh->selectall_arrayref("
SELECT
  pfamA.description,
  $PRJ\_PFAM.pfamA_id,
  $PRJ\_PFAM.pfamA_acc
FROM $PRJ\_PFAM
  INNER JOIN pfamA
    ON $PRJ\_PFAM.pfamA_id = pfamA.pfamA_id
WHERE $PRJ\_PFAM.Seqname = '".$seqNAME_pfam."'
AND $PRJ\_PFAM.Best_domain <= 0.00000000001
ORDER BY $PRJ\_PFAM.Full_sequence
LIMIT 0, 1
")
  or die "print unable to connect to the DB";

# Test for no results
if (scalar(@$pfamRESDB) == 0) {
return "1"; #check if there is some information. If not set it as 1 and pass to the annotation
}

foreach my $row (@$pfamRESDB) {
     my ($desc, $pfamID, $pfamACC) = @$row;
     return " PFAM: $desc($pfamACC:$pfamID)";
}
  
}
###END pfamRES

############################################# Routines END

open FILE, $infile or die $!;

#Start looping the fasta file
while (my $fstHEADER = <FILE>) {
  if ($fstHEADER =~ s/^>//) { # Get the header
    #$fstHEADER =~ s/^>(.*)\s+cov(.*)\n/\1/;
    my @fstDESC = split /\s/, $fstHEADER;
    #print $fstDESC[0]."\n"; #Just the first word
    print $fstDESC[0]."\t"; 
    my $blastRES1 = blastRES($fstDESC[0]); # call blastRES to check and mount blast description of the contig
    my $meropsRES1 = meropsRES($fstDESC[0]); # call meropsRES to mount peptidase annotation
    my $rfamRES1 = rfamRES($fstDESC[0]); # call rfamRES to mount RNA families annotation
    my $pfamRES1 = pfamRES($fstDESC[0]); # call rfamRES to mount Protein families annotation
    #check if there are some information to present
    #if both searchs does not return any results mark this as UNKNOWN ANNOTATION
    if (($blastRES1 eq  1) && ($meropsRES1 eq 1) && ($rfamRES1 eq 1) && ($pfamRES1 eq 1)) {
      print "UNKNOWN ANNOTATION";
    } else {
      unless ($blastRES1 eq 1) {
        print "$blastRES1";
      }
      unless ($meropsRES1 eq 1) {
       print $meropsRES1;
      }
      unless ($rfamRES1 eq 1) {
      print $rfamRES1;
      }
      unless ($pfamRES1 eq 1) {
      print $pfamRES1;
      }
    } #close if there are results from blast and merops
    print "\n"; #new line
  } #close if header
} #close while loop
close(FILE);
