library(CNVPanelizer)

bedFilepath <- "/home/benflies/github/norlux/scripts/bed/3037891_Covered_chr11.bed"

amplColumnNumber <- 4

genomicRangesFromBed <- BedToGenomicRanges(bedFilepath, ampliconColumn = amplColumnNumber, split = "_")
genomicRangesFromBed

metadataFromGenomicRanges <- elementMetadata(genomicRangesFromBed)
geneNames = metadataFromGenomicRanges["geneNames"][,1]
ampliconNames = metadataFromGenomicRanges["ampliconNames"][,1]

sampleDirectory <- "/home/benflies/Desktop/NGS_DATA/170217-B2CTH_20170217_NorLux5/out/bam/test"
referenceDirectory<- "/home/benflies/Desktop/NGS_DATA/170217-B2CTH_20170217_NorLux5/out/bam/reference"

sampleFilenames <- list.files(path = sampleDirectory, pattern = ".bam$", full.names=TRUE)
referenceFilenames <- list.files(path = referenceDirectory, pattern = ".bam$", full.names=TRUE)
sampleFilenames

removePcrDuplicates <- FALSE

sampleReadCounts <- ReadCountsFromBam(sampleFilenames, genomicRangesFromBed, sampleNames = sampleFilenames, ampliconNames = ampliconNames, removeDup = removePcrDuplicates)
referenceReadCounts <- ReadCountsFromBam(referenceFilenames, genomicRangesFromBed, sampleNames = referenceFilenames, ampliconNames = ampliconNames, removeDup = removePcrDuplicates)
sampleReadCounts

normalizedReadCounts <- CombinedNormalizedCounts(sampleReadCounts, referenceReadCounts, ampliconNames = ampliconNames)

samplesNormalizedReadCounts = normalizedReadCounts["samples"][[1]]
referenceNormalizedReadCounts = normalizedReadCounts["reference"][[1]]

replicates <- 1000000
bootList <- BootList(geneNames, samplesNormalizedReadCounts, referenceNormalizedReadCounts, replicates = replicates)

backgroundNoise <- Background(geneNames, samplesNormalizedReadCounts, referenceNormalizedReadCounts, bootList, replicates = replicates, significanceLevel= 0.0000001, robust = TRUE)

reportTables <- ReportTables(geneNames, samplesNormalizedReadCounts, referenceNormalizedReadCounts, bootList, backgroundNoise)

PlotBootstrapDistributions(bootList, reportTables, outputFolder="/home/benflies/Desktop", save=TRUE, scale = 14)
