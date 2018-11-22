#! perl -w
use strict;
use Data::Dumper;
use List::Util qw/ first /;

my ($unmapped,$gff3,$name) = @ARGV;

if ( -z $unmapped ){
	die "No unmapped gene found, keep processing!\n";
}

my @unmapped;
open IN,$unmapped or die $!;
while (<IN>) {
	chomp;
	push @unmapped,$_;
}
close IN;

my %gene;
open IN,$gff3 or die $!;
while (<IN>) {
	if (/\tgene\t/) {
		chomp;
		$_ = $_.';';
		my @line = split;
		my ($gene) = $line[9-1] =~ /ID=(.*?);/;
		$gene{ $gene } = join("\t",($line[1-1],$line[4-1]-1,$line[5-1]));
	}
}
close IN;

open IN, $gff3 or die $!;
while (<IN>) {
	next unless  /\tmRNA\t/ or /\ttranscript\t/;
	chomp;
	$_ = $_.';';
	my ($gene) = $_ =~ /Parent=(.*?);/;
	my ($mrna) = $_ =~ /ID=(.*?);/;
	#print "$gene\n";
	if ( first {$_ eq $mrna} @unmapped ){
		print "$gene{ $gene }\t$name\n", if exists $gene{ $gene };
	}
}
close IN;
