#!/bin/bash

DOWNLDATA="/home/mmbrand/Downloads/DeNSAS"
ASSDBDIR="/home/mmbrand/Downloads/DeNSAS/assocdb/"

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

#Deal with GO assocdb file
#Create dir if not exists
if [ ! -d "$ASSDBDIR" ]; then
    mkdir $ASSDBDIR
fi

#Move downloaded file
mv go_monthly-assocdb-data.gz $ASSDBDIR

cd $ASSDBDIR

gunzip go_monthly-assocdb-data.gz

#Split single SQL into various
./mysql_splitdump.sh go_monthly-assocdb-data


#Update database

#############
#Association
#############

mysql -uannotate -pb10ine0! -h 143.106.4.169 annotate < association.sql &
# mysqlimport -uannotate -pb10ine0! -h 143.106.4.169 --use-threads=10 --local annotate association.txt

########
#dbxref
########

mysql -uannotate -pb10ine0! -h 143.106.4.169 annotate < dbxref.sql &
# mysqlimport -uannotate -pb10ine0! -h 143.106.4.169 --use-threads=10 --local annotate $ASSDBDIR/dbxref.txt

#########
#evidence
#########

mysql -uannotate -pb10ine0! -h 143.106.4.169 annotate < evidence.sql &
# mysqlimport -uannotate -pb10ine0! -h 143.106.4.169 --use-threads=10 --local annotate $ASSDBDIR/evidence.txt

##############
#gene_product
##############

mysql -uannotate -pb10ine0! -h 143.106.4.169 annotate < gene_product.sql &
# mysqlimport -uannotate -pb10ine0! -h 143.106.4.169 --use-threads=10 --local annotate $ASSDBDIR/gene_product.txt

#########
#species
#########

mysql -uannotate -pb10ine0! -h 143.106.4.169 annotate < species.sql &
# mysqlimport -uannotate -pb10ine0! -h 143.106.4.169 --use-threads=10 --local annotate $ASSDBDIR/species.txt

#######
#term
#######

mysql -uannotate -pb10ine0! -h 143.106.4.169 annotate < term.sql &
# mysqlimport -uannotate -pb10ine0! -h 143.106.4.169 --use-threads=10 --local annotate $ASSDBDIR/term.txt

############
#graph_path
############

mysql -uannotate -pb10ine0! -h 143.106.4.169 annotate < graph_path.sql &

wait



################
#gene2accession
################

cd $DOWNLDATA
gunzip gene2accession.gz
mysqlimport -uannotate -pb10ine0! -h 143.106.4.169 --use-threads=10 --local --ignore-lines=1 --columns "tax_id,GeneID,status,RNA_nucleotide_accession,RNA_nucleotide_gi,protein_accession,protein_gi,genomic_nucleotide_accession,genomic_nucleotide_gi,start_position,end_positon,orientation,assembly" --delete -d densas $DOWNLDATA/gene2accession

##################
#gene_association
##################

zcat goa_uniprot_all.gaf.gz | cut -f 2,5,7,9 > gene_association.txt
mysqlimport -uannotate -pb10ine0! -h 143.106.4.169 --use-threads=10 --local --delete --columns "Object_ID,GO_ID,Evidence,GO_aspect" -d densas $DOWNLDATA/gene_association.txt

###########
#gene_info
###########

gunzip gene_info.gz
mysqlimport -uannotate -pb10ine0! -h 143.106.4.169 --use-threads=10 --local --delete -d densas $DOWNLDATA/gene_info

###############
#MEROPS_DOMAIN
###############

mv domain.txt MEROPS_domain.txt
mysqlimport -uannotate -pb10ine0! -h 143.106.4.169 --use-threads=30 --local --delete --fields-enclosed-by=\" -d densas $DOWNLDATA/MEROPS_domain.txt

###########
#MEROPS2GO
###########

mv GO_annotation.txt MEROPS2GO.txt
mysqlimport -uannotate -pb10ine0! -h 143.106.4.169 --use-threads=30 --local --delete --fields-enclosed-by=\" -d densas $DOWNLDATA/MEROPS2GO.txt

#########
#GO_term
#########

mysql -uannotate -pb10ine0! -h bioinfo.cbmeg.unicamp.br densas -e "SELECT DISTINCT
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

mysqlimport -uannotate -pb10ine0! -h 143.106.4.169 --use-threads=10 --local --ignore-lines=1 --delete -d densas $DOWNLDATA/GO_term.txt

######
#RFAM
######

mv family.txt.gz RFAM.txt.gz
gunzip RFAM.txt.gz
mysqlimport -uannotate -pb10ine0! -h 143.106.4.169 --use-threads=10 --local --delete -d densas $DOWNLDATA/RFAM.txt

#########
#RFAM2GO
#########

mysqlimport -uannotate -pb10ine0! -h 143.106.4.169 --use-threads=10 --local --delete --columns "rfam_id,GO_ID" -d densas $DOWNLDATA/RFAM2GO.txt

########
#gi2tax
########

zcat gi_taxid_nucl.zip gi_taxid_prot.zip > gi2tax.txt
mysqlimport -uannotate -pb10ine0! -h 143.106.4.169 --use-threads=10 --local --delete -d densas $DOWNLDATA/gi2tax.txt

############
#gi2uniprot
############

perl DeNSAS/Update/Create_gi2uniprot2.pl $DOWNLDATA/idmapping.tb > gi2uniprot.txt
mysqlimport -uannotate -pb10ine0! -h 143.106.4.169 --use-threads=10 --local --delete --columns "UniprotKB_acc,UniprotKB_id,GI" -d densas $DOWNLDATA/gi2uniprot.txt
