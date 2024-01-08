###MAIN###

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


###Access to cluster###
For X2Go Client and filezilla cluster access the following info is required:
- username: farmauser
- password: b6tSqi3gztq8
- host: 161.116.221.75
- port: 22


###Script explanation and order###
1. imputation_formatting_QC.sh: transform raw gentoyping data for imputation server
2. postimputation_QC.sh: download, annotate and QC imputed genotyping data
3. sumstat_preparation_examples.R: format and QC reference summary statistics file
4. calculate_weights_example.py: PRSCS processing for effect size correction
5. allchr_weights.R: merge per-chromosome PRSCS processed summary statistics into a single file
6. construct_PRS.sh: calculate PRS
7. merge_PRS.R: create a single file with all PRS for your sample/project




###DETAILED INFO###

#Cluster management

All modules have to be loaded in the terminal. Base terminal uses bash code. Useful commands:
- module avail: see all available modules. These can only be installed by the master user (not us)
- module load <modulename>: load module before using it
- R: execute R. The terminal will only recognize R coding; quit() / n: to return to bash terminal
- conda activate alexenv: to install, execute anything in python
- python <namescript.py>: execute .py script



#Genotyping files

Different formats are needed to process our sample genotyping information:
- bfiles (.bim, .fam, .bed): file trio that contain, respectively: SNP info (ID, chromosomic location, etc.), subject info (id, sex, phenotype, etc.) and a binary file that connects SNP and subject info
- Variant Call Format (.vcf): binary file, contains all genotyping information in a single file
- compressed gz (.vcf.gz): zipped .vcf files



#Imputation

Optional and highly recommended step to infer genotype information from non-genotiped SNPs. Available at https://imputationserver.sph.umich.edu/index.html#!
Useful information:
- Sign in is required
- Pre-QC is mandatory. QC script is provided
- Input files are per-chromosome .vcf.gz
- Reference panel/array build have to match the sample's
- Refrence population selection is required
- Imputation results are temporarily stored in the server



#Annotation

Post-imputation SNP id is formatted as CHR:BP:A1:A2. Annotation is required to switch back to SNP rsID. A reference panel is required.
Some SNPs will be dropped due to id mismatch.



#Genotyping data QC

Imputed and annotated data is QCed to include only reliable data in the PRS. QC consists of:
- SNP QC: possible exclusion for for MAF, missingness, HWE, heterozigosity, duplicated ids. Some steps will require SNP prunning
- Individual QC: possible exclusion for label-sex mismatch, missingness, relatedness



#Summary statistics file

This file contains the per-SNP p-value, associated effect on the phenotyope (odds ratio/beta values) among other data. This raw file has to be formatted processed by PRS-CS

Keep in mind that summary statistic files come from published articles. Although highly recommended, summary statistics data is not always publicly available. There is no standard format to report summary statistica, so we'll have to consider each file's particularities.

Useful repositories to obtain GWAS summary statistics:
- GWAS catalog: https://www.ebi.ac.uk/gwas/
- Psychiatric Genetics Consorium: https://pgc.unc.edu/for-researchers/download-results/
- Genetic Investigation of ANthropometric Traits consortium: https://portals.broadinstitute.org/collaboration/giant/index.php/GIANT_consortium_data_files

Summarizing, we'll need the following data from the summary statistics file:
- SNP id: with rsID
- Minor Allele Frequency: to exclude MAF<0.01. If missing, we can estimate MAFs with a reference file
- OR/beta: effect value for dichotomic/continuous phonotypes
- Major/minor allele: to identify risk allele and exclude indels and non-binary polymorphisms

Additionally, we'll need extra information for PRS-CS prcessing:
- Sample size: found in the article text
  - For the dichotomic phenotypes GWAS, we have to calculate the effective sample size (Neff, as proposed in https://www.biorxiv.org/content/10.1101/2021.03.29.437510v4.full)
  - Formula: NEFF=(4/(2*Freq*(1-Freq)*IMPINFO)-BETA^2)/SE^2 #it makes no difference to use freq or MAF, since 2*Freq*(1-Freq) = 2*MAF*(1-MAF)
- reference linkage desequilibrium data: we'll use the UK BioBank population as reference



#PRSCS

A base script is available to run PRSCS. File path, phenotype names and Neff have to be manually inserted.
The script automatically creates per-chromosome jobs for each phenoype. There are sent to slurm. Useful slurm commands:
- squeue: check queue and job status
- scancel -u farmauser: cancel all sent jobs



#PRS construction

Once all the above is ready, PRS can be constructed with plink. Additional scripts are provided to construct a single .txt file with the per-individual per-phenotype PRS
