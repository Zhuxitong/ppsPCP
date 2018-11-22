use strict;
use warnings;
use Bio::SeqIO;
use Bio::Seq;
my ($list,$fa,$ou,$anno,$bed,$name) = @ARGV;
my $in = Bio::SeqIO->new(-file=>$fa,-format=>"Fasta");
my $out = Bio::SeqIO->new(-file=>">$ou",-format=>"Fasta");
open LI,$list;
open OU, ">$anno";
open BE, ">$bed";
my %hash;
while(my $sub = $in->next_seq()){
	my $id = $sub->id;
	my $seq = $sub->seq;
	$hash{$id} = $seq;
}
my %pos;
while(<LI>){
	chomp;
	my @arr = split /\t/;
	$pos{$arr[0]}{$arr[4]}{$arr[5]}++;
}
my $seq = "N" x 100;
my $const = "N" x 100;
for my $k1(sort keys %pos){
	for my $k2(sort {$a<=>$b} keys %{$pos{$k1}}){
		for my $k3(sort {$a<=>$b} keys %{$pos{$k1}{$k2}}){
			my $id = join "_",$k1,$k2,$k3;
			my $start = length($seq) + 1;
			my $end = length($seq) + $k3 - $k2 + 1;
			print OU "$name\t$start\t$end\t$k1\t$k2\t$k3\n";
			print BE "$k1\t$k2\t$k3\t$name\t$start\t$end\n";
			$seq .= $hash{$id}.$const;
		}
	}
}
my $obj = Bio::Seq->new(-id=>$name,-seq=>$seq);
$out->write_seq($obj);
close LI;
close OU;
close BE;
