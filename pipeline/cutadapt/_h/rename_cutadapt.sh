#!/bin/bash

"exec" "snakemake" "--printshellcmds" "--snakefile" "$0" "--jobs" "20" "--latency-wait" "120"

import glob
import os.path
import itertools

SOURCE_DIR = '../_m'
EXT = '_R2.fastq.gz'


def sample_dict_iter(path, ext):
    for filename in glob.iglob(path+'/*'+ext):
        sample = os.path.basename(filename)[:-len(ext)]
               
        yield sample, {'r1_in': SOURCE_DIR + '/' + sample.upper() + '_R1.cutadapt.out',
		       'r2_in': SOURCE_DIR + '/' + sample.upper() + '_R2.cutadapt.out'
		      }

SAMPLE_DICT = {k:v for k,v in sample_dict_iter(SOURCE_DIR, EXT)}

#insure errors propogate along pipe'd shell commands
shell.prefix("set -o pipefail; ")

rule all:
    input:
        expand('../_m2/{sample}_{suffix}.cutadapt.out',
	       sample=SAMPLE_DICT.keys(),
	       suffix=['R1','R2'])
        
rule rename_cutadapt:
    input:
        r1 = lambda x: SAMPLE_DICT[x.sample]['r1_in'],
        r2 = lambda x: SAMPLE_DICT[x.sample]['r2_in']
        
    output:
        r1 = '../_m2/{sample}_R1.cutadapt.out',
        r2 = '../_m2/{sample}_R2.cutadapt.out'

    shell:
        '''

    mv {input.r1} {output.r1} 
    mv {input.r2} {output.r2} 


'''
