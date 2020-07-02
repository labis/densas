#!/bin/bash
#PBS -M brandao.marcelo@gmail.com
#PBS -m abe
#PBS -N UPDATE_BLAST
#PBS -l nodes=1:ppn=2
#PBS -q default
#PBS -j oe
#PBS -o update_BLAST.out

BLASTDIR=/home/mmbrand/Downloads/DeNSAS
SCRIPTSDIR=/home/mmbrand/Experimentos/DeNSAS/Update

cd $BLASTDIR

if [ ! -d "${BLASTDIR}/compressed/" ]; then
    mkdir  ${BLASTDIR}/compressed/
fi

###################
#START DOWNLOADING
###################

# rsync -auh --quiet ftp.ncbi.nlm.nih.gov::blast/db/FASTA/swissprot.gz ${BLASTDIR}/compressed/&
rsync -auh --quiet ftp.ncbi.nlm.nih.gov::blast/db/nr*.* ${BLASTDIR}/compressed/& 
# rsync -auh --quiet ftp.ncbi.nlm.nih.gov::blast/db/FASTA/nr.gz ${BLASTDIR}/compressed/&
rsync -auh --quiet ftp.ncbi.nlm.nih.gov::blast/db/refseq_protein*.* ${BLASTDIR}/compressed/&
# rsync -auh --quiet ftp.ncbi.nlm.nih.gov::blast/db/taxdb.tar.gz ${BLASTDIR}/compressed/&
wget --quiet ftp://ftp.ebi.ac.uk/pub/databases/merops/current_release/pepunit.lib &
wget --quiet ftp://ftp.ebi.ac.uk/pub/databases/Pfam/current_release/Pfam-A.hmm.gz &
wget --quiet ftp://ftp.ebi.ac.uk/pub/databases/Rfam/CURRENT/Rfam.seed.gz &
# swissprot=`jobs -l | grep "swissprot" | awk '{print $2}'`
# blastN=`jobs -l | grep "ftp.ncbi.nlm.nih.gov::blast/db/n" | awk '{print $2}'`
nr=`jobs -l | grep "nr.gz" | awk '{print $2}'`
refseq=`jobs -l | grep "refseq_protein" | awk '{print $2}'` &
# taxdb=`jobs -l | grep "taxdb.tar.gz" | awk '{print $2}'` &
merops=`jobs -l | grep "pepunit.lib" | awk '{print $2}'`  &
PFAM=`jobs -l | grep "Pfam-A.hmm.gz" | awk '{print $2}'` &
RFAM=`jobs -l | grep "Rfam.seed.gz" | awk '{print $2}'` &
# wait $swissprot
wait $nr &
# wait $blastN
# wait $est_others
wait $refseq
# wait $taxdb &
wait $merops &
wait $PFAM &
wait $RFAM 

#############
#MOVE MEROPS
#############

# cd ${BLASTDIR}/compressed/
# date > ./updatetime.txt

######################
#DISTRIBUTE ALL FILES
######################

cd $SCRIPTSDIR

for i in {0..6}
do
   echo "Lançando Thunder-0-$i"
   sed -e "s/NUM/0-$i/g" up_blast_local.sh | qsub -v "blastdir=${BLASTDIR}"
   sleep 60
done

for i in {2..2}
do
   echo "Lançando Thunder-1-$i"
   sed -e "s/NUM/1-$i/g" up_blast_local.sh | qsub -l nodes=thunder-1-2:ppn=4 -v "blastdir=${BLASTDIR}"
done
rm -rf ${BLASTDIR}/compressed/*.md5
