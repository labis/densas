#!/bin/bash
#PBS -m abe
#PBS -N blast_local_NUM
#PBS -l nodes=thunder-NUM:ppn=14
#PBS -l walltime=660:00:00
#PBS -q default
#PBS -j oe
#PBS -o blast_local_NUM.out

TODAY=`date +"%d-%m-%Y"`

############
#CLEAN DIRS
############

rm -rf /state/partition1/db/blastdb/compressed
rm -rf /state/partition1/db/blastdb

if [ ! -d "/state/partition1/db/" ]; then
    mkdir  /state/partition1/db/
fi

if [ ! -d "/state/partition1/db/blastdb/" ]; then
    mkdir  /state/partition1/db/blastdb/
fi

if [ ! -d "/state/partition1/db/blastdb/compressed" ]; then
    mkdir  /state/partition1/db/blastdb/compressed
fi

#####################
#COPY FILES TO LOCAL
#####################

rsync -ruth $blastdir /state/partition1/db/blastdb/compressed/

##################
#UNCOMPRESS FILES
##################

cd /state/partition1/db/blastdb/

######################
#BLAST FILES
######################

for filename in ./compressed/*.tar.gz
do
tar -zxvf $filename -C /state/partition1/db/blastdb/
done

cd compressed
# gunzip nr.gz &
# gunzip swissprot.gz &
# wait

#################################
#TREAT FILES TO CREATE DATABASES
#################################


tr -d '-' < pepunit.lib > pepunit_limpa.lib
sed -i 's/\-/:/g' pepunit_limpa.lib
cut -f1 -d" " pepunit_limpa.lib | sed -e 's/\(\/\|\:\)//g' > pepunit_limpa3.lib

##################
#CREATE DATABASES
##################

/share/programs/blast/makeblastdb -in pepunit_limpa3.lib -dbtype 'prot' -title 'MEROPS $TODAY' -out ../MEROPS &
/share/programs/blast/blastdbcmd -db ../refseq_protein -dbtype prot -out refseq_protein.fasta -entry all &
wait
NODEP=$(hostname)
if [ `hostname` != 'thunder-1-2.local' ]; then
/share/programs/downloads/diamond makedb --in refseq_protein.fasta -d ../refseq_DIAMOND -b 5 -p $PBS_NP
/share/programs/downloads/diamond makedb --in pepunit_limpa3.lib -d ../MEROPS_diamond -b 5 -p $PBS_NP
fi

#######################
#CREATE PFAM DATABASES
#######################

rm -rf /state/partition1/db/pfam/*
mv Pfam-A.hmm.gz /state/partition1/db/pfam/
cd /state/partition1/db/pfam/
gunzip Pfam-A.hmm.gz
/share/programs/hmmer/binaries/hmmpress Pfam-A.hmm
rm -rf Pfam-A.hmm

#######################
#CREATE RFAM DATABASES
#######################

rm -rf /state/partition1/db/rfam/*

if [ ! -d "/state/partition1/db/rfam/" ]; then
    mkdir  /state/partition1/db/rfam/
fi
mv /state/partition1/db/blastdb/compressed/Rfam.seed.gz /state/partition1/db/rfam/
cd /state/partition1/db/rfam/
gunzip Rfam.seed.gz
/share/programs/hmmer/binaries/hmmbuild Rfam.seed.hmm Rfam.seed
/share/programs/hmmer/binaries/hmmpress Rfam.seed.hmm
rm -rf Rfam.seed Rfam.seed.hmm

cd ..
date > update_time.txt
##################
#CLEANUP THE MESS
##################

cd ~/
rm -rf /state/partition1/db/blastdb/compressed/*
