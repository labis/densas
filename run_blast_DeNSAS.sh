#!/bin/bash

TMPDIR="/state/partition1/BLAST_${PRJ}_$SGE_TASK_ID"
BLSTDIR="$RUNDIR/blastXML"
MRPSDIR="$RUNDIR/MEROPS"
NP=$NSLOTS
MaxSEQ=15
Evalue=0.00000000001

export BLASTDB=/state/partition1/DBs/blastdb

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
cp $FSTDIR/${PRJ}_$SGE_TASK_ID.fasta $TMPDIR
# NP=$(($NP/2))

#############
#REFSEQ / BLASTx
#############


if [ $where = 1 ]; then
echo "running blastx using refseq_protein database"
~/programs/blast/blastx -query $TMPDIR/${PRJ}_$SGE_TASK_ID.fasta -db /state/partition1/DBs/blastdb/nr -out $BLSTDIR/${PRJ}_blastx_$SGE_TASK_ID.tsv -outfmt 6 -num_threads $NP -max_target_seqs $MaxSEQ -evalue $Evalue
qsub ${DNSASDIR}/run_insert_results_DeNSAS.sh -t $SGE_TASK_ID -N ${PRJ}_inBLST -d ./ -o $RUNDIR/OUT/In_BLAST_$SGE_TASK_ID.out -v RUNDIR=$RUNDIR,DNSASDIR=$DNSASDIR,PRJ=$PRJ,where=1
fi

#############
#REFSEQ / DIAMOND
#############

if [ $where = 2 ]; then
echo "running DIAMOND using refseq_protein database for DIAMOND"
$soft_diamond $ABLAST --threads $NP -d $soft_diamond_refseq -q $TMPDIR/${PRJ}_$SGE_TASK_ID.fasta -a $BLSTDIR/${PRJ}_${SGE_TASK_ID}_Diamond -t $TMPDIR -k $MaxSEQ -c 5 -e $Evalue
$soft_diamond view -a $BLSTDIR/${PRJ}_${SGE_TASK_ID}_Diamond.daa -o $BLSTDIR/${PRJ}_blastx_$SGE_TASK_ID.tsv -f tab
echo "Sending to DeNSAS_db"
qsub -t $SGE_TASK_ID -N ${PRJ}_inDIA -q $qname -cwd -o $RUNDIR/OUT/In_Diamon_$SGE_TASK_ID.out -e $RUNDIR/OUT/In_Diamon_$SGE_TASK_ID.err -pe smp $ncpus_insert -v RUNDIR=$RUNDIR,DNSASDIR=$DNSASDIR,PRJ=$PRJ,where=2 ${DNSASDIR}/run_insert_results_DeNSAS.sh
gzip $BLSTDIR/${PRJ}_${SGE_TASK_ID}_Diamond.daa
fi

#############
#MEROPS / BLASTx
#############

if [ $where = 3 ]; then
echo "running blastx using MEROPS database"
NP2=$(($NP/2)) # run half threads
~/programs/blast/blastx -query $TMPDIR/${PRJ}_$SGE_TASK_ID.fasta -db /state/partition1/DBs/blastdbMEROPS -out $MRPSDIR/${PRJ}_Blstx_$SGE_TASK_ID.tsv -outfmt 6 -num_threads $NP -max_target_seqs $MaxSEQ -evalue $Evalue
qsub ${DNSASDIR}/run_insert_results_DeNSAS.sh -t $SGE_TASK_ID -N ${PRJ}_inMRPS -d -o $RUNDIR/OUT/In_MEROPS_$SGE_TASK_ID.out -v RUNDIR=$RUNDIR, DNSASDIR=$DNSASDIR, PRJ=$PRJ, where=3
fi

#############
#MEROPS / DIAMOND
#############

if [ $where = 4 ]; then
echo "date\nrunning diamond using MEROPS database"
$soft_diamond $ABLAST --threads $NP -d $soft_diamond_merops -q $TMPDIR/${PRJ}_$SGE_TASK_ID.fasta -a $MRPSDIR/${PRJ}_${SGE_TASK_ID}_Diamond -t $TMPDIR -k $MaxSEQ -c 5 -e $Evalue
$soft_diamond view -a $MRPSDIR/${PRJ}_${SGE_TASK_ID}_Diamond.daa -o $MRPSDIR/${PRJ}_Blastx_$SGE_TASK_ID.tsv -f tab
qsub -t $SGE_TASK_ID -N ${PRJ}_inMRPS -q $qname -cwd -o $RUNDIR/OUT/In_MERDiamon_$SGE_TASK_ID.out -e $RUNDIR/OUT/In_MERDiamon_$SGE_TASK_ID.err -pe smp $ncpus_insert -v RUNDIR=$RUNDIR,DNSASDIR=$DNSASDIR,PRJ=$PRJ,where=3 ${DNSASDIR}/run_insert_results_DeNSAS.sh
gzip $MRPSDIR/${PRJ}_${SGE_TASK_ID}_Diamond.daa
fi

cd $RUNDIR
rm -rf $TMPDIR
