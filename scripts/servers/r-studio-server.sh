#!/bin/bash
# -*- coding: utf-8 -*-
# SLURM job script for run RStudio into Singularity container
# The Advanced Research Computing at Hopkins (ARCH)
# Ricardo S Jacomini < rdesouz4 @ jhu.edu >
# Date: Feb, 4 2022

# custom of /data/apps/helpers/interact
#
# customize --output path as appropriate (to a directory readable only by the user!)

# Session timeout set up --time and --auth-stay-signed-in-day

export TERMINFO=/usr/share/terminfo

function Header
{

cat > $1 << EOF
#!/bin/bash

# ---------------------------------------------------
# The Advanced Research Computing at Hopkins (ARCH)
# User and Application Support < help@rockfish.jhu.edu >
#
# SLURM script to run the R-Studio-Server
#
# ---------------------------------------------------
#  INPUT ENVIRONMENT VARIABLES
# ---------------------------------------------------
#SBATCH --job-name=rstudio_container_${USER}
#SBATCH --time=${WALLTIME}
#SBATCH --partition=${QUEUE}
#SBATCH --signal=USR2
#SBATCH --nodes=${NODES}
#SBATCH --cpus-per-task=${CPUS}
EOF

if [[ ${MEM} != "4G" ]] ; then
cat >> $1 << EOF
#SBATCH --mem=${MEM}
EOF
fi

if [[ ${GRES} != 0 ]] ; then
   if [[ ${GID} -eq 1002 ]]; then
cat >> $1 << EOF
#SBATCH --qos=${QOS}
EOF
   else
cat >> $1 << EOF
#SBATCH --account=${ACCOUNT}
EOF
   fi
cat >> $1 << EOF
#SBATCH --gres=gpu:${GRES}
EOF
fi

if [[ ${QUEUE} == "bigmem" ]] ; then
cat >> $1 << EOF
#SBATCH --account=${ACCOUNT}_bigmem
EOF
fi

cat >> $1 << EOF
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=${EMAIL}
#SBATCH --output=rstudio-server.job.%j.out
# ---------------------------------------------------

EOF

cat >> $1 << \EOF

module restore

# ---------------------------------------------------
#  R environment
# ---------------------------------------------------
# This session is to run this script using another R instead of inside the container (R 4.0.4).

#  There are two ways to run it:
#
#     METHOD 1: Using an R via the system module

# Uncomment this Line
# module load r/3.6.3
# or
# module load seurat/4.1.1

#     METHOD 2: Using an R installed in a custom virtual environment, in this case using conda.
#
#     How to install an R version 3.6.6 using conda env
#     $ module load anaconda && conda create -n r_3.6.3 -c conda-forge r-base=3.6.3 libuuid && module unload anaconda
#     How to remove conda envs
#     $ conda remove --name r_3.6.3 --all

#
# Uncomment these two instructions
# module load anaconda && conda activate r_3.6.3 && export VIRT_ENV=$CONDA_PREFIX && module unload anaconda
# export R_HOME=${VIRT_ENV}/lib/R

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

EOF

}

function rockfish
{

cat >> $1 << \EOF

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
          --auth-none 0 --server-user=${SINGULARITYENV_USER} \
          --auth-pam-helper-path=pam-arch \
          --rsession-path=/etc/rstudio/rsession.sh
EOF

}

function none
{

cat > $1 << \EOF

cat 1>&2 <<END
1. SSH tunnel from your workstation using the following command:

	ssh -N -L ${PORT}:${HOSTNAME}:${PORT} ${SINGULARITYENV_USER}@login.rockfish.jhu.edu

2. log in to RStudio Server in your web browser using the Rockfish cluster credentials (username and password) at:

	http://localhost:${PORT}

3. RStudio Server is runnig without credentials!

4. When done using RStudio Server, terminate the job by:

	a. Exit the RStudio Session ("power" button in the top right corner of the RStudio window)
	b. Issue the following command on the login node:

	scancel -f ${SLURM_JOB_ID}
END

singularity run ${SINGULARITY_CONTAINER} \
    rserver --www-port ${PORT} --www-address=0.0.0.0 \
            --auth-none=1 \
            --rsession-path=/etc/rstudio/rsession.sh
printf 'rserver exited' 1>&2
EOF

}

function random
{

cat > $1 << \EOF

export SINGULARITYENV_PASSWORD=$(openssl rand -base64 15)

cat 1>&2 <<END
1. SSH tunnel from your workstation using the following command:

	ssh -N -L ${PORT}:${HOSTNAME}:${PORT} ${SINGULARITYENV_USER}@login.rockfish.jhu.edu

2. log in to RStudio Server in your web browser using the Rockfish cluster credentials (username and password) at:

	http://localhost:${PORT}

3. log in to RStudio Server using the following credentials:

	user: ${SINGULARITYENV_USER}
	password: ${SINGULARITYENV_PASSWORD}

4 . When done using RStudio Server, terminate the job by:

	a. Exit the RStudio Session ("power" button in the top right corner of the RStudio window)
	b. Issue the following command on the login node:

	scancel -f ${SLURM_JOB_ID}
END

singularity run ${SINGULARITY_CONTAINER} \
    rserver --www-port ${PORT} --www-address=0.0.0.0 \
            --auth-none=0 \
            --auth-pam-helper-path=pam-helper \
            --rsession-path=/etc/rstudio/rsession.sh
EOF

}
function run ()
{

	sbr="$(sbatch "$@")"

  sleep 5

  #NODE=$(sacct -j ${JobId} -o nodelist | tail -n 1 | tr -d ' ')

	if [[ "$sbr" =~ Submitted\ batch\ job\ ([0-9]+) ]]; then
		echo -e "\n\nHow to login to RStudio Server see details in: \n"
	  echo "rstudio-server.job.${BASH_REMATCH[1]}.out"
    echo -e "\n"
	else
	  echo "sbatch failed"
	  exit 1
	fi
}

function r_studio_variables
{
cat > .r-studio-variables << \EOF

# Create temporary directory to be populated with directories to bind-mount in the container
# where writable file systems are necessary. Adjust path as appropriate for your computing environment.
export workdir=$(python -c 'import tempfile; print(tempfile.mkdtemp())')

mkdir -p -m 700 ${workdir}/run ${workdir}/tmp ${workdir}/var/lib/rstudio-server ${workdir}/var/log

cat > ${workdir}/database.conf <<END
provider=sqlite
directory=/var/lib/rstudio-server
END

cat > ${workdir}/rserver.conf <<END
rsession-which-r=/usr/local/bin/R
END

cat >  ${workdir}/rsession.sh << END
#!/bin/sh
# Log all output from this script
export RSESSION_LOG_FILE=/var/log/rstudio/rsession.log
export OMP_NUM_THREADS=${SLURM_JOB_CPUS_PER_NODE}

exec &>>"\${RSESSION_LOG_FILE}"

# Launch the original command
echo "**Which rsession"
which rsession
echo "Launching rsession..."
set -x

exec rsession --r-libs-user "${R_LIBS_USER}"  "\${@}"
END

chmod +x ${workdir}/rsession.sh

readonly export PORT=$(python -c 'import socket; s=socket.socket(); s.bind(("", 0)); print(s.getsockname()[1]); s.close()')

# Do not suspend idle sessions.
# Alternative to setting session-timeout-minutes=0 in /etc/rstudio/rsession.conf
# https://github.com/rstudio/rstudio/blob/v1.4.1106/src/cpp/server/ServerSessionManager.cpp#L126

export SINGULARITY_BIND=$SINGULARITY_BIND,"${workdir}/run:/run,${workdir}/tmp:/tmp,${workdir}/rserver.conf:/etc/rstudio/rserver.conf,${workdir}/database.conf:/etc/rstudio/database.conf,${workdir}/rsession.sh:/etc/rstudio/rsession.sh,${workdir}/var/log/:/var/log/rstudio/,${workdir}/var/lib/rstudio-server:/var/lib/rstudio-server"

export SINGULARITYENV_RSTUDIO_SESSION_TIMEOUT=0
export SINGULARITYENV_LIBRARY_PATH=$LIBRARY_PATH
export SINGULARITYENV_LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${VIRT_ENV}/lib
export SINGULARITYENV_R_LIBS_USER=$R_LIBS_USER
export SINGULARITYENV_PATH=/usr/lib/rstudio-server/bin:${PATH}

export SINGULARITYENV_USER=$(id -un)

export RSTUDIO_VERSION=rstudio_2022.10.6_485.sif

export SINGULARITY_CONTAINER=$HOME/singularity/r-studio/rstudio.sif

echo -e "\n The Advanced Research Computing at Hopkins (ARCH)"
echo -e " SLURM job script for run RStudio into Singularity container"
echo -e " Support:  help@rockfish.jhu.edu \n"


if [ ! -f ${SINGULARITY_CONTAINER} ]; then
   echo -e "Copying R-Studio-Server singularity :"
   echo -e "from: /data/apps/extern/singularity/r-studio/${RSTUDIO_VERSION} \n"
   echo -e "to  : $HOME/singularity/r-studio/rstudio.sif \n"

   mkdir -p $HOME/singularity/r-studio/
   cp -rpa /data/apps/extern/singularity/r-studio/${RSTUDIO_VERSION}  $HOME/singularity/r-studio/rstudio.sif
else
   echo -e "\nEvaluate the singularity version\n"

   result=$(md5sum /data/apps/extern/singularity/r-studio/${RSTUDIO_VERSION} $HOME/singularity/r-studio/rstudio.sif | awk '{print $1}' | uniq | wc -l)

   if [ $result == "2" ]; then
     echo -e "\nUpdating Singularity image: ${SINGULARITY_CONTAINER} \n"
     cp -rpa /data/apps/extern/singularity/r-studio/${RSTUDIO_VERSION} $HOME/singularity/r-studio/rstudio.sif
   else
     echo -e "\nUsing Singularity image: ${SINGULARITY_CONTAINER} \n"
   fi

fi

if [ ! -d ${R_LIBS_USER} ]; then
   mkdir -p ${R_LIBS_USER}
fi

EOF
}

function create
{

  r_studio_variables

  SCRIPT=R-Studio-Server.slurm.script

  echo -e "\n Creating slurm script: $SCRIPT \n"

  tmpfile_header=$(mktemp /tmp/header-slurm.XXXXXXXXXX)
  tmpfile_function=$(mktemp /tmp/function-slurm.XXXXXXXXXX)

  Header $tmpfile_header
  # Call function passed as argument
  $1 $tmpfile_function
  cat $tmpfile_header $tmpfile_function > $SCRIPT
  rm $tmpfile_header $tmpfile_function

  echo -e "\n The Advanced Research Computing at Hopkins (ARCH)"
  echo -e " SLURM job script for run RStudio into Singularity container"
  echo -e " Support:  help@rockfish.jhu.edu \n"

  echo -e  " Nodes:       \t$NODES"
  echo -e  " Cores/task:  \t$CPUS"
  echo -e  " Total cores: \t$(echo $NODES*$CPUS | bc)"
  echo -e  " Walltime:    \t$WALLTIME"
  echo -e  " Queue:       \t$QUEUE"

  echo -e "\n The R-Studio-Server is ready to run.  \n"
  echo -e " 1 - Usage: \n"
  echo -e "\t $ sbatch ${SCRIPT}  \n"

  echo -e " 2 - How to login see login file (after step 1): \n"
  echo -e "\t $ cat rstudio-server.job.<SLURM_JOB_ID>.out \n"

  echo -e " 3 - More information about the job (after step 1): \n"
  echo -e "\t $ scontrol show jobid <SLURM_JOB_ID> \n"


	exit 0
}

function usage_rfadmin
{
  clear
  echo "Admin Menu"

  echo -e "
  Usage: ${0##*/} [options] [arguments]
                  [-n nodes] [-c cpus] [-m memory] [-t walltime] [-p partition] [-a account] [-q qos] [-g gpu] [-e email] [-l login]

  Starts a SLURM job script to run R-Studio server into singularity container.

	Choose the access method to login.

  arguments:
  \t -l login  [ rockfish / none / random ] (default: $LOGIN)
  \t\t rockfish  = cluster credentials
  \t\t none      = without PASSWORD
  \t\t random    = random PASSWORD
"
  usage
}

function menu
{
  echo "User Menu"
  echo "
  usage: ${0##*/} [options]
                  [-n nodes] [-c cpus] [-m memory] [-t walltime] [-p partition] [-a account] [-q qos] [-g gpu] [-e email]

  Starts a SLURM job script to run R-Studio server into singularity container.
  "
  usage
}

function usage
{
  echo "
  options:
  ?,-h help      give this help list
    -n nodes     how many nodes you need  (default: $NODES)
    -c cpus      number of cpus per task (default: $CPUS)
    -m memory    memory in K|M|G|T        (default: $MEM)
                 (if m > max-per-cpu * cpus, more cpus are requested)
                 note: that if you ask for more than one CPU has, your account gets
                 charged for the other (idle) CPUs as well
    -t walltime  as dd-hh:mm (default: $WALLTIME) 2 hours
    -p partition partition in $QUEUE|bigmem|a100 (default: $QUEUE)
    -a account   if users needs to use a different account and GPU.
                 Default is primary PI combined with '_' for instance:
                 <PI-userid>_gpu (default: none)
    -q qos       quality of Service's that jobs are able to run in your association (default: qos_gpu)
    -g gpu       specify GRES for GPU-based resources (eg: -g 1 )
    -e email     notify if finish or fail (default: <userid>@jhu.edu)
    "
  exit 2
}

# we set express as the default shortly after adding it
export QUEUE="defq"
export NODES=1
export CPUS=1
export MEM=4G
export WALLTIME=00-02:00
export GRES=0
export ACCOUNT=$(sacctmgr list account withas where account=rfadmin format="acc%-20,us%-30" | grep $USER | cut -d " " -f 1)
export QOS=$(sacctmgr show qos format=name  | grep gpu | sed 's/ //g' | awk 'NR==1{print $1; exit}')
export EMAIL=$USER"@jhu.edu"
export LOGIN="rockfish"
export PASSWORD
export GID=$(id -g)

# check whether user had supplied -l or --login . If yes display usage
if [[ ( "$1" == *"all"* ) ]]
then
	usage_rfadmin
fi

if [[ ( "$1" == "-h" ) || ( "$1" == *"?"* ) || ( "$1" == "--help" )  ]]
then
  clear
  menu
fi

die() { echo "$*" >&2; exit 2; }  # complain to STDERR and exit with error
needs_arg() { if [ -z "$OPTARG" ]; then die "No arg for --$OPT option"; fi; }

while getopts q:n:c:m:t:p:a:g:e:l:-: OPT; do
  # support long options: https://stackoverflow.com/a/28466267/519360
 if [ "$OPT" = "-" ]; then   # long option: reformulate OPT and OPTARG
   OPT="${OPTARG%%=*}"       # extract long option name
   OPTARG="${OPTARG#$OPT}"   # extract long option argument (may be empty)
   OPTARG="${OPTARG#=}"      # if long option argument, remove assigning `=`
 fi

case $OPT in
    n | nodes ) NODES=${OPTARG};;
    c | cpus )  CPUS=${OPTARG};;
    m | memory ) MEM="${OPTARG}";;
    t | walltime )  WALLTIME="${OPTARG}";;
    p | partition ) QUEUE="${OPTARG}";;
    a | account ) ACCOUNT="${OPTARG}";;
    q | qos )  qos=${OPTARG};;
    g | gpu )  GRES=${OPTARG};;
    e | email )  EMAIL="${OPTARG}";;
    l | login )  LOGIN=${OPTARG};;
    ??* ) die "Illegal option --$OPT" ;;  # bad long option
    ? ) exit 2 ;;  # bad short option (error reported via getopts)
esac
done

clear
# ARCH has a gpu partition but GRES/GPUs are needed
if [ ${GRES} -eq 0 ] && [ ${QUEUE} != "defq" ] ; then
   echo -e "\n Error: please add number of gpus, use -g "
   menu
   exit 1
fi

if [ ${GRES} != 0 ] && [ ${QUEUE} == "defq" ] ; then
   echo -e "\n Error: please add a valid partition for GPU, -p "
   menu
   exit 1
fi

# Wall clock limit:
date "+%d-%H:%M" -d "$WALLTIME" > /dev/null 2>&1
if [ $? != 0 ]
then
    echo "Date $WALLTIME NOT a valid d-hh:mm WALLTIME"
    exit 1
fi

export TIME=$(echo $WALLTIME | cut -d - -f 1)
export TIME=30

# the arguments is a function name
# type $@ &>/dev/null && create $MODEL || menu
create $LOGIN
exit 0
