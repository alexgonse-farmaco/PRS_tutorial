###Retrieve imputed data, annotate and perform QC

#Setting up
module load plink/v1.9
module load R
alias plink='plink --noweb' #to initiate plink without the --noweb flag

#Variables
namei=example_imp #sample/project name imputed
nameqc=example_QC #sample/project name QCed
nameok=example_OK #sample/project name ready for PRS construction
psw='vkJG=JG0:zi7dA' #set password sent by server
workingdirectory=/farmacologia/home/farmauser/PRS/tutorial_files #to store all intermediate files

cd $workingdirectory


#Download imputed files: email link > Imputation Results > wget > copy curl commmand > paste in the terminal

#Unzip and format imputed data
for i in {1..22}; do
unzip -P $psw -o chr_$i.zip
gzip -d -f chr$i.dose.vcf.gz > chr$i.dose.vcf
plink --vcf chr$i.dose.vcf --make-bed --out chr$i.dose
done #unzip, ungzip, transfrom to bfiles

for i in {1..22}; do
echo "chr$i.dose" >> beddosefilename;
done #create file for merging all chromosomes

plink --merge-list beddosefilename --make-bed --out $namei


#Annotate CHR:BP:A1:A2 to rsID
plink --bfile $namei --recode-vcf --out $namei
bgzip $namei.vcf
tabix $namei.vcf.gz

bcftools annotate -c ID --collapse snps -a /farmacologia/home/farmauser/PRS/scripts/HRC.r1-1.GRCh37.wgs.mac5.sites.vcf.gz $namei.vcf.gz > $namei"_1".vcf


#Perform QC
plink --vcf $namei"_1".vcf --make-bed --out $namei
rm *dose*


#SNP QC
plink --bfile $namei --maf 0.01 --hwe 1e-3 --geno 0.01 --write-snplist --make-bed --out $nameqc #MAF, HWE, missingness

plink --bfile $nameqc --extract $nameqc.snplist --indep-pairwise 200 50 0.25 --out $nameqc #prunning for heterozigosity
plink --bfile $nameqc --extract $nameqc.prune.in --het --out heteroz

R
library(data.table)
dat=fread("heteroz.het")
valid=dat[F<=mean(F)+3*sd(F) & F>=mean(F)-3*sd(F)]
fwrite(valid[,c("FID","IID")], "heteroz.valid.sample", sep="\t")
quit()
n

awk '{print $2}' nameqc.bim > snpstemp
sort snpstemp | uniq -d > dupsnps


#Subject QC
plink --bfile $nameqc --mind 0.05 --make-just-fam --out missingness #missingness
plink --bfile $nameqc --extract $nameqc.prune.in --genome --make-just-fam --out relatedness_nocutoff #relatedness

#Check manually, can exclude second degree familiar or closer
#pi_hat meaning: 1=duplicated or twin; 0.5=first degree familiar; 0.25=second degree familiar; 0.125=third degree familiar...
#exclude one pair randomly, cases are preferred over controls
#if known siblings or trios, just check for duplicates and other issues


#Sex-label check
R
library(dplyr)
library(data.table)
bim=fread("unimp_sexbfile.bim")
bim$V1=gsub(23, "X", bim$V1)
bim$V1=gsub(24, "Y", bim$V1)
fwrite(bim,"XY.bim",sep = " ")
quit()
n

plink --bfile unimp_sexbfile --extract XY.bim --check-sex --out sex

R
library(data.table)
sex<-fread("sex.sexcheck")
fwrite(sex[STATUS=="OK",c("FID","IID")], "sex.valid", sep="\t")
fwrite(sex[STATUS=="PROBLEM",c("IID")], "sex_excluded", sep="\t")
quit()
n


#Final file
plink --bfile $nameqc --keep heteroz.valid.sample --make-bed --out TEMP1
plink --bfile TEMP1 --keep missingness.fam --make-bed --out TEMP2
plink --bfile TEMP2 --make-bed --exclude dupsnps --out /farmacologia/home/farmauser/PRS/bfiles/$nameok
rm TEMP* *nosex



