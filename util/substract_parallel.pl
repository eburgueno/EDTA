#!/usr/bin/perl -w
use strict;
use threads;
use Thread::Queue;

#usage: perl sustract.pl minuend.list subtrahend.list
#Author: Shujun Ou (oushujun@msu.edu), 03/08/2015
#
#
#minuend − subtrahend = difference
open Minuend, "<$ARGV[0]" or die $!;
open Subtrahend, "<$ARGV[1]" or die $!;
open Diff, ">$ARGV[0]-$ARGV[1]" or die $!;

my %substr;
while (<Subtrahend>){
	next if /^\s+$/;
	my ($chr, $from, $to)=(split)[0,1,2];
	push @{$substr{$chr}}, [$from, $to];
	}

# multi-threading using queue, put candidate regions into queue for parallel computation
my $queue = Thread::Queue->new();
foreach my $chr (keys %substr){
	last unless defined $substr{$chr};
	$queue->enqueue($chr);
	}



#my %minuend;
my $keep=1;
while (<Minuend>){
	next if /^\s+$/;
	my ($chr, $from, $to)=(split)[0,1,2];
	Run:
	foreach my $info (@{$substr{$chr}}){
		my @range=@{$info};
		last if $range[0]>$to;
		next if $range[1]<$from;
		$keep=0 if ($range[0]<=$from and $range[1]>=$to);
		if ($range[0]>$from){
			$keep=0;
			$range[0]--;
			print Diff "$chr\t$from\t$range[0]\n";
			} # if $range[0]>$from;
		if ($range[1]<$to){
			$from=$range[1]+1;
			$keep=1;
			goto Run;
			}
		}
	print Diff "$chr\t$from\t$to\n" if $keep==1;
	$keep=1;
	}

sub subtract(){
	while (defined($_ = $queue->dequeue())){
		next unless exists $substr{$chr};
		my @range=@{$substr{$chr}};
#		my ($id, $coor) = (@{$_}[0], @{$_}[1]);
