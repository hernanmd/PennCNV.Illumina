#!/bin/sh
# Author: Hernan Morales Durand
# Input parameters:
#
#	Illumina Final Report ZIP file
#	Name of the PED/MAP file without extension
#	Name of the filtered PED/MAP without extension
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

echo "Write removed SNPs to new file..."
# comm -3 EQN65kCAR.f2.sorted.map EQN65kCAR-GENO01.f2.sorted.map > EQN65kCAR.removed.snps
comm -3 $pmfile.f2.sorted.map $fpmfile.f2.sorted.map > $pmfile.removed.snps

echo "Downloading and installing Pharo..."
#curl -O https://raw.githubusercontent.com/hernanmd/pi/master/pi
#chmod 755 pi
#./pi install NeoCSV
wget -O- get.pharo.org/stable | bash

echo "Filter FinalReportCNV..."
export frptcsv
export pmfile
export pmfile
pharo -headless Pharo.image eval st buildFR4signalList.st
pharo -headless Pharo.image eval st buildMap4CompilePFB.st
