#!/bin/bash

#Set all variables
DOWNLDATA="/share/thunderstorm2/densas_db"
ASSDBDIR="${DOWNLDATA}/assocdb/"
DBSERVER="143.106.4.87"
DBNAME="densas"
DBUSER="annotate"
DBPASS="b10ine0!"
DensasDIR="/home/mmbrand/Experimentos/densas"
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
#echo $(date -u) "Update the download list"
#wget -N http://densas.bioinfoguy.net/update/up_URL.txt

#start the downloading
#echo $(date -u) "Start the downloading"
#aria2c -c -i $DensasDIR/Update/up_URL.txt -d $DOWNLDATA -s 10 -j 10 -x 2 -V true

#Deal with GO assocdb file
#Move downloaded file
echo $(date -u) "Dealing with GO assocdb file"
mv go_monthly-assocdb-data.gz $ASSDBDIR

cd $ASSDBDIR

gunzip go_monthly-assocdb-data.gz

#Split single SQL into various
bash $DensasDIR/Update/mysql_splitdump.sh go_monthly-assocdb-data

#Update database
echo $(date -u) "Update the GO database"
#############
#Association
#############

mysql -u$DBUSER -p$DBPASS -h $DBSERVER $DBNAME < association.sql &
# mysqlimport -u$DBUSER -p$DBPASS -h $DBSERVER --use-threads=10 --local $DBNAME association.txt

########
#dbxref
########

mysql -u$DBUSER -p$DBPASS -h $DBSERVER $DBNAME < dbxref.sql &
# mysqlimport -u$DBUSER -p$DBPASS -h $DBSERVER --use-threads=10 --local $DBNAME $ASSDBDIR/dbxref.txt

#########
#evidence
#########

mysql -u$DBUSER -p$DBPASS -h $DBSERVER $DBNAME < evidence.sql &
# mysqlimport -u$DBUSER -p$DBPASS -h $DBSERVER --use-threads=10 --local $DBNAME $ASSDBDIR/evidence.txt

##############
#gene_product
##############

mysql -u$DBUSER -p$DBPASS -h $DBSERVER $DBNAME < gene_product.sql &
# mysqlimport -u$DBUSER -p$DBPASS -h $DBSERVER --use-threads=10 --local $DBNAME $ASSDBDIR/gene_product.txt

#########
#species
#########

mysql -u$DBUSER -p$DBPASS -h $DBSERVER $DBNAME < species.sql &
# mysqlimport -u$DBUSER -p$DBPASS -h $DBSERVER --use-threads=10 --local $DBNAME $ASSDBDIR/species.txt

#######
#term
#######

mysql -u$DBUSER -p$DBPASS -h $DBSERVER $DBNAME < term.sql &
# mysqlimport -u$DBUSER -p$DBPASS -h $DBSERVER --use-threads=10 --local $DBNAME $ASSDBDIR/term.txt

############
#graph_path
############

mysql -u$DBUSER -p$DBPASS -h $DBSERVER $DBNAME < graph_path.sql &

wait

# Clean the mess
rm -rf *.sql

################
#gene2accession
################

cd $DOWNLDATA
echo $(date -u) "Update the gene2accession database"
gunzip gene2accession.gz
mysqlimport -u$DBUSER -p$DBPASS -h $DBSERVER --use-threads=10 --local --ignore-lines=1 --columns "tax_id,GeneID,status,RNA_nucleotide_accession,RNA_nucleotide_gi,protein_accession,protein_gi,genomic_nucleotide_accession,genomic_nucleotide_gi,start_position,end_positon,orientation,assembly" --delete -d densas $DOWNLDATA/gene2accession

##################
#gene_association
##################

echo $(date -u) "Update the gene_association database"
zcat goa_uniprot_all.gaf.gz | cut -f 2,5,7,9 > gene_association.txt
mysqlimport -u$DBUSER -p$DBPASS -h $DBSERVER --use-threads=10 --local --delete --columns "Object_ID,GO_ID,Evidence,GO_aspect" -d densas $DOWNLDATA/gene_association.txt

###########
#gene_info
###########

echo $(date -u) "Update the gene_info database"
gunzip gene_info.gz
mysqlimport -u$DBUSER -p$DBPASS -h $DBSERVER --use-threads=10 --local --delete -d densas $DOWNLDATA/gene_info

###############
#MEROPS_DOMAIN
###############

echo $(date -u) "Update the Merops database"
mv domain.txt MEROPS_domain.txt
mysqlimport -u$DBUSER -p$DBPASS -h $DBSERVER --use-threads=30 --local --delete --fields-enclosed-by=\" -d densas $DOWNLDATA/MEROPS_domain.txt

###########
#MEROPS2GO
###########

mv GO_annotation.txt MEROPS2GO.txt
mysqlimport -u$DBUSER -p$DBPASS -h $DBSERVER --use-threads=30 --local --delete --fields-enclosed-by=\" -d densas $DOWNLDATA/MEROPS2GO.txt

#########
#GO_term
#########

echo $(date -u) "Preparing and Update the GO_term database"
mysql -u$DBUSER -p$DBPASS -h $DBSERVER densas -e "SELECT DISTINCT
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

mysqlimport -u$DBUSER -p$DBPASS -h $DBSERVER --use-threads=10 --local --ignore-lines=1 --delete -d densas $DOWNLDATA/GO_term.txt

######
#RFAM
######

echo $(date -u) "Update the RFAM database"
mv family.txt.gz RFAM.txt.gz
gunzip RFAM.txt.gz
mysqlimport -u$DBUSER -p$DBPASS -h $DBSERVER --use-threads=10 --local --delete -d densas $DOWNLDATA/RFAM.txt

#########
#RFAM2GO
#########

echo $(date -u) "Update the RFAM2GO database"
awk '{print $1, $NF;}' rfam2go | sed -e 's/Rfam://g' > $DOWNLDATA/RFAM2GO.txt
mysqlimport -u$DBUSER -p$DBPASS -h $DBSERVER --use-threads=10 --local --delete --columns "rfam_id,GO_ID" -d densas $DOWNLDATA/RFAM2GO.txt

########
#gi2tax
########

echo $(date -u) "Update the gi2tax database"
zcat gi_taxid_prot.dmp.gz > gi2tax.txt &
zcat gi_taxid_nucl.dmp.gz >> gi2tax.txt &
wait
mysqlimport -u$DBUSER -p$DBPASS -h $DBSERVER --use-threads=10 --local --delete -d densas $DOWNLDATA/gi2tax.txt

############
#gi2uniprot
############

echo $(date -u) "Update the gi2uniprot database"
perl $DensasDIR/Update/Create_gi2uniprot2.pl $DOWNLDATA/idmapping.tb > gi2uniprot.txt
mysqlimport -u$DBUSER -p$DBPASS -h $DBSERVER --use-threads=10 --local --delete --columns "UniprotKB_acc,UniprotKB_id,Accession,GI" -d densas $DOWNLDATA/gi2uniprot.txt

##########
#pfamA2GO
##########

echo $(date -u) "Update the pfam2GO database"
awk '{print $1, $NF;}' pfam2go | sed -e 's/Pfam://g' > $DOWNLDATA/pfamA2GO.txt
mysqlimport -u$DBUSER -p$DBPASS -h $DBSERVER --use-threads=30 --local --delete --columns "pfamA_acc,go_id" -d densas $DOWNLDATA/pfamA2GO.txt

##########
#pfamA
##########

echo $(date -u) "Update the pfamA database"
gunzip pfamA.txt.gz
mysqlimport -u$DBUSER -p$DBPASS -h $DBSERVER --use-threads=30 --local --delete -d densas $DOWNLDATA/pfamA.txt
