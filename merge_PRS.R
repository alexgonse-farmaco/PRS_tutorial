###Merge all PRS sscore files in a single file and standarize values
library(data.table)
library(dplyr)

sscorespath="/farmacologia/home/farmauser/PRS/sample_PRS_output/"
sscores=grep(list.files(path=sscorespath),pattern = ".sscore", value = T)

phenoty=c("pheno1","pneho2")
filefile=fread("/farmacologia/home/farmauser/PRS/sample_PRS_output/FLX.ADimp.sscore") #one random sscorefile to retrieve IID column
filefile=filefile%>%dplyr::select(.,IID)
for (pheno in phenoty){
  phenofile=grep(list.files(path=sscorespath),pattern = pheno, value = T)
  phenofile=grep(phenofile,pattern = ".sscore",value=T)
  filetemp=paste0(sscorespath,phenofile)
  temp=fread(filetemp)
  temp[[pheno]]=temp$SCORE1_AVG
  temp=temp%>%dplyr::select(.,pheno)
  filefile=cbind.data.frame(filefile,temp)
}
colnames(filefile)=c("ID",phenoty)
filefile[,phenoty]=lapply(phenoty, function(x) scale(filefile[[x]])) #z-score the PRS (mean=0, SD=1)
fwrite(filefile,"/farmacologia/home/farmauser/PRS/sample_PRS_output/sample_all_PRSCS.txt",sep='\t')
