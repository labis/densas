#!/usr/bin/perl -w
use strict;
use DBI;
my $platform = "mysql";
my $database = "SPDK";
my $host = "143.106.4.249";
my $port = "3306";
my $user = "annotate";
my $pw = "b10ine0!";
#Conects to the MySQL database
my $dbh = DBI->connect("dbi:mysql:$database:$host:$port", "$user", "$pw",
                    { RaiseError => 1, AutoCommit => 0 });

#############
# SUBROUTINE
#############

sub MontaGO {
     my ($seqNAME_all) = @_; # Get the sequence name
     my @MontaGO_ALL; #Array para guardar os dados de cada anotação 
     my $GO_ALL = $dbh->selectall_arrayref("SELECT SPDK2_ann.GOID FROM SPDK.SPDK2_ann WHERE SPDK2_ann.Seqname = '".$seqNAME_all."'");
foreach my $row2 (@$GO_ALL) {
     my ($GO_ID) = @$row2;
     push(@MontaGO_ALL, $GO_ID); # coloca todos os resultados em um array
     }
print "$seqNAME_all\t"; # mostra o nome da sequencia
print join(', ', @MontaGO_ALL), "\n"; # Monta todos os GOS
}


my $GENEALL = $dbh->selectall_arrayref("
           SELECT
  SPDK2_ann.Seqname
FROM SPDK2_ann
GROUP BY SPDK2_ann.Seqname                              
")
  or die "print unable to connect to the DB";


 my @TESTEALL; 
foreach my $row (@$GENEALL) {
     my ($Seqname) = @$row;
     MontaGO($Seqname);
     }