#!/bin/sh
# Author: Hernan Morales Durand
# Input parameters:
#
#	$1 : Illumina Final Report ZIP file
#	$2 : Name of the PED/MAP file without extension
#	$3 : Name of the filtered PED/MAP without extension
#
# Output files:

frptzip=$1
frptcsv=${frptzip/zip/csv}
pmfile=$2
fpmfile=$3

# Uncompress Illumina Final Report
# unzip IGEVET_EQN65KV02_20170605_FinalReportCNV.zip
unzip $frptzip

echo "Extract SNP names from Map files..."
#cut -f 2 EQN65kCAR.map > EQN65kCAR.f2.map
cut -f 2 $pmfile.map > $pmfile.f2.map
# cut -f 2 EQN65kCAR-GENO01.map > EQN65kCAR-GENO01.f2.map
cut -f 2 $fpmfile.map > $fpmfile.f2.map

echo "Sorting both maps..."
# sort EQN65kCAR.f2.map > EQN65kCAR.f2.sorted.map
sort $pmfile.f2.map > $pmfile.f2.sorted.map
# sort EQN65kCAR-GENO01.f2.map > EQN65kCAR-GENO01.f2.sorted.map
sort $fpmfile.f2.map > $fpmfile.f2.sorted.map

echo "Write filtered SNPs to a new file..."
# comm -3 EQN65kCAR.f2.sorted.map EQN65kCAR-GENO01.f2.sorted.map > EQN65kCAR.removed.snps
comm -3 $pmfile.f2.sorted.map $fpmfile.f2.sorted.map > $pmfile.fltr.snps

echo "Downloading and installing Pharo..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/hernanmd/pi/master/install.sh)"

echo "Filter FinalReport CNV and build PennCNV input files..."
export frptcsv
export pmfile
./pharo -headless Pharo.image st build-penncnv-in.st
