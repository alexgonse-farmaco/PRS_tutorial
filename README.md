# PRS_tutorial

This is a tutoril for PRS construction with PRS-CS method. This method applies a correction on the effect of risk alleles (continuous shrinkage), considering their association with the target phenotype and linkage desequilibrium score among other risk alleles. This allows the construction of PRS without the selection of a thresholding criteron or a cumpling processing.

The following steps are included in the tutorial:

1. Genotyping file imputation, annotation and QC
2. Summary statistics processing and formatting
3. PRS construction

For this specific tutorial, we will use UB cluster. The cluster can execute linux software, run python scripts and runs computationally demanding jobs in parallel.

Overwiew of the needed software, for our local computer (L) and for the cluster (C):
- (L) X2Go Client: to access a remote linux desktop of the cluster
- (L) filezilla: to transfer files back and forth from the cluster
- (L) Axiom Analysis Suite: to format raw genotyping data from the CeGEN repository
- (C) R: multiuse, data management and formating among others
- (C) plink: for gentoyping data formatting, QC and PRS construction. Highlighted packages:
    - data.table: fast read/write files
    - dplyr: general data frame work package
- (C): becftools: to annotate post-imputation genotyping data
- (C) conda: to create a pyhton environment in which we can install/run modules and scripts
- (C) slurm: to send jobs for remote computing and parallelization
- (C) PRSCS: to correct risk alleles effect
