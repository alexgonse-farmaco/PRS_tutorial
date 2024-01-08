###Format and QC raw genotyping data to send to imputation server

#Setting up
module load plink/v1.7
alias plink='plink --noweb' #to initiate plink without the --noweb flag

#Variables
name=example #sample/project name
updateid=updateid.txt #file to update id, if necessary. Format: oldIID oldFID newIID newFID
updatesex=updatesex.txt #file to update id, if necessary. Format: IID FID sex (coded 1/2/0 for M/F/missing)
workingdirectory=/farmacologia/home/farmauser/PRS/workingdirectory #to store all intermediate files

cd $workingdirectory

#ID update and formatting
plink --vcf $name --make-bed --out $name
plink --bfile $name --update-id $updateid --out unimp_sexbfile #bfiles for later sex-labelled QC (requires unimputed data)
plink --bfile $name --maf 0.01 --hwe 1e-3 --geno 0.01 --write-snplist --make-bed --out $name"QC_noimp" #bfiles for genetic PCA (for statistical analysis)
plink --bfile $name"QC_noimp" --recode_vcf --out $name"QC_noimp" #vcf for genetic PCA (for statistical analysis)

#Pre-imputation QC
plink --bfile $name --freq --out $name
perl /farmacologia/home/farmauser/PRS/scripts/HRC-1000G-check-bim.pl -b $name.bim -f $name.frq -r /farmacologia/home/farmauser/PRS/scripts/HRC.r1-1.GRCh37.wgs.mac5.sites.tab -h	
sh Run-plink.sh

#File formatting
for i in {1..22}; do
plink --bfile $name"-updated-chr"$i --recode vcf --out $name"-chr"$i
sed -i 1,6d $name"-chr"$i".vcf"
sed -i '1s/^/##fileformat=VCFv4.1\n/' $name"-chr"$i".vcf"
gzip $name"-chr"$i."vcf";
done

rm TEMP* *.nosex *updated*

## Upload files to Michigan Imputation Server
# https://imputationserver.sph.umich.edu/index.html#!pages/home
# Run > Genotype Imputation (Minimac4)
# Set name > set Reference Panel > upload vcf.gz chromosome files > choose population > accept conditions > Submit Job