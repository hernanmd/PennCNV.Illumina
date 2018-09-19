# Introduction

Workflow for Equine 65K PennCNV analysis

# Installation

  - Download and install [PennCNV](http://penncnv.openbioinformatics.org/en/latest/user-guide/download/)
  - Open [GitBash](https://git-scm.com/downloads), create and cd to a working directory for example: ```mkdir /c/bio_jobs; cd /c/bio_jobs```
  - Clone this repository.
  - Put your Illumina Final Results into the directory, i.e.: EQN65KV02_20170605_FinalReportCNV.zip (do not uncompress).
  - Put both your original PED/MAP files and already filtered PED/MAP files into the directory.
    
 # Usage
 
```bash
./build_penncnv.sh EQN65KV02_20170605_FinalReportCNV.zip EQN65KV02 EQN65KV02.fltr
```
  - First parameter is a ZIP files containing Illumina Final Report CSV file.
  - Second parameter is the name of the PED/MAP file without the extension.
  - Third parameter is the name of the filtered PED/MAP file without the extension.
  - Fourth parameter is the Illumina SNP_Map.txt (tab-delimited) file.

Edit the file run_penncnv.sh to adjust parameters and/or enable downloading the GC file (required for the first time): 

```
./run_penncnv.sh EQN65KV02.fltr.ped
```

 # Issues
 
   - Please report issues here: [https://github.com/hernanmd/PennCNV.Illumina/issues](https://github.com/hernanmd/PennCNV.Illumina/issues) describing:
     - Your platform (Operating System, Architecture: i686, x64)
     - The command you have used.
     - The produced output. 
       - To copy text from MSYS2 or GitBash console, please go to the upper left menu and select Edit and then Mark.
 
 # License
 
This software is licensed under the MIT License.

Copyright Hernán Morales Durand, 2018.

Permission is hereby granted, free of charge, to any person obtaining  a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Authors

Hernán Morales Durand
