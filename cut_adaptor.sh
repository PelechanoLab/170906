#!/bin/bash

module load cutadapt
module load bwa
module load samtools

while getopts "hr:i:o:" opt; do
        case $opt in
        h) 
                echo "Usage: demultiplex.sh -i <input directory> -d <sequence settings> -x 1,1 -o <output directory>"
                exit 0
                ;;
        r) ref=$OPTARG;;
        i) indir=$OPTARG;;
        o) outdir=$OPTARG;;
        esac
done

if [ ! -d "$indir" ];then
        echo "Input directory does not exist!"
        exit 0
fi

if [ ! -d "$outdir" ];then
        echo "Output directory does not exist! Generate directory."
        mkdir $outdir
fi

indir=${indir%/}
outdir=${outdir%/}

for fq1 in $indir/*R1_001.fastq.gz; do
	s=${fq1##*/}
	s=${s%_S*fastq*}
	fq2=${fq1/_R1_001./_R2_001.}
	cutfq1=${fq1/_R1_001./_R1_cutadapt.}
	cutfq2=${fq2/_R2_001./_R2_cutadapt.}
	cutadapt -a "GATCGGAAGAGCACACGTCTGAACTCCAGTCAC" -A "AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT" --match-read-wildcards --nextseq-trim=20 -o $cutfq1 -p $cutfq2 $fq1 $fq2 > $indir/cutadapt_$s.log
	bwa mem -R '@RG\tID:'$s'\tSM:'$s'' $ref $cutfq1 $cutfq2 > $outdir/$s.sam
	samtools view -b -F 4 -o $outdir/$s.bam $outdir/$s.sam
done
