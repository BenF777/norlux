# norlux

Pipeline for NorLux Project

Command Line Usage Example:
```. runNorlux.sh configuration.conf 161216-ARHBV_NorLux_3 161216-ARHBV_NorLux_3 1 1 ```

The final filtered and annotated variant calls are saved to ```*.hg19_multianno.xlxs``` files

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
