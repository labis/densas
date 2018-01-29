#!/bin/bash
#PBS -m abe
#PBS -l nodes=1:ppn=12
#PBS -l walltime=350:00:00
#PBS -q default
#PBS -j oe

#RUNDIR= Comes from the prep_annotation.pl
#FSTDIR= Comes from the prep_annotation.pl
#PRJ= Comes from the prep_annotation.pl
#where= Comes from the prep_annotation.pl
#DNSASDIR= Comes from the prep_annotation.pl

TMPDIR="/state/partition1/BLAST_${PRJ}_$PBS_ARRAYID"
BLSTDIR="$RUNDIR/blastXML"
MRPSDIR="$RUNDIR/MEROPS"
NP=$(wc -l $PBS_NODEFILE | awk '{print $1}')
MaxSEQ=15
Evalue=0.00000000001

export BLASTDB=/state/partition1/db/blastdb/

#If not present, create the Map directory

cd $RUNDIR

 if [ ! -d "$BLSTDIR" ]; then
     mkdir $BLSTDIR
 fi

if [ ! -d "$MRPSDIR" ]; then
    mkdir $MRPSDIR
fi

if [ ! -d "./OUT" ]; then
    mkdir OUT
fi

if [ ! -d "$TMPDIR" ]; then
    mkdir $TMPDIR
fi

#NP=$(($NP-4))
cp $FSTDIR/${PRJ}_$PBS_ARRAYID.fasta $TMPDIR
# NP=$(($NP/2))

#############
#REFSEQ / BLASTx
#############


if [ $where = 1 ]; then
echo "running blastx using refseq_protein database"
~/programs/blast/blastx -query $TMPDIR/${PRJ}_$PBS_ARRAYID.fasta -db /state/partition1/db/blastdb/nr -out $BLSTDIR/${PRJ}_blastx_$PBS_ARRAYID.tsv -outfmt 6 -num_threads $NP -max_target_seqs $MaxSEQ -evalue $Evalue
qsub ${DNSASDIR}/run_insert_results_DeNSAS.sh -t $PBS_ARRAYID -N ${PRJ}_inBLST -d ./ -o $RUNDIR/OUT/In_BLAST_$PBS_ARRAYID.out -v "RUNDIR=$RUNDIR, DNSASDIR=$DNSASDIR, PRJ=$PRJ, where=1"
fi

#############
#REFSEQ / DIAMOND
#############

if [ $where = 2 ]; then
echo "running DIAMOND using refseq_protein database for DIAMOND"
/share/programs/downloads/diamond blastx --threads $NP -d /state/partition1/db/blastdb/refseq_DIAMOND -q $TMPDIR/${PRJ}_$PBS_ARRAYID.fasta -a $BLSTDIR/${PRJ}_${PBS_ARRAYID}_Diamond -t $TMPDIR -k $MaxSEQ -c 5 -e $Evalue
/share/programs/downloads/diamond view -a $BLSTDIR/${PRJ}_${PBS_ARRAYID}_Diamond.daa -o $BLSTDIR/${PRJ}_blastx_$PBS_ARRAYID.tsv -f tab
qsub ${DNSASDIR}/run_insert_results_DeNSAS.sh -t $PBS_ARRAYID -N ${PRJ}_inDIA -d ./ -o $RUNDIR/OUT/In_Diamon_$PBS_ARRAYID.out -v "RUNDIR=$RUNDIR, DNSASDIR=$DNSASDIR, PRJ=$PRJ, where=2"
fi

#############
#MEROPS / BLASTx
#############

if [ $where = 3 ]; then
echo "running blastx using MEROPS database"
NP2=$(($NP/2)) # run half threads
~/programs/blast/blastx -query $TMPDIR/${PRJ}_$PBS_ARRAYID.fasta -db /state/partition1/db/blastdb/MEROPS -out $MRPSDIR/${PRJ}_Blstx_$PBS_ARRAYID.tsv -outfmt 6 -num_threads $NP -max_target_seqs $MaxSEQ -evalue $Evalue
qsub ${DNSASDIR}/run_insert_results_DeNSAS.sh -t $PBS_ARRAYID -N ${PRJ}_inMRPS -d ./ -o $RUNDIR/OUT/In_MEROPS_$PBS_ARRAYID.out -v "RUNDIR=$RUNDIR, DNSASDIR=$DNSASDIR, PRJ=$PRJ, where=3"
fi

#############
#MEROPS / DIAMOND
#############

if [ $where = 4 ]; then
echo "running diamond using MEROPS database"
/share/programs/downloads/diamond blastx --threads $NP -d /state/partition1/db/blastdb/MEROPS_diamond -q $TMPDIR/${PRJ}_$PBS_ARRAYID.fasta -a $MRPSDIR/${PRJ}_${PBS_ARRAYID}_Diamond -t $TMPDIR -k $MaxSEQ -c 5 -e $Evalue
/share/programs/downloads/diamond view -a $MRPSDIR/${PRJ}_${PBS_ARRAYID}_Diamond.daa -o $MRPSDIR/${PRJ}_Blastx_$PBS_ARRAYID.tsv -f tab
qsub ${DNSASDIR}/run_insert_results_DeNSAS.sh -t $PBS_ARRAYID -N ${PRJ}_inMRPS -d ./ -o $RUNDIR/OUT/In_MERDiamon_$PBS_ARRAYID.out -v "RUNDIR=$RUNDIR, DNSASDIR=$DNSASDIR, PRJ=$PRJ, where=3"
fi

cd $RUNDIR
rm -rf $TMPDIR
