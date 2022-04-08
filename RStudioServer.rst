RStudio Server
##############

The open-source RStudio Server provides a fully-featured IDE for R users.

The users can access RStudio Server on Rockfish using the r-studio-server.sh command. It will submit a SLURM job to system.

Usage examples to start the RStudio service:

.. code-block:: console

  $ r-studio-server.sh -h
  $ r-studio-server.sh -n 1 -c 2 -m 4G -t 0-02:0:0 -p defq (default)
  $ r-studio-server.sh -c 2 -t 4:0:0 -p defq -e <userid>@jhu.edu

.. code-block:: console

  #!/bin/bash
  #####################################
  #SBATCH --job-name=rstudio_container_$user
  #SBATCH --time=00-02:00
  #SBATCH --partition=defq
  #SBATCH --mem=16G
  #SBATCH --signal=USR2
  #SBATCH --nodes=1
  #SBATCH --cpus-per-task=4
  #SBATCH --mail-type=END,FAIL
  #SBATCH --mail-user=$user@jhu.edu
  #SBATCH --output=rstudio-server.job.%j.out
  #####################################

  #module load r/4.0.2

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
