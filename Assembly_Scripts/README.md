# Cold-Water-Coral_Genomics_Scripts
## Overview

This folder contains all scripts used for the assembly of raw reads (fastq) to VCFs for CWC species.
These scripts were used on a High-Performance Computing (HPC) machine (i.e. a Cluster) with the PBS job scheduler.
If you want to reuse them on a HPC machine with slurm job scheduler, you have the change the header of each scripts and few variable ( i.e ${PBS_ARRAY_INDEX} to ${SLURM_ARRAY_TASK_ID} )


### Assembly Workflow
![Pipeline](https://github.com/user-attachments/assets/a5d61b2b-e88e-4e4b-b909-f86dcfc4797f)
0. **Generate all subfolders** 
    Before submitting jobs, we generate all the needed folder and path from a bash file. This will also be used later in subsequent jobs to get the right path.
    bash config.sh 
    
1. **Concatenate Raw Reads**  (Optional)  
   Concatenate raw sequencing reads into a single forward (R1) and reverse (R2) FASTQ file for each sample when you have multiple sequencing lanes for the same sample.
   ex:
   ```
   Sample_AXXX_R1_L001.fastq.gz and Sample_AXXX_R1_L002.fastq.gz
   ```
2. **Quality Control with FastQC** 
   Perform a quality check on the concatenated FASTQ files (R1 and R2) using **FastQC** to assess the quality of the raw sequencing data.
    NB: to merge all fastQC outputs, use multiQC.
    
3. **Clean raw reads with Fastp**  
   Clean raw reads from remaining adapter content, trim base on quality
   
4. **Mapping and Assembly**  
   This step involves mapping paired-end reads to a reference genome and processing the resulting alignments:
   - **Mapping with BWA-MEM2**: Align reads to the reference genome using **BWA-MEM2** (alternatively compatible with **BWA-MEM** or other mapping tools such).
   - **SAM to BAM Conversion**: Convert SAM files to BAM format and sort them using **SortSam** from the **Picard** tool suite.
   - **Alignment Check with Samtools**: Use **Samtools flagstat** to check the percentage of reads aligned against the reference genome.
   - **Mark Duplicates**: Identify and mark duplicate reads using **Picard MarkDuplicates**. 
   - **Add Sample Information**: Add sample-specific information to the BAM files with **Picard AddOrReplaceReadGroups**.
   - **Index BAM Files**: Create an index for each BAM file using **Samtools index** to prepare them for variant calling.

5. **Variant Calling with bcftools**  
   Call variants independently for each sample and contig (or chromosome) to avoid Hardy-Weinberg equilibrium assumption in the genotype frequencies estimates during the variant calling (in bcftools mpileup):
   - **bcftools mpileup**: Generate pileup files for each sample and contig.
   - **bcftools call**: Perform variant calling for each sample and contig independently.
6. **Merging VCFs with bcftools**
    Finally, we used a bash script and bcftools to merge all sample-VCF into a one VCF per contig but containing all samples.
    

NB: Popmap format used here is one line per sample 
```
Sample1
Sample2
Sample3
Sample4
```
Only Popmap format used in step 5 include the path and file format (you can modify the script to incorporate the path directly in the script and use the same popmap as previously).
There is an exemple: 
```
PATH/OF_THE/BAM_FILE/Sample1.bam
PATH/OF_THE/BAM_FILE/Sample2.bam
PATH/OF_THE/BAM_FILE/Sample3.bam
```

#### To run
First, generate all folders in main directory with the bash file **config.sh** 
1. Change the first path in the file and the "bash config.sh" to create all the folders.
NB: make sure you have all the input files in the correct format and name.
2. Then, you can run the pipeline step by step (by submitting each step with a qsub)

**PS : if you are running under your conda/mamba env where everything is already installed, there is no need to source each module/software in each script 
as this "source /appli/bioinfo/fastqc/0.11.9/env.sh". I did this because of the HPC specific structure.
