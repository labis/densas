#!/bin/bash
#PBS -m abe
#PBS -l nodes=1:ppn=4
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
echo "Running: /share/thunderstorm/perl5/perls/perl-5.18.1/bin/perl ${DNSASDIR}/insert_blast_results.pl -i $BLSTDIR/${PRJ}_blastx_$PBS_ARRAYID.tsv --prj ${PRJ}"
/share/thunderstorm/perl5/perls/perl-5.18.1/bin/perl ${DNSASDIR}/insert_blast_results.pl -i $BLSTDIR/${PRJ}_blastx_$PBS_ARRAYID.tsv --prj ${PRJ}
fi

#############
#REFSEQ / DIAMOND
#############

if [ $where = 2 ]; then
echo "Inserting DIAMOND using refseq_protein database for DIAMOND"
/share/thunderstorm/perl5/perls/perl-5.18.1/bin/perl ${DNSASDIR}/insert_blast_results.pl -i $BLSTDIR/${PRJ}_blastx_$PBS_ARRAYID.tsv --prj ${PRJ}
echo "/share/thunderstorm/perl5/perls/perl-5.18.1/bin/perl ${DNSASDIR}/insert_blast_results.pl -i $BLSTDIR/${PRJ}_blastx_$PBS_ARRAYID.tsv --prj ${PRJ}"
fi

#############
#MEROPS / BLASTx
#############

if [ $where = 3 ]; then
echo "Inserting blastx using MEROPS database"
echo "Running /share/thunderstorm/perl5/perls/perl-5.18.1/bin/perl ${DNSASDIR}/insert_merops_results.pl -i $MRPSDIR/${PRJ}_Blastx_$PBS_ARRAYID.tsv --prj ${PRJ}"
/share/thunderstorm/perl5/perls/perl-5.18.1/bin/perl ${DNSASDIR}/insert_merops_results.pl -i $MRPSDIR/${PRJ}_Blastx_$PBS_ARRAYID.tsv --prj ${PRJ}
fi

#############
#PFAM
#############

if [ $where = 4 ]; then
echo "Inserting PFAM"
echo "running /share/thunderstorm/perl5/perls/perl-5.18.1/bin/perl ${DNSASDIR}/insert_pfam_results.pl --prj $PRJ --infile $PFAMDIR/${PRJ}_PFAM_$PBS_ARRAYID.tsv"
/share/thunderstorm/perl5/perls/perl-5.18.1/bin/perl ${DNSASDIR}/insert_pfam_results.pl --prj $PRJ --infile $PFAMDIR/${PRJ}_PFAM_$PBS_ARRAYID.tsv
fi

#############
#RFAM
#############

if [ $where = 5 ]; then
echo "Inserting RFAM"
echo "Running /share/thunderstorm/perl5/perls/perl-5.18.1/bin/perl ${DNSASDIR}/insert_rfam_results.pl -i $RFAMDIR/${PRJ}_RFAM_$PBS_ARRAYID.tsv --prj $PRJ"
/share/thunderstorm/perl5/perls/perl-5.18.1/bin/perl ${DNSASDIR}/insert_rfam_results.pl -i $RFAMDIR/${PRJ}_RFAM_$PBS_ARRAYID.tsv --prj $PRJ
fi
