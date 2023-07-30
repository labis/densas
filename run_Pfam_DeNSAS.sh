#!/bin/bash
NP=$NSLOTS
#All those variables comes from prep_annotation_DeNSAS.pl
#RUNDIR
#FSTDIR
#PRJ
#DNSASDIR
#ABLAST
#qname
#ncpus_insert
#soft_hmmscan

TMPDIR="/state/partition1/PFAM_${PRJ}_$SGE_TASK_ID"
PEPDIR=$RUNDIR/PEP
PFAMDIR="$RUNDIR/PFAM"

 if [ ! -d "$RUNDIR" ]; then
     echo "Creating $RUNDIR"
     mkdir $RUNDIR
 fi

#Open a temp dir at local machine
 if [ ! -d "$TMPDIR" ]; then
     echo "Creating $TMPDIR"
     mkdir $TMPDIR
 fi
 
 if [ ! -d "$RUNDIR/OUT" ]; then
    mkdir $RUNDIR/OUT
fi

if [ ! -d "$PEPDIR" ]; then
    echo "Creating $RUNDIR"
    mkdir $PEPDIR
fi

if [ ! -d "$PFAMDIR" ]; then
    echo "Creating $PFAMDIR"
    mkdir $PFAMDIR
fi

echo "Let's get started
Check all the folders that will be used:
Running dir = $RUNDIR
Fasta Dir = $FSTDIR
Project name = $PRJ
DeNSAS = $DNSASDIR
Temp dir = $TMPDIR
Peptide dir $RUNDIR/PEP
PFAMDIR = $RUNDIR/PFAM

Send to queue by
qsub -t $SGE_TASK_ID -N ${PRJ}_inPFAM -q $qname -cwd -o $RUNDIR/OUT/In_PFAM_$SGE_TASK_ID.out -pe smp $ncpus_insert -v RUNDIR=$RUNDIR,DNSASDIR=$DNSASDIR,PRJ=$PRJ,where=4 ${DNSASDIR}/run_insert_results_DeNSAS.sh
"

###############################################
#   STEP ONE:
#   RUN TRANSDECODER AND FIND THE LONGEST ORFS
#   IF RUNNING ATYPE=NUC
###############################################

cd $TMPDIR
cp $FSTDIR/${PRJ}_$SGE_TASK_ID.fasta ./
if [ $ABLAST = "nuc" ]; then
$soft_transdecoder/TransDecoder.LongOrfs -t ${PRJ}_$SGE_TASK_ID.fasta -m 50
$soft_transdecoder/TransDecoder.Predict -t ${PRJ}_$SGE_TASK_ID.fasta
runfile=${PRJ}_$SGE_TASK_ID.fasta.transdecoder_dir/longest_orfs.pep
cp ${PRJ}_$SGE_TASK_ID.fasta.transdecoder_dir/longest_orfs.pep $PEPDIR/${PRJ}_PFAM_$SGE_TASK_ID.pep
else
runfile=${PRJ}_$SGE_TASK_ID.fasta
fi
sed -i 's/\*//g' $runfile
##############################################
#   STEP TWO:
#   RUN PFAM
##############################################

$soft_hmmscan -o temp_${PRJ}_hmm --tblout ${PRJ}_${SGE_TASK_ID}_pfam.tblout --noali --cpu $NP $soft_pfam_db  $runfile
perl ${DNSASDIR}/hmm_parser.pl ${PRJ}_${SGE_TASK_ID}_pfam.tblout > $PFAMDIR/${PRJ}_PFAM_$SGE_TASK_ID.tsv

##############################################
#   STEP THREE:
#   Insert on DB
##############################################

echo "GOING TO DeNSASdb\n"
qsub -t $SGE_TASK_ID -N ${PRJ}_inPFAM -q $qname -o $RUNDIR/OUT/In_PFAM_$SGE_TASK_ID.out -pe smp $ncpus_insert -v RUNDIR=$RUNDIR,DNSASDIR=$DNSASDIR,PRJ=$PRJ,where=4 ${DNSASDIR}/run_insert_results_DeNSAS.sh

##############################################
#   STEP FOUR:
#   CLEAN UP
##############################################
# if [ $ABLAST = "nuc" ]; then
# mv ${PRJ}_$SGE_TASK_ID.fasta.transdecoder_dir/longest_orfs.pep $PEPDIR/${PRJ}_PFAM_$SGE_TASK_ID.pep
# mv $PFAMDIR/*.pep $PEPDIR/
# fi
zip -rm ${PRJ}_${SGE_TASK_ID}_pfam.tblout.zip ${PRJ}_${SGE_TASK_ID}_pfam.tblout
mv *.zip $PFAMDIR
cd $PFAMDIR
rm -rf $TMPDIR
