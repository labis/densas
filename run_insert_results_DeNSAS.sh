#!/bin/bash
#PBS -m abe
#PBS -l nodes=1:ppn=2
#PBS -l walltime=350:00:00
#PBS -q default
#PBS -j oe


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

hostname

#############
#REFSEQ / BLASTx
#############

if [ $where = 1 ]; then
echo "Inserting blastx using refseq_protein database"
echo "Running: /opt/perl/bin/perl ${DNSASDIR}/insert_blast_results_createTXT.pl -i $BLSTDIR/${PRJ}_blastx_$PBS_ARRAYID.tsv --prj ${PRJ}"
/opt/perl/bin/perl ${DNSASDIR}/insert_blast_results_createTXT.pl -i $BLSTDIR/${PRJ}_blastx_$PBS_ARRAYID.tsv --prj ${PRJ} > $BLSTDIR/${PRJ}_blastx_$PBS_ARRAYID.db
fi

#############
#REFSEQ / DIAMOND
#############

if [ $where = 2 ]; then
echo "Inserting DIAMOND using refseq_protein database for DIAMOND"
/opt/perl/bin/perl ${DNSASDIR}/insert_blast_results_directly.pl -i $BLSTDIR/${PRJ}_blastx_$PBS_ARRAYID.tsv --prj ${PRJ}
fi

#############
#MEROPS / BLASTx
#############

if [ $where = 3 ]; then
echo "Inserting blastx using MEROPS database"
/opt/perl/bin/perl ${DNSASDIR}/insert_merops_results_directly.pl -i $MRPSDIR/${PRJ}_Blastx_$PBS_ARRAYID.tsv --prj ${PRJ}
fi

#############
#PFAM
#############

if [ $where = 4 ]; then
echo "Inserting PFAM"
/opt/perl/bin/perl ${DNSASDIR}/insert_pfam_results_directly.pl --prj $PRJ --infile $PFAMDIR/${PRJ}_PFAM_$PBS_ARRAYID.tsv
fi

#############
#RFAM
#############

if [ $where = 5 ]; then
echo "Inserting RFAM"
/opt/perl/bin/perl ${DNSASDIR}/insert_rfam_results_directly.pl -i $RFAMDIR/${PRJ}_RFAM_$PBS_ARRAYID.tsv --prj $PRJ
fi
