#!/bin/bash
# config.sh - Generic configuration file for project paths and settings

# Base project directory
MAIN_DIR="my_path/to/the/working_folder/Cold-Water-Coral_Genomics_Scripts-main/Assembly_Scripts"

# Data directories
INPUT_DIR_FASTQ="${MAIN_DIR}/data/input"              # Directory for input data files, can contain symlinks to raw data

##### Step 1: Concatenated fastq files
OUTPUT_DIR_CONCAT="${MAIN_DIR}/data/concat"           # Directory for concatenated fastq files (optional if only one lane used)

##### Step 2: Fastp-filtered fastq files
OUTPUT_DIR_FASTP="${MAIN_DIR}/data/FASTP"             # Directory for fastq files filtered with Fastp

##### Step 3: Assembly-related directories
OUTPUT_DIR_MAIN="${MAIN_DIR}/data/output/ASSEMBLY"    # Directory for intermediate outputs during assembly

# Final outputs
OUTPUT_FINAL_BAM="${MAIN_DIR}/data/final/FINAL_BAM_FILES"  # Directory for final BAM files
OUTPUT_FINAL_VCF="${MAIN_DIR}/data/final/VCFs"            # Directory for final VCF files

# Log and script output directory
SCRIPT_OUTPUT="${MAIN_DIR}/logs"                        # Directory for logs and script outputs

# Configuration and reference directories
SCRIPTS="${MAIN_DIR}/SCRIPTS"                             # SCRIPTS directory
POPMAP="${CONFIG}/POPMAP_SAMPLES.txt"                   # Population map for samples
POPMAP_BAM="${CONFIG}/POPMAP_BAM_FILES.txt"             # Population map for BAM files
REF_GENOME="${MAIN_DIR}/reference/genome.fa"            # Path to the reference genome file

# Temporary directory for processing
TEMP_DIR="${MAIN_DIR}/temp"
export TMPDIR="${TEMP_DIR}"                             # Set TMPDIR for system-wide temp storage

# Create all necessary directories
mkdir -p "$MAIN_DIR" "$INPUT_DIR_FASTQ" "$OUTPUT_DIR_CONCAT" "$OUTPUT_DIR_FASTP" \
         "$OUTPUT_DIR_MAIN" "$OUTPUT_FINAL_BAM" "$OUTPUT_FINAL_VCF" \
         "$SCRIPT_OUTPUT" "$SCRIPTS" "$TEMP_DIR"

# Notify that directories have been created or verified
echo "All necessary directories have been created or verified."

# Copy this config file into the config directory for use by other scripts
cp "$0" "${SCRIPTS}/config.sh"
echo "Configuration file copied to ${SCRIPTS}/config.sh for access by other scripts."

# Export variables so they’re accessible in any script that sources this config file
export MAIN_DIR INPUT_DIR_FASTQ OUTPUT_DIR_CONCAT OUTPUT_DIR_FASTP OUTPUT_DIR_MAIN \
       OUTPUT_FINAL_BAM OUTPUT_FINAL_VCF SCRIPT_OUTPUT SCRIPTS POPMAP POPMAP_BAM \
       REF_GENOME TEMP_DIR TMPDIR
