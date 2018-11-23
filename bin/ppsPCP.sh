#########################################################################
# File Name: ppsPCP.sh
# Author: Muhammad Tahir ul Qamar
# mail: m.tahirulqamar@hotmail.com
# Created Time: Wed Oct 17 16:15:15 2018
#########################################################################
#!/bin/bash

#########################################################################
# Explain parameter
# $5  = pan_number
# $6  = src_path
# $7  = tmp
# $8  = keep_tmp
# $9  = coverage
# $10 = sim_pav
# $11 = sim_gene
# $12 = thread
#########################################################################

# File name parse
ref=$( basename $1 )
query=$( basename $3 )

refgff=$( basename $2)
querygff=$( basename $4)

refbase=`basename $ref`
querybase=`basename $query`
refbase=${refbase%\.*}
querybase=${querybase%\.*}

res="${querybase}to${refbase}"

# Create link files for  genome and annotation file in tmp

if [ ! -e "$ref" ]
then
	ln -s $1
	ln -s $2
fi

ln -s $3
ln -s $4

#--------------------------------------------------------------------------------------------------
echo -e "\n##########################################################################################\n"

echo -e "Step 1: Aligning $query to $ref with nucmer!"

echo -n "Total number of genes in ${refbase}: "
grep -cP "\tgene\t" $2
echo -n "Total number of genes in ${querybase}: "
grep -cP "\tgene\t" $4

nucmer -p $res $ref $query
delta-filter -1 ${res}.delta > ${res}.rq.delta
show-coords -clrT -I 0.95 -L 100 ${res}.rq.delta > ${res}.rq.coords


#--------------------------------------------------------------------------------------------------
echo -e "\nStep 2: Extracting PAVs from nucmer output!"

perl $6/get_absese_region.pl ${res}.rq.coords  ${refbase}_absence.txt ${querybase}_absence.txt
perl $6/get_seq.pl ${query} ${querybase}_absence.txt ${querybase}_absence.fa

echo -n "Total number of PAVs extracted from ${querybase}: "
grep -c '>' ${querybase}_absence.fa


#--------------------------------------------------------------------------------------------------
echo -e "\nStep 3: Aligning the extracted PAVs against reference genome using blastn!"

makeblastdb -in ${ref} -title ${refbase}_DB -dbtype nucl -out ${refbase}_database
blastn -db ${refbase}_database -query ${querybase}_absence.fa -num_threads ${12} -evalue 1e-5 -outfmt 6 -out ${res}_blastn.txt


#--------------------------------------------------------------------------------------------------
echo -e "\nStep 4: Filtering PAVs from blastn output (1. high coverage and similarity, 2. unmapped/ no similarity)!"

perl $6/get_coverage_filter.pl ${res}_blastn.txt ${querybase}_absence.fa ${querybase}_absence_filtered.fa ${querybase}_absence_pavs.txt $9 ${10}
perl $6/sep_pav_bed.pl ${querybase}_absence_pavs.txt ${querybase}
perl $6/get_unmapped_pavs.pl ${res}_blastn.txt ${querybase}_absence.fa ${querybase}_unmapped_pavs.txt

echo -n "Number of filtered ${querybase} PAVs having definded covergae/similarity: "
grep -c '>' ${querybase}_absence_filtered.fa 
echo -n "Number of filtered ${querybase} PAVs having no similarity/hit with ${refbase}: "
cat ${querybase}_unmapped_pavs.txt | wc -l


#--------------------------------------------------------------------------------------------------
echo -e "\nStep 5: Extension and correction of filtered PAVs by matching them with reference genome to get full gene covering regions!"

perl $6/sep_pav_bed.pl ${querybase}_unmapped_pavs.txt ${querybase}.2
cat ${querybase}.bed ${querybase}.2.bed | sortBed > ${querybase}_draft.bed

echo -n "Total number of ${querybase} PAVs after boundries correction: "
cat ${querybase}_draft.bed | wc -l


#--------------------------------------------------------------------------------------------------
echo -e "\nStep 6: Filtering and annotating genes overlapped with extracted PAVs!"

grep -P "\tgene\t" ${querygff} > ${querybase}_loci.gff3
intersectBed -a ${querybase}_draft.bed -b ${querybase}_loci.gff3 -wa -wb > ${querybase}_pav_intersect_gene.gff3 
perl $6/get_pav_for_each.pl ${querybase}_draft.bed ${querybase}_pav_intersect_gene.gff3 ${query} ${querybase}_pav_region.txt ${querybase}_pav_final.fa
perl $6/get_the_pav_seq.pl ${querybase}_pav_region.txt ${querybase}_pav_final.fa ${querybase}_pav_seq.fa ${querybase}_pav.agp ${querybase}_pav.bed ${querybase}


#--------------------------------------------------------------------------------------------------
echo -e "\nStep 7: Merging filtered information with reference genome and making sequence based draft pan-genome!"

cat ${ref} ${querybase}_pav_seq.fa > ${res}_draft_genome.fa

echo -n "Size of the draft pan-genome: "
ls -lh "${querybase}to${refbase}_draft_genome.fa" | awk '{print $5}'

intersectBed -a ${querybase}_pav.bed -b ${querygff} -wa -wb > ${querybase}_gene_relocation.txt
perl $6/get_gff3_file.pl ${querybase}_gene_relocation.txt ${querybase}_gene_relocation.gff3

echo -n "Number of genes overlapped with ${querybase} PAVs and added into draft genome: "
grep -P "\tgene\t" ${querybase}_gene_relocation.gff3 | cut -f 9 | sort | uniq | wc -l


#--------------------------------------------------------------------------------------------------
echo -e "\nStep 8: Realigning the draft pan-genome to query genome as reference using BLAT, to filter less similar genes or genes not fulfill the previous defined criteria!"

gffread ${querygff} -g ${query} -w ${querybase}_exons.fa 
cat ${querybase}_exons.fa  | awk '/^>/ {if(N>0) printf("\n"); printf("%s\t",$0);N++;next;} {printf("%s",$0);} END {if(N>0) printf("\n");}' | awk -F '	' '{printf("%s\t%d\n",$0,length($2));}' | awk '{n=NF-1;print $1" "$2"\t"$n"\t"$NF}' | sort -k2,2 -k4,4nr | sort -k2,2 -u -s | awk '{print $1" "$2"\n"$3}' | fold -w 80 > ${querybase}_exons_longest.fa
blat ${res}_draft_genome.fa ${querybase}_exons_longest.fa ${res}_output.psl
sed '1,5'd ${res}_output.psl | awk -v sim=${11} '$1/$11*100 >= sim{print $1"\t"$1/$11*100"\t"$10}' | sort -k3,3 -k1,1nr | sort -k3,3 -u -s | cut -f 3 | sort > ${querybase}_mapped.gene.list.txt
grep '>' ${querybase}_exons_longest.fa | awk '/>/{sub(/>/,"",$1);print $1}' | sort | uniq > ${querybase}_all.gene.list.txt
comm -1 -3 ${querybase}_mapped.gene.list.txt ${querybase}_all.gene.list.txt > ${querybase}_unmapped.genes.txt

echo -ne "\nNumber of ${querybase} genes mapped to draft pan-genome: "
cat ${querybase}_mapped.gene.list.txt | wc -l
echo -n "Number of ${querybase} genes NOT mapped to draft pan-genome: "
cat ${querybase}_unmapped.genes.txt | wc -l


#--------------------------------------------------------------------------------------------------
echo -e "\nStep 9: Including missing/less similar genes to step 5 output for final process!\n"

perl $6/get_unmapped_gene_bed.pl ${querybase}_unmapped.genes.txt ${querygff} ${querybase} | sortBed > ${querybase}.3.bed
cat ${querybase}.bed ${querybase}.2.bed ${querybase}.3.bed | sortBed > ${querybase}_final.bed


#--------------------------------------------------------------------------------------------------
echo -e "\nStep 10: Generating final pan-genome and its annotation file!"

intersectBed -a ${querybase}_final.bed -b ${querybase}_loci.gff3 -wa -wb > ${querybase}_pav_intersect_gene_final.gff3 
perl $6/get_pav_for_each.pl ${querybase}_final.bed ${querybase}_pav_intersect_gene_final.gff3 ${query} ${querybase}_pav_region_final.txt ${querybase}_pavs_confirm_final.fa
awk '{print $1"\t"$5"\t"$6"\t"$4"\t"$2"\t"$3}' ${querybase}_pav_region_final.txt | bedtools merge -i stdin -c 4,5,6 -o collapse | awk '{split($4,name,/,/);split($5,start,/,/);split($6,end,/,/);l=length(end);print $1"\t"$2"\t"$3"\t"$1"_"$2"_"$3}' > ${querybase}_pav_region_final2.txt
awk '{print $1"\t"$5"\t"$6"\t"$4"\t"$2"\t"$3}' ${querybase}_pav_region_final.txt | bedtools merge -i stdin -c 4,5,6 -o collapse | awk '{split($4,name,/,/);split($5,start,/,/);split($6,end,/,/);l=length(end);print $1"\t"start[1]"\t"end[l]"\t"name[1]"\t"$2"\t"$3}' > ${querybase}_pav_region_final3.txt
bedtools getfasta -fi ${query} -bed ${querybase}_pav_region_final2.txt -name | fold -w 80 > ${querybase}_pavs_confirm_final2.fa
perl $6/get_the_pav_seq.pl ${querybase}_pav_region_final3.txt ${querybase}_pavs_confirm_final2.fa ${querybase}_pav_seq_final.fa ${querybase}_pav_final.agp ${querybase}_pav_final.bed ${querybase}
intersectBed -a ${querybase}_pav_final.bed -b ${querygff} -wa -wb > ${querybase}_gene_relocation_final.txt
perl $6/get_gff3_file.pl ${querybase}_gene_relocation_final.txt ${querybase}_gene_relocation_final.gff3
cat ${ref} ${querybase}_pav_seq_final.fa > pangenome$5.fa
cat ${refgff} ${querybase}_gene_relocation_final.gff3 > pangenome$5.gff3

echo -n "Number of ${querybase} PAVs added to the pan-genome${5}: "
cat ${querybase}_pav_final.bed | wc -l
echo -n "Number of ${querybase} genes added to the pan-genome${5}: "
grep -cP "\tgene\t" ${querybase}_gene_relocation_final.gff3
echo -n "Average length of ${querybase} PAVs: "
awk '{n=$6-$5;sum+=n}END{print sum/NR/1000"Kb"}' ${querybase}_pav_final.bed
echo -n "Total size of the pan-genome${5}: "
ls -lh pangenome${5}.fa  | awk '{print $5}'
echo -n "Total number of genes in the pan-genome${5}: "
grep -Pc "\tgene\t" pangenome${5}.gff3


#--------------------------------------------------------------------------------------------------

cp pangenome$5.fa ../
cp pangenome$5.gff3 ../

echo -e "\nJob successfully completed. Check current directory for final results!"
