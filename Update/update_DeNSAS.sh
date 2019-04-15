#!/bin/bash

#Set all variables
DOWNLDATA="/home/mmbrand/Downloads/DeNSAS"
ASSDBDIR="${DOWNLOAD}/assocdb/"
DBSERVER="143.106.4.87"
DBNAME="densas"
DBUSER="densas"
DBPASS="b10ine0!"
DensasDIR="/home/mmbrand/DeNSAS"
#Deal with all directories
#Check if $DOWNLDATA exists, if not create it
if [ ! -d "$DOWNLDATA" ]; then
    mkdir $DOWNLDATA
fi

#GO assocdb file
#Create dir if not exists
if [ ! -d "$ASSDBDIR" ]; then
    mkdir $ASSDBDIR
fi

# Go to the Downlod dir
cd $DOWNLDATA

# get updated list 
echo $(date -u) "Update the download list"
wget -N http://densas.bioinfoguy.net/update/up_URL.txt

#start the downloading
echo $(date -u) "Start the downloading"
aria2c -c -i up_URL.txt -d $DOWNLDATA -s 10 -j 10 -x 2 -V true --checksum

#Deal with GO assocdb file
#Move downloaded file
echo $(date -u) "Dealing with GO assocdb file"
mv go_monthly-assocdb-data.gz $ASSDBDIR

cd $ASSDBDIR

gunzip go_monthly-assocdb-data.gz

#Split single SQL into various
./mysql_splitdump.sh go_monthly-assocdb-data

#Update database
echo $(date -u) "Update the database"
#############
#Association
#############

mysql -u $DBUSER -p $DBPASS -h $DBSERVER $DBNAME < association.sql &
# mysqlimport -u $DBUSER -p $DBPASS -h $DBSERVER --use-threads=10 --local $DBNAME association.txt

########
#dbxref
########

mysql -u $DBUSER -p $DBPASS -h $DBSERVER $DBNAME < dbxref.sql &
# mysqlimport -u $DBUSER -p $DBPASS -h $DBSERVER --use-threads=10 --local $DBNAME $ASSDBDIR/dbxref.txt

#########
#evidence
#########

mysql -u $DBUSER -p $DBPASS -h $DBSERVER $DBNAME < evidence.sql &
# mysqlimport -u $DBUSER -p $DBPASS -h $DBSERVER --use-threads=10 --local $DBNAME $ASSDBDIR/evidence.txt

##############
#gene_product
##############

mysql -u $DBUSER -p $DBPASS -h $DBSERVER $DBNAME < gene_product.sql &
# mysqlimport -u $DBUSER -p $DBPASS -h $DBSERVER --use-threads=10 --local $DBNAME $ASSDBDIR/gene_product.txt

#########
#species
#########

mysql -u $DBUSER -p $DBPASS -h $DBSERVER $DBNAME < species.sql &
# mysqlimport -u $DBUSER -p $DBPASS -h $DBSERVER --use-threads=10 --local $DBNAME $ASSDBDIR/species.txt

#######
#term
#######

mysql -u $DBUSER -p $DBPASS -h $DBSERVER $DBNAME < term.sql &
# mysqlimport -u $DBUSER -p $DBPASS -h $DBSERVER --use-threads=10 --local $DBNAME $ASSDBDIR/term.txt

############
#graph_path
############

mysql -u $DBUSER -p $DBPASS -h $DBSERVER $DBNAME < graph_path.sql &

wait



################
#gene2accession
################

cd $DOWNLDATA
gunzip gene2accession.gz
mysqlimport -u $DBUSER -p $DBPASS -h $DBSERVER --use-threads=10 --local --ignore-lines=1 --columns "tax_id,GeneID,status,RNA_nucleotide_accession,RNA_nucleotide_gi,protein_accession,protein_gi,genomic_nucleotide_accession,genomic_nucleotide_gi,start_position,end_positon,orientation,assembly" --delete -d densas $DOWNLDATA/gene2accession

##################
#gene_association
##################

zcat goa_uniprot_all.gaf.gz | cut -f 2,5,7,9 > gene_association.txt
mysqlimport -u $DBUSER -p $DBPASS -h $DBSERVER --use-threads=10 --local --delete --columns "Object_ID,GO_ID,Evidence,GO_aspect" -d densas $DOWNLDATA/gene_association.txt

###########
#gene_info
###########

gunzip gene_info.gz
mysqlimport -u $DBUSER -p $DBPASS -h $DBSERVER --use-threads=10 --local --delete -d densas $DOWNLDATA/gene_info

###############
#MEROPS_DOMAIN
###############

mv domain.txt MEROPS_domain.txt
mysqlimport -u $DBUSER -p $DBPASS -h $DBSERVER --use-threads=30 --local --delete --fields-enclosed-by=\" -d densas $DOWNLDATA/MEROPS_domain.txt

###########
#MEROPS2GO
###########

mv GO_annotation.txt MEROPS2GO.txt
mysqlimport -u $DBUSER -p $DBPASS -h $DBSERVER --use-threads=30 --local --delete --fields-enclosed-by=\" -d densas $DOWNLDATA/MEROPS2GO.txt

#########
#GO_term
#########

mysql -u $DBUSER -p $DBPASS -h $DBSERVER densas -e "SELECT DISTINCT
  term.acc AS go_id,
  term.name AS term,
  CASE WHEN term.term_type = 'biological_process' THEN 'P' WHEN term.term_type = 'molecular_function' THEN 'F' WHEN term.term_type = 'cellular_component' THEN 'C' END AS category,
  p.distance
FROM term
  INNER JOIN graph_path p
    ON p.term2_id = term.id
  INNER JOIN term root
    ON p.term1_id = root.id
WHERE root.is_root = 1
AND term.is_obsolete <> 1;" > $DOWNLDATA/GO_term.txt

mysqlimport -u $DBUSER -p $DBPASS -h $DBSERVER --use-threads=10 --local --ignore-lines=1 --delete -d densas $DOWNLDATA/GO_term.txt

######
#RFAM
######

mv family.txt.gz RFAM.txt.gz
gunzip RFAM.txt.gz
mysqlimport -u $DBUSER -p $DBPASS -h $DBSERVER --use-threads=10 --local --delete -d densas $DOWNLDATA/RFAM.txt

#########
#RFAM2GO
#########

mysqlimport -u $DBUSER -p $DBPASS -h $DBSERVER --use-threads=10 --local --delete --columns "rfam_id,GO_ID" -d densas $DOWNLDATA/RFAM2GO.txt

########
#gi2tax
########

zcat gi_taxid_nucl.zip gi_taxid_prot.zip > gi2tax.txt
mysqlimport -u $DBUSER -p $DBPASS -h $DBSERVER --use-threads=10 --local --delete -d densas $DOWNLDATA/gi2tax.txt

############
#gi2uniprot
############

perl $DensasDIR/Update/Create_gi2uniprot2.pl $DOWNLDATA/idmapping.tb > gi2uniprot.txt
mysqlimport -u $DBUSER -p $DBPASS -h $DBSERVER --use-threads=10 --local --delete --columns "UniprotKB_acc,UniprotKB_id,GI" -d densas $DOWNLDATA/gi2uniprot.txt

##########
#pfamA2GO
##########

mysqlimport -u $DBUSER -p $DBPASS -h $DBSERVER --use-threads=30 --local --delete --columns "pfamA_acc,go_id" -d densas $DOWNLDATA/pfamA2GO.txt
