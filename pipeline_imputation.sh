#!/bin/bash

echo Pre-QC before imputation
/BiO3/program/plink/plink --file /BiO3/GWAS/input/${1} \
        --geno 0.05 \
        --hwe 0.000001 \
        --maf 0.005 \
      	--recode \
	--out /BiO3/GWAS/interm/${1}_qc

echo Split data into chromosomes
for chr in $(seq 1 22); do
        /BiO3/program/plink/plink --file /BiO3/GWAS/interm/${1}_qc \
                --chr ${chr} \
                --make-bed \
                --out /BiO3/GWAS/interm/${1}_qc_chr${chr}
        mv /BiO3/GWAS/interm/${1}_qc_chr${chr}.bed /BiO3/program/shapeit.v2.904/input
	mv /BiO3/GWAS/interm/${1}_qc_chr${chr}.bim /BiO3/program/shapeit.v2.904/input
        mv /BiO3/GWAS/interm/${1}_qc_chr${chr}.fam /BiO3/program/shapeit.v2.904/input
done

echo Prephasing before imputation
for chr in $(seq 1 22); do
	/BiO3/program/shapeit.v2.904/bin/shapeit -B /BiO3/program/shapeit.v2.904/input/${1}_qc_chr${chr} \
				     -M /BiO3/program/shapeit.v2.904/genetic_map_b37/genetic_map_chr${chr}_combined_b37.txt \
				     -O /BiO3/program/shapeit.v2.904/phased/${1}_qc_chr${chr}_phased \
				     -T 16   # Multi-threading 

done

echo Imputation
python multi_impute.py ${1}_qc

echo Merging imputed chunks
python merge_impute.py ${1}_qc

echo Generating sample data
cp /BiO3/program/shapeit.v2.904/phased/${1}_qc_chr1_phased.sample /BiO3/GWAS/interm
mv /BiO3/GWAS/interm/${1}_qc_chr1_phased.sample /BiO3/GWAS/interm/${1}_qc.imputed.all.sample
#python sample_modify.py /BiO3/GWAS/interm/${1}_qc

echo QC on imputed data
/BiO3/program/qctool/qctool -g /BiO3/GWAS/interm/${1}_qc.imputed.all \
	 -s /BiO3/GWAS/interm/${1}_qc.imputed.all.sample \
	 -og /BiO3/GWAS/interm/${1}_qc.imputed.all.qc \
	 -os /BiO3/GWAS/interm/${1}_qc.imputed.all.qc.sample \
	 -info 0.3 1 \
	 -omit-chromosome

echo Oxford Gen/Sample to PLINK Ped/Map
/BiO3/program/gtool/gtool -G \
	--g /BiO3/GWAS/interm/${1}_qc.imputed.all.qc \
	--s /BiO3/GWAS/interm/${1}_qc.imputed.all.qc.sample \
	--ped /BiO3/GWAS/interm/${1}_qc.imputed.all.ped \
	--map /BiO3/GWAS/interm/${1}_qc.imputed.all-1.map

echo map file trimming for chromosome number
python map_trimming.py /BiO3/GWAS/interm/${1}_qc

echo QC with plink
/BiO3/program/plink/plink --file /BiO3/GWAS/interm/${1}_qc.imputed.all \
	--geno 0.05 \
	--hwe 0.000001 \
	--maf 0.005 \
	--make-bed \
	--out /BiO3/GWAS/imputed/${1}_qc.imputed.all.clean

#echo Association study with imputed data, phenotype, covariates
#/BiO3/program/plink/plink --bfile ${1}.qc.imputed.all.clean \
#	--pheno ${1}.qc_pheno.txt \
#	--pheno-name EFFLUX \
#	--covar ${1}.qc_cov.txt \
#	--covar-name SEX,AGE,TG,HDLC,LDLC,STATIN \
#	--linear \
#	--hide-covar \
#	--adjust \
#	--out Gwas607.imputed.plink
