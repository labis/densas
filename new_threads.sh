#!/usr/bin/Perl

# Always good practice
use strict;
# The threads module allows us to implement threading in our script
use threads;

# The number of threads used in the script
my $num_of_threads = 2;

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
	my $i = 0;
	while($i < 100000000){
			$i++
	}
        # Inform us that the thread is done and exit the thread.
	print "Thread $id done!\n";
	threads->exit();
}
