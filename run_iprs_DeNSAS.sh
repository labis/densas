#!/bin/bash

#All those variables comes from prep_annotation_DeNSAS.pl
#RUNDIR
#FSTDIR
#PRJ
#DNSASDIR
#soft_rfam_db
#ncpus_insert

TMPDIR="/state/partition1/RFAM_${PRJ}_$SGE_TASK_ID"
RFAMDIR="$RUNDIR/RFAM"
NP=$NSLOTS

if [ ! -d "$RFAMDIR" ]; then
    mkdir $RFAMDIR
fi

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

echo "Let's get started
Check all the folders that will be used:
Running dir = $RUNDIR
Fasta Dir = $FSTDIR
Project name = $PRJ
DeNSAS = $DNSASDIR
Temp dir = $TMPDIR
RFAMDIR = $RFAMDIR

Send to queue by
qsub ${DNSASDIR}/run_insert_results_DeNSAS.sh -t $SGE_TASK_ID -N ${PRJ}_inRFAM -d ./ -o $RUNDIR/OUT/Insert_RFAM_$SGE_TASK_ID.out -v 'RUNDIR=$RUNDIR, DNSASDIR=$DNSASDIR, PRJ=$PRJ, where=5'
"


cd $TMPDIR
cp $FSTDIR/${PRJ}_$SGE_TASK_ID.fasta ./

##############################################
#   STEP ONE:
#   RUN RFAM
##############################################

$soft_hmmscan -o temp_${PRJ}_hmm --tblout ${PRJ}_rfam.tblout --noali --cpu $NP $soft_rfam_db ${PRJ}_$SGE_TASK_ID.fasta
perl ${DNSASDIR}//hmm_parser.pl ${PRJ}_rfam.tblout > $RFAMDIR/${PRJ}_RFAM_$SGE_TASK_ID.tsv

##############################################
#   STEP TWO:
#   Insert on DB
##############################################

#/share/thunderstorm/perl5/perls/perl-5.18.1/bin/perl ${DNSASDIR}/insert_rfam_results.pl -i $RFAMDIR/${PRJ}_RFAM_$SGE_TASK_ID.tsv --prj $PRJ
qsub ${DNSASDIR}/run_insert_results_DeNSAS.sh -t $SGE_TASK_ID -N ${PRJ}_inRFAM -q $qname -cwd -o $RUNDIR/OUT/In_RFAM_$SGE_TASK_ID.out -pe smp $ncpus_insert -v RUNDIR=$RUNDIR,DNSASDIR=$DNSASDIR,PRJ=$PRJ,where=5

##############################################
#   STEP THREE:
#   CLEAN UP
##############################################

zip -rm ${PRJ}_rfam_$SGE_TASK_ID.zip ${PRJ}_rfam.tblout
mv *.zip $RFAMDIR
cd $RFAMDIR
rm -rf $TMPDIR
