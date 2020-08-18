#!/bin/bash

TODAY=`date +"%d-%m-%Y"`
#########
#SET DIRS
#########

DBDIR="/state/partition1/DBs/"
DBRAW="/home/mmbrand/Downloads/DeNSAS/"
BLSTDIR=$DBDIR/blastdb
COMPBLSTDIR=$DBDIR/compressed
THUNDERSRV=thunder

##############
#SET PROGRAMS
##############
soft_makeblastdb="/home/mmbrand/miniconda2/bin/makeblastdb"
soft_blastdbcmd="/home/mmbrand/miniconda2/bin/blastdbcmd"
soft_diamond="/home/mmbrand/miniconda2/bin/diamond"
soft_hmmpress="/home/mmbrand/miniconda2/bin/hmmpress"
soft_hmmbuild="/home/mmbrand/miniconda2/bin/hmmbuild"

############
#CLEAN DIRS
############

rm -rf ${COMPBLSTDIR}
rm -rf ${BLSTDIR}

if [ ! -d "${DBDIR}" ]; then
    mkdir  ${DBDIR}
fi

if [ ! -d "${BLSTDIR}/" ]; then
    mkdir  ${BLSTDIR}/
fi

if [ ! -d "${COMPBLSTDIR}" ]; then
    mkdir  ${COMPBLSTDIR}
fi

#####################
#COPY FILES TO LOCAL
#####################

rsync -ruth --exclude md5 -e ssh ${THUNDERSRV}:$DBRAW $DBDIR

##################
#UNCOMPRESS FILES
##################

cd $DBDIR

######################
#BLAST FILES
######################

for filename in $COMPBLSTDIR/*.tar.gz
do
tar -zxvf $filename -C ${BLSTDIR}/
rm -rf $filename
done

###############
#DIAMOND FILES
###############
gunzip pepunit.lib.gz &
gunzip nr.gz &
# gunzip swissprot.gz &
# gunzip uniref90.fasta.gz &
wait

#################################
#TREAT FILES TO CREATE DATABASES
#################################

tr -d '-' < pepunit.lib | sed -e 's/\-/:/g' | cut -f1 -d" " | sed -e 's/\(\/\|\:\)//g' > pepunit_limpa3.lib
rm -rf pepunit.lib

########################
#CREATE BLAST DATABASES
########################

$soft_makeblastdb -in pepunit_limpa3.lib -dbtype 'prot' -title 'MEROPS $TODAY' -out $BLSTDIR/MEROPS &
$soft_blastdbcmd -db $BLSTDIR/refseq_protein -dbtype prot -out refseq_protein.fasta -entry all &
wait

##########################
#CREATE DIAMOND DATABASES
##########################


$soft_diamond makedb --in pepunit_limpa3.lib -d $BLSTDIR/MEROPS_diamond -p $NSLOTS
rm -rf pepunit_limpa3.lib
$soft_diamond makedb --in uniref90.fasta.gz -d $BLSTDIR/uniref90_diamond -p $NSLOTS
rm -rf uniref90.fasta.gz
$soft_diamond makedb --in nr.gz -d $BLSTDIR/nr_diamond --taxonmap prot.accession2taxid.gz --taxonnodes taxdmp.zip -p $NSLOTS
rm -rf nr.gz
$soft_diamond makedb --in refseq_protein.fasta --taxonmap prot.accession2taxid.gz --taxonnodes taxdmp.zip -d $BLSTDIR/refseq_DIAMOND -p $NSLOTS
rm -rf refseq_protein.fasta


#######################
#CREATE PFAM DATABASES
#######################

if [ -d "${DBDIR}/pfam" ]; then
    rm -rf  ${DBDIR}/pfam/*
    else
    mkdir  ${DBDIR}/pfam/
fi
gunzip -c Pfam-A.hmm.gz > ${DBDIR}/pfam/Pfam-A.hmm
rm -rf Pfam-A.hmm.gz
cd ${DBDIR}/pfam/
$soft_hmmpress Pfam-A.hmm
rm -rf Pfam-A.hmm

#######################
#CREATE RFAM DATABASES
#######################

if [ -d "${DBDIR}/rfam" ]; then
    rm -rf  ${DBDIR}/rfam/*
    else
    mkdir  ${DBDIR}/rfam/
fi

cd $DBDIR

gunzip -c Rfam.seed.gz > ${DBDIR}/rfam/Rfam.seed
rm -rf Rfam.seed.gz
cd ${DBDIR}/rfam/
$soft_hmmbuild Rfam.seed.hmm Rfam.seed
$soft_hmmpress Rfam.seed.hmm
rm -rf Rfam.seed Rfam.seed.hmm

##################
#CLEANUP THE MESS
##################

find ${DBDIR} -maxdepth 1 -type f -print0 | xargs -0r rm -rf
rm -rf ${COMPBLSTDIR}/
date > update_time.txt
