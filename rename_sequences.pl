# first, bring in the SeqIO module
 
use Bio::SeqIO;
use Getopt::Long;
use warnings;
use Term::ANSIColor qw(:constants);
$Term::ANSIColor::AUTORESET = 1; # auto reset colors

GetOptions ('prj=s' => \$PRJ,
            'infile=s' => \$file,
            'format=s' =>\$format,
            'name=s' =>\$name,
            );

# ###################################            
# # CHECK IF ALL VARIABLES ARE THERE
# ###################################
if ((!$PRJ) || (!$name) || (!$file)) {
    print BOLD RED "Warning!\n";
    print BOLD BLUE "Some required arguments are missing.\nYou must use this as follow:\n$0 --prj [ PROJECT ] --infile [ FASTA FILE ] --name [ FASTA HEADER NAME ] --format [ fasta|fastq ]\n";
exit 1
}
print BOLD YELLOW "Starting to rename\n";
my $SEQNUM = 1; 
my $inseq = Bio::SeqIO->new(
                            -file   => "<$file",
                            -format => $format,
                            );

my ($filename, $exte) = split /./, $file;
open(my $fh, '>', $PRJ."_rename.fasta"); # Open file to write sequences
open(my $th, '>', $PRJ."_translate_rename.txt"); #Open file to write translations
while (my $seq = $inseq->next_seq) {
    print $fh ">",$PRJ,"_",$name,":",$SEQNUM,"\n";
    print $fh $seq->seq,"\n";
    $SEQNUM ++;
    print $th $PRJ,"_",$name,":",$SEQNUM,"\t",$seq->primary_id,"\n";
}
close $fh; # close file to write
close $th; # close file to write
print BOLD GREEN "Done\n Now proceed to DeNSAS!\n";
