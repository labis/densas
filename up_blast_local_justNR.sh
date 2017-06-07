#!/bin/bash
#PBS -m abe
#PBS -N diamond_local_NUM
#PBS -l nodes=thunder-NUM:ppn=8
#PBS -l walltime=660:00:00
#PBS -q default
#PBS -j oe
#PBS -o blast_local_NUM.out

##################
#UNCOMPRESS FILES
##################

cd /state/partition1/db/blastdb/

######################
#BLAST FILES
######################

# for filename in ./compressed/*.tar.gz
# do
# tar -zxvf $filename -C /state/partition1/db/blastdb/
# done

##################
#CREATE DATABASES
##################

if [ `hostname` != 'thunder-1-2.local' ]; then
cd compressed
gunzip nr.gz
~/programs/downloads/diamond makedb --in nr -d ../nr_DIAMOND -b 5 -p $PBS_NP
fi
