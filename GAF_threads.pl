#!/usr/bin/perl
# BASEADO EM http://www.dreamincode.net/forums/topic/255487-multithreading-in-perl/
use strict;
use threads;
use POSIX qw/ceil/;
use Benchmark qw(:hireswallclock);

my $starttime = Benchmark->new;
my $finishtime;
my $timespent;
my $num_of_threads = 32;
my $contarTotal = 100000000;
my $piece = ceil($contarTotal / $num_of_threads);
# cria o número de threads para rodar
my @threads = initThreads();

# chama os threads
foreach(@threads){
        print $_;
		$_ = threads->create(\&doOperation);
	}
foreach(@threads){
	$_->join();
}
$finishtime = Benchmark->new;
$timespent = timediff($finishtime,$starttime);
print "\nDone!\nSpent ". timestr($timespent);

print "\n\nNow trying without threading:\n\n";

my $starttime = Benchmark->new;

doWithoutThread();

$finishtime = Benchmark->new;
$timespent = timediff($finishtime,$starttime);
select(STDOUT);
print "\nDone!\nSpent ". timestr($timespent);

print "\nProgram Done!\nPress Enter to exit";
$a = <>;

sub initThreads{
	my @initThreads;
	for(my $i = 1;$i<=$num_of_threads;$i++){
                print $i,"\n";
		push(@initThreads,$i);
	}
	return @initThreads;
}
sub doOperation{
	# Get the thread id. Allows each thread to be identified.
	my $id = threads->tid();
        my $i = ($id - 1) * ($id * $piece);
	my $END = ($id * $piece);
	while($i < $END){
			$i++
	}
	print "Thread $id done!\n";
	# Exit the thread
	threads->exit();
}
sub doWithoutThread{
	my $c = 0;
	#for(my $i=0;$i<$num_of_threads;$i++){
		while($c < 100000000){
			$c++;
		}
		$c=0;
		#print "Count $i done!\n";
                print "Count done!\n";
	#}
}

