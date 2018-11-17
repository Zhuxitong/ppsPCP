# ppsPCP
A Plant PAVs Scanner and Pan-genome Construction Pipeline.

## Description
ppsPCP is a Pipeline to detect presence/absence variations (PAVs) and make a fully annotated Pan-genome when comparing one or multiple assembled plant genomes against one selected reference genome.

To find PAVs and construct a Pan-genome using reference and two query genomes, ppcPCP will perform the following steps: 
```
1. The reference and first query genome are aligned together to find absent regions
2. The alignments are processed to filter out PAVs. The smallest size of PAV extracted is 100bp
3. To confirm PAVs, BLASTn against reference is performed
4. BLASTn results are parsed to classify the PAVs scaffolds into two different categories: 
   - Similar (to the reference tested) [default: similarity 90% and coverage 80%]
   - No hits on the reference
5. PAVs are compared with the reference genome annotation file and those which were adjacent to each other and 
   having some overlapping gene sequence are extended, corrected and merged 
6. Genes which were associated with the PAVs are filtered out and make a PAVs annotation file
7. Filtered PAVs and annotation files are merged with reference genome fasta and annotation file to construct 
   a draft genome
8. Draft genome is aligned again with the query genome to get the not similar genes information which at least 
   not following one of the previous defined criteria
9. Filtered out not similar genes then added into files generated at step 5 and repeated the steps 5 and 6 
   By this way, ppsPCP collects not only sequence based PAVs and its associated genes, but also collect the genes 
   which are less similar and not following one of the previous defined criteria 
10. New PAVs sequence and annotation files are merged with the reference genome sequence and annotation 
    files respectively to create Pan-genome 1. After that, this Pan-genome 1 is used as reference genome for 
    second query genome and whole process is repeated. Finally, This pipeline yield a fully annotated Pan-genome 
    which represent a whole sequence/genes set for all three genomes.
```

## Dependencies

### System requirement
ppsPCP currently only supports  ***Linux*** system due to the software dependencies. 

### Softwares
1. MUMmer  
You can find MUMmer [HERE](http://mummer.sourceforge.net/). Installing MUMmer is quite easy and version 3.X.X is needed:
```
$ wget https://sourceforge.net/projects/mummer/files/latest/download
$ tar -xvzf MUMmerX.X.tar.gz (X means the VERSION of MUMmer)
$ make check
$ make install
# Add MUMmer tools to your PATH
$ export PATH=/path/to/MUMmer/:$PATH
```
2. Blast+  
You can find Blast+ [HERE](https://blast.ncbi.nlm.nih.gov/Blast.cgi) in NCBI. We downloaded the x64-linux version of Blast+.
```
$ wget ftp://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/LATEST/ncbi-blast-2.7.1+-x64-linux.tar.gz
$ tar zxvf ncbi-blast-2.7.1+-x64-linux.tar.gz
# Add Blast+ tools to your PATH
$ export PATH=/path/to/blast+/bin:$PATH
```
3. Bedtools  
[Bedtools](https://bedtools.readthedocs.io/en/latest/) is a powerful toolset for genome arithmetic. It is also very easy to install. In this pipeline, four sub-tools from Bedtools are used: *getfasta*, *intersect*, *merge* and *sort*.
```
$ wget https://github.com/arq5x/bedtools2/releases/download/v2.25.0/bedtools-2.25.0.tar.gz
$ tar -zxvf bedtools-2.25.0.tar.gz
$ cd bedtools2
$ make
# Add Bedtools tools to your PATH
$ export PATH=/path/to/bedtools/bin:$PATH
```
4. Blat  
[Blat](https://en.wikipedia.org/wiki/BLAT_(bioinformatics)) is one of utilities from UCSC. You can select one utility to download or use below commad to download all of them from this [page](http://hgdownload.soe.ucsc.edu/admin/exe/linux.x86_64/).
```
$ mkdir UCSC_tools
$ rsync -aP rsync://hgdownload.soe.ucsc.edu/genome/admin/exe/linux.x86_64/ ./
#Add blat to your PATH
export PATH=/path/to/UCSC_tools/blat/:$PATH
```
5. gffread  
gffread is a build-in tool in [Cufflinks](http://cole-trapnell-lab.github.io/cufflinks/manual/).So by installing cufflinks, you can use gffread easily.
```
$ wget http://cole-trapnell-lab.github.io/cufflinks/assets/downloads/cufflinks-2.2.1.Linux_x86_64.tar.gz
$ tar zxvf cufflinks-2.2.1.Linux_x86_64.tar.gz
# Add gffread to your PATH
$ export PATH=/path/to/cufflinks-2.2.1.Linux_x86_64/:$PATH
```
6. Perl and perl modules  
Here we recommand the version of perl should be least *5.10.0* (use `perl -v` to check the version). Although most of the modules ppsPCP used are already exist, you still need to install the [Bio::Perl](http://www.bioperl.org/) module. Installing the perl module under Linux system sometimes can be troublesome due to the lack of adminstrator permission. This [page](https://bioperl.org/INSTALL.html) inrtoduces three ways to install the Bio::Perl module, but in practice the *cpanm* is the most friendly way to install perl module. You can find a pre-compiled source code for the cpanm [HERE](https://github.com/miyagawa/cpanminus/tree/devel/App-cpanminus).
```
#if you are using cpanm for the first time, type the following command on your system.(By default, the module installed through cpanm will be in '~/perl5' directory).
$ cpanm --local-lib=~/perl5 local::lib && eval $(perl -I ~/perl5/lib/perl5/ -Mlocal::lib)
# install Bio::Perl
$ cpanm Bio::Perl
```

### Download and Installation
Installing ppsPCP can be very easy. You can either download and uncompress the ppsPCP package or through git. After downloading, remember to put the bin directory into your PATH.
```
# download the ppsPCP
$ wget
or 
git clone git@github.com:Zhuxiaobu/pan_genome.git
# Add the bin to PATH
$ export PATH=/path/to/ppsPCP/bin/:$PATH
```

## ppsPCP options
```
     Options:

      ***Help
            --help|-h       Print the help message and exit.

      ***Required parameters
            --ref           Reference sequence file, usually a fasta file
            --ref_anno      The gff3 annotation file for the reference sequence
            --query         The query sequence files, can be one or more, separated with space
            --query_anno    The gff3 annotation files corresponding to the query sequence files, optional. If supplied, must have the same order with the query sequence files

      ***Filter parameters
            --coverage      The coverage used to filter similar PAVs. Can be any number between 0 and 1. Default: 0.8
            --sim_pav       The similarity used to filter similar PAVs. Can be any number between 0 and 1. Default: 0.9
            --sim_gene      Then similarity used to filter mapped genes in blat mapping. Can be any number between 0 and 1. Default: 0.8

      ***Other parameters
            --tmp           The temporary directory where you want to save the temporary files. Default: ./tmp
            --no_tmp        Delete tmp file when job finished
            --thread        The number of thread used in blastn only. Remember not all the phases of ppsPCP are parallelized. Default: 1

```

## Test ppsPCP with example data
A small dataset in the 'example' directory can be used to test whether ppsPCP can run on your system successfully or not. Move to the 'example' directory and type the following commands:
```
$ cd example
$ make_pan.pl --ref Zmw_sc00394.1.fa --ref_anno Zmw_sc00394.1.gff3 --query Zjn_sc00188.1.fa --query_anno Zjn_sc00188.1.gff3
```
If any error occurs, please check the log information or contact us through e-mail. This result has no biological meaning because these two sequences are only a small part of two genomes from [HERE](http://zoysia.kazusa.or.jp/ "zoysia").
## Input and output files
### Input files
At least two genome sequence files and two corresponding annotation files are required to run ppsPCP.

The genome sequence file should be a fasta file with following format:
```
>chr1
ATCGATCG...
```
File extension doesn't matter, '.fa', '.fasta' or any other suffix can be accepted. But the prefix name of sequence file will be used to indicate the temporary file, so we recommend you to use 'cultivar.fa (like rice.fa)' to run ppsPCP.

Annotation file should be [GFF3](https://github.com/The-Sequence-Ontology/Specifications/blob/master/gff3.md 'GFF3') format:
```
ctg123 . gene            1000  9000  .  +  .  ID=gene00001;Name=EDEN
ctg123 . mRNA            1050  9000  .  +  .  ID=mRNA00001;Parent=gene00001;Name=EDEN.1
ctg123 . exon            1300  1500  .  +  .  ID=exon00001;Parent=mRNA00003
ctg123 . CDS             1201  1500  .  +  0  ID=cds00001;Parent=mRNA00001;Name=edenprotein.1
```
Although it is possible to construct a pan-genome without any annotation information, but then the downstream analyses can only be done based on sequence. So we strongly recommend you to create annotation file for your genome. There are lots of excellent tools to annote a genome, like [Maker](http://www.yandell-lab.org/software/maker.html), [PASA](https://github.com/PASApipeline/PASApipeline/wiki) and so on.
### Output files
The main output files of ppsPCP are 'pangenome.fa' and 'pangenome.gff3' if you create pan-genome with two genome (one reference and one query), as well as some useful information about the pan-genome like number of PAVs in query, number of genes merged into pan-genome and so on. ppsPCP supports multiple query genome files, which will produce 'pangenome1.fa', 'pangenome2.fa'... et al, with corresponding gff3 file for each of them.

We also provide some useful information about the pan-genome during the construction of it, like the size of draft pan-genome, genes added into pan-genome from query genome and so on. See the log for more details.
## Examlpe commands
Type 'make_pan.pl -h' for a detailed look at the parameters in ppsPCP.

If you have only one query genome: 
```
make_pan.pl --ref cultivar1.fa --ref_anno cultivar1.gff3 --query cultivar2.fa --query_anno cultivar2.gff3 &> run.log
```
If you have multiple query genomes:
```
make_pan.pl --ref cultivar1.fa --ref_anno cultivar1.gff3 --query cultivar2.fa cultivar3.fa ... --query_anno cultivar2.gff3 cultivar2.gff3 ... &> run.log
```

We also provide some other useful parameters to control the performance of ppsPCP. *--coverage*, *--sim_pav* and *--sim_gene* are used to filter out similar PAVs and genes described in above steps. We strongly suggest using multiple threads through*--thread*, witch can significantly improve the speed of blastn.

## Contact us
- Muhammad Tahir ul Qamar, m.tahirulqamar@webmail.hzau.edu.cn
- Zhu xitong, z724@qq.com (E-mail can be in Chinese)
