#!/bin/bash

DOWNLDATA="/home/mmbrand/Downloads/DeNSAS"
ASSDBDIR="/home/mmbrand/Downloads/DeNSAS/assocdb/go_201606-assocdb-tables"

#Check if $DOWNLDATA exists, if not create it
if [ ! -d "$DOWNLDATA" ]; then
    mkdir $DOWNLDATA
fi
# Go to the Downlod dir
cd $DOWNLDATA

# get updated list 
wget -N http://densas.bioinfoguy.net/update/up_URL.txt

#start the downloading
aria2c -c -i up_URL.txt -d $DOWNLDATA -s 10 -j 10 -x 2 -V true --checksum

# 
# #Update database
# 
# #############
# #Association
# #############
# 
# cd $ASSDBDIR
# mysql -uannotate -pb10ine0! -h localhost annotate < association.sql
# mysqlimport -uannotate -pb10ine0! -h localhost --use-threads=60 --local annotate $ASSDBDIR/association.txt
# 
# ########
# #dbxref
# ########
# 
# mysql -uannotate -pb10ine0! -h localhost annotate < dbxref.sql
# mysqlimport -uannotate -pb10ine0! -h localhost --use-threads=10 --local annotate $ASSDBDIR/dbxref.txt
# 
# #########
# #evidence
# #########
# 
# mysql -uannotate -pb10ine0! -h localhost annotate < evidence.sql
# mysqlimport -uannotate -pb10ine0! -h localhost --use-threads=60 --local annotate $ASSDBDIR/evidence.txt
# 
# ##############
# #gene_product
# ##############
# 
# mysql -uannotate -pb10ine0! -h localhost annotate < gene_product.sql
# mysqlimport -uannotate -pb10ine0! -h localhost --use-threads=10 --local annotate $ASSDBDIR/gene_product.txt
# 
# #########
# #species
# #########
# 
# mysql -uannotate -pb10ine0! -h localhost annotate < species.sql
# mysqlimport -uannotate -pb10ine0! -h localhost --use-threads=10 --local annotate $ASSDBDIR/species.txt
# 
# #######
# #term
# #######
# 
# mysql -uannotate -pb10ine0! -h localhost annotate < term.sql
# mysqlimport -uannotate -pb10ine0! -h localhost --use-threads=10 --local annotate $ASSDBDIR/term.txt
# 
# ################
# #gene2accession
# ################
# 
# cd $DOWNLDATA
# gunzip gene2accession.gz
# mysqlimport -uannotate -pb10ine0! -h localhost --use-threads=60 --local -d annotate $DOWNLDATA/gene2accession
# 
# ##################
# #gene_association
# ##################
# 
# zcat goa_uniprot_all.gaf.gz | cut -f 2,5,7,9 > gene_association.txt
# mysqlimport -uannotate -pb10ine0! -h localhost --use-threads=60 --local -d annotate $DOWNLDATA/gene_association.txt
# 
# ###########
# #gene_info
# ###########
# 
# gunzip gene_info.gz
# mysqlimport -uannotate -pb10ine0! -h localhost --use-threads=60 --local -d annotate $DOWNLDATA/gene_info
