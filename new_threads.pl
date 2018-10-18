#!/usr/bin/perl

use strict;
use threads;

# Define the number of threads
my $num_of_threads = 1;

# use the initThreads subroutine to create an array of threads.
my @threads = initThreads();
open FILE, "teste_hla.txt" or die $!; # open Header file to search for GOs
# Loop through the array:
foreach(@threads){
                # Tell each thread to perform our 'doOperation()' subroutine.
		$_ = threads->create(\&doOperation);
}

# This tells the main program to keep running until all threads have finished.
foreach(@threads){
	$_->join();
}

# print "\nProgram Done!\nPress Enter to exit";
# $a = <>;


sub initThreads{
        # An array to place our threads in
	my @initThreads;
	for(my $i = 1;$i<=$num_of_threads;$i++){
		push(@initThreads,$i);
	}
	return @initThreads;
}

sub doOperation{
	# Get the thread id. Allows each thread to be identified.
	my $id = threads->tid();
#open file 
while (my $fstHEADER = <FILE>) {
print $fstHEADER;
}
#end while
# Inform us that the thread is done and exit the thread.
	print "Thread $id done!\n";
	threads->exit();
}
