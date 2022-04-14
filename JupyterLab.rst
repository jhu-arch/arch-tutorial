JupyterLab
##########

The JupyterLab is the latest web-based interactive development environment for notebooks, code, and data. Its flexible interface allows users to configure and arrange workflows in data science, scientific computing, computational journalism, and machine learning.

The users can access the JupyterLab on Rockfish using the ``jupyterlab.sh`` command. It will create a SLURM script.

Usage examples to start the JupyterLab service:

.. code-block:: console

  $ jupyterlab.sh -h
  $ jupyterlab.sh -n 1 -c 2 -m 8G -t 1-02:0 -p defq (default)
  $ jupyterlab.sh -c 2 -t 4:0:0 -p defq -e <userid>@jhu.edu
  $ jupyterlab.sh -c 24 -g 2 -p a100 -a <PI-userid>_gpu

After running ``jupyterlab.sh`` you will see details about the script created in the current directory, like this next code-block below.

.. tip::
  Once run the ``jupyterlab.sh`` command for the first time, a python virtual environment (~/jp_lab) will be installed with needed packages to run JupyterLab in your HOME directory.

.. code-block:: console

  Use jupyterlab.sh –help for more details.

  1) Slurm script to run jupyterlab (jupyter_lab.slurm.script)
  2) File with login information (Jupyter_lab.job..login)
  3) File related to slurm INPUT ENVIRONMENT VARIABLES and HTTPS server information (Jupyter_lab.info)
  4) Notebook server file (.jupyter/jupyter_notebook_config.py)
  5) The jupyter-lab, ipykernal, pip will be installed/updated in: /home/$USER/jp_lab

  <Ctrl+C> to cancel

  Sign in with your Rockfish Login credentials:

	Enter the $USER password:

  Attempt 1 of 3
  ?

  Sign in with your Rockfish Login credentials:

  Enter the $USER password:

  Creating slurm script: /home/$USER/jupyter_lab.slurm.script

  SLURM job script for run Jupyter Lab

  The Jupyter Lab is ready to run.

  1 - Usage:

 	 $ sbatch jupyter_lab.slurm.script

  2 - How to login see login file (after step 1):

 	 $ cat Jupyter_lab.job.<SLURM_JOB_ID>.login

  3 - Further information:

 	 $ cat Jupyter_lab.info

  Instructions for adding multiple envs:

  # change to the proper version of python or conda

  # For Python Virtual environment

 	 $ module load python; source <myenv>/bin/activate

  # For Conda environment

 	 $ module load conda; conda activate <myenv>

  then:

 	 (myenv)$ pip install ipykernel

  # Install Jupyter kernel

 	 (myenv)$ ipython kernel install --user --name=<any_name_for_kernel> --display-name "Python (myenv)"

  # List kernels

 	 (myenv)$ jupyter kernelspec list

.. note::
  The jupyterlab.sh script will create a slurm script for multiple environments with jupyterlab and #SBATCH with default parameters.
