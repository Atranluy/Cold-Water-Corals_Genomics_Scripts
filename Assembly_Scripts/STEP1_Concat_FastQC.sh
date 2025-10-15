#!/usr/bin/env bash
#PBS -q sequentiel    
#PBS -l mem=1g
#PBS -l walltime=24:00:00


source "/path/to/project/SCRIPTS/config.sh"  
# Count the number of samples (lines) in the population map file (POPMAP)
N_FILE=$(wc -l < "${POPMAP}")

# Move to the directory for script output
cd ${SCRIPT_OUTPUT}

# Generate the array job script for concatenating fastq files
cat > Concat_Fastq_ARRAY.sh << EOF
#!/usr/bin/env bash
#PBS -q sequentiel
#PBS -l mem=1g
#PBS -l walltime=12:00:00
#PBS -J 1-${N_FILE}

# Load configuration within the array job script
source "/path/to/project/SCRIPTS/config.sh"

# Define the array job variable
ITER=\${PBS_ARRAY_INDEX}  # Job array index, iterates through samples in POPMAP

# Retrieve the sample name from the population map at the current line
SAMPLE=\$(awk -v ITER=\${PBS_ARRAY_INDEX} '{if(NR==ITER) print \$1}' \${POPMAP})

# Ensure output directory exists
mkdir -p \${OUTPUT_DIR_CONCAT}

# Merge R1 FASTQ files for the sample across lanes
echo "Merging \${INPUT_DIR_FASTQ}/\${SAMPLE}_L002_R1.fastq.gz \${INPUT_DIR_FASTQ}/\${SAMPLE}_L003_R1.fastq.gz > \${OUTPUT_DIR_CONCAT}/\${SAMPLE}_R1.fastq.gz"
cat \${INPUT_DIR_FASTQ}/\${SAMPLE}_L002_R1.fastq.gz \${INPUT_DIR_FASTQ}/\${SAMPLE}_L003_R1.fastq.gz > \${OUTPUT_DIR_CONCAT}/\${SAMPLE}_R1.fastq.gz

# Display line counts for verification
zcat \${INPUT_DIR_FASTQ}/\${SAMPLE}_L002_R1.fastq.gz | wc -l 
zcat \${INPUT_DIR_FASTQ}/\${SAMPLE}_L003_R1.fastq.gz | wc -l 
zcat \${OUTPUT_DIR_CONCAT}/\${SAMPLE}_R1.fastq.gz | wc -l

# Merge R2 FASTQ files for the sample across lanes
echo "Merging \${INPUT_DIR_FASTQ}/\${SAMPLE}_L002_R2.fastq.gz \${INPUT_DIR_FASTQ}/\${SAMPLE}_L003_R2.fastq.gz > \${OUTPUT_DIR_CONCAT}/\${SAMPLE}_R2.fastq.gz"
cat \${INPUT_DIR_FASTQ}/\${SAMPLE}_L002_R2.fastq.gz \${INPUT_DIR_FASTQ}/\${SAMPLE}_L003_R2.fastq.gz > \${OUTPUT_DIR_CONCAT}/\${SAMPLE}_R2.fastq.gz

# Display line counts for verification
zcat \${INPUT_DIR_FASTQ}/\${SAMPLE}_L002_R2.fastq.gz | wc -l 
zcat \${INPUT_DIR_FASTQ}/\${SAMPLE}_L003_R2.fastq.gz | wc -l 
zcat \${OUTPUT_DIR_CONCAT}/\${SAMPLE}_R2.fastq.gz | wc -l
EOF

# Make the generated script executable
chmod +x Concat_Fastq_ARRAY.sh

echo "Concat_Fastq_ARRAY.sh has been generated and made executable in ${SCRIPT_OUTPUT}."

# Uncomment the following line to submit the script automatically
# qsub Concat_Fastq_ARRAY.sh