#!/bin/bash

#All those variables comes from prep_annotation_DeNSAS.pl
#RUNDIR
#FSTDIR
#PRJ
#DNSASDIR
#soft_IPRS_db
#ncpus_insert
PATH=$PATH:$soft_python3
TMPDIR="/state/partition1/IPRS_${PRJ}_$SGE_TASK_ID"
IPRSDIR="$RUNDIR/IPRS"
NP=$NSLOTS

if [ ! -d "$IPRSDIR" ]; then
    mkdir $IPRSDIR
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
else
runfile=${PRJ}_$SGE_TASK_ID.fasta
fi

##############################################
#   STEP TWO:
#   Run interproscan
##############################################

$soft_interproscan -i $runfile --cpu $NSLOTS -appl Pfam,Gene3D,TIGRFAM,SFLD -dp -iprlookup -goterms -pa -t p -T $TMPDIR -d $IPRSDIR -f tsv

##############################################
#   STEP THREE:
#   CLEAN UP
##############################################
if [ $ABLAST = "nuc" ]; then
mv ${PRJ}_$SGE_TASK_ID.fasta.transdecoder_dir/longest_orfs.pep $IPRSDIR/${PRJ}_${SGE_TASK_ID}_longest_orfs.pep
fi
cd $IPRSDIR
rm -rf $TMPDIR
