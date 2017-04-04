#!/bin/bash

CONFIG_FILE=$1
source $CONFIG_FILE
echo $SERVER_NGS_PATH

RUN_ID=$2
RUN_NAME=$RUN_ID

TRIMMER_LEFT=2
TRIMMER_RIGHT=2

FILE_PATH=$RUN_PATH/out
FASTQ_PATH=$FILE_PATH/fastq_tmp
FASTQ_DEMUX=$FILE_PATH/fastq
BAM_PATH=$FILE_PATH/bam
LOG_PATH=$FILE_PATH/log
VAR_PATH_SAMTOOLS=$FILE_PATH/var_samtools
VAR_PATH_PLATYPUS=$FILE_PATH/var_platypus
CNV_PATH=$FILE_PATH/cnv

#local path for processing
RUN_PATH=$LOCAL_NGS_PATH/$RUN_NAME
echo $RUN_PATH
echo

echo "RUN Agilent paired end with BWA mem"

echo "Lib: $RUN_ID"
echo "Run-Name: $RUN_NAME"
date
echo
echo "COPY"
echo

mkdir -p $LOCAL_NGS_PATH/$RUN_ID

#COPY to local workstation
#time cp -rf $SERVER_NGS_PATH/$RUN_NAME $LOCAL_NGS_PATH

#Create output directories in the local run copy
mkdir -p $FASTQ_DEMUX
mkdir -p $FASTQ_PATH
mkdir -p $LOG_PATH
mkdir -p $BAM_PATH

#Generate FASTQ files
echo "Convert Bcl To Fastq"
#bash $SCRIPT_PATH/bcl/convertBclToFastq.sh $RUN_PATH
#wait

mv $FASTQ_PATH/* $FASTQ_DEMUX/

#Trim low-quality bases from FASTQ reads
#Cut 2 bases from the ends of each read -> is necessary due to A-tailing in the Lib Prep workflow.

echo "TRIMMER"
find $FASTQ_DEMUX -name "*R1*.fastq.gz" | grep -v I1 | grep -v Undetermined | grep -v trimmed | sort | parallel -P$DNA_PARALLEL_ALIGNMENT -n1 bash $SCRIPT_PATH/qc/fastxTrimmer_bothSites.sh $CONFIG_FILE $TRIMMER_LEFT $TRIMMER_RIGHT $FASTQ_DEMUX
find $FASTQ_DEMUX -name "*R2*.fastq.gz" | grep -v I1 | grep -v Undetermined | grep -v trimmed | sort | parallel -P$DNA_PARALLEL_ALIGNMENT -n1 bash $SCRIPT_PATH/qc/fastxTrimmer_bothSites.sh $CONFIG_FILE $TRIMMER_LEFT $TRIMMER_RIGHT $FASTQ_DEMUX
wait

#Perform a Quality Control on FASTQ files
#Do this for both trimmed and untrimmed FASTQ files -> see how trimming affects data

echo "FASTQC"
time bash $SCRIPT_PATH/qc/generateFastqc.sh $CONFIG_FILE $RUN_PATH &
wait

#Align reads to reference genome (hg19) with BWA MEM
echo "ALIGNMENT"
SCRIPT="bash $SCRIPT_PATH/dna/bwaAllignmentPairedRead.sh $CONFIG_FILE $BAM_PATH $LOG_PATH $RUN_ID"
find $FASTQ_DEMUX -name "*trimmed.fastq.gz" | grep -v I1 | grep -v Undetermined | sort | parallel -P $DNA_PARALLEL_ALIGNMENT -n2 $SCRIPT
wait

#Copy Number Variant Analysis
#Still testing, still did not find a satisfying tool.
#Optimally we want something like the CNV tool for the Hereditary Cancer Solution in SophiaDDM.

#echo "CNV"
#mkdir -p $CNV_PATH
#ACT_BED_FILE=$SCRIPT_PATH/bed/3037891_Covered.bed
#find $BAM_PATH -name "*.dupsMarked.bam" | while read fname; do
#      file_name=$(basename "$fname")
#      Rscript $SCRIPT_PATH/cnv/cnv_analysis_seqCNA_seqRun.R $SERVER_RESULT_PATH $CNV_PATH $ACT_BED_FILE $file_name $fname $RUN_ID
#done

echo "VARIANT CALLING"
#This is how they do it in the paper.
#TODO: implement other variant calling algorithms (samtools apparently isn't the best one)
#TODO: compare the results of these algorithms

mkdir -p $VAR_PATH_SAMTOOLS
mkdir -p $VAR_PATH_PLATYPUS

find $BAM_PATH -name "*dupsMarked.bam" | while read fname; do
      echo $fname
      #bash $SCRIPT_PATH/dna/runSamtools_INDEL.sh $CONFIG_FILE $VAR_PATH_SAMTOOLS $ACT_BED_FILE $fname &
      bash $SCRIPT_PATH/dna/runSamtools_SNV.sh $CONFIG_FILE $VAR_PATH_SAMTOOLS $ACT_BED_FILE $fname
done

find $BAM_PATH -name "*dupsMarked.bam" | while read fname; do
      echo $fname
      #bash $SCRIPT_PATH/dna/runPlatypus_SNV.sh $CONFIG_FILE $VAR_PATH_PLATYPUS $ACT_BED_FILE $fname &
      bash $SCRIPT_PATH/dna/runPlatypus_INDEL.sh $CONFIG_FILE $VAR_PATH_PLATYPUS $ACT_BED_FILE $fname
done

#Perform a coverage analysis for QC
echo "COVERAGE"

COVERAGE_PATH=$FILE_PATH/coverage
mkdir -p $COVERAGE_PATH

find $BAM_PATH -name "*.dupsMarked.bam" | while read fname; do
      Rscript $SCRIPT_PATH/qc/CoverageTEQC.R $COVERAGE_PATH $ACT_BED_FILE $fname &
      done

echo "Analysis ready!"
