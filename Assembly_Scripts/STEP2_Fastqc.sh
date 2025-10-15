#!/usr/bin/env bash
#PBS -q sequentiel
#PBS -l mem=1g
#PBS -l ncpus=2
#PBS -l walltime=24:00:00


source "/path/to/project/SCRIPTS/config.sh"
cd ${SCRIPTS}


# Set the directories for output and input
OUTPUT=${OUTPUT_DIR_FASTQC}
INPUT=${OUTPUT_DIR_CONCAT}
SCRIPT_OUTPUT=${SCRIPT_OUTPUT}
export TMPDIR=${TEMP_DIR}
# Get the number of samples from the POPMAP file
N_FILE=$(< "${POPMAP}" wc -l)
array_job="-J 1-${N_FILE}"

# Change to the script output directory
cd "${SCRIPT_OUTPUT}"
# Create the FASTQC array job script
cat > FASTQC_Array.sh << EOF
#!/usr/bin/env bash
#PBS -q sequentiel
#PBS -l mem=4g
#PBS -l walltime=12:00:00
#PBS ${array_job}

# Load FastQC environment or module
source /appli/bioinfo/fastqc/0.11.9/env.sh

# Get the current array index and sample ID
Iter=\${PBS_ARRAY_INDEX}
IND=\$(awk -v Iter=\${PBS_ARRAY_INDEX} '{if(NR==Iter) print \$1}' ${POPMAP})

# Print the current iteration and sample ID
echo "Processing sample: \${IND} (Iteration: \${Iter})"

# Run FastQC on both R1 and R2 reads
fastqc "${INPUT}/\${IND}_R1.fastq.gz" -o "${OUTPUT}"
fastqc "${INPUT}/\${IND}_R2.fastq.gz" -o "${OUTPUT}"
EOF

# Submit the FASTQC array job script to the queue
qsub FASTQC_Array.sh
