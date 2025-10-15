#!/usr/bin/env bash
#PBS -q sequentiel
#PBS -l mem=1g
#PBS -l ncpus=2
#PBS -l walltime=24:00:00

source "/path/to/project/SCRIPTS/config.sh"
cd ${SCRIPTS}

# Set main directories and file paths
OUTPUT=${OUTPUT_FINAL_VCF}
INPUT=${OUTPUT_FINAL_BAM}
SCRIPT_OUTPUT=${SCRIPT_OUTPUT}
export TMPDIR=${TEMP_DIR}

NB=0  # Initializing a variable NB to 0 (in case if you want to add sample later) each sample need to have an unique value
N_FILE=$(< "${POPMAP}" wc -l)  # Counting number of lines in POPMAP file 
array_job=`echo "-J 1-${N_FILE}"`  # Generating array job specification, one job per sample
cd ${SCRIPT_OUTPUT}


#### Adapt of the number of contig/chromosomes (1-626 here) 

# Start the iteration from sample 197 to the total number of samples
for Iter_ind in `seq 1 ${N_FILE}`; do

  # Extract the sample name from the population map file (POPMAP)
  FILE=$(awk -v Iter=${Iter_ind} '{if(NR==Iter) print $1}' ${POPMAP_BAM})
 
  # Create a new script for bcftools mpileup and variant calling
  cat > BCFTOOLS_mpileup_INDV_${Iter_ind}.sh << EOF
#!/usr/bin/env bash
#PBS -q omp  
#PBS -l mem=5g
#PBS -l ncpus=2
#PBS -l walltime=24:00:00
#PBS -J 1-626

# omp  #Request OpenMP parallel queue
# mem=5g  # Allocate 5GB memory
# ncpus=2  # Use 2 CPUs for multithreading
# walltime=24:00:00  # Set a wall time limit of 24 hours
# -J 1-626  # Array job over 626 contigs

# Load the BCFTOOLS environment
source /appli/bioinfo/bcftools/1.13/env.sh

# Iterate over contigs using PBS_ARRAY_INDEX
Iter_1=\${PBS_ARRAY_INDEX}

# Change directory to the output directory
cd ${OUTPUT}

# Run bcftools mpileup to generate VCF files, and call variants with bcftools call
bcftools mpileup -r Desmophyllum_pertusum_contig_\${Iter_1} -Ov -f ${REF_G} ${FILE} --annotate FORMAT/AD,FORMAT/ADF,FORMAT/ADR,FORMAT/DP,FORMAT/SP,INFO/AD,INFO/ADF,INFO/ADR | bcftools call --threads 2 -m -Oz -f GQ -o ${OUTPUT}/VCF_contig_\${Iter_1}_INDV_${Iter_ind}.vcf.gz

EOF

  # Submit the job to the PBS queue
  qsub BCFTOOLS_mpileup_INDV_${Iter_ind}.sh
done
