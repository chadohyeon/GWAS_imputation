#!/usr/bin/python
import sys
def map_trimming_main(n):
	with open(n+".imputed.all-1.map") as mapf:
		with open(n+".imputed.all.map", "w") as newf:
			chro=1
			pos1=0
			for i in mapf.readlines():
				x=i.split()
				y=x[:]
				if y[1].startswith("rs"):
					y[1]=y[1].split(":")[0]
				else:
					y[1]=y[0]+":"+y[3]
				pos2=int(y[-1])
				if pos1 > pos2:
					chro+=1
				y[0]=str(chro)
				newf.write("\t".join(y)+"\n")
				pos1=int(y[-1])
map_trimming_main(sys.argv[1])	
