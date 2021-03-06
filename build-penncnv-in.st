" 
Pharo script to 
	Generate a filtered Illumina FinalReport CSV file filtering from excluded SNPs in exclsnps (for building Signal File List)
	Generate a filtered Illumina Map CSV file filtering from excluded SNPs in exclsnps. (for building PFB file)

Author: Hernan Morales Durand <hernan.morales@gmail.com>

Input parameters:

	Exported $frptcsv shell variable containing a String with CSV file name of filtered CNVs
	Exported $exclsnps shell variable containing a String with file name of excluded SNPs
	SNP_Map.txt CSV (tab delimited) file from Illumina.
	
Output files:

	CSV (comma delimited) file with .fltr extension containing 4 columns:
		SNP Name
		Sample ID
		B Allele Freq
		Log R Ratio
"
| exclsnps outfrpt osEnv frptcsv insnpmap outfrbaf outfrmap excls |

Iceberg enableMetacelloIntegration: true;
	remoteTypeSelector: #httpsUrl.
Metacello new
	configuration: 'NeoCSV';
	repository: 'github://svenvc/NeoCSV/repository';
	load.
osEnv := (SmalltalkImage current version beginsWith: 'Pharo6')
	ifTrue: [ OSEnvironment current ]
	ifFalse: [ OSEnvironment default ].
frptcsv := osEnv getEnv: 'frptcsv'.
exclsnps := (osEnv getEnv: 'pmfile') , '.fltr.snps'.
insnpmap := 'SNP_Map.txt'.
outfrbaf := frptcsv , '.fltr'.
outfrmap := insnpmap , '.fltr'. 
excls := exclsnps asFileReference contents lines.

frptcsv asFileReference readStreamDo: [ : stream |
    | reader |
    reader := (NeoCSVReader on: stream)
            separator: $,;
            yourself.
    10 timesRepeat: [ reader skipHeader ].
    outfrbaf asFileReference writeStreamDo: [ : writeStream |
        | writer |
        writer := (NeoCSVWriter on: writeStream)
            fieldWriter: #raw;
            separator: $,;
            writeHeader: #('SNP' 'Name' 'Sample ID' 'B Allele Freq' 'Log R Ratio');
            yourself.
        reader do: [ : row | (excls includes: row first) ifFalse: [ writer nextPut: row ] ].
        writer flush ] ].

insnpmap asFileReference readStreamDo: [ : stream |
    | reader |
    reader := (NeoCSVReader on: stream)
            separator: Character tab;
            skipHeader;
            yourself.
    outfrmap asFileReference writeStreamDo: [ : writeStream |
        | writer |
        writer := (NeoCSVWriter on: writeStream)
            fieldWriter: #raw;
            separator:  Character tab;
            writeHeader: #('Index Name' 'Chromosome' 'Position' 'GenTrain Score' 'SNP' 'ILMN Strand' 'Customer Strand' 'NormID');
            yourself.
        reader do: [ : row | (excls includes: row second) ifFalse: [ writer nextPut: row ] ].
        writer flush ] ].
