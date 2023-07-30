
#!/bin/bash
# Set all variables
# DBRAW       Where all files will be downloaded 
# THUNDERSRV  Remote data server
# SCRIPTSDIR  Where DeNDAS are located

DBRAW="/share/thunderstorm2/densas_db/raw"
THUNDERSRV=thunder
SCRIPTSDIR=/home/mmbrand/Experimentos/densas/Update

# Create all diretories

if [ ! -d "${DBRAW}" ]; then
    mkdir  ${DBRAW}
fi

# Go to RAW directory and start Downloading
cd $DBRAW

###################
#START DOWNLOADING
###################

# rsync -auh --quiet ftp.ncbi.nlm.nih.gov::blast/db/FASTA/swissprot.gz ${BLASTDIR}/compressed/&
# rsync -auh --quiet ftp.ncbi.nlm.nih.gov::blast/db/nr*.* ${BLASTDIR}/compressed/&
wget --quiet ftp.ncbi.nlm.nih.gov/blast/db/FASTA/nr.gz &
# rsync -auh --quiet ftp.ncbi.nlm.nih.gov::blast/db/FASTA/nr.gz ${DBRAW}&
rsync -auh --quiet --exclude md5 ftp.ncbi.nlm.nih.gov::blast/db/refseq_protein*.* ${DBRAW} &
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

# for i in {0..6}
# do
#    echo "Lançando Thunder-0-$i"
#    sed -e "s/NUM/0-$i/g" up_blast_local.sh | qsub -v "blastdir=${BLASTDIR}"
#    sleep 60
# done
