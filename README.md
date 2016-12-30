# norlux

Pipeline for NorLux Project

Tools used:
- FastQ Generation: bcl2fastq
- FastQ Trimming: FastX
- FastQ Quality Control: FastQC
- Alignment: BWA mem
- Variant Calling: Samtools & Platypus
- Variant Filtering: VariantAnnotation
- Variant Annotation: Annotator

Variant Filtering Settings:
- Minimum Coverage: 40x
- Minimum Variant Allele Frequency: 10% (0.1)
- Strand Bias: 0
