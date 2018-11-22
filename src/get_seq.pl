use strict;
use warnings;
use Bio::SeqIO;
use Bio::Seq;
my ($fl,$list,$ou)  = @ARGV;
open LI,$list;
my $in  = Bio::SeqIO->new(-file=>$fl,-format=>'Fasta');
my $out  = Bio::SeqIO->new(-file=>">$ou",-format=>'Fasta');
my %hash;
while(my $sub = $in->next_seq()){
	my $id = $sub->id;
	my $seq = $sub->seq;
	$hash{$id} = $seq;
}
while(<LI>){
	chomp;
	my @arr = split /\t/;
	my $seq = substr($hash{$arr[0]},$arr[1] - 1,$arr[2] - $arr[1] + 1);
	my @seq = split "",$seq;
	my $length = 0;
	for my $i(0..$#seq){
		if ($seq[$i] =~ /N/i){
			if ($length < 100){
				$length = 0;
				next;
			}
			elsif($length >= 100){
				my $end = $arr[1] + $i - 1;
				my $start = $end - $length + 1;
				my $id = join "_",$arr[0],$start,$end;
				my $tmp_seq = substr($seq,$i - $length,$length);
				my $obj = Bio::Seq->new(-id=>$id,-seq=>$tmp_seq);
				$out->write_seq($obj);
				$length = 0;
			}
		}
		else{
			$length++;
			next if($i < $#seq);
			if ($length >= 100){
				my $end = $arr[1] + $i;
				my $start = $end - $length + 1;
				my $id = join "_",$arr[0],$start,$end;
				my $tmp_seq = substr($seq,$i + 1 - $length,$length);
				my $tmp = length($tmp_seq);
				#print "$i - $length\t$tmp\n";
				my $obj = Bio::Seq->new(-id=>$id,-seq=>$tmp_seq);
				$out->write_seq($obj);
			}
		}
	}
}
close LI;
