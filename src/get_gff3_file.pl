use strict;
use warnings;
my ($intersect,$gff_res) = @ARGV;
open IN,$intersect;
open OU,">$gff_res";
while(<IN>){
	chomp;
	my @arr = split /\t/;
	$arr[9] = $arr[9] + $arr[4] - $arr[1];
	$arr[10] = $arr[10] + $arr[4] - $arr[1];
	my $tmp = join "\t",$arr[3],@arr[7..14];
	print OU $tmp,"\n";
}
