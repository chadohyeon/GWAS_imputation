#/usr/bin/python
from subprocess import call
from multiprocessing import Process
import sys

def chr_start_end():
	chr_start=[]
	chr_end=[]
	with open("/BiO3/GWAS/interm/{0}.map".format(sys.argv[1])) as rf:
		temp_dic={}
		for i in rf.readlines():
			x=i.strip().split()
			if x[0] not in temp_dic.keys(): temp_dic[x[0]]=[x[3]]
			else: temp_dic[x[0]].append(x[3])
		for j in range(1,23):
			chr_start.append(int(temp_dic[str(j)][0]))
			chr_end.append(int(temp_dic[str(j)][-1]))
	return chr_start, chr_end							

def impute_chr(i):
        call(["bash","impute.sh",sys.argv[1],str(i+1),str(chr_start[i]), str(chr_start[i]//5000000*5000000+5000000)])
	for j in range(chr_start[i]//5000000+1,chr_end[i]//5000000):
		call(["bash","impute.sh",sys.argv[1],str(i+1),str(1+5000000*j), str(5000000*(j+1))])
        call(["bash","impute.sh",sys.argv[1],str(i+1),str(1+(chr_end[i]//5000000)*5000000), str(chr_end[i])])

if __name__=="__main__":
	chr_start, chr_end=chr_start_end()
	procs=[Process(target=impute_chr, args=[i]) for i in range(22)]
	for p in procs:
		p.start()
	for p in procs:
		p.join()	
