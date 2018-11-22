#! perl -w
use strict;
use Data::Dumper;

my ($mapped,$all,$unmapped) = @ARGV;

my %mapped;
open IN,$mapped or die $!;
while (<IN>) {
	chomp;
	my @line = split;
	$mapped{ $line[0] } = 1;
}
close IN;
#print Dumper(\%mapped);

my %unmapped;
open IN,$all or die $!;
while (<IN>) {
	next if !/^>/;
	chomp;
	s/>//;
	$unmapped{ $_ } = 1  if !exists $mapped{ $_ };
}
close IN;

open OUT,">$unmapped" or die $!;
for my $key ( sort {$a cmp $b } keys %unmapped ) {
	print OUT "$key\n";
}
close OUT;
