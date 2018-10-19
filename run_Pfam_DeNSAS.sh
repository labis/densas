#!/bin/bash
#PBS -m abe
#PBS -N PFAM_${PRJ}
#PBS -l nodes=1:ppn=4
#PBS -l walltime=900:00:00
#PBS -q default
#PBS -j oe

NP=$(wc -l $PBS_NODEFILE | awk '{print $1}')
#RUNDIR= Comes from the prep_annotation.pl
#FSTDIR= Comes from the prep_annotation.pl
#PRJ= Comes from the prep_annotation.pl
#DNSASDIR= Comes from the prep_annotation.pl
#ABLAST= Comes from the prep_annotation.pl

TMPDIR="/state/partition1/PFAM_${PRJ}_$PBS_ARRAYID"
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

if [ ! -d "/state/partition1/db/pfam/" ]; then
    mkdir /state/partition1/db/pfam/
fi

echo "Sync new database"
rsync -vru /share/thunderstorm/db/pfam/Pfam-A* /state/partition1/db/pfam/

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
qsub ${DNSASDIR}/run_insert_results_DeNSAS.sh -t $PBS_ARRAYID -N ${PRJ}_inPFAM -d ./ -o $RUNDIR/OUT/Insert_PFAM_$PBS_ARRAYID.out -v 'RUNDIR=$RUNDIR, DNSASDIR=$DNSASDIR, PRJ=$PRJ, where=4'
"

###############################################
#   STEP ONE:
#   RUN TRANSDECODER AND FIND THE LONGEST ORFS
#   IF RUNNING ATYPE=NUC
###############################################

cd $TMPDIR
cp $FSTDIR/${PRJ}_$PBS_ARRAYID.fasta ./
if [ $ABLAST = "nuc" ]; then
/share/programs/TransDecoder-2.0.1/TransDecoder.LongOrfs -t ${PRJ}_$PBS_ARRAYID.fasta -m 50
/share/programs/TransDecoder-2.0.1/TransDecoder.Predict -t ${PRJ}_$PBS_ARRAYID.fasta
runfile=${PRJ}_$PBS_ARRAYID.fasta.transdecoder_dir/longest_orfs.pep
else
runfile=${PRJ}_$PBS_ARRAYID.fasta
fi
##############################################
#   STEP TWO:
#   RUN PFAM
##############################################

~/programs/hmmer/binaries/hmmscan -o temp_${PRJ}_hmm --tblout ${PRJ}_${PBS_ARRAYID}_pfam.tblout --noali --cpu $NP /state/partition1/db/pfam/Pfam-A.hmm  $runfile
perl ${DNSASDIR}/hmm_parser.pl ${PRJ}_${PBS_ARRAYID}_pfam.tblout > $PFAMDIR/${PRJ}_PFAM_$PBS_ARRAYID.tsv

##############################################
#   STEP THREE:
#   Insert on DB
##############################################

#/share/thunderstorm/perl5/perls/perl-5.18.1/bin/perl ${DNSASDIR}/insert_pfam_results.pl --prj $PRJ --infile $PFAMDIR/${PRJ}_PFAM_$PBS_ARRAYID.tsv
qsub ${DNSASDIR}/run_insert_results_DeNSAS.sh -t $PBS_ARRAYID -N ${PRJ}_inPFAM -d ./ -o $RUNDIR/OUT/In_PFAM_$PBS_ARRAYID.out -v "RUNDIR=$RUNDIR, DNSASDIR=$DNSASDIR, PRJ=$PRJ, where=4"

##############################################
#   STEP FOUR:
#   CLEAN UP
##############################################
if [ $ABLAST = "nuc" ]; then
cp ${PRJ}_$PBS_ARRAYID.fasta.transdecoder_dir/longest_orfs.pep $PFAMDIR/${PRJ}_PFAM_$PBS_ARRAYID.pep
fi
zip -rm ${PRJ}_${PBS_ARRAYID}_pfam.tblout.zip ${PRJ}_${PBS_ARRAYID}_pfam.tblout
# tar -zcvpf ${PRJ}_$PBS_ARRAYID.fasta_dir.tar.gz ${PRJ}_$PBS_ARRAYID.fasta_dir/ --remove-files
mv $PFAMDIR/*.pep $PEPDIR/
mv *.tar.gz $PFAMDIR
mv *.zip $PFAMDIR
cd $PFAMDIR
rm -rf $TMPDIR
