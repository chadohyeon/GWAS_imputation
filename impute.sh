#!/bin/bash

/BiO3/program/impute.v2.3.2/impute2 -use_prephased_g \
	  -known_haps_g /BiO3/program/shapeit.v2.904/phased/${1}_chr${2}_phased.haps \
	  -h /BiO3/program/impute.v2.3.2/panel/1000GP_Phase3/1000GP_Phase3_chr${2}.hap.gz \
	  -l /BiO3/program/impute.v2.3.2/panel/1000GP_Phase3/1000GP_Phase3_chr${2}.legend.gz \
	  -m /BiO3/program/impute.v2.3.2/panel/1000GP_Phase3/genetic_map_chr${2}_combined_b37.txt \
	  -int ${3} ${4} \
	  -Ne 20000 \
	  -o /BiO3/program/impute.v2.3.2/results/${1}.chr${2}.`expr ${3} / 5000000 + 1`.imputed
