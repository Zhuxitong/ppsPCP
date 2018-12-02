use strict;
use warnings;
use Bio::SeqIO;
use Bio::Seq;
use Data::Dumper;
my ($list,$fl,$fa,$ou,$oufa) = @ARGV;
open LI,$list;
open FL,$fl;
open OU,">$ou";
my $in = Bio::SeqIO->new(-file=>"$fa",-format=>"Fasta");
my $out = Bio::SeqIO->new(-file=>">$oufa",-format=>"Fasta");
my %hash;
my %exists;
my $pre = <FL>;
while(<FL>){
	chomp;
	my @arr = split /\t/;
	chomp($pre);
	my @pre = split /\t/,$pre;
	$exists{$pre[0]}{$pre[1]}{$pre[2]}++;
	$exists{$arr[0]}{$arr[1]}{$arr[2]}++;
	my @pretmp = sort {$a<=>$b} @pre[1..2],@pre[7..8];
	my @arrtmp = sort {$a<=>$b} @arr[1..2],@arr[7..8];
	if ($pre[0] eq $arr[0] &&($pretmp[3] >= $arrtmp[0])){
		my @tmp = sort {$a<=>$b} @pretmp,@arrtmp;
		$pre[1] = $tmp[0];
		$pre[2] = $tmp[$#tmp];
		$pre[7] = $tmp[0];
		$pre[8] = $tmp[$#tmp];
		$pre = join "\t",@pre;
	}
	else{
		my $key = join "\t",$pre[0],$pretmp[0],$pretmp[3];
		$hash{$key}++;
		$pre = $_;
	}
}

my %seq;
while(my $sub = $in->next_seq()){
	my $id = $sub->id;
	$seq{$id} = $sub;
}

my $name;
while(<LI>){
	chomp;
	my @arr = split /\t/;
	if (!exists($exists{$arr[0]}{$arr[1]}{$arr[2]})){
		my $seq = $seq{$arr[0]}->subseq($arr[1],$arr[2]);
		my $id = join "_",@arr[0..2];
		my $obj = Bio::Seq->new(-id=>$id,-seq=>$seq);
		$out->write_seq($obj);
		print OU "$_\t$arr[1]\t$arr[2]\n";
		$name = $arr[$#arr];
	}
	
}
for my $key(sort keys %hash){
	my @arr = split /\t/,$key;
	my $seq = $seq{$arr[0]}->subseq($arr[1],$arr[2]);
	my $id = join "_",@arr;
	my $obj = Bio::Seq->new(-id=>$id,-seq=>$seq);
	$out->write_seq($obj);
	print OU "$arr[0]\t$arr[1]\t$arr[2]\t$name\t$arr[1]\t$arr[2]\n";
}
close LI;
close FL;
close OU;
