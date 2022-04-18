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

After running ``r-studio-server.sh`` you will see details about the script created, like this next code-block below.

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

Example the R-Studio-Server slurm script created by ``r-studio-server.sh -n 1 -c 2 -m 8G -t 1-02:0 -p defq`` command.

.. tip::
  The ``#SBATCH`` tags can be customized.

.. code-block:: console

  #!/bin/bash
  #####################################
  #SBATCH --job-name=rstudio_container_$user
  #SBATCH --time==1-02:0
  #SBATCH --partition=defq
  #SBATCH --signal=USR2
  #SBATCH --nodes=1
  #SBATCH --cpus-per-task=2
  #SBATCH --mem=8G
  #SBATCH --mail-type=END,FAIL
  #SBATCH --mail-user=$user@jhu.edu
  #SBATCH --output=rstudio-server.job.%j.out
  #####################################

  # module load r/4.0.2

  # R_LIBS_USER directives for installing and using packages
  export R_LIBS_USER=${HOME}/R/rstudio/4.0

  # do not remove or change any lines below - include singularity environment variables
  source /data/apps/helpers/.r-studio-server-variables

  cat 1>&2 <<END
  1. SSH tunnel from your workstation using the following command:

  	ssh -N -L ${PORT}:${HOSTNAME}:${PORT} ${SINGULARITYENV_USER}@login.rockfish.jhu.edu

  2. log in to RStudio Server in your web browser using the Rockfish cluster credentials (username and password) at:

  	http://localhost:${PORT}

  3. log in to RStudio Server using the following credentials:

  	user: ${SINGULARITYENV_USER}
  	password: <Rochkfish password>

  4 . When done using RStudio Server, terminate the job by:

  	a. Exit the RStudio Session ("power" button in the top right corner of the RStudio window)
  	b. Issue the following command on the login node:

  	scancel -f ${SLURM_JOB_ID}
  END

  singularity run ${SINGULARITY_IMAGE} \
      rserver --www-port ${PORT} --www-address=0.0.0.0 \
            --auth-none 0 \
            --auth-pam-helper-path=ldap_auth \
            --rsession-path=/etc/rstudio/rsession.sh
