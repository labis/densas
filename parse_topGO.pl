#!/usr/bin/env perl

use strict;
use warnings;
use Getopt::Long;

my ($infile);
    GetOptions ('infile=s' => \$infile);
        if ((!$infile)) {
    print "Some required arguments are missing.\nYou must use this as follow:\n$0 --infile [Annotation file]\n";
    exit 1
}
#based on https://unix.stackexchange.com/questions/264058/merge-multiple-lines-in-same-file-based-on-column-1

my %anDATA; 
open(DATA, $infile) or die "Couldn't open file file.txt, $!";

my ( $id, @anLINE ) = split '\t', <DATA>;
splice @anLINE, 0, 3;
while ( <DATA> ) { 
   my ( $key, @values ) = split; 
   my %row;
   @row{@anLINE} = @values; 
   push ( @{$anDATA{$key}{$_}}, $row{$_} ) for keys %row;
}

# print join ( "\t", $id, @anLINE),"\n"; # first row as header
foreach my $key ( sort keys %anDATA ) {
   print join ("\t", $key, map { join ",", @{$anDATA{$key}{$_}}} @anLINE), "\n";
}
