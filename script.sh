#!/bin/bash

module load bcl2fastq
module load FastQC

OPTIND=1

while getopts "hd:i:o:r:" opt; do
        case $opt in
        h) 
                echo "Usage: script.sh -i <input raw data directory> -d <sequence index> -o <output directory>"
                exit 0
                ;;
        d) index=$OPTARG;;
        i) indir=$OPTARG;;
        o) outdir=$OPTARG;;
	r) ref=$OPTARG;;
        esac
done

indir=${indir%/}
outdir=${outdir%/}
sampleSheet=${outdir%/}/sampleSheet.csv

#write a sample sheet
./prep_sampleSheet.sh $index > $sampleSheet
#demultiplex the raw data
bcl2fastq -R $indir -o $outdir/Fastq --sample-sheet $sampleSheet
#count read number for each sample
awk -F"[<>]" '$0~"Sample name"{split($0,n,"\"");printf ("%s\t",n[2])};$0~"Barcode name=\"all\""{getline; getline;printf("%s\n",$3)}' $outdir/Fastq/Stats/DemultiplexingStats.xml > $outdir/Fastq/demultiplex_stat.txt
#Quality check
mkdir $outdir/fastqc
for i in $outdir/Fastq/fastq/*fastq.gz; do fastqc -o $outdir/fastqc $i; done
#trim adaptor and align
mkdir $outdir/mapping
./cut_adaptor.sh -i $outdir/Fastq/fastq -o $outdir/mapping -r $ref
#merge bam files
samtools merge $outdir/mapping/allSamples.bam $outdir/mapping/*bam
#sort the large bam file
samtools sort -o $outdir/mapping/allSamples_sorted.bam $outdir/mapping/allSamples.bam
#index the large bam file
samtools index $outdir/mapping/allSamples_sorted.bam
#identify variants
java -jar /sw/apps/bioinfo/GATK/3.7/GenomeAnalysisTK.jar -T HaplotypeCaller -R $ref -I $outdir/mapping/allSamples_sorted.bam -o $outdir/allSamples.vcf
#extract info from vcf file

