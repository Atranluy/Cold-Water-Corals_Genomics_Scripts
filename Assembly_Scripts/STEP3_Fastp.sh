#!/usr/bin/env bash
#PBS -q sequentiel
#PBS -l mem=1g
#PBS -l ncpus=2
#PBS -l walltime=24:00:00


source "/path/to/project/SCRIPTS/config.sh"
cd ${SCRIPTS}

# Set main directories and file paths
OUTPUT=${OUTPUT_DIR_FASTP}
INPUT=${OUTPUT_DIR_CONCAT}
SCRIPT_OUTPUT=${SCRIPT_OUTPUT}
export TMPDIR=${TEMP_DIR}

# Count the number of samples (lines) in the population map file (POPMAP)
N_FILE=$(wc -l < "${POPMAP}")

# Move to the directory for script output
cd ${SCRIPT_OUTPUT}

# Generate the array job script to process each sample using fastp
cat > FASTp_Array.sh << EOF
#!/usr/bin/env bash
#PBS -q omp
#PBS -l mem=5g
#PBS -l ncpus=4
#PBS -l walltime=12:00:00
#PBS -J 1-${N_FILE}

# Load fastp environment
source /appli/bioinfo/fastp/0.23.2/env.sh

# Get sample name from POPMAP
Iter=\${PBS_ARRAY_INDEX}   
IND=\$(awk 'NR==Iter {print \$1}' ${POPMAP})

# Run fastp on paired-end reads, trimming the first 10 bases of both forward and reverse reads
fastp -i ${INPUT_DIR}/\${IND}_R1.fastq.gz -I ${INPUT_DIR}/\${IND}_R2.fastq.gz \
      -o ${OUTPUT_DIR}/\${IND}_R1.fastq.gz -O ${OUTPUT_DIR}/\${IND}_R2.fastq.gz \
      -f 10 -F 10

EOF

# Submit the generated script to the job scheduler
qsub FASTp_Array.sh
