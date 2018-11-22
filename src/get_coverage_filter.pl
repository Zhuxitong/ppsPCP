use strict;
use warnings;
use Bio::SeqIO;
use Bio::Seq;

my ($fl,$fa,$ou,$ou2,$cov,$sim) = @ARGV;
my $in = Bio::SeqIO->new(-file=>$fa,-format=>"Fasta");
my $out = Bio::SeqIO->new(-file=>">$ou",-format=>"Fasta");
open OU2,">$ou2";
open FL,$fl;
my %hash;
while(my $sub = $in->next_seq()){
	my $id = $sub->id;
	$hash{$id} = $sub;
}

my %res;
while(<FL>){
	my @arr = split /\t/;
	if (!exists($res{$arr[0]})){
		my $align = abs($arr[6] - $arr[7]) + 1;
		my $length = length( $hash{$arr[0]} -> seq() );
		my $coverage = $align/($length);
		$res{$arr[0]}++;
#		if ($coverage < 0.8 or $arr[2] < 90){
#		print "$coverage\t$cov\t$arr[2]\t$sim\n";
		if ($coverage < $cov and $arr[2] < $sim){
			$out->write_seq($hash{$arr[0]});
			print OU2 "$arr[0]\t$arr[1]\t$arr[8]\t$arr[9]\n";
		}
	}
}
close OU2;
close FL;
