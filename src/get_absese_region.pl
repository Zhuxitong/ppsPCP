use strict;
use warnings;
my ($fl,$ref,$query) = @ARGV;
open LF,$fl;
open REF,">$ref";
open QUE,">$query";
my (%ref,%query,%ref_len,%query_len);
while(<LF>){
	next if($_ !~ /^\d/);
	chomp;
	my @arr = split /\t/;
	($arr[0],$arr[1]) = sort {$a<=>$b} @arr[0..1];
	($arr[2],$arr[3]) = sort {$a<=>$b} @arr[2..3];
	for my $i($arr[0]..$arr[1]){
		$ref{$arr[11]}{$i}++;
	}
	for my $i($arr[2]..$arr[3]){
		$query{$arr[12]}{$i}++;
	}
	$ref_len{$arr[11]} = $arr[7];
	$query_len{$arr[12]} = $arr[8];
	#print "$arr[0]\t$arr[1]\t$arr[2]\t$arr[3]\t$arr[11]\t$arr[12]\n";
}
my $length = 0;
my $start = 0;
my $label = 0;
for my $key(sort keys %ref_len){
	my $len = $ref_len{$key};
	for my $i(1..$len){
		if (!exists($ref{$key}{$i}) && $start == 0 && $i < $len){
			$start = $i;
			$length = 1;
			$label = 0;
		}
		elsif (!exists($ref{$key}{$i}) && $start != 0 && $i < $len){
			$length++;
		}
		elsif (!exists($ref{$key}{$i}) && $start != 0 && $i == $len){
			$length++;
			my $end = $start + $length - 1;
			if ($length >= 100 && $label == 0){
				print REF "$key\t$start\t$end\n";
			}
			$start = 0;
			$length = 0;
			$label = 0;
		}
		elsif(exists($ref{$key}{$i}) && $i < $len){
			my $end = $start + $length - 1;
			if ($length >= 100 && $label == 0){
				print REF "$key\t$start\t$end\n";
			}
			$start = 0;
			$length = 0;
			$label = 1;
		}
		elsif(exists($ref{$key}{$i}) && $i == $len){
			my $end = $start + $length - 1;
			if ($length >= 100 && $label == 0){
				print REF "$key\t$start\t$end\n";
			}
			$start = 0;
			$length = 0;
			$label = 0;
		}
	}
}
$label = 0;
$start = 0;
$length = 0;
for my $key(sort keys %query_len){
	my $len = $query_len{$key};
	#print $len,"\n";
	for my $i(1..$len){
		if (!exists($query{$key}{$i}) && $start == 0 && $i < $len){
			$start = $i;
			$length = 1;
			$label = 0;
		}
		elsif (!exists($query{$key}{$i}) && $start != 0 && $i < $len){
			$length++;
		}
		elsif (!exists($query{$key}{$i}) && $i == $len){
			$length++;
			my $end = $start + $length - 1;
			if ($length >= 100 && $label == 0){
				print QUE "$key\t$start\t$end\n";
			}
			$start = 0;
			$length = 0;
			$label = 0;
		}
		elsif(exists($query{$key}{$i}) && $i < $len){
			my $end = $start + $length - 1;
			if ($length >= 100 && $label == 0){
				print QUE "$key\t$start\t$end\n";
			}
			$start = 0;
			$length = 0;
			$label = 1;
		}
		elsif(exists($query{$key}{$i}) && $i == $len){
			my $end = $start + $length - 1;
			if ($length >= 100 && $label == 0){
				print QUE "$key\t$start\t$end\n";
			}
			$start = 0;
			$length = 0;
			$label = 0;
		}
	}
}
close LF;
close REF;
close QUE;
