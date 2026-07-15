"""
Extract a 1D Site Frequency Spectrum (SFS) from a SNP data file using dadi.
"""

import dadi
import matplotlib.pyplot as pyplot
import sys

# Arguments
VCF = sys.argv[1]      # VCF file
popmap = sys.argv[2]   # Popmap file (tab-delimited: sample \t population)
size = int(sys.argv[3]) # Number of chromosomes to project down to (sample size)
nom = sys.argv[4]      # Output prefix
pop = sys.argv[5]      # Target population

# Make dadi data dictionary
dd = dadi.Misc.make_data_dict_vcf(VCF, popmap)

# Build 1D SFS
fs = dadi.Spectrum.from_data_dict(dd, [pop], [size], polarized=False)

# Save spectrum
fs.to_file(f"SFS_1D_{size}_{nom}_{pop}.fs")

# Plot 1D SFS
pyplot.figure()
dadi.Plotting.plot_1d_fs(fs, show=False)
pyplot.xlabel("Derived allele count")
pyplot.ylabel("Number of SNPs")
pyplot.title(f"1D SFS for {pop}")
pyplot.savefig(f"Plot_FS_dadi_1D_{size}_{nom}_{pop}.png")
pyplot.close()

print(f"1D SFS for {pop} written to SFS_1D_{size}_{nom}_{pop}.fs")

