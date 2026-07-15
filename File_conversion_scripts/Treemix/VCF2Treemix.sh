#!/bin/bash

# Input file (modify as needed)
INPUT_FILE=/media/adrien/Disque_mobile_ATLY/VCF/VCF_Lophelia/FINAL_FOLDER/GENET/POPMAP_EU_ONLY.txt
VCF=VCF_allsites_Lp_ALLCONTIGS_no_indels_biall_GENET_minDP5_minQ30_minmaxDP_10_80_BED_Dd_outgroup_biallelic_kept_EU_only_maf0.05_maxmiss_0.9_thin1000.vcf.gz
OUTPUT_FILE="EU_Treemix_lineage_outgroup_refilter_outgroup_Dd_split.txt"

mkdir -p TEMP_FILES
# Check if the input file exists
if [[ ! -f "$INPUT_FILE" ]]; then
    echo "Error: File '$INPUT_FILE' not found!"
    exit 1
fi

# Extract unique populations from the second column
populations=$(awk '{print $2}' "$INPUT_FILE" | sort -u)

# Loop through each unique population and create a popmap_temp file
for pop in $populations; do
    awk -v pop="$pop" '$2 == pop {print $1}' "$INPUT_FILE" > TEMP_FILES/popmap_temp_${pop}.txt
    echo "Generated: popmap_temp_${pop}.txt"
    vcftools --gzvcf ${VCF} --keep TEMP_FILES/popmap_temp_${pop}.txt --counts2 --stdout > TEMP_FILES/count_pop_${pop}_temp.txt
done

echo "Done! All population-specific files created."

# Create an empty temporary file for merging
> "$OUTPUT_FILE"

# Process each population
for pop in $populations; do
    # Remove the header (first line with "{COUNT}") from vcftools
    tail -n +2 "TEMP_FILES/count_pop_${pop}_temp.txt" | awk '{print $5 "," $6}' > "TEMP_FILES/formatted_count_${pop}.txt"
    echo "Processed count_pop_${pop}.txt -> formatted_count_${pop}.txt"
done


# Create header with explicitly sorted populations
echo -e "$(echo $populations | tr ' ' ' ')" > "$OUTPUT_FILE"

# Merge files in the same sorted order as population names
paste $(for pop in $populations; do echo "TEMP_FILES/formatted_count_${pop}.txt" ; done) >> "$OUTPUT_FILE"

echo "Final merged file created: $OUTPUT_FILE"

gzip $OUTPUT_FILE


rm -rf TEMP_FILES




