##MAIN
This is a tutorial for PRS construction with PRS-CS method. This method applies a correction on the effect of risk alleles (continuous shrinkage), considering their association with the target phenotype and linkage desequilibrium score among other risk alleles. This allows the construction of PRS without the selection of a thresholding criteron or a cumpling processing.

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


##DETAILED INFO

#Genotyping files
Different formats are needed to process our sample genotyping information:
- bfiles (.bim, .fam, .bed): file trio that contain, respectively: SNP info (ID, chromosomic location, etc.), subject info (id, sex, phenotype, etc.) and a binary file that connects SNP and subject info
- Variant Call Format (.vcf): binary file, contains all genotyping information in a single file
- compressed gz (.vcf.gz): zipped .vcf files

Some processes/software require a specific format


#Imputation
Optional and highly recommended step to infer genotype information from non-genotiped SNPs. Available at https://imputationserver.sph.umich.edu/index.html#!

Useful information:
- Sign in is required
- Pre-QC is mandatory. QC script is provided
- Input files are per-chromosome .vcf.gz
- Reference panel/array build have to match the sample's
- Refrence population selection is required




#Summary statistics file
This file contains the per-SNP p-value, associated effect on the phenotyope (odds ratio/beta values) among other data. This raw file has to be formatted processed by PRS-CS

Keep in mind that summary statistic files come from published articles. Although highly recommended, summary statistics data is not always publicly available. There is no standard format to report summary statistica, so we'll have to consider each file's particularities.

Useful repositories to obtain GWAS summary statistics:
- GWAS catalog: https://www.ebi.ac.uk/gwas/
- Psychiatric Genetics Consorium: https://pgc.unc.edu/for-researchers/download-results/
- Genetic Investigation of ANthropometric Traits consortium: https://portals.broadinstitute.org/collaboration/giant/index.php/GIANT_consortium_data_files

Summarizing, we'll need the following data from the summary statistics file:
- SNP id: with rs code
- Minor Allele Frequency: to exclude MAF<0.01. If missing, we can estimate MAFs with a reference file
- OR/beta: effect value for dichotomic/continuous phonotypes

Additionally, we'll need extra information for PRS-CS prcessing:
- Sample size: found in the article text
  - For the dichotomic phenotypes GWAS, we have to calculate the effective sample size (Neff, as proposed in https://www.biorxiv.org/content/10.1101/2021.03.29.437510v4.full)
  - Formula: NEFF=(4/(2*Freq*(1-Freq)*IMPINFO)-BETA^2)/SE^2 #it makes no difference to use freq or MAF, since 2*Freq*(1-Freq) = 2*MAF*(1-MAF)
- reference linkage desequilibrium data: we'll use the UK BioBank population as reference


#
