#!/usr/bin/perl -w
use strict;
use DBI;
use List::MoreUtils qw(uniq);
use List::Util qw(sum);
use Getopt::Long;
my ($fstFILE,$ANNOT_file,$PRJ);
    GetOptions ('infile=s' => \$fstFILE,'outfile=s' => \$ANNOT_file, 'prj=s' => \$PRJ);
    if ((!$PRJ) || (!$fstFILE)|| (!$ANNOT_file)) {
    print "Some required arguments are missing.\nYou must use this as follow:\n$0 --prj PROJECT --infile FASTA --outfile ANNOT file\n";
    exit 1
}


# CONFIG VARIABLES
my $st_time = time(); # set the starting time for calculation
my $platform = "mysql";
my $database = "annotate";
my $host = "143.106.4.249";
my $port = "3306";
my $user = "annotate";
my $pw = "b10ine0!";
#my $fstFILE   = $ARGV[0];
    #my $usage = "You must use this as follow:\n perl Make_an_GO.pl [fasta file] [ANNOT file]\n";
    #my $fstFILE = shift or die $usage;
    #my $ANNOT_file = shift or die $usage;

#Conects to the MySQL database
my $dbh = DBI->connect("dbi:mysql:$database:$host:$port", "$user", "$pw",
                    { RaiseError => 1, AutoCommit => 0 });

#################################SUB routines
sub blastRES {
  my ($seqNAME_blst) = @_; # Get the sequence name
  my $noBLSTRES = ();
  my @ALL_GO = ();
  #Search the Blast results for seqName
  my $blastRESDB = $dbh->selectall_arrayref("
SELECT
  gi2uniprot.UniprotKB_acc
FROM $PRJ\_blastRESULTS
  INNER JOIN gi2uniprot
    ON $PRJ\_blastRESULTS.seqGI = gi2uniprot.GI
WHERE AND $PRJ\_blastRESULTS.pident >= 40
AND $PRJ\_blastRESULTS.Seqname = '".$seqNAME_blst."'
")
  or die "print unable to connect to the DB";
  
 # Test for no results
# if (scalar(@$blastRESDB) == 0) {
#    return "1"; # This results has no UNIPROT equivalent
#}
 ### Deal with the results
 foreach my $row (@$blastRESDB) {
     my ($UNIPROT) = @$row;
     push(@ALL_GO, "'$UNIPROT'");
     }
my $EXP_UNIPROT = join( ',', @ALL_GO );  # create the in statement for GO search.
#UNIPROT2GO($EXP_UNIPROT,$seqNAME_blst);
return "$EXP_UNIPROT"; # do not return an output
  
}
############ End the sub blastRES

sub UNIPROT2GO {
    my ($UNIPROT_IDs,$seqNAME_blst) = @_; # Get the uniprot ACC to consult
    my @BLST_TO_GO;
    #print "$UNIPROT_IDs";
      #Search the Gene ontology database results for seqName
  my $UNI2GORESDB = $dbh->selectall_arrayref("
SELECT
  term.acc
FROM gene_product
  INNER JOIN dbxref
    ON gene_product.dbxref_id = dbxref.id
  INNER JOIN association
    ON gene_product.id = association.gene_product_id
  INNER JOIN term
    ON association.term_id = term.id
WHERE dbxref.xref_key IN (".$UNIPROT_IDs.")
")
  or die "print unable to connect to the DB";
  
  # Test for no results
   
foreach my $row (@$UNI2GORESDB) {
     my ($GO_RES) = @$row;
     my $TO_TO_GO = "$seqNAME_blst-$GO_RES";
     push(@BLST_TO_GO, $TO_TO_GO);
     #print "$seqNAME_blst\t$GO_RES\t$GO_CASE\n"; #print the GO search output
     
}
return @BLST_TO_GO;
########## End Blast search
}
########## End Sub UNIPROT2GO

sub RFAM2GO {
    my ($seqNAME_blst) = @_; # Get the uniprot ACC to consult
    my @RFAM_TO_GO;
    #Search the Gene ontology database results for seqName
  my $RFAM2GORESDB = $dbh->selectall_arrayref("
SELECT
  RFAM2GO.GO_ID
  FROM $PRJ\_RFAM
  INNER JOIN RFAM2GO
    ON $PRJ\_RFAM.rfam_acc = RFAM2GO.rfam_id
  INNER JOIN term
    ON RFAM2GO.GO_ID = term.acc
WHERE $PRJ\_RFAM.Seqname = '".$seqNAME_blst."'
GROUP BY $PRJ\_RFAM.rfam_acc,
         RFAM2GO.GO_ID,
         term.term_type
ORDER BY $PRJ\_RFAM.Full_sequence
")
  or die "print unable to connect to the DB";
  
  # Test for no results
   
foreach my $row (@$RFAM2GORESDB) {
     my ($GO_RES) = @$row;
     my $TO_TO_GO = "$seqNAME_blst-$GO_RES";
     push(@RFAM_TO_GO, $TO_TO_GO);
     #print "$seqNAME_blst\t$GO_RES\t$GO_CASE\n"; #print the GO search output
     
}
return @RFAM_TO_GO;
########## End Blast search
}
########## End Sub RFAM2GO

sub PFAM2GO {
    my ($seqNAME_blst) = @_; # Get the uniprot ACC to consult
    my @PFAM_TO_GO;
    #Search the Gene ontology database results for seqName
  my $PFAM2GORESDB = $dbh->selectall_arrayref("
SELECT
  pfamA2GO.go_id
  FROM $PRJ\_PFAM
  INNER JOIN pfamA2GO
    ON $PRJ\_PFAM.pfamA_acc = pfamA2GO.pfamA_acc
  INNER JOIN term
    ON pfamA2GO.go_id = term.acc
WHERE $PRJ\_PFAM.Seqname = '".$seqNAME_blst."'
GROUP BY pfamA2GO.go_id
")
  or die "print unable to connect to the DB";
  
  # Test for no results
   
foreach my $row (@$PFAM2GORESDB) {
     my ($GO_RES) = @$row;
     my $TO_TO_GO = "$seqNAME_blst-$GO_RES";
     push(@PFAM_TO_GO, $TO_TO_GO);
     #print "$seqNAME_blst\t$GO_RES\t$GO_CASE\n"; #print the GO search output
     
}
return @PFAM_TO_GO;
########## End Blast search
}
########## End Sub PFAM2GO

sub MRPS2GO {
    my ($seqNAME_blst) = @_; # Get the uniprot ACC to consult
    my @MRPS_TO_GO;
    #Search the Gene ontology database results for seqName
  my $MRPS2GORESDB = $dbh->selectall_arrayref("
SELECT
  MEROPS2GO.GO_ID
FROM $PRJ\_MEROPS
  INNER JOIN MEROPS_domain
    ON $PRJ\_MEROPS.mernum = MEROPS_domain.mernum
  INNER JOIN (SELECT
      MEROPS2GO.code,
      MEROPS2GO.GO_ID
    FROM MEROPS2GO
    GROUP BY MEROPS2GO.GO_ID) MEROPS2GO
    ON MEROPS_domain.code = MEROPS2GO.code
  INNER JOIN term
    ON MEROPS2GO.GO_ID = term.acc
WHERE $PRJ\_MEROPS.Seqname = '".$seqNAME_blst."'
AND $PRJ\_MEROPS.evalue <= 0.00000000001
AND $PRJ\_MEROPS.pident >= 40
GROUP BY MEROPS2GO.GO_ID
")
  or die "print unable to connect to the DB";
  
  # Test for no results
   
foreach my $row (@$MRPS2GORESDB) {
     my ($GO_RES) = @$row;
     my $TO_TO_GO = "$seqNAME_blst-$GO_RES";
     push(@MRPS_TO_GO, $TO_TO_GO);
     #print "$seqNAME_blst\t$GO_RES\t$GO_CASE\n"; #print the GO search output
     
}
return @MRPS_TO_GO;
########## End Blast search
}
########## End Sub MRPS2GO

sub timing{
  my ($seqN) = @_; # Get the uniprot ACC to consult
  my $endtime = time();
  my $runtime = $endtime - $st_time;
  return $runtime;

}

################################# LOOP File

open FILE, $fstFILE or die $!; # open fasta file to search for GOs
#Start looping the fasta file
print "Step 1: Reading fasta file and searching for annotation\n";
my @SUPER_GO; # create an array to store all the GO annotation
my @UNIQ_GO; # create an array to store the unique GO annotation summarizing BLAST, RFAM, PFAM and MEROPS
my @timing; #create a timing array for debug
my $i = 0;
my $o = 0;
while (my $fstHEADER = <FILE>) {
  if ($fstHEADER =~ s/^>//) { # Get the header
        my @fstDESC = split /\s/, $fstHEADER;
        #print $fstDESC[0]."go\n"; #Just for debug, print the sequence name from file
        #Go to blast results, check for best hits and retrive UNIPROT
        my $blastRES1 = blastRES($fstDESC[0]); # call blastRES to check and mount blast description of the contig
        if ($blastRES1 ne "") { # Check if there are some results, if yes retrive GOs.
            #print "there are some things here\t$blastRES1\n";
           my @BLST_GO = UNIPROT2GO($blastRES1,$fstDESC[0]); # Call subroutine and get all the annotation from BLAST
           my @RFAM_GO = RFAM2GO($fstDESC[0]); # Call subroutine RFAM and get all the annotation
           my @PFAM_GO = PFAM2GO($fstDESC[0]); # Call subroutine PFAM and get all the annotation
           my @MRPS_GO = MRPS2GO($fstDESC[0]); # Call subroutine PFAM and get all the annotation
           push(@SUPER_GO, @BLST_GO); # put all the results from blast into array @SUPER_GO
           push(@SUPER_GO, @RFAM_GO); # put all the results from RFAM into array @SUPER_GO
           push(@SUPER_GO, @PFAM_GO); # put all the results from PFAM into array @SUPER_GO
           push(@SUPER_GO, @MRPS_GO); # put all the results from MEROPS into array @SUPER_GO
           my $timer = timing($i);
           push(@timing, $timer);
          $i ++;
           } # Close if 
         $o ++;
        } #close if Get the Header
  } #Close While FILE
print "Step 1 complete on ".timing()." seconds\n Let´s continue.\nStep 2: Generating GO annotation and saving to file\n";

################################# End LOOP file

my @unique_GO = uniq @SUPER_GO; # create a non-redundant GO annotation

open(my $fh, '>', $ANNOT_file); # Open file to write

foreach (@unique_GO) {
  my ($seqNAME,$GOID) = split /-/, $_;
  my $MONTA_ANOT = $dbh->selectall_arrayref("
SELECT
  GO_term.go_id,
  GO_term.term,
  GO_term.category,
  GO_term.Dist
FROM GO_term
WHERE GO_term.go_id = '".$GOID."'
")
  or die "print unable to connect to the DB";
  
# Test for no results
if (scalar(@$MONTA_ANOT) == 0) {
print "1"; #check if there is some information. If not set it as 1 and pass to the annotation
}
  foreach my $row (@$MONTA_ANOT) {
     my ($GO_ID,$GO_TERM,$GO_CAT,$GO_DIST) = @$row;
     print $fh "$seqNAME\t$GO_ID\t$GO_CAT\t$GO_DIST\t$GO_TERM\n";
} # close d search
  
  } # Close foreach
close $fh; # close file to write
#output some statistics
my $runtime = sum(@timing / scalar(@SUPER_GO));
print "It was searched $o Contigs, $i with blast results.\n".scalar(@unique_GO)." unique GOs from ".scalar(@SUPER_GO)." available for this dataset\nThis was done on ".timing()." seconds at an average of $runtime seconds / sequence.\nThe results were saved on $ANNOT_file\n";
