#!/bin/bash
#PBS -m abe
#PBS -l nodes=1:ppn=4
#PBS -l walltime=350:00:00
#PBS -q default
#PBS -j oe
#PBS -o OUT/SPDK_RFAM_$PBS_ARRAYID.out

#RUNDIR= Comes from the prep_annotation.pl
#FSTDIR= Comes from the prep_annotation.pl
#PRJ= Comes from the prep_annotation.pl
#DNSASDIR= Comes from the prep_annotation.pl

TMPDIR="/state/partition1/RFAM_${PRJ}_$PBS_ARRAYID"
RFAMDIR="$RUNDIR/RFAM"
NP=$(wc -l $PBS_NODEFILE | awk '{print $1}')
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

if [ ! -d "/state/partition1/db/rfam/" ]; then
    mkdir /state/partition1/db/rfam/
fi

#NP=$(($NP-4))
rsync -vru /share/thunderstorm/db/Rfam/Rfam.hmm* /state/partition1/db/rfam/

echo "Let's get started
Check all the folders that will be used:
Running dir = $RUNDIR
Fasta Dir = $FSTDIR
Project name = $PRJ
DeNSAS = $DNSASDIR
Temp dir = $TMPDIR
RFAMDIR = $RFAMDIR

Send to queue by
qsub ${DNSASDIR}/run_insert_results_DeNSAS.sh -t $PBS_ARRAYID -N ${PRJ}_inRFAM -d ./ -o $RUNDIR/OUT/Insert_RFAM_$PBS_ARRAYID.out -v 'RUNDIR=$RUNDIR, DNSASDIR=$DNSASDIR, PRJ=$PRJ, where=5'
"


cd $TMPDIR
cp $FSTDIR/${PRJ}_$PBS_ARRAYID.fasta ./

##############################################
#   STEP ONE:
#   RUN RFAM
##############################################

~/programs/hmmer/binaries/hmmscan -o temp_${PRJ}_hmm --tblout ${PRJ}_rfam.tblout --noali --cpu $NP /state/partition1/db/rfam/Rfam.hmm ${PRJ}_$PBS_ARRAYID.fasta
perl ${DNSASDIR}//hmm_parser.pl ${PRJ}_rfam.tblout > $RFAMDIR/${PRJ}_RFAM_$PBS_ARRAYID.tsv

##############################################
#   STEP TWO:
#   Insert on DB
##############################################

#/share/thunderstorm/perl5/perls/perl-5.18.1/bin/perl ${DNSASDIR}/insert_rfam_results.pl -i $RFAMDIR/${PRJ}_RFAM_$PBS_ARRAYID.tsv --prj $PRJ
qsub ${DNSASDIR}/run_insert_results_DeNSAS.sh -t $PBS_ARRAYID -N ${PRJ}_inRFAM -d ./ -o $RUNDIR/OUT/In_RFAM_$PBS_ARRAYID.out -v "RUNDIR=$RUNDIR, DNSASDIR=$DNSASDIR, PRJ=$PRJ, where=5"

##############################################
#   STEP THREE:
#   CLEAN UP
##############################################

zip -rm ${PRJ}_rfam_$PBS_ARRAYID.zip ${PRJ}_rfam.tblout
mv *.zip $RFAMDIR
cd $RFAMDIR
rm -rf $TMPDIR
