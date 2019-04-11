# ppsPCP

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.2567390.svg)](https://doi.org/10.5281/zenodo.2567390)

ppsPCP is a Pipeline to scan presence/absence variants (PAVs) and make fully annotated Pan-genome when one or multiple assembled plant genomes compared against one selected reference genome. ppsPCP can also be used for prokaryotes and other eukaryotes like animals etc.

An introduction of ppsPCP in Chinese can be found [HERE](https://mp.weixin.qq.com/s?__biz=MzUzMTEwODk0Ng==&mid=2247487392&idx=1&sn=2a6a5c878313838a95d697a95c6c72d2&chksm=fa46ca9dcd31438bb5f3f595d43a40765bb82fba5d3f8a1f80f7679d90e574381b8068bb81fc&mpshare=1&scene=2&srcid=&from=timeline&ascene=2&devicetype=android-27&version=2700033c&nettype=WIFI&abtest_cookie=BAABAAoACwASABMABQAjlx4AVpkeAMSZHgDTmR4A3JkeAAAA&lang=zh_CN&pass_ticket=r9l59c3GEUVZpPgqqloJ5dGmBhDYx9QbJYDdv80ORjFBGqjFO2%2Fn8N%2BDak4A%2BYXk&wx_header=1). Thanks lakeseafly from 生信菜鸟团 for making this.

To find PAVs and construct a Pan-genome, ppcPCP perform the following steps: 
```
- The reference and query genomes are aligned together, and PAVs are scanned. The minimum PAV length set to 100bp
- All genes either assosiated with the PAVs, have no similarity with reference or not satisfy at least one of the 
  previous defined criteria are filtered out
- Extracted unique PAVs and genes are merged with reference genome to construct a fully annotated pan-genome
```

## Download and Usage
Installing ppsPCP is very much easy. You can download and uncompress the ppsPCP package using wget or through git. 
After downloading, put the bin directory into your PATH.
```
# download the ppsPCP
wget http://cbi.hzau.edu.cn/ppsPCP/files/ppsPCP.zip
or
git clone git@github.com:Zhuxitong/ppsPCP.git
# Add the bin to PATH
$ export PATH=/path/to/ppsPCP/bin/:$PATH
```

## ppsPCP available options for users
```
     Usage: 
            make_pan.pl [options] --ref [reference_genome] --ref_anno [refernece_anno] --query query1_genome[query2...] --query_anno query1_anno[query2...] &> [job_name].log 
     
     Options:

      ***Help
            --help|-h       Print the help message and exit.

      ***Required parameters
            --ref           Reference sequence file, usually a fasta file
            --ref_anno      The gff3 annotation file for the reference sequence
            --query         The query sequence files, can be one or more, separated with space
            --query_anno    The gff3 annotation files corresponding to the query sequence files, 
                            must have the same order with the query sequence files

      ***Filter parameters
            --coverage      The coverage used to filter similar PAVs. Can be any number between 0 and 1. Default: 0.9
            --sim_pav       The similarity used to filter similar PAVs. Can be any number between 0 and 1. Default: 0.95
            --sim_gene      Then similarity used to filter mapped genes in blat mapping. Can be any number between 0 and 1. Default: 0.8

      ***Other parameters
            --tmp           The temporary directory where you want to save the temporary files. Default: ./tmp
            --no_tmp        Delete tmp file when job finished
            --thread        The number of threads used for mummer and blastn. Remember not all the phases of ppsPCP are parallelized. Default: 1

```

## Dependencies

1. MUMmer  
You can find MUMmer [HERE](https://github.com/mummer4/mummer/releases). We used Mummer-4.0.0beta2. Mummer version 4.x.x requires a recent version of the GCC compiler (g++ version >= 4.7), which is hard to install if you have no ***administrator authority***. You can ask your system administrator for some help in this case.
```
$ wget https://github.com/mummer4/mummer/releases/download/v4.0.0beta2/mummer-4.0.0beta2.tar.gz
$ tar -xvzf mummer-4.0.0beta2.tar.gz
$ ./configure --prefix=/path/to/installation
$ make
$ make install
# Add MUMmer tools to your PATH
$ export PATH=/path/to/installation/:$PATH
```
2. Blast+  
You can find Blast+ [HERE](https://blast.ncbi.nlm.nih.gov/Blast.cgi) in NCBI. We used the x64-linux version of Blast+.
```
$ wget ftp://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/LATEST/ncbi-blast-2.7.1+-x64-linux.tar.gz
$ tar zxvf ncbi-blast-2.7.1+-x64-linux.tar.gz
# Add Blast+ tools to your PATH
$ export PATH=/path/to/blast+/bin:$PATH
```
3. Bedtools  
[Bedtools](https://bedtools.readthedocs.io/en/latest/) is a powerful toolset for genome arithmetic. It is also very easy to install. In this pipeline, four sub-tools of Bedtools are used: *getfasta*, *intersect*, *merge* and *sort*.
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
# Add blat to your PATH
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
We recommand the version of perl should be at-least *5.10.0* (use `perl -v` to check the version). 
Although most of the modules ppsPCP used are already exist, however you still may need to install the [Bio::Perl](http://www.bioperl.org/) module. 
Installing the perl module under Linux system sometimes can be troublesome due to the lack of adminstrator permission. 
This [page](https://bioperl.org/INSTALL.html) inrtoduces three ways to install the Bio::Perl module, but in practice the *cpanm* is the most friendly way to install perl module. You can find a pre-compiled source code for the cpanm [HERE](https://github.com/miyagawa/cpanminus/tree/devel/App-cpanminus).
```
#if you are using cpanm for the first time, type the following command on your system.(By default, the module installed through cpanm will be in '~/perl5' directory).
$ cpanm --local-lib=~/perl5 local::lib && eval $(perl -I ~/perl5/lib/perl5/ -Mlocal::lib)
# install Bio::Perl
$ cpanm Bio::Perl
```
ppsPCP currently only supports ***Linux*** system due to the software dependencies.

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
***GFF*** format with 'gene' information line can also be accepted by ppsPCP.
### Output files

The main output files of ppsPCP are 'pangenome.fa' and 'pangenome.gff3', if you create pan-genome with only two genome (one reference and one query), and some useful information about the pan-genome like number of PAVs in query, number of genes merged into pan-genome and so on. ppsPCP supports multiple query genome files, which will produce 'pangenome1.fa', 'pangenome2.fa'... so on, with corresponding gff3 file for each of them. The last pan-genome will be the final pan-genome representing total set of PAVs/genes scaned from every query genome and merged into reference genome. 

## Test ppsPCP with example data
A small dataset in the 'example' directory can be used to test whether ppsPCP can run on your system successfully or not. Move to the 'example' directory and type the following commands:
```
$ cd example
$ make_pan.pl --ref Zmw_sc00394.1.fa --ref_anno Zmw_sc00394.1.gff3 --query Zjn_sc00188.1.fa --query_anno Zjn_sc00188.1.gff3 &> run.log
```
If you receive any error, please check the log information or contact us through e-mail. 
This result has no biological meaning because these two sequences are only a small part of two genomes from [HERE](http://zoysia.kazusa.or.jp/ "zoysia").

## Reference
Muhammad Tahir ul Qamar, Xitong Zhu, Feng Xing, Ling-Ling Chen. ppsPCP: A Plant Presence/absence Variants Scanner and Pan-genome Construction Pipeline. *Bioinformatics*, [https://doi.org/10.1093/bioinformatics/btz168](https://doi.org/10.1093/bioinformatics/btz168 'ppsPCP')

All the data used in above paper and the outputs can be downloaded from here [Rice](http://cbi.hzau.edu.cn/ppsPCP/files/rice_ppsPCP.tar.gz "rice") and [Arabidopsis](http://cbi.hzau.edu.cn/ppsPCP/files/arabidopsis_ppsPCP.tar.gz "arabidopsis"). 

## Contact us
- Muhammad Tahir ul Qamar; m.tahirulqamar@hotmail.com
- Zhu xitong; z724@qq.com (E-mail can be in Chinese)
- Feng Xing; xfengr@mail.hzau.edu.cn (E-mail can be in Chinese) 
- Ling-Ling Chen; llchen@mail.hzau.edu.cn (E-mail can be in Chinese)
