###For each phenotype, create sscore files

module load plink/v2.0
sample=example

for phenotype in ADimp ADnrem;do
plink2 \
--bfile /farmacologia/home/farmauser/PRS/bfiles/$sample"_OK" \
--score /farmacologia/home/farmauser/PRS/weights/$phenotype/$phenotype.weightsall 2 4 6 cols=+scoresums \
--out /farmacologia/home/farmauser/PRS/sample_PRS_output/$sample.$phenotype
done
