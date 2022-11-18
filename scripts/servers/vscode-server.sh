#!/bin/bash
# -*- coding: utf-8 -*-
# SLURM job script for run VSCode into Singularity container
# The Advanced Research Computing at Hopkins (ARCH)
# Ricardo S Jacomini < rdesouz4 @ jhu.edu >
# Date: Sep, 17 2022

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
# SLURM script to run the VSCode-Server
#
# ---------------------------------------------------
#  INPUT ENVIRONMENT VARIABLES
# ---------------------------------------------------
#SBATCH --job-name=vscode_${USER}
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
#SBATCH --output=vscode-server.job.%j.out
# ---------------------------------------------------

EOF

cat >> $1 << \EOF

module restore
module load git vscodeserver/4.7.0

CODE_SERVER_DATAROOT=${HOME}/vscodeserver/4.7.0

if [[ ! -d  $CODE_SERVER_DATAROOT/extensions ]]; then
    mkdir -p $CODE_SERVER_DATAROOT/extensions
    rsync -rpa  $EXTENSIONS/extensions/ $CODE_SERVER_DATAROOT/extensions
fi

# Print compute node.
echo "$(date): Running on compute node ${host}:$port"

CPP_FILE=${CODE_SERVER_DATAROOT}/c_cpp_properties.json

if [[ -f "$CPP_FILE" ]]; then
    CPP_DIR="${TMPDIR:=/tmp/$USER}/cpp-vscode"
    mkdir -p "$CPP_DIR"
    chmod 700 "$CPP_DIR"

    # if the file is empty, let's initialize it
    [ -s "$CPP_FILE" ] || echo '{"configurations": [{ "name": "Linux", "browse": { "databaseFilename": null }}], "version": 4}' > "$CPP_FILE"

    jq --arg dbfile "$CPP_DIR/cpp-vscode.db" \
      '.configurations[0].browse.databaseFilename = $dbfile' \
      "$CPP_FILE" > "$CPP_FILE".new

    mv "$CPP_FILE".new "$CPP_FILE"
fi

#
# Start Code Server.
#
echo "$(date): Started code-server"
echo ""

readonly export PORT=$(python -c 'import socket; s=socket.socket(); s.bind(("", 0)); print(s.getsockname()[1]); s.close()')

EOF

}

function rockfish
{

cat >> $1 << \EOF
# Expose the password to the code-server.
export PASSWORD=$(crypde.sh -d ${HOME}/vscodeserver/.cretendials)

cat 1>&2 <<END

1. SSH tunnel from your workstation using the following command:

   ssh -N -L ${PORT}:${HOSTNAME}:${PORT} ${USER}@login.rockfish.jhu.edu

2. log in to VSCode Server in your web browser using the Rockfish cluster credentials (username and password) at:

   http://localhost:${PORT}
   password: < Rochkfish password >

3. When done using VSCode Server, terminate the job by:

   a. Exit the VSCode Session ("power" button in the top right corner of the VSCode window)
   b. Issue the following command on the login node:

  scancel -f ${SLURM_JOB_ID}
END

code-server \
    --auth=password \
    --bind-addr="0.0.0.0:${PORT}" \
    --disable-telemetry \
    --extensions-dir=${CODE_SERVER_DATAROOT}/extensions \
    --user-data-dir=${CODE_SERVER_DATAROOT} \
    ${HOME}

EOF

}

function none
{

cat > $1 << \EOF
cat 1>&2 <<END
1. SSH tunnel from your workstation using the following command:

	ssh -N -L ${PORT}:${HOSTNAME}:${PORT} ${USER}@login.rockfish.jhu.edu

2. log in to VSCode Server in your web browser using the Rockfish cluster credentials (username and password) at:

	http://localhost:${PORT}

3. VSCode Server is runnig without credentials!

4. When done using VSCode Server, terminate the job by:

	a. Exit the VSCode Session ("power" button in the top right corner of the VSCode window)
	b. Issue the following command on the login node:

	scancel -f ${SLURM_JOB_ID}
END

code-server \
    --auth=none \
    --bind-addr="0.0.0.0:${PORT}" \
    --disable-telemetry \
    --extensions-dir=${CODE_SERVER_DATAROOT}/extensions \
    --user-data-dir=${CODE_SERVER_DATAROOT} \
    ${HOME}
EOF

}

function random
{

cat > $1 << \EOF

# Expose the password to the code-server.
export PASSWORD=$(openssl rand -base64 15)

cat 1>&2 <<END
1. SSH tunnel from your workstation using the following command:

	ssh -N -L ${PORT}:${HOSTNAME}:${PORT} ${USER}@login.rockfish.jhu.edu

2. log in to VSCode Server in your web browser using the Rockfish cluster credentials (username and password) at:

	http://localhost:${PORT}

3. log in to VSCode Server using:

	password: ${PASSWORD}

4 . When done using VSCode Server, terminate the job by:

	a. Exit the VSCode Session ("power" button in the top right corner of the VSCode window)
	b. Issue the following command on the login node:

	scancel -f ${SLURM_JOB_ID}
END

code-server \
    --auth=password \
    --bind-addr="0.0.0.0:${PORT}" \
    --disable-telemetry \
    --extensions-dir=${CODE_SERVER_DATAROOT}/extensions \
    --user-data-dir=${CODE_SERVER_DATAROOT} \
    ${HOME}
EOF

}

function GATEKEEPER
{
  read -s -p "? " passwd

  if [[ ! -d  ${HOME}/vscodeserver/4.7.0/ ]]; then
      mkdir -p ${HOME}/vscodeserver/4.7.0/
  fi

  RESULT=$(gatekeeper_auth $USER $passwd)

  if [[ $? -eq 0 ]]; then
    crypde.sh -c $passwd ${HOME}/vscodeserver/.cretendials
    chmod 600 ${HOME}/vscodeserver/.cretendials
    return 0
  else
    return 1
  fi

}


function create_login_vscode
{
  vscode_menu

  echo -e "\nThis script will create an encrypted password (~/vscodeserver/.cretendials) file to access vscode \nor update it if older than 30 days. \n"
  echo -e "\nNote: If you changed your Rockfish cretendials, please remove the (~/vscodeserver/.cretendials) file to script update it."

  echo -e "\nSign in with your Rockfish Login credentials: \n"
  echo -e "\t Enter the ${USER} password: "

  counter=0

  until [ $counter -gt 2 ]
   do
    ((counter++))
    echo -e "Attempt $counter of 3"

    GATEKEEPER

    if [[ $? -eq 0  ]]; then
       break;
    fi

    if [[ counter -eq 3 ]]; then
      echo -e "The password provided does not match the Rockfish login credentials! \n"
      echo -e "The password was not validated, try it again, ! \n"
      exit 1
    fi
    echo -e "The password provided does not match the Rockfish login credentials! \n"
  done
}

function create_password_to_login_vscode
{
  clear

  if [[ ( ${HOME}/vscodeserver/.cretendials) ]]; then
     if [[ ! $(find ${HOME}/vscodeserver/.cretendials -mtime +30 2>/dev/null) ]]; then
        return
     fi
  fi

  create_login_vscode
  clear

}


function run ()
{

	sbr="$(sbatch "$@")"

  sleep 5

  #NODE=$(sacct -j ${JobId} -o nodelist | tail -n 1 | tr -d ' ')

	if [[ "$sbr" =~ Submitted\ batch\ job\ ([0-9]+) ]]; then
		echo -e "\n\nHow to login to VSCode Server see details in: \n"
	  echo "vscode-server.job.${BASH_REMATCH[1]}.out"
    echo -e "\n"
	else
	  echo "sbatch failed"
	  exit 1
	fi
}

function promptyn () {
    while true; do
        read -p "$1 " yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

function vscode_menu

{
  echo "
The ${0##*/} script will starts a SLURM job script to Run VS Code on any computer node.
You can the VS Code anywhere and access it in a browser.

Use ${0##*/} --help for more details.

1) Slurm script to run jupyterlab ($SCRIPT)
2) Instructions how to add multiple envs using python kernels (VSCode_server.info)

<Ctrl+C> to cancel
"
}

function create
{

  SCRIPT=VSCode-Server.slurm.script

  echo -e "\n Creating slurm script: $SCRIPT \n"

  if [  $1 == "rockfish" ]; then
     create_password_to_login_vscode
  fi

  tmpfile_header=$(mktemp /tmp/header-slurm.XXXXXXXXXX)
  tmpfile_function=$(mktemp /tmp/function-slurm.XXXXXXXXXX)

  Header $tmpfile_header
  # Call function passed as argument
  $1 $tmpfile_function
  cat $tmpfile_header $tmpfile_function > $SCRIPT
  rm $tmpfile_header $tmpfile_function

  echo -e "\n The Advanced Research Computing at Hopkins (ARCH)"
  echo -e " SLURM job script for run VSCode"
  echo -e " Support:  help@rockfish.jhu.edu \n"

  echo -e  " Nodes:       \t$NODES"
  echo -e  " Cores/task:  \t$CPUS"
  echo -e  " Total cores: \t$(echo $NODES*$CPUS | bc)"
  echo -e  " Walltime:    \t$WALLTIME"
  echo -e  " Queue:       \t$QUEUE"

  echo -e "\n The VSCode-Server is ready to run.  \n"
  echo -e " 1 - Usage: \n"
  echo -e "\t $ sbatch ${SCRIPT}  \n"

  echo -e " 2 - How to login see login file (after step 1): \n"
  echo -e "\t $ cat vscode-server.job.<SLURM_JOB_ID>.out \n"

  echo -e " 3 - More information about the job (after step 1): \n"
  echo -e "\t $ scontrol show jobid <SLURM_JOB_ID> \n"

  echo -e " 4 - Instructions for adding multiple envs using python kernels: \n"
  echo -e "\t $ cat VSCode_server.info \n"

  echo -e "\nInstructions for adding multiple envs using python kernels:
  \n \t $ module load jupyterlab/3.4.5
  \n # Install Jupyter kernel
  \n \t (myenv)$ ipython kernel install --user --name=<any_name_for_kernel> --display-name \"Python (myenv)\"
  \n # List kernels
  \n \t (myenv)$ jupyter kernelspec list"

  echo -e "\nInstructions for adding multiple envs using python kernels:
  \n \t $ module load jupyterlab/3.4.5
  \n # Install Jupyter kernel
  \n \t (myenv)$ ipython kernel install --user --name=<any_name_for_kernel> --display-name \"Python (myenv)\"
  \n # List kernels
  \n \t (myenv)$ jupyter kernelspec list"  > VSCode_server.info


	exit 0
}

function usage_login
{
  clear
  echo "Admin Menu"

  echo -e "
  Usage: ${0##*/} [options] [arguments]
                  [-n nodes] [-c cpus] [-m memory] [-t walltime] [-p partition] [-a account] [-q qos] [-g gpu] [-e email] [-l login]

  Starts a SLURM job script to Run VS Code on any computer node anywhere and access it in the browser

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

  Starts a SLURM job script to Run VS Code on any computer node anywhere and access it in the browser
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
if [[ ("$1" == *"l"*) && ( "$1" != *"help"*) ]]
then
	usage_login
fi

if [[ ( "$1" == *"h"* ) || ( "$1" == *"?"*)  ]]
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
