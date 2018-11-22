#!/usr/bin/env perl
use warnings;
use strict;
use Getopt::Long;
use Pod::Usage;
use Cwd qw/ abs_path /;
use FindBin qw/ $Bin /;
use File::Basename qw/basename/;

###parameter and path
my @argv	   = @ARGV;
my $src_path   = "$Bin/../src";

###help and version
my $help	   = 0;
my $msg		   = "\nPlease provide appropriate parameters!\n\nVersion: 1.0\n";

###required paremeters
my $ref_seq    = '';
my $ref_anno   = '';
my @query	   = ();
my @query_anno = ();

###filter parameters
my $coverage   = 0.9;
my $sim_pav	   = 0.95;
my $sim_gene   = 0.8;

###other parameters
my $tmp		   = './tmp';
my $no_tmp	   = 0;
my $thread	   = 1;


GetOptions( 'help'				=> \$help,
			'ref=s'				=> \$ref_seq,
			'ref_anno=s'		=> \$ref_anno,
			'query=s{1,}'		=> \@query,
			'query_anno=s{1,}'  => \@query_anno,
			'tmp:s'				=> \$tmp,
			'no_tmp'			=> \$no_tmp,
			'thread:i'			=> \$thread,
			'coverage:s'		=> \$coverage,
			'sim_pav:s'			=> \$sim_pav,
			'sim_gene:s'		=> \$sim_gene,
		) or pod2usage(2);

pod2usage(-msg=>$msg,-exitval=>1,-verbose=>99, -sections=>'NAME|SYNOPSIS|AUTHOR|CONTACT') if ($help or @argv == 0);
#pod2usage(-msg=>$msg,-exitval=>1) if ($help or @argv == 0);

###check input files
for my $file ($ref_seq, $ref_anno, @query, @query_anno){
	if ( ! -e $file ){
		die "\nError: file \"$file\" doesn't exist, please check!\n\n";
	}
}

if ( -d $tmp ) {
	die "ERROR: Temporary directory $tmp already exists, please check. Delete it or change a directory to run the command again!\n"
}
else {
	mkdir $tmp,0755 or die "Cannot create $tmp: $!";
}

my $pan_num = 1;
my $pan = basename($ref_seq);
if ( $pan =~ /pangenome(\d+).fa/){
	$pan_num = $1 + 1;
}


###main funcation
my $ref_file      = abs_path( $ref_seq );
my $ref_anno_file = abs_path( $ref_anno );
$sim_pav		  = $sim_pav  * 100;
$sim_gene		  = $sim_gene * 100;

for my $index (0..$#query) {
	my $query_file		= abs_path( $query[$index] );
	my $query_anno_file = abs_path( $query_anno[$index] );

	chdir $tmp;
	system("sh $Bin/ppsPCP.sh $ref_file $ref_anno_file $query_file $query_anno_file $pan_num $src_path $tmp $no_tmp $coverage $sim_pav $sim_gene $thread");

	$ref_file      = "pangenome$pan_num.fa";
	$ref_anno_file = "pangenome$pan_num.gff3";
	$pan_num++;

	chdir "../";
}

if ( $no_tmp ){
	unlink glob("$tmp/*");
	rmdir $tmp;
}


__END__

=head1 NAME

make_pan.pl  -  To make a pan-genome

=head1 SYNOPSIS

 make_pan.pl [options] --ref reference_genome --ref_anno refernece_anno --query query1[ query2 ...] --query_anno anno1[ anno2 ...]

 Options:

  ***Help
	--help|-h	Print the help message and exit.

  ***Required parameters
	--ref		Reference sequence file, usually a fasta file
	--ref_anno	The gff3 annotation file for the reference sequence
	--query		The query sequence files, can be one or more, separated with space
	--query_anno	The gff3 annotation files corresponding to the query sequence files, optional. If supplied, must have the same order with the query sequence files

  ***Filter parameters
	--coverage	The coverage used to filter similar PAVs. Can be any number between 0 and 1. Default: 0.9
	--sim_pav	The similarity used to filter similar PAVs. Can be any number between 0 and 1. Default: 0.95
	--sim_gene	Then similarity used to filter mapped genes in blat mapping. Can be any number between 0 and 1. Default: 0.8

  ***Other parameters
	--tmp		The temporary directory where you want to save the temporary files. Default: ./tmp
	--no_tmp	Delete tmp file when job finished
	--thread	The number of thread used in blastn only. Remember not all the phases of ppsPCP are parallelized. Default: 1
	

=head1 AUTHOR
	
	Muhammad Tahir ul Qamar

=head1 CONTACT

	m.tahirulqamar@hotmail.com
