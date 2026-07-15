# Cold-Water-Coral_Genomics_Scripts

Scripts for Whole-genome data filtering.

## Overview
This folder contains the script for filtering the VCFs.
    I used bcftools (), vcftools () and R
### Filtering Workflow
0. **Merge all samples per contig**
    Use bcftool merge to merge all samples per contig (i.e. having a VCF per contig containing all samples and all sites)

1. **Filtering for biallelic variants**
    Filtering indels, multi allelic and invariant sites for each VCFs.
    
2. **Filtering samples** 
    Filtering samples to keep only those of interest (i.e. GENET, RAMET or ALL) 

3. **Filtering for variant quality**  
    Applying different variant filtering quality based on quality and coverage.
   
4. **Filtering for variant passing ngsParalog filter**  
   This step involves a three step procedure:
        - Generating a BED file from 3. and use it to run  ngsParalog per genetic population.
        - Generating the list (BED file) of variant passing the ngsParalog threshold filter for being non deviant in **ALL** genetic populations
        - Using this final BED file for filtering variant that pass the 3.

5. **Filtering for MAF and missing data per variant**  
    Filtering variant with a minimal Minor Allele Frequency (MAF) at 0.05 and a maximum of missing data of 10%.

6. **Pruning for Physical distance**  
    Finally, I prune my variant with a minimal distance of 1000 bp.

