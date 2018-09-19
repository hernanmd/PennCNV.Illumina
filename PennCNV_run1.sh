#!/bin/bash
# Author : Hernán Morales Durand
#
# Input parameters:
# 	Project name prefix. Ex: EQN65k
#	Illumina Final Report file name. Ex: EQN65k.CSV
# 	SNP Map (from Illumina results) file name
#
# Output files:
#	PFB (Population B-Allele Frequency) file : .pfb
#	GC Model File : .gcmodel
# 	Output directory with PennCNV results

prj_prefix=$1
illumina_final_report=$2
#EQN65kCAR_FR-GENO01.csv
gc_file_prefix="gc5Base"
gc_file=$gc_file_prefix".txt"
gc_file_sorted=$gc_file_prefix"_equCab2_sorted.txt"
#GC_FILE_GZ=$gc_file".gz"
#GC_FILE_URL="http://hgdownload.cse.ucsc.edu/goldenPath/equCab2/database/"$GC_FILE_GZ

# Output files:
pfb_file=$prj_prefix".pfb"
gc_file_model=$prj_prefix".gcmodel"
signal_output_dir="PennCNV_run1/"
#signal_output_dir="PennCNV_signals/"
signal_output_suffix=".txt"
signal_file_list="signal_filtered_file_names.txt"

##############################################
# Compile PFB
##############################################

echo "Using $gc_file_sorted for building PFB"
echo "Using GC MODEL: $gc_file_model"

snp_map="SNP_Map_filtered.txt"

[ -f $illumina_final_report ] || { echo "ERROR: Illumina Final Report ($illumina_final_report) not found in current directory"; exit 1; }
[ -f $gc_file_sorted ] || { echo "ERROR: GC file ($gc_file) not found in current directory"; exit 1; }
[ -f $snp_map ] || { echo "ERROR: SNP Map file ($snp_map) not found in current directory"; exit 1; }

##############################################
# Detect CNV parameters
##############################################
hmm1="/usr/local/src/PennCNV-1.0.4/lib/hhall.hmm"
hmm2="/usr/local/src/PennCNV-1.0.4/example/example.hmm"
minsnp=3
lastchr=31
log_file1=hmm1.minsnp_"$minsnp".log
raw_file1=hmm1.minsnp_"$minsnp".rawcnv
qc_log_file1=hmm1_minsnp_"$minsnp".log
qclrrsd1=0.3
qc_passout1=hmm1_minsnp_"$minsnp".qcpass
qc_sumout1=hmm1_minsnp_"$minsnp".qcsum
qc_goodcnv1=hmm1_minsnp_"$minsnp".goodcnv

log_file2=hmm2.minsnp_"$minsnp".log
raw_file2=hmm2.minsnp_"$minsnp".rawcnv

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

# Download GC file

# wget $GC_FILE_URL; gunzip $GC_FILE_GZ; sort -k 2,2 -k 3,3n < $gc_file > $GC_FILE_SORTED

# Make GC model
echo "About creating GC Model..."
cal_gc_snp.pl \
	$gc_file_sorted $pfb_file \
	-output $gc_file_model
echo "done"

echo "About detecting CNVs method 1..."
detect_cnv.pl \
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
	-qclrrsd1 $qclrrsd \
	-qcpassout $qc_passout1  \
	-qcsumout $qc_sumout1 \
	-out $qc_goodcnv1
