#!/usr/bin/env python3

import argparse
import sys
import math
import itertools
import re
import logging
import subprocess
from operator import itemgetter

__author__ = "Ira Cooke"
__email__ = "ira.cooke@jcu.edu.au"

#
# Helper functions
#
def read_fasta(fp):
    name, seq = None, []
    for line in fp:
        line = line.rstrip()
        if line.startswith(">"):
            if name: yield (name, ''.join(seq))
            name, seq = line[1:], []
        else:
            seq.append(line)
    if name: yield (name, ''.join(seq))

def print_fasta(name,seq):
    sys.stdout.write(">"+name+"\n"+seq+"\n")



#
# Logging
#
log = logging.getLogger()
logging.basicConfig(stream=sys.stderr,level=logging.DEBUG)


#
# Arguments
#
parser = argparse.ArgumentParser(description='Convert fasta alignment to nexus')

parser.add_argument('infasta',metavar='FILE',nargs='?',type=argparse.FileType('r'),help='Input fasta alignment data',default=sys.stdin)
parser.add_argument('-t', '--traits',metavar='FILE',type=argparse.FileType('r'),help='Traits file',required=False)
parser.add_argument('-o', '--out',metavar='FILE',type=argparse.FileType('w'),help='Filename for output',default=sys.stdout)

args  = parser.parse_args()

#
# Read the alignment data
#
alignment_length=None

sequence_ids = []
sequences = []

for name,seq in read_fasta(args.infasta):
	if alignment_length==None:
		alignment_length=len(seq)
	elif alignment_length!=len(seq):
		log.error("All sequences must be the same length")
		exit()

	sequence_ids.append(name)
	sequences.append(seq)




#
# Prepare output
#
taxa_block="""
begin taxa;
	dimensions ntax={ntax};
	taxlabels
{taxlabels};
end;
""".format(ntax = len(sequence_ids), taxlabels = '\t'.join(sequence_ids))

#import pdb;pdb.set_trace();

sd='\n'.join([ name+"\t"+seq for name,seq in zip(sequence_ids,sequences)])

characters_block="""
begin characters;
	dimensions nchar={nchar};
	format datatype=dna missing=? gap=-;
	matrix
{sequence_data};
end;
""".format(nchar = alignment_length, sequence_data = sd)

args.out.write("#NEXUS\n")
args.out.write(taxa_block)
args.out.write(characters_block)

if not args.traits:
	exit()


#
# Read traits
#
traitlabels=None
traits={}
for line in args.traits:
	line_values = line.strip().split(",")
	if traitlabels is None:
		traitlabels=line_values[1:]
	else:
		taxid=line_values[0]
		traits[taxid]=line_values[1:]

traits_block="""
BEGIN TRAITS;
Dimensions NTRAITS={ntraits};
Format labels=yes missing=? separator=Comma;
TraitLabels {traitlabels};
Matrix
{traitmatrix};
end;
""".format(
	ntraits = len(traitlabels), 
	traitlabels = '\t'.join(traitlabels),
	traitmatrix = '\n'.join([ taxid+'\t'+','.join(traits[taxid]) for taxid in sequence_ids])
	)


args.out.write(traits_block)















