###Merge all PRS sscore files in a single file and standarize values
library(data.table)
library(dplyr)

samplename="example"
sscorespath="/farmacologia/home/farmauser/PRS/sample_PRS_output/"
sscores=grep(list.files(path=sscorespath),pattern = ".sscore", value = T)

phenoty=c("ADimp","ADnrem")
filetoread=paste0("/farmacologia/home/farmauser/PRS/sample_PRS_output/",samplename,".",phenoty[1],".sscore") #one random sscorefile to retrieve IID column
prslist=fread(filetoread) 
prslist=prslist%>%dplyr::select(.,IID)
for (pheno in phenoty){
  phenofile=grep(list.files(path=sscorespath),pattern = pheno, value = T)
  phenofile=grep(phenofile,pattern = ".sscore",value=T)
  phenofile=grep(phenofile,pattern = samplename,value=T)
  filetemp=paste0(sscorespath,phenofile)
  temp=fread(filetemp)
  temp[[pheno]]=temp$SCORE1_AVG
  temp=temp%>%dplyr::select(.,pheno)
  prslist=cbind.data.frame(prslist,temp)
}
colnames(prslist)=c("ID",phenoty)
prslist[,phenoty]=lapply(phenoty, function(x) scale(prslist[[x]])) #z-score the PRS (mean=0, SD=1)
savefile=paste0("/farmacologia/home/farmauser/PRS/sample_PRS_output/",samplename,"_all_PRSCS.txt")                      
fwrite(prslist,savefile,sep='\t')
