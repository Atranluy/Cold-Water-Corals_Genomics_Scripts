#!/usr/bin/env bash
#PBS -q sequentiel
#PBS -l mem=1g
#PBS -l ncpus=2
#PBS -l walltime=24:00:00

source "/path/to/project/SCRIPTS/config.sh"
cd ${SCRIPTS}

# Set main directories and file paths
OUTPUT=${OUTPUT_DIR_MAIN}
INPUT=${OUTPUT_DIR_FASTP}
SCRIPT_OUTPUT=${SCRIPT_OUTPUT}
OUTPUT_FINAL=${OUTPUT_FINAL_BAM}

export TMPDIR=${TEMP_DIR}

NB=0  # Initializing a variable NB to 0 (in case if you want to add sample later) each sample need to have an unique value
N_FILE=$(< "${POPMAP}" wc -l)  # Counting number of lines in POPMAP file 
array_job=`echo "-J 1-${N_FILE}"`  # Generating array job specification, one job per sample
cd ${SCRIPT_OUTPUT}

# Creating a script (array_ALL_PIPE.sh) to be executed with qsub
cat > array_ALL_PIPE.sh << EOF
#!/usr/bin/env bash
#PBS -q omp
#PBS -l mem=8g
#PBS -l ncpus=4
#PBS -l walltime=100:00:00
#PBS ${array_job}

# Setting IND and ITER variables
#IND will retrieve the sample name and ITER the job iteration 
ITER=\${PBS_ARRAY_INDEX}
IND=\$(awk -v ITER=\${PBS_ARRAY_INDEX} '{if(NR==ITER) print \$1}' ${POPMAP})

# Loading necessary environment modules
source /appli/bioinfo/bwa-mem2/2.2.1/env.sh

# Running BWA-MEM2 alignment on the reference genome with default settings
bwa-mem2 mem -t 4 ${REF_WG} ${INPUT}/\${IND}_R1.fastq.gz ${INPUT}/\${IND}_R2.fastq.gz > ${OUTPUT}/\${IND}_Paired_mapped.sam

# Sorting SAM file and convert it to BAM format. 
source /appli/bioinfo/picard/2.21.1/env.sh
picard SortSam \
    I=${OUTPUT}/\${IND}_Paired_mapped.sam \
    O=${OUTPUT}/\${IND}_Paired_mapped_sorted.bam \
    SORT_ORDER=coordinate \
    CREATE_INDEX=true \
    VALIDATION_STRINGENCY=LENIENT \
    TMP_DIR=${TEMP_DIR}

# Running flagstat to generate alignement stats.
source /appli/bioinfo/samtools/1.9/env.sh
samtools flagstat ${OUTPUT}/\${IND}_Paired_mapped_sorted.bam

source /appli/bioinfo/picard/2.21.1/env.sh
# Marking duplicates reads
picard MarkDuplicates \
    I=${OUTPUT}/\${IND}_Paired_mapped_sorted.bam \
    O=${OUTPUT}/\${IND}_Paired_mapped_sorted_markdup.bam \
    ASSUME_SORTED=TRUE \
    REMOVE_DUPLICATES=FALSE \
    CREATE_INDEX=TRUE \
    METRICS_FILE=${OUTPUT}/\${IND}_metrics_file_markdup.txt \
    VALIDATION_STRINGENCY=LENIENT \
    TMP_DIR=${TEMP_DIR}

# Adding or replacing read groups
# It add some specific information on the BAM file, see GATK AddOrReplaceReadGroups tool index for more informations.
picard AddOrReplaceReadGroups \
    I=${OUTPUT}/\${IND}_Paired_mapped_sorted_markdup.bam  \
    O=${OUTPUT_FINAL}/\${IND}_Paired_mapped_sorted_markdup_rg.bam \
    RGID=\$((\${ITER}+${NB})) \
    RGPL=Novaseq \
    RGLB=lib \
    RGPU=WGS_lib_collab \
    RGSM=\${IND} \
    TMP_DIR=${TEMP_DIR}

# Indexing final BAM file
samtools index ${OUTPUT_FINAL}/\${IND}_Paired_mapped_sorted_markdup_rg.bam
EOF

# Submitting the script (array_ALL_PIPE.sh) for execution using qsub
qsub array_ALL_PIPE.sh
