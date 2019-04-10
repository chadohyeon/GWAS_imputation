#!/usr/bin/python
import os
from subprocess import call
import sys
path="/BiO3/program/impute.v2.3.2/results/"
def integration():
	with open("/BiO3/GWAS/interm/{0}.imputed.all".format(sys.argv[1]), "w") as f:
		for i in sorted([k for k in os.listdir(path) if k[-7:]=="imputed"]):
			with open(path+i,"r") as ind:
				for j in ind.readlines():
					f.write(j.replace("\n","")+"\n")
							
def reorder():
	a=sorted([k for k in os.listdir(path) if k.startswith(sys.argv[1])])
	for i in a:
		x=i.split(".")
		if len(x[1].split("chr")[1])==1:
			x[1]="chr0"+x[1][-1]
		if len(x[2])==1:
			x[2]="0"+x[2]
		call(["mv",path+i,path+".".join(x)])
reorder()
integration()
		
