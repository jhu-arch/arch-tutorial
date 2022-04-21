RStudio Server
##############

The open-source RStudio Server provides a fully-featured IDE for R users.

The ARCH users can access the RStudio Server on Rockfish using the ``r-studio-server.sh`` command. It will create a Slurm script to run on the system.

Usage examples to start the RStudio service:

.. code-block:: console

  $ r-studio-server.sh -h
  $ r-studio-server.sh -n 1 -c 2 -m 8G -t 1-02:0 -p defq (default)
  $ r-studio-server.sh -c 2 -t 4:0:0 -p defq -e <userid>@jhu.edu
  $ r-studio-server.sh -c 24 -g 2 -p a100 -a <PI-userid>_gpu

Executing the ``r-studio-server.sh`` you will a script called ``R-Studio-Server.slurm.script`` it looks like this code-block below.

.. code-block:: console

  Creating slurm script: R-Studio-Server.slurm.script

  The Advanced Research Computing at Hopkins (ARCH)
  SLURM job script for run RStudio into Singularity container
  Support:  help@rockfish.jhu.edu

  Nodes:       	2
  Cores/task:  	4
  Total cores: 	8
  Walltime:    	00-02:00
  Queue:       	defq

  The R-Studio-Server is ready to run.

  1 - Usage:

 	 $ sbatch R-Studio-Server.slurm.script

  2 - How to login see login file (after step 1):

 	 $ cat rstudio-server.job.<SLURM_JOB_ID>.out

  3 - More information about the job (after step 1):

 	 $ scontrol show jobid <SLURM_JOB_ID>

Example the R-Studio-Server.slurm.script created by this syntax ``r-studio-server.sh -n 1 -c 2 -m 8G -t 1-02:0 -p defq`` command.

.. tip::
  The ``#SBATCH`` tags can be customized.
  Also, there is an R environment session in the R-Studio-Server.slurm.script which the user can change to run it using another R, instead of inside the container (R 4.0.4).

.. warning::

  To run the R-Studio-Server.slurm.script properly. Please, make sure you don't have the anaconda module loaded when you submit it.

  You should disable it ``$ module unload anaconda``.

.. code-block:: console

  #!/bin/bash
  #####################################
  #SBATCH --job-name=rstudio_container_rdesouz4
  #SBATCH --time=1-02:0
  #SBATCH --partition=defq
  #SBATCH --signal=USR2
  #SBATCH --nodes=1
  #SBATCH --cpus-per-task=2
  #SBATCH --mem=8G
  #SBATCH --mail-type=END,FAIL
  #SBATCH --mail-user=rdesouz4@jh.edu
  #SBATCH --output=rstudio-server.job.%j.out
  #####################################

  # ---------------------------------------------------
  #  R environment
  # ---------------------------------------------------
  # This session is to run this script using another R instead of inside the container (R 4.0.4).

  #  There are two ways to run it:
  #
  #     METHOD 1: Using an R via the system module

  # Uncomment this Line
  # module load r/3.6.3

  #     METHOD 2: Using an R installed in a custom virtual environment, in this case using conda.
  #
  #     How to install an R version 3.6.6 sunig conda
  #     $ module load anaconda && conda create -n r_3.6.3 -c conda-forge r-base=3.6.3 libuuid && module unload anaconda
  #
  # Uncomment these two instructions
  # module load anaconda && conda activate r_3.6.3 && module unload anaconda
  # export R_HOME=$CONDA_PREFIX/lib/R

  #   -- THIS LINE IS REQUIRED FOR BOTH METHODS --
  #
  # Uncomment this instruction
  # export SINGULARITY_BIND=${R_HOME}:/usr/local/lib/R

  # ---------------------------------------------------
  # R_LIBS_USER directives for multiple environments
  # ---------------------------------------------------
  # Change the MY_LIBS variable to use the libraries related with your project.

  export MY_LIBS=4.0.4
  export R_LIBS_USER=${HOME}/R/${MY_LIBS}

  # ---------------------------------------------------
  #  Singularity environment variables
  # ---------------------------------------------------

  # -- SHOULDN'T BE NECESSARY TO CHANGE ANYTHING BELOW THIS --

  source .r-studio-variables

  export SINGULARITYENV_LDAP_HOST=ldapserver
  export SINGULARITYENV_LDAP_USER_DN='uid=%s,dc=cm,dc=cluster'
  export SINGULARITYENV_LDAP_CERT_FILE=/etc/rstudio/ca.pem

  cat 1>&2 <<END

  1. SSH tunnel from your workstation using the following command:

   ssh -N -L ${PORT}:${HOSTNAME}:${PORT} ${SINGULARITYENV_USER}@login.rockfish.jhu.edu

  2. log in to RStudio Server in your web browser using the Rockfish cluster credentials (username and password) at:

   http://localhost:${PORT}

   user: ${SINGULARITYENV_USER}
   password: < Rochkfish password >

  3. When done using RStudio Server, terminate the job by:

   a. Exit the RStudio Session ("power" button in the top right corner of the RStudio window)
   b. Issue the following command on the login node:

  scancel -f ${SLURM_JOB_ID}
  END

  singularity run ${SINGULARITY_CONTAINER} \
  rserver --www-port ${PORT} --www-address=0.0.0.0 \
          --auth-none 0 \
          --auth-pam-helper-path=ldap_auth \
          --rsession-path=/etc/rstudio/rsession.sh
