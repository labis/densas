DOWNLDATA="/home/mmbrand/Downloads/DeNSAS"
ASSDBDIR="/home/mmbrand/Downloads/DeNSAS/assocdb/go_201606-assocdb-tables"
# cd $DOWNLDATA
# wget -c -q -nd -r --no-parent -Aassocdb-data.gz --reject html,txt  http://archive.geneontology.org/latest-full/ &
# wget -c -q -nd ftp://ftp.ncbi.nlm.nih.gov/gene/DATA/gene2accession.gz &
# wget -c -q -nd ftp://ftp.ebi.ac.uk/pub/databases/GO/goa/UNIPROT/gene_association.goa_ref_uniprot.gz &
# wget -c -q -nd ftp://ftp.ebi.ac.uk/pub/databases/GO/goa/UNIPROT/goa_uniprot_all.gaf.gz &
# wget -c -q -nd ftp://ftp.ncbi.nlm.nih.gov/gene/DATA/gene_info.gz & 
# wget -c -q -nd ftp://ftp.pir.georgetown.edu/databases/idmapping/idmapping.tb.gz &
# wget -c -q -nd ftp://ftp.ebi.ac.uk/pub/databases/Pfam/current_release/database_fi les/pfamA.innodb.sql.gz &
# wget -c -q -nd ftp://ftp.ebi.ac.uk/pub/databases/Pfam/current_release/database_files/pfamA.txt.gz &
# wget -c -q -nd http://geneontology.org/external2go/pfam2go &
# wget -c -q -nd http://geneontology.org/external2go/rfam2go &
# wget -c -q -nd ftp://ftp.ebi.ac.uk/pub/databases/Rfam/CURRENT/database_files/family.sql.gz &
# wget -c -q -nd ftp://ftp.ebi.ac.uk/pub/databases/Rfam/CURRENT/database_files/family.txt.gz &
# wget -c -q -nd ftp://ftp.ncbi.nlm.nih.gov/pub/taxonomy/gi_taxid_prot.zip &
# wget -c -q -nd ftp://ftp.ncbi.nlm.nih.gov/pub/taxonomy/gi_taxid_nucl.zip &
# wget -c -q -nd ftp://ftp.sanger.ac.uk/pub/MEROPS/current_release/database_files/domain.sql &
# wget -c -q -nd ftp://ftp.sanger.ac.uk/pub/MEROPS/current_release/database_files/domain.txt &
# wget -c -q -nd ftp://ftp.sanger.ac.uk/pub/MEROPS/current_release/database_files/GO_annotation.sql &
# wget -c -q -nd ftp://ftp.sanger.ac.uk/pub/MEROPS/current_release/database_files/GO_annotation.txt &
# wait


#Tabelas

#############
#Association
#############

cd $ASSDBDIR
mysql -uannotate -pb10ine0! -h localhost annotate < association.sql
mysqlimport -uannotate -pb10ine0! -h localhost --use-threads=60 --local annotate $ASSDBDIR/association.txt

########
#dbxref
########

mysql -uannotate -pb10ine0! -h localhost annotate < dbxref.sql
mysqlimport -uannotate -pb10ine0! -h localhost --use-threads=10 --local annotate $ASSDBDIR/dbxref.txt

#########
#evidence
#########

mysql -uannotate -pb10ine0! -h localhost annotate < evidence.sql
mysqlimport -uannotate -pb10ine0! -h localhost --use-threads=60 --local annotate $ASSDBDIR/evidence.txt

##############
#gene_product
##############

mysql -uannotate -pb10ine0! -h localhost annotate < gene_product.sql
mysqlimport -uannotate -pb10ine0! -h localhost --use-threads=10 --local annotate $ASSDBDIR/gene_product.txt

#########
#species
#########

mysql -uannotate -pb10ine0! -h localhost annotate < species.sql
mysqlimport -uannotate -pb10ine0! -h localhost --use-threads=10 --local annotate $ASSDBDIR/species.txt

#######
#term
#######

mysql -uannotate -pb10ine0! -h localhost annotate < term.sql
mysqlimport -uannotate -pb10ine0! -h localhost --use-threads=10 --local annotate $ASSDBDIR/term.txt

################
#gene2accession
################

cd $DOWNLDATA
gunzip gene2accession.gz
mysqlimport -uannotate -pb10ine0! -h localhost --use-threads=60 --local -d annotate $DOWNLDATA/gene2accession

##################
#gene_association
##################

zcat goa_uniprot_all.gaf.gz | cut -f 2,5,7,9 > gene_association.txt
mysqlimport -uannotate -pb10ine0! -h localhost --use-threads=60 --local -d annotate $DOWNLDATA/gene_association.txt

###########
#gene_info
###########

gunzip gene_info.gz
mysqlimport -uannotate -pb10ine0! -h localhost --use-threads=60 --local -d annotate $DOWNLDATA/gene_info
