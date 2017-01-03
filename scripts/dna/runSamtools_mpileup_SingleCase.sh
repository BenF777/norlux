#!/bin/bash
CONFIG_FILE=$1
source $CONFIG_FILE

OUT_PATH=$2
BED_FILE=$3
FILENAME=$4

echo "run samtools"
OUT=$OUT_PATH/$(basename $FILENAME)
OUT=${OUT%_aligned.dupsMarked.bam}
OUT=${OUT}_MPILEUP
echo $OUT

#echo $FILENAME #$OUT
REFERENCE=/home/benflies/NGS/references/hg19/ucsc.hg19.fa

samtools mpileup -u -f $REFERENCE $FILENAME | bcftools call -cv -V indels > ${OUT}.bcf
bcftools view ${OUT}.bcf > ${OUT}.vcf
bgzip -c $OUT.vcf > $OUT.vcf.gz
tabix -p vcf $OUT.vcf.gz

#Filter
echo "FILTER $OUT"

Rscript $SCRIPT_PATH/dna/VariantFilter_mpileup_SNP.R 40 0.1 0.1 ${OUT}.vcf.gz

#variant annotation
echo "VARIANT ANNOTATION"
bash $SCRIPT_PATH/dna/anovar_annotate.sh $CONFIG_FILE  $(ls -d -1 ${OUT}_filtered_DP40_AF0.1.vcf)

Rscript $SCRIPT_PATH/dna/annovar_csv2xlsx_mpileup.R  $(ls -d -1 ${OUT}_filtered_DP40_AF0.1.hg19_multianno.csv)

echo "$OUT finished"
