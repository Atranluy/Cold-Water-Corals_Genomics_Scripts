# Cold-Water-Coral_Genomics_Scripts

Scripts for Whole-genome data assembly and analysis for the CWC project.

## Overview
In this repository, you will find different folders and README files that provide scripts for various stages of whole-genome data assembly and analysis.

## Repository Structure
- **Assembly_Scripts/**: Contains all scripts for the assembly of raw reads to VCF.
- **Filtering_Scripts/**: Contains all scripts for VCF filtering.
- **File_conversion_scripts/**: Contains all scripts for converting VCF to different specific format 

Scripts are written in Bash, Python, and R. Most of them are designed for HPC systems using PBS job queries but can be easily adapted to SGE or Slurm job scheduler.

## Usage
Each folder contains specific scripts along with a README file that provides detailed information on how to use the scripts within that folder.
NB: Scripts are written for PBS HPC job scheduler , if you're using a Slurm0 HPC job scheduler, you will need to adapt all scripts.
### Assembly_Scripts
This folder includes scripts to:
1. Quality control of raw reads
2. Trimming and filtering reads
3. Genome assembly
4. Variant calling to generate VCF files

### Filtering_Scripts
This folder includes scripts to:
1. Filter VCF files
2. Prepare data for downstream analysis

### File_conversion_scripts
1.


## Prerequisites
- Installed dependencies: Bash, Python, R, and other relevant bioinformatics tools (e.g., FastQC, Fastp, BWA-MEM, GATK, BCFtools, VCFtools....).
- Depending of the cluster/machine you may use, you can generate a mamba environment (conda like environment) and install all theses software within this environment with bioconda.
