Snakemake Workflows
###################

.. image:: https://img.shields.io/conda/dn/bioconda/snakemake.svg?label=Bioconda
    :target: https://bioconda.github.io/recipes/snakemake/README.html

.. image:: https://img.shields.io/pypi/pyversions/snakemake.svg
    :target: https://www.python.org

.. image:: https://img.shields.io/pypi/v/snakemake.svg
    :target: https://pypi.python.org/pypi/snakemake

.. image:: https://img.shields.io/github/workflow/status/snakemake/snakemake/Publish%20to%20Docker%20Hub?color=blue&label=docker%20container&branch=main
    :target: https://hub.docker.com/r/snakemake/snakemake

.. image:: https://github.com/snakemake/snakemake/workflows/CI/badge.svg?branch=main&label=tests
    :target: https://github.com/snakemake/snakemake/actions?query=branch%3Amain+workflow%3ACI

.. image:: https://img.shields.io/badge/stack-overflow-orange.svg
    :target: https://stackoverflow.com/questions/tagged/snakemake

The `Snakemake`_ workflows management system is a tool to create reproducible and scalable data analyses.

.. warning::
  The $SM_ARGS env variable used in the scripts below is still under evaluation.

This tutorial presents a bioinformatics pipeline using Snakemake and :ref:`the Reproducibility Framework (RF)
<Reproducibility-Framework>`.

We will use the Two classes of L1-associated somatic variants in human brain from Sallk Institute for Biological Studies dataset.

.. note::
  Bioproject: ``PRJEB10849`` SRA Study: ``ERP012147``.

  https://trace.ncbi.nlm.nih.gov/Traces/sra/?run=ERR1016570

Pipeline
********

Then, let's create the pipeline directory structure to store this tutorial.

.. code-block:: python

    [userid@login03 ~]$ mkdir -p pipeline/_h
    [userid@login03 ~]$ mkdir -p pipeline/cutadapt/_h
    [userid@login03 ~]$ mkdir -p pipeline/cutadapt/bwamem/_h
    [userid@login03 ~]$ mkdir -p pipeline/cutadapt/bwamem/rmdup/_h
    [userid@login03 ~]$ mkdir -p pipeline/cutadapt/bwamem/rmdup/tags/_h
    [userid@login03 ~]$ mkdir -p pipeline/cutadapt/bwamem/rmdup/tags/tabix/_h

SRA Toolkit
***********

To download sequence data files using SRA Toolkit, you need create a ``run`` file into ``pipeline/_h`` folder.

.. code-block:: python

  #!/bin/bash

  #SBATCH -J sra_tools
  #SBATCH -p defq
  #SBATCH -N 1
  #SBATCH --time=2:00:00
  #SBATCH --cpus-per-task=1
  #SBATCH --output=Array_test.%A_%a.out
  #SBATCH --array=1-101

  ml sra-tools/3.0.0

  # samples correspond to Bioproject PRJEB10849

  sra_numbers=($(echo {1016570..1016671}))

  sra_id='ERR'${sra_numbers[ $SLURM_ARRAY_TASK_ID - 1 ]}

  prefetch --max-size 100G $sra_id --force yes --verify no
  fastq-dump --outdir . --gzip --skip-technical  --readids --read-filter pass --dumpbase --split-3 --clip ${sra_id}/${sra_id}.sra

  rm $sra_id -Rf

The  ``rf`` command will call the ``run`` script to retrieve SRA Normalized Format files with full base quality scores, and store them ``fastq`` files into ``_m`` folder.

.. code-block:: python

  [userid@login03 ~]$ cd pipeline/
  [userid@login03 ~]$ chmod +x _h/run
  [userid@login03 pipeline]$ rf sbatch -v .
  all: /home/userid/pipeline/_m/SUCCESS

  .ONESHELL:
  /home/userid/pipeline/_m/SUCCESS:
  	echo -n "Start /home/userid/pipeline: "; date --rfc-3339=seconds
  	mkdir /home/userid/pipeline/_m
  	cd /home/userid/pipeline/_m
  	sbatch ../_h/run > nohup.out 2>&1
  	touch SUCCESS
  	echo -n "End /home/userid/pipeline: "; date --rfc-3339=seconds

  Start /home/userid/pipeline: 2022-04-27 16:14:52-04:00
  End /home/userid/pipeline: 2022-04-27 16:14:52-04:00


.. note::
  * **Writing Workflows** : "In Snakemake, `workflows`_ are specified as Snakefiles. Inspired by GNU Make, a `Snakefile`_ contains rules that denote how to create output files from input files. Dependencies between rules are handled implicitly, by matching filenames of input files against output files. Thereby wildcards can be used to write general rules."

  * **Snakefiles and Rules** : "A Snakemake workflow defines a data analysis in terms of rules that are specified in the Snakefile."

We will create a hypothetical scenario with precedent steps, where for example the Level 5 (tabix) depends on the Level 4 (tags), and so on.

.. note::
  **Level 1 (cutadapt)  ->   Level 2 (bwamem) ->   Level 3 (rmdup) ->  Level 4 (tags) ->  Level 5 (tabix)**

Cutadapt
********

.. image:: https://github.com/marcelm/cutadapt/workflows/CI/badge.svg
    :alt:

.. image:: https://img.shields.io/pypi/v/cutadapt.svg?branch=master
    :target: https://pypi.python.org/pypi/cutadapt
    :alt:

.. image:: https://codecov.io/gh/marcelm/cutadapt/branch/master/graph/badge.svg
    :target: https://codecov.io/gh/marcelm/cutadapt
    :alt:

.. image:: https://img.shields.io/badge/install%20with-bioconda-brightgreen.svg?style=flat
    :target: http://bioconda.github.io/recipes/cutadapt/README.html
    :alt: install with bioconda

Cutadapt finds and removes adapter sequences, primers, poly-A tails and other types of unwanted sequence from your high-throughput sequencing reads. It helps with these trimming tasks by finding the adapter or primer sequences in an error-tolerant way.

.. code-block:: python

  [userid@login03 pipeline]$ cd cutadapt/
  [userid@login03 cutadapt]$ vi _h/run
  [userid@login03 cutadapt]$ chmod +x _h/run
  [userid@login03 cutadapt]$ rf sbatch -v .
  all: /home/userid/pipeline/cutadapt/_m/SUCCESS

  .ONESHELL:
  /home/userid/pipeline/cutadapt/_m/SUCCESS:
  	echo -n "Start /home/userid/pipeline/cutadapt: "; date --rfc-3339=seconds
  	mkdir /home/userid/pipeline/cutadapt/_m
  	cd /home/userid/pipeline/cutadapt/_m
  	sbatch ../_h/run > nohup.out 2>&1
  	touch SUCCESS
  	echo -n "End /home/userid/pipeline/cutadapt: "; date --rfc-3339=seconds

  Start /home/userid/pipeline/cutadapt: 2022-04-27 16:47:18-04:00
  End /home/userid/pipeline/cutadapt: 2022-04-27 16:47:18-04:00


.. code-block:: python

  #!/bin/bash

  module snakemake/7.6.0

  SM_ARGS="--cpus-per-task=10 --job-name=cutadpat --partition=defq --time=2:00:00 --mail-user=userid@jhu.edu -mail-type=END,FAIL --output=cutadapt.job.%j.out"

  # Syntax to run it on Rockfish cluster
  "exec" "snakemake" "--jobs" "200" "--snakefile" "$0" "--latency-wait" "120" "--cluster" "sbatch $SM_ARGS"

  # Syntax to run it on computer
  #"exec" "snakemake" "--printshellcmds" "--snakefile" "$0" "--jobs" "20" "--latency-wait" "120"

  import glob
  import os.path
  import itertools

  SOURCE_DIR = '../../_m'
  EXT = '_pass_1.fastq.gz'

  def sample_dict_iter(path, ext):
    for filename in glob.iglob(path+'/*'+ext):
        sample = os.path.basename(filename)[:-len(ext)]

        yield sample, {'r1_in': SOURCE_DIR + '/' + sample + '_pass_1.fastq.gz',
                       'r2_in': SOURCE_DIR + '/' + sample + '_pass_2.fastq.gz'
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
    module load cutadapt/3.2

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

.. image:: https://github.com/lh3/bwa/actions/workflows/ci.yaml/badge.svg
    :target: https://github.com/lh3/bwa/actions
    :alt: Build Status

.. image:: https://img.shields.io/sourceforge/dt/bio-bwa.svg
    :target: https://sourceforge.net/projects/bio-bwa/files/?source=navbar
    :alt: SourceForge Downloads

.. image:: https://img.shields.io/github/downloads/lh3/bwa/total.svg
    :target: https://github.com/lh3/bwa/releases
    :alt: GitHub Downloads

.. image:: https://img.shields.io/conda/dn/bioconda/bwa.svg
    :target: https://anaconda.org/bioconda/bwa
    :alt: BioConda Install

`BWA`_ is a software package for mapping low-divergent sequences against a large reference genome, such as the human genome. It consists of three algorithms: BWA-backtrack, BWA-SW and BWA-MEM.

.. code-block:: python

  #!/bin/bash

  module snakemake/7.6.0

  SM_ARGS="--cpus-per-task=10 --mem-per-cpu=4GB --job-name=bwamem --nodes=10 --partition=defq --time=2:00:00 --mail-user=userid@jhu.edu -mail-type=END,FAIL --output=bwamem.job.%j.out"

  # Syntax to run it on Rockfish cluster
  "exec" "snakemake" "--jobs" "200" "--snakefile" "$0" "--latency-wait" "120" "--cluster" "sbatch $SM_ARGS"

  # Syntax to run it on computer
  #"exec" "snakemake" "--printshellcmds" "--snakefile" "$0" "--jobs" "10" "--latency-wait" "120"

  import glob
  import os.path
  import itertools

  SOURCE_DIR = '../../_m'
  EXT = '_pass_1.fastq.gz'

  def sample_dict_iter(path, ext):
      for filename in glob.iglob(path+'/*'+ext):
          sample = os.path.basename(filename)[:-len(ext)]
          yield sample, {'r1_in': SOURCE_DIR + '/' + sample + '_pass_1.fastq.gz',
  		                   'r2_in': SOURCE_DIR + '/' + sample + '_pass_2.fastq.gz'
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
      module load bwa-mem/0.7.17 samtools/1.15.1

      export PATH=$HOME'/.local/bin:'$PATH

      GENOME='../../../../genome/hs37d5/names_as_hg19/bwa/_m/hs37d5_hg19.fa'

      bwa mem -T 19 -t 4 ${{GENOME}} {input.r1} {input.r2} 2> {params.sample}.stderr | samtools view -S -b - > {output}
  '''

Remove duplicates
***************

`rmdup`_ is a script part of the SLAV-Seq protocol written by Apuã Paquola, coded in Perl to read .bam input files and apply samtools software to treat paired-end reads and single-end reads.

.. code-block:: python

  #!/bin/bash

  SM_ARGS="--cpus-per-task=10 --mem-per-cpu=4GB --job-name=rmdup --nodes=10 --partition=defq --time=2:00:00 --mail-user=userid@jhu.edu -mail-type=END,FAIL --output=rmdup.job.%j.out"

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

`tags`_ is a script part of the SLAV-Seq protocol written by Apuã Paquola, coded in Perl to add the custom flags into bam files.

.. code-block:: python

  #!/bin/bash

  module snakemake/7.6.0

  SM_ARGS="--cpus-per-task=10 --mem-per-cpu=4GB --job-name=tags --nodes=10 --partition=defq --time=2:00:00 --mail-user=userid@jhu.edu -mail-type=END,FAIL --output=tags.job.%j.out"

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

      module load samtools/1.15.1

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

.. code-block:: python

  #!/bin/bash

  module snakemake/7.6.0

  SM_ARGS="--cpus-per-task=10 --mem-per-cpu=4GB --job-name=tabix --nodes=10 --partition=defq --time=2:00:00 --mail-user=userid@jhu.edu -mail-type=END,FAIL --output=tabix.job.%j.out"

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
      module load tabix/1.13 samtools/1.15.1 bzip2/1.0.8

      export PATH=$HOME'/.local/bin:'$PATH

      TMP_DIR='tmp.{params.sample}'
      mkdir ${{TMP_DIR}}

      export LC_ALL=C

      ( samtools view {input} | ../_h/sam_to_tabix.py 2>{params.sample}.stderr | sort --temporary-directory=${{TMP_DIR}} --buffer-size=10G -k1,1 -k2,2n -k3,3n | bgzip2 -c > {output.bgz} )

      rmdir ${{TMP_DIR}}

      tabix -s 1 -b 2 -e 3 -0 {output.bgz}

  '''

Once you coded the pipeline, just run :ref:`the Reproducibility Framework (RF)
<Reproducibility-Framework>`.

.. code-block:: python

    ├── pipeline
    │   └── cutadapt
    │       ├── _h
    │       │   ├── rename_cutadapt.sh
    │       │   └── run
    │       └── bwamem
    │           ├── _h
    │           │   ├── check_ok.sh
    │           │   ├── run
    │           │   ├── run.hg19
    │           │   └── run.hs37d5
    │           └── rmdup
    │               ├── _h
    │               │   ├── run
    │               │   ├── slavseq_rmdup.pl
    │               │   └── slavseq_rmdup_hts.pl
    │               └── tags
    │                   ├── _h
    │                   │   ├── add_tags.pl
    │                   │   ├── add_tags_hts.pl
    │                   │   └── run
    │                   └── tabix
    │                       └── _h
    │                           ├── run
    │                           └── sam_to_tabix.py

You run one level at a time, or you can use the ``-r`` option for recursive. It will perform the ``rf`` command, once the level 1 is finishes, it will run next level, so consecutively.

.. code-block:: console

  [userid@login03 ~]$ interact -c 2 -t 120
  [userid@c010 ~]$ cd pipeline
  [userid@c010 ~]$ rf run -r .

.. warning::
  The ``rf`` command is validated to run in interactive mode, so far.


.. _Cutadapt: https://cutadapt.readthedocs.io/en/stable/
.. _BWA: http://bio-bwa.sourceforge.net/bwa.shtml
.. _rmdup: https://github.com/apuapaquola/slavseq_rf/blob/master/pipeline/fastq/cutadapt/bwamem/rmdup/_h/slavseq_rmdup.pl
.. _tags: https://github.com/apuapaquola/slavseq_rf/blob/master/pipeline/fastq/cutadapt/bwamem/rmdup/tags/_h/add_tags.pl
.. _tabix: http://www.htslib.org/doc/tabix.html
.. _Snakemake: https://snakemake.readthedocs.io/en/stable/tutorial/tutorial.html
.. _Snakefile: ttps://snakemake.readthedocs.io/en/stable/snakefiles/rules.html
.. _workflows: https://snakemake.readthedocs.io/en/stable/snakefiles/writing_snakefiles.html
