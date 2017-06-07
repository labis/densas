#!/bin/bash
#PBS -m abe
#PBS -l nodes=1:ppn=2
#PBS -l walltime=350:00:00
#PBS -q default
#PBS -j oe
#PBS -o OUT/insert_$PBS_ARRAYID.out

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
#Description
#############

if [ $where = 1 ]; then
echo "Creating Description from data"
/share/thunderstorm/perl5/perls/perl-5.18.1/bin/perl ~/annotate/Runscripts/Make_an_desc.pl --prj ${PRJ} --infile $infile > $outfile

fi

#############
#Annotation
#############

if [ $where = 2 ]; then
echo "Generating Annotation from file"
/share/thunderstorm/perl5/perls/perl-5.18.1/bin/perl ~/annotate/Runscripts/Make_an_GO3.pl --prj $PRJ --infile $infile --outfile $outfile
fi
