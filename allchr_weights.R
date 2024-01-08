###Create a .weightsall file that comprises all SNP beta values after PRSCS processing

library(data.table)
library(dplyr)

#select phenotypes; this command selects all of them byt they can be subseted manually
pathwg="/farmacologia/home/farmauser/PRS/weights"
phenotypes=grep(list.files(path=pathwg),pattern = "weights", invert=T, value=T)

for (pheno in phenotypes){
  dirph=paste0(pathwg,"/",pheno)
  dirsave=paste0(pathwg,"/",pheno,"/",pheno,".weightsall")
  setwd(dirph)
  files <- list.files(pattern = ".txt")
  weight=list()
  dirfin=data.frame()
  for (i in files){
    weight[[i]]=fread(i)
    dirfin=rbind.data.frame(dirfin,weight[[i]])
  }
  colnames(dirfin)=c("CHR","SNP","BP","A1","A2","WEIGHT")
  fwrite(dirfin,dirsave,sep="\t")
}
