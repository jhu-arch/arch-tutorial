Snakemake Workflows
###################

The `Snakemake`_ `workflows`_ management system is a tool to create reproducible and scalable data analyses.

.. warning::
  This tutorial is still under evaluation.

This tutorial presents a bioinformatics pipeline using Snakemake.

.. note::
  * Writing Workflows
    In Snakemake, workflows are specified as Snakefiles. Inspired by GNU Make, a Snakefile contains rules that denote how to create output files from input files. Dependencies between rules are handled implicitly, by matching filenames of input files against output files. Thereby wildcards can be used to write general rules.

  * Snakefiles and Rules
    A Snakemake workflow defines a data analysis in terms of rules that are specified in the `Snakefile`_ .

We will create a hypothetical scenario with precedent steps, where for example the Level 5 (tabix) depends on the Level 4 (tags), and so on.

.. note::
  Level 1     Level 2    Level 3   Level 4  Level 5
  cutadapt -> bwamem  -> rmdup  -> tags  -> tabix

cutadapt
********

Cutadapt finds and removes adapter sequences, primers, poly-A tails and other types of unwanted sequence from your high-throughput sequencing reads.

.. code-block:: console

  #!/bin/bash

  SM_ARGS="--cpus-per-task {cluster.cpus-per-task} --mem-per-cpu {cluster.mem-per-cpu-mb} --job-name {cluster.job-name} --ntasks {cluster.ntasks} --partition {cluster.partition} --time {cluster.time} --mail-user {cluster.mail-user} --mail-type {cluster.mail-type} --error {cluster.error} --output {cluster.output}"

  # Syntax to run it on Rockfish cluster
  "exec" "snakemake" "--jobs" "200" "--snakefile" "$0" "--latency-wait" "120" "--cluster" "sbatch $SM_ARGS"

  # Syntax to run it on computer
  #"exec" "snakemake" "--printshellcmds" "--snakefile" "$0" "--jobs" "20" "--latency-wait" "120"

  import glob
  import os.path
  import itertools

  SOURCE_DIR = '../../_m'
  EXT = '_R2.fastq.gz'

  def sample_dict_iter(path, ext):
      for filename in glob.iglob(path+'/*'+ext):
          sample = os.path.basename(filename)[:-len(ext)]

          if 'bulk' not in sample:
              yield sample, {'r1_in': SOURCE_DIR + '/' + sample + '_R1.fastq.gz',
                             'r2_in': SOURCE_DIR + '/' + sample + '_R2.fastq.gz'
  		          }

  SAMPLE_DICT = {k:v for k,v in sample_dict_iter(SOURCE_DIR, EXT)}

  #insure errors propogate along pipe'd shell commands
  shell.prefix("set -o pipefail; ")

  rule all:
      input:
          expand('../_m/{sample}_{suffix}.fastq.gz',
  	       sample=SAMPLE_DICT.keys(),
  	       suffix=['R1','R2'])

  rule cutadapt:
      input:
          r1 = lambda x: SAMPLE_DICT[x.sample]['r1_in'],
          r2 = lambda x: SAMPLE_DICT[x.sample]['r2_in']
      output:
          r1 = '../_m/{sample}_R1.fastq.gz',
          r2 = '../_m/{sample}_R2.fastq.gz'

      params:
          sample = '{sample}'

      shell:
          '''
      export PATH=$HOME'/.local/bin:'$PATH

      R1_ADAPTER='AATGATACGGCGACCACCGAGATCTACACTCTTTCCCTACACGACGCTCTTCCGATCT'
      R2_ADAPTER='CAAGCAGAAGACGGCATACGAGANNNNNNNGTGACTGGAGTTCAGACGTGTGCTCTTCCGATCT'

      NESTED_PRIMER='TAACTAACCTGCACAATGTGCAC'

      R1_FRONT=${{R1_ADAPTER}}
      R2_FRONT=${{R2_ADAPTER}}${{NESTED_PRIMER}}
      R1_END=`rc ${{R2_FRONT}}`
      R2_END=`rc ${{R1_FRONT}}`

      QUALITY_BASE=33
      QUALITY_CUTOFF=28
      MINIMUM_LENGTH=36
      ADAPTOR_OVERLAP=5
      ADAPTOR_TIMES=4

      cutadapt -j 0 --quality-base=${{QUALITY_BASE}} --quality-cutoff=${{QUALITY_CUTOFF}} --minimum-length=${{MINIMUM_LENGTH}} --overlap=${{ADAPTOR_OVERLAP}} --times=${{ADAPTOR_TIMES}} --front=${{R1_FRONT}} --adapter=${{R1_END}} --paired-output tmp.2.{params.sample}.fastq -o tmp.1.{params.sample}.fastq {input.r1} {input.r2} > {params.sample}_R1.cutadapt.out

      cutadapt -j 0 --quality-base=${{QUALITY_BASE}} --quality-cutoff=${{QUALITY_CUTOFF}} --minimum-length=${{MINIMUM_LENGTH}} --overlap=${{ADAPTOR_OVERLAP}} --times=${{ADAPTOR_TIMES}} --front=${{R2_FRONT}} --adapter=${{R2_END}} --paired-output {output.r1} -o {output.r2} tmp.2.{params.sample}.fastq tmp.1.{params.sample}.fastq > {params.sample}_R2.cutadapt.out

      rm -f tmp.2.{params.sample}.fastq tmp.1.{params.sample}.fastq

  '''

Burrows-Wheeler Alignment Tool
******************************

`BWA`_ is a software package for mapping low-divergent sequences against a large reference genome, such as the human genome. It consists of three algorithms: BWA-backtrack, BWA-SW and BWA-MEM.

.. code-block:: console


  #!/bin/bash

  SM_ARGS="--cpus-per-task {cluster.cpus-per-task} --mem-per-cpu {cluster.mem-per-cpu-mb} --job-name {cluster.job-name} --ntasks {cluster.ntasks} --partition {cluster.partition} --time {cluster.time} --mail-user {cluster.mail-user} --mail-type {cluster.mail-type} --error {cluster.error} --output {cluster.output}"

  # Syntax to run it on Rockfish cluster
  "exec" "snakemake" "--jobs" "200" "--snakefile" "$0" "--latency-wait" "120" "--cluster" "sbatch $SM_ARGS"

  # Syntax to run it on computer
  #"exec" "snakemake" "--printshellcmds" "--snakefile" "$0" "--jobs" "10" "--latency-wait" "120"

  import glob
  import os.path
  import itertools

  SOURCE_DIR = '../../_m'
  EXT = '_R2.fastq.gz'

  def sample_dict_iter(path, ext):
      for filename in glob.iglob(path+'/*'+ext):
          sample = os.path.basename(filename)[:-len(ext)]
          yield sample, {'r1_in': SOURCE_DIR + '/' + sample + '_R1.fastq.gz',
  		       'r2_in': SOURCE_DIR + '/' + sample + '_R2.fastq.gz'
  		      }

  SAMPLE_DICT = {k:v for k,v in sample_dict_iter(SOURCE_DIR, EXT)}

  #insure errors propogate along pipe'd shell commands
  shell.prefix("set -o pipefail; ")

  rule all:
      input:
          expand('../_m/{sample}.bam',
  	       sample=SAMPLE_DICT.keys())

  rule bwamem:
      input:
          r1 = lambda x: SAMPLE_DICT[x.sample]['r1_in'],
  	r2 = lambda x: SAMPLE_DICT[x.sample]['r2_in']

      output:
          '../_m/{sample}.bam'

      params:
          sample = '{sample}'

      shell:
          '''
      export PATH=$HOME'/.local/bin:'$PATH

      GENOME='../../../../genome/hs37d5/names_as_hg19/bwa/_m/hs37d5_hg19.fa'

      bwa mem -T 19 -t 4 ${{GENOME}} {input.r1} {input.r2} 2> {params.sample}.stderr | samtools view -S -b - > {output}

  '''

Remove duplicates
***************

`rmdup`_ is a script part of the SLAV-Seq protocol written by Apuã Paquola, coded in Perl to read .bam input files and apply samtools software to treat paired-end reads and single-end reads

.. code-block:: console

  #!/bin/bash

  SM_ARGS="--cpus-per-task {cluster.cpus-per-task} --mem-per-cpu {cluster.mem-per-cpu-mb} --job-name {cluster.job-name} --ntasks {cluster.ntasks} --partition {cluster.partition} --time {cluster.time} --mail-user {cluster.mail-user} --mail-type {cluster.mail-type} --error {cluster.error} --output {cluster.output}"

  # Syntax to run it on Rockfish cluster
  "exec" "snakemake" "--jobs" "200" "--snakefile" "$0" "--latency-wait" "120" "--cluster" "sbatch $SM_ARGS"

  # Syntax to run it on computer
  #"exec" "snakemake" "--printshellcmds" "--snakefile" "$0" "--jobs" "40" "--latency-wait" "240"

  import glob
  import os.path
  import itertools

  SOURCE_DIR = '../../_m'
  EXT = '.bam'


  def sample_dict_iter(path, ext):
      for filename in glob.iglob(path+'/*'+ext):
          sample = os.path.basename(filename)[:-len(ext)]
          yield sample, {'filename': filename}


  SAMPLE_DICT = {k:v for k,v in sample_dict_iter(SOURCE_DIR, EXT)}

  #insure errors propogate along pipe'd shell commands
  shell.prefix("set -o pipefail; ")

  rule all:
      input:
          expand('../_m/{sample}.bam', sample=SAMPLE_DICT.keys())

  rule process_one_sample:
      input:
          lambda x: SAMPLE_DICT[x.sample]['filename']

      output:
          '../_m/{sample}.bam'
      log:
          stderr = '{sample}.stderr',
          stdout = '{sample}.stdout'
      shell:
          '../_h/slavseq_rmdup.pl {input} {output}'


Add tags
***************

_tags is a script part of the SLAV-Seq protocol written by Apuã Paquola, coded in Perl to add the custom flags into the bam file.

.. code-block:: console

  #!/bin/bash

  SM_ARGS="--cpus-per-task {cluster.cpus-per-task} --mem-per-cpu {cluster.mem-per-cpu-mb} --job-name {cluster.job-name} --ntasks {cluster.ntasks} --partition {cluster.partition} --time {cluster.time} --mail-user {cluster.mail-user} --mail-type {cluster.mail-type} --error {cluster.error} --output {cluster.output}"

  # Syntax to run it on Rockfish cluster
  "exec" "snakemake" "--jobs" "200" "--snakefile" "$0" "--latency-wait" "120" "--cluster" "sbatch $SM_ARGS"

  # Syntax to run it on computer
  #"exec" "snakemake" "--printshellcmds" "--snakefile" "$0" "--jobs" "10" "--latency-wait" "120"

  import glob
  import os.path
  import itertools

  SOURCE_DIR = '../../_m'
  EXT = '.bam'

  def sample_dict_iter(path, ext):
      for filename in glob.iglob(path+'/*'+ext):
          sample = os.path.basename(filename)[:-len(ext)]
          yield sample, {'filename': SOURCE_DIR + '/' + sample + '.bam'}


  SAMPLE_DICT = {k:v for k,v in sample_dict_iter(SOURCE_DIR, EXT)}

  #insure errors propogate along pipe'd shell commands
  shell.prefix("set -o pipefail; ")

  rule all:
      input:
          expand('../_m/{sample}.bam',
                 sample=SAMPLE_DICT.keys())

  rule tags:
      input:
          '../../_m/{sample}.bam'

      output:
          '../_m/{sample}.bam'

      params:
          sample = '{sample}'

      shell:
          '''
      export PERL5LIB=$HOME'/perl5/lib/perl5/'
      export CONSENSUS='ATGTACCCTAAAACTTAGAGTATAATAAA'
      export PATH=$HOME'/.local/bin:'$PATH

      GENOME='../../../../../../genome/hs37d5/names_as_hg19/_m/hs37d5_hg19.fa'

      PREFIX_LENGTH=`perl -e 'print length($ENV{{CONSENSUS}})+2'`
      R1_FLANK_LENGTH=750
      R2_FLANK_LENGTH=${{PREFIX_LENGTH}}
      SOFT_CLIP_LENGTH_THRESHOLD=5

      (samtools view -h {input} | ../_h/add_tags_hts.pl --genome_fasta_file ${{GENOME}} --prefix_length ${{PREFIX_LENGTH}} --consensus ${{CONSENSUS}} --r1_flank_length ${{R1_FLANK_LENGTH}} --r2_flank_length ${{R2_FLANK_LENGTH}} --soft_clip_length_threshold ${{SOFT_CLIP_LENGTH_THRESHOLD}} | samtools view -S -b - > {output}) 2> {params.sample}.stderr

  '''


Tabix
***************

`Tabix`_ indexes a TAB-delimited genome position file in.tab.bgz and creates an index file (in.tab.bgz.tbi or in.tab.bgz.csi) when region is absent from the command-line.

.. code-block:: console

  #!/bin/bash

  SM_ARGS="--cpus-per-task {cluster.cpus-per-task} --mem-per-cpu {cluster.mem-per-cpu-mb} --job-name {cluster.job-name} --ntasks {cluster.ntasks} --partition {cluster.partition} --time {cluster.time} --mail-user {cluster.mail-user} --mail-type {cluster.mail-type} --error {cluster.error} --output {cluster.output}"

  # Syntax to run it on Rockfish cluster
  "exec" "snakemake" "--jobs" "200" "--snakefile" "$0" "--latency-wait" "120" "--cluster" "sbatch $SM_ARGS"

  # Syntax to run it on computer
  #"exec" "snakemake" "--printshellcmds" "--snakefile" "$0" "--jobs" "10" "--latency-wait" "120"

  import glob
  import os.path
  import itertools
  import os
  import sys
  import warnings
  import subprocess

  SOURCE_DIR = '../../_m'
  EXT = '.bam'

  def sample_dict_iter(path, ext):
      for filename in glob.iglob(path+'/*'+ext):
          sample = os.path.basename(filename)[:-len(ext)]
          yield sample, {'filename': SOURCE_DIR + '/' + sample + '.bam'}

  SAMPLE_DICT = {k:v for k,v in sample_dict_iter(SOURCE_DIR, EXT)}

  #insure errors propogate along pipe'd shell commands
  shell.prefix("set -o pipefail; ")

  rule all:
      input:
          expand('../_m/{sample}.{ext}',
                 sample=SAMPLE_DICT.keys(),
  	       ext=['bgz', 'bgz.tbi'])

  rule tabix:
      input:
          '../../_m/{sample}.bam'

      output:
          bgz = '../_m/{sample}.bgz',
          tbi = '../_m/{sample}.bgz.tbi'

      params:
          sample = '{sample}'

      shell:
          '''
      export PATH=$HOME'/.local/bin:'$PATH

      TMP_DIR='tmp.{params.sample}'
      mkdir ${{TMP_DIR}}

      export LC_ALL=C

      ( samtools view {input} | ../_h/sam_to_tabix.py 2>{params.sample}.stderr | sort --temporary-directory=${{TMP_DIR}} --buffer-size=10G -k1,1 -k2,2n -k3,3n | bgzip -c > {output.bgz} )

      rmdir ${{TMP_DIR}}

      tabix -s 1 -b 2 -e 3 -0 {output.bgz}

  '''


.. _Cutadapt: https://cutadapt.readthedocs.io/en/stable/
.. _BWA: http://bio-bwa.sourceforge.net/bwa.shtml
.. _rmdup: https://github.com/apuapaquola/slavseq_rf/blob/master/pipeline/fastq/cutadapt/bwamem/rmdup/_h/slavseq_rmdup.pl
.. _tags:https://github.com/apuapaquola/slavseq_rf/blob/master/pipeline/fastq/cutadapt/bwamem/rmdup/tags/_h/add_tags.pl
.. _tabix: http://www.htslib.org/doc/tabix.html
.. _Snakemake: https://snakemake.readthedocs.io/en/stable/tutorial/tutorial.html
.._Snakefile: ttps://snakemake.readthedocs.io/en/stable/snakefiles/rules.html
.. _workflows: https://snakemake.readthedocs.io/en/stable/snakefiles/writing_snakefiles.html
