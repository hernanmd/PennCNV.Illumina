#!/bin/bash
# Author : Hernán Morales Durand
#
# Command-line parameters (you must provide):
# 	Project name prefix. Ex: EQN65k
#	Illumina Final Report file name. Ex: EQN65k.CSV
#
# Pre-conditions:
# 	SNP Map (from Illumina results) file should exist in current directory
#
# Script parameters (you should adjust):
#	GC file name
#	RefGene URL
#	SNP Map name
#
# Output files:
#	PFB (Population B-Allele Frequency) file : .pfb
#	GC Model File : .gcmodel
# 	Output directory with
#		Signal intensity PennCNV results
#		JPEG visualizations of signal itensity files for each individual
#		BED files for loading into UCSC Genome Browser for each individual

############################################################
# Input parameters
############################################################
prj_prefix=$1
illumina_final_report=$2
# For building GC model adjustment file .gcmodel
gc_file_prefix="gc5Base"
gc_file=$gc_file_prefix".txt"
gc_file_sorted=$gc_file_prefix"_equCab2_sorted.txt"
gc_file_gz=$gc_file".gz"
gc_file_url="http://hgdownload.cse.ucsc.edu/goldenPath/equCab2/database/"$gc_file_gz
# For annotating with scan_region.pl
refGeneUrl="http://hgdownload.soe.ucsc.edu/goldenPath/equCab2/database/refGene.txt.gz"
# For compiling PFB
snp_map="SNP_Map.txt.fltr"

##############################################################
# Output files:
##############################################################
pfb_file=$prj_prefix".pfb"
gc_file_model=$prj_prefix".gcmodel"
signal_output_dir="PennCNV_run1/"
#signal_output_dir="PennCNV_signals/"
signal_output_suffix=".txt"
signal_file_list="signal_filtered_file_names.txt"

##############################################
# Compile PFB sanity checks
##############################################

echo "Using $gc_file_sorted for building PFB"
echo "Using GC MODEL: $gc_file_model"

[ -f $illumina_final_report ] || { echo "ERROR: Illumina Final Report ($illumina_final_report) not found in current directory"; exit 1; }
# [ -f $gc_file_sorted ] || { echo "ERROR: GC file ($gc_file) not found in current directory"; exit 1; }
[ -f $snp_map ] || { echo "ERROR: SNP Map file ($snp_map) not found in current directory"; exit 1; }

##############################################
# Detect CNV parameters
##############################################

# Call CNVs containing more than or equal to 3 SNPs
minsnp=3
# Last chromosome nr
lastchr=31

############ For main HMM file
hmm1="/usr/local/src/PennCNV-1.0.4/lib/hhall.hmm"
log_file1=hmm1.minsnp_"$minsnp".log
raw_file1=hmm1.minsnp_"$minsnp".rawcnv
qc_log_file1=hmm1_minsnp_"$minsnp".log
qclrrsd1=0.3
qc_passout1=hmm1_minsnp_"$minsnp".qcpass
qc_sumout1=hmm1_minsnp_"$minsnp".qcsum
qc_goodcnv1=hmm1_minsnp_"$minsnp".goodcnv

############ For complementary HMM file
hmm2="/usr/local/src/PennCNV-1.0.4/example/example.hmm"
log_file2=hmm2.minsnp_"$minsnp".log
raw_file2=hmm2.minsnp_"$minsnp".rawcnv

###############################################################
# Begin processing
###############################################################

# Create output directories
rm -frv $signal_output_dir
rm -fv $signal_file_list
mkdir $signal_output_dir

echo "About splitting Illumina report..."
# The output is a directory with 1 file per sample
split_illumina_report.pl \
	-comma \
	-prefix "$signal_output_dir" \
	-suffix "$signal_output_suffix" "$illumina_final_report"
echo "done"

# No .pfb files? Use compile_pfb.pl
# ls='ls -lkF --color=auto'
echo "Creating signal file list"
#unalias ls
signal_files=$(ls -1 $signal_output_dir)
echo "Created signal file list: $signal_files"

# The output is a new file with directory/signal_file_name in each line
for f in $signal_files; do
	echo $signal_output_dir/$f >> $signal_file_list
done

# SNP_Map.txt from SNP_Map.zip in the Illumina raw files
# The output is a .pfb file
echo "About compiling PFB..."
compile_pfb.pl \
	--listfile $signal_file_list \
	--snpposfile $snp_map \
	--output $pfb_file
echo "done compile PFB"

# Download and sort GC file if not found
[ -f $gc_file_sorted ] || { wget $gc_file_url; gunzip $gc_file_gz; sort -k 2,2 -k 3,3n < $gc_file > $gc_file_sorted; }

# Make GC model
echo "About creating GC Model..."
cal_gc_snp.pl \
	$gc_file_sorted $pfb_file \
	-output $gc_file_model
echo "done"

echo "About detecting CNVs method 1..."
detect_cnv.pl \
	-verbose \
	-test \
	-hmm $hmm1 \
	-pfb $pfb_file \
	-minsnp $minsnp \
	-lastchr $lastchr \
	-list $signal_file_list \
	-gcmodelfile $gc_file_model \
	-confidence \
	-log $log_file1 \
	-out $raw_file1
echo "done"

echo "About detecting CNVs method 2..."
detect_cnv.pl \
	-verbose \
	-test \
	-hmm $hmm2 \
	-pfb $pfb_file \
	-minsnp $minsnp \
	-lastchr $lastchr \
	-list $signal_file_list \
	-gcmodelfile $gc_file_model \
	-confidence \
	-log $log_file2 \
	-out $raw_file2

filter_cnv.pl \
	$raw_file1 \
	-qclogfile $qc_log_file1 \
	-qclrrsd $qclrrsd1 \
	-qcpassout $qc_passout1  \
	-qcsumout $qc_sumout1 \
	-out $qc_goodcnv1

echo "Downloading refGene from UCSC..."
[ -f refGene.txt ] || { wget $refGeneUrl; gunzip refGene.txt.gz; }

echo "CNV Annotation for method 1..."
scan_region.pl --verbose --refgene_flag $raw_file1 refGene.txt > $raw_file1.annot
scan_region.pl --verbose --refgene_flag $raw_file1 refGene.txt --expandmax 5m > $raw_file1.annot.5m
scan_region.pl --verbose --overlap --refgene_flag $raw_file1 refGene.txt > $raw_file1.annot.ovlap
scan_region.pl --verbose --dbregion --refgene_flag $raw_file1 refGene.txt > $raw_file1.annot.dbregion

echo "Generating CNV Visualization files..."
for sig in $(cat $signal_file_list); do
	visualize_cnv.pl \
		-format plot \
		-out $sig.jpg \
		-signal $sig \
		--snpposfile $snp_map \
		$raw_file1
	visualize_cnv.pl \
		-format bed \
		-out $sig.bed \
		-signal $sig \
		--snpposfile $snp_map \
		$raw_file1
done
