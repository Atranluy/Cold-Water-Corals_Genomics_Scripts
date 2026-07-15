#!/usr/bin/env bash
#PBS -q sequentiel
#PBS -l mem=1g
#PBS -l ncpus=2
#PBS -l walltime=24:00:00
#PBS -J 1-626

source "/path/to/project/SCRIPTS/config.sh"
cd ${SCRIPTS}

# Load the BCFTOOLS environment
source /appli/bioinfo/bcftools/1.13/env.sh

# Set main directories and file paths
OUTPUT=${OUTPUT_FINAL_VCF}
INPUT=${OUTPUT_FINAL_BAM}
SCRIPT_OUTPUT=${SCRIPT_OUTPUT}
export TMPDIR=${TEMP_DIR}


ITER=${PBS_ARRAY_INDEX}

N_FILE=$(< "${POPMAP}" wc -l)  # Counting number of lines in POPMAP file 
cd ${SCRIPT_OUTPUT}

for i in {1..${N_FILE}}; do
	echo "VCF_contig_${ITER}_INDV_${N_FILE}.vcf.gz" >> list_contig_vcf_${ITER}.txt
done
bcftools merge -l list_contig_vcf_${ITER}.txt -Oz -o VCF_all_samples_contig_${ITER}.vcf.gz --threads 2

