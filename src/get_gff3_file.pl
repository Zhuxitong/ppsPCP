#! perl -w
use strict;

#get file
my ($intersect, $gff3, $gff_res) = @ARGV;

#parse gff3
open IN, $gff3 or die $!;
my %gene;
my $name;
while (<IN>) {
	chomp;
	next if (/^#/ or /\tchromosome\t/ or /\tcontig\t/ or /\tscaffold\t/ or /^$/);
	if (/\tgene\t/) {
		$_ = $_.";";
		($name) = $_ =~ /ID=(.*?);/;
		push @{ $gene{ $name } }, $_;
	}
	else {
		push @{ $gene{ $name } }, $_;
	}
}
close IN;


open IN, $intersect or die $!;
open OUT,">$gff_res" or die $!;
while (<IN>) {
	chomp;
	$_		 = $_.";";
	my ($id) = $_ =~ /ID=(.*?);/;
	my @arr  = split/\t/;
	if (exists $gene{$id}){
		for my $line (@{ $gene{$id} }){
			my @f  = split/\t/,$line;
			$f[4-1] = $f[4-1] + $arr[4] - $arr[1];
			$f[5-1] = $f[5-1] + $arr[4] - $arr[1];
			print OUT join("\t",$arr[3],@f[2-1..9-1]),"\n";
		}
	}
}
close IN;
close OUT;
