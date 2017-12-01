#!/usr/bin/env perl

use strict;
use warnings;

my %stuff; 

my ( $id, @header ) = split '\t', <>;

while ( <> ) { 
   my ( $key, @values ) = split; 
   my %row;
   @row{@header} = @values; 
   push ( @{$stuff{$key}{$_}}, $row{$_} ) for keys %row;
}

print join ( "\t", $id, @header),"\n";
foreach my $key ( sort keys %stuff ) {
   print join ("\t", $key, map { join ";", @{$stuff{$key}{$_}}} @header), "\n";
}
