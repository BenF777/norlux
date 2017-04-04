# norlux

Pipeline for NorLux Project

Command Line Usage Example:
```. runNorlux.sh configuration.conf 161216-ARHBV_NorLux_3```

Tools used:
- FastQ Generation: bcl2fastq
- FastQ Trimming: FastX
- FastQ Quality Control: FastQC
- Alignment: BWA mem
- Variant Calling: Samtools (SNVs) & Platypus (Indels)
- Variant Filtering: VariantAnnotation
- Variant Annotation: Annovar

Variant Filtering Settings:
- Minimum Coverage: 40x
- Minimum Variant Allele Frequency: 10% (0.1)
- Strand Bias: 0
