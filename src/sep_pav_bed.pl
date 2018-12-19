use strict;
use warnings;
use Data::Dumper;

my ($fl, $sep) = @ARGV;
open FL,$fl or die($!);
my %hash;
while(<FL>){
	chomp;
	my @test = split /\t/;
	my @arr  = split /_/,$test[0];
	my $len  = $#arr;
	$arr[$len - 1]	 = $arr[$len - 1] - 1;
	my $id   = join("_",@arr[0 .. $len - 2]);
	my $pos  = join("\t",$id,@arr[$len-1..$len]);
	$hash{ $id }{ $pos }++;
=pod
	if ($#arr == 5){
		my $id  = join "_",@arr[0..3];
		$arr[4] = $arr[4] - 1;
		my $pos = join "\t",$id,@arr[4..5];
		$hash{$arr[0]}{$pos}++;
	}
	elsif ($#arr == 4){
		my $id  = join "_",@arr[0..2];
		$arr[3] = $arr[3] - 1;
		my $pos = join "\t",$id,@arr[3..4];
		$hash{$id}{$pos}++;
	}
	elsif ($#arr == 3){
		my $id  = join "_",@arr[0..1];
		$arr[2] = $arr[2] - 1;
		my $pos = join "\t",$id,@arr[2..3];
		$hash{$arr[0]}{$pos}++;
	}
	elsif ($#arr == 2){
		my $id  = join "_",$arr[0];
		$arr[1] = $arr[1] - 1
		my $pos = join "\t",$id,@arr[1..2];
		$hash{$arr[0]}{$pos}++;
	}
=cut
}

open OU,">$sep.bed";
for my $k1(sort keys %hash){
	for my $k2(sort keys %{$hash{$k1}}){
		print OU "$k2\t$sep\n";
	}
}

close FL;
close OU;
