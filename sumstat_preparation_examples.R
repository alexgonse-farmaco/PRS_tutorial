####Sumstat preparation examples

##Quick guide:
#Load and check sumstats file format
#Identify all the particularities
#Calculate Neff if dichotomic phenotype
#Write down Neff
#Exclude unreliable SNPs
#Format file for PRSCS processing

#Packages
library(data.table)
library(dplyr)

#External MAF reference for sumstats with missing MAF info
ref<-fread("/farmacologia/home/farmauser/PRS/scripts/reference.1000G.maf.0.005.txt.gz") #annotate MAF from reference, lots of missing in sumstats CEUaf
ref<-data.frame(ref$SNP,ref$MAF)


#Example 1: SZ; dichotomic, Freq but no MAF
PRS=frPRSd("/farmacologia/home/farmauser/PRS/sumstats_raw/PGC3_SCZ_wave3.europPRSn.autosome.public.v3.vcf.tsv.gz")
PRS$Freq=(PRS$FCAS*PRS$NCAS+PRS$FCON*PRS$NCON)/(PRS$NCAS+PRS$NCON) #calculate Freq as an average from cases and controls
PRS$MAF<-ifelse(PRS$Freq > .5, 1-PRS$Freq, PRS$Freq) #convert Freq to MAF. Just to filter out low MAF SNPs

PRS=subset(PRS,PRS$IMPINFO<=1) #remove INFO>1 variants (chrX)
PRS$Freq=(PRS$FCAS*PRS$NCAS+PRS$FCON*PRS$NCON)/(PRS$NCAS+PRS$NCON) #calculate Freq as an average from cases and controls
PRS$NEFF=(4/(2*PRS$Freq*(1-PRS$Freq)*PRS$IMPINFO)-PRS$BETA^2)/PRS$SE^2
TotalNeff=quantile(PRS$NEFF,probs = seq(0, 1, 1/5))[5] #keep this number as Neff for PRSCS

PRS=subset(PRS,PRS$MAF>=0.01)
PRS=subset(PRS,PRS$IMPINFO>=0.8)

PRS=PRS%>%select(.,ID,A1,A2,BETA,PVAL) #Never include MAF if ref allele and OR haven't been flipped!
colnames(PRS)=c("SNP","A1","A2","BETA","P")
fwrite(PRS, file = "/farmacologia/home/farmauser/PRS/sumstats_QCed/SZ.sumstats", sep = "\t", quote=FALSE,row.names=FALSE,col.names=TRUE)




#Example 2: BD; dichotomic, no MAF or Freq, weird colnames
PRS=frPRSd("/farmacologia/home/farmauser/PRS/sumstats_raw/pgc.bip.full.2012-04.txt.gz")
colnames(PRS)=c("SNP","CHR","BP","A1","A2","OR","SE","P","INFO","NGT","CEUaf")

PRS<-inner_join(PRS,ref,by="SNP",all=F) #get MAF from external reference

PRS=subset(PRS,PRS$INFO<=1) #remove INFO>1 variants (chrX)
PRS$NEFF=(4/(2*PRS$MAF*(1-PRS$MAF)*PRS$INFO)-PRS$OR^2)/PRS$SE^2
TotalNeff=quantile(PRS$NEFF,probs = seq(0, 1, 1/5))[5] #keep this number as Neff for PRSCS

PRS=subset(PRS,PRS$MAF>=0.01)
PRS=subset(PRS,PRS$INFO>=0.8)
PRS=PRS%>%select(.,SNP,A1,A2,OR,P)
fwrite(PRS, file = "/farmacologia/home/farmauser/PRS/sumstats_QCed/BD.sumstats", sep = "\t", quote=FALSE,row.names=FALSE,col.names=TRUE)




#Example 3: IQ; continuous, Freq but no MAF; alleles in lowercase
PRS<-fread("/farmacologia/home/farmauser/PRS/sumstats_raw/SavageJansen_2018_intelligence_metaanalysis.txt")
PRS$MAF<-ifelse(PRS$EAF_HRC > .5, 1-PRS$EAF_HRC, PRS$EAF_HRC) #convert Freq to MAF

PRS$A1=toupper(PRS$A1) #transform lowercase to uppercase
PRS$A2=toupper(PRS$A2)
PRS=subset(PRS,PRS$MAF>=0.01)
PRS=subset(PRS,PRS$minINFO>=0.8)

TotalNeff<-269867 #retrieved from the abstract of Savage et al. (2018)

PRS=PRS%>%select(.,SNP,A1,A2,stdBeta,P)
colnames(PRS)=c("SNP","A1","A2","BETA","P")
fwrite(PRS, file = "/farmacologia/home/farmauser/PRS/sumstats_QCed/IQ.sumstats", sep = "\t", quote=FALSE,row.names=FALSE,col.names=TRUE)


