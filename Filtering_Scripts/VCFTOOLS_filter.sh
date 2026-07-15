#!/usr/bin/env bash
#PBS -q sequentiel
#PBS -l mem=1g
#PBS -l ncpus=1
#PBS -l walltime=24:00:00
#PBS -J 1-626

ITER=${PBS_ARRAY_INDEX}
TMP_DIR="path/to/my/folder/temp"
POPMAP_GENET="path/to/my/folder/popmap_genet_Mo.txt"
OUTPUT_FINAL="path/to/my/folder/output"
BED="path/to/my/folder/ngsparalog.bed"
VCF_PATH="path/to/my/folder/vcf_files"

export TMPDIR=${TMP_DIR}
mkdir -p ${OUTPUT_FINAL}
cd ${OUTPUT_FINAL}

source /appli/bioinfo/vcftools/0.1.14/env.sh

# Step 1: Filter for biallelic variants only
vcftools --gzvcf ${VCF_PATH}/VCF_contig_${ITER}.vcf.gz --remove-indels --min-alleles 2 --max-alleles 2 --stdout --recode | gzip -c > VCF_contig_${ITER}_biallelic_only.vcf.gz

# Step 2: Filter samples to keep only GENET
vcftools --gzvcf VCF_contig_${ITER}_biallelic_only.vcf.gz --keep ${POPMAP_GENET} --stdout --recode | gzip -c > VCF_contig_${ITER}_biallelic_only_GENET.vcf.gz

# Step 3: Apply variant quality filters (minDP, minQ, etc.)
vcftools --gzvcf VCF_contig_${ITER}_biallelic_only_GENET.vcf.gz --minDP 5 --minQ 30 --max-meanDP 80 --min-meanDP 10 --stdout --recode | gzip -c > VCF_contig_${ITER}_biallelic_only_GENET_minDP5_minQ30_minmaxDP_10_80.vcf.gz

# Step 4: Apply ngsParalog filter across all populations
vcftools --gzvcf VCF_contig_${ITER}_biallelic_only_GENET_minDP5_minQ30_minmaxDP_10_80.vcf.gz \
--bed ${BED} --stdout --recode | gzip -c > VCF_contig_${ITER}_biallelic_only_GENET_minDP5_minQ30_minmaxDP_10_80_ngsParalog.vcf.gz

# Step 5: Filter by MAF and missing data
vcftools --gzvcf  VCF_contig_${ITER}_biallelic_only_GENET_minDP5_minQ30_minmaxDP_10_80_ngsParalog.vcf.gz --maf 0.05 --max-missing 0.9 \
--stdout --recode | gzip -c > VCF_contig_${ITER}_biallelic_only_GENET_minDP5_minQ30_minmaxDP_10_80_ngsParalog_maf5p_maxmiss10p.vcf.gz

# Step 6: Prune variants by physical distance (1000 bp)
vcftools --gzvcf VCF_contig_${ITER}_biallelic_only_GENET_minDP5_minQ30_minmaxDP_10_80_ngsParalog_maf5p_maxmiss10p.vcf.gz \ 
--thin 1000 --stdout --recode | gzip -c > VCF_contig_${ITER}_biallelic_only_GENET_minDP5_minQ30_minmaxDP_10_80_ngsParalog_maf5p_maxmiss10p_thin1000.vcf.gz
