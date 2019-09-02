#!/bin/bash

#RUNDIR= Comes from the prep_annotation.pl
#FSTDIR= Comes from the prep_annotation.pl
#PRJ= Comes from the prep_annotation.pl
#where= Comes from the prep_annotation.pl
#DNSASDIR= Comes from the prep_annotation.pl


BLSTDIR="$RUNDIR/blastXML"
MRPSDIR="$RUNDIR/MEROPS"
PFAMDIR="$RUNDIR/PFAM"
RFAMDIR="$RUNDIR/RFAM"
FSTDIR="$RUNDIR/fasta"

echo "running at " & hostname
echo $where
echo RUNDIR=$RUNDIR,DNSASDIR=$DNSASDIR,PRJ=$PRJ,where=$where

#############
#REFSEQ / BLASTx
#############

if [ $where = 1 ]; then
echo "Inserting blastx using refseq_protein database"
echo "Running: /opt/perl/bin/perl ${DNSASDIR}/insert_blast_results_createTXT.pl -i $BLSTDIR/${PRJ}_blastx_$SGE_TASK_ID.tsv --prj ${PRJ}"
/opt/perl/bin/perl ${DNSASDIR}/insert_blast_results_createTXT.pl -i $BLSTDIR/${PRJ}_blastx_$SGE_TASK_ID.tsv --prj ${PRJ} > $BLSTDIR/${PRJ}_blastx_$SGE_TASK_ID.db
fi

#############
#REFSEQ / DIAMOND
#############

if [ $where = 2 ]; then
echo "Inserting DIAMOND using refseq_protein database for DIAMOND"
perl ${DNSASDIR}/insert_blast_results_directly.pl -i $BLSTDIR/${PRJ}_blastx_$SGE_TASK_ID.tsv --prj ${PRJ}
fi

#############
#MEROPS / BLASTx
#############

if [ $where = 3 ]; then
echo "Inserting blastx using MEROPS database"
/opt/perl/bin/perl ${DNSASDIR}/insert_merops_results_directly.pl -i $MRPSDIR/${PRJ}_Blastx_$SGE_TASK_ID.tsv --prj ${PRJ}
fi

#############
#PFAM
#############

if [ $where = 4 ]; then
echo "Inserting PFAM"
/opt/perl/bin/perl ${DNSASDIR}/insert_pfam_results_directly.pl --prj $PRJ --infile $PFAMDIR/${PRJ}_PFAM_$SGE_TASK_ID.tsv
fi

#############
#RFAM
#############

if [ $where = 5 ]; then
echo "Inserting RFAM"
/opt/perl/bin/perl ${DNSASDIR}/insert_rfam_results_directly.pl -i $RFAMDIR/${PRJ}_RFAM_$SGE_TASK_ID.tsv --prj $PRJ
fi
