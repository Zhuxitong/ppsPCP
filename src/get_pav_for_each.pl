use strict;
use warnings;
use Bio::SeqIO;
use Bio::Seq;
my ($list,$fl,$fa,$ou,$oufa) = @ARGV;
open LI,$list;
open FL,$fl;
open OU,">$ou";
my $in = Bio::SeqIO->new(-file=>"$fa",-format=>"Fasta");
my $out = Bio::SeqIO->new(-file=>">$oufa",-format=>"Fasta");
my %hash;
while(<FL>){
	chomp;
	my @arr = split /\t/;
	if (!exists($hash{$arr[0]}{$arr[1]}{$arr[2]})){
		$hash{$arr[0]}{$arr[1]}{$arr[2]} = join "\t",$arr[0],@arr[7..8];
	}
	elsif (exists($hash{$arr[0]}{$arr[1]}{$arr[2]})){
		my @tmp = split /\t/,$hash{$arr[0]}{$arr[1]}{$arr[2]};
		if ($arr[7] < $tmp[1]){
			$tmp[1] = $arr[7];
		}
		if ($arr[8] > $tmp[2]){
			$tmp[2] = $arr[8];
		}
		$hash{$arr[0]}{$arr[1]}{$arr[2]} = join "\t",@tmp[0..2];
	}
}
my %seq;
while(my $sub = $in->next_seq()){
	my $id = $sub->id;
#	$seq{$id} = $sub;
	$seq{$id} = $sub -> seq();
}
while(<LI>){
	chomp;
	my @arr = split /\t/;
	if (!exists($hash{$arr[0]}{$arr[1]}{$arr[2]})){
#		my $seq = $seq{$arr[0]}->subseq($arr[1],$arr[2]);
		my $seq = substr($seq{$arr[0]},$arr[1] - 1,$arr[2] - $arr[1] + 1);
		my $id = join "_",@arr[0..2];
		my $obj = Bio::Seq->new(-id=>$id,-seq=>$seq);
		$out->write_seq($obj);
		print OU "$_\t$arr[1]\t$arr[2]\n";
	}else{
		my @tmp = split /\t/,$hash{$arr[0]}{$arr[1]}{$arr[2]};
		my ($left,$right);
		$left = $arr[1];
		$right = $arr[2];
		if ($arr[1] > $tmp[1]){
			$left = $tmp[1];
		}
		if ($arr[2] < $tmp[2]){
			$right = $tmp[2];
		}
#		my $seq = $seq{$arr[0]}->subseq($left,$right);
		my $seq = substr( $seq{$arr[0]}, $left - 1,$right - $left + 1);
		my $id = join "_",$arr[0],$left,$right;
		my $obj = Bio::Seq->new(-id=>$id,-seq=>$seq);
		$out->write_seq($obj);
		print OU "$_\t$left\t$right\n";
	}
}
close LI;
close FL;
close OU;
