###Merge all PRS sscore files in a single file and standarize values
library(data.table)
library(dplyr)

samplename="example"
sscorespath="/farmacologia/home/farmauser/PRS/sample_PRS_output/"
patt=paste0(samplename".*sscore")
sscores=grep(list.files(path=sscorespath),pattern = patt, value = T)

phenoty=sub(paste0("^",example,"."),"",sscores) 
phenoty=sub(paste0(".weightsall.sscore","$"),"",phenoty) #for all available PRS of a sample

filetoread=paste0("/farmacologia/home/farmauser/PRS/sample_PRS_output/",sscores[1]) #one random sscorefile to retrieve IID column
prslist=fread(filetoread) 
prslist=prslist%>%dplyr::select(.,"#FID",IID)
for (pheno in sscores){
  filetemp=paste0(sscorespath,pheno)
  temp=fread(filetemp)
  temp[[pheno]]=temp$SCORE1_AVG
  temp=temp%>%dplyr::select(.,pheno)
  prslist=cbind.data.frame(prslist,temp)
}
colnames(prslist)=c("FID","IID",phenoty)
prslist[,phenoty]=lapply(phenoty, function(x) scale(prslist[[x]])) #z-score the PRS (mean=0, SD=1)
savefile=paste0("/farmacologia/home/farmauser/PRS/sample_PRS_output/",samplename,"_all_PRSCS.txt")                      
fwrite(prslist,savefile,sep='\t')
