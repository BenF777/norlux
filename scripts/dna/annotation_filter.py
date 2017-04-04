#!/usr/bin/python
# -*- coding: utf-8 -*-

import csv
import re
import sys

#INPUT_CSV = sys.argv[1]
INPUT_CSV = "/home/benflies/Desktop/NGS_DATA/170217-B2CTH_20170217_NorLux5/out/var_samtools/FemaleReference_aligned.bam.dupsMarked.bam_samtools_snv_filtered_DP_FREQ_SB_intervals.hg19_multianno_reordered.csv"
INPUT = re.sub(".csv", '', INPUT_CSV)
OUTPUT_CSV = INPUT+"_filtered.csv"

def csv_to_dict(file_name):
    rows = []
    with open(file_name, "rt") as csv_file:
        reader = csv.DictReader(csv_file)
        for row in reader:
            rows.append(row)
    return rows

in_csv = csv_to_dict(INPUT_CSV)

with open(OUTPUT_CSV, 'w') as res:
    for i in in_csv:
        header = []
        for name, row in i.items():
            header.append(name)
        break

    writer = csv.DictWriter(res, fieldnames=header)
    writer.writeheader()

    for variant in in_csv:
        if float(variant['Variant_Allele_Frequency']) < float(0.2):
            continue
        if variant['ExonicFunc.refGene'] == 'NA' or variant['ExonicFunc.refGene'] == 'synonymous SNV':
            continue
        if variant['cosmic68'] == 'NA':
            continue
        else:
            writer.writerow(variant)
