# first, bring in the SeqIO module
 
use Bio::SeqIO;
use Getopt::Long;

# Notice that you do not have to use any Bio:SeqI
# objects, because SeqIO does this for you. In fact, it
# even knows which SeqI object to use for the provided
# format.
 
# Bring in the file and format, or die with a nice
# usage statement if one or both arguments are missing.

GetOptions ('prj=s' => \$PRJ,
            'infile=s' => \$file,
            'format=s' =>\$format,
            'name=s' =>\$name,
            );

# ###################################            
# # CHECK IF ALL VARIABLES ARE THERE
# ###################################
if ((!$PRJ) || (!$name) || (!$infile)) {
print "Some required arguments are missing.\nYou must use this as follow:\n$0 --prj [ PROJECT ] --infile [ FASTA FILE ] --name [ FASTA HEADER NAME ] --format [ fasta|fastq ]\n";
exit 1
}

# Now create a new SeqIO object to bring in the input
# file. The new method takes arguments in the format
# key => value, key => value. The basic keys that it
# can accept values for are '-file' which expects some
# information on how to access your data, and '-format'
# which expects one of the Bioperl-format-labels mentioned
# above. Although it is optional, it is good
# programming practice to provide > and < in front of any
# filenames provided in the -file parameter. This makes the
# resulting filehandle created by SeqIO explicitly read (<)
# or write(>).  It will definitely help others reading your
# code understand the function of the SeqIO object.
my $SEQNUM = 1; 
my $inseq = Bio::SeqIO->new(
                            -file   => "<$file",
                            -format => $format,
                            );
# Now that we have a seq stream,
# we need to tell it to give us a $seq.
# We do this using the 'next_seq' method of SeqIO.
 
while (my $seq = $inseq->next_seq) {
    print ">",$PRJ,"_",$name,":",$SEQNUM,"\n";
    print $seq->seq,"\n";
    $SEQNUM ++;
}
