#!/usr/bin/env python3

import argparse
import sys
import math

parser = argparse.ArgumentParser(description='Convert high PCAdapt regions to gff intervals')

parser.add_argument('insf2',metavar='FILE',nargs='?',type=argparse.FileType('r'),help='Input pval File',default=sys.stdin)
parser.add_argument('-t','--threshold',type=int,help='Keep regions with -log10(pval) above this value',default=20)


args  = parser.parse_args()

start_pos = None
end_pos = None
chrom = None
scores = []

for line in args.insf2:

	line_values = line.split()


	if (chrom==None) or (chrom!=line_values[0]):
		chrom=line_values[0]
		start_pos = None
		end_pos = None

	pval = float(line_values[3])
	if ( pval > args.threshold ):
		if start_pos == None:
			start_pos = line_values[1]

		end_pos = line_values[2]
		scores.append(pval)

	else:
		if ( start_pos != None ):
			if int(start_pos) > int(end_pos):
				import pdb; pdb.set_trace()
			sys.stdout.write(chrom+"\tpcangsd\tinversion\t"+str(start_pos)+"\t"+
										str(end_pos)+"\t"+str(round(max(scores),1))+
										"\t+\t.\tNote=threshold"+str(args.threshold)+"\n")
			start_pos = None
			scores=[]
